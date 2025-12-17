import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/utils/date_time_utils.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/models/request/comment.dart';

class CommentsTableWidget extends StatelessWidget {
  final List<Comment> comments;

  const CommentsTableWidget({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      autoFitWidth: true,
      showPagination: true,
      rowsPerPage: 5,
      columnHeaderHeight: 30.w,
      columns: _getCommentColumns(),
      rows: _getCommentRows(),
    );
  }

  List<TableColumn> _getCommentColumns() {
    final columnNames = [
      TableColumn(
          forcedWidth: 100.w,
          label: Text("covenantsConditions.covenantsSummary.timeStamp".tr())),
      TableColumn(
          forcedWidth: 100.w,
          label: Text("covenantsConditions.covenantsSummary.user".tr())),
      TableColumn(
          forcedWidth: 100.w,
          label: Text("covenantsConditions.covenantsSummary.comment".tr())),
    ];

    return columnNames;
  }

  List<List<Widget>> _getCommentRows() {
    return List.generate((comments).length, (index) {
      Comment? comment = comments[index];
      return [
        Text(
          textAlign: TextAlign.start,
          comment.createdDate != null
              ? DateTimeUtils.formatDateTime(
                  comment.createdDate!,
                  format: 'dd/MM/yyyy HH:mm:ss', // or whatever you prefer
                )
              : "",
        ),
        Text(textAlign: TextAlign.start, comment.user?.toString() ?? ""),
        Text(textAlign: TextAlign.start, comment.comment?.toString() ?? ""),
      ];
    });
  }
}
