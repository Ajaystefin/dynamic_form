import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart';

class DirectLimits extends StatelessWidget {
  final AddCbrbDialogViewModel viewModel;
  const DirectLimits({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'groupInformation.facilitiesWithOtherBanks.directLimits'.tr(),
      isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
      showLabel: true,
      child: CustomTextField(
        semanticLabel:
            'groupInformation.facilitiesWithOtherBanks.directLimits'.tr(),
        initialValue:
            viewModel.currentCbrbItems.fundedLimitAllBanks?.toString() ?? '',
        validator: (viewModel.showCurrentFiCreditRisk)
            ? null
            : viewModel.currentCbrbItems.fundedLimitAllBanks == null
                ? CustomValidator.requiredField
                : null,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        // onChanged: (value) {
        //   viewModel.currentCbrbItems.fundedLimitAllBanks = int.tryParse(value);
        // },
        onSaved: (value) {
          viewModel.currentCbrbItems.fundedLimitAllBanks =
              int.tryParse(value.toString());
        },
      ),
    );
  }
}
