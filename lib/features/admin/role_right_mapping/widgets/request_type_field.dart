import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class RequestTypeField extends StatelessWidget {
  const RequestTypeField({required this.viewModel, super.key});
  final RoleRightMappingViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    Scale.setup(context, const Size(1080, 1));
    return SizedBox(
      height: 80,
      width: 250.w,
      child: LabelWidget(
        label: "admin.roleRightMapping.requestType".tr(),
        isRequired: true,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        child: CustomDropdown<Reference>(
          items: viewModel.requestTypes ?? [],
          semanticLabel: "admin.roleRightMapping.requestType".tr(),
          onSelected: (selectedValue) {
            viewModel.onRequestTypeSelected(
              selectedValue.first,
            );
          },
          dropdownBuilder: (context, item) => Text(item?.name ?? ""),
          itemBuilder: (context, item, isDisabled, isSelected) {
            return dropdownItemBuildWidget(
              item.name,
              isListTile: true,
              isSelected: isSelected,
            );
          },
          selectedItems: viewModel.selectedRequestType != null
              ? [viewModel.selectedRequestType]
              : [
                  Reference(
                    name: "admin.roleRightMapping.selectValue".tr(),
                  ),
                ],
        ),
      ),
    );
  }
}
