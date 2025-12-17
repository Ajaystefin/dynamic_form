import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/model.dart';

class ExpectedCompletionDate extends StatelessWidget {
  final EditContractViewModel viewmodel;
  const ExpectedCompletionDate(this.viewmodel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.expectedCompletionDate".tr(),
      child: CustomDatePicker(
        semanticLabel:
            "project.viewEditContractDetails.expectedCompletionDate".tr(),
        initialDateTime: viewmodel.contract.expectedCompletionDate,
        onSubmit2:
            viewmodel.onCompletionDateSubmitted2, // ✅ Correct method call
      ),
    );
  }
}
