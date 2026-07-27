import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";

/// Customer name field.
class CustomerName extends StatelessWidget {
  /// Creates a customer name field.
  const CustomerName({required this.viewModel, super.key});

  /// Edit contract view model.
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.customerName".tr(),
      child: CustomTextField(
        semanticLabel: "project.viewEditContractDetails.customerName".tr(),
        controller: viewModel.customerNameController,
        readOnly: true,
        filled: true,
      ),
    );
  }
}
