import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";

class DataId extends StatelessWidget {
  const DataId({required this.viewModel, super.key});
  final UpdateReferenceDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "admin.referenceDataManagement.referenceDataId".tr(),
      isRequired: false,
      showLabel: true,
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
