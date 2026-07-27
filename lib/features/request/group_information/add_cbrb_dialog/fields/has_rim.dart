import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Has RIM selection widget.
class HasRim extends StatelessWidget {
  /// Creates a [HasRim] widget.
  const HasRim({required this.viewModel, super.key});

  /// View model used by the widget.
  final AddCbrbDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "groupInformation.facilitiesWithOtherBanks.hasRim".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        CustomRadioButton<Reference>(
          // isEnabled: viewModel.canEdit,
          itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
              Text(item.name ?? ""),
          options: viewModel.getFilteredOptions(viewModel.yesNoNaOptions),
          selectedValue: viewModel.getSelectedReference(
            options: viewModel.yesNoNaOptions,
            selectedValue: viewModel.selectedAllFailitiesYesNo,
            fallbackFlag: viewModel.isHasRimYes,
          ),
          validator: (value) => viewModel.validateSelection(
            value?.name,
            viewModel.getFilteredOptions(viewModel.yesNoNaOptions),
            "groupInformation.facilitiesWithOtherBanks.selectHasRim".tr(),
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
