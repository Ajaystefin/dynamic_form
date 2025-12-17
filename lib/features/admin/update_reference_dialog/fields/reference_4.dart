import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/model.dart';

class Reference4 extends StatelessWidget {
  const Reference4({super.key, required this.viewModel});
  final UpdateReferenceDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final columnNames = viewModel.getColumnLabelNames();
    final reference4Label = columnNames.length > 6
        ? columnNames[6]
        : 'admin.referenceDataManagement.reference4'.tr();

    return LabelWidget(
      label: reference4Label,
      isRequired: false,
      showLabel: true,
      child: CustomTextField(
        initialValue: viewModel.reference.reference4,
        semanticLabel: reference4Label,
        onSaved: (String? value) {
          viewModel.reference.reference4 = value;
        },
      ),
    );
  }
}
