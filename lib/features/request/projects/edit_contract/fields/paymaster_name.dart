import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";

/// Paymaster name field.
class PaymasterName extends StatelessWidget {
  /// Creates a paymaster name field.
  const PaymasterName({required this.viewModel, super.key});

  /// Edit contract view model.
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.paymasterName".tr(),
      child: CustomTextField(
        semanticLabel: "project.viewEditContractDetails.paymasterName".tr(),
        initialValue: viewModel.contract.paymasterName,
        readOnly: true,
        filled: true,
      ),
    );
  }
}
