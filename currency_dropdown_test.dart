import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/currency_dropdown.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
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

    // Mock rootBundle for assets
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
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

  Widget createSubject({
    required DynamicField fieldData,
    Function(Map<String, dynamic>)? onSubmit,
    Map<String, dynamic>? document,
    bool showLabel = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DynamicFormCurrencyDropdownTextfield(
          fieldData: fieldData,
          onSubmit: onSubmit ?? (_) {},
          document: document,
          showLabel: showLabel,
        ),
      ),
    );
  }

  group('DynamicFormCurrencyDropdownTextfield Tests', () {
    final validOptions = [
      Option(key: 'AED', pairValue: 'AED'),
      Option(key: 'USD', pairValue: 'USD'),
      Option(key: 'EUR', pairValue: 'EUR'),
    ];

    final fieldData = DynamicField(
      key: 'test_currency',
      label: 'Currency',
      optionList: validOptions,
      maxLength: 10,
      controlType: FieldType.currency,
      required: true,
      rowData: 1,
      enabledDefault: true,
      isDisable: true,
    );

    testWidgets('Formatting applied to text input', (tester) async {
      await tester.pumpWidget(createSubject(fieldData: fieldData));
      await tester.enterText(find.byType(TextField).first, '5000');
      await tester.pump();
      expect(find.text('5,000'), findsOneWidget);
    });
  });
}
