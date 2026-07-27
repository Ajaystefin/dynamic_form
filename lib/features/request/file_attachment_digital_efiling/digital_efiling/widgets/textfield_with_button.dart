import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart";

/// TextfieldWithButton stateless widget
class TextfieldWithButton extends StatelessWidget {
  /// Creates [TextfieldWithButton] instance
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
    this.isSelectionDialog = false,
    this.showAsteric = true,
  });

  /// value
  final String? value;

  /// DigitalEfilingViewModel view model to handle actions
  final DigitalEfilingViewModel viewModel;

  /// Label
  final String label;

  /// onChanged callback function
  final Function(String)? onChanged;

  /// onSave callback function
  final Function(String)? onSubmit;

  /// validator callback function
  final String? Function(String?)? validator;

  /// string to set button label
  final String buttonLabel;

  /// is read only or not
  final bool readOnly;

  /// List of TextInputFormatter
  final List<TextInputFormatter>? inputFormatters;

  /// for showing loader
  final bool isLoading;

  /// whether required or not
  final bool isRequired;

  /// from dialogue flag
  final bool isFromDialogue;

  /// semantic label
  final String? semanticLabel;

  /// selection dialog flag
  final bool isSelectionDialog;

  /// show asteric flag
  final bool showAsteric;

  /// buttonOnPressed function
  final VoidCallback? buttonOnPressed;

  /// FocusNode reference variable
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: label,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      isRequired: isRequired,
      showAsteric: showAsteric,
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
              searchDebounce: const Duration(milliseconds: 800),
              onSearchChanged: (String query) async {
                // Simulate API call or search operation
                // await Future.delayed(const Duration(seconds: 2));
                logger.i("Search query: $query");
                await onSubmit!(query);
                // Your actual search logic here
                // e.g., await viewModel.searchItems(query);
              },
            ),
          ),
          if (isSelectionDialog)
            const Gap(
              direction: Axis.horizontal,
            ),
          if (isSelectionDialog)
            CustomButton(
              isLoading: isLoading,
              onPressed: readOnly ? null : buttonOnPressed,
              label: buttonLabel,
            ),
          if (isSelectionDialog) const Gap(customValue: 40),
        ],
      ),
    );
  }
}
