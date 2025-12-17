import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/model.dart';

class Reference1 extends StatelessWidget {
  const Reference1({super.key, required this.viewModel});
  final UpdateReferenceDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final columnNames = viewModel.getColumnLabelNames();
    final reference1Label = columnNames.length > 3
        ? columnNames[3]
        : 'admin.referenceDataManagement.reference1'.tr();

    return LabelWidget(
      label: reference1Label,
      isRequired: true,
      showLabel: true,
      child: CustomTextField(
        semanticLabel: reference1Label,
        initialValue: viewModel.reference.reference1 ?? "",
        validator: CustomValidator.requiredField,
        onSaved: (String? value) {
          viewModel.reference.reference1 = value;
        },
      ),
    );
  }
}
