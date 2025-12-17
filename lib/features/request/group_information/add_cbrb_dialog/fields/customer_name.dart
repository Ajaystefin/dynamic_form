import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart';
import 'package:wcas_frontend/features/request/group_information/add_cbrb_dialog/state.dart';

class CustomerName extends StatelessWidget {
  final AddCbrbDialogViewModel viewModel;
  final AddCbrbDialogState state;
  const CustomerName({super.key, required this.viewModel, required this.state});

  @override
  Widget build(BuildContext context) {
    final customerName =
        (state.customerName == null || state.customerName == 'null')
            ? ''
            : state.customerName ?? '';
    return LabelWidget(
        label: 'groupInformation.facilitiesWithOtherBanks.customerName'.tr(),
        isRequired: false,
        showLabel: true,
        child: CustomTextField(
          semanticLabel:
              'groupInformation.facilitiesWithOtherBanks.customerName'.tr(),
          filled: true,
          readOnly: true,
          initialValue: customerName,
          hintText: customerName,
          fillColor: AppColors.textFieldDisabledFill,
          onChanged: (value) {
            viewModel.selectedCustomer?.customerName = value;
          },
        ));
  }
}
