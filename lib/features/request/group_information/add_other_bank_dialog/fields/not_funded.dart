import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart';

class NotFunded extends StatelessWidget {
  final AddOtherBankDialogViewModel viewModel;
  const NotFunded({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'groupInformation.facilitiesWithOtherBanks.nonFunded'.tr(),
      isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
      showLabel: true,
      child: CustomTextField(
        semanticLabel: 'groupInformation.facilitiesWithOtherBanks.nonFunded'.tr(),
        initialValue:
            viewModel.currentFacilityItems.nonFundedLimit?.toString() ?? '',
        validator: (viewModel.showCurrentFiCreditRisk)
            ? null
            : (viewModel.currentFacilityItems.nonFundedLimit?.toString() == '')
                ? CustomValidator.requiredField
                : null,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          viewModel.currentFacilityItems.nonFundedLimit = int.tryParse(value);
          viewModel.calculateTotal();
        },
        onSaved: (value) {
          viewModel.currentFacilityItems.nonFundedLimit =
              int.tryParse(value.toString());
        },
      ),
    );
  }
}
