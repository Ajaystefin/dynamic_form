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
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
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
  final Map<String, TextEditingController> controllers = {};

  List<List<Widget>> rows = [];

  bool _isSourceKey(String key) {
    return key == 'noOfUnits' || key == 'mvPerUnit';
  }

  void calculateTotal(String key) {
    if (!_isSourceKey(key)) return;

    String unitsStr = widget.document['noOfUnits']?.toString() ?? '0';
    String perUnitStr = widget.document['mvPerUnit']?.toString() ?? '0';

    double units = double.tryParse(unitsStr.replaceAll(',', '')) ?? 0.0;
    double perUnit = double.tryParse(perUnitStr.replaceAll(',', '')) ?? 0.0;

    double total = units * perUnit;

    widget.document['totalMv'] = total;

    final totalCtrl = controllers['totalMv'];
    if (totalCtrl != null) {
      final formatted = total.toString();
      if (totalCtrl.text != formatted) {
        totalCtrl.text = formatted;
      }
    }

    setState(() {});
  }

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
          Row(
            children: [
              Text(widget.fieldData.label, style: AppStyle.boldLabel),
              const Gap(
                direction: Axis.horizontal,
              ),
              if (!widget.isTable)
                IconButton(
                    onPressed: () {
                      addSingleTableRow();
                    },
                    icon: const Icon(Icons.add)),
            ],
          ),
          buildTable(columns: getTableColumns()),
        ],
      ),
    );
  }

  List<List<Widget>> getRows() {
    List<DynamicGridField>? dynamicFormGridFields =
        (widget.fieldData.columnInfoList ?? []);
    return [
      [
        for (int i = 0; i < dynamicFormGridFields.length; i++) ...[
          formWidget(dynamicFormGridFields[i].dynamicField, i, false)
        ],
        const SizedBox()
      ]
    ];
  }

  Widget buildTable({
    required List<TableColumn> columns,
  }) {
    return CustomRawTable(
      key: UniqueKey(),
      columns: columns,
      autoFitWidth: true,
      rows: rows,
    );
  }

  void _deleteRow() {
    setState(() {
      rows.removeLast();
    });
  }

  List<TableColumn> getTableColumns() {
    List<TableColumn> columns = [];
    for (DynamicGridField element in widget.fieldData.columnInfoList ?? []) {
      columns.add(
        TableColumn(label: Text(element.dynamicField.label)),
      );
    }
    return [...columns, const TableColumn(forcedWidth: 30, label: SizedBox())];
  }

  Widget deleteFunction() {
    return IconButton(
        onPressed: () {
          _deleteRow();
        },
        icon: const Icon(Icons.delete));
  }

  Widget formWidget(DynamicField dynamicField, int index, bool isNewRow) {
    dynamicField.isNewRow = isNewRow;
    late Widget returnWidget;

    final controller = controllers.putIfAbsent(
        dynamicField.key, () => TextEditingController());

    final initialText = widget.document[dynamicField.key]?.toString() ?? '';
    if (controller.text != initialText) {
      controller.text = initialText;
    }

    switch (dynamicField.controlType) {
      case FieldType.textField:
        returnWidget = CustomTextField(
          key: UniqueKey(),
          controller: controller,
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: dynamicField.isDisable || dynamicField.key == 'totalMv',
          counterText: "",
          onSaved: (value) {
            widget.document[dynamicField.key] = value;
          },
          onChanged: (value) {
            widget.document[dynamicField.key] = value;

            calculateTotal(dynamicField.key);
          },
        );
      case FieldType.customerSearch:
        returnWidget = CustomTextField(
          key: UniqueKey(),
          controller: controller,
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: dynamicField.isDisable,
          counterText: "",
          onSaved: (value) {
            widget.document[dynamicField.key] = value;
          },
          onChanged: (value) {
            widget.document[dynamicField.key] = value;
          },
        );
      case FieldType.amount:
        returnWidget = CustomTextField(
          key: UniqueKey(),
          controller: controller,
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: dynamicField.isDisable,
          onSaved: (value) {
            widget.document[dynamicField.key] = value;
          },
          onChanged: (value) {
            widget.document[dynamicField.key] = value;

            calculateTotal(dynamicField.key);
          },
        );
      case FieldType.percentage:
        returnWidget = CustomTextField(
          key: UniqueKey(),
          controller: controller,
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: dynamicField.isDisable,
          onSaved: (value) {
            widget.document[dynamicField.key] = value;
          },
          onChanged: (value) {
            widget.document[dynamicField.key] = value;
            calculateTotal(dynamicField.key);
          },
        );
      case FieldType.datePicker:
        returnWidget = CustomDatePicker(
          key: UniqueKey(),
          controller: controller,
          initialDateTime: widget.document[dynamicField.key],
          onSubmit2: (DateTime? selectedDate) {
            widget.document[dynamicField.key] = selectedDate;
          },
        );
      case FieldType.singleCheckBox:
        returnWidget = DynamicFormSingleCheckBox(
          key: UniqueKey(),
          fieldData: dynamicField,
          value: widget.document[dynamicField.key],
          onSaved: (value) {
            widget.document[dynamicField.key] = value;
          },
          onChanged: (value) => widget.document[dynamicField.key] = value,
        );
      case FieldType.dropdown:
        returnWidget = CustomDropdown<Option>(
          key: UniqueKey(),
          validationMessage: dynamicField.message,
          isEnabled: !dynamicField.isDisable,
          isSearchable: true,
          items: dynamicField.optionList ?? [],
          selectedItems: widget.document[dynamicField.key],
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
        returnWidget = CustomDropdownTextbox(
          key: UniqueKey(),
          controller: controller,
          options: Globals.dynamicFormCurrencyCodes ?? [],
          initialOption: Globals.dynamicFormCurrencyCodes?.first.value,
          onChanged: (value) => widget.document[dynamicField.key] = value,
        );
      case FieldType.grid:
        returnWidget = DynamicFormGrid(
          key: UniqueKey(),
          fieldData: dynamicField,
          document: widget.document,
        );
      case FieldType.multiSelect:
        returnWidget = CustomMultiSelectDropdown(
            key: UniqueKey(),
            isEnabled: !dynamicField.isDisable,
            isSearchable: true,
            items: (dynamicField.optionList ?? []).map((e) => e.value).toList(),
            onSelected: (value) => widget.document[dynamicField.key] = value);
      case FieldType.tenorControl:
        returnWidget = DynamicFormDropdownTextfield(
          key: UniqueKey(),
          onSubmit: (value) {}, inputFormatters: const [],
          showLabel: false,
          fieldData: dynamicField,
          // selectedOptions: (value) =>
          //     widget.document[dynamicField.key] = value);
        );
      default:
        returnWidget = const SizedBox();
    }
    return returnWidget;
  }

  void addSingleTableRow() {
    rows.add([
      // ignore: unused_local_variable
      for (int i = 0; i < (widget.fieldData.columnInfoList?.length ?? 0); i++)
        formWidget(widget.fieldData.columnInfoList![i].dynamicField, i, true),
      deleteFunction(),
    ]);
    setState(() {});
  }
}
