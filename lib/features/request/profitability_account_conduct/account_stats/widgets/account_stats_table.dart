import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/text_utils.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/account_stats/model.dart';
import 'package:wcas_frontend/models/request/profitability/account_stat.dart';

class AccountStatsTable extends StatefulWidget {
  final AccountStatsViewModel viewModel;
  final List<AccountStat> accountStat;
  const AccountStatsTable(
      {super.key, required this.viewModel, required this.accountStat});

  @override
  State<AccountStatsTable> createState() => _AccountStatsTableState();
}

class _AccountStatsTableState extends State<AccountStatsTable> {
  List<bool> checkboxes = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: CustomSelectableText(
            text: "profitabilityAccountConduct.accountStats.aedValue".tr(),
            textAlign: TextAlign.right,
            style: AppStyle.tableSuffixHeaderStyle,
          ),
        ),
        CustomRawTable(
          key: UniqueKey(),
          // autoFitWidth: false,
          stackedHeaders: [
            StackedHeader(
                width: 280.w,
                startIndex: 2,
                endIndex: 5,
                widget: Text(
                    "profitabilityAccountConduct.accountStats.previousYear"
                        .tr())),
            StackedHeader(
                width: 280.w,
                startIndex: 6,
                endIndex: 9,
                widget: Text(
                    "profitabilityAccountConduct.accountStats.currentYear"
                        .tr()))
          ],
          columns: getTableColumns(),
          rows: List.generate(widget.accountStat.length, (index) {
            return [
              CustomSelectableText(
                text: widget.accountStat[index].product.toString(),
              ),
              CustomSelectableText(
                text: widget.accountStat[index].accountCommitmentNumber
                    .toString(),
                maxLines: 1,
                style: const TextStyle(
                    color: AppColors.business, overflow: TextOverflow.clip),
              ),
              CustomSelectableText(
                text: widget.accountStat[index].highBalancePreviousYear
                        ?.toStringAsFixed(2)
                        .formatNumber() ??
                    "",
                maxLines: 1,
                style: const TextStyle(
                    color: AppColors.business, overflow: TextOverflow.clip),
              ),
              CustomSelectableText(
                text: widget.accountStat[index].lowBalancePreviousYear
                        ?.toStringAsFixed(2)
                        .formatNumber() ??
                    "",
                maxLines: 1,
                style: const TextStyle(
                    color: AppColors.business, overflow: TextOverflow.clip),
              ),
              CustomSelectableText(
                text: widget.accountStat[index].averageBalancePreviousYear
                        ?.toStringAsFixed(2)
                        .formatNumber() ??
                    "",
                maxLines: 1,
                style: const TextStyle(
                    color: AppColors.business, overflow: TextOverflow.clip),
              ),
              CustomSelectableText(
                text: widget.accountStat[index].turnoverPreviousYear
                        ?.toStringAsFixed(2)
                        .formatNumber() ??
                    "",
                maxLines: 1,
                style: const TextStyle(
                    color: AppColors.business, overflow: TextOverflow.clip),
              ),
              CustomSelectableText(
                text: widget.accountStat[index].highBalanceCurrentYear
                        ?.toStringAsFixed(2)
                        .formatNumber() ??
                    "",
                maxLines: 1,
                style: const TextStyle(
                    color: AppColors.business, overflow: TextOverflow.clip),
              ),
              CustomSelectableText(
                text: widget.accountStat[index].lowBalanceCurrentYear
                        ?.toStringAsFixed(2)
                        .formatNumber() ??
                    "",
                style: const TextStyle(
                    color: AppColors.business, overflow: TextOverflow.clip),
                maxLines: 1,
              ),
              CustomSelectableText(
                text: widget.accountStat[index].averageBalanceCurrentYear
                        ?.toStringAsFixed(2)
                        .formatNumber() ??
                    "",
                style: const TextStyle(
                    color: AppColors.business, overflow: TextOverflow.clip),
                maxLines: 1,
              ),
              CustomSelectableText(
                text: widget.accountStat[index].turnoverCurrentYear
                        ?.toStringAsFixed(2)
                        .formatNumber() ??
                    "",
                style: const TextStyle(
                    color: AppColors.business, overflow: TextOverflow.clip),
                maxLines: 1,
              ),
            ];
          }),
        ),
      ],
    );
  }

  List<TableColumn> getTableColumns() {
    return [
      TableColumn(
          width: 80.w,
          label: Text(
            "profitabilityAccountConduct.accountStats.product".tr(),
          )),
      TableColumn(
          width: 120.w,
          label: Text(
            "profitabilityAccountConduct.accountStats.accountCommitmentNumber"
                .tr(),
          )),
      TableColumn(
          width: 70.w,
          isStacked: true,
          label: Text(
            "profitabilityAccountConduct.accountStats.highBalance".tr(),
          )),
      TableColumn(
          width: 70.w,
          isStacked: true,
          label: Text(
            "profitabilityAccountConduct.accountStats.lowBalance".tr(),
          )),
      TableColumn(
          width: 70.w,
          isStacked: true,
          label: Text(
            "profitabilityAccountConduct.accountStats.avgBalance".tr(),
          )),
      TableColumn(
          width: 70.w,
          isStacked: true,
          label: Text(
            "profitabilityAccountConduct.accountStats.turnover".tr(),
          )),
      TableColumn(
          width: 70.w,
          isStacked: true,
          label: Text(
            "profitabilityAccountConduct.accountStats.highBalance".tr(),
          )),
      TableColumn(
          width: 70.w,
          isStacked: true,
          label: Text(
            "profitabilityAccountConduct.accountStats.lowBalance".tr(),
          )),
      TableColumn(
          width: 70.w,
          isStacked: true,
          label: Text(
            "profitabilityAccountConduct.accountStats.avgBalance".tr(),
          )),
      TableColumn(
          width: 70.w,
          isStacked: true,
          label: Text(
            "profitabilityAccountConduct.accountStats.turnover".tr(),
          )),
    ];
  }
}
