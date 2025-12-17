import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/ccsys/create_request/model.dart';

class TextfieldWithButton extends StatelessWidget {
  const TextfieldWithButton(
      {super.key,
      this.value,
      this.onSubmit,
      required this.viewModel,
      required this.label,
      this.onChanged,
      required this.buttonLabel,
      required this.buttonOnPressed,
      this.readOnly = false,
      this.isLoading = false,
      this.isRequired = false,
      this.inputFormatters,
      this.validator,
      this.focusNode,
      this.semanticLabel,
      this.isFromDialogue = false});
  final String? value;
  final CcsysCreateRequestViewModel viewModel;
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
                onChanged: onChanged,
                onSubmitted: onSubmit,
              ),
            ),
            const Gap(
              direction: Axis.horizontal,
            ),
            CustomButton(
              isLoading: isLoading,
              onPressed: buttonOnPressed,
              label: buttonLabel,
            ),
            const SizedBox(
              width: 40,
            )
          ],
        ));
  }
}
