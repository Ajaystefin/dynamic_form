import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";

class Name extends StatelessWidget {
  const Name({required this.viewModel, super.key});
  final UpdateReferenceDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "admin.referenceDataManagement.referenceDataName".tr(),
      isRequired: true,
      showLabel: true,
      child: CustomTextField(
        controller: viewModel.nameController,
        onChanged: (value) {
          viewModel.reference.name = value;
          viewModel.onFieldChanged();
        },
        semanticLabel: "admin.referenceDataManagement.referenceDataName".tr(),
        // maxLength: 50,
        inputFormatters: viewModel.nameFormatters,
        validator: !(viewModel.reference.name?.isNotEmpty ?? false)
            ? CustomValidator.requiredField
            : null,
        // onSaved: (String? value) {
        //   viewModel.reference.name = value;
        // },
      ),
    );
  }
}
