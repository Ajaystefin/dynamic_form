import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/model.dart';

class ExpectedStartDate extends StatelessWidget {
  final EditContractViewModel viewmodel;
  const ExpectedStartDate(this.viewmodel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.expectedStartDate".tr(),
      child: CustomDatePicker(
        semanticLabel: "project.viewEditContractDetails.expectedStartDate".tr(),
        initialDateTime: viewmodel.contract.expectedStartDate,
        onSubmit2: viewmodel.onStartDateSubmitted2, // ✅ Correct method call
      ),
    );
  }
}
