import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class DynamicRadioButton extends StatelessWidget {
  const DynamicRadioButton({required this.viewModel, super.key});
  final SelectFacilitiesDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "security.selectFacilityDialog.linktoAllFacilities".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        CustomRadioButton<Reference>(
          isEnabled: viewModel.canEdit,
          itemBuilder: (context, item, isSelected, isEnabled) =>
              Text(item.name ?? ""),
          options: viewModel.getFilteredOptions(viewModel.yesNoNaOptions),
          selectedValue: viewModel.getSelectedReference(
            options: viewModel.yesNoNaOptions,
            selectedValue: viewModel.selectedAllFailitiesYesNo,
            fallbackFlag: viewModel.securityItem?.allFacilities,
          ),
          validator: (value) => viewModel.validateSelection(
            value?.name,
            viewModel.getFilteredOptions(viewModel.yesNoNaOptions),
            "requestInformation.requestInformation.selectermApproval".tr(),
          ),
          onChanged: (selectedRef) {
            viewModel.updateFacilityLinkageOption(selectedRef);
          },
          selectedColor: AppColors.primary,
          unselectedColor: Colors.grey,
          scrollDirection: Axis.horizontal,
        ),
      ],
    );
  }
}
