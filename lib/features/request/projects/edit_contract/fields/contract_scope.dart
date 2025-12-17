import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/model.dart';

class ContractScope extends StatelessWidget {
  final EditContractViewModel viewModel;
  const ContractScope(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.contractScope".tr(),
      isRequired: true,
      child: CustomTextArea(
        semanticLabel: "project.viewEditContractDetails.contractScope".tr(),
        maxLines: 4,
        minLines: 4,
        onSubmitted: (String value) {
          viewModel.contract.contractorScope = value;
        },
        validator: CustomValidator.requiredField,
      ),
    );
  }
}
