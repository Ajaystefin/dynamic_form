import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";

/// Displays the reference status dropdown field.
class ReferenceStatus extends StatelessWidget {
  /// Creates a [ReferenceStatus].
  const ReferenceStatus({required this.viewModel, super.key});

  /// View model containing the reference data.
  final UpdateReferenceDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = viewModel.isReferenceStatusDisabled;

    return LabelWidget(
      label: "admin.referenceDataManagement.status".tr(),
      isRequired: true,
      child: CustomDropdown(
        hintText: "common.selectValue".tr(),
        semanticLabel: "admin.referenceDataManagement.status".tr(),
        items: viewModel.statusList,
        isEnabled: !isDisabled,
        onSelected: (selected) {
          if (isDisabled || selected.isEmpty) {
            return;
          }

          final String value = selected.first as String;

          /// Store normalized lowercase status in the model while keeping
          /// the dropdown display value capitalized.
          viewModel.reference.status = value.toLowerCase();
          viewModel.statusListValue = [value];

          viewModel.onFieldChanged(); // triggers draft autosave
        },
        selectedItems: viewModel.statusListValue ?? [],
        validationMessage: "common.validation.requiredField".tr(),
      ),
    );
  }
}
