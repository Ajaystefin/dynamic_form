import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

/// Covenant test credit entity section for the covenant edit dialog.
class CovenantTestCreditEntity extends StatelessWidget {
  /// Creates a covenant test credit entity section.
  const CovenantTestCreditEntity({required this.viewModel, super.key});

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "covenantsConditions.covenantEditDialog.covenantsToBeTestedOn"
              .tr(),
          labelStyle: AppStyle.tableHeaderStyle,
          child: const Row(),
        ),
      ],
    );
  }
}
