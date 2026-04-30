import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

class CovenantTestLabelField extends StatelessWidget {
  const CovenantTestLabelField({required this.viewModel, super.key});
  final CovenantEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    viewModel.initializeSelectedDescriptionType();

    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label:
          "covenantsConditions.covenantEditDialog.covenantsToBeTestedOn".tr(),
    );
  }
}
