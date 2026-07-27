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

/// Displays comments in a tabular format.
class CommentsTableWidget extends StatelessWidget {
  /// Creates a [CommentsTableWidget].
  const CommentsTableWidget({
    required this.comments,
    super.key,
    this.ishtmlComment = false,
  });

  /// Comments to display.
  final List<Comment> comments;

  /// Indicates whether comments contain HTML content.
  final bool ishtmlComment;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      rowsPerPage: 5,
      columnHeaderHeight: 30.w,
      columns: getCommentColumns(),
      rows: getCommentRows(context),
    );
  }

  /// Returns table columns for comments.
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

  /// Returns table rows for comments.
  List<List<Widget>> getCommentRows(BuildContext context) {
    final LayoutViewModel layoutViewModel = context.watch<LayoutViewModel>();
    if (comments.isEmpty) {
      return [];
    }

    const int previewCharLimit = 50;

    return List.generate(comments.length, (index) {
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
                    Semantics(
                      button: true,
                      label: "common.viewMore".tr(),
                      child: InkWell(
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
        // Text(textAlign: TextAlign.start, comment.userId ?? ""),
        Text(textAlign: TextAlign.start, comment.user ?? ""),
        commentCell,
      ];
    });
  }
}
