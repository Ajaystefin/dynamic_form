import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";

class Reference4 extends StatelessWidget {
  const Reference4({required this.viewModel, super.key});
  final UpdateReferenceDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final columnNames = viewModel.getColumnLabelNames();
    final label = columnNames.length > 6
        ? columnNames[6]
        : "admin.referenceDataManagement.reference4".tr();

    return LabelWidget(
      label: label,
      isRequired: false,
      showLabel: true,
      child: CustomTextField(
        controller: viewModel.reference4Controller,
        semanticLabel: label,
        inputFormatters: viewModel.reference4Formatters,
        onChanged: (value) {
          viewModel.reference.reference4 = value;
          viewModel.onFieldChanged();
        },
      ),
    );
  }
}
