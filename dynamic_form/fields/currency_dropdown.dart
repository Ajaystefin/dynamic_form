import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/button_dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';

class DynamicFormCurrecnyDropdownTextfield extends StatefulWidget {
  final DynamicField fieldData;
  final Map<String, dynamic>? document;
  final Function(Map<String, dynamic>) onSubmit;
  final bool showLabel;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;

  const DynamicFormCurrecnyDropdownTextfield({
    super.key,
    required this.fieldData,
    this.document,
    required this.onSubmit,
    this.showLabel = false,
    this.inputFormatters,
    this.controller,
  });

  @override
  State<DynamicFormCurrecnyDropdownTextfield> createState() => _DynamicFormCurrecnyDropdownTextfieldState();
}

class _DynamicFormCurrecnyDropdownTextfieldState extends State<DynamicFormCurrecnyDropdownTextfield> {
  late TextEditingController _controller;
  String? _initialCurrency;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _initializeFromDocument();
  }

  void _initializeFromDocument() {
    if (widget.document == null) return;

    final storedValue = widget.document![widget.fieldData.key];
    if (storedValue is Map<String, dynamic> && storedValue.isNotEmpty) {
      // Currency field stores as {currency: amount}
      final entry = storedValue.entries.first;
      _initialCurrency = entry.key;
      if (_controller.text.isEmpty) {
        _controller.text = entry.value?.toString() ?? '';
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = CurrencyDropdown(
      textFieldWidth: 215.w,
      options: widget.fieldData.optionList ?? [],
      initialOption: _initialCurrency ?? widget.fieldData.optionList?.first.value,
      controller: _controller,
      onChanged: (value) {
        widget.onSubmit(value);
      },
    );
    return widget.showLabel
        ? LabelWidget(
            showLabel: widget.showLabel,
            label: widget.fieldData.label,
            isRequired: widget.fieldData.required,
            child: child)
        : child;
  }
}

class CurrencyDropdown extends StatelessWidget {
  final TextEditingController? controller;
  final String? textFieldLabel;
  final String? dropdownLabel;
  final double? textFieldWidth;
  final List<CustomDropdownItem> options;
  final String? initialOption;
  final String? Function(String?)? validator;
  final Function(Map<String, dynamic>)? onChanged;

  const CurrencyDropdown(
      {super.key,
      this.controller,
      required this.options,
      this.textFieldLabel,
      this.dropdownLabel,
      this.textFieldWidth,
      this.initialOption,
      this.validator,
      this.onChanged});

  Widget makeExpandableWidget(bool isExpanded, Widget child) {
    return isExpanded ? Expanded(child: child) : child;
  }

  @override
  Widget build(BuildContext context) {
    String? selectedOption = initialOption;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.textFieldBorder),
          borderRadius: BorderRadius.circular(4)),
      child: Row(
        spacing: 2.0,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: dropdownLabel,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textFieldBorder),
                  borderRadius: BorderRadius.circular(4.0)),
              child: CustomDropdownButton(
                borderRadius: 4.0,
                label: dropdownLabel ?? "",
                disabledColor: AppColors.scaffoldBackground,
                textColor: AppColors.defaultTextColor,
                options: options
                    .map((option) => CustomDropdownItem(
                          value: option.value,
                          label: option.value,
                          onPressed: option.onPressed,
                        ))
                    .toList(),
                height: 34.0,
                isSearchable: false,
                initialOption: CustomDropdownItem(
                  value: initialOption ?? "",
                  label: initialOption ?? "",
                ),
                callBack: (selectedValue) => selectedOption = selectedValue,
              ),
            ),
          ),
          makeExpandableWidget(
            textFieldWidth == null,
            CustomTextField(
              semanticLabel: textFieldLabel,
              validator: validator,
              controller: controller,
              hintText: textFieldLabel,
              width: textFieldWidth,
              onChanged: (value) {
                if (onChanged != null && selectedOption != null) {
                  onChanged!({selectedOption!: value});
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
