import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";

class AppOutputSelectionTableWidget extends StatelessWidget {
  const AppOutputSelectionTableWidget({required this.viewModel, super.key});
  final dynamic viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomRawTable(
          key: UniqueKey(),
          rowsPerPage: viewModel.rowsPerPage ?? 10,
          showPagination: true,
          headerColor: Colors.grey.shade200,
          columns: _getCommentColumns(),
          rows: _getCommentRows(),
        ),
      ],
    );
  }

  List<TableColumn> _getCommentColumns() {
    return [
      TableColumn(label: Text("".tr())),
      TableColumn(
        label: Text("approval.requestForLimitRelease.applicationForm".tr()),
      ),
    ];
  }

  List<List<Widget>> _getCommentRows() {
    if (viewModel.comment == null) return [];

    return List.generate(viewModel.comment.length, (index) {
      final comment = viewModel.comment[index];
      return [
        CustomCheckbox(
          value: false,
          onChange: (p0) {},
        ),
        CustomSelectableText(text: comment.createdBy?.toString() ?? ""),
      ];
    });
  }
}
