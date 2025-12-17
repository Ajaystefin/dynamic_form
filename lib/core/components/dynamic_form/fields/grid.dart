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

  /// Accepts bool, 1/0, "true"/"false", "yes"/"no"
  bool get _existingCustomer {
    final v = widget.document['existingCustomer'];
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }
    return false;
  }

  void calculateTotal(String changedKey, int rowIndex) {
    if (!_isSourceKey(changedKey)) return;

    final unitsText = controllers['noOfUnits@$rowIndex']?.text ?? '';
    final priceText = controllers['mvPerUnit@$rowIndex']?.text ?? '';
    final totalCtrlKey = 'totalMv@$rowIndex';

    final units = double.tryParse(unitsText.replaceAll(',', '')) ?? 0.0;
    final pricePerUnit = double.tryParse(priceText.replaceAll(',', '')) ?? 0.0;
    final totalValue = units * pricePerUnit;

    controllers[totalCtrlKey]?.text = totalValue.toStringAsFixed(2);
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
              Text.rich(
                TextSpan(
                  text: widget.fieldData.label,
                  children: [
                    if (widget.fieldData.isRequired)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: AppColors.failure,
                          fontFeatures: [FontFeature.enable('sups')],
                        ),
                      ),
                    if (widget.fieldData.isCMOUpdate)
                      const TextSpan(
                        text: " #",
                        style: TextStyle(
                          fontSize: 9,
                          fontFeatures: [
                            FontFeature.superscripts(),
                            FontFeature.enable('sups')
                          ],
                        ),
                      ),
                  ],
                  style: AppStyle.boldLabel,
                ),
              ),
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
      rowHeight: 90,
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
        TableColumn(
          label: RichText(
              text: TextSpan(children: [
            TextSpan(
              text: element.dynamicField.label,
            ),
            if (element.dynamicField.isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.failure,
                  fontFeatures: [FontFeature.enable('sups')],
                ),
              ),
          ])),
        ),
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

    final controllerKey = '${dynamicField.key}@$index';
    final controller = controllers.putIfAbsent(
      controllerKey,
      () => TextEditingController(),
    );

    final storedValue = isNewRow ? '' : widget.document[dynamicField.key];

    final String initialText = isNewRow ? '' : (storedValue?.toString() ?? '');

    final isCurrencyMap = dynamicField.controlType == FieldType.currency &&
        storedValue is Map<String, dynamic>;

    if (!isCurrencyMap && controller.text != initialText) {
      controller.text = initialText;
    }

// right after: dynamicField.isNewRow = isNewRow;
    final String fieldKey = dynamicField.key; // <— use the key from the JSON
    if (fieldKey == 'rimNo' && !_existingCustomer) {
      return const SizedBox.shrink();
    }

    if (!isNewRow && !isCurrencyMap) {
      final initialText = storedValue?.toString() ?? '';
      if (controller.text != initialText) {
        controller.text = initialText;
      }
    } else if (isNewRow) {
      // Ensure brand-new row starts blank
      controller.text = '';
    }

    switch (dynamicField.controlType) {
      case FieldType.textField:
        returnWidget = CustomTextField(
          key: ValueKey('${dynamicField.key}_$index'),
          //  controller: controller,
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: dynamicField.isDisable ||
              dynamicField.key == 'totalMv' ||
              (fieldKey == 'customerName' && _existingCustomer),
          counterText: "",
          onSaved: (value) {
            widget.document[dynamicField.key] = value;
          },
          onChanged: (value) {
            widget.document[dynamicField.key] = value;

            calculateTotal(dynamicField.key, index);
          },
        );
      case FieldType.customerSearch:
        returnWidget = CustomTextField(
          key: UniqueKey(),
          // controller: controller,
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
          // controller: controller,
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: dynamicField.isDisable,
          onSaved: (value) {
            widget.document[dynamicField.key] = value;
          },
          onChanged: (value) {
            widget.document[dynamicField.key] = value;

            calculateTotal(dynamicField.key, index);
          },
        );
      case FieldType.percentage:
        returnWidget = CustomTextField(
          key: UniqueKey(),
          //  controller: controller,
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: dynamicField.isDisable,
          onSaved: (value) {
            widget.document[dynamicField.key] = value;
          },
          onChanged: (value) {
            widget.document[dynamicField.key] = value;
            calculateTotal(dynamicField.key, index);
          },
        );
      case FieldType.datePicker:
        returnWidget = CustomDatePicker(
          key: UniqueKey(),
          //  controller: controller,
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
          // controller: controller,
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
      for (int i = 0; i < (widget.fieldData.columnInfoList?.length ?? 0); i++)
        formWidget(widget.fieldData.columnInfoList![i].dynamicField, i, true),
      deleteFunction(),
    ]);
    setState(() {});
  }
}
