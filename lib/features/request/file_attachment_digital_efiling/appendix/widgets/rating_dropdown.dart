import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";

/// CustomCountryRatingDropdown stateless widget
class CustomCountryRatingDropdown extends StatelessWidget {
  /// Creates [CustomCountryRatingDropdown] instance
  const CustomCountryRatingDropdown({
    required this.onRatingChange,
    required this.ratingOptions,
    required this.viewModel,
    super.key,
    this.selectedRating,
  });

  /// onSave callback function
  final void Function(String) onRatingChange;

  /// selected rating
  final String? selectedRating;

  /// AppendixViewModel view model to handle actions
  final AppendixViewModel viewModel;

  /// List of rating options
  final List<String> ratingOptions;

  @override
  Widget build(BuildContext context) {
    final List<String> options = ratingOptions.map((e) => e.trim()).toList();
    final String? initial = selectedRating?.trim();

    return LabelWidget(
      label: "eDigitalFilingFileAttachments.appendix.countryRating".tr(),
      child: CustomDropdown<String>(
        // Use a stable key so the dropdown doesn't lose its internal controller/overlay
        key: const ValueKey("country-rating-dropdown"),
        isEnabled: !viewModel.isAppendixReadOnly,

        items: options,

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

        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item,
            isSelected: isSelected ?? false,
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
