import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";

class ExpectedStartDate extends StatelessWidget {
  const ExpectedStartDate(this.viewmodel, {super.key});
  final EditContractViewModel viewmodel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label: "project.viewEditContractDetails.expectedStartDate".tr(),
      child: CustomDatePicker(
        controller: viewmodel.startDateController,
        isEnabled: (viewmodel.canEdit) ? true : false,
        semanticLabel: "project.viewEditContractDetails.expectedStartDate".tr(),
        initialDateTime: viewmodel.contract.expectedStartDate,
        onSubmit2: viewmodel.onStartDateSubmitted2,
        validator: CustomValidator.date,
      ),
    );
  }
}
