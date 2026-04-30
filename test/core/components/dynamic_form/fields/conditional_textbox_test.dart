import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/conditional_textbox.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";

void main() {
  group("DynamicConditionalTextbox", () {
    late DynamicField mockFieldData;
    late Function(String) mockOnSubmit;

    setUp(() {
      mockFieldData = DynamicField(
        controlType: FieldType.conditionalTextbox,
        key: "test_key",
        label: "Test Label",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        defaultValue: "Default Value",
        maxLength: 100,
        message: "Test message",
      );
      mockOnSubmit = (String value) {};
    });

    testWidgets("renders correctly with required parameters",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicConditionalTextbox(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      //  expect(find.text('Test Label *'), findsOneWidget);
    });

    testWidgets("renders without label when showLabel is false",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicConditionalTextbox(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              showLabel: false,
            ),
          ),
        ),
      );

      expect(find.text("Test Label"), findsNothing);
    });

    testWidgets("renders with custom input formatters",
        (WidgetTester tester) async {
      final inputFormatters = [FilteringTextInputFormatter.digitsOnly];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicConditionalTextbox(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              inputFormatters: inputFormatters,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicConditionalTextbox), findsOneWidget);
    });

    testWidgets("handles field data with different values",
        (WidgetTester tester) async {
      final fieldWithNullValues = DynamicField(
        controlType: FieldType.conditionalTextbox,
        key: "test_key",
        label: "",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        defaultValue: null,
        maxLength: null,
        message: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicConditionalTextbox(
              fieldData: fieldWithNullValues,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicConditionalTextbox), findsOneWidget);
    });

    testWidgets("renders with maximum length field data",
        (WidgetTester tester) async {
      final fieldWithMaxLength = DynamicField(
        controlType: FieldType.conditionalTextbox,
        key: "test_key",
        label: "Test Label",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        defaultValue: "Default",
        maxLength: 50,
        message: "Error message",
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicConditionalTextbox(
              fieldData: fieldWithMaxLength,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      // expect(find.byType(DynamicConditionalTextbox), findsOneWidget);
      // expect(find.text('Test Label *'), findsOneWidget);
    });

    testWidgets("handles disabled state correctly",
        (WidgetTester tester) async {
      final disabledField = DynamicField(
        controlType: FieldType.conditionalTextbox,
        key: "test_key",
        label: "Disabled Field",
        required: false,
        rowData: 1,
        enabledDefault: false,
        isDisable: true,
        defaultValue: "Read Only",
        maxLength: 100,
        message: "",
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicConditionalTextbox(
              fieldData: disabledField,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.text("Disabled Field"), findsOneWidget);
    });

    testWidgets("renders with multiple input formatters",
        (WidgetTester tester) async {
      final inputFormatters = [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicConditionalTextbox(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              inputFormatters: inputFormatters,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicConditionalTextbox), findsOneWidget);
    });

    testWidgets("handles empty input formatters list",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicConditionalTextbox(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              inputFormatters: const [],
            ),
          ),
        ),
      );

      expect(find.byType(DynamicConditionalTextbox), findsOneWidget);
    });

    testWidgets("handles field with empty label", (WidgetTester tester) async {
      final fieldWithEmptyLabel = DynamicField(
        controlType: FieldType.conditionalTextbox,
        key: "test_key",
        label: "",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        defaultValue: "Default",
        maxLength: 100,
        message: "",
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicConditionalTextbox(
              fieldData: fieldWithEmptyLabel,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicConditionalTextbox), findsOneWidget);
    });
  });
}
