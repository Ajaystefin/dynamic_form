import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/projects/search_project/model.dart";
import "package:wcas_frontend/features/request/projects/search_project/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class SearchCriteria extends StatelessWidget {
  const SearchCriteria({
    required this.viewModel,
    required this.state,
    super.key,
  });
  final SearchProjectViewModel viewModel;
  final SearchProjectState state;

  @override
  Widget build(BuildContext context) {
    // final bool isValid = viewModel.canEdit;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "project.searchProject.searchCriteria".tr(),
          isRequired: true,
          showLabel: true,
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
            itemBuilder: (context, item, isDisabled, isSelected) {
              return dropdownItemBuildWidget(
                item.name,
                isListTile: true,
                isSelected: isSelected,
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
