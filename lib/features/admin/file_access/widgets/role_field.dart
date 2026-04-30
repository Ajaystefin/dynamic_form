import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/features/admin/file_access/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class RoleField extends StatelessWidget {
  const RoleField({required this.viewModel, super.key});
  final FileAccessViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    Scale.setup(context, const Size(1080, 1));
    return LabelWidget(
      label: "admin.fileAccess.role".tr(),
      isRequired: true,
      child: SizedBox(
        width: context.isDesktop
            ? 250.w
            : context.isTablet
                ? 500.w
                : 700.w,
        child: CustomDropdown<Reference>(
          validationMessage: "common.validation.pleaseEnter".tr() +
              "admin.fileAccess.role".tr(),
          semanticLabel: "admin.fileAccess.role".tr(),
          showClearIcon: false,
          items: viewModel.roles,
          onSelected: (selectedValue) {
            viewModel.onRoleTypeSelected(
              selectedValue.first,
            );
          },
          dropdownBuilder: (context, item) =>
              Text(item?.name?.capitalizeFirstLetter() ?? ""),
          itemBuilder: (context, item, isDisabled, isSelected) {
            return dropdownItemBuildWidget(
              item.name?.capitalizeFirstLetter(),
              isListTile: true,
              isSelected: isSelected,
            );
          },
          selectedItems: viewModel.selectedRoleType != null
              ? [
                  viewModel.roles?.firstWhere(
                        (r) => r.id == viewModel.selectedRoleType!.id,
                      ) ??
                      viewModel.selectedRoleType!,
                ]
              : [
                  Reference(
                    name: "admin.referenceDataManagement.selectValue".tr(),
                  ),
                ],
        ),
      ),
    );
  }
}
