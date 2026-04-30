import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart";

class CbrbClassification extends StatelessWidget {
  const CbrbClassification({required this.viewModel, super.key});
  final AddCbrbDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label:
          "groupInformation.facilitiesWithOtherBanks.CBRBClassification".tr(),
      isRequired: (viewModel.isFiFlow) ? false : true,
      showLabel: true,
      child: CustomTextField(
        semanticLabel:
            "groupInformation.facilitiesWithOtherBanks.CBRBClassification".tr(),
        initialValue: viewModel.currentCbrbItems.cbrbClassifications ?? "",
        maxLength: 50,
        validator: (viewModel.isFiFlow)
            ? null
            : (viewModel.currentCbrbItems.cbrbClassifications == null ||
                    viewModel.currentCbrbItems.cbrbClassifications!.isEmpty)
                ? CustomValidator.requiredField
                : null,
        onChanged: (value) {
          viewModel.currentCbrbItems.cbrbClassifications = value;
        },
        onSaved: (value) {
          viewModel.currentCbrbItems.cbrbClassifications = value;
        },
      ),
    );
  }
}
