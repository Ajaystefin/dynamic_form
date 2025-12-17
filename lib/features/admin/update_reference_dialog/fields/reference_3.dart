import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/model.dart';

class Reference3 extends StatelessWidget {
  const Reference3({super.key, required this.viewModel});
  final UpdateReferenceDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final columnNames = viewModel.getColumnLabelNames();
    final reference3Label = columnNames.length > 5
        ? columnNames[5]
        : 'admin.referenceDataManagement.reference3'.tr();

    return LabelWidget(
      label: reference3Label,
      isRequired: false,
      showLabel: true,
      child: CustomTextField(
        initialValue: viewModel.reference.reference3,
        semanticLabel: reference3Label,
        onSaved: (String? value) {
          viewModel.reference.reference3 = value;
        },
      ),
    );
  }
}
