import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/models/request/profitability/relationship_profitability_detailed.dart";

List<StackedHeader> getRelProfitDetStackedHeader() {
  return [
    StackedHeader(
      startIndex: 1,
      endIndex: 1,
      widget: Text(
        "profitabilityAccountConduct."
                "relationshipProfitabilityDetailed.last12Month"
            .tr(),
      ),
      width: 200,
    ),
    StackedHeader(
      startIndex: 2,
      endIndex: 3,
      widget: Text(
        "profitabilityAccountConduct."
                "relationshipProfitabilityDetailed.next12Month"
            .tr(),
      ),
      width: 400,
    ),
    StackedHeader(
      startIndex: 4,
      endIndex: 5,
      widget: Text(
        "profitabilityAccountConduct."
                "relationshipProfitabilityDetailed.next12To24Month"
            .tr(),
      ),
      width: 400,
    ),
  ];
}

List<TableColumn> getRelProfitDetColumns() {
  final List<TableColumn> columns = [
    TableColumn(
      width: 250,
      label: Text(
        "profitabilityAccountConduct."
                "relationshipProfitabilityDetailed.natureOfBusiness"
            .tr(),
      ),
    ),
    TableColumn(
      width: 200,
      isStacked: true,
      label: Text(
        "profitabilityAccountConduct.relationshipProfitabilityDetailed.amount"
            .tr(),
      ),
    ),
    TableColumn(
      isStacked: true,
      width: 200,
      label: Text(
        "profitabilityAccountConduct.relationshipProfitabilityDetailed.amount"
            .tr(),
      ),
    ),
    TableColumn(
      isStacked: true,
      width: 200,
      label: Text(
        "profitabilityAccountConduct."
                "relationshipProfitabilityDetailed.profitabilityPer"
            .tr(),
      ),
    ),
    TableColumn(
      isStacked: true,
      width: 200,
      label: Text(
        "profitabilityAccountConduct.relationshipProfitabilityDetailed.amount"
            .tr(),
      ),
    ),
    TableColumn(
      isStacked: true,
      width: 200,
      label: Text(
        "profitabilityAccountConduct."
                "relationshipProfitabilityDetailed.profitabilityPer"
            .tr(),
      ),
    ),
  ];

  return columns;
}

List<List<Widget>> getRelProfitDetRows(
  List<RelationshipProfitabilityDetail>? relationshipProfitabilityDetail,
) {
  final List<List<Widget>> widgets = [];

  widgets.addAll(
    List.generate(
        relationshipProfitabilityDetail == null
            ? 0
            : relationshipProfitabilityDetail.length, (index) {
      final detail = relationshipProfitabilityDetail?[index];
      return [
        Text("${detail?.natureOfBusiness}"),
        Text("${detail?.last12Months}"),
        Text("${detail?.next12MonthsAmount}"),
        Text(
          "${detail?.next12MonthsProfitabilityPercent}",
        ),
        Text(
          "${detail?.next12To24MonthsAmount}",
        ),
        Text(
          "${detail?.next12To24MonthsProfitabilityPercent}",
        ),
      ];
    }),
  );
  return widgets;
}
