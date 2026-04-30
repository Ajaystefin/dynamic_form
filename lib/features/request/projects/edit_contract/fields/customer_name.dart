import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";

class CustomerName extends StatelessWidget {
  const CustomerName({required this.viewModel, super.key});
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
