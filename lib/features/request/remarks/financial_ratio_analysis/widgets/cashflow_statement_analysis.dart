import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/add_table_rows.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/financial_dropdown_widget.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/cashflow_statement_analysis.dart";

/// Displays the Cash Flow Statement Analysis section.
class CashflowStatementAnalysis extends StatelessWidget {
  /// Creates a Cash Flow Statement Analysis widget.
  const CashflowStatementAnalysis({
    required this.viewModel,
    super.key,
  });

  /// Financial Ratio Analysis view model.
  final FinancialRatioAnalysisViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(),
        CustomSectionHeader(
          title: "remarks.financialRatiosAnalysis.cashflowSheetAnalysis".tr(),
        ),
        const Gap(),
        CustomRawTable(
          key: UniqueKey(),
          columns: getColumns(),
          rows: getRows(),
        ),
        const Gap(size: GapSize.small),
        AddTableRows(
          viewModel: viewModel,
          type: StatementType.cashflow,
          text: "remarks.financialRatiosAnalysis.addCashflowSheetAnalysis".tr(),
        ),
        const Gap(size: GapSize.small),
        FinancialDropdownWidget(
          width: AppStyle.groupBorrowersTextField,
          label: "remarks.financialRatiosAnalysis.cashflowSheetHealth".tr(),
          child: CustomDropdown<Reference>(
            semanticLabel:
                "remarks.financialRatiosAnalysis.cashflowSheetHealth".tr(),
            items: viewModel.cashflowHealth,
            itemBuilder: (context, item, {isDisabled, isSelected}) {
              return dropdownItemBuildWidget(
                item.name,
                isSelected: isSelected ?? false,
              );
            },
            onSelected: (selectedValue) {
              viewModel.selectedCashFlowHealth = selectedValue.first;
            },
            dropdownBuilder: (context, item) => Text(item?.name ?? ""),
            selectedItems: viewModel.selectedCashFlowHealth != null
                ? [viewModel.selectedCashFlowHealth]
                : [Reference(name: "Select")],
          ),
        ),
        const Gap(),
        LabelWidget(
          label: "remarks.financialRatiosAnalysis.rmRemarks".tr(),
          child: SizedBox(
            height: AppStyle.customTextEditorWidgetForRemark,
            child: UnifiedTextEditor(
              showVideoUpload: false,
              semanticLabel: "remarks.financialRatiosAnalysis.rmRemarks".tr(),
              controller: viewModel.cashflowController,
              initialText: viewModel.cashflowDescription,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the table columns for the Cash Flow Statement Analysis table.
  List<TableColumn> getColumns() {
    final showAction = viewModel.hasActionColumnCashflow;
    return [
      TableColumn(
        label: Text("remarks.financialRatiosAnalysis.keyCashflowItems".tr()),
      ),
      TableColumn(label: Text(viewModel.getHeaderDate(0))),
      TableColumn(label: Text(viewModel.getHeaderDate(1))),
      TableColumn(label: Text(viewModel.getHeaderDate(2))),
      TableColumn(label: Text(viewModel.getHeaderDate(3))),
      TableColumn(label: Text(viewModel.getHeaderDate(4))),
      if (showAction) const TableColumn(label: SizedBox()),
    ];
  }

  /// Builds the table rows for the Cash Flow Statement Analysis table.
  List<List<Widget>> getRows() {
    final cashflowRefs = viewModel.financialRatioType
            ?.where((row) => row.reference1 == ServerConstants.cashFlowAnalysis)
            .toList() ??
        [];

    final mergedRows = cashflowRefs.map((ref) {
      final apiRow = viewModel.cashflowSheetRows.firstWhere(
        (row) => row.id == (ref.reference2 ?? ""),
        orElse: () {
          return CashFlowSheetAnalysisRow(
            id: ref.reference2 ?? "",
            cashFlowItems: ref.name!,
          );
        },
      )..cashFlowItems = ref.name!;
      return apiRow;
    }).toList();

    final newRows =
        viewModel.cashflowSheetRows.where((row) => row.isNew).toList();

    final allRows = [...mergedRows, ...newRows];
    return List.generate(allRows.length, (index) {
      final row = allRows[index];
      final itemLabel = row.cashFlowItems;

      final cells = <Widget>[
        if (row.isNew)
          Center(
            child: CustomTextField(
              initialValue: itemLabel,
              validator: CustomValidator.twoDecimalNumeric,
              maxLength: 100,
              inputFormatters: [AlphanumericOrTwoDecimalInputFormatter()],
              onChanged: (v) => row.cashFlowItems = v,
            ),
          )
        else
          Text(
            viewModel.rowValue(
              itemLabel,
              isNew: row.isNew,
              rowIndex: index,
            ),
          ),
      ]

          // Cash Flow Item Name
          ;

      // Audited columns
      final List<String> auditedValues = [
        row.audited1,
        row.audited2,
        row.audited3,
      ];
      for (int i = 0; i < auditedValues.length; i++) {
        final String value = auditedValues[i];
        cells.add(
          Center(
            child: row.isNew
                ? CustomTextField(
                    initialValue: value,
                    validator: CustomValidator.twoDecimalNumeric,
                    inputFormatters: [DecimalInputFormatterTwoDigit()],
                    onChanged: (txt) {
                      if (i == 0) {
                        row.audited1 = txt;
                      }
                      if (i == 1) {
                        row.audited2 = txt;
                      }
                      if (i == 2) {
                        row.audited3 = txt;
                      }
                    },
                  )
                : Text(
                    viewModel.rowValue(
                      value,
                      isNew: row.isNew,
                      rowIndex: index,
                    ),
                  ),
          ),
        );
      }

      // In-house
      cells
        ..add(
          Center(
            child: row.isNew
                ? CustomTextField(
                    initialValue: row.inhouse,
                    validator: CustomValidator.twoDecimalNumeric,
                    inputFormatters: [DecimalInputFormatterTwoDigit()], //
                    onChanged: (v) => row.inhouse = v,
                  )
                : Text(
                    viewModel.rowValue(
                      row.inhouse,
                      isNew: row.isNew,
                      rowIndex: index,
                    ),
                  ),
          ),
        )
        ..add(
          Center(
            child: row.isNew
                ? CustomTextField(
                    initialValue: row.estimated,
                    validator: CustomValidator.twoDecimalNumeric,
                    inputFormatters: [DecimalInputFormatterTwoDigit()], //
                    onChanged: (v) => row.estimated = v,
                  )
                : Text(
                    viewModel.rowValue(
                      row.estimated,
                      isNew: row.isNew,
                      rowIndex: index,
                    ),
                  ),
          ),
        );

      if (viewModel.hasActionColumnCashflow) {
        cells.add(
          row.isNew
              ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      viewModel.deleteUserAddedCashflowRow(row), // ← CHANGED
                )
              : const SizedBox.shrink(),
        );
      }

      return cells;
    });
  }
}
