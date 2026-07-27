import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/models/request/profitability/relationship_profitability_detailed.dart";

/// Relationship profit detail table.
class RelationshipProfitDetailTable extends StatelessWidget {
  /// Creates a relationship profit detail table.
  const RelationshipProfitDetailTable({
    required this.details,
    super.key,
  });

  /// Relationship profitability details.
  final List<RelationshipProfitabilityDetail>? details;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      stackedHeaders: _buildStackedHeaders(),
      columns: _buildColumns(),
      rows: _buildRows(),
      // columnHeaderHeight: 30.w,
      autoFitWidth: false,
      rowsPerPage: 10,
      columnHeaderHeight: 25.w,
      // columnSpacing: 20.w,
      // headerColor: Colors.grey.shade200,
    );
  }

  List<StackedHeader> _buildStackedHeaders() {
    final headers = [
      {
        "startIndex": 1,
        "endIndex": 1,
        "labelKey": "profitabilityAccountConduct."
            "relationshipProfitabilityDetailed.last12Month",
        "width": 127.5.w,
      },
      {
        "startIndex": 2,
        "endIndex": 3,
        "labelKey": "profitabilityAccountConduct."
            "relationshipProfitabilityDetailed.next12Month",
        "width": 250.0.w,
      },
      {
        "startIndex": 4,
        "endIndex": 5,
        "labelKey": "profitabilityAccountConduct."
            "relationshipProfitabilityDetailed.next12To24Month",
        "width": 250.0.w,
      },
    ];

    return headers.map((header) {
      return StackedHeader(
        startIndex: header["startIndex"]! as int,
        endIndex: header["endIndex"]! as int,
        widget: Text((header["labelKey"]! as String).tr()),
        width: header["width"]! as double,
      );
    }).toList();
  }

  List<TableColumn> _buildColumns() {
    final columnData = [
      {
        "width": 127.5.w,
        "isStacked": false,
        "labelKey": "profitabilityAccountConduct."
            "relationshipProfitabilityDetailed.natureOfBusiness",
      },
      {
        "width": 127.5.w,
        "isStacked": true,
        "labelKey": "profitabilityAccountConduct."
            "relationshipProfitabilityDetailed.amount",
      },
      {
        "width": 125.0.w,
        "isStacked": true,
        "labelKey": "profitabilityAccountConduct."
            "relationshipProfitabilityDetailed.amount",
      },
      {
        "width": 125.0.w,
        "isStacked": true,
        "labelKey": "profitabilityAccountConduct."
            "relationshipProfitabilityDetailed.profitabilityPer",
      },
      {
        "width": 125.0.w,
        "isStacked": true,
        "labelKey": "profitabilityAccountConduct."
            "relationshipProfitabilityDetailed.amount",
      },
      {
        "width": 125.0.w,
        "isStacked": true,
        "labelKey": "profitabilityAccountConduct."
            "relationshipProfitabilityDetailed.profitabilityPer",
      },
    ];

    return columnData.map((data) {
      return TableColumn(
        width: data["width"]! as double,
        isStacked: data["isStacked"]! as bool,
        label: Text((data["labelKey"]! as String).tr()),
      );
    }).toList();
  }

  List<List<Widget>> _buildRows() {
    return List.generate(details?.length ?? 0, (index) {
      final detail = details![index];
      return [
        Text(detail.natureOfBusiness ?? ""),
        Text(
          detail.last12Months ?? "",
          style: const TextStyle(color: AppColors.primary),
        ),
        Text(
          detail.next12MonthsAmount ?? "",
          style: const TextStyle(color: AppColors.primary),
        ),
        Text(
          detail.next12MonthsProfitabilityPercent ?? "",
          style: const TextStyle(color: AppColors.primary),
        ),
        Text(
          detail.next12To24MonthsAmount ?? "",
          style: const TextStyle(color: AppColors.primary),
        ),
        Text(
          detail.next12To24MonthsProfitabilityPercent ?? "",
          style: const TextStyle(color: AppColors.primary),
        ),
      ];
    });
  }
}
