import "package:decimal/decimal.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart";

/// Funded limit field widget.
class Funded extends StatelessWidget {
  /// Creates a [Funded] widget.
  const Funded({required this.viewModel, super.key});

  /// View model used by the widget.
  final AddOtherBankDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.funded".tr(),
      label2: "groupInformation.facilitiesWithOtherBanks.inAed".tr(),
      isRequired: !viewModel.isFiFlow,
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
