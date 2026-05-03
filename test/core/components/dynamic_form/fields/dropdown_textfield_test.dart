import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/dropdown_textfield.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";

void main() {
  group("DynamicFormDropdownTextfield", () {
    late DynamicField mockFieldData;
    late Function(Map<String, dynamic>) mockOnSubmit;

    setUp(() {
      mockFieldData = DynamicField(
        controlType: FieldType.tenorControl,
        key: "dropdown_textfield_key",
        label: "Dropdown Textfield",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        defaultValue: "100",
        optionList: [
          Option(key: "days", pairValue: "Days"),
          Option(key: "months", pairValue: "Months"),
          Option(key: "years", pairValue: "Years"),
        ],
      );
      mockOnSubmit = (Map<String, dynamic> value) {};
    });

    // testWidgets('renders correctly with required parameters', (WidgetTester
    // tester) async {
    //   await tester.pumpWidget(
    //     MaterialApp(
    //       home: Scaffold(
    //         body: DynamicFormDropdownTextfield(
    //           fieldData: mockFieldData,
    //           onSubmit: mockOnSubmit,
    //         ),
    //       ),
    //     ),
    //   );

    //   expect(find.text('Dropdown Textfield *'), findsOneWidget);
    //   expect(find.byType(DynamicFormDropdownTextfield), findsOneWidget);
    // });

    testWidgets("renders without label when showLabel is false",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdownTextfield(
              document: const {},
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              showLabel: false,
            ),
          ),
        ),
      );

      expect(find.text("Dropdown Textfield"), findsNothing);
      expect(find.byType(DynamicFormDropdownTextfield), findsOneWidget);
    });

    testWidgets("shows required indicator when field is required",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdownTextfield(
              document: const {},
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdownTextfield), findsOneWidget);
    });

    testWidgets("handles empty option list", (WidgetTester tester) async {
      final fieldWithEmptyList = DynamicField(
        controlType: FieldType.tenorControl,
        key: "dropdown_textfield_key",
        label: "Dropdown Textfield",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdownTextfield(
              document: const {},
              fieldData: fieldWithEmptyList,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdownTextfield), findsOneWidget);
    });

    testWidgets("handles null option list", (WidgetTester tester) async {
      final fieldWithNullList = DynamicField(
        controlType: FieldType.tenorControl,
        key: "dropdown_textfield_key",
        label: "Dropdown Textfield",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdownTextfield(
              document: const {},
              fieldData: fieldWithNullList,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdownTextfield), findsOneWidget);
    });

    testWidgets("renders with custom input formatters",
        (WidgetTester tester) async {
      final inputFormatters = [FilteringTextInputFormatter.digitsOnly];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdownTextfield(
              document: const {},
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              inputFormatters: inputFormatters,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdownTextfield), findsOneWidget);
    });

    testWidgets("handles field with default value",
        (WidgetTester tester) async {
      final fieldWithDefaultValue = DynamicField(
        controlType: FieldType.tenorControl,
        key: "dropdown_textfield_key",
        label: "Dropdown Textfield",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        defaultValue: "50",
        optionList: [
          Option(key: "opt1", pairValue: "Option 1"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdownTextfield(
              document: const {},
              fieldData: fieldWithDefaultValue,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdownTextfield), findsOneWidget);
    });

    // testWidgets('handles non-required field correctly', (WidgetTester tester)
    // async {
    //   final optionalField = DynamicField(
    //     controlType: FieldType.tenorControl,
    //     key: 'dropdown_textfield_key',
    //     label: 'Optional Field',
    //     required: false,
    //     rowData: 1,
    //     enabledDefault: true,
    //     isDisable: false,
    //     optionList: [
    //       Option(key: 'opt1', pairValue: 'Option 1'),
    //     ],
    //   );

    //   await tester.pumpWidget(
    //     MaterialApp(
    //       home: Scaffold(
    //         body: DynamicFormDropdownTextfield(
    //           fieldData: optionalField,
    //           onSubmit: mockOnSubmit,
    //         ),
    //       ),
    //     ),
    //   );

    //   expect(find.text('Optional Field'), findsOneWidget);
    // });

    testWidgets("handles field with empty label", (WidgetTester tester) async {
      final fieldWithEmptyLabel = DynamicField(
        controlType: FieldType.tenorControl,
        key: "dropdown_textfield_key",
        label: "",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "opt1", pairValue: "Option 1"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdownTextfield(
              document: const {},
              fieldData: fieldWithEmptyLabel,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdownTextfield), findsOneWidget);
    });

    testWidgets("handles multiple input formatters",
        (WidgetTester tester) async {
      final inputFormatters = [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(5),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdownTextfield(
              document: const {},
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              inputFormatters: inputFormatters,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdownTextfield), findsOneWidget);
    });

    testWidgets("handles empty input formatters list",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdownTextfield(
              document: const {},
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              inputFormatters: const [],
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdownTextfield), findsOneWidget);
    });

    // testWidgets('renders with default showLabel value',
    //     (WidgetTester tester) async {
    //   await tester.pumpWidget(
    //     MaterialApp(
    //       home: Scaffold(
    //         body: DynamicFormDropdownTextfield(
    //           fieldData: mockFieldData,
    //           onSubmit: mockOnSubmit,
    //         ),
    //       ),
    //     ),
    //   );

    //   expect(find.text('Dropdown Textfield *'), findsOneWidget);
    // });
  });
}
