import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';

class StatusField extends StatelessWidget {
  const StatusField({super.key, required this.viewModel, this.readOnly = true});
  final CovenantEditDialogViewModel viewModel;
  final bool readOnly;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        isRequired: viewModel.isRequiredBusinessSegment,
        label: "covenantsConditions.covenantEditDialog.status".tr(),
        child: CustomTextField(
          semanticLabel: "covenantsConditions.covenantEditDialog.status".tr(),
          initialValue: viewModel.selectedStatus?.name.toString() ?? '',
          filled: true,
          readOnly: readOnly,
        ));
  }
}
