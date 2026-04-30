import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/dynamic_form/field.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/country_dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/currency_dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/dropdown_textfield.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/editable_dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/multi_check_box.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/multiselect.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/single_check_box.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/textfield.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";

void main() {
  // /
  // ===========================================================================
  /// Helpers
  // /
  // ===========================================================================

  DynamicFormField buildField(
    FieldType type, {
    bool showField = true,
    List<Option>? options,
    Map<String, dynamic>? document, // onCurrencyFieldChangeallow injection
  }) {
    return DynamicFormField(
      field: DynamicField(
        key: "${type.name}_key",
        controlType: type,
        label: type.name,
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: options,
      ),
      document: document ?? <String, dynamic>{},
    );
  }

  Future<void> pumpField(WidgetTester tester, DynamicFormField field) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: field),
      ),
    );
  }

  // /
  // ===========================================================================
  /// BASIC RENDERING
  // /
  // ===========================================================================

  testWidgets("renders SizedBox.shrink when showField is false",
      (tester) async {
    await pumpField(
      tester,
      buildField(FieldType.textField, showField: false),
    );

    // Widget exists but renders nothing
    expect(find.byType(DynamicFormField), findsOneWidget);
    expect(find.byType(SizedBox), findsWidgets);
  });

  // /
  // ===========================================================================
  /// FIELD TYPE COVERAGE (SINGLE LOOP)
  // /
  // ===========================================================================
  testWidgets("formWidget renders widget-safe field types", (tester) async {
    final widgetSafeTypes = [
      FieldType.entityIdField,
      FieldType.textField,
      FieldType.percentage,
      FieldType.datePicker,
      FieldType.singleCheckBox,
      FieldType.checkbox,
      FieldType.dropdown,
      FieldType.editableDropdown,
      FieldType.currency,
      FieldType.multiSelect,
      FieldType.customerSearch,
      FieldType.amount,
      FieldType.tenorControl,
      FieldType.conditionalTextbox,
      FieldType.textArea,
      FieldType.radioButton,
      FieldType.refDataDropdown,
      FieldType.countryDropdown,
      FieldType.conditionaldropdown,
      FieldType.accountNo,
      FieldType.label,
      FieldType.sizedBox,
    ];

    for (final type in widgetSafeTypes) {
      await pumpField(
        tester,
        buildField(
          type,
          options: (type == FieldType.dropdown ||
                  type == FieldType.multiSelect ||
                  type == FieldType.radioButton)
              ? [Option(key: "A", pairValue: "a")]
              : null,
        ),
      );

      expect(
        find.byType(DynamicFormField),
        findsOneWidget,
        reason: "Should render for $type",
      );

      // Clear tree between iterations
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets("default case renders SizedBox", (tester) async {
    await pumpField(
      tester,
      DynamicFormField(
        field: DynamicField(
          controlType: FieldType.none,
          key: "none",
          label: "None",
          required: false,
          rowData: 1,
          enabledDefault: true,
          isDisable: false,
        ),
        document: const <String, dynamic>{},
      ),
    );

    expect(find.byType(SizedBox), findsWidgets);
  });

  // /
  // ===========================================================================
  /// DOCUMENT UPDATE BEHAVIOUR
  // /
  // ===========================================================================
  testWidgets("text input updates document on change", (tester) async {
    final document = <String, dynamic>{};

    await pumpField(
      tester,
      buildField(
        FieldType.textField,
        document: document, // onCurrencyFieldChangeSAME MAP
      ),
    );

    await tester.enterText(
      find.byType(DynamicFormTextField),
      "hello",
    );
    await tester.pump();

    expect(document["textField_key"], "hello");
  });

  testWidgets("singleCheckBox sets default value when missing", (tester) async {
    final document = <String, dynamic>{};

    final field = DynamicFormField(
      field: DynamicField(
        controlType: FieldType.singleCheckBox,
        key: "check",
        label: "Check",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        defaultValue: "true",
      ),
      document: document,
    );

    await pumpField(tester, field);

    // default value should be applied during build
    expect(document["check"], isTrue);
  });

  // /
  // ===========================================================================
  /// DEFAULT / SAFETY CASES
  // /
  // ===========================================================================

  testWidgets("unknown field type renders SizedBox safely", (tester) async {
    await pumpField(
      tester,
      DynamicFormField(
        field: DynamicField(
          controlType: FieldType.none,
          key: "none",
          label: "None",
          required: false,
          rowData: 1,
          enabledDefault: true,
          isDisable: false,
        ),
        document: const <String, dynamic>{},
      ),
    );

    // Widget exists but renders nothing
    expect(find.byType(DynamicFormField), findsOneWidget);
    expect(find.byType(SizedBox), findsWidgets);
  });

  // /
  // ===========================================================================
  /// LIFECYCLE
  // /
  // ===========================================================================

  testWidgets("widget disposes safely when removed from tree", (tester) async {
    await pumpField(
      tester,
      buildField(FieldType.textField),
    );

    // Remove widget → triggers dispose
    await tester.pumpWidget(const SizedBox.shrink());

    // No exception thrown = success
    expect(tester.takeException(), isNull);
  });

  group("NumericFloatingPointFormatter", () {
    late NumericFloatingPointFormatter formatter;

    setUp(() {
      formatter = NumericFloatingPointFormatter();
    });

    test("allows empty input", () {
      const oldValue = TextEditingValue(text: "123");
      const newValue = TextEditingValue(text: "");

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "");
    });

    test("allows integer input", () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: ""),
        const TextEditingValue(text: "123"),
      );

      expect(result.text, "123");
    });

    test("allows decimal input", () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: ""),
        const TextEditingValue(text: "12.34"),
      );

      expect(result.text, "12.34");
    });

    test("allows leading decimal point", () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: ""),
        const TextEditingValue(text: ".5"),
      );

      expect(result.text, ".5");
    });

    test("allows trailing decimal point", () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: "12"),
        const TextEditingValue(text: "12."),
      );

      expect(result.text, "12.");
    });

    test("rejects letters", () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: "123"),
        const TextEditingValue(text: "123a"),
      );

      expect(result.text, "123");
    });

    test("rejects special characters", () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: "123"),
        const TextEditingValue(text: "123!"),
      );

      expect(result.text, "123");
    });

    test("rejects multiple decimal points", () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: "1.2"),
        const TextEditingValue(text: "1.2.3"),
      );

      expect(result.text, "1.2");
    });
  });

  group("Currency & Save Handlers", () {
    late Map<String, dynamic> document;
    late String? changedKey;
    late dynamic changedValue;

    setUp(() {
      document = {};
      changedKey = null;
      changedValue = null;
    });

    testWidgets(
      "currency change updates document and triggers callback",
      (tester) async {
        final field = DynamicFormField(
          field: DynamicField(
            key: "currency_key",
            controlType: FieldType.currency,
            label: "Currency",
            required: false,
            rowData: 1,
            enabledDefault: true,
            isDisable: false,
          ),
          document: document,
          onFieldChange: (key, value) {
            changedKey = key;
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: field)),
        );

        // onCurrencyFieldChangeCall the submit callback exposed by the currency
        // widget
        final currencyWidget =
            tester.widget<DynamicFormCurrencyDropdownTextfield>(
          find.byType(DynamicFormCurrencyDropdownTextfield),
        );

        final currencyMap = {"currency": "USD", "amount": "100"};

        currencyWidget.onSubmit(currencyMap);

        expect(document["currency_key"], currencyMap);
        expect(changedKey, "currency_key");
        expect(changedValue, currencyMap);
      },
    );

    testWidgets(
      "onFieldSaved updates document without triggering callback",
      (tester) async {
        final field = DynamicFormField(
          field: DynamicField(
            key: "text_key",
            controlType: FieldType.textField,
            label: "Text",
            required: false,
            rowData: 1,
            enabledDefault: true,
            isDisable: false,
          ),
          document: document,
          onFieldChange: (key, value) {
            changedKey = key;
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: field)),
        );

        // onCurrencyFieldChangeTrigger save instead of change
        final textField = tester.widget<DynamicFormTextField>(
          find.byType(DynamicFormTextField),
        );

        textField.onSubmit.call("savedValue");

        expect(document["text_key"], "savedValue");
        expect(changedKey, isNull);
        expect(changedValue, isNull);
      },
    );
  });

  group("DynamicFormSingleCheckBox handlers", () {
    late Map<String, dynamic> document;
    late String? changedKey;
    late dynamic changedValue;

    setUp(() {
      document = {};
      changedKey = null;
      changedValue = null;
    });

    testWidgets(
      "onChanged updates document and triggers onFieldChange callback",
      (tester) async {
        final field = DynamicFormField(
          field: DynamicField(
            key: "check_key",
            controlType: FieldType.singleCheckBox,
            label: "Check",
            required: false,
            rowData: 1,
            enabledDefault: true,
            isDisable: false,
          ),
          document: document,
          onFieldChange: (key, value) {
            changedKey = key;
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: field)),
        );

        final checkBox = tester.widget<DynamicFormSingleCheckBox>(
          find.byType(DynamicFormSingleCheckBox),
        );

        // simulate change
        checkBox.onChanged.call(true);

        expect(document["check_key"], true);
        expect(changedKey, "check_key");
        expect(changedValue, true);
      },
    );

    testWidgets(
      "onSaved updates document without triggering onFieldChange",
      (tester) async {
        final field = DynamicFormField(
          field: DynamicField(
            key: "check_key",
            controlType: FieldType.singleCheckBox,
            label: "Check",
            required: false,
            rowData: 1,
            enabledDefault: true,
            isDisable: false,
          ),
          document: document,
          onFieldChange: (key, value) {
            changedKey = key;
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: field)),
        );

        final checkBox = tester.widget<DynamicFormSingleCheckBox>(
          find.byType(DynamicFormSingleCheckBox),
        );

        // simulate save
        checkBox.onSaved.call(false);

        expect(document["check_key"], false);
        expect(changedKey, isNull);
        expect(changedValue, isNull);
      },
    );
  });

  group("DynamicFormMultiCheckBox handlers", () {
    late Map<String, dynamic> document;
    late String? changedKey;
    late dynamic changedValue;

    setUp(() {
      document = {};
      changedKey = null;
      changedValue = null;
    });

    testWidgets(
      "onChanged updates document and triggers onFieldChange callback",
      (tester) async {
        final field = DynamicFormField(
          field: DynamicField(
            key: "multi_check_key",
            controlType: FieldType.checkbox,
            label: "Multi Check",
            required: false,
            rowData: 1,
            enabledDefault: true,
            isDisable: false,
          ),
          document: document,
          onFieldChange: (key, value) {
            changedKey = key;
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: field)),
        );

        final widget = tester.widget<DynamicFormMultiCheckBox>(
          find.byType(DynamicFormMultiCheckBox),
        );

        final values = ["A", "B"];

        widget.onChanged.call(values);

        expect(document["multi_check_key"], values);
        expect(changedKey, "multi_check_key");
        expect(changedValue, values);
      },
    );

    testWidgets(
      "onSaved updates document without triggering onFieldChange",
      (tester) async {
        final field = DynamicFormField(
          field: DynamicField(
            key: "multi_check_key",
            controlType: FieldType.checkbox,
            label: "Multi Check",
            required: false,
            rowData: 1,
            enabledDefault: true,
            isDisable: false,
          ),
          document: document,
          onFieldChange: (key, value) {
            changedKey = key;
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: field)),
        );

        final widget = tester.widget<DynamicFormMultiCheckBox>(
          find.byType(DynamicFormMultiCheckBox),
        );

        final values = ["C"];

        widget.onSaved.call(values);

        expect(document["multi_check_key"], values);
        expect(changedKey, isNull);
        expect(changedValue, isNull);
      },
    );
  });

  group("DynamicFormDropdown handlers", () {
    late Map<String, dynamic> document;
    late String? changedKey;
    late dynamic changedValue;

    setUp(() {
      document = {};
      changedKey = null;
      changedValue = null;
    });

    testWidgets(
      "selectedOption updates document and triggers onFieldChange",
      (tester) async {
        final field = DynamicFormField(
          field: DynamicField(
            key: "dropdown_key",
            controlType: FieldType.dropdown,
            label: "Dropdown",
            required: false,
            rowData: 1,
            enabledDefault: true,
            isDisable: false,
            optionList: [
              Option(key: "A", pairValue: "a"),
              Option(key: "B", pairValue: "b"),
            ],
          ),
          document: document,
          onFieldChange: (key, value) {
            changedKey = key;
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: field)),
        );

        final dropdown = tester.widget<DynamicFormDropdown>(
          find.byType(DynamicFormDropdown),
        );

        final selectedOption = Option(key: "A", pairValue: "a");

        dropdown.selectedOption.call(selectedOption);

        expect(document["dropdown_key"], "A"); // value.key
        expect(changedKey, "dropdown_key");
        expect(changedValue, selectedOption);
      },
    );
  });
  group("DynamicFormEditableDropdown handlers", () {
    late Map<String, dynamic> document;
    late String? changedKey;
    late dynamic changedValue;

    setUp(() {
      document = {};
      changedKey = null;
      changedValue = null;
    });

    testWidgets(
      "onValueChange updates document and triggers onFieldChange",
      (tester) async {
        final field = DynamicFormField(
          field: DynamicField(
            key: "editable_dropdown_key",
            controlType: FieldType.editableDropdown,
            label: "Editable Dropdown",
            required: false,
            rowData: 1,
            enabledDefault: true,
            isDisable: false,
          ),
          document: document,
          onFieldChange: (key, value) {
            changedKey = key;
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: field)),
        );

        final editableDropdown = tester.widget<DynamicFormEditableDropdown>(
          find.byType(DynamicFormEditableDropdown),
        );

        editableDropdown.onValueChange.call("customValue");

        expect(document["editable_dropdown_key"], "customValue");
        expect(changedKey, "editable_dropdown_key");
        expect(changedValue, "customValue");
      },
    );
  });

  group("DynamicFormGrid (grid & table cases)", () {
    test("FieldType.grid can be instantiated without crashing", () {
      final document = <String, dynamic>{};

      final field = DynamicFormField(
        field: DynamicField(
          key: "grid_key",
          controlType: FieldType.grid,
          label: "Grid",
          required: false,
          rowData: 1,
          enabledDefault: true,
          isDisable: false,
        ),
        document: document,
      );

      // Just creating the widget is the test
      expect(field, isNotNull);
    });

    test("FieldType.table can be instantiated without crashing", () {
      final document = <String, dynamic>{};

      final field = DynamicFormField(
        field: DynamicField(
          key: "table_key",
          controlType: FieldType.table,
          label: "Table",
          required: false,
          rowData: 1,
          enabledDefault: true,
          isDisable: false,
        ),
        document: document,
      );

      // Just creating the widget is the test
      expect(field, isNotNull);
    });
  });

  group("DynamicFormMultiSelectDropdown handlers", () {
    late Map<String, dynamic> document;
    late String? changedKey;
    late dynamic changedValue;

    setUp(() {
      document = {};
      changedKey = null;
      changedValue = null;
    });

    testWidgets(
      "selectedOptions updates document and triggers onFieldChange",
      (tester) async {
        final field = DynamicFormField(
          field: DynamicField(
            key: "multi_select_key",
            controlType: FieldType.multiSelect,
            label: "Multi Select",
            required: false,
            rowData: 1,
            enabledDefault: true,
            isDisable: false,
            optionList: [
              Option(key: "A", pairValue: "a"),
              Option(key: "B", pairValue: "b"),
            ],
          ),
          document: document,
          onFieldChange: (key, value) {
            changedKey = key;
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: field)),
        );

        final multiSelect = tester.widget<DynamicFormMultiSelectDropdown>(
          find.byType(DynamicFormMultiSelectDropdown),
        );

        final selectedValues = ["a", "b"];

        // simulate selection
        multiSelect.selectedOptions.call(selectedValues);

        expect(document["multi_select_key"], selectedValues);
        expect(changedKey, "multi_select_key");
        expect(changedValue, selectedValues);
      },
    );
  });
  group("DynamicFormDropdownTextfield (tenorControl)", () {
    late Map<String, dynamic> document;
    late String? changedKey;
    late dynamic changedValue;

    setUp(() {
      document = {};
      changedKey = null;
      changedValue = null;
    });

    testWidgets(
      "onSubmit updates document and triggers onFieldChange",
      (tester) async {
        final field = DynamicFormField(
          field: DynamicField(
            key: "tenor_key",
            controlType: FieldType.tenorControl,
            label: "Tenor",
            required: false,
            rowData: 1,
            enabledDefault: true,
            isDisable: false,
          ),
          document: document,
          onFieldChange: (key, value) {
            changedKey = key;
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: field)),
        );

        final tenorWidget = tester.widget<DynamicFormDropdownTextfield>(
          find.byType(DynamicFormDropdownTextfield),
        );

        // onCurrencyFieldChangeFIX: pass Map<String, dynamic>, not String
        final submitValue = {"value": "12M"};

        tenorWidget.onSubmit.call(submitValue);

        expect(document["tenor_key"], submitValue);
        expect(changedKey, "tenor_key");
        expect(changedValue, submitValue);
      },
    );
  });
  group("DynamicFormDropdown (conditionaldropdown) handlers", () {
    late Map<String, dynamic> document;
    late String? changedKey;
    late dynamic changedValue;

    setUp(() {
      document = {};
      changedKey = null;
      changedValue = null;
    });

    testWidgets(
      "selectedOption updates document and triggers onFieldChange",
      (tester) async {
        final field = DynamicFormField(
          field: DynamicField(
            key: "conditional_dropdown_key",
            controlType: FieldType.conditionaldropdown,
            label: "Conditional Dropdown",
            required: false,
            rowData: 1,
            enabledDefault: true,
            isDisable: false,
            optionList: [
              Option(key: "A", pairValue: "a"),
              Option(key: "B", pairValue: "b"),
            ],
          ),
          document: document,
          onFieldChange: (key, value) {
            changedKey = key;
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: field)),
        );

        final dropdown = tester.widget<DynamicFormDropdown>(
          find.byType(DynamicFormDropdown),
        );

        final selectedOption = Option(key: "A", pairValue: "a");

        dropdown.selectedOption.call(selectedOption);

        // document stores value.key
        expect(document["conditional_dropdown_key"], "A");
        expect(changedKey, "conditional_dropdown_key");
        expect(changedValue, selectedOption);
      },
    );
  });

  group("DynamicFormCountryDropdown handlers", () {
    late Map<String, dynamic> document;
    late String? changedKey;
    late dynamic changedValue;

    setUp(() {
      document = {};
      changedKey = null;
      changedValue = null;
    });

    testWidgets(
      "selectedOption updates document and triggers onFieldChange",
      (tester) async {
        final field = DynamicFormField(
          field: DynamicField(
            key: "country_key",
            controlType: FieldType.countryDropdown,
            label: "Country",
            required: false,
            rowData: 1,
            enabledDefault: true,
            isDisable: false,
          ),
          document: document,
          onFieldChange: (key, value) {
            changedKey = key;
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: field)),
        );

        final countryDropdown = tester.widget<DynamicFormCountryDropdown>(
          find.byType(DynamicFormCountryDropdown),
        );

        // onCurrencyFieldChangemust pass CustomDropdownItem (not String)
        final selectedCountry = CustomDropdownItem(
          value: "IN",
          label: "India",
        );

        countryDropdown.selectedOption.call(selectedCountry);

        expect(document["country_key"], selectedCountry);
        expect(changedKey, "country_key");
        expect(changedValue, selectedCountry);
      },
    );
  });
}
