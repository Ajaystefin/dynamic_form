import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart';
import 'package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/add_table_rows.dart';
import 'package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/financial_formattable_text.dart';
import 'package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/financial_dropdown_widget.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/remarks/financial_ratio_analysis/cashflow_statement_analysis.dart';

class CashflowStatementAnalysis extends StatelessWidget {
  final FinancialRatioAnalysisViewModel viewModel;
  const CashflowStatementAnalysis({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(size: GapSize.medium),
        CustomSectionHeader(
            title:
                "remarks.financialRatiosAnalysis.cashflowSheetAnalysis".tr()),
        const Gap(size: GapSize.medium),
        CustomRawTable(
            key: UniqueKey(), columns: getColumns(), rows: getRows()),
        const Gap(size: GapSize.small),
        AddTableRows(
            viewModel: viewModel,
            type: StatementType.cashflow,
            text: "remarks.financialRatiosAnalysis.addCashflowSheetAnalysis"
                .tr()),
        const Gap(size: GapSize.small),
        FinancialDropdownWidget(
          width: AppStyle.groupBorrowersTextField,
          label: "remarks.financialRatiosAnalysis.cashflowSheetHealth".tr(),
          child: CustomDropdown<Reference>(
            semanticLabel:
                "remarks.financialRatiosAnalysis.cashflowSheetHealth".tr(),
            items: viewModel.financialHealth,
            itemBuilder: (context, item, isDisabled, isSelected) {
              return dropdownItemBuildWidget(item.name,
                  isListTile: true, isSelected: isSelected);
            },
            onSelected: (selectedValue) {
              viewModel.selectedBalanceSheetHealth = (selectedValue.first);
            },
            dropdownBuilder: (context, item) => Text(item?.name ?? ""),
            selectedItems: viewModel.selectedBalanceSheetHealth != null
                ? [viewModel.selectedBalanceSheetHealth!]
                : null,
          ),
        ),
        const Gap(size: GapSize.medium),
        FinancialFormattableText(
            label: 'remarks.financialRatiosAnalysis.rmRemarks'.tr(),
            viewModel: viewModel,
            isRequired: false),
      ],
    );
  }

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

  List<List<Widget>> getRows() {
    final cashflowRefs = viewModel.financialRatioType
            ?.where((row) => row.reference1 == ServerConstants.cashFlowAnalysis)
            .toList() ??
        [];

    final mergedRows = cashflowRefs.map((ref) {
      final apiRow = viewModel.cashflowSheetRows.firstWhere(
        (row) => row.id == (ref.reference2 ?? ''),
        orElse: () {
          return CashFlowSheetAnalysisRow(
            id: ref.reference2 ?? '',
            cashFlowItems: ref.name!,
            audited1: '',
            audited2: '',
            audited3: '',
            inhouse: '',
            isNew: false,
          );
        },
      );
      apiRow.cashFlowItems = ref.name!;
      return apiRow;
    }).toList();

    final newRows =
        viewModel.cashflowSheetRows.where((row) => row.isNew).toList();

    final allRows = [...mergedRows, ...newRows];
    return List.generate(allRows.length, (index) {
      final row = allRows[index];
      final itemLabel = row.cashFlowItems;

      final cells = <Widget>[];

      // Cash Flow Item Name
      cells.add(row.isNew
          ? Center(
              child: CustomTextField(
                initialValue: itemLabel,
                validator: CustomValidator.twoDecimalNumeric,
                inputFormatters: [AlphanumericOrTwoDecimalInputFormatter()],
                onChanged: (v) => row.cashFlowItems = v,
              ),
            )
          : Text(viewModel.rowValue(itemLabel,
              isNew: row.isNew, rowIndex: index)));

      // Audited columns
      for (var value in [row.audited1, row.audited2, row.audited3]) {
        cells.add(
          Center(
            child: row.isNew
                ? CustomTextField(
                    initialValue: value,
                    validator: CustomValidator.twoDecimalNumeric,
                    inputFormatters: [AlphanumericOrTwoDecimalInputFormatter()],
                    onChanged: (v) {
                      if (value == row.audited1) {
                        row.audited1 = v;
                      } else if (value == row.audited2) {
                        row.audited2 = v;
                      } else {
                        row.audited3 = v;
                      }
                    },
                  )
                : Text(viewModel.rowValue(value,
                    isNew: row.isNew, rowIndex: index)),
          ),
        );
      }

      // In-house
      cells.add(
        Center(
            child: row.isNew
                ? CustomTextField(
                    initialValue: row.inhouse,
                    validator: CustomValidator.twoDecimalNumeric,
                    inputFormatters: [
                      AlphanumericOrTwoDecimalInputFormatter()
                    ], //
                    onChanged: (v) => row.inhouse = v,
                  )
                : Text(viewModel.rowValue(row.inhouse,
                    isNew: row.isNew, rowIndex: index))),
      );

      cells.add(
        Center(
            child: row.isNew
                ? CustomTextField(
                    initialValue: row.inhouse,
                    validator: CustomValidator.twoDecimalNumeric,
                    inputFormatters: [
                      AlphanumericOrTwoDecimalInputFormatter()
                    ], //
                    onChanged: (v) => row.inhouse = v,
                  )
                : Text(viewModel.rowValue(row.inhouse,
                    isNew: row.isNew, rowIndex: index))),
      );

      // Delete button only for new rows
      if (viewModel.hasActionColumnCashflow) {
        cells.add(
          row.isNew
              ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => viewModel.deleteCashflowRow(row.id),
                )
              : const SizedBox.shrink(),
        );
      }

      return cells;
    });
  }
}
