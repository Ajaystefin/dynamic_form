import "package:decimal/decimal.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart";

/// Total facilities amount field widget.
class Total extends StatelessWidget {
  /// Creates a [Total] widget.
  const Total({required this.viewModel, super.key});

  /// View model used by the widget.
  final AddOtherBankDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.total".tr(),
      label2: "groupInformation.facilitiesWithOtherBanks.inAed".tr(),
      child: CustomTextField(
        controller: viewModel.facilityController,
        semanticLabel: "groupInformation.facilitiesWithOtherBanks.total".tr(),
        initialValue: viewModel.currentFacilityItems.total?.toString() ?? "0",
        hintText: viewModel.currentFacilityItems.total?.toString() ?? "0",
        readOnly: true,
        filled: true,
        onChanged: (value) {
          viewModel.currentFacilityItems.total =
              Decimal.tryParse(value);
        },
        onSaved: (value) {
          viewModel.currentFacilityItems.total =
              Decimal.tryParse(value.toString());
        },
      ),
    );
  }
}
