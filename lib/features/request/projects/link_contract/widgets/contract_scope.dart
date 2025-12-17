import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/model.dart';

class ContractScope extends StatelessWidget {
  final LinkContractViewModel viewModel;
  const ContractScope({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.contractScope".tr(),
      isRequired: true,
      child: CustomTextArea(
        semanticLabel: "project.linkContract.contractScope".tr(),
        validator: (v) => CustomValidator.requiredFieldCustomMsg(
            v, "project.linkContract.pleaseEnterContractScope".tr()),
        maxLength: 1000,
        onChanged: (val) => viewModel.contract.contractorScope = val,
      ),
    );
  }
}
