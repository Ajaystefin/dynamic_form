import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";

class ContractScope extends StatelessWidget {
  const ContractScope({required this.viewModel, super.key});
  final LinkContractViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.contractScope".tr(),
      isRequired: true,
      child: CustomTextArea(
        controller: viewModel.contractorScopeController,
        key: const ValueKey("ContractScope"),
        semanticLabel: "project.linkContract.contractScope".tr(),
        filled: (viewModel.canEdit) ? false : true,
        readOnly: (viewModel.canEdit) ? false : true,
        validator: (v) => CustomValidator.requiredFieldCustomMsg(
          v,
          "project.linkContract.pleaseEnterContractScope".tr(),
        ),
        maxLength: 1000,
        onChanged: (val) => viewModel.contract.contractScope = val,
      ),
    );
  }
}
