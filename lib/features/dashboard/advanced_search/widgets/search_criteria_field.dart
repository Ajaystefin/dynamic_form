import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/model.dart";

/// Dropdown field for selecting the search criteria.
class SearchCriteriaField extends StatelessWidget {
  /// Creates a [SearchCriteriaField].
  const SearchCriteriaField({
    required this.viewModel,
    super.key,
    this.width,
  });

  /// View model used to manage advanced search values.
  final AdvancedSearchViewModel viewModel;

  /// Optional width for the field.
  final double? width;

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
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        onSelected: (selectedValue) async {
          await viewModel.onSearchCriteriaSelected(selectedValue.first);
        },
        dropdownBuilder: (context, item) => Text(item?.name ?? ""),
        selectedItems: viewModel.selectedSearchCriteria != null
            ? [viewModel.selectedSearchCriteria!]
            : null,
      ),
    );
  }
}
