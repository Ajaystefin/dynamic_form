import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/features/admin/manage_reference/model.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/view.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";

/// Displays the reference data table.
class ReferenceTableField extends StatelessWidget {
  /// Creates a [ReferenceTableField].
  const ReferenceTableField({required this.viewModel, super.key});

  /// View model containing reference data.
  final ManageReferenceViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      rowsPerPage: viewModel.rowsPerPage,
      columnHeaderHeight: 30.w,
      key: UniqueKey(),
      columns: getTableColumns(),
      onPageChange: (page) {
        viewModel.currentPage = page;
      },
      isFilterTable: true,
      rowModels: getTableRows(
        viewModel.filteredReferences,
        viewModel.selectedReferenceType,
        context,
      ),
    );
  }

  /// Returns the table columns based on the selected reference type.
  List<TableColumn> getTableColumns() {
    final List<TableColumn> columns = [];
    if (viewModel.selectedReferenceType == null) {
      return columns;
    }

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

  List<RowModel> getTableRows(
    List<Reference> references,
    ReferenceType? selectedReferenceType,
    BuildContext context,
  ) {
    final filterRow = RowModel(
      isFilterRow: false,
      color: AppColors.tableHeadingColor,
      widget: [
        _textFilter(viewModel.idFilter, viewModel.onIdFilterChanged),
        _textFilter(viewModel.nameFilter, viewModel.onNameFilterChanged),
        _textFilter(
          viewModel.descriptionFilter,
          viewModel.onDescriptionFilterChanged,
        ),
        _textFilter(
          viewModel.ref1Filter,
          viewModel.onReference1FilterChanged,
        ),
        _textFilter(
          viewModel.ref2Filter,
          viewModel.onReference2FilterChanged,
        ),
        _textFilter(
          viewModel.ref3Filter,
          viewModel.onReference3FilterChanged,
        ),
        _textFilter(
          viewModel.ref4Filter,
          viewModel.onReference4FilterChanged,
        ),
        _textFilter(
          viewModel.ref5Filter,
          viewModel.onReference5FilterChanged,
        ),
        _statusFilterDropdown(),
      ],
    );
    final rowModels = references.map((reference) {
      return RowModel(
        isFilterRow: false,
        widget: [
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
        ],
      );
    }).toList();

    final merged = addFilterForRowModel(
      rows: rowModels,
      filterRow: filterRow,
      rowsPerPage: viewModel.rowsPerPage,
    );

    return merged.isEmpty ? [filterRow] : merged;
  }

  Widget _textFilter(
    String? value,
    Function(String) onChanged,
  ) {
    return CustomTextField(
      initialValue: value,
      fillColor: AppColors.white,
      filled: true,
      textStyle: const TextStyle(fontSize: 13),
      onSubmitted: onChanged,
    );
  }

  Widget _statusFilterDropdown() {
    return CustomMultiSelectDropdown<String>(
      isFilterField: true,
      items: viewModel.status,
      fillColor: AppColors.white,
      semanticLabel: "admin.referenceDataManagement.status".tr(),
      itemBuilder: (
        context,
        item, {
        isDisabled,
        isSelected,
      }) {
        return dropdownItemBuildWidget(
          item,
          isSelected: isSelected ?? false,
        );
      },
      dropdownBuilder: (context, items) => _selectedSummary(items ?? []),
      selectedItems: viewModel.statusFilter,
      onSelected: (selectedValue) {
        viewModel.onStatusFilterChanged(
          selectedValue,
        );
      },
    );
  }

  Widget _selectedSummary(List<String> labels) {
    if (labels.isEmpty) {
      return const SizedBox();
    }
    final String text = labels.length == 1
        ? labels.first
        : "${labels.first} & ${labels.length - 1} more";
    return CustomTooltip(
      message: labels.join(", "),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: TextAlign.left,
      ),
    );
  }
}
