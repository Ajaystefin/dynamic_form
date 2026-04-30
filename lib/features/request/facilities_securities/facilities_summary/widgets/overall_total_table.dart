import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";

class OverallTotalTable extends StatelessWidget {
  const OverallTotalTable({
    required this.viewModel,
    required this.customer,
    super.key,
    this.groupIndex,
  });
  final FacilitiesSummaryViewModel viewModel;
  final FacilitySummaryList customer;
  final int? groupIndex;

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
        ),
      ],
    );
  }

  List<List<Widget>> getTableRows() {
    final thousands = NumberFormat("#,###"); // or NumberFormat.decimalPattern()

    final RimSummary? rim =
        (customer.rims?.isNotEmpty ?? false) ? customer.rims!.first : null;
    final List<OverallTotalEntry> entries =
        rim?.overallTotals ?? const <OverallTotalEntry>[];
    return entries
        .map(
          (e) => [
            Text(e.totalType ?? ""),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                thousands.format((e.existingLimit ?? 0)),
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                thousands.format((e.proposedLimit ?? 0)),
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
            Text(
              e.differenceLabel ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        )
        .toList();
  }
}

List<TableColumn> getTableColumns() {
  return [
    const TableColumn(
      label: SizedBox(),
    ),
    TableColumn(
      label: Text("facilities.facilitySummary.existingLimits".tr()),
    ),
    TableColumn(
      label: Text("facilities.facilitySummary.proposedLimits".tr()),
    ),
    TableColumn(
      label: Text("facilities.facilitySummary.change".tr()),
    ),
  ];
}
