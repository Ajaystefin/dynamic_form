import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/model.dart';

class OriginalCompletionDate extends StatelessWidget {
  final EditContractViewModel viewModel;
  const OriginalCompletionDate(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.originalCompletionDate".tr(),
      child: CustomDatePicker(
          semanticLabel:
              "project.viewEditContractDetails.originalCompletionDate".tr(),
          initialDateTime: viewModel.contract.expectedStartDate,
          onSubmit2: (DateTime? date) {
            viewModel.contract.expectedStartDate = date;
          }),
    );
  }
}
