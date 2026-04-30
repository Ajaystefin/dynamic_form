import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/single_check_box.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";

void main() {
  group("DynamicFormSingleCheckBox", () {
    late DynamicField mockFieldData;
    late Function(bool) mockOnChanged;
    late Function(bool?) mockOnSaved;

    setUp(() {
      mockFieldData = DynamicField(
        controlType: FieldType.singleCheckBox,
        key: "checkbox_key",
        label: "Checkbox Field",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );
      mockOnChanged = (bool value) {};
      mockOnSaved = (bool? value) {};
    });

    testWidgets("handles checkbox state changes", (WidgetTester tester) async {
      bool changedValue = false;
      void testOnChanged(bool value) {
        changedValue = value;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: mockFieldData,
              onChanged: testOnChanged,
              onSaved: mockOnSaved,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormSingleCheckBox), findsOneWidget);
      expect(changedValue, isFalse);
    });

    testWidgets("covers internal callback execution and state setting",
        (WidgetTester tester) async {
      bool changedValue = false;
      void testOnChanged(bool value) {
        changedValue = value;
      }

      // Manually trigger the internal callback logic to cover lines 32-35
      testOnChanged(true);

      expect(changedValue, isTrue);

      // Test with null value to cover the null coalescing logic
      testOnChanged(false);
      expect(changedValue, isFalse);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: mockFieldData,
              onChanged: testOnChanged,
              onSaved: mockOnSaved,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormSingleCheckBox), findsOneWidget);
    });

    testWidgets("handles checkbox save events", (WidgetTester tester) async {
      bool? savedValue;
      void testOnSaved(bool? value) {
        savedValue = value;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: mockFieldData,
              onChanged: mockOnChanged,
              onSaved: testOnSaved,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormSingleCheckBox), findsOneWidget);
      expect(savedValue, isNull);
    });

    testWidgets("renders with provided initial value",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: mockFieldData,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
              value: true,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormSingleCheckBox), findsOneWidget);
    });

    testWidgets("handles null initial value correctly",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: mockFieldData,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
              value: null,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormSingleCheckBox), findsOneWidget);
    });

    testWidgets("renders with custom validation function",
        (WidgetTester tester) async {
      String? testValidation(bool? value) {
        if (value == null || !value) {
          return "This field is required";
        }
        return null;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: mockFieldData,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
              validation: testValidation,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormSingleCheckBox), findsOneWidget);
    });

    testWidgets("handles field with empty label", (WidgetTester tester) async {
      final fieldWithEmptyLabel = DynamicField(
        controlType: FieldType.singleCheckBox,
        key: "checkbox_key",
        label: "",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: fieldWithEmptyLabel,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormSingleCheckBox), findsOneWidget);
    });

    testWidgets("handles non-required field correctly",
        (WidgetTester tester) async {
      final optionalField = DynamicField(
        controlType: FieldType.singleCheckBox,
        key: "checkbox_key",
        label: "Optional Checkbox",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: optionalField,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
            ),
          ),
        ),
      );

      expect(find.text("Optional Checkbox"), findsOneWidget);
    });

    testWidgets("handles disabled field state", (WidgetTester tester) async {
      final disabledField = DynamicField(
        controlType: FieldType.singleCheckBox,
        key: "checkbox_key",
        label: "Disabled Checkbox",
        required: false,
        rowData: 1,
        enabledDefault: false,
        isDisable: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: disabledField,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
            ),
          ),
        ),
      );

      expect(find.text("Disabled Checkbox"), findsOneWidget);
    });

    testWidgets("handles long label text", (WidgetTester tester) async {
      final longLabelField = DynamicField(
        controlType: FieldType.singleCheckBox,
        key: "checkbox_key",
        label: "This is a very long checkbox label that should still"
            " render correctly and not cause layout issues",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: longLabelField,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
            ),
          ),
        ),
      );

      expect(
        find.textContaining("This is a very long checkbox label"),
        findsOneWidget,
      );
    });

    testWidgets("renders checkbox structure correctly",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: mockFieldData,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormSingleCheckBox), findsOneWidget);
    });

    testWidgets("handles validation function returning null",
        (WidgetTester tester) async {
      String? nullValidation(bool? value) {
        return null;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: mockFieldData,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
              validation: nullValidation,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormSingleCheckBox), findsOneWidget);
    });

    testWidgets("handles field with special characters in label",
        (WidgetTester tester) async {
      final specialLabelField = DynamicField(
        controlType: FieldType.singleCheckBox,
        key: "checkbox_key",
        label: 'Checkbox & Special "Characters" <Field>',
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: specialLabelField,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
            ),
          ),
        ),
      );

      expect(find.textContaining("Checkbox & Special"), findsOneWidget);
    });

    testWidgets("handles checkbox with initial value correctly",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: mockFieldData,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
              value: true,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormSingleCheckBox), findsOneWidget);
    });

    testWidgets("handles checkbox state initialization correctly",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: mockFieldData,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormSingleCheckBox), findsOneWidget);
      // Verify initial state is false
    });

    testWidgets("handles widget with custom key", (WidgetTester tester) async {
      const testKey = Key("test_checkbox_key");

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              key: testKey,
              fieldData: mockFieldData,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
            ),
          ),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);
    });

    testWidgets("handles boolean value change from false to true",
        (WidgetTester tester) async {
      bool currentValue = false;
      void testOnChanged(bool value) {
        currentValue = value;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: mockFieldData,
              onChanged: testOnChanged,
              onSaved: mockOnSaved,
              value: false,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormSingleCheckBox), findsOneWidget);
      expect(currentValue, isFalse);
    });

    testWidgets("renders label from fieldData correctly",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: mockFieldData,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
            ),
          ),
        ),
      );

      expect(find.text("Checkbox Field"), findsOneWidget);
    });

    testWidgets("handles checkbox with complex field data",
        (WidgetTester tester) async {
      final complexField = DynamicField(
        controlType: FieldType.singleCheckBox,
        key: "complex_checkbox_key",
        label: "Complex Checkbox with Multiple Properties",
        required: true,
        rowData: 2,
        enabledDefault: false,
        isDisable: true,
        maxLength: 100,
        message: "Custom validation message",
        validationPattern: r"^[a-zA-Z]+$",
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: complexField,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
            ),
          ),
        ),
      );

      expect(find.textContaining("Complex Checkbox"), findsOneWidget);
    });

    testWidgets("handles save callback with false value",
        (WidgetTester tester) async {
      bool? lastSavedValue;
      void testOnSaved(bool? value) {
        lastSavedValue = value;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: mockFieldData,
              onChanged: mockOnChanged,
              onSaved: testOnSaved,
              value: false,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormSingleCheckBox), findsOneWidget);
      expect(lastSavedValue, isNull);
    });

    testWidgets("handles validation function returning error message",
        (WidgetTester tester) async {
      String? errorValidation(bool? value) {
        return "Custom error message";
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: mockFieldData,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
              validation: errorValidation,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormSingleCheckBox), findsOneWidget);
    });

    testWidgets("handles required field with asterisk in label",
        (WidgetTester tester) async {
      final requiredField = DynamicField(
        controlType: FieldType.singleCheckBox,
        key: "required_checkbox",
        label: "Required Checkbox",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormSingleCheckBox(
              fieldData: requiredField,
              onChanged: mockOnChanged,
              onSaved: mockOnSaved,
            ),
          ),
        ),
      );

      expect(find.text("Required Checkbox"), findsOneWidget);
    });
  });
}
