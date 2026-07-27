import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

/// Covenant test label field for the covenant edit dialog.
class CovenantTestLabelField extends StatelessWidget {
  /// Creates a covenant test label field.
  const CovenantTestLabelField({required this.viewModel, super.key});

  /// Covenant edit dialog view model.
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
