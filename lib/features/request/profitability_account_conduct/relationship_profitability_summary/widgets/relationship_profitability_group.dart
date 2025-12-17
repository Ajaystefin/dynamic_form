import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/model.dart';

class RelationshipProfitabilityGroup extends StatelessWidget {
  final RelationshipProfitabilitySummaryViewModel viewModel;
  final int index;

  const RelationshipProfitabilityGroup({
    super.key,
    required this.viewModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      autoFitWidth: true,
      showPagination: true,
      rowsPerPage: viewModel.rowsPerPage,
      columns: getRelationshipProfitColumns(),
      rows: getRelationshipProfitRows(),
    );
  }

  List<TableColumn> getRelationshipProfitColumns() {
    List<TableColumn> columns = [
      TableColumn(
        width: 120.w,
        label: Text(
            "profitabilityAccountConduct.relationshipProfitabilitySummary.aedMn"
                .tr()),
      ),
      TableColumn(
        width: 120.w,
        label: Text(
            "profitabilityAccountConduct.relationshipProfitabilitySummary.nii"
                .tr()),
      ),
      TableColumn(
        width: 120.w,
        label: Text(
            "profitabilityAccountConduct.relationshipProfitabilitySummary.nfi"
                .tr()),
      ),
      TableColumn(
        width: 120.w,
        label: Text(
            "profitabilityAccountConduct.relationshipProfitabilitySummary.expectedNetIncome"
                .tr()),
      ),
      TableColumn(
        width: 120.w,
        label: Text(
            "profitabilityAccountConduct.relationshipProfitabilitySummary.avgCASA"
                .tr()),
      ),
      TableColumn(
        width: 120.w,
        label: Text(
            "profitabilityAccountConduct.relationshipProfitabilitySummary.rwa"
                .tr()),
      ),
    ];

    return columns;
  }

  List<List<Widget>> getRelationshipProfitRows() {
    final data = viewModel.sumProfitabilityData; // Get precomputed sum

    return [
      [
        Text(
            "profitabilityAccountConduct.relationshipProfitabilitySummary.projectedForNext12Month"
                .tr()),
        Text("${data?.nii}",style: const TextStyle(color: AppColors.primary)),
        Text("${data?.nfi}",style: const TextStyle(color: AppColors.primary)),
        Text("${data?.expectedNetIncome}",style: const TextStyle(color: AppColors.primary)),
        Text("${data?.avgCasa}",style: const TextStyle(color: AppColors.primary)),
        Text("${data?.rwa}",style: const TextStyle(color: AppColors.primary)),
      ],
      [
        Text(
            "profitabilityAccountConduct.relationshipProfitabilitySummary.realizedLastYer"
                .tr()),
        Text("${data?.realizedNii}",style: const TextStyle(color: AppColors.primary)),
        Text("${data?.realizedNfi}",style: const TextStyle(color: AppColors.primary)),
        Text("${data?.realizedExpectedNetIncome}",style: const TextStyle(color: AppColors.primary)),
        Text("${data?.realizedAvgCasa}",style: const TextStyle(color: AppColors.primary)),
        Text("${data?.realizedRwa}",style: const TextStyle(color: AppColors.primary)),
      ]
    ];
  }
}
