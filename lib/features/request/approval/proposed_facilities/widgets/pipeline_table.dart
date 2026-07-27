import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/approval/proposed_facilities/model.dart";
import "package:wcas_frontend/models/request/approval/proposed_facilities.dart";

/// Displays pipeline proposed facilities in a custom raw table.
class PipelineTable extends StatelessWidget {
  /// Creates the pipeline table widget.
  const PipelineTable({
    required this.viewModel,
    super.key,
    this.pipelineRequests,
  });

  /// View model used to provide proposed facilities table context.
  final ProposedFacilitiesViewModel viewModel;

  /// List of pipeline requests displayed in the table.
  final List<ProposedFacilities>? pipelineRequests;

  @override
  Widget build(BuildContext context) {
    // Replace this with your actual table or layout logic
    return CustomRawTable(
      key: UniqueKey(),
      columnHeaderHeight: 30.w,
      columns: getPositionsColumns(),
      rows: getPositionsRows(pipelineRequests),
    );
  }

  /// Returns the column definitions for the pipeline table.
  List<TableColumn> getPositionsColumns() {
    return [
      TableColumn(
        forcedWidth: 120.w,
        label: Text("approval.proposedFacilities.applicationRefNo".tr()),
      ),
      TableColumn(
        forcedWidth: 100.w,
        label: Text("approval.proposedFacilities.caDate".tr()),
      ),
      TableColumn(
        width: 90.w,
        label: Text("approval.proposedFacilities.requestType".tr()),
      ),
      TableColumn(
        forcedWidth: 120.w,
        label: Text("approval.proposedFacilities.purpose".tr()),
      ),
      TableColumn(
        forcedWidth: 120.w,
        label: Text("approval.proposedFacilities.status".tr()),
      ),
    ];
  }

  /// Returns the row widgets for the given pipeline requests.
  List<List<Widget>> getPositionsRows(
    List<ProposedFacilities>? pipelineRequests,
  ) {
    if (pipelineRequests == null) {
      return [];
    }

    return List.generate(pipelineRequests.length, (index) {
      final pipelineRequest = pipelineRequests[index];
      return [
        Text(pipelineRequest.applicationRefNo),
        Text(
          pipelineRequest.creditAppDate.toString(),
        ),
        Text(pipelineRequest.requestType),
        CustomTooltip(
          message: pipelineRequest.purpose,
          child: Text(pipelineRequest.purpose),
        ),
        Text(pipelineRequest.status?.toString() ?? ""),
      ];
    });
  }
}
