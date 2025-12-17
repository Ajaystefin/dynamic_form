import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart';

class IndirectLimits extends StatelessWidget {
  final AddCbrbDialogViewModel viewModel;
  const IndirectLimits({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'groupInformation.facilitiesWithOtherBanks.indirectLimits'.tr(),
      isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
      showLabel: true,
      child: CustomTextField(
        semanticLabel:  'groupInformation.facilitiesWithOtherBanks.indirectLimits'.tr(),
        initialValue:
            viewModel.currentCbrbItems.nonFundedLimitAllBanks?.toString() ?? '',
        validator: (viewModel.showCurrentFiCreditRisk)
            ? null
            : viewModel.currentCbrbItems.nonFundedLimitAllBanks == null
                ? CustomValidator.requiredField
                : null,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        // onChanged: (value) {
        //   viewModel.currentCbrbItems.nonFundedLimitAllBanks =
        //       int.tryParse(value);
        // },
        onSaved: (value) {
          viewModel.currentCbrbItems.nonFundedLimitAllBanks =
              int.tryParse(value.toString());
        },
      ),
    );
  }
}
