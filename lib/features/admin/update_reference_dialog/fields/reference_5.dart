import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";

/// Displays the Reference 5 input field.
class Reference5 extends StatelessWidget {
  /// Creates a [Reference5].
  const Reference5({required this.viewModel, super.key});

  /// View model containing the reference data.
  final UpdateReferenceDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final columnNames = viewModel.getColumnLabelNames();
    final label = columnNames.length > 7
        ? columnNames[7]
        : "admin.referenceDataManagement.reference5".tr();

    return LabelWidget(
      label: label,
      child: CustomTextField(
        controller: viewModel.reference5Controller,
        semanticLabel: label,
        inputFormatters: viewModel.reference5Formatters,
        onChanged: (value) {
          viewModel.reference.reference5 = value;
          viewModel.onFieldChanged();
        },
      ),
    );
  }
}
