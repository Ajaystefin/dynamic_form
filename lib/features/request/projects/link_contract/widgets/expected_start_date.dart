import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/model.dart';

class ExpectedStartDate extends StatelessWidget {
  final LinkContractViewModel viewModel;
  const ExpectedStartDate({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.expextedStartDate".tr(),
      isRequired: true,
      child: CustomDatePicker(
        semanticLabel: "project.linkContract.expextedStartDate".tr(),
        initialDateTime: DateTime.tryParse(viewModel.startDateController.text),
        validator: (v) => CustomValidator.requiredFieldCustomMsg(
            v, "project.linkContract.pleaseSelectExpectedStartDate".tr()),
        onSubmit2: viewModel.onStartDateSubmitted2,
      ),
    );
  }
}
