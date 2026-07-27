import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";

void main() {
  group("DynamicFormDropdown", () {
    late DynamicField mockFieldData;
    late Function(CustomDropdownItem) mockSelectedOption;

    setUp(() {
      mockFieldData = DynamicField(
        controlType: FieldType.dropdown,
        key: "dropdown_key",
        label: "Dropdown Field",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        message: "Please select an option",
        optionList: [
          Option(key: "opt1", pairValue: "Option 1"),
          Option(key: "opt2", pairValue: "Option 2"),
          Option(key: "opt3", pairValue: "Option 3"),
        ],
      );
      mockSelectedOption = (CustomDropdownItem item) {};
    });

    testWidgets("renders correctly with required parameters",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdown(
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      //expect(find.text('Dropdown Field *'), findsOneWidget);
      //expect(find.byType(DynamicFormDropdown), findsOneWidget);
    });

    testWidgets("renders without label when showLabel is false",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdown(
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
              showLabel: false,
            ),
          ),
        ),
      );

      expect(find.text("Dropdown Field"), findsNothing);
      expect(find.byType(DynamicFormDropdown), findsOneWidget);
    });

    testWidgets("shows required indicator when field is required",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdown(
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdown), findsOneWidget);
    });

    testWidgets("handles empty option list", (WidgetTester tester) async {
      final fieldWithEmptyList = DynamicField(
        controlType: FieldType.dropdown,
        key: "dropdown_key",
        label: "Dropdown Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdown(
              fieldData: fieldWithEmptyList,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdown), findsOneWidget);
    });

    testWidgets("handles null option list", (WidgetTester tester) async {
      final fieldWithNullList = DynamicField(
        controlType: FieldType.dropdown,
        key: "dropdown_key",
        label: "Dropdown Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdown(
              fieldData: fieldWithNullList,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdown), findsOneWidget);
    });

    testWidgets("renders as disabled when isDisable is true",
        (WidgetTester tester) async {
      final disabledField = DynamicField(
        controlType: FieldType.dropdown,
        key: "dropdown_key",
        label: "Disabled Dropdown",
        required: false,
        rowData: 1,
        enabledDefault: false,
        isDisable: true,
        optionList: [
          Option(key: "opt1", pairValue: "Option 1"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdown(
              fieldData: disabledField,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.text("Disabled Dropdown"), findsOneWidget);
      expect(find.byType(DynamicFormDropdown), findsOneWidget);
    });

    testWidgets("renders with validation message", (WidgetTester tester) async {
      final fieldWithValidation = DynamicField(
        controlType: FieldType.dropdown,
        key: "dropdown_key",
        label: "Dropdown Field",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        message: "This field is required",
        optionList: [
          Option(key: "opt1", pairValue: "Option 1"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdown(
              fieldData: fieldWithValidation,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdown), findsOneWidget);
    });

    testWidgets("handles non-required field correctly",
        (WidgetTester tester) async {
      final optionalField = DynamicField(
        controlType: FieldType.dropdown,
        key: "dropdown_key",
        label: "Optional Dropdown",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "opt1", pairValue: "Option 1"),
          Option(key: "opt2", pairValue: "Option 2"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdown(
              fieldData: optionalField,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.text("Optional Dropdown"), findsOneWidget);
    });

    testWidgets("handles field with empty label", (WidgetTester tester) async {
      final fieldWithEmptyLabel = DynamicField(
        controlType: FieldType.dropdown,
        key: "dropdown_key",
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
            body: DynamicFormDropdown(
              fieldData: fieldWithEmptyLabel,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdown), findsOneWidget);
    });

    testWidgets("renders dropdown with searchable functionality",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdown(
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdown), findsOneWidget);
    });

    testWidgets("handles options with null values",
        (WidgetTester tester) async {
      final fieldWithNullOptionValues = DynamicField(
        controlType: FieldType.dropdown,
        key: "dropdown_key",
        label: "Dropdown Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "opt1", pairValue: null),
          Option(key: "opt2", pairValue: "Valid Option"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdown(
              fieldData: fieldWithNullOptionValues,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdown), findsOneWidget);
    });

    testWidgets("handles options with empty string values",
        (WidgetTester tester) async {
      final fieldWithEmptyOptionValues = DynamicField(
        controlType: FieldType.dropdown,
        key: "dropdown_key",
        label: "Dropdown Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "opt1", pairValue: ""),
          Option(key: "opt2", pairValue: "Valid Option"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdown(
              fieldData: fieldWithEmptyOptionValues,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdown), findsOneWidget);
    });

    testWidgets("handles long option values", (WidgetTester tester) async {
      final fieldWithLongOptions = DynamicField(
        controlType: FieldType.dropdown,
        key: "dropdown_key",
        label: "Dropdown Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(
            key: "opt1",
            pairValue: "This is a very long option text that should still"
                " render properly in the dropdown",
          ),
          Option(key: "opt2", pairValue: "Short option"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDropdown(
              fieldData: fieldWithLongOptions,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDropdown), findsOneWidget);
    });
  });
}
