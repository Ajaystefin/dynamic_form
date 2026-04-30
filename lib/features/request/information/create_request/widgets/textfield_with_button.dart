import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/information/create_request/model.dart";

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
    this.readOnly = false,
    this.isLoading = false,
    this.isRequired = false,
    this.inputFormatters,
    this.validator,
    this.focusNode,
    this.semanticLabel,
    this.isFromDialogue = false,
    this.maxLength,
  });
  final String? value;
  final CreateRequestViewModel viewModel;
  final String label;
  final Function(String)? onChanged;
  final Function(String)? onSubmit;
  final String? Function(String?)? validator;
  final String buttonLabel;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final bool isLoading;
  final bool isRequired;
  final bool isFromDialogue;
  final String? semanticLabel;
  final int? maxLength;

  final VoidCallback? buttonOnPressed;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: label,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      isRequired: isRequired,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomTextField(
              key: ValueKey(viewModel.isFieldsFilled()),
              semanticLabel: semanticLabel ?? label,
              filled: viewModel.isFieldsFilled() || readOnly,
              inputFormatters: inputFormatters,
              readOnly: readOnly,
              validator: viewModel.showError ? validator : null,
              initialValue: value,
              hintText: value,
              onChanged: onChanged,
              onSubmitted: onSubmit,
              maxLength: maxLength,
            ),
          ),
          const Gap(
            direction: Axis.horizontal,
          ),
          CustomButton(
            isLoading: isLoading,
            onPressed: readOnly ? null : buttonOnPressed,
            label: buttonLabel,
          ),
          const Gap(customValue: 40),
        ],
      ),
    );
  }
}
