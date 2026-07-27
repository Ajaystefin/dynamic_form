import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";

/// Displays the Reference 4 input field.
class Reference4 extends StatelessWidget {
  /// Creates a [Reference4].
  const Reference4({required this.viewModel, super.key});

  /// View model containing the reference data.
  final UpdateReferenceDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final columnNames = viewModel.getColumnLabelNames();
    final label = columnNames.length > 6
        ? columnNames[6]
        : "admin.referenceDataManagement.reference4".tr();

    return LabelWidget(
      label: label,
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
