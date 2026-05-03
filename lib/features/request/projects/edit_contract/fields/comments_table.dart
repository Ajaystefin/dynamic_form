import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

class CommentsTable extends StatelessWidget {
  const CommentsTable({required this.viewModel, super.key});
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final comments = viewModel.commentItem; // List<Comment>
    return Column(
      children: [
        // if (comments.isNotEmpty)
        CustomRawTable(
          key: UniqueKey(),
          autoFitWidth: true,
          showPagination: true,
          rowsPerPage: 5,
          columnHeaderHeight: 30.w,
          columns: [
            TableColumn(
              forcedWidth: 100.w,
              label: Text(
                "covenantsConditions.covenantsSummary.commentHistory".tr(),
              ),
            ),
            // TableColumn(
            //     forcedWidth: 100.w,
            //     label:
            // Text("covenantsConditions.covenantsSummary.user".tr())),
            TableColumn(
              forcedWidth: 100.w,
              label: Text(
                "covenantsConditions.covenantsSummary.timeStamp".tr(),
              ),
            ),
          ],
          rows: List.generate(comments.length, (index) {
            final Comment comment = comments[index];
            return [
              CustomTooltip(
                message: comment.comment?.toString() ??
                    comment.strategyComment ??
                    "",
                child: Text(
                  textAlign: TextAlign.start,
                  comment.comment?.toString() ?? comment.strategyComment ?? "",
                ),
              ),
              // Text(
              //     textAlign: TextAlign.start,
              //     comment.user?.toString() ?? comment.createdBy?.toString()
              // ?? ""),
              Text(
                textAlign: TextAlign.start,
                comment.createdDate != null
                    ? DateTimeUtils.formatDateTime(
                        comment.createdDate!,
                        format: "dd/MM/yyyy HH:mm:ss", // or whatever you prefer
                      )
                    : "",
              ),
            ];
          }),
        ),
      ],
    );
  }
}
