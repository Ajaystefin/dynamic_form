import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/model.dart';

class PaymasterName extends StatelessWidget {
  final LinkContractViewModel viewModel;
  const PaymasterName({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'project.linkContract.paymasterName'.tr(),
      isRequired: true,
      child: CustomTextField(
        semanticLabel: 'project.linkContract.paymasterName'.tr(),
        controller: viewModel.paymasterNameController,
        validator: (v) => CustomValidator.requiredFieldCustomMsg(
            v, 'project.linkContract.pleaseEnterPaymasterName'.tr()),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(100),
        ],
        onChanged: (val) => viewModel.contract.paymasterName = val,
      ),
    );
  }
}
