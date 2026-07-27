import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";

/// Contract scope field for the link contract screen.
class ContractScope extends StatelessWidget {
  /// Creates a contract scope field.
  const ContractScope({required this.viewModel, super.key});

  /// Link contract view model.
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
        filled: !viewModel.canEdit,
        readOnly: !viewModel.canEdit,
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
