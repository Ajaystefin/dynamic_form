import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/features/admin/manage_reference/model.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/view.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";

class ReferenceTableField extends StatelessWidget {
  const ReferenceTableField({required this.viewModel, super.key});
  final ManageReferenceViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final List<Reference> references = viewModel.references;
    return CustomRawTable(
      showPagination: true,
      rowsPerPage: 10,
      columnHeaderHeight: 30.w,
      key: ValueKey(viewModel.selectedReferenceType?.id ?? "no-ref"),
      columns: getTableColumns(),
      rows: getTableRows(references, viewModel.selectedReferenceType, context),
    );
  }

  List<TableColumn> getTableColumns() {
    final List<TableColumn> columns = [];
    if (viewModel.selectedReferenceType == null) return columns;

    final List<String> columnNames = viewModel.getColumnNames();
    for (int i = 0; i < columnNames.length; i++) {
      final String columnName = columnNames[i];
      columns.add(
        TableColumn(
          forcedWidth: 100,
          label: Text(key: ValueKey(columnName), columnName),
        ),
      );
    }

    return columns;
  }

  List<List<Widget>> getTableRows(
    List<Reference> references,
    ReferenceType? selectedReferenceType,
    BuildContext context,
  ) {
    return references.map((reference) {
      return [
        TextButton(
          onPressed: () async {
            await DialogHelper.showCustomDialog(
              barrierDismissible: false,
              title:
                  "admin.referenceDataManagement.referencedatainformationTitle"
                      .tr(),
              content: UpdateReferenceDialogView(
                reference: reference,
                referenceType: selectedReferenceType ?? ReferenceType(),
              ),
              context: context,
            );
            await viewModel.onReferenceDataSelected(
              selectedReferenceType ?? ReferenceType(),
            );
          },
          child: Text(
            reference.id.toString(),
            style: const TextStyle(
              fontSize: AppStyle.fontSizeSmall,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.darkBlue,
            ),
          ),
        ),
        Text(
          reference.name ?? "",
          textAlign: TextAlign.start,
        ),
        Text(
          reference.description ?? "",
          textAlign: TextAlign.start,
        ),
        Text(
          reference.reference1 ?? "",
          textAlign: TextAlign.start,
        ),
        Text(
          reference.reference2 ?? "",
          textAlign: TextAlign.start,
        ),
        Text(
          reference.reference3 ?? "",
          textAlign: TextAlign.start,
        ),
        Text(
          reference.reference4 ?? "",
          textAlign: TextAlign.start,
        ),
        Text(
          reference.reference5 ?? "",
          textAlign: TextAlign.start,
        ),
        Text(
          (reference.status ?? Status.inactive.name).capitalizeFirstLetter(),
          textAlign: TextAlign.start,
        ),
      ];
    }).toList();
  }
}
