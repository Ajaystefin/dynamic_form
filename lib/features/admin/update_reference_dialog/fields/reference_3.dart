import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";

/// Displays the Reference 3 input field.
class Reference3 extends StatelessWidget {
  /// Creates a [Reference3].
  const Reference3({required this.viewModel, super.key});

  /// View model containing the reference data.
  final UpdateReferenceDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final columnNames = viewModel.getColumnLabelNames();
    final label = columnNames.length > 5
        ? columnNames[5]
        : "admin.referenceDataManagement.reference3".tr();

    return LabelWidget(
      label: label,
      child: CustomTextField(
        controller: viewModel.reference3Controller,
        semanticLabel: label,
        inputFormatters: viewModel.reference3Formatters,
        onChanged: (value) {
          viewModel.reference.reference3 = value;
          viewModel.onFieldChanged();
        },
      ),
    );
  }
}
