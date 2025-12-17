import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown_textbox.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/model.dart';

class InitialContractValue extends StatelessWidget {
  final EditContractViewModel? viewModel;
  const InitialContractValue({this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.initialContractValue".tr(),
      child: CustomDropdownTextbox(
        options: const [],
        initialOption: "${viewModel?.contract.initialContractorValue}",
        onChanged: (Map<String, dynamic> value) {
          viewModel?.contract.initialContractorValue =
              double.tryParse(value.values.toString());
        },
      ),
    );
  }
}
