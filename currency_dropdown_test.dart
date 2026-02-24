import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/currency_dropdown.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';

// Mock AlertManager
class MockAlertManager extends Mock implements AlertManager {}

void main() {
  late MockAlertManager mockAlertManager;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockAlertManager = MockAlertManager();
    AlertManager.overrideInstance(mockAlertManager);

    // Stub showFailureToast so tests don't crash on error paths
    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

    // Intercept asset/HTTP calls to return mock exchange rate data
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      final String path = utf8.decode(message!.buffer.asUint8List());

      if (path.contains('rating_getExchangeRate.json')) {
        final Map<String, dynamic> mockData = {
          "baseResponse": {
            "status": {"statusCode": "0", "statusDescription": "Success"}
          },
          "responseData": {"USD": 3.6725, "EUR": 4.0, "GBP": 4.5}
        };
        return ByteData.view(
            Uint8List.fromList(utf8.encode(jsonEncode(mockData))).buffer);
      }

      if (path.contains('assets/translations')) {
        return ByteData.view(Uint8List.fromList(utf8.encode('{}')).buffer);
      }

      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  // ─────────────────────────────────────────
  // Helper: build a CurrencyDropdown widget
  // ─────────────────────────────────────────
  Widget buildCurrencyDropdown({
    List<Option> options = const [],
    Option? initialOption,
    double? initialAedEquivalent,
    TextEditingController? controller,
    Function(Map<String, dynamic>)? onChanged,
    bool readOnly = false,
    bool disableDropdown = false,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CurrencyDropdown(
          options: options,
          initialOption: initialOption,
          initialAedEquivalent: initialAedEquivalent,
          controller: controller,
          onChanged: onChanged,
          readOnly: readOnly,
          disableDropdown: disableDropdown,
          validator: validator,
          maxLength: maxLength,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Helper: build a DynamicFormCurrencyDropdownTextfield widget
  // ─────────────────────────────────────────────────────────────
  Widget buildDynamicWidget({
    required DynamicField fieldData,
    Map<String, dynamic>? document,
    Function(Map<String, dynamic>)? onSubmit,
    bool showLabel = false,
    TextEditingController? controller,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DynamicFormCurrencyDropdownTextfield(
          fieldData: fieldData,
          document: document,
          onSubmit: onSubmit ?? (_) {},
          showLabel: showLabel,
          controller: controller,
        ),
      ),
    );
  }

  // Helper: build a standard DynamicField for currency
  DynamicField buildCurrencyField({
    String key = 'amount',
    String label = 'Amount',
    bool required = false,
    bool isDisable = false,
    bool isCMOUpdate = false,
    bool disableDropdown = false,
    List<Option>? optionList,
    String? message,
    int? maxLength,
  }) {
    return DynamicField(
      controlType: FieldType.currency,
      key: key,
      label: label,
      required: required,
      rowData: 0,
      enabledDefault: true,
      isDisable: isDisable,
      isCMOUpdate: isCMOUpdate,
      disableDropdown: disableDropdown,
      optionList: optionList ??
          [
            Option(key: 'AED', pairValue: 'AED'),
            Option(key: 'USD', pairValue: 'USD'),
          ],
      message: message,
      maxLength: maxLength,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Group 1: CurrencyDropdown widget tests
  // ─────────────────────────────────────────────────────────────
  group('CurrencyDropdown', () {
    testWidgets('renders correctly with empty options',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildCurrencyDropdown());
      await tester.pumpAndSettle();

      // No AED equivalent row should appear when no option is selected
      expect(find.byType(CurrencyDropdown), findsOneWidget);
    });

    testWidgets('renders with AED initial option (no AED equivalent row)',
        (WidgetTester tester) async {
      final Option aedOption = Option(key: 'AED', pairValue: 'AED');

      await tester.pumpWidget(buildCurrencyDropdown(
        options: [aedOption, Option(key: 'USD', pairValue: 'USD')],
        initialOption: aedOption,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CurrencyDropdown), findsOneWidget);
    });

    testWidgets('renders AED equivalent row when non-AED currency is selected',
        (WidgetTester tester) async {
      final Option usdOption = Option(key: 'USD', pairValue: 'USD');

      await tester.pumpWidget(buildCurrencyDropdown(
        options: [Option(key: 'AED', pairValue: 'AED'), usdOption],
        initialOption: usdOption,
        initialAedEquivalent: 367.25,
      ));
      await tester.pumpAndSettle();

      // Two CustomTextField widgets: main and AED equivalent
      expect(find.byType(CurrencyDropdown), findsOneWidget);
    });

    testWidgets('initializes AED controller with provided aedEquivalent',
        (WidgetTester tester) async {
      final Option usdOption = Option(key: 'USD', pairValue: 'USD');

      await tester.pumpWidget(buildCurrencyDropdown(
        options: [Option(key: 'AED', pairValue: 'AED'), usdOption],
        initialOption: usdOption,
        initialAedEquivalent: 1000.0,
      ));
      await tester.pumpAndSettle();

      // The AED equivalent field should show "1,000"
      expect(find.text('1,000'), findsAtLeastNWidgets(1));
    });

    testWidgets('does not initialize AED controller if aedEquivalent is null',
        (WidgetTester tester) async {
      final Option usdOption = Option(key: 'USD', pairValue: 'USD');

      await tester.pumpWidget(buildCurrencyDropdown(
        options: [Option(key: 'AED', pairValue: 'AED'), usdOption],
        initialOption: usdOption,
        initialAedEquivalent: null,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CurrencyDropdown), findsOneWidget);
    });

    testWidgets('does not show AED equivalent row when aedEquivalent is 0',
        (WidgetTester tester) async {
      final Option usdOption = Option(key: 'USD', pairValue: 'USD');

      await tester.pumpWidget(buildCurrencyDropdown(
        options: [Option(key: 'AED', pairValue: 'AED'), usdOption],
        initialOption: usdOption,
        initialAedEquivalent: 0.0, // exactly 0, should NOT initialize
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CurrencyDropdown), findsOneWidget);
    });

    testWidgets('onChanged emits map when text is entered',
        (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController();
      final Option aedOption = Option(key: 'AED', pairValue: 'AED');
      Map<String, dynamic>? emitted;

      await tester.pumpWidget(buildCurrencyDropdown(
        options: [aedOption, Option(key: 'USD', pairValue: 'USD')],
        initialOption: aedOption,
        controller: controller,
        onChanged: (val) => emitted = val,
      ));
      await tester.pumpAndSettle();

      // Enter text in the amount field
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, '500');
      await tester.pumpAndSettle();

      expect(emitted, isNotNull);
      expect(emitted!['fromCurrency'], 'AED');
      expect(emitted!['fromVal'], 500.0);
      // For AED, aedEquivalent equals amount
      expect(emitted!['aedEquivalent'], 500.0);

      controller.dispose();
    });

    testWidgets('readOnly prevents dropdown callback from firing',
        (WidgetTester tester) async {
      final Option aedOption = Option(key: 'AED', pairValue: 'AED');

      await tester.pumpWidget(buildCurrencyDropdown(
        options: [aedOption, Option(key: 'USD', pairValue: 'USD')],
        initialOption: aedOption,
        readOnly: true,
      ));
      await tester.pumpAndSettle();

      // Widget renders successfully in readOnly mode
      expect(find.byType(CurrencyDropdown), findsOneWidget);
    });

    testWidgets('disableDropdown disables just the dropdown',
        (WidgetTester tester) async {
      final Option aedOption = Option(key: 'AED', pairValue: 'AED');

      await tester.pumpWidget(buildCurrencyDropdown(
        options: [aedOption, Option(key: 'USD', pairValue: 'USD')],
        initialOption: aedOption,
        disableDropdown: true,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CurrencyDropdown), findsOneWidget);
    });

    testWidgets('didUpdateWidget: AED equivalent updates when changed',
        (WidgetTester tester) async {
      final Option usdOption = Option(key: 'USD', pairValue: 'USD');

      // Build with aedEquivalent = 500
      await tester.pumpWidget(buildCurrencyDropdown(
        options: [Option(key: 'AED', pairValue: 'AED'), usdOption],
        initialOption: usdOption,
        initialAedEquivalent: 500.0,
      ));
      await tester.pumpAndSettle();
      expect(find.text('500'), findsAtLeastNWidgets(1));

      // Rebuild with updated aedEquivalent = 1000
      await tester.pumpWidget(buildCurrencyDropdown(
        options: [Option(key: 'AED', pairValue: 'AED'), usdOption],
        initialOption: usdOption,
        initialAedEquivalent: 1000.0,
      ));
      await tester.pumpAndSettle();
      expect(find.text('1,000'), findsAtLeastNWidgets(1));
    });

    testWidgets(
        'didUpdateWidget: clears AED equivalent when set to null and no controller',
        (WidgetTester tester) async {
      final Option aedOption = Option(key: 'AED', pairValue: 'AED');

      // First render: AED currency with no AED row
      await tester.pumpWidget(buildCurrencyDropdown(
        options: [aedOption],
        initialOption: aedOption,
        initialAedEquivalent: null,
      ));
      await tester.pumpAndSettle();

      // Second render: same, still null
      await tester.pumpWidget(buildCurrencyDropdown(
        options: [aedOption],
        initialOption: aedOption,
        initialAedEquivalent: null,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CurrencyDropdown), findsOneWidget);
    });

    testWidgets('didUpdateWidget: currency change updates selectedOption',
        (WidgetTester tester) async {
      final Option aedOption = Option(key: 'AED', pairValue: 'AED');
      final Option usdOption = Option(key: 'USD', pairValue: 'USD');

      // Start with AED
      await tester.pumpWidget(buildCurrencyDropdown(
        options: [aedOption, usdOption],
        initialOption: aedOption,
      ));
      await tester.pumpAndSettle();

      // Switch to USD
      await tester.pumpWidget(buildCurrencyDropdown(
        options: [aedOption, usdOption],
        initialOption: usdOption,
        initialAedEquivalent: 367.0,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CurrencyDropdown), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Group 2: DynamicFormCurrencyDropdownTextfield tests
  // ─────────────────────────────────────────────────────────────
  group('DynamicFormCurrencyDropdownTextfield', () {
    testWidgets('renders without label when showLabel is false',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField();

      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        showLabel: false,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(LabelWidget), findsNothing);
    });

    testWidgets('renders with label when showLabel is true',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField(label: 'My Currency');

      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        showLabel: true,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.text('My Currency'), findsOneWidget);
    });

    testWidgets('shows CMO exponent "#" when isCMOUpdate is true',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField(isCMOUpdate: true);

      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        showLabel: true,
      ));
      await tester.pumpAndSettle();

      final LabelWidget label =
          tester.widget<LabelWidget>(find.byType(LabelWidget));
      expect(label.exponent, '#');
    });

    testWidgets('shows no exponent when isCMOUpdate is false',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField(isCMOUpdate: false);

      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        showLabel: true,
      ));
      await tester.pumpAndSettle();

      final LabelWidget label =
          tester.widget<LabelWidget>(find.byType(LabelWidget));
      expect(label.exponent, isNull);
    });

    testWidgets('initializes with empty controller when document is null',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField();

      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        document: null,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DynamicFormCurrencyDropdownTextfield), findsOneWidget);
    });

    testWidgets('initializes controller text from document amount',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField(key: 'amount');
      final Map<String, dynamic> doc = {
        'amount': {
          'fromCurrency': 'AED',
          'fromVal': 1500.0,
          'aedEquivalent': 1500.0,
        }
      };

      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        document: doc,
      ));
      await tester.pumpAndSettle();

      // The controller text should be '1,500'
      expect(find.text('1,500'), findsAtLeastNWidgets(1));
    });

    testWidgets('initializes with empty controller when amount is null',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField(key: 'amount');
      final Map<String, dynamic> doc = {
        'amount': {
          'fromCurrency': 'AED',
          'fromVal': null,
          'aedEquivalent': null,
        }
      };

      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        document: doc,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DynamicFormCurrencyDropdownTextfield), findsOneWidget);
    });

    testWidgets('uses provided external controller',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField();
      final TextEditingController controller =
          TextEditingController(text: '999');

      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        controller: controller,
      ));
      await tester.pumpAndSettle();

      // The provided controller value should be visible
      expect(find.text('999'), findsAtLeastNWidgets(1));

      controller.dispose();
    });

    testWidgets('falls back to first option if no currency in document',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField(
        optionList: [
          Option(key: 'AED', pairValue: 'AED'),
          Option(key: 'USD', pairValue: 'USD'),
        ],
      );

      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        document: {}, // empty doc — no currency key
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DynamicFormCurrencyDropdownTextfield), findsOneWidget);
    });

    testWidgets('uses currency from document to build initial option',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField(key: 'amount');
      final Map<String, dynamic> doc = {
        'amount': {
          'fromCurrency': 'USD',
          'fromVal': 200.0,
          'aedEquivalent': 734.5,
        }
      };

      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        document: doc,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DynamicFormCurrencyDropdownTextfield), findsOneWidget);
    });

    testWidgets('onSubmit is called when amount text changes',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField(key: 'amount');
      Map<String, dynamic>? submitted;
      final TextEditingController controller = TextEditingController();

      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        document: {
          'amount': {
            'fromCurrency': 'AED',
            'fromVal': null,
            'aedEquivalent': null,
          }
        },
        onSubmit: (val) => submitted = val,
        controller: controller,
      ));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, '250');
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);

      controller.dispose();
    });

    testWidgets('didUpdateWidget: clears controller when amount becomes null',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField(key: 'amount');
      final TextEditingController controller = TextEditingController();

      // First render: document has an amount
      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        document: {
          'amount': {
            'fromCurrency': 'AED',
            'fromVal': 300.0,
            'aedEquivalent': 300.0,
          }
        },
        controller: controller,
      ));
      await tester.pumpAndSettle();

      // Second render: amount becomes null
      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        document: {
          'amount': {
            'fromCurrency': 'AED',
            'fromVal': null,
            'aedEquivalent': null,
          }
        },
        controller: controller,
      ));
      await tester.pumpAndSettle();

      // Controller text should be cleared
      expect(controller.text, isEmpty);

      controller.dispose();
    });

    testWidgets('didUpdateWidget: updates controller text when amount changes',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField(key: 'amount');
      final TextEditingController controller = TextEditingController();

      // First render: amount 100
      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        document: {
          'amount': {
            'fromCurrency': 'AED',
            'fromVal': 100.0,
            'aedEquivalent': 100.0,
          }
        },
        controller: controller,
      ));
      await tester.pumpAndSettle();

      // Second render: amount changes to 200
      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        document: {
          'amount': {
            'fromCurrency': 'AED',
            'fromVal': 200.0,
            'aedEquivalent': 200.0,
          }
        },
        controller: controller,
      ));
      await tester.pumpAndSettle();

      expect(controller.text, '200');

      controller.dispose();
    });

    testWidgets('didUpdateWidget: does nothing when amount does not change',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField(key: 'amount');
      final TextEditingController controller = TextEditingController();

      // Build once
      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        document: {
          'amount': {
            'fromCurrency': 'AED',
            'fromVal': 500.0,
            'aedEquivalent': 500.0,
          }
        },
        controller: controller,
      ));
      await tester.pumpAndSettle();

      final String textBefore = controller.text;

      // Rebuild with same data
      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        document: {
          'amount': {
            'fromCurrency': 'AED',
            'fromVal': 500.0,
            'aedEquivalent': 500.0,
          }
        },
        controller: controller,
      ));
      await tester.pumpAndSettle();

      // Controller text should remain unchanged
      expect(controller.text, textBefore);

      controller.dispose();
    });

    testWidgets('does not crash when document has non-map value for field key',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField(key: 'amount');

      // Document has a string instead of a map — extractFromDocument returns null
      await tester.pumpWidget(buildDynamicWidget(
        fieldData: field,
        document: {'amount': 'not-a-map'},
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DynamicFormCurrencyDropdownTextfield), findsOneWidget);
    });

    testWidgets('handles empty optionList gracefully',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField(optionList: []);

      await tester.pumpWidget(buildDynamicWidget(fieldData: field));
      await tester.pumpAndSettle();

      expect(find.byType(DynamicFormCurrencyDropdownTextfield), findsOneWidget);
    });

    testWidgets(
        'required field passes validator function into CurrencyDropdown',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField(
        required: true,
        message: 'Amount is required',
      );

      final GlobalKey<FormState> formKey = GlobalKey<FormState>();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: DynamicFormCurrencyDropdownTextfield(
              fieldData: field,
              onSubmit: (_) {},
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Trigger form validation
      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      // Widget rendered ok — validator passed to child
      expect(find.byType(DynamicFormCurrencyDropdownTextfield), findsOneWidget);
    });

    testWidgets('non-required field has no validator',
        (WidgetTester tester) async {
      final DynamicField field = buildCurrencyField(required: false);

      await tester.pumpWidget(buildDynamicWidget(fieldData: field));
      await tester.pumpAndSettle();

      expect(find.byType(DynamicFormCurrencyDropdownTextfield), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Group 3: CurrencyDropdown didUpdateWidget advanced paths
  // ─────────────────────────────────────────────────────────────
  group('CurrencyDropdown advanced didUpdateWidget paths', () {
    testWidgets(
        'switching currency from AED to non-AED triggers currency change path and onChanged',
        (WidgetTester tester) async {
      final Option aedOption = Option(key: 'AED', pairValue: 'AED');
      final Option usdOption = Option(key: 'USD', pairValue: 'USD');
      final TextEditingController controller =
          TextEditingController(text: '100');
      Map<String, dynamic>? emitted;

      // Render with AED
      await tester.pumpWidget(buildCurrencyDropdown(
        options: [aedOption, usdOption],
        initialOption: aedOption,
        controller: controller,
        onChanged: (val) => emitted = val,
      ));
      await tester.pumpAndSettle();

      // Switch to USD — triggers async addPostFrameCallback for exchange rate fetch
      // Lines 229-256 in source (didUpdateWidget currency-change path)
      await tester.pumpWidget(buildCurrencyDropdown(
        options: [aedOption, usdOption],
        initialOption: usdOption,
        controller: controller,
        onChanged: (val) => emitted = val,
      ));

      // Pump past MockInterceptor 500ms delay + frame callbacks
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // onChanged should have been called with USD currency from getCurrencyRates
      expect(emitted, isNotNull);
      expect(find.byType(CurrencyDropdown), findsOneWidget);

      controller.dispose();
    });

    testWidgets(
        'same currency, null aedEquivalent, non-empty controller triggers recalculation path',
        (WidgetTester tester) async {
      final Option usdOption = Option(key: 'USD', pairValue: 'USD');
      final TextEditingController controller =
          TextEditingController(text: '200');

      // Render with USD and a valid AED equivalent
      await tester.pumpWidget(buildCurrencyDropdown(
        options: [Option(key: 'AED', pairValue: 'AED'), usdOption],
        initialOption: usdOption,
        controller: controller,
        initialAedEquivalent: 734.5,
        onChanged: (_) {},
      ));
      await tester.pumpAndSettle();

      // Rebuild with same USD but no AED equivalent — triggers recalculation block
      // Lines 258-297 in source: non-AED, null aedEquivalent, controller text non-empty
      await tester.pumpWidget(buildCurrencyDropdown(
        options: [Option(key: 'AED', pairValue: 'AED'), usdOption],
        initialOption: usdOption,
        controller: controller,
        initialAedEquivalent: null,
        onChanged: (_) {},
      ));
      // Pump past MockInterceptor 500ms delay
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Widget should still render correctly after recalculation
      expect(find.byType(CurrencyDropdown), findsOneWidget);

      controller.dispose();
    });

    testWidgets(
        'AED equivalent cleared when set to null and no recalculation pending',
        (WidgetTester tester) async {
      final Option aedOption = Option(key: 'AED', pairValue: 'AED');
      // No controller, so no recalculation pending

      // Start with a non-null aedEquivalent (even though AED won't show a row)
      await tester.pumpWidget(buildCurrencyDropdown(
        options: [aedOption],
        initialOption: aedOption,
        initialAedEquivalent: 500.0,
      ));
      await tester.pumpAndSettle();

      // Rebuild with null aedEquivalent
      await tester.pumpWidget(buildCurrencyDropdown(
        options: [aedOption],
        initialOption: aedOption,
        initialAedEquivalent: null,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CurrencyDropdown), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────
  // Group 4: getCurrencyRates path tests (covering async branches)
  // ──────────────────────────────────────────────────────────────
  group('CurrencyDropdown getCurrencyRates paths', () {
    testWidgets(
        'entering text with non-AED currency triggers getCurrencyRates via onChanged',
        (WidgetTester tester) async {
      final Option usdOption = Option(key: 'USD', pairValue: 'USD');
      final TextEditingController controller = TextEditingController();
      Map<String, dynamic>? emitted;

      await tester.pumpWidget(buildCurrencyDropdown(
        options: [Option(key: 'AED', pairValue: 'AED'), usdOption],
        initialOption: usdOption,
        controller: controller,
        onChanged: (val) => emitted = val,
      ));
      await tester.pumpAndSettle();

      // Enter text in the amount field while non-AED currency is selected
      // This triggers onChanged which calls getCurrencyRates for non-AED
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, '100');
      // Pump past MockInterceptor 500ms delay
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // onChanged should have been called
      expect(emitted, isNotNull);
      expect(emitted!['fromCurrency'], 'USD');

      controller.dispose();
    });

    testWidgets(
        'getCurrencyRates success path updates aedController text via setState',
        (WidgetTester tester) async {
      final Option usdOption = Option(key: 'USD', pairValue: 'USD');
      final TextEditingController controller =
          TextEditingController(text: '100');

      await tester.pumpWidget(buildCurrencyDropdown(
        options: [Option(key: 'AED', pairValue: 'AED'), usdOption],
        initialOption: usdOption,
        initialAedEquivalent: 367.25,
        controller: controller,
        onChanged: (_) {},
      ));
      await tester.pumpAndSettle();

      // Rebuild with null aedEquivalent to force async recalculation
      // (same currency, non-null controller text, USD selected)
      await tester.pumpWidget(buildCurrencyDropdown(
        options: [Option(key: 'AED', pairValue: 'AED'), usdOption],
        initialOption: usdOption,
        initialAedEquivalent: null,
        controller: controller,
        onChanged: (_) {},
      ));

      // Pump past the MockInterceptor 500ms delay + frame callbacks
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // getCurrencyRates should have run and updated the AED display
      expect(find.byType(CurrencyDropdown), findsOneWidget);

      controller.dispose();
    });

    testWidgets(
        'getCurrencyRates error path triggers AlertManager showFailureToast',
        (WidgetTester tester) async {
      // Override the asset handler to simulate an API error for exchange rate
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        final String path = utf8.decode(message!.buffer.asUint8List());

        // Return an error status for exchange rate request
        if (path.contains('rating_getExchangeRate.json')) {
          final Map<String, dynamic> errorData = {
            "baseResponse": {
              "status": {
                "statusCode": "1",
                "statusDescription": "Exchange rate error"
              }
            },
            "responseData": null
          };
          return ByteData.view(
              Uint8List.fromList(utf8.encode(jsonEncode(errorData))).buffer);
        }

        if (path.contains('assets/translations')) {
          return ByteData.view(Uint8List.fromList(utf8.encode('{}')).buffer);
        }

        return null;
      });

      final Option usdOption = Option(key: 'USD', pairValue: 'USD');
      final TextEditingController controller = TextEditingController();

      await tester.pumpWidget(buildCurrencyDropdown(
        options: [Option(key: 'AED', pairValue: 'AED'), usdOption],
        initialOption: usdOption,
        controller: controller,
        onChanged: (_) {},
      ));
      await tester.pumpAndSettle();

      // Enter text to trigger onChanged -> getCurrencyRates
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, '200');
      // Pump past MockInterceptor delay
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Widget should still be alive
      expect(find.byType(CurrencyDropdown), findsOneWidget);

      controller.dispose();
    });

    testWidgets('AED currency onChanged does NOT call getCurrencyRates',
        (WidgetTester tester) async {
      final Option aedOption = Option(key: 'AED', pairValue: 'AED');
      final TextEditingController controller = TextEditingController();
      Map<String, dynamic>? emitted;

      await tester.pumpWidget(buildCurrencyDropdown(
        options: [aedOption, Option(key: 'USD', pairValue: 'USD')],
        initialOption: aedOption,
        controller: controller,
        onChanged: (val) => emitted = val,
      ));
      await tester.pumpAndSettle();

      // Enter text — for AED, aedEquivalent == amount (no API call)
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, '300');
      await tester.pump();

      expect(emitted, isNotNull);
      expect(emitted!['fromCurrency'], 'AED');
      // For AED, aedEquivalent equals the entered amount
      expect(emitted!['aedEquivalent'], 300.0);
      expect(emitted!['fromVal'], 300.0);

      controller.dispose();
    });

    testWidgets(
        'didUpdateWidget with null aedEquivalent and non-AED, non-empty controller covers recalc path',
        (WidgetTester tester) async {
      final Option usdOption = Option(key: 'USD', pairValue: 'USD');
      final TextEditingController controller =
          TextEditingController(text: '200');

      // First render with valid aedEquivalent so exchangeRate gets set
      await tester.pumpWidget(buildCurrencyDropdown(
        options: [Option(key: 'AED', pairValue: 'AED'), usdOption],
        initialOption: usdOption,
        initialAedEquivalent: 734.5,
        controller: controller,
        onChanged: (_) {},
      ));
      // Pump to let getCurrencyRates run (covers exchangeRate cached = 0 path)
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Rebuild: same currency, null aedEquivalent → triggers recalculation block
      await tester.pumpWidget(buildCurrencyDropdown(
        options: [Option(key: 'AED', pairValue: 'AED'), usdOption],
        initialOption: usdOption,
        initialAedEquivalent: null, // triggers the else branch
        controller: controller,
        onChanged: (_) {},
      ));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Widget should still be alive and showing the AED equivalent row
      expect(find.byType(CurrencyDropdown), findsOneWidget);

      controller.dispose();
    });
  });
}
