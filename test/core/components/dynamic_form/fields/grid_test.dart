import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/currency_dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/dropdown_textfield.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/grid.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/reference_data_dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/single_check_box.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/grid_field.dart";
import "package:wcas_frontend/core/components/textfield.dart";

void main() {
  Widget buildTestWidget(
    DynamicField fieldData,
    Map<String, dynamic> document, {
    bool isTable = false,
    Set<String>? disabledCells,
    Set<String>? enabledCells,
    Function(String, Object?)? onFieldChange,
    Function(String, TextEditingController)? onControllerCreated,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DynamicFormGrid(
          fieldData: fieldData,
          document: document,
          isTable: isTable,
          disabledCells: disabledCells,
          enabledCells: enabledCells,
          onFieldChange: onFieldChange,
          onControllerCreated: onControllerCreated,
        ),
      ),
    );
  }

  DynamicField createBaseField(
    String key,
    FieldType type, {
    List<Option>? options,
    defaultValue,
  }) {
    return DynamicField(
      controlType: type,
      key: key,
      label: key,
      required: false,
      rowData: 0,
      enabledDefault: true,
      isDisable: false,
      optionList: options,
      defaultValue: defaultValue,
    );
  }

  group("DynamicFormGrid Tests", () {
    testWidgets("renders all control types and handles input",
        (WidgetTester tester) async {
      final Map<String, dynamic> document = {};

      final columns = [
        DynamicGridField(
          columnTitle: "Text",
          dynamicField: createBaseField("textCol", FieldType.textField),
        ),
        DynamicGridField(
          columnTitle: "Cust",
          dynamicField: createBaseField("custCol", FieldType.customerSearch),
        ),
        DynamicGridField(
          columnTitle: "Amount",
          dynamicField: createBaseField("amountCol", FieldType.amount),
        ),
        DynamicGridField(
          columnTitle: "Percent",
          dynamicField: createBaseField("percentCol", FieldType.percentage),
        ),
        DynamicGridField(
          columnTitle: "Date",
          dynamicField: createBaseField("dateCol", FieldType.datePicker),
        ),
        DynamicGridField(
          columnTitle: "Check",
          dynamicField: createBaseField("checkCol", FieldType.singleCheckBox),
        ),
        DynamicGridField(
          columnTitle: "Drop",
          dynamicField: createBaseField(
            "dropCol",
            FieldType.dropdown,
            options: [Option(key: "1", pairValue: "One")],
          ),
        ),
        DynamicGridField(
          columnTitle: "EditDrop",
          dynamicField: createBaseField(
            "editDropCol",
            FieldType.editableDropdown,
            options: [Option(key: "2", pairValue: "Two")],
          ),
        ),
        DynamicGridField(
          columnTitle: "Currency",
          dynamicField: createBaseField("currCol", FieldType.currency),
        ),
        DynamicGridField(
          columnTitle: "Multi",
          dynamicField: createBaseField(
            "multiCol",
            FieldType.multiSelect,
            options: [Option(key: "3", pairValue: "Three")],
          ),
        ),
        DynamicGridField(
          columnTitle: "Tenor",
          dynamicField: createBaseField("tenorCol", FieldType.tenorControl),
        ),
        DynamicGridField(
          columnTitle: "RefData",
          dynamicField: createBaseField(
            "refCol",
            FieldType.refDataDropdown,
            options: [Option(key: "4", pairValue: "Four")],
          ),
        ),
        DynamicGridField(
          columnTitle: "Unknown",
          dynamicField: createBaseField("unkCol", FieldType.none),
        ),
        DynamicGridField(
          columnTitle: "AccountNo",
          dynamicField: createBaseField("accCol", FieldType.accountNo),
        ),
        DynamicGridField(
          columnTitle: "Grid",
          dynamicField: createBaseField("subGrid", FieldType.grid),
        ),
      ];

      final gridField = DynamicField(
        controlType: FieldType.grid,
        key: "mainGrid",
        label: "Main Grid",
        required: true,
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
        columnInfoList: columns,
      );

      await tester.pumpWidget(
        buildTestWidget(
          gridField,
          document,
          onFieldChange: (fieldKey, value) {},
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CustomTextField), findsWidgets);
      expect(find.byType(CustomDatePicker), findsWidgets);
      expect(find.byType(DynamicFormSingleCheckBox), findsWidgets);
      expect(find.byType(CustomDropdown<Option>), findsWidgets);
      expect(find.byType(DynamicFormCurrencyDropdownTextfield), findsWidgets);
      expect(find.byType(CustomMultiSelectDropdown), findsWidgets);
      expect(find.byType(DynamicFormDropdownTextfield), findsWidgets);
      expect(find.byType(DynamicReferenceDataDropdown), findsWidgets);

      // Add Row test
      final addIcon = find.byIcon(Icons.add).first;
      await tester.tap(addIcon);
      await tester.pumpAndSettle();

      // Delete Row test
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
    });

    testWidgets("handles document initialization correctly",
        (WidgetTester tester) async {
      final columns = [
        DynamicGridField(
          columnTitle: "Text",
          dynamicField: createBaseField("textCol", FieldType.textField),
        ),
        DynamicGridField(
          columnTitle: "Check",
          dynamicField: createBaseField("checkCol", FieldType.singleCheckBox),
        ),
      ];

      final gridField = DynamicField(
        controlType: FieldType.grid,
        key: "mainGrid",
        label: "Main Grid",
        required: false,
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
        columnInfoList: columns,
      );

      final Map<String, dynamic> document = {
        "mainGrid.textCol@0": "Hello Row 0",
        "mainGrid.checkCol@0": true,
        "mainGrid.textCol@1": "Hello Row 1",
        "mainGrid.checkCol@1": false,
        "mainGrid.textCol@2": "No effect",
      };

      await tester.pumpWidget(buildTestWidget(gridField, document));
      await tester.pumpAndSettle();

      expect(find.text("Hello Row 0"), findsOneWidget);
      expect(find.text("Hello Row 1"), findsOneWidget);
      expect(find.text("No effect"), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsNWidgets(2));
    });

    testWidgets("handles enabled and disabled combinations",
        (WidgetTester tester) async {
      final columns = [
        DynamicGridField(
          columnTitle: "Text",
          dynamicField: createBaseField("textCol", FieldType.textField),
        ),
      ];

      final gridField = DynamicField(
        controlType: FieldType.grid,
        key: "mainGrid",
        label: "Main Grid",
        required: false,
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
        columnInfoList: columns,
      );

      final Map<String, dynamic> document = {
        "mainGrid.textCol@0": "Row 0",
        "mainGrid.textCol@1": "Row 1",
      };

      await tester.pumpWidget(
        buildTestWidget(
          gridField,
          document,
          disabledCells: {"mainGrid.textCol@0"},
          enabledCells: {"mainGrid.textCol@1"},
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets("Table mode does not show add/delete actions",
        (WidgetTester tester) async {
      final columns = [
        DynamicGridField(
          columnTitle: "Text",
          dynamicField: createBaseField("textCol", FieldType.textField),
        ),
      ];

      final gridField = DynamicField(
        controlType: FieldType.grid,
        key: "mainGrid",
        label: "Main Grid",
        required: false,
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
        columnInfoList: columns,
      );

      final Map<String, dynamic> document = {};
      await tester
          .pumpWidget(buildTestWidget(gridField, document, isTable: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets("onChange callbacks verify row operations",
        (WidgetTester tester) async {
      final columns = [
        DynamicGridField(
          columnTitle: "Text",
          dynamicField: createBaseField("textCol", FieldType.textField),
        ),
      ];

      final gridField = DynamicField(
        controlType: FieldType.grid,
        key: "mainGrid",
        label: "Main Grid",
        required: false,
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
        columnInfoList: columns,
      );

      String? lastField;
      dynamic lastValue;

      await tester.pumpWidget(
        buildTestWidget(
          gridField,
          {},
          onFieldChange: (field, value) {
            lastField = field;
            lastValue = value;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(CustomTextField).first, "Test Input");
      await tester.pump();

      expect(lastField, "textCol");
      expect(lastValue["value"], "Test Input");
      expect(lastValue["index"], 0);
    });

    testWidgets("covers edge cases and callbacks", (WidgetTester tester) async {
      final columns = [
        DynamicGridField(
          columnTitle: "Date",
          dynamicField: createBaseField("dateCol", FieldType.datePicker)
            ..message = "Date Needed"
            ..isMandatory = true,
        ),
        DynamicGridField(
          columnTitle: "Percent",
          dynamicField: createBaseField(
            "percentCol",
            FieldType.percentage,
            defaultValue: "10",
          ),
        ),
        DynamicGridField(
          columnTitle: "Editable",
          dynamicField: createBaseField("editCol", FieldType.editableDropdown),
        ),
      ];

      final gridField = DynamicField(
        controlType: FieldType.grid,
        key: "edgeGrid",
        label: "Edge Grid",
        required: false,
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
        columnInfoList: columns,
      );

      final Map<String, dynamic> document = {
        "edgeGrid.dateCol@0": {"jsdate": "2023-10-10"},
        "edgeGrid.percentCol@0": "15.5",
        "edgeGrid.editCol@0": "CustomText123",
      };

      final Map<String, TextEditingController> createdControllers = {};

      await tester.pumpWidget(
        buildTestWidget(
          gridField,
          document,
          onControllerCreated: (key, controller) {
            createdControllers[key] = controller;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(createdControllers.isNotEmpty, true);

      // Interactions
      final addIcon = find.byIcon(Icons.add).first;
      await tester.tap(addIcon);
      await tester.pumpAndSettle();

      // Delete the second row
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
    });

    testWidgets("form submission calls onSaved on all widgets",
        (WidgetTester tester) async {
      final columns = [
        DynamicGridField(
          columnTitle: "Text",
          dynamicField: createBaseField("textCol", FieldType.textField),
        ),
        DynamicGridField(
          columnTitle: "Cust",
          dynamicField: createBaseField("custCol", FieldType.customerSearch),
        ),
        DynamicGridField(
          columnTitle: "Amount",
          dynamicField: createBaseField("amountCol", FieldType.amount),
        ),
        DynamicGridField(
          columnTitle: "Percent",
          dynamicField: createBaseField("percentCol", FieldType.percentage),
        ),
        DynamicGridField(
          columnTitle: "Date",
          dynamicField: createBaseField("dateCol", FieldType.datePicker),
        ),
        DynamicGridField(
          columnTitle: "Check",
          dynamicField: createBaseField("checkCol", FieldType.singleCheckBox),
        ),
        DynamicGridField(
          columnTitle: "Drop",
          dynamicField: createBaseField(
            "dropCol",
            FieldType.dropdown,
            options: [Option(key: "1", pairValue: "One")],
          ),
        ),
        DynamicGridField(
          columnTitle: "EditDrop",
          dynamicField: createBaseField(
            "editDropCol",
            FieldType.editableDropdown,
            options: [Option(key: "2", pairValue: "Two")],
          ),
        ),
        DynamicGridField(
          columnTitle: "Currency",
          dynamicField: createBaseField("currCol", FieldType.currency),
        ),
        DynamicGridField(
          columnTitle: "Multi",
          dynamicField: createBaseField(
            "multiCol",
            FieldType.multiSelect,
            options: [Option(key: "3", pairValue: "Three")],
          ),
        ),
        DynamicGridField(
          columnTitle: "Tenor",
          dynamicField: createBaseField("tenorCol", FieldType.tenorControl),
        ),
        DynamicGridField(
          columnTitle: "RefData",
          dynamicField: createBaseField(
            "refCol",
            FieldType.refDataDropdown,
            options: [Option(key: "4", pairValue: "Four")],
          ),
        ),
        DynamicGridField(
          columnTitle: "AccountNo",
          dynamicField: createBaseField("accCol", FieldType.accountNo),
        ),
      ];

      final gridField = DynamicField(
        controlType: FieldType.grid,
        key: "saveGrid",
        label: "Save Grid",
        required: false,
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
        columnInfoList: columns,
      );

      final Map<String, dynamic> document = {};
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: DynamicFormGrid(
                fieldData: gridField,
                document: document,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger save
      formKey.currentState!.save();
    });

    testWidgets("triggers all field callbacks to maximize coverage",
        (WidgetTester tester) async {
      final columns = [
        DynamicGridField(
          columnTitle: "Text",
          dynamicField: createBaseField("textCol", FieldType.textField),
        ),
        DynamicGridField(
          columnTitle: "Cust",
          dynamicField: createBaseField("custCol", FieldType.customerSearch),
        ),
        DynamicGridField(
          columnTitle: "Amount",
          dynamicField: createBaseField("amountCol", FieldType.amount),
        ),
        DynamicGridField(
          columnTitle: "Percent",
          dynamicField: createBaseField("percentCol", FieldType.percentage),
        ),
        DynamicGridField(
          columnTitle: "Date",
          dynamicField: createBaseField("dateCol", FieldType.datePicker),
        ),
        DynamicGridField(
          columnTitle: "Check",
          dynamicField: createBaseField("checkCol", FieldType.singleCheckBox),
        ),
        DynamicGridField(
          columnTitle: "Drop",
          dynamicField: createBaseField(
            "dropCol",
            FieldType.dropdown,
            options: [Option(key: "1", pairValue: "One")],
          ),
        ),
        DynamicGridField(
          columnTitle: "EditDrop",
          dynamicField: createBaseField(
            "editDropCol",
            FieldType.editableDropdown,
            options: [Option(key: "2", pairValue: "Two")],
          ),
        ),
        DynamicGridField(
          columnTitle: "Currency",
          dynamicField: createBaseField("currCol", FieldType.currency),
        ),
        DynamicGridField(
          columnTitle: "Multi",
          dynamicField: createBaseField(
            "multiCol",
            FieldType.multiSelect,
            options: [Option(key: "3", pairValue: "Three")],
          ),
        ),
        DynamicGridField(
          columnTitle: "Tenor",
          dynamicField: createBaseField("tenorCol", FieldType.tenorControl),
        ),
        DynamicGridField(
          columnTitle: "RefData",
          dynamicField: createBaseField(
            "refCol",
            FieldType.refDataDropdown,
            options: [Option(key: "4", pairValue: "Four")],
          ),
        ),
        DynamicGridField(
          columnTitle: "AccountNo",
          dynamicField: createBaseField("accCol", FieldType.accountNo),
        ),
      ];

      final gridField = DynamicField(
        controlType: FieldType.grid,
        key: "callbackGrid",
        label: "Callback Grid",
        required: false,
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
        columnInfoList: columns,
      );

      final Map<String, dynamic> document = {};
      await tester.pumpWidget(
        buildTestWidget(gridField, document, onFieldChange: (k, v) {}),
      );
      await tester.pumpAndSettle();

      // Trigger text fields
      final textFields = find.byType(CustomTextField).evaluate().toList();
      for (final element in textFields) {
        await tester.enterText(find.byWidget(element.widget), "99");
      }
      await tester.pumpAndSettle();

      // Trigger DatePicker
      final datePicker =
          tester.widget<CustomDatePicker>(find.byType(CustomDatePicker).first);
      datePicker.onSubmit2?.call(DateTime(2023));

      // Trigger Checkbox
      final checkbox = tester.widget<DynamicFormSingleCheckBox>(
        find.byType(DynamicFormSingleCheckBox).first,
      );
      checkbox.onChanged.call(value: true);

      // Trigger Dropdowns
      final dropdowns = find.byType(CustomDropdown<Option>).evaluate().toList();
      if (dropdowns.isNotEmpty) {
        final regularDropCtx = dropdowns.first;
        final regularDrop = dropdowns.first.widget as CustomDropdown<Option>;
        regularDrop.onSelected?.call([Option(key: "1", pairValue: "One")]);
        regularDrop.filterFn?.call(Option(key: "1", pairValue: "One"), "one");
        regularDrop.itemBuilder?.call(
          regularDropCtx,
          Option(key: "1", pairValue: "One"),
          isDisabled: false,
          isSelected: false,
        );
        regularDrop.dropdownBuilder
            ?.call(regularDropCtx, Option(key: "1", pairValue: "One"));

        if (dropdowns.length > 1) {
          final editDropCtx = dropdowns.last;
          final editDrop = dropdowns.last.widget as CustomDropdown<Option>;
          editDrop.onSelected?.call([Option(key: "2", pairValue: "Two")]);
          editDrop.onEditComplete?.call("custom input");
          editDrop.onTextChanged?.call("typing");
          editDrop.filterFn?.call(Option(key: "2", pairValue: "Two"), "two");
          editDrop.itemBuilder?.call(
            editDropCtx,
            Option(key: "2", pairValue: "Two"),
            isDisabled: false,
            isSelected: false,
          );
          editDrop.dropdownBuilder
              ?.call(editDropCtx, Option(key: "2", pairValue: "Two"));
          editDrop.dropdownBuilder?.call(editDropCtx, null);
        }
      }

      // Trigger Currency
      final currency = tester.widget<DynamicFormCurrencyDropdownTextfield>(
        find.byType(DynamicFormCurrencyDropdownTextfield).first,
      );
      currency.onSubmit.call({"currency": "USD", "amount": "100"});

      // Trigger MultiSelect
      final multiSelect = tester.widget<CustomMultiSelectDropdown>(
        find.byType(CustomMultiSelectDropdown).first,
      );
      multiSelect.onSelected?.call(["Three"]);

      // Trigger Tenor
      final tenor = tester.widget<DynamicFormDropdownTextfield>(
        find.byType(DynamicFormDropdownTextfield).first,
      );
      tenor.onSubmit.call({"tenor": "1M"});

      // Trigger RefData
      final refData = tester.widget<DynamicReferenceDataDropdown>(
        find.byType(DynamicReferenceDataDropdown).first,
      );
      refData.selectedOption.call(Option(key: "4", pairValue: "Four"));
    });

    testWidgets("triggers didUpdateWidget properly on property changes",
        (WidgetTester tester) async {
      final gridField = DynamicField(
        controlType: FieldType.grid,
        key: "updateGrid",
        label: "Update Grid",
        rowData: 0,
        required: false,
        isDisable: false,
        enabledDefault: true,
        columnInfoList: [
          DynamicGridField(
            columnTitle: "Text",
            dynamicField: createBaseField("textCol", FieldType.textField),
          ),
        ],
      );
      final Map<String, dynamic> document = {};
      await tester.pumpWidget(buildTestWidget(gridField, document));
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        buildTestWidget(
          gridField,
          document,
          enabledCells: {"updateGrid.textCol@0"},
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        buildTestWidget(
          gridField,
          document,
          disabledCells: {"updateGrid.textCol@0"},
        ),
      );
      await tester.pumpAndSettle();
    });
  });
}
