import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/text_utils.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/model.dart';
import 'package:wcas_frontend/models/request/profitability/relationship_utilization.dart';

class RelationshipUtilTable extends StatelessWidget {
  final RelationshipUtilizationViewModel viewModel;
  final int index;

  const RelationshipUtilTable({
    super.key,
    required this.viewModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final data = viewModel.relationshipUtilizationData[index];

    // Replace this with your actual table or layout logic
    return CustomRawTable(
      key: UniqueKey(),
      showPagination: true,
      rowsPerPage: viewModel.rowsPerPage,
      columnHeaderHeight: 30.w,
      // autoFitWidth: false,
      columns: getRelationshipUtilColumns(),
      rows: getRelationshipUtilRows(data.relationshipRevenueDetails),
    );
  }

  List<TableColumn> getRelationshipUtilColumns() {
    List<TableColumn> columns = [
      TableColumn(
        width: 152.w,
        label: Text(
            "profitabilityAccountConduct.relationshipUtilisation.product".tr()),
      ),
      TableColumn(
        width: 152.w,
        label: Text(
            "profitabilityAccountConduct.relationshipUtilisation.accountCommitmentNumber"
                .tr()),
      ),
      TableColumn(
        width: 152.w,
        label: Text(
            "profitabilityAccountConduct.relationshipUtilisation.accountLimit"
                .tr()),
      ),
      TableColumn(
        width: 152.w,
        label: Text(
            "profitabilityAccountConduct.relationshipUtilisation.averageUtilization"
                .tr()),
      ),
      TableColumn(
        width: 152.w,
        label: Text(
            "profitabilityAccountConduct.relationshipUtilisation.utilization"
                .tr()),
      ),
    ];
    return columns;
  }

  List<List<Widget>> getRelationshipUtilRows(
      List<RelationshipRevenueDetails>? relationshipRevenueDetails) {
    List<List<Widget>> widgets = [];

    widgets.addAll(List.generate(relationshipRevenueDetails!.length, (index) {
      return [
        Text("${relationshipRevenueDetails[index].product}"),
        Text("${relationshipRevenueDetails[index].accountCommitmentNumber}"),
        Text(relationshipRevenueDetails[index].accountLimit
                    ?.toStringAsFixed(2).formatNumber() ??
                "",style: const TextStyle(color: AppColors.primary)),
        Text(relationshipRevenueDetails[index].averageUtilization
                    ?.toStringAsFixed(2)
                    .formatNumber() ??
                "",style: const TextStyle(color: AppColors.primary)),
        Text(relationshipRevenueDetails[index].utilizationPercent
                    ?.toStringAsFixed(2) ??
                "",style: const TextStyle(color: AppColors.primary)),
      ];
    }));
    return widgets;
  }
}
