import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';

class NextMonitoryDateField extends StatelessWidget {
  const NextMonitoryDateField(
      {super.key, required this.viewModel, this.readOnly = true});
  final CovenantEditDialogViewModel viewModel;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final formattedInitialValue =
        viewModel.nextMonitorDate(viewModel.covenant?.nextMonitorDate);

    return LabelWidget(
      label: 'covenantsConditions.covenantEditDialog.nextMonitoringDate'.tr(),
      isRequired: viewModel.isRequiredBusinessSegment,
      child: CustomTextField(
        initialValue: formattedInitialValue,
        controller: viewModel.nextMonitoringDateController,
        semanticLabel:
            'covenantsConditions.covenantEditDialog.nextMonitoringDate'.tr(),
        key: UniqueKey(),
        filled: true,
        readOnly: true,
      ),
    );
  }
}
