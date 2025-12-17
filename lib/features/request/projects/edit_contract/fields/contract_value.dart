import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown_textbox.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/model.dart';

class ContractValue extends StatelessWidget {
  final EditContractViewModel? viewModel;
  const ContractValue(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.contractValue".tr(),
      child: CustomDropdownTextbox(
        options: const [],
        initialOption: "${viewModel?.contract.contractorValue}",
        onChanged: (Map<String, dynamic> value) {
          viewModel?.contract.contractorValue =
              double.tryParse(value.values.toString());
        },
        validator: CustomValidator.requiredField,
      ),
    );
  }
}
