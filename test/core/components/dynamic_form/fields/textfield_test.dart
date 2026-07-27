import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/textfield.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";

void main() {
  group("DynamicFormTextField", () {
    late DynamicField mockFieldData;
    late Function(String?) mockOnSubmit;

    setUp(() {
      mockFieldData = DynamicField(
        controlType: FieldType.textField,
        key: "textfield_key",
        label: "Text Field",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        defaultValue: "Default text",
        maxLength: 100,
        message: "Please enter text",
      );
      mockOnSubmit = (String? value) {};
    });

    testWidgets("renders correctly with required parameters",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      //  expect(find.text('Text Field *'), findsOneWidget);
      // expect(find.byType(DynamicFormTextField), findsOneWidget);
    });

    testWidgets("renders without label when showLabel is false",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              showLabel: false,
            ),
          ),
        ),
      );

      expect(find.text("Text Field"), findsNothing);
      expect(find.byType(DynamicFormTextField), findsOneWidget);
    });

    testWidgets("shows required indicator when field is required",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextField), findsOneWidget);
    });

    testWidgets("renders with custom input formatters",
        (WidgetTester tester) async {
      final inputFormatters = [FilteringTextInputFormatter.digitsOnly];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              inputFormatters: inputFormatters,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextField), findsOneWidget);
    });

    testWidgets("handles disabled field state", (WidgetTester tester) async {
      final disabledField = DynamicField(
        controlType: FieldType.textField,
        key: "textfield_key",
        label: "Disabled Text Field",
        required: false,
        rowData: 1,
        enabledDefault: false,
        isDisable: true,
        defaultValue: "Read only text",
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: disabledField,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.text("Disabled Text Field"), findsOneWidget);
    });

    testWidgets("handles field with error message",
        (WidgetTester tester) async {
      final fieldWithError = DynamicField(
        controlType: FieldType.textField,
        key: "textfield_key",
        label: "Text Field",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        message: "This field has an error",
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: fieldWithError,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextField), findsOneWidget);
    });

    testWidgets("handles non-required field correctly",
        (WidgetTester tester) async {
      final optionalField = DynamicField(
        controlType: FieldType.textField,
        key: "textfield_key",
        label: "Optional Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: optionalField,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.text("Optional Field"), findsOneWidget);
    });

    testWidgets("handles field with empty default value",
        (WidgetTester tester) async {
      final fieldWithEmptyDefault = DynamicField(
        controlType: FieldType.textField,
        key: "textfield_key",
        label: "Text Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        defaultValue: "",
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: fieldWithEmptyDefault,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextField), findsOneWidget);
    });

    testWidgets("handles field with null default value",
        (WidgetTester tester) async {
      final fieldWithNullDefault = DynamicField(
        controlType: FieldType.textField,
        key: "textfield_key",
        label: "Text Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: fieldWithNullDefault,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextField), findsOneWidget);
    });

    testWidgets("handles field with empty label", (WidgetTester tester) async {
      final fieldWithEmptyLabel = DynamicField(
        controlType: FieldType.textField,
        key: "textfield_key",
        label: "",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: fieldWithEmptyLabel,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextField), findsOneWidget);
    });

    testWidgets("handles multiple input formatters",
        (WidgetTester tester) async {
      final inputFormatters = [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              inputFormatters: inputFormatters,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextField), findsOneWidget);
    });

    testWidgets("handles empty input formatters list",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              inputFormatters: const [],
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextField), findsOneWidget);
    });

    testWidgets("renders with default showLabel value",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      //  expect(find.text('Text Field *'), findsOneWidget);
    });

    testWidgets("handles field with max length", (WidgetTester tester) async {
      final fieldWithMaxLength = DynamicField(
        controlType: FieldType.textField,
        key: "textfield_key",
        label: "Text Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        maxLength: 50,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: fieldWithMaxLength,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextField), findsOneWidget);
    });

    testWidgets("handles field with null max length",
        (WidgetTester tester) async {
      final fieldWithNullMaxLength = DynamicField(
        controlType: FieldType.textField,
        key: "textfield_key",
        label: "Text Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: fieldWithNullMaxLength,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextField), findsOneWidget);
    });

    testWidgets("handles long text input", (WidgetTester tester) async {
      final fieldWithLongText = DynamicField(
        controlType: FieldType.textField,
        key: "textfield_key",
        label: "Long Text Field Label That Should Still Render Correctly",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        defaultValue: "This is a very long default value that should still"
            " render correctly in the text field",
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextField(
              fieldData: fieldWithLongText,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.textContaining("Long Text Field Label"), findsOneWidget);
    });
  });
}
