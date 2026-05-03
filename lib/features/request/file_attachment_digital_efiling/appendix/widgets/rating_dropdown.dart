import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";

class CustomCountryRatingDropdown extends StatelessWidget {
  const CustomCountryRatingDropdown({
    required this.onRatingChange,
    required this.ratingOptions,
    required this.viewModel,
    super.key,
    this.selectedRating,
  });
  final void Function(String) onRatingChange;
  final String? selectedRating;
  final AppendixViewModel viewModel;
  final List<String> ratingOptions;

  @override
  Widget build(BuildContext context) {
    final List<String> options = ratingOptions.map((e) => e.trim()).toList();
    final String? initial = selectedRating?.trim();

    return LabelWidget(
      label: "eDigitalFilingFileAttachments.appendix.countryRating".tr(),
      isRequired: false, // not mandatory
      child: CustomDropdown<String>(
        // Use a stable key so the dropdown doesn't lose its internal controller/overlay
        key: const ValueKey("country-rating-dropdown"),
        isEnabled: !viewModel.isAppendixReadOnly,

        // Optional field: disable validation/red state
        validationMessage: null,

        items: options,
        showClearIcon: true,

        // IMPORTANT: use an empty list (not null) to represent "no selection"
        selectedItems:
            (initial != null && initial.isNotEmpty) ? [initial] : const [],

        onSelected: (List<String> selected) {
          if (selected.isEmpty) {
            // Clear clicked
            onRatingChange("");
            // Unfocus to close any open input/overlay if applicable
            FocusScope.of(context).unfocus();
            return;
          }

          final String value = selected.first.trim();
          onRatingChange(value);
          FocusScope.of(context).unfocus();
        },

        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item,
            isListTile: true,
            isSelected: isSelected,
          );
        },

        // Let the dropdown render the selected text by itself (no custom
        // builder).
        // Removing dropdownBuilder prevents type shape issues and keeps clear
        // behavior correct.
      ),
    );
  }
}
