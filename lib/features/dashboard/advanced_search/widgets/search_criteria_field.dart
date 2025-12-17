import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/dashboard/advanced_search/model.dart';

class SearchCriteriaField extends StatelessWidget {
  final AdvancedSearchViewModel viewModel;
  final double? width;
  const SearchCriteriaField({super.key, required this.viewModel, this.width});

  @override
  Widget build(BuildContext context) {
    Scale.setup(context, const Size(1080, 1));

    return LabelWidget(
      isRequired: true,
      label: "dashboard.advancedSearch.searchCriteria".tr(),
      child: CustomDropdown(
        showClearIcon: false,
        semanticLabel: "dashboard.advancedSearch.searchCriteria".tr(),
        hintText: "common.select".tr(),
        validationMessage: "common.validation.pleaseEnter".tr() +
            "dashboard.advancedSearch.searchCriteria".tr(),
        items: viewModel.getCriteriaList(),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.name,
              isListTile: true, isSelected: isSelected);
        },
        onSelected: (selectedValue) {
          viewModel.onSearchCriteriaSelected(selectedValue.first);
        },
        dropdownBuilder: (context, item) => Text(item?.name ?? ""),
        selectedItems: viewModel.selectedSearchCriteria != null
            ? [viewModel.selectedSearchCriteria!]
            : null,
      ),
    );
  }
}
