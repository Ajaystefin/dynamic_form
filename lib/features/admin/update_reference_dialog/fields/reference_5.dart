import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/model.dart';

class Reference5 extends StatelessWidget {
  const Reference5({super.key, required this.viewModel});
  final UpdateReferenceDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final columnNames = viewModel.getColumnLabelNames();
    final reference5Label = columnNames.length > 7
        ? columnNames[7]
        : 'admin.referenceDataManagement.reference5'.tr();

    return LabelWidget(
      label: reference5Label,
      isRequired: false,
      showLabel: true,
      child: CustomTextField(
        initialValue: viewModel.reference.reference5,
        semanticLabel: reference5Label,
        onSaved: (String? value) {
          viewModel.reference.reference5 = value;
        },
      ),
    );
  }
}
