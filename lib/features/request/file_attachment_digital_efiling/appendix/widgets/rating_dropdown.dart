import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';


class CustomCountryRatingDropdown extends StatelessWidget {
  final Function(String) onRatingChange;
  final String? selectedRating;
  final List<String> ratingOptions;

  const CustomCountryRatingDropdown({
    super.key,
    required this.onRatingChange,
    required this.ratingOptions,
    this.selectedRating,
  });

  @override
  Widget build(BuildContext context) {

    return LabelWidget(
      label: 'eDigitalFilingFileAttachments.appendix.countryRating'.tr(),
      isRequired: false,
      child: CustomDropdown<String>(
        validationMessage: "common.validation.countryRating".tr(),
        items: ratingOptions,
        onSelected: (selected) {
          if (selected.isNotEmpty) {
           final value = selected.first;
            (onRatingChange).call(value);
          }
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data ?? '',
            style: const TextStyle(fontSize: 13),
          );
        },
        selectedItems: selectedRating != null ? [selectedRating!] : [],
      ),
    );
  }
}