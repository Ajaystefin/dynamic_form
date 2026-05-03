import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/widgets/add_table_rows.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/widgets/guarantor_dropdown_widget.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class IncomeStatementAnalysis extends StatelessWidget {
  const IncomeStatementAnalysis({
    required this.viewModel,
    required this.entityId,
    super.key,
  });
  final GuarantorFinancialViewModel viewModel;
  final int entityId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(size: GapSize.medium),
        CustomRawTable(
          key: UniqueKey(),
          autoFitWidth: false,
          topStackedHeaders: [
            StackedHeader(
              startIndex: 0,
              endIndex: 0,
              width: 165.w,
              widget: CustomTextField(
                width: 155.w,
                initialValue: viewModel.longNameFor(entityId) ??
                    viewModel.longName ??
                    "",
                onChanged: (txt) => viewModel.updateLongNameFor(entityId, txt),
                onSubmitted: (_) {},
              ),
            ),
            StackedHeader(
              startIndex: 1,
              endIndex: 1,
              width: 118.w,
              widget: Text(_getConstValueFor(entityId, 0, 0)),
            ),
            StackedHeader(
              startIndex: 2,
              endIndex: 2,
              width: 118.w,
              widget: Text(_getConstValueFor(entityId, 1, 0)),
            ),
            StackedHeader(
              startIndex: 3,
              endIndex: 3,
              width: 118.w,
              widget: Text(_getConstValueFor(entityId, 2, 0)),
            ),
            StackedHeader(
              startIndex: 4,
              endIndex: 4,
              width: 118.w,
              widget: Text(_getConstValueFor(entityId, 3, 0)),
            ),
            StackedHeader(
              startIndex: 5,
              endIndex: 5,
              width: 118.w,
              widget: Text(_getConstValueFor(entityId, 4, 0)),
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
              widget: Text(_getConstValueFor(entityId, 0, 1)),
            ),
            StackedHeader(
              startIndex: 2,
              endIndex: 2,
              width: 118.w,
              widget: Text(_getConstValueFor(entityId, 1, 1)),
            ),
            StackedHeader(
              startIndex: 3,
              endIndex: 3,
              width: 118.w,
              widget: Text(_getConstValueFor(entityId, 2, 1)),
            ),
            StackedHeader(
              startIndex: 4,
              endIndex: 4,
              width: 118.w,
              widget: Text(_getConstValueFor(entityId, 3, 1)),
            ),
            StackedHeader(
              startIndex: 5,
              endIndex: 5,
              width: 118.w,
              widget: Text(_getConstValueFor(entityId, 4, 1)),
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
              label: Text(_getHeaderDateFor(entityId, 0)),
            ),
            TableColumn(
              isStacked: true,
              width: 118.w,
              label: Text(_getHeaderDateFor(entityId, 1)),
            ),
            TableColumn(
              isStacked: true,
              width: 118.w,
              label: Text(_getHeaderDateFor(entityId, 2)),
            ),
            TableColumn(
              isStacked: true,
              width: 118.w,
              label: Text(_getHeaderDateFor(entityId, 3)),
            ),
            TableColumn(
              isStacked: true,
              width: 118.w,
              label: Text(_getHeaderDateFor(entityId, 4)),
            ),
            if (_hasActionColumnFor(entityId))
              const TableColumn(label: SizedBox()),
          ],
          rows: getRows(entityId),
        ),
        const Gap(size: GapSize.small),
        AddTableRows(
          viewModel: viewModel,
          type: StatementType.income,
          text: "remarks.financialRatiosAnalysis.addFinancials".tr(),
          entityId: entityId,
        ),
        const Gap(size: GapSize.small),
        GuarantorDropdownWidget(
          width: AppStyle.groupBorrowersTextField,
          label: "remarks.guarantorFinancials.guarantorhealth".tr(),
          child: CustomDropdown<Reference>(
            semanticLabel: "remarks.guarantorFinancials.guarantorhealth".tr(),
            items: viewModel.guarantorsHealth, // now from reference data
            itemBuilder: (context, item, isDisabled, isSelected) {
              return dropdownItemBuildWidget(
                item.name,
                isListTile: true,
                isSelected: isSelected,
              );
            },
            onSelected: (selectedValue) {
              viewModel.setSelectedHealthFor(
                entityId,
                selectedValue.first,
              ); // NEW
            },
            dropdownBuilder: (context, item) => Text(item?.name ?? ""),
            selectedItems: viewModel.selectedHealthFor(entityId) != null
                ? [viewModel.selectedHealthFor(entityId)]
                : [Reference(name: "Select")],
          ),
        ),
        const Gap(size: GapSize.medium),
      ],
    );
  }

  String _getConstValueFor(int id, int statementIndex, int constIndex) {
    final statements = viewModel.statementsFor(id);
    if (statementIndex < 0 || statementIndex >= statements.length) {
      return viewModel.unavailableText;
    }

    final s = statements[statementIndex];
    final consts = s.statementConsts;
    if (constIndex < 0 || constIndex >= consts.length) {
      return viewModel.unavailableText;
    }
    final raw = consts[constIndex].value.trim();
    if (raw.isEmpty) return viewModel.unavailableText;
    return raw == ServerConstants.unqualified ? "Audited-$raw" : raw;
  }

  String _getHeaderDateFor(int id, int idx) {
    final statements = viewModel.statementsFor(id);
    if (idx < 0 || idx >= statements.length) return viewModel.unavailableText;
    final s = statements[idx];
    return "${DateFormat('MMM-yyyy').format(s.date)} (${s.periods}M)";
  }

  bool _hasActionColumnFor(int id) =>
      viewModel.incomeRowsFor(id).any((r) => r.isNew);

  List<List<Widget>> getRows(int id) {
    return viewModel.incomeRowsFor(id).map((row) {
      final cells = <Widget>[
        row.isNew
            ? Center(
                child: CustomTextField(
                  initialValue: row.incomePositions,
                  validator: CustomValidator.twoDecimalNumeric,
                  maxLength: 100,
                  inputFormatters: [
                    AlphanumericOrTwoDecimalInputFormatter(),
                  ],
                  onChanged: (v) => row.incomePositions = v,
                ),
              )
            : Text(row.incomePositions),
        for (int i = 0; i < 3; i++)
          Center(
            child: row.isNew
                ? CustomTextField(
                    initialValue:
                        [row.audited1, row.audited2, row.audited3][i],
                    validator: CustomValidator.twoDecimalNumeric,
                    inputFormatters: [DecimalInputFormatterTwoDigit()],
                    onChanged: (txt) {
                      if (i == 0) row.audited1 = txt;
                      if (i == 1) row.audited2 = txt;
                      if (i == 2) row.audited3 = txt;
                    },
                  )
                : Text(
                    ([row.audited1, row.audited2, row.audited3][i]
                            .trim()
                            .isEmpty)
                        ? viewModel.unavailableText
                        : [row.audited1, row.audited2, row.audited3][i],
                  ),
          ),
        Center(
          child: row.isNew
              ? CustomTextField(
                  initialValue: row.inhouse,
                  validator: CustomValidator.twoDecimalNumeric,
                  inputFormatters: [DecimalInputFormatterTwoDigit()],
                  onChanged: (txt) => row.inhouse = txt,
                )
              : Text(
                  (row.inhouse.trim().isEmpty)
                      ? viewModel.unavailableText
                      : row.inhouse,
                ),
        ),
        Center(
          child: row.isNew
              ? CustomTextField(
                  initialValue: row.estimated,
                  validator: CustomValidator.twoDecimalNumeric,
                  inputFormatters: [DecimalInputFormatterTwoDigit()],
                  onChanged: (txt) => row.estimated = txt,
                )
              : Text(
                  (row.estimated.trim().isEmpty)
                      ? viewModel.unavailableText
                      : row.estimated,
                ),
        ),
        if (_hasActionColumnFor(id))
          row.isNew
              ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => viewModel.deleteUserAddedIncomeRowForEntity(
                    id,
                    row,
                  ), //  NEW
                )
              : const SizedBox.shrink(),
      ];

      return cells;
    }).toList();
  }
}
