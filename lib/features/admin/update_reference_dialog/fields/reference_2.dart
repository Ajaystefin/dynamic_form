import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/model.dart';

class Reference2 extends StatelessWidget {
  const Reference2({super.key, required this.viewModel});
  final UpdateReferenceDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final columnNames = viewModel.getColumnLabelNames();
    final reference2Label = columnNames.length > 4
        ? columnNames[4]
        : 'admin.referenceDataManagement.reference2'.tr();

    return LabelWidget(
      label: reference2Label,
      isRequired: false,
      showLabel: true,
      child: CustomTextField(
        initialValue: viewModel.reference.reference2,
        semanticLabel: reference2Label,
        onSaved: (String? value) {
          viewModel.reference.reference2 = value;
        },
      ),
    );
  }
}
