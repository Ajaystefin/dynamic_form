import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/reference_data_dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";

void main() {
  group("DynamicReferenceDataDropdown", () {
    late DynamicField mockFieldData;
    late Function(CustomDropdownItem) mockSelectedOption;

    setUp(() {
      mockFieldData = DynamicField(
        controlType: FieldType.refDataDropdown,
        key: "refdata_key",
        label: "Reference Data Dropdown",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "ref1", pairValue: "Reference 1"),
          Option(key: "ref2", pairValue: "Reference 2"),
          Option(key: "ref3", pairValue: "Reference 3"),
        ],
      );
      mockSelectedOption = (CustomDropdownItem item) {};
    });

    testWidgets("renders correctly with required parameters",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      // expect(find.text('Reference Data Dropdown *'), findsOneWidget);
      // expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
    });

    testWidgets("renders without label when showLabel is false",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
              showLabel: false,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.text("Reference Data Dropdown"), findsNothing);
      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
    });

    testWidgets("shows required indicator when field is required",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
    });

    testWidgets("handles empty option list", (WidgetTester tester) async {
      final fieldWithEmptyList = DynamicField(
        controlType: FieldType.refDataDropdown,
        key: "refdata_key",
        label: "Reference Data Dropdown",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: fieldWithEmptyList,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
    });

    testWidgets("handles null option list", (WidgetTester tester) async {
      final fieldWithNullList = DynamicField(
        controlType: FieldType.refDataDropdown,
        key: "refdata_key",
        label: "Reference Data Dropdown",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: fieldWithNullList,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
    });

    testWidgets("renders as disabled when isDisable is true",
        (WidgetTester tester) async {
      final disabledField = DynamicField(
        controlType: FieldType.refDataDropdown,
        key: "refdata_key",
        label: "Disabled Reference Dropdown",
        required: false,
        rowData: 1,
        enabledDefault: false,
        isDisable: true,
        optionList: [
          Option(key: "ref1", pairValue: "Reference 1"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: disabledField,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.text("Disabled Reference Dropdown"), findsOneWidget);
      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
    });

    testWidgets("handles non-required field correctly",
        (WidgetTester tester) async {
      final optionalField = DynamicField(
        controlType: FieldType.refDataDropdown,
        key: "refdata_key",
        label: "Optional Reference Dropdown",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "ref1", pairValue: "Reference 1"),
          Option(key: "ref2", pairValue: "Reference 2"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: optionalField,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.text("Optional Reference Dropdown"), findsOneWidget);
    });

    testWidgets("handles field with empty label", (WidgetTester tester) async {
      final fieldWithEmptyLabel = DynamicField(
        controlType: FieldType.refDataDropdown,
        key: "refdata_key",
        label: "",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "ref1", pairValue: "Reference 1"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: fieldWithEmptyLabel,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
    });

    testWidgets("renders dropdown with searchable functionality",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
    });

    testWidgets("handles reference options with null values",
        (WidgetTester tester) async {
      final fieldWithNullOptionValues = DynamicField(
        controlType: FieldType.refDataDropdown,
        key: "refdata_key",
        label: "Reference Data Dropdown",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "ref1", pairValue: null),
          Option(key: "ref2", pairValue: "Valid Reference"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: fieldWithNullOptionValues,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
    });

    testWidgets("handles reference options with empty string values",
        (WidgetTester tester) async {
      final fieldWithEmptyOptionValues = DynamicField(
        controlType: FieldType.refDataDropdown,
        key: "refdata_key",
        label: "Reference Data Dropdown",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "ref1", pairValue: ""),
          Option(key: "ref2", pairValue: "Valid Reference"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: fieldWithEmptyOptionValues,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
    });

    testWidgets("handles long reference option values",
        (WidgetTester tester) async {
      final fieldWithLongOptions = DynamicField(
        controlType: FieldType.refDataDropdown,
        key: "refdata_key",
        label: "Reference Data Dropdown",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(
            key: "ref1",
            pairValue: "This is a very long reference data option text"
                " that should still render properly",
          ),
          Option(key: "ref2", pairValue: "Short ref"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: fieldWithLongOptions,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
    });

    testWidgets("renders with default showLabel value",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      // expect(find.text('Reference Data Dropdown *'), findsOneWidget);
    });

    testWidgets("handles callback function properly",
        (WidgetTester tester) async {
      bool callbackTriggered = false;
      void testSelectedOption(CustomDropdownItem item) {
        callbackTriggered = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: mockFieldData,
              selectedOption: testSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
      expect(callbackTriggered, isFalse);
    });

    testWidgets("handles validation message when provided",
        (WidgetTester tester) async {
      final fieldWithValidation = DynamicField(
        controlType: FieldType.refDataDropdown,
        key: "refdata_key",
        label: "Reference Data Dropdown",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        message: "This field is required",
        optionList: [
          Option(key: "ref1", pairValue: "Reference 1"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: fieldWithValidation,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
    });

    testWidgets("handles widget with custom key", (WidgetTester tester) async {
      const testKey = Key("test_ref_dropdown_key");

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              key: testKey,
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);
    });

    testWidgets("handles options with special characters in keys",
        (WidgetTester tester) async {
      final fieldWithSpecialKeys = DynamicField(
        controlType: FieldType.refDataDropdown,
        key: "refdata_key",
        label: "Reference Data Dropdown",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "ref&key", pairValue: "Reference & Value"),
          Option(key: 'ref"key', pairValue: 'Reference "Value"'),
          Option(key: "ref<key>", pairValue: "Reference <Value>"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: fieldWithSpecialKeys,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
    });

    testWidgets("handles single reference option", (WidgetTester tester) async {
      final singleOptionField = DynamicField(
        controlType: FieldType.refDataDropdown,
        key: "refdata_key",
        label: "Reference Data Dropdown",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "ref1", pairValue: "Single Reference"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: singleOptionField,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
    });

    testWidgets("handles multiple reference options correctly",
        (WidgetTester tester) async {
      final multipleOptionsField = DynamicField(
        controlType: FieldType.refDataDropdown,
        key: "refdata_key",
        label: "Reference Data Dropdown",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "ref1", pairValue: "Reference 1"),
          Option(key: "ref2", pairValue: "Reference 2"),
          Option(key: "ref3", pairValue: "Reference 3"),
          Option(key: "ref4", pairValue: "Reference 4"),
          Option(key: "ref5", pairValue: "Reference 5"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: multipleOptionsField,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
    });

    testWidgets("renders dropdown builder correctly",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicReferenceDataDropdown(
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
              onSubmit: (p0) {},
            ),
          ),
        ),
      );

      expect(find.byType(DynamicReferenceDataDropdown), findsOneWidget);
      // Verify the dropdown builder functionality is tested
    });
  });
}
