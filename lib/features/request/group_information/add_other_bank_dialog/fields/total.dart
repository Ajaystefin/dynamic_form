import "package:decimal/decimal.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart";

class Total extends StatelessWidget {
  const Total({required this.viewModel, super.key});
  final AddOtherBankDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.total".tr(),
      isRequired: false,
      showLabel: true,
      child: CustomTextField(
        controller: viewModel.facilityController,
        semanticLabel: "groupInformation.facilitiesWithOtherBanks.total".tr(),
        initialValue: viewModel.currentFacilityItems.total?.toString() ?? "0",
        hintText: viewModel.currentFacilityItems.total?.toString() ?? "0",
        readOnly: true,
        filled: true,
        onChanged: (value) {
          viewModel.currentFacilityItems.total =
              Decimal.tryParse(value.toString());
        },
        onSaved: (value) {
          viewModel.currentFacilityItems.total =
              Decimal.tryParse(value.toString());
        },
      ),
    );
  }
}
