import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/editable_dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";

void main() {
  Widget createTestWidget({
    required DynamicField fieldData,
    required Function(String?) onValueChange,
    Map<String, dynamic>? document,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DynamicFormEditableDropdown(
          fieldData: fieldData,
          document: document,
          onValueChange: onValueChange,
        ),
      ),
    );
  }

  group("DynamicFormEditableDropdown", () {
    final fieldData = DynamicField(
      controlType: FieldType.dropdown,
      key: "testField",
      label: "Test Label",
      required: false,
      rowData: 1,
      enabledDefault: true,
      isDisable: false,
      optionList: [
        Option(key: "opt1", pairValue: "Option 1"),
        Option(key: "opt2", pairValue: "Option 2"),
      ],
    );

    testWidgets("initializes with no value when document is null",
        (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        createTestWidget(
          fieldData: fieldData,
          document: null,
          onValueChange: (val) => changedValue = val,
        ),
      );
      changedValue = changedValue;
      // Check CustomDropdown exists
      expect(find.byType(CustomDropdown<Option>), findsOneWidget);
    });

    testWidgets("initializes with matching option from document",
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          fieldData: fieldData,
          document: {"testField": "opt1"},
          onValueChange: (_) {},
        ),
      );

      // 'Option 1' is the value for key 'opt1'
      expect(find.text("Option 1"), findsOneWidget);
    });

    testWidgets("initializes with custom text when value does not match option",
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          fieldData: fieldData,
          document: {"testField": "Custom Value"},
          onValueChange: (_) {},
        ),
      );

      // Custom text is hidden until edit mode is activated
      final editIcon = find.byIcon(Icons.edit_outlined);
      expect(editIcon, findsOneWidget);
      await tester.tap(editIcon);
      await tester.pumpAndSettle();

      expect(find.text("Custom Value"), findsOneWidget);
    });

    testWidgets("calls onValueChange when option is selected", (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        createTestWidget(
          fieldData: fieldData,
          document: null,
          onValueChange: (val) => changedValue = val,
        ),
      );

      // Open dropdown
      final dropdown = find.byType(CustomDropdown<Option>);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Select Option 2
      final option2 = find.text("Option 2").last;
      await tester.ensureVisible(option2);
      await tester.tap(option2, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(changedValue, "opt2");
      expect(find.text("Option 2"), findsOneWidget);
    });

    testWidgets("calls onValueChange when text is edited", (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        createTestWidget(
          fieldData: fieldData,
          document: null,
          onValueChange: (val) => changedValue = val,
        ),
      );

      // Tap edit icon to enter edit mode
      final editIcon = find.byIcon(Icons.edit_outlined);
      await tester.tap(editIcon);
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, "New Text");
      await tester.pump(); // onTextChanged triggers immediately

      expect(changedValue, "New Text");
    });

    testWidgets("updates state when document changes externally",
        (tester) async {
      // 1. Init with Option 1
      await tester.pumpWidget(
        createTestWidget(
          fieldData: fieldData,
          document: {"testField": "opt1"},
          onValueChange: (_) {},
        ),
      );
      expect(find.text("Option 1"), findsOneWidget);

      // 2. Update with Option 2
      await tester.pumpWidget(
        createTestWidget(
          fieldData: fieldData,
          document: {"testField": "opt2"},
          onValueChange: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Option 2"), findsOneWidget);

      // 3. Update with Custom Text
      await tester.pumpWidget(
        createTestWidget(
          fieldData: fieldData,
          document: {"testField": "Custom"},
          onValueChange: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      // Verify custom text by entering edit mode
      final editIcon = find.byIcon(Icons.edit_outlined);
      await tester.tap(editIcon);
      await tester.pumpAndSettle();

      expect(find.text("Custom"), findsOneWidget);
    });

    testWidgets("updates onValueChange to null when text cleared",
        (tester) async {
      String? changedValue = "initial";
      await tester.pumpWidget(
        createTestWidget(
          fieldData: fieldData,
          document: {"testField": "Custom"},
          onValueChange: (val) => changedValue = val,
        ),
      );

      final editIcon = find.byIcon(Icons.edit_outlined);
      await tester.tap(editIcon);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), "");
      await tester.pump();

      expect(changedValue, null);
    });

    testWidgets("initializes as custom text when optionList is null",
        (tester) async {
      final noOptionsField = DynamicField(
        controlType: FieldType.dropdown,
        key: "testField",
        label: "No Options",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: null, // optionList is explicitly null
      );

      await tester.pumpWidget(
        createTestWidget(
          fieldData: noOptionsField,
          document: {"testField": "Only Custom Value"},
          onValueChange: (_) {},
        ),
      );

      // Need to activate edit mode as there are no options
      final editIcon = find.byIcon(Icons.edit_outlined);
      expect(editIcon, findsOneWidget);
      await tester.tap(editIcon);
      await tester.pumpAndSettle();

      expect(find.text("Only Custom Value"), findsOneWidget);
    });

    testWidgets("handles validation message correctly when required",
        (tester) async {
      final requiredField = DynamicField(
        controlType: FieldType.dropdown,
        key: "requiredField",
        label: "Required Label",
        required: true,
        message: "Custom required message",
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [Option(key: "opt1", pairValue: "Option 1")],
      );

      await tester.pumpWidget(
        createTestWidget(
          fieldData: requiredField,
          document: null,
          onValueChange: (_) {},
        ),
      );

      final dropdown = find.byType(CustomDropdown<Option>);
      expect(dropdown, findsOneWidget);

      final dropdownWidget = tester.widget<CustomDropdown<Option>>(dropdown);
      // Validating internal string passed down
      expect(dropdownWidget.validationMessage, "Custom required message");
    });

    testWidgets(
        "handles default validation message correctly"
        " when required but no message", (tester) async {
      final requiredField = DynamicField(
        controlType: FieldType.dropdown,
        key: "requiredField",
        label: "Required Label",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [Option(key: "opt1", pairValue: "Option 1")],
      );

      await tester.pumpWidget(
        createTestWidget(
          fieldData: requiredField,
          document: null,
          onValueChange: (_) {},
        ),
      );

      final dropdown = find.byType(CustomDropdown<Option>);
      final dropdownWidget = tester.widget<CustomDropdown<Option>>(dropdown);
      expect(dropdownWidget.validationMessage, "Required Label is required");
    });

    testWidgets("verifies filterFn searches items correctly", (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          fieldData: fieldData,
          document: null,
          onValueChange: (_) {},
        ),
      );

      final dropdown = find.byType(CustomDropdown<Option>);
      final dropdownWidget = tester.widget<CustomDropdown<Option>>(dropdown);

      final filterFn = dropdownWidget.filterFn!;

      expect(filterFn(Option(key: "1", pairValue: "Apple"), "app"), isTrue);
      expect(filterFn(Option(key: "2", pairValue: "Banana"), "app"), isFalse);
      expect(filterFn(Option(key: "3", pairValue: null), "app"), isFalse);
    });

    testWidgets("verifies dropdownBuilder handles null values", (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          fieldData: fieldData,
          document: null,
          onValueChange: (_) {},
        ),
      );

      final dropdown = find.byType(CustomDropdown<Option>);
      final dropdownWidget = tester.widget<CustomDropdown<Option>>(dropdown);

      final builder = dropdownWidget.dropdownBuilder;
      if (builder != null) {
        final widget = builder(
          tester.element(find.byType(CustomDropdown<Option>)),
          Option(key: "null_val", pairValue: null),
        );
        expect(widget, isA<Text>());
        expect((widget as Text).data, "");
      }
    });

    testWidgets("triggers onEditComplete for custom text", (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        createTestWidget(
          fieldData: fieldData,
          document: null,
          onValueChange: (val) => changedValue = val,
        ),
      );

      final dropdown = find.byType(CustomDropdown<Option>);
      final dropdownWidget = tester.widget<CustomDropdown<Option>>(dropdown);

      // Simulate onEditComplete callback directly
      dropdownWidget.onEditComplete?.call("Final Value");
      expect(changedValue, "Final Value");

      dropdownWidget.onEditComplete?.call("");
      expect(changedValue, null);
    });
  });
}
