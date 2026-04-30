import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";

class Reference2 extends StatelessWidget {
  const Reference2({required this.viewModel, super.key});
  final UpdateReferenceDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final columnNames = viewModel.getColumnLabelNames();
    final label = columnNames.length > 4
        ? columnNames[4]
        : "admin.referenceDataManagement.reference2".tr();

    return LabelWidget(
      label: label,
      isRequired: false,
      showLabel: true,
      child: CustomTextField(
        controller: viewModel.reference2Controller,
        semanticLabel: label,
        inputFormatters: viewModel.reference2Formatters,
        onChanged: (value) {
          viewModel.reference.reference2 = value;
          viewModel.onFieldChanged();
        },
      ),
    );
  }
}
