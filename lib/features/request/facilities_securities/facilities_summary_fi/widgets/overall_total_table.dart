import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/model.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';

class OverallTotalFiTable extends StatelessWidget {
  final FacilitiesSummaryFiViewModel viewModel;
  final OverallTotal? overallTotal;
  const OverallTotalFiTable(
      {super.key, required this.viewModel, required this.overallTotal});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: CustomSectionHeader(
              title: "facilities.facilitySummary.overall".tr()),
        ),
        CustomRawTable(
          columns: getTableColumns(),
          rows: getTableRows(),
        )
      ],
    );
  }

  List<List<Widget>> getTableRows() {
    List<List<Widget>> rows = [];

    for (int index = 0; index < (overallTotal?.limits ?? []).length; index++) {
      rows.add([
        Text(overallTotal?.limits?[index].description ?? ""),
        Text("${overallTotal?.limits?[index].existingLimit ?? 0}"),
        Text("${overallTotal?.limits?[index].proposedLimit ?? 0}"),
        Text(overallTotal?.limits?[index].remark ?? ""),
      ]);
    }
    return rows;
  }
}

List<TableColumn> getTableColumns() {
  return [
    const TableColumn(
      label: SizedBox(),
    ),
    TableColumn(
      label: Text('facilities.facilitySummary.existingLimits'.tr()),
    ),
    TableColumn(
      label: Text('facilities.facilitySummary.proposedLimits'.tr()),
    ),
    const TableColumn(
      label: SizedBox(),
    ),
  ];
}
