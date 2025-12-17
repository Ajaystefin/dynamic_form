import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/approval/proposed_facilities/model.dart';
import 'package:wcas_frontend/models/request/approval/proposed_facilities.dart';

class PipelineTable extends StatelessWidget {
  final ProposedFacilitiesViewModel viewModel;
  final List<ProposedFacilities>? pipelineRequests;

  const PipelineTable(
      {super.key, required this.viewModel, this.pipelineRequests});

  @override
  Widget build(BuildContext context) {
    // Replace this with your actual table or layout logic
    return CustomRawTable(
      key: UniqueKey(),
      showPagination: true,
      autoFitWidth: true,
      columnHeaderHeight: 30.w,
      columns: getPositionsColumns(),
      rows: getPositionsRows(pipelineRequests),
    );
  }

  List<TableColumn> getPositionsColumns() {
    return [
      TableColumn(
          forcedWidth: 120.w,
          label: Text("approval.proposedFacilities.applicationRefNo".tr())),
      TableColumn(
          forcedWidth: 100.w,
          label: Text("approval.proposedFacilities.caDate".tr())),
      TableColumn(
        width: 90.w,
        label: Text("approval.proposedFacilities.requestType".tr()),
      ),
      TableColumn(
          forcedWidth: 120.w,
          label: Text("approval.proposedFacilities.purpose".tr())),
      TableColumn(
          forcedWidth: 120.w,
          label: Text("approval.proposedFacilities.status".tr())),
    ];
  }

  List<List<Widget>> getPositionsRows(
      List<ProposedFacilities>? pipelineRequests) {
    if (pipelineRequests == null) return [];

    return List.generate(pipelineRequests.length, (index) {
      final pipelineRequest = pipelineRequests[index];
      return [
        Text(pipelineRequest.applicationRefNo.toString()),
        Text(
          pipelineRequest.creditAppDate.toString(),
        ),
        Text(pipelineRequest.requestType.toString()),
        CustomTooltip(
            message: pipelineRequest.purpose.toString(),
            child: Text(pipelineRequest.purpose.toString())),
        Text(pipelineRequest.status?.toString() ?? ""),
      ];
    });
  }
}
