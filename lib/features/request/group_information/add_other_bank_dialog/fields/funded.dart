import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart';

class Funded extends StatelessWidget {
  final AddOtherBankDialogViewModel viewModel;
  const Funded({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'groupInformation.facilitiesWithOtherBanks.funded'.tr(),
      isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
      showLabel: true,
      child: CustomTextField(
        semanticLabel:  'groupInformation.facilitiesWithOtherBanks.funded'.tr(),
        initialValue:
            viewModel.currentFacilityItems.fundedLimit?.toString() ?? '',
        validator: (viewModel.showCurrentFiCreditRisk)
            ? null
            : (viewModel.currentFacilityItems.fundedLimit?.toString() == '')
                ? CustomValidator.requiredField
                : null,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          viewModel.currentFacilityItems.fundedLimit = int.tryParse(value);
          viewModel.calculateTotal();
        },
        onSaved: (value) {
          viewModel.currentFacilityItems.fundedLimit =
              int.tryParse(value.toString());
        },
      ),
    );
  }
}
