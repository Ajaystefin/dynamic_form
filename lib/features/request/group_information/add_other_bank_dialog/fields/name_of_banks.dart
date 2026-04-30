import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class NameOfBanks extends StatelessWidget {
  const NameOfBanks({required this.viewModel, super.key});
  final AddOtherBankDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.nameofBanks".tr(),
      isRequired: (viewModel.isFiFlow) ? false : true,
      showLabel: true,
      child: CustomDropdown<Reference>(
        semanticLabel:
            "groupInformation.facilitiesWithOtherBanks.nameofBanks".tr(),
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
        items: viewModel.bankNameOptions,
        onSelected: (selected) {
          viewModel.nameofBanksReferenceSelected(selected.first);
        },
        validationMessage:
            (viewModel.isFiFlow) ? "" : "requestInformation.requiredField".tr(),
        selectedItems: viewModel.currentFacilityItems.bankNameId == null
            ? null
            : viewModel.bankNameOptions
                .where((e) => e.id == viewModel.currentFacilityItems.bankNameId)
                .toList(),
      ),
    );
  }
}
