import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

class CommentsTableWidget extends StatelessWidget {
  const CommentsTableWidget({
    required this.comments,
    super.key,
    this.ishtmlComment = false,
  });
  final List<Comment> comments;
  final bool ishtmlComment;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      autoFitWidth: true,
      showPagination: true,
      rowsPerPage: 5,
      columnHeaderHeight: 30.w,
      columns: getCommentColumns(),
      rows: getCommentRows(context),
    );
  }

  List<TableColumn> getCommentColumns() {
    final columnNames = [
      TableColumn(
        forcedWidth: 100.w,
        label: Text("covenantsConditions.covenantsSummary.timeStamp".tr()),
      ),
      TableColumn(
        forcedWidth: 100.w,
        label: Text("covenantsConditions.covenantsSummary.user".tr()),
      ),
      TableColumn(
        forcedWidth: 100.w,
        label: Text("covenantsConditions.covenantsSummary.comment".tr()),
      ),
    ];

    return columnNames;
  }

  List<List<Widget>> getCommentRows(BuildContext context) {
    final LayoutViewModel layoutViewModel = context.watch<LayoutViewModel>();
    if (comments.isEmpty) {
      return [];
    }

    const int previewCharLimit = 50;

    return List.generate((comments).length, (index) {
      final Comment comment = comments[index];

      final String commentText = (comment.comment ?? "").trim();
      final bool isLongPlainText =
          !ishtmlComment && commentText.length > previewCharLimit;

      // Build the comment cell:
      // - HTML comment => button opens HTML dialog
      // - Plain text & long => preview + "View more"
      // - Plain text & short => show full text
      final Widget commentCell = ishtmlComment
          ? Center(
              child: CustomButton(
                isLoading: false,
                label: "common.viewComment".tr(),
                onPressed: () {
                  if (context.mounted) {
                    layoutViewModel.showCommentDialog(context, commentText);
                  }
                },
              ),
            )
          : isLongPlainText
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "${commentText.substring(0, previewCharLimit)}…",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        if (context.mounted) {
                          layoutViewModel.showCommentCorporateDialog(
                            context,
                            commentText,
                          );
                        }
                      },
                      child: Text(
                        "common.viewMore".tr(),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.highlightedTextColor,
                          color: AppColors.highlightedTextColor,
                        ),
                      ),
                    ),
                  ],
                )
              : Text(
                  commentText,
                  textAlign: TextAlign.start,
                );

      return [
        Text(
          textAlign: TextAlign.start,
          (comment.createdDate != null)
              ? DateTimeUtils.formatDateTime(
                  comment.createdDate!,
                  format: "dd/MM/yyyy HH:mm:ss",
                )
              : "",
        ),
        Text(textAlign: TextAlign.start, comment.userId ?? ""),
        commentCell,
      ];
    });
  }
}
