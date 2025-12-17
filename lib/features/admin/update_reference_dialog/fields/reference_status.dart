import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/model.dart';

class ReferenceStatus extends StatelessWidget {
  const ReferenceStatus({super.key, required this.viewModel});
  final UpdateReferenceDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'admin.referenceDataManagement.status'.tr(),
      isRequired: true,
      showLabel: true,
      child: CustomDropdown(
        hintText: "common.selectValue".tr(),
        semanticLabel: 'admin.referenceDataManagement.status'.tr(),
        items: viewModel.statusList,
        onSelected: (selected) {
          final selectedStatus = selected.first.toString();
          viewModel.reference.status = selectedStatus;
          viewModel.statusListValue = [selectedStatus];
        },
        selectedItems: viewModel.statusListValue ?? [],
        validationMessage: "common.validation.requiredField".tr(),
      ),
    );
  }
}
