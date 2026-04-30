import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";

class ReferenceStatus extends StatelessWidget {
  const ReferenceStatus({required this.viewModel, super.key});
  final UpdateReferenceDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "admin.referenceDataManagement.status".tr(),
      isRequired: true,
      showLabel: true,
      child: CustomDropdown(
        hintText: "common.selectValue".tr(),
        semanticLabel: "admin.referenceDataManagement.status".tr(),
        items: viewModel.statusList,
        onSelected: (selected) {
          final value = selected.first;

          viewModel.reference.status = value as String?; // API format

          viewModel.statusListValue = ["$value"];

          viewModel.onFieldChanged(); // triggers draft autosave
        },
        selectedItems: viewModel.statusListValue ?? [],
        validationMessage: "common.validation.requiredField".tr(),
      ),
    );
  }
}
