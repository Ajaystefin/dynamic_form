import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart";

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
  });
  final String? value;
  final DigitalEfilingViewModel viewModel;
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
              searchDebounce: const Duration(milliseconds: 800),
              onSearchChanged: (String query) async {
                // Simulate API call or search operation
                // await Future.delayed(const Duration(seconds: 2));
                debugPrint("Search query: $query");
                await onSubmit!(query);
                // Your actual search logic here
                // e.g., await viewModel.searchItems(query);
              },
            ),
          ),
        ],
      ),
    );
  }
}
