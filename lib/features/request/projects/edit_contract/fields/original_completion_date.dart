import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";

class OriginalCompletionDate extends StatelessWidget {
  const OriginalCompletionDate(this.viewModel, {super.key});
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.originalCompletionDate".tr(),
      child: CustomDatePicker(
        isEnabled: false,
        semanticLabel:
            "project.viewEditContractDetails.originalCompletionDate".tr(),
        initialDateTime: viewModel.contract.originalCompletionDate,
        onSubmit2: viewModel.onOriginalCompletionDateSubmitted2,
        // onSubmit2: (DateTime? date) {
        //   viewModel.contract.originalEndDate = date;
        //   viewModel.updateCompletionVariation();
        // }
      ),
    );
  }
}
