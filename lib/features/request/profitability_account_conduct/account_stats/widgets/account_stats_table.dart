import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_stats/model.dart";
import "package:wcas_frontend/models/request/profitability/account_stat.dart";

class AccountStatsTable extends StatefulWidget {
  const AccountStatsTable({
    required this.viewModel,
    required this.accountStat,
    super.key,
  });
  final AccountStatsViewModel viewModel;
  final List<AccountStat> accountStat;

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
                "profitabilityAccountConduct.accountStats.previousYear".tr(),
              ),
            ),
            StackedHeader(
              width: 280.w,
              startIndex: 6,
              endIndex: 9,
              widget: Text(
                "profitabilityAccountConduct.accountStats.currentYear".tr(),
              ),
            ),
          ],
          columns: getTableColumns(),
          rows: widget.accountStat.isEmpty
              ? []
              : List.generate(widget.accountStat.length, (index) {
                  return [
                    Text(
                      widget.accountStat[index].product.toString(),
                    ),
                    CustomSelectableText(
                      text: widget.accountStat[index].accountCommitmentNumber
                          .toString(),
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.business,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    CustomSelectableText(
                      text: widget.accountStat[index].highBalancePreviousYear ??
                          "",
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.business,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    CustomSelectableText(
                      text: widget.accountStat[index].lowBalancePreviousYear ??
                          "",
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.business,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    CustomSelectableText(
                      text: widget
                              .accountStat[index].averageBalancePreviousYear ??
                          "",
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.business,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    CustomSelectableText(
                      text:
                          widget.accountStat[index].turnoverPreviousYear ?? "",
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.business,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    CustomSelectableText(
                      text: widget.accountStat[index].highBalanceCurrentYear ??
                          "",
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.business,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    CustomSelectableText(
                      text:
                          widget.accountStat[index].lowBalanceCurrentYear ?? "",
                      style: const TextStyle(
                        color: AppColors.business,
                        overflow: TextOverflow.clip,
                      ),
                      maxLines: 1,
                    ),
                    CustomSelectableText(
                      text:
                          widget.accountStat[index].averageBalanceCurrentYear ??
                              "",
                      style: const TextStyle(
                        color: AppColors.business,
                        overflow: TextOverflow.clip,
                      ),
                      maxLines: 1,
                    ),
                    CustomSelectableText(
                      text: widget.accountStat[index].turnoverCurrentYear ?? "",
                      style: const TextStyle(
                        color: AppColors.business,
                        overflow: TextOverflow.clip,
                      ),
                      maxLines: 1,
                    ),
                  ];
                }),
        ),
        if (widget.accountStat.isEmpty)
          Center(
            child: Text(
              "common.emptyState".tr(),
            ),
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
        ),
      ),
      TableColumn(
        width: 120.w,
        label: Text(
          "profitabilityAccountConduct.accountStats.accountCommitmentNumber"
              .tr(),
        ),
      ),
      TableColumn(
        width: 70.w,
        isStacked: true,
        label: Text(
          "profitabilityAccountConduct.accountStats.highBalance".tr(),
        ),
      ),
      TableColumn(
        width: 70.w,
        isStacked: true,
        label: Text(
          "profitabilityAccountConduct.accountStats.lowBalance".tr(),
        ),
      ),
      TableColumn(
        width: 70.w,
        isStacked: true,
        label: Text(
          "profitabilityAccountConduct.accountStats.avgBalance".tr(),
        ),
      ),
      TableColumn(
        width: 70.w,
        isStacked: true,
        label: Text(
          "profitabilityAccountConduct.accountStats.turnover".tr(),
        ),
      ),
      TableColumn(
        width: 70.w,
        isStacked: true,
        label: Text(
          "profitabilityAccountConduct.accountStats.highBalance".tr(),
        ),
      ),
      TableColumn(
        width: 70.w,
        isStacked: true,
        label: Text(
          "profitabilityAccountConduct.accountStats.lowBalance".tr(),
        ),
      ),
      TableColumn(
        width: 70.w,
        isStacked: true,
        label: Text(
          "profitabilityAccountConduct.accountStats.avgBalance".tr(),
        ),
      ),
      TableColumn(
        width: 70.w,
        isStacked: true,
        label: Text(
          "profitabilityAccountConduct.accountStats.turnover".tr(),
        ),
      ),
    ];
  }
}
