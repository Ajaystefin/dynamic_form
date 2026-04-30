import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/model.dart";

class CustomerSegmentField extends StatelessWidget {
  const CustomerSegmentField({required this.viewModel, super.key});
  final UpdateWorkflowConfigViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // FIX: uses plain list field, not getter
    final List<String> segments = viewModel.availableSegments;
    if (segments.isEmpty) return const SizedBox.shrink();

    return LabelWidget(
      isRequired: true,
      label: "admin.workflowConfig.dialog.customerSegment".tr(),
      child: CustomRadioButton<String?>(
        isRequired: true,
        scrollDirection: Axis.horizontal,
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return "admin.workflowConfig.validation.customerSegmentRequired"
                .tr();
          }
          return null;
        },
        onChanged: (String? value) {
          viewModel.onCustomerSegmentSelected(value);
        },
        options: segments,
        selectedValue: viewModel.selectedCustomerSegment,
      ),
    );
  }
}
