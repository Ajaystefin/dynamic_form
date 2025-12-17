import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/model.dart';

class Name extends StatelessWidget {
  const Name({super.key, required this.viewModel});
  final UpdateReferenceDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'admin.referenceDataManagement.referenceDataName'.tr(),
      isRequired: true,
      showLabel: true,
      child: CustomTextField(
        initialValue: viewModel.reference.name,
        semanticLabel: 'admin.referenceDataManagement.referenceDataName'.tr(),
        validator: !(viewModel.reference.name?.isNotEmpty ?? false)
            ? CustomValidator.requiredField
            : null,
        onSaved: (String? value) {
          viewModel.reference.name = value;
        },
      ),
    );
  }
}
