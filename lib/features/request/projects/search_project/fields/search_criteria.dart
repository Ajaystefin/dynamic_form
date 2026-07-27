import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/projects/search_project/model.dart";
import "package:wcas_frontend/features/request/projects/search_project/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Search criteria dropdown section for the search project screen.
class SearchCriteria extends StatelessWidget {
  /// Creates a search criteria section.
  const SearchCriteria({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// Search project view model.
  final SearchProjectViewModel viewModel;

  /// Search project state.
  final SearchProjectState state;

  @override
  Widget build(BuildContext context) {
    // final bool isValid = viewModel.canEdit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "project.searchProject.searchCriteria".tr(),
          isRequired: true,
          child: CustomDropdown<Reference>(
            // isEnabled: isValid,
            validationMessage: "common.validation.pleaseEnter".tr() +
                "requestInformation.createRequest.requestType".tr(),
            semanticLabel: "validation.emptyField".tr(),
            items: viewModel.searchCriteriaItems,
            selectedItems: viewModel.searchCriteriaValue == null
                ? null
                : [viewModel.searchCriteriaValue],
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                viewModel.onSearchCriteriaSelected(selectedValue.first);
              }
            },
            itemBuilder: (context, item, {isDisabled, isSelected}) {
              return dropdownItemBuildWidget(
                item.name,
                isSelected: isSelected ?? false,
              );
            },
            dropdownBuilder: (context, data) {
              return Text(
                data?.name ?? "",
                style: const TextStyle(fontSize: 14),
              );
            },
          ),
        ),
      ],
    );
  }
}
