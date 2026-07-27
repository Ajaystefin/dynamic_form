import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";

/// Displays the Reference 1 input field.
class Reference1 extends StatelessWidget {
  /// Creates a [Reference1].
  const Reference1({required this.viewModel, super.key});

  /// View model containing the reference data.
  final UpdateReferenceDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final columnNames = viewModel.getColumnLabelNames();
    final label = columnNames.length > 3
        ? columnNames[3]
        : "admin.referenceDataManagement.reference1".tr();

    return LabelWidget(
      label: label,
      isRequired: true,
      child: CustomTextField(
        hintText: viewModel.hasHolidayMasterReferenceId
            ? "admin.referenceDataManagement.yyyy".tr()
            : null,
        controller: viewModel.reference1Controller,
        semanticLabel: label,
        inputFormatters: viewModel.reference1Formatters,
        validator: CustomValidator.requiredField,
        onChanged: (value) {
          viewModel.reference.reference1 = value;
          viewModel.onFieldChanged();
        },
      ),
    );
  }
}
