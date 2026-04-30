import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ShariaApproval extends StatelessWidget {
  const ShariaApproval({required this.viewModel, super.key});
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.shariaApproval".tr(),
          isRequired: false,
          showLabel: true,
          child: CustomRadioButton<Reference>(
            isEnabled: viewModel.canEdit,
            //  isEnabled: viewModel.canEdit ? viewModel.viewAccessRolesCheck()
            //         ? true
            //         : false : false,
            itemBuilder: (context, item, isSelected, isEnabled) =>
                Text(item.name ?? ""),
            options:
                viewModel.getFilteredOptions(viewModel.shariaApprovalItems),
            selectedValue: viewModel.getSelectedReference(
              options: viewModel.shariaApprovalItems,
              selectedValue: viewModel.selectedShariaApproval,
              fallbackFlag: viewModel.applicationDetails?.shariaApproval,
            ),
            validator: (value) => viewModel.validateSelection(
              value?.name,
              viewModel.getFilteredOptions(viewModel.shariaApprovalItems),
              "requestInformation.requestInformation.selectShariaApproval".tr(),
            ),
            onChanged: (selectedRef) {
              viewModel.onShariaApprovalSelected(selectedRef);
            },
            selectedColor: AppColors.primary,
            unselectedColor: Colors.grey,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }
}
