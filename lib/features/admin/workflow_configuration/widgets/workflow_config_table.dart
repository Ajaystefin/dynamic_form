import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/view.dart";
import "package:wcas_frontend/features/admin/workflow_configuration/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Table widget that displays workflow configuration records.
class WorkflowConfigTable extends StatelessWidget {
  /// Creates a [WorkflowConfigTable].
  const WorkflowConfigTable({required this.viewModel, super.key});

  /// View model used to load, display, and refresh workflow configurations.
  final WorkflowConfigViewModel viewModel;

  /// Builds the workflow configuration table.
  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      rowsPerPage: 10,
      columnHeaderHeight: 30.w,
      key: ValueKey(viewModel.workflowConfigs.length),
      columns: _buildColumns(),
      rows: _buildRows(viewModel.workflowConfigs, context),
    );
  }

  List<TableColumn> _buildColumns() {
    return viewModel.getColumnNames().asMap().entries.map((entry) {
      return TableColumn(
        forcedWidth: entry.key == 0 ? 50 : 150,
        label: Text(entry.value),
      );
    }).toList();
  }

  List<List<Widget>> _buildRows(
    List<Reference> configs,
    BuildContext context,
  ) {
    return configs.asMap().entries.map((entry) {
      final Reference config = entry.value;

      // ── Column mapping from CUSTOM_APPLICATION_TYPE ───────────────────────
      // reference1 = subtype code   e.g. "RR"  → resolved to name via viewModel
      // reference2 = segment short  e.g. "C,F" → shown as-is
      // reference3 = request type   e.g. "MEMO","FULL" → shown as-is
      // name       = new application type name  e.g. "dfgasfd"
      // reference1 shown in "Existing Application" column (the subtype code)
      // name shown in "New Application Type" column

      final String existingAppType =
          viewModel.resolveAppTypeName(config.reference1 ?? "");
      final String workflowType = viewModel.resolveWorkflowTypeName(config);
      final String customerSegment =
          viewModel.formatCustomerSegment(config.reference2);

      return [
        // ID — clickable, opens edit dialog
        TextButton(
          onPressed: () async {
            // viewModel.onEditConfig(config);
            await DialogHelper.showCustomDialog(
              barrierDismissible: false,
              title: "admin.workflowConfig.dialog.editTitle".tr(),
              content: UpdateWorkflowConfigurationView(config: config),
              context: context,
            );
            await viewModel.refreshTable();
          },
          child: Text(
            "${config.id}",
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: AppStyle.fontSizeSmall,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.darkBlue,
              color: AppColors.darkBlue,
            ),
          ),
        ),

        // Application Type (subtype code) — e.g. "RR", "NW"
        Text(workflowType, textAlign: TextAlign.start),

        // Customer Segment — e.g. C,F → Corporate, FI
        Text(customerSegment, textAlign: TextAlign.start),

        // Request Type — e.g. "MEMO", "FULL"
        Text(config.reference3 ?? "", textAlign: TextAlign.start),

        // Existing Application Type — resolved display name e.g. "Risk Rating / Staging"
        Text(existingAppType, textAlign: TextAlign.start),

        // New Application Type Name — user entered name
        Text(config.name ?? "", textAlign: TextAlign.start),

        // Status
        Text(
          (config.isActive ?? false ? "Active" : "Inactive"),
          textAlign: TextAlign.start,
        ),
      ];
    }).toList();
  }
}
