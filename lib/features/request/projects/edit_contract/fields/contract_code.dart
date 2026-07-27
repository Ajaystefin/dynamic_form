import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";

/// Contract code field.
class ContractCode extends StatelessWidget {
  /// Creates a contract code field.
  const ContractCode({required this.viewModel, super.key});

  /// Edit contract view model.
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.contractCode".tr(),
      child: CustomTextField(
        semanticLabel: "project.viewEditContractDetails.contractCode".tr(),
        initialValue: viewModel.contract.contractCode,
        readOnly: true,
        filled: true,
      ),
    );
  }
}
