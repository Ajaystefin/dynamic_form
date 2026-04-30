import "package:decimal/decimal.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart";

class NotFunded extends StatelessWidget {
  const NotFunded({required this.viewModel, super.key});
  final AddOtherBankDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.nonFunded".tr(),
      isRequired: (viewModel.isFiFlow) ? false : true,
      showLabel: true,
      child: CustomTextField(
        semanticLabel:
            "groupInformation.facilitiesWithOtherBanks.nonFunded".tr(),
        initialValue:
            viewModel.currentFacilityItems.nonFundedLimit?.toString() ?? "",
        validator: (viewModel.isFiFlow) ? null : CustomValidator.requiredField,
        inputFormatters: [DecimalInputFormatter()],
        onChanged: (value) {
          viewModel.currentFacilityItems.nonFundedLimit =
              Decimal.tryParse(value);
          viewModel.calculateTotal();
        },
        onSaved: (value) {
          viewModel.currentFacilityItems.nonFundedLimit =
              Decimal.tryParse(value.toString());
        },
      ),
    );
  }
}
