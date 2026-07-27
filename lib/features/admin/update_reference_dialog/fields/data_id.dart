import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";

/// Displays the reference data ID field.
class DataId extends StatelessWidget {
  /// Creates a [DataId].
  const DataId({required this.viewModel, super.key});

  /// View model containing the reference data.
  final UpdateReferenceDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "admin.referenceDataManagement.referenceDataId".tr(),
      child: CustomTextField(
        semanticLabel: "admin.referenceDataManagement.referenceDataId".tr(),
        initialValue: viewModel.reference.id != null
            ? viewModel.reference.id.toString()
            : "",
        readOnly: true,
        filled: true,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onSaved: (String? value) {
          viewModel.reference.id = int.tryParse(value.toString());
        },
      ),
    );
  }
}
