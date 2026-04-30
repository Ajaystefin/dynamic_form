import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/model.dart";
import "package:wcas_frontend/models/login/user.dart";

class RMNameField extends StatelessWidget {
  const RMNameField({required this.viewModel, super.key, this.width});
  final AdvancedSearchViewModel viewModel;
  final double? width;

  @override
  Widget build(BuildContext context) {
    Scale.setup(context, const Size(1080, 1));

    return LabelWidget(
      isRequired: true,
      label: "dashboard.advancedSearch.rmName".tr(),
      child: CustomDropdown<User>(
        validationMessage: "common.validation.pleaseEnter".tr() +
            "dashboard.advancedSearch.rmName".tr(),
        semanticLabel: "dashboard.advancedSearch.rmName".tr(),
        items: viewModel.userList,
        isLoading: viewModel.state.fieldLoader,
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.userName,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        onSelected: (selectedValue) {
          viewModel.onRMNameSelected(selectedValue.first);
        },
        dropdownBuilder: (context, item) => Text(item?.userName ?? ""),
        selectedItems:
            viewModel.selectedRM != null ? [viewModel.selectedRM] : null,
      ),
    );
  }
}
