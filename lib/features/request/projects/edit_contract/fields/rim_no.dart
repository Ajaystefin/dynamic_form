import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";

class RimNo extends StatelessWidget {
  const RimNo({required this.viewModel, super.key});
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.rimNo".tr(),
      child: CustomTextField(
        semanticLabel: "project.viewEditContractDetails.rimNo".tr(),
        initialValue: viewModel.contract.rimNo,
        readOnly: true,
        filled: true,
      ),
    );
  }
}
