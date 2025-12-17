import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart';
import 'package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/add_table_rows.dart';
import 'package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/financial_formattable_text.dart';
import 'package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/financial_dropdown_widget.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/remarks/financial_ratio_analysis/income_statement_analysis.dart';

class IncomeStatementAnalysis extends StatelessWidget {
  final FinancialRatioAnalysisViewModel viewModel;
  const IncomeStatementAnalysis({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(size: GapSize.medium),
        CustomSectionHeader(
            title:
                "remarks.financialRatiosAnalysis.incomeStatementAnalysis".tr()),
        const Gap(size: GapSize.medium),
        CustomRawTable(
          key: UniqueKey(),
          autoFitWidth: true,
          topStackedHeaders: [
            StackedHeader(
              startIndex: 0,
              endIndex: 0,
              width: 165.w,
              widget: CustomTextField(
                width: 155.w,
                initialValue: viewModel.longName,
                onSubmitted: (_) {},
              ),
            ),
            StackedHeader(
              startIndex: 1,
              endIndex: 1,
              width: 118.w,
              widget: Text(viewModel.getConstValue(0, 0)),
            ),
            StackedHeader(
              startIndex: 2,
              endIndex: 2,
              width: 118.w,
              widget: Text(viewModel.getConstValue(1, 0)),
            ),
            StackedHeader(
              startIndex: 3,
              endIndex: 3,
              width: 118.w,
              widget: Text(viewModel.getConstValue(2, 0)),
            ),
            StackedHeader(
              startIndex: 4,
              endIndex: 4,
              width: 118.w,
              widget: Text(viewModel.getConstValue(3, 0)),
            ),
            StackedHeader(
              startIndex: 5,
              endIndex: 5,
              width: 118.w,
              widget: Text(viewModel.getConstValue(4, 0)),
            ),
          ],
          stackedHeaders: [
            StackedHeader(
              startIndex: 0,
              endIndex: 0,
              width: 165.w,
              widget: Text("remarks.financialRatiosAnalysis.auditor".tr()),
            ),
            StackedHeader(
              startIndex: 1,
              endIndex: 1,
              width: 118.w,
              widget: Text(viewModel.getConstValue(0, 1)),
            ),
            StackedHeader(
              startIndex: 2,
              endIndex: 2,
              width: 118.w,
              widget: Text(viewModel.getConstValue(1, 1)),
            ),
            StackedHeader(
              startIndex: 3,
              endIndex: 3,
              width: 118.w,
              widget: Text(viewModel.getConstValue(2, 1)),
            ),
            StackedHeader(
              startIndex: 4,
              endIndex: 4,
              width: 118.w,
              widget: Text(viewModel.getConstValue(3, 1)),
            ),
            StackedHeader(
              startIndex: 5,
              endIndex: 5,
              width: 118.w,
              widget: Text(viewModel.getConstValue(4, 1)),
            ),
          ],
          columns: [
            TableColumn(
              isStacked: true,
              width: 165.w,
              label: Text("remarks.financialRatiosAnalysis.positions".tr()),
            ),
            TableColumn(
              isStacked: true,
              width: 118.w,
              label: Text(viewModel.getHeaderDate(0)),
            ),
            TableColumn(
              isStacked: true,
              width: 118.w,
              label: Text(viewModel.getHeaderDate(1)),
            ),
            TableColumn(
              isStacked: true,
              width: 118.w,
              label: Text(viewModel.getHeaderDate(2)),
            ),
            TableColumn(
              isStacked: true,
              width: 118.w,
              label: Text(viewModel.getHeaderDate(3)),
            ),
            TableColumn(
              isStacked: true,
              width: 118.w,
              label: Text(viewModel.getHeaderDate(4)),
            ),
            if (viewModel.hasActionColumn) const TableColumn(label: SizedBox()),
          ],
          rows: getRows(),
        ),
        const Gap(size: GapSize.small),
        AddTableRows(
            viewModel: viewModel,
            type: StatementType.income,
            text: "remarks.financialRatiosAnalysis.addIncomeStatementAnalysis"
                .tr()),
        const Gap(size: GapSize.small),
        FinancialDropdownWidget(
          width: AppStyle.groupBorrowersTextField,
          label: 'remarks.financialRatiosAnalysis.incomeStatementHealth'.tr(),
          child: CustomDropdown<Reference>(
            semanticLabel:
                'remarks.financialRatiosAnalysis.incomeStatementHealth'.tr(),
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

  List<List<Widget>> getRows() {
    final incomeRefs = viewModel.financialRatioType
            ?.where((row) =>
                row.reference1 == ServerConstants.incomeStatementAnalysis)
            .toList() ??
        [];

    final mergedRows = incomeRefs.map((ref) {
      final apiRow = viewModel.incomeStatementRows.firstWhere(
        (row) => row.id == (ref.reference2 ?? ''),
        orElse: () {
          return IncomeStatementAnalysisRow(
            id: ref.reference2 ?? '',
            incomePositions: ref.name ?? '',
            audited1: '',
            audited2: '',
            audited3: '',
            inhouse: '',
            estimated: '',
            isNew: false,
          );
        },
      );
      apiRow.incomePositions = ref.name ?? '';
      return apiRow;
    }).toList();

    final newRows =
        viewModel.incomeStatementRows.where((row) => row.isNew).toList();

    final allRows = [...mergedRows, ...newRows];

    return List.generate(allRows.length, (index) {
      final row = allRows[index];
      final ratioName = row.incomePositions;

      final cells = <Widget>[];

      // Company Name
      cells.add(
        row.isNew
            ? Center(
                child: CustomTextField(
                  initialValue: ratioName,
                  validator: CustomValidator.twoDecimalNumeric,
                  inputFormatters: [
                    AlphanumericOrTwoDecimalInputFormatter()
                  ], //
                  onChanged: (v) => row.incomePositions = v,
                ),
              )
            : Text(ratioName),
      );

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
                    inputFormatters: [AlphanumericOrTwoDecimalInputFormatter()],
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
                    inputFormatters: [AlphanumericOrTwoDecimalInputFormatter()],
                    onChanged: (v) => row.inhouse = v,
                  )
                : Text(viewModel.rowValue(row.inhouse,
                    isNew: row.isNew, rowIndex: index))),
      );

      // Delete button only for new rows
      if (viewModel.hasActionColumn) {
        cells.add(
          row.isNew
              ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => viewModel.deleteIncomeRow(row.id),
                )
              : const SizedBox.shrink(),
        );
      }

      return cells;
    });
  }
}
