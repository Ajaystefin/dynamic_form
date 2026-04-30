import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";

class ExpectedCompletionDate extends StatelessWidget {
  const ExpectedCompletionDate(this.viewmodel, {super.key});
  final EditContractViewModel viewmodel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label: "project.viewEditContractDetails.expectedCompletionDate".tr(),
      child: CustomDatePicker(
        controller: viewmodel.completionDateController,
        isEnabled: (viewmodel.canEdit) ? true : false,
        semanticLabel:
            "project.viewEditContractDetails.expectedCompletionDate".tr(),
        initialDateTime: viewmodel.contract.expectedEndDate,
        onSubmit2: viewmodel.onCompletionDateSubmitted2,
        validator: CustomValidator.date,
      ),
    );
  }
}
