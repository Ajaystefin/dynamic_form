import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown_textbox.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/dropdown_textfield.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/single_check_box.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/grid_field.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/globals.dart';

class DynamicFormGrid extends StatefulWidget {
  final bool isTable;
  final DynamicField fieldData;
  final Map<String, dynamic> document;
  const DynamicFormGrid({
    super.key,
    required this.fieldData,
    this.isTable = false,
    required this.document,
  });

  @override
  State<DynamicFormGrid> createState() => _DynamicFormGridState();
}

class _DynamicFormGridState extends State<DynamicFormGrid> {
  List<List<Widget>> rows = [];

  @override
  void initState() {
    rows = getRows();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isTable)
            IconButton(
                onPressed: () {
                  addSingleTableRow();
                },
                icon: const Icon(Icons.add)),
          buildTable(rows: rows, columns: getTableColumns()),
        ],
      ),
    );
  }

  List<List<Widget>> getRows() {
    return [
      [
        for (int i = 0; i < (widget.fieldData.columnInfoList?.length ?? 0); i++)
          formWidget(widget.fieldData.columnInfoList![i].dynamicField, i)
      ]
    ];
  }

  Widget buildTable({
    required List<List<Widget>> rows,
    required List<TableColumn> columns,
  }) {
    return CustomRawTable(
      key: UniqueKey(),
      columns: columns, autoFitWidth: true,
      rows: rows,
      // columnGroups: columnGroups,
    );
  }

  void _deleteRow(int rowIndex) {
    setState(() {
      rows.removeAt(rowIndex);
    });
  }

  List<TableColumn> getTableColumns() {
    List<TableColumn> columns = [];
    for (DynamicGridField element in widget.fieldData.columnInfoList ?? []) {
      columns.add(
        TableColumn(label: Text(element.dynamicField.label)),
      );
    }
    return columns;
  }

  Widget deleteFunction(int index) {
    return IconButton(
        onPressed: () {
          _deleteRow(index);
        },
        icon: const Icon(Icons.delete));
  }

  Widget formWidget(DynamicField dynamicField, int index) {
    switch (dynamicField.controlType) {
      case FieldType.textField:
        return CustomTextField(
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: dynamicField.isDisable,
          counterText: "",
          onSaved: (value) {
            widget.document[dynamicField.key] = value;
          },
        );
      case FieldType.customerSearch:
        return CustomTextField(
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: dynamicField.isDisable,
          onSaved: (value) {
            widget.document[dynamicField.key] = value;
          },
        );

      case FieldType.amount:
        return CustomTextField(
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: dynamicField.isDisable,
          onSaved: (value) {
            widget.document[dynamicField.key] = value;
          },
        );
      case FieldType.percentage:
        return CustomTextField(
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: dynamicField.isDisable,
          onSaved: (value) {
            widget.document[dynamicField.key] = value;
          },
        );
      case FieldType.datePicker:
        return CustomDatePicker(
          onSubmit2: (DateTime? selectedDate) {
            widget.document[dynamicField.key] = selectedDate;
          },
        );
      case FieldType.singleCheckBox:
        return DynamicFormSingleCheckBox(
          fieldData: dynamicField,
          onSaved: (value) {
            widget.document[dynamicField.key] = value;
          },
          onChanged: (value) => widget.document[dynamicField.key] = value,
        );
      case FieldType.dropdown:
        return CustomDropdown<Option>(
          validationMessage: dynamicField.message,
          isEnabled: !dynamicField.isDisable,
          isSearchable: true,
          items: dynamicField.optionList ?? [],
          onSelected: (value) => widget.document[dynamicField.key] = value,
          itemBuilder: (context, item, isDisabled, isSelected) {
            return dropdownItemBuildWidget(item.value);
          },
          dropdownBuilder: (context, data) {
            return dropdownBuilderWidget(
              text: data?.value ?? "",
              showToolTip: false,
            );
          },
        );
      case FieldType.currency:
        return CustomDropdownTextbox(
          options: Globals.dynamicFormCurrencyCodes ?? [],
          initialOption: Globals.dynamicFormCurrencyCodes?.first.value,
          onChanged: (value) => widget.document[dynamicField.key] = value,
        );
      case FieldType.grid:
        return DynamicFormGrid(
          fieldData: dynamicField,
          document: widget.document,
        );
      case FieldType.multiSelect:
        return CustomMultiSelectDropdown(
            isEnabled: !dynamicField.isDisable,
            isSearchable: true,
            items: (dynamicField.optionList ?? []).map((e) => e.value).toList(),
            onSelected: (value) => widget.document[dynamicField.key] = value);
      case FieldType.tenorControl:
        return DynamicFormDropdownTextfield(
          onSubmit: (value) {}, inputFormatters: const [],
          showLabel: false,
          fieldData: dynamicField,
          // selectedOptions: (value) =>
          //     widget.document[dynamicField.key] = value);
        );
      default:
        return const SizedBox();
    }
  }

  void addSingleTableRow() {
    setState(() {
      rows.add([
        // ignore: unused_local_variable
        for (var element in widget.fieldData.columnInfoList ?? [])
          const Text(""),
      ]);
    });
  }
}
