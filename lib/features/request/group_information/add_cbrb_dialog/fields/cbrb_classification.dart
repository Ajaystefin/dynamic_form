import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart';

class CbrbClassification extends StatelessWidget {
  final AddCbrbDialogViewModel viewModel;
  const CbrbClassification({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label:
          'groupInformation.facilitiesWithOtherBanks.CBRBClassification'.tr(),
      isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
      showLabel: true,
      child: CustomTextField(
        semanticLabel:'groupInformation.facilitiesWithOtherBanks.CBRBClassification'.tr(),
        initialValue: viewModel.currentCbrbItems.cbrbClassifications ?? '',
        validator: (viewModel.showCurrentFiCreditRisk)
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
