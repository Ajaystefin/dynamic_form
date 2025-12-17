import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary_list.dart';

class OverallTotalTable extends StatelessWidget {
  final FacilitiesSummaryViewModel viewModel;
  final FacilitySummaryList customer;
  final int? groupIndex;
  const OverallTotalTable({
    super.key,
    required this.viewModel,
    required this.customer,
    this.groupIndex,
  });

  @override
  Widget build(BuildContext context) {
    final rim =
        (customer.rims?.isNotEmpty ?? false) ? customer.rims!.first : null;
    final groups = rim?.groups ?? const <RimGroup>[];
    String title = "";
    if (groupIndex != null && groupIndex! >= 0 && groupIndex! < groups.length) {
      title = groups[groupIndex!].groupName ?? title;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Gap(),
        CustomSectionHeader(title: "facilities.facilitySummary.overall".tr()),
        const Gap(),
        CustomRawTable(
          columns: getTableColumns(),
          rows: getTableRows(),
        )
      ],
    );
  }

  List<List<Widget>> getTableRows() {
    RimSummary? rim =
        (customer.rims?.isNotEmpty ?? false) ? customer.rims!.first : null;
    List<OverallTotalEntry> entries =
        rim?.overallTotals ?? const <OverallTotalEntry>[];
    return entries
        .map((e) => [
              Text(e.totalType ?? ""),
              Text("${e.existingLimit ?? 0}"),
              Text("${e.proposedLimit ?? 0}"),
              Text(e.differenceLabel ?? ""),
            ])
        .toList();
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
