import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

class NextMonitoryDateField extends StatelessWidget {
  const NextMonitoryDateField({
    required this.viewModel,
    super.key,
    this.readOnly = true,
    this.row,
  });
  final CovenantEditDialogViewModel viewModel;
  final bool readOnly;
  final Covenant? row;

  @override
  Widget build(BuildContext context) {
    final String? rawDate = (row != null)
        ? row!.nextMonitorDate
        : viewModel.covenant?.nextMonitorDate;

    final String formattedInitialValue = viewModel.formatApiDateForUi(rawDate);

    return LabelWidget(
      label: "covenantsConditions.covenantEditDialog.nextMonitoringDate".tr(),
      isRequired: viewModel.isRequiredBusinessSegment,
      child: CustomTextField(
        initialValue: formattedInitialValue,
        controller:
            (row == null) ? viewModel.nextMonitoringDateController : null,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.nextMonitoringDate".tr(),
        key: UniqueKey(),
        filled: true,
        readOnly: true,
      ),
    );
  }
}
