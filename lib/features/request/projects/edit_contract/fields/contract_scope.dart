import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";

/// Contract scope field.
class ContractScope extends StatelessWidget {
  /// Creates a contract scope field.
  const ContractScope(this.viewModel, {super.key});

  /// Edit contract view model.
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.contractScope".tr(),
      isRequired: true,
      child: CustomTextArea(
        controller: viewModel.contractorScopeController,
        filled: !viewModel.canEdit,
        readOnly: !viewModel.canEdit,
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
