import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/model.dart";
import "package:wcas_frontend/models/request/profitability/relationship_utilization.dart";

class RelationshipUtilTable extends StatelessWidget {
  const RelationshipUtilTable({
    required this.viewModel,
    required this.index,
    super.key,
  });
  final RelationshipUtilizationViewModel viewModel;
  final int index;

  @override
  Widget build(BuildContext context) {
    final RelationshipUtilization data =
        viewModel.relationshipUtilizationData[index];
    final List<RelationshipRevenueDetails>? details =
        data.relationshipRevenueDetails;

    // Build rows safely (empty if null/empty)
    final rows = getRelationshipUtilRows(details);

    return CustomRawTable(
      key: UniqueKey(),
      showPagination: rows.isNotEmpty, // ⬅ turn off pagination when no rows
      rowsPerPage: viewModel.rowsPerPage,
      columnHeaderHeight: 30.w,
      columns: getRelationshipUtilColumns(),
      rows: rows,
      // Optionally, if your CustomRawTable supports an empty state:
      // emptyPlaceholder: const Text('No data available'),
    );
  }

  List<TableColumn> getRelationshipUtilColumns() {
    return [
      TableColumn(
        width: 152.w,
        label: Text(
          "profitabilityAccountConduct.relationshipUtilisation.product".tr(),
        ),
      ),
      TableColumn(
        width: 152.w,
        label: Text(
          "profitabilityAccountConduct."
                  "relationshipUtilisation.accountCommitmentNumber"
              .tr(),
        ),
      ),
      TableColumn(
        width: 152.w,
        label: Text(
          "profitabilityAccountConduct.relationshipUtilisation.accountLimit"
              .tr(),
        ),
      ),
      TableColumn(
        width: 152.w,
        label: Text(
          "profitabilityAccountConduct."
                  "relationshipUtilisation.averageUtilization"
              .tr(),
        ),
      ),
      TableColumn(
        width: 152.w,
        label: Text(
          "profitabilityAccountConduct.relationshipUtilisation.utilization"
              .tr(),
        ),
      ),
    ];
  }

  List<List<Widget>> getRelationshipUtilRows(
    List<RelationshipRevenueDetails>? relationshipRevenueDetails,
  ) {
    if (relationshipRevenueDetails == null ||
        relationshipRevenueDetails.isEmpty) {
      return const <List<Widget>>[];
    }

    return List.generate(relationshipRevenueDetails.length, (i) {
      final RelationshipRevenueDetails item = relationshipRevenueDetails[i];

      // Use safe formatting for nullable doubles
      final String accountLimit =
          item.accountLimit != null ? item.accountLimit ?? "" : "";

      final String avgUtil =
          item.averageUtilization != null ? item.averageUtilization ?? "" : "";

      final String utilPct =
          item.utilizationPercent != null ? item.utilizationPercent ?? "" : "";

      return [
        Text(item.product ?? ""), // product can be null -> empty string
        Text(item.accountCommitmentNumber ?? ""),
        Text(accountLimit, style: const TextStyle(color: AppColors.primary)),
        Text(avgUtil, style: const TextStyle(color: AppColors.primary)),
        Text(utilPct, style: const TextStyle(color: AppColors.primary)),
      ];
    });
  }
}
