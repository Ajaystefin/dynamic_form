import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";

class ContractScope extends StatelessWidget {
  const ContractScope(this.viewModel, {super.key});
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.contractScope".tr(),
      isRequired: true,
      child: CustomTextArea(
        controller: viewModel.contractorScopeController,
        filled: (viewModel.canEdit) ? false : true,
        readOnly: (viewModel.canEdit) ? false : true,
        semanticLabel: "project.viewEditContractDetails.contractScope".tr(),
        initialValue: viewModel.contract.contractScope,
        maxLength: 1000,
        onSubmitted: (String value) {
          viewModel.contract.contractorScope = value;
        },
        validator: CustomValidator.requiredField,
        onSaved: (value) {
          viewModel.contract.contractorScope = value;
        },
        onChanged: (val) => viewModel.contract.contractScope = val,
      ),
    );
  }
}
