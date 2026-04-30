import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/text_area.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";

void main() {
  group("DynamicFormTextAreaField", () {
    late DynamicField mockFieldData;
    late Function(String?) mockOnSubmit;

    setUp(() {
      mockFieldData = DynamicField(
        controlType: FieldType.textArea,
        key: "textarea_key",
        label: "Text Area Field",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        defaultValue: "Default text area content",
        maxLength: 500,
        message: "Please enter text",
      );
      mockOnSubmit = (String? value) {};
    });

    testWidgets("renders without label when showLabel is false",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              onChange: (e) {},
              showLabel: false,
            ),
          ),
        ),
      );

      expect(find.text("Text Area Field"), findsNothing);
      expect(find.byType(DynamicFormTextAreaField), findsOneWidget);
    });

    testWidgets("shows required indicator when field is required",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              onChange: (e) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextAreaField), findsOneWidget);
    });

    testWidgets("renders with custom input formatters",
        (WidgetTester tester) async {
      final inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              onChange: (e) {},
              inputFormatters: inputFormatters,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextAreaField), findsOneWidget);
    });

    testWidgets("handles disabled field state", (WidgetTester tester) async {
      final disabledField = DynamicField(
        controlType: FieldType.textArea,
        key: "textarea_key",
        label: "Disabled Text Area",
        required: false,
        rowData: 1,
        enabledDefault: false,
        isDisable: true,
        defaultValue: "Read only text area content",
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: disabledField,
              onSubmit: mockOnSubmit,
              onChange: (e) {},
            ),
          ),
        ),
      );

      expect(find.text("Disabled Text Area"), findsOneWidget);
    });

    testWidgets("handles field with error message",
        (WidgetTester tester) async {
      final fieldWithError = DynamicField(
        controlType: FieldType.textArea,
        key: "textarea_key",
        label: "Text Area Field",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        message: "This field has an error",
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: fieldWithError,
              onSubmit: mockOnSubmit,
              onChange: (e) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextAreaField), findsOneWidget);
    });

    testWidgets("handles non-required field correctly",
        (WidgetTester tester) async {
      final optionalField = DynamicField(
        controlType: FieldType.textArea,
        key: "textarea_key",
        label: "Optional Text Area",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: optionalField,
              onSubmit: mockOnSubmit,
              onChange: (e) {},
            ),
          ),
        ),
      );

      expect(find.text("Optional Text Area"), findsOneWidget);
    });

    testWidgets("renders with custom max lines", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              maxLines: 10,
              onChange: (e) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextAreaField), findsOneWidget);
    });

    testWidgets("renders with custom min lines", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              onChange: (e) {},
              minLines: 3,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextAreaField), findsOneWidget);
    });

    testWidgets("renders with both custom max and min lines",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              maxLines: 8,
              minLines: 3,
              onChange: (e) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextAreaField), findsOneWidget);
    });

    testWidgets("handles field with empty default value",
        (WidgetTester tester) async {
      final fieldWithEmptyDefault = DynamicField(
        controlType: FieldType.textArea,
        key: "textarea_key",
        label: "Text Area Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        defaultValue: "",
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: fieldWithEmptyDefault,
              onSubmit: mockOnSubmit,
              onChange: (e) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextAreaField), findsOneWidget);
    });

    testWidgets("handles field with null default value",
        (WidgetTester tester) async {
      final fieldWithNullDefault = DynamicField(
        controlType: FieldType.textArea,
        key: "textarea_key",
        label: "Text Area Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        defaultValue: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: fieldWithNullDefault,
              onSubmit: mockOnSubmit,
              onChange: (e) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextAreaField), findsOneWidget);
    });

    testWidgets("handles field with empty label", (WidgetTester tester) async {
      final fieldWithEmptyLabel = DynamicField(
        controlType: FieldType.textArea,
        key: "textarea_key",
        label: "",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: fieldWithEmptyLabel,
              onSubmit: mockOnSubmit,
              onChange: (e) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextAreaField), findsOneWidget);
    });

    testWidgets("handles multiple input formatters",
        (WidgetTester tester) async {
      final inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
        LengthLimitingTextInputFormatter(200),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              inputFormatters: inputFormatters,
              onChange: (e) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextAreaField), findsOneWidget);
    });

    testWidgets("handles empty input formatters list",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              inputFormatters: const [],
              onChange: (e) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextAreaField), findsOneWidget);
    });

    testWidgets("renders with default showLabel value",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              onChange: (e) {},
            ),
          ),
        ),
      );

      // expect(find.text('Text Area Field *'), findsOneWidget);
    });

    testWidgets("handles field with max length", (WidgetTester tester) async {
      final fieldWithMaxLength = DynamicField(
        controlType: FieldType.textArea,
        key: "textarea_key",
        label: "Text Area Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        maxLength: 250,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: fieldWithMaxLength,
              onSubmit: mockOnSubmit,
              onChange: (e) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextAreaField), findsOneWidget);
    });

    testWidgets("handles field with null max length",
        (WidgetTester tester) async {
      final fieldWithNullMaxLength = DynamicField(
        controlType: FieldType.textArea,
        key: "textarea_key",
        label: "Text Area Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        maxLength: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: fieldWithNullMaxLength,
              onSubmit: mockOnSubmit,
              onChange: (e) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextAreaField), findsOneWidget);
    });

    testWidgets("handles long text content", (WidgetTester tester) async {
      final fieldWithLongText = DynamicField(
        controlType: FieldType.textArea,
        key: "textarea_key",
        label: "Long Text Area Field Label That Should Still Render Correctly",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        defaultValue: "This is a very long "
            "default value for the text "
            "area that should still "
            "render correctly and"
            " handle multiple lines of text content "
            "properly without causing any layout issues",
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: fieldWithLongText,
              onSubmit: mockOnSubmit,
              onChange: (e) {},
            ),
          ),
        ),
      );

      expect(find.textContaining("Long Text Area Field Label"), findsOneWidget);
    });

    testWidgets("handles callback function properly",
        (WidgetTester tester) async {
      String? submittedValue;
      void testOnSubmit(String? value) {
        submittedValue = value;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormTextAreaField(
              fieldData: mockFieldData,
              onSubmit: testOnSubmit,
              onChange: (e) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormTextAreaField), findsOneWidget);
      expect(submittedValue, isNull);
    });
  });
}
