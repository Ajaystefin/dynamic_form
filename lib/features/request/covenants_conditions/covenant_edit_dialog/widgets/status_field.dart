import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

/// Status field for the covenant edit dialog.
class StatusField extends StatelessWidget {
  /// Creates a status field.
  const StatusField({required this.viewModel, super.key, this.readOnly = true});

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Whether the status field is read-only.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.status".tr(),
      child: CustomTextField(
        semanticLabel: "covenantsConditions.covenantEditDialog.status".tr(),
        initialValue: viewModel.covenant?.status?.toString() ??
            ServerConstants.defaultNewStatus,
        filled: true,
        readOnly: readOnly,
      ),
    );
  }
}
