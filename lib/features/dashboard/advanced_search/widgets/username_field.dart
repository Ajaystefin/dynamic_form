import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/dashboard/advanced_search/model.dart';
import 'package:wcas_frontend/models/login/user.dart';

class UsernameField extends StatelessWidget {
  final AdvancedSearchViewModel viewModel;
  final double? width;
  const UsernameField({super.key, required this.viewModel, this.width});

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
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.id, isSelected: isSelected);
        },
        onSelected: (selectedValue) {
          viewModel.onUserNameSelected(selectedValue.first);
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.id ?? ""),
        selectedItems: viewModel.selectedUserName != null
            ? [viewModel.selectedUserName!]
            : null,
      ),
    );
  }
}
