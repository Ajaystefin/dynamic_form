import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/search_project/model.dart";

class TextfieldWithButton extends StatelessWidget {
  const TextfieldWithButton({
    required this.viewModel,
    required this.label,
    required this.buttonLabel,
    required this.buttonOnPressed,
    super.key,
    this.value,
    this.onSubmit,
    this.onChanged,
    this.filled = false,
    this.readOnly = false,
    this.isLoading = false,
    this.inputFormatters,
    this.validator,
    this.onSaved,
    this.isRequired = false,
    this.showLabel = true,
    this.showbuttonLabel = true,
    this.hintText,
    this.controller,
    this.maxLength,
  });
  final String? value;
  final SearchProjectViewModel viewModel;
  final String label;
  final Function(String)? onChanged;
  final Function(String)? onSubmit;
  final String? Function(String?)? validator;
  final String buttonLabel;
  final bool readOnly;
  final bool filled;
  final List<TextInputFormatter>? inputFormatters;
  final bool isLoading;
  final Function(String?)? onSaved;
  final bool isRequired; // Display * or + based on flag
  final bool showLabel; // Toggle label visibility
  final bool showbuttonLabel;
  final String? hintText;
  final TextEditingController? controller;
  final int? maxLength;
  final VoidCallback buttonOnPressed;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: label,
      isRequired: isRequired,
      showLabel: showLabel,
      child: Row(
        spacing: 20,
        children: [
          Expanded(
            child: CustomTextField(
              inputFormatters: inputFormatters,
              readOnly: readOnly,
              validator: validator,
              hintText: hintText,
              initialValue: value,
              onChanged: onChanged,
              onSubmitted: onSubmit,
              controller: controller,
              maxLength: maxLength,
              onSaved: onSaved,
              filled: filled,
            ),
          ),
          showbuttonLabel
              ? CustomButton(
                  isLoading: isLoading,
                  onPressed: buttonOnPressed,
                  label: buttonLabel,
                )
              : Container(),
        ],
      ),
    );
  }
}
