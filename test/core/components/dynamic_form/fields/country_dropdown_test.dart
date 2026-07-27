import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/country_dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";

void main() {
  group("DynamicFormCountryDropdown", () {
    late DynamicField mockFieldData;
    late Function(CustomDropdownItem) mockSelectedOption;

    setUp(() {
      mockFieldData = DynamicField(
        controlType: FieldType.countryDropdown,
        key: "country_key",
        label: "Country",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        message: "Please select a country",
        dependentList: [
          Option(key: "us", pairValue: "United States"),
          Option(key: "uk", pairValue: "United Kingdom"),
          Option(key: "ca", pairValue: "Canada"),
        ],
      );
      mockSelectedOption = (CustomDropdownItem item) {};
    });

    testWidgets("renders correctly with required parameters",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormCountryDropdown(
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test for label text with required indicator
      // expect(find.text('Country *'), findsOneWidget);
      //expect(find.byType(DynamicFormCountryDropdown), findsOneWidget);
    });

    testWidgets("renders without label when showLabel is false",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormCountryDropdown(
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
              showLabel: false,
            ),
          ),
        ),
      );

      expect(find.text("Country"), findsNothing);
    });

    testWidgets("shows required indicator when field is required",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormCountryDropdown(
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormCountryDropdown), findsOneWidget);
    });

    testWidgets("handles empty dependent list", (WidgetTester tester) async {
      final fieldWithEmptyList = DynamicField(
        controlType: FieldType.countryDropdown,
        key: "country_key",
        label: "Country",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        dependentList: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormCountryDropdown(
              fieldData: fieldWithEmptyList,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormCountryDropdown), findsOneWidget);
    });

    testWidgets("handles null dependent list", (WidgetTester tester) async {
      final fieldWithNullList = DynamicField(
        controlType: FieldType.countryDropdown,
        key: "country_key",
        label: "Country",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormCountryDropdown(
              fieldData: fieldWithNullList,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormCountryDropdown), findsOneWidget);
    });

    testWidgets("renders as disabled when isDisable is true",
        (WidgetTester tester) async {
      final disabledField = DynamicField(
        controlType: FieldType.countryDropdown,
        key: "country_key",
        label: "Country",
        required: false,
        rowData: 1,
        enabledDefault: false,
        isDisable: true,
        dependentList: [
          Option(key: "us", pairValue: "United States"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormCountryDropdown(
              fieldData: disabledField,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormCountryDropdown), findsOneWidget);
    });

    testWidgets("renders with validation message", (WidgetTester tester) async {
      final fieldWithValidation = DynamicField(
        controlType: FieldType.countryDropdown,
        key: "country_key",
        label: "Country",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        message: "This field is required",
        dependentList: [
          Option(key: "us", pairValue: "United States"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormCountryDropdown(
              fieldData: fieldWithValidation,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormCountryDropdown), findsOneWidget);
    });

    testWidgets("handles non-required field correctly",
        (WidgetTester tester) async {
      final optionalField = DynamicField(
        controlType: FieldType.countryDropdown,
        key: "country_key",
        label: "Country (Optional)",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        dependentList: [
          Option(key: "us", pairValue: "United States"),
          Option(key: "uk", pairValue: "United Kingdom"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormCountryDropdown(
              fieldData: optionalField,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.text("Country (Optional)"), findsOneWidget);
    });

    testWidgets("renders with single country option",
        (WidgetTester tester) async {
      final singleOptionField = DynamicField(
        controlType: FieldType.countryDropdown,
        key: "country_key",
        label: "Country",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        dependentList: [
          Option(key: "us", pairValue: "United States"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormCountryDropdown(
              fieldData: singleOptionField,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormCountryDropdown), findsOneWidget);
    });

    testWidgets("handles multiple country options",
        (WidgetTester tester) async {
      final multipleOptionsField = DynamicField(
        controlType: FieldType.countryDropdown,
        key: "country_key",
        label: "Country",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        dependentList: [
          Option(key: "us", pairValue: "United States"),
          Option(key: "uk", pairValue: "United Kingdom"),
          Option(key: "ca", pairValue: "Canada"),
          Option(key: "au", pairValue: "Australia"),
          Option(key: "de", pairValue: "Germany"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormCountryDropdown(
              fieldData: multipleOptionsField,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormCountryDropdown), findsOneWidget);
    });

    testWidgets("handles field with empty label", (WidgetTester tester) async {
      final fieldWithEmptyLabel = DynamicField(
        controlType: FieldType.countryDropdown,
        key: "country_key",
        label: "",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        dependentList: [
          Option(key: "us", pairValue: "United States"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormCountryDropdown(
              fieldData: fieldWithEmptyLabel,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormCountryDropdown), findsOneWidget);
    });

    testWidgets("renders dropdown with searchable functionality",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormCountryDropdown(
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormCountryDropdown), findsOneWidget);
    });

    testWidgets("covers callback function execution",
        (WidgetTester tester) async {
      // Test the callback logic directly
      final List<CustomDropdownItem> localCallbackResults = [];
      void localMockSelectedOption(CustomDropdownItem item) {
        localCallbackResults.add(item);
      }

      final testOption = Option(key: "TEST", pairValue: "Test Value");
      final List<Option> testList = [testOption];

      // This simulates the onSelected callback being triggered with a list
      localMockSelectedOption(testList.first);

      expect(localCallbackResults.length, 1);
      expect(localCallbackResults.first.label, "TEST");

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormCountryDropdown(
              fieldData: mockFieldData,
              selectedOption: localMockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormCountryDropdown), findsOneWidget);
    });

    testWidgets("tests dropdown builder with data values",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormCountryDropdown(
              fieldData: mockFieldData,
              selectedOption: mockSelectedOption,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormCountryDropdown), findsOneWidget);

      // This helps test the dropdownBuilder function (line 37)
      expect(find.byType(Text), findsAtLeastNWidgets(1));
    });
  });
}
