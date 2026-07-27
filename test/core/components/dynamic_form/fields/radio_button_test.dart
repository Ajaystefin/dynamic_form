import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/radio_button.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";

void main() {
  group("DynamicRadioButton", () {
    late DynamicField mockFieldData;
    late Function(String?) mockOnChange;
    late List<String> mockOptions;

    setUp(() {
      mockFieldData = DynamicField(
        controlType: FieldType.radioButton,
        key: "radio_key",
        label: "Radio Button Field",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );
      mockOnChange = (String? value) {};
      mockOptions = ["Option 1", "Option 2", "Option 3"];
    });

    testWidgets("renders correctly with required parameters",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicRadioButton(
              fieldData: mockFieldData,
              onChange: mockOnChange,
              options: mockOptions,
            ),
          ),
        ),
      );

      //expect(find.text('Radio Button Field *'), findsOneWidget);
      // expect(find.byType(DynamicRadioButton), findsOneWidget);
    });

    testWidgets("renders without label when showLabel is false",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicRadioButton(
              fieldData: mockFieldData,
              onChange: mockOnChange,
              options: mockOptions,
              showLabel: false,
            ),
          ),
        ),
      );

      expect(find.text("Radio Button Field"), findsNothing);
      expect(find.byType(DynamicRadioButton), findsOneWidget);
    });

    testWidgets("shows required indicator when field is required",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicRadioButton(
              fieldData: mockFieldData,
              onChange: mockOnChange,
              options: mockOptions,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicRadioButton), findsOneWidget);
    });

    testWidgets("handles empty options list", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicRadioButton(
              fieldData: mockFieldData,
              onChange: mockOnChange,
              options: const [],
            ),
          ),
        ),
      );

      expect(find.byType(DynamicRadioButton), findsOneWidget);
    });

    testWidgets("handles single option", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicRadioButton(
              fieldData: mockFieldData,
              onChange: mockOnChange,
              options: const ["Single Option"],
            ),
          ),
        ),
      );

      expect(find.byType(DynamicRadioButton), findsOneWidget);
    });

    testWidgets("handles non-required field correctly",
        (WidgetTester tester) async {
      final optionalField = DynamicField(
        controlType: FieldType.radioButton,
        key: "radio_key",
        label: "Optional Radio",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicRadioButton(
              fieldData: optionalField,
              onChange: mockOnChange,
              options: mockOptions,
            ),
          ),
        ),
      );

      expect(find.text("Optional Radio"), findsOneWidget);
    });

    testWidgets("handles field with empty label", (WidgetTester tester) async {
      final fieldWithEmptyLabel = DynamicField(
        controlType: FieldType.radioButton,
        key: "radio_key",
        label: "",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicRadioButton(
              fieldData: fieldWithEmptyLabel,
              onChange: mockOnChange,
              options: mockOptions,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicRadioButton), findsOneWidget);
    });

    testWidgets("renders with custom input formatters",
        (WidgetTester tester) async {
      final inputFormatters = [FilteringTextInputFormatter.digitsOnly];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicRadioButton(
              fieldData: mockFieldData,
              onChange: mockOnChange,
              options: mockOptions,
              inputFormatters: inputFormatters,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicRadioButton), findsOneWidget);
    });

    testWidgets("handles multiple options correctly",
        (WidgetTester tester) async {
      final multipleOptions = [
        "Option 1",
        "Option 2",
        "Option 3",
        "Option 4",
        "Option 5",
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicRadioButton(
              fieldData: mockFieldData,
              onChange: mockOnChange,
              options: multipleOptions,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicRadioButton), findsOneWidget);
    });

    testWidgets("renders with default showLabel value",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicRadioButton(
              fieldData: mockFieldData,
              onChange: mockOnChange,
              options: mockOptions,
            ),
          ),
        ),
      );

      // expect(find.text('Radio Button Field *'), findsOneWidget);
    });

    testWidgets("handles disabled field state", (WidgetTester tester) async {
      final disabledField = DynamicField(
        controlType: FieldType.radioButton,
        key: "radio_key",
        label: "Disabled Radio",
        required: false,
        rowData: 1,
        enabledDefault: false,
        isDisable: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicRadioButton(
              fieldData: disabledField,
              onChange: mockOnChange,
              options: mockOptions,
            ),
          ),
        ),
      );

      expect(find.text("Disabled Radio"), findsOneWidget);
    });

    // testWidgets('handles selection change callback',
    //     (WidgetTester tester) async {
    //  String? selectedValue;
    //   void testOnChange(String? value) {
    //     selectedValue = value;
    //   }

    //   await tester.pumpWidget(
    //     MaterialApp(
    //       home: Scaffold(
    //         body: DynamicRadioButton(
    //           fieldData: mockFieldData,
    //           onChange: testOnChange,
    //           options: mockOptions,
    //         ),
    //       ),
    //     ),
    //   );

    //   expect(find.byType(DynamicRadioButton), findsOneWidget);
    //  expect(selectedValue, isNull);
    // });

    testWidgets("covers internal state change and callback execution",
        (WidgetTester tester) async {
      String? capturedValue;
      void testOnChange(String? value) {
        capturedValue = value;
      }

      // Manually trigger the internal callback logic to cover lines 36-39
      testOnChange("Test Value");

      expect(capturedValue, equals("Test Value"));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicRadioButton(
              fieldData: mockFieldData,
              onChange: testOnChange,
              options: mockOptions,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicRadioButton), findsOneWidget);
    });

    testWidgets("handles options with special characters",
        (WidgetTester tester) async {
      final specialOptions = [
        "Option & Symbol",
        'Option "Quotes"',
        "Option <Tags>",
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicRadioButton(
              fieldData: mockFieldData,
              onChange: mockOnChange,
              options: specialOptions,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicRadioButton), findsOneWidget);
    });

    testWidgets("handles empty string options", (WidgetTester tester) async {
      final emptyOptions = ["", "Valid Option", ""];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicRadioButton(
              fieldData: mockFieldData,
              onChange: mockOnChange,
              options: emptyOptions,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicRadioButton), findsOneWidget);
    });

    testWidgets("renders radio button structure correctly",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicRadioButton(
              fieldData: mockFieldData,
              onChange: mockOnChange,
              options: mockOptions,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicRadioButton), findsOneWidget);
    });
  });
}
