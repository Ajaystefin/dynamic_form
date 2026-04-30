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
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/add_table_rows.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/financial_dropdown_widget.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/income_statement_analysis.dart";

class IncomeStatementAnalysis extends StatelessWidget {
  const IncomeStatementAnalysis({required this.viewModel, super.key});
  final FinancialRatioAnalysisViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(size: GapSize.medium),
        CustomSectionHeader(
          title: "remarks.financialRatiosAnalysis.incomeStatementAnalysis".tr(),
        ),
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
                initialValue: viewModel.longName ?? "",
                onChanged: viewModel.updateLongName, // persist edits
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
          text:
              "remarks.financialRatiosAnalysis.addIncomeStatementAnalysis".tr(),
        ),
        const Gap(size: GapSize.small),
        FinancialDropdownWidget(
          width: AppStyle.groupBorrowersTextField,
          label: "remarks.financialRatiosAnalysis.incomeStatementHealth".tr(),
          child: CustomDropdown<Reference>(
            semanticLabel:
                "remarks.financialRatiosAnalysis.incomeStatementHealth".tr(),
            items: viewModel.incomeHealth,
            itemBuilder: (context, item, isDisabled, isSelected) {
              return dropdownItemBuildWidget(
                item.name,
                isListTile: true,
                isSelected: isSelected,
              );
            },
            onSelected: (selectedValue) {
              viewModel.selectedIncomeHealth = (selectedValue.first);
            },
            dropdownBuilder: (context, item) => Text(item?.name ?? ""),
            selectedItems: viewModel.selectedIncomeHealth != null
                ? [viewModel.selectedIncomeHealth]
                : [Reference(name: "Select")],
          ),
        ),
        const Gap(size: GapSize.medium),
        LabelWidget(
          label: "remarks.financialRatiosAnalysis.rmRemarks".tr(),
          isRequired: false,
          child: SizedBox(
            height: AppStyle.customTextEditorWidget,
            child: UnifiedTextEditor(
              showVideoUpload: false,
              semanticLabel: "remarks.financialRatiosAnalysis.rmRemarks".tr(),
              controller: viewModel.incomeStatementController,
              initialText: viewModel.incomeDescription,
            ),
          ),
        ),
      ],
    );
  }

  List<List<Widget>> getRows() {
    final incomeRefs = viewModel.financialRatioType
            ?.where(
              (row) =>
                  row.reference1 == ServerConstants.incomeStatementAnalysis,
            )
            .toList() ??
        [];

    final mergedRows = incomeRefs.map((ref) {
      final apiRow = viewModel.incomeStatementRows.firstWhere(
        (row) => row.id == (ref.reference2 ?? ""),
        orElse: () {
          return IncomeStatementAnalysisRow(
            id: ref.reference2 ?? "",
            incomePositions: ref.name ?? "",
            audited1: "",
            audited2: "",
            audited3: "",
            inhouse: "",
            estimated: "",
            isNew: false,
          );
        },
      );
      apiRow.incomePositions = ref.name ?? "";
      return apiRow;
    }).toList();

    final newRows =
        viewModel.incomeStatementRows.where((row) => row.isNew).toList();

    final allRows = [...mergedRows, ...newRows];

    String display(FinancialRatioAnalysisViewModel vm, String? s) =>
        (s == null || s.trim().isEmpty) ? vm.unavailableText : s;

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
                    AlphanumericOrTwoDecimalInputFormatter(),
                  ], //
                  maxLength: 100,
                  onChanged: (v) => row.incomePositions = v,
                ),
              )
            : Text(display(viewModel, row.incomePositions)),
      );

      final auditedValues = [row.audited1, row.audited2, row.audited3];
      for (int i = 0; i < auditedValues.length; i++) {
        final v = auditedValues[i];
        cells.add(
          Center(
            child: row.isNew
                ? CustomTextField(
                    initialValue: v,
                    validator: CustomValidator.twoDecimalNumeric,
                    inputFormatters: [DecimalInputFormatterTwoDigit()],
                    onChanged: (txt) {
                      if (i == 0) row.audited1 = txt;
                      if (i == 1) row.audited2 = txt;
                      if (i == 2) row.audited3 = txt;
                    },
                  )
                : Text(display(viewModel, v)),
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
                  inputFormatters: [DecimalInputFormatterTwoDigit()],
                  onChanged: (v) => row.inhouse = v,
                )
              : Text(display(viewModel, row.inhouse)),
        ),
      );

      cells.add(
        Center(
          child: row.isNew
              ? CustomTextField(
                  initialValue: row.estimated,
                  validator: CustomValidator.twoDecimalNumeric,
                  inputFormatters: [DecimalInputFormatterTwoDigit()],
                  onChanged: (v) => row.estimated = v,
                )
              : Text(display(viewModel, row.estimated)),
        ),
      );

      // Delete button only for new rows
      if (viewModel.hasActionColumn) {
        cells.add(
          row.isNew
              ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      viewModel.deleteUserAddedIncomeRow(row), // ← CHANGED
                )
              : const SizedBox.shrink(),
        );
      }

      return cells;
    });
  }
}
