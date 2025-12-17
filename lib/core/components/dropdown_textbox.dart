import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button_dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class CustomDropdownTextbox extends StatelessWidget {
  final TextEditingController? controller;
  final String? textFieldLabel;
  final String? dropdownLabel;
  final double? textFieldWidth;
  final List<CustomDropdownItem> options;
  final String? initialOption;
  final String? Function(String?)? validator;
  final Function(Map<String, dynamic>)? onChanged;

  const CustomDropdownTextbox(
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
