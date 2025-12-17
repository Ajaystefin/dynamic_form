import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/model.dart';

class ExpectedEndDate extends StatelessWidget {
  final LinkContractViewModel viewModel;
  const ExpectedEndDate({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.expectedCompletionDate".tr(),
      isRequired: true,
      child: CustomDatePicker(
        semanticLabel: "project.linkContract.expectedCompletionDate".tr(),
        initialDateTime:
            DateTime.tryParse(viewModel.completionDateController.text),
        onSubmit2: viewModel.onCompletionDateSubmitted2,
        validator: (v) => CustomValidator.requiredFieldCustomMsg(
            v, "project.linkContract.pleaseSelectExpectedEndDate".tr()),
      ),
    );
  }
}
