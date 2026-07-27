import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";

/// Displays the Reference 2 input field.
class Reference2 extends StatelessWidget {
  /// Creates a [Reference2].
  const Reference2({required this.viewModel, super.key});

  /// View model containing the reference data.
  final UpdateReferenceDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final columnNames = viewModel.getColumnLabelNames();
    final label = columnNames.length > 4
        ? columnNames[4]
        : "admin.referenceDataManagement.reference2".tr();

    return LabelWidget(
      label: label,
      child: CustomTextField(
        hintText: viewModel.hasHolidayMasterReferenceId
            ? "admin.referenceDataManagement.dd/mm/yyyy".tr()
            : null,
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
