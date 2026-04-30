import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/model.dart";
import "package:wcas_frontend/models/login/user.dart";

class UsernameField extends StatelessWidget {
  const UsernameField({required this.viewModel, super.key, this.width});
  final AdvancedSearchViewModel viewModel;
  final double? width;

  @override
  Widget build(BuildContext context) {
    Scale.setup(context, const Size(1080, 1));

    return LabelWidget(
      isRequired: true,
      label: "dashboard.advancedSearch.username".tr(),
      child: CustomDropdown<User>(
        showClearIcon: false,
        semanticLabel: "dashboard.advancedSearch.username".tr(),
        validationMessage: "common.validation.pleaseEnter".tr() +
            "dashboard.advancedSearch.username".tr(),
        items: viewModel.userList,
        isLoading: viewModel.state.fieldLoader,
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.name, isSelected: isSelected);
        },
        onSelected: (selectedValue) {
          viewModel.onUserNameSelected(selectedValue.first);
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name ?? ""),
        selectedItems: viewModel.selectedUserName != null
            ? [viewModel.selectedUserName]
            : null,
      ),
    );
  }
}
