import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart';

class Total extends StatelessWidget {
  final AddOtherBankDialogViewModel viewModel;
  const Total({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'groupInformation.facilitiesWithOtherBanks.total'.tr(),
      isRequired: false,
      showLabel: true,
      child: CustomTextField(
        semanticLabel:  'groupInformation.facilitiesWithOtherBanks.total'.tr(),
       // initialValue: viewModel.currentFacilityItems.total?.toString() ?? '',
        hintText: viewModel.currentFacilityItems.total?.toString() ?? '',
        readOnly: true,
        filled: true,
        onChanged: (value) {
          viewModel.currentFacilityItems.total = int.tryParse(value);
        },
        onSaved: (value) {
          viewModel.currentFacilityItems.total = int.tryParse(value.toString());
        },
      ),
    );
  }
}
