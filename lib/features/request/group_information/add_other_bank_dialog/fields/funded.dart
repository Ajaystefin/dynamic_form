import "package:decimal/decimal.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart";

class Funded extends StatelessWidget {
  const Funded({required this.viewModel, super.key});
  final AddOtherBankDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.funded".tr(),
      isRequired: (viewModel.isFiFlow) ? false : true,
      showLabel: true,
      child: CustomTextField(
        semanticLabel: "groupInformation.facilitiesWithOtherBanks.funded".tr(),
        initialValue:
            viewModel.currentFacilityItems.fundedLimit?.toString() ?? "",
        validator: (viewModel.isFiFlow) ? null : CustomValidator.requiredField,
        inputFormatters: [DecimalInputFormatter()],
        onChanged: (value) {
          viewModel.currentFacilityItems.fundedLimit = Decimal.tryParse(value);
          viewModel.calculateTotal();
        },
        onSaved: (value) {
          viewModel.currentFacilityItems.fundedLimit =
              Decimal.tryParse(value.toString());
        },
      ),
    );
  }
}
