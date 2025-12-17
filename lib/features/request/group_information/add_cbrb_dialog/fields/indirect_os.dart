import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart';

class IndirectOs extends StatelessWidget {
  final AddCbrbDialogViewModel viewModel;
  const IndirectOs({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'groupInformation.facilitiesWithOtherBanks.indirectOs'.tr(),
      isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
      showLabel: true,
      child: CustomTextField(
        semanticLabel: 'groupInformation.facilitiesWithOtherBanks.indirectOs'.tr(),
        initialValue: viewModel.currentCbrbItems.nonFundedOutstandingAllBanks
                ?.toString() ??
            '',
        validator: (viewModel.showCurrentFiCreditRisk)
            ? null
            : viewModel.currentCbrbItems.nonFundedOutstandingAllBanks == null
                ? CustomValidator.requiredField
                : null,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        // onChanged: (value) {
        //   viewModel.currentCbrbItems.nonFundedOutstandingAllBanks =
        //       int.tryParse(value);
        // },
        onSaved: (value) {
          viewModel.currentCbrbItems.nonFundedOutstandingAllBanks =
              int.tryParse(value.toString());
        },
      ),
    );
  }
}
