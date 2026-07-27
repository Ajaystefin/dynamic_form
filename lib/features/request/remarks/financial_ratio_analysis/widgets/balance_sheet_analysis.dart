import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/add_table_rows.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/financial_dropdown_widget.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/financial_formattable_text.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/balance_sheet_analysis.dart";

/// Displays the Balance Sheet Analysis section.
class BalanceSheetAnalysis extends StatelessWidget {
  /// Creates a Balance Sheet Analysis widget.
  const BalanceSheetAnalysis({
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
          title: "remarks.financialRatiosAnalysis.balanceSheetAnalysis".tr(),
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
          type: StatementType.balance,
          text: "remarks.financialRatiosAnalysis.addbalanceSheetAnalysis".tr(),
        ),
        const Gap(size: GapSize.small),
        FinancialDropdownWidget(
          width: AppStyle.groupBorrowersTextField,
          label: "remarks.financialRatiosAnalysis.balanceSheetHealth".tr(),
          child: CustomDropdown<Reference>(
            semanticLabel:
                "remarks.financialRatiosAnalysis.balanceSheetHealth".tr(),
            items: viewModel.balanceHealth,
            itemBuilder: (context, item, {isDisabled, isSelected}) {
              return dropdownItemBuildWidget(
                item.name,
                isSelected: isSelected ?? false,
              );
            },
            onSelected: (selectedValue) {
              viewModel.selectedBalanceSheetHealth = selectedValue.first;
            },
            dropdownBuilder: (context, item) => Text(item?.name ?? ""),
            selectedItems: viewModel.selectedBalanceSheetHealth != null
                ? [viewModel.selectedBalanceSheetHealth]
                : [Reference(name: "Select")],
          ),
        ),
        const Gap(),
        FinancialFormattableText(
          key: UniqueKey(),
          label: "remarks.financialRatiosAnalysis.rmRemarks".tr(),
          viewModel: viewModel,
          isRequired: false,
        ),
      ],
    );
  }

  /// Builds the table columns for the Balance Sheet Analysis table.
  List<TableColumn> getColumns() {
    final showAction = viewModel.hasActionColumnBalanceSheet;
    return [
      TableColumn(
        label: Text(
          "remarks.financialRatiosAnalysis.balanceSheetCapitalStructure".tr(),
        ),
      ),
      TableColumn(label: Text(viewModel.getHeaderDate(0))),
      TableColumn(label: Text(viewModel.getHeaderDate(1))),
      TableColumn(label: Text(viewModel.getHeaderDate(2))),
      TableColumn(label: Text(viewModel.getHeaderDate(3))),
      TableColumn(label: Text(viewModel.getHeaderDate(4))),
      if (showAction) const TableColumn(label: SizedBox()),
    ];
  }

  /// Builds the table rows for the Balance Sheet Analysis table.
  List<List<Widget>> getRows() {
    final balanceRefs = viewModel.financialRatioType
            ?.where(
              (row) => row.reference1 == ServerConstants.balanceSheetAnalysis,
            )
            .toList() ??
        [];

    final mergedRows = balanceRefs.map((ref) {
      final apiRow = viewModel.balanceSheetRows.firstWhere(
        (row) => row.id == (ref.reference2 ?? ""),
        orElse: () => BalanceSheetAnalysisRow(
          id: ref.reference2 ?? "",
          balanceSheet: ref.name ?? "",
        ),
      )..balanceSheet = ref.name ?? "";
      return apiRow;
    }).toList();

    final newRows =
        viewModel.balanceSheetRows.where((row) => row.isNew).toList();

    final allRows = [...mergedRows, ...newRows];

    return List.generate(allRows.length, (index) {
      final row = allRows[index];
      final label = row.balanceSheet;
      final List<String> auditedValues = [
        row.audited1,
        row.audited2,
        row.audited3,
      ];

      final cells = <Widget>[
        if (row.isNew)
          Center(
            child: CustomTextField(
              initialValue: label,
              validator: CustomValidator.twoDecimalNumeric,
              inputFormatters: [AlphanumericOrTwoDecimalInputFormatter()],
              maxLength: 100,
              onChanged: (v) => row.balanceSheet = v,
            ),
          )
        else
          Text(label),
        for (int i = 0; i < auditedValues.length; i++)
          Center(
            child: row.isNew
                ? CustomTextField(
                    initialValue: auditedValues[i],
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
                      auditedValues[i],
                      isNew: row.isNew,
                      rowIndex: index,
                    ),
                  ),
          ),
        Center(
          child: row.isNew
              ? CustomTextField(
                  initialValue: row.inhouse,
                  validator: CustomValidator.twoDecimalNumeric,
                  inputFormatters: [DecimalInputFormatterTwoDigit()],
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
        Center(
          child: row.isNew
              ? CustomTextField(
                  initialValue: row.estimated,
                  validator: CustomValidator.twoDecimalNumeric,
                  inputFormatters: [DecimalInputFormatterTwoDigit()],
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
        if (viewModel.hasActionColumnBalanceSheet)
          row.isNew
              ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => viewModel.deleteUserAddedBalanceRow(row),
                )
              : const SizedBox.shrink(),
      ];

      return cells;
    });
  }
}
