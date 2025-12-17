import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart';
import 'package:wcas_frontend/features/request/remarks/guarantor_financials/widgets/add_table_rows.dart';
import 'package:wcas_frontend/features/request/remarks/guarantor_financials/widgets/guarantor_dropdown_widget.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class IncomeStatementAnalysis extends StatelessWidget {
  final GuarantorFinancialViewModel viewModel;
  const IncomeStatementAnalysis({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final columns = getColumns();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(size: GapSize.medium),
        CustomRawTable(
            key: UniqueKey(),
            columns: columns,
            autoFitWidth: false,
            topStackedHeaders: [
              StackedHeader(
                startIndex: 0,
                endIndex: 0,
                width: 200.w,
                widget: CustomTextField(
                  width: 180.w,
                  initialValue:
                      "remarks.financialRatiosAnalysis.incomePositions".tr(),
                  onSubmitted: (_) {},
                ),
              ),
              StackedHeader(
                startIndex: 1,
                endIndex: 1,
                width: 112.w,
                widget: Text(
                    "remarks.financialRatiosAnalysis.dataNotAvailable".tr()),
              ),
              StackedHeader(
                startIndex: 2,
                endIndex: 2,
                width: 112.w,
                widget: Text(
                    "remarks.financialRatiosAnalysis.dataNotAvailable".tr()),
              ),
              StackedHeader(
                startIndex: 3,
                endIndex: 3,
                width: 112.w,
                widget: Text(
                    "remarks.financialRatiosAnalysis.dataNotAvailable".tr()),
              ),
              StackedHeader(
                startIndex: 4,
                endIndex: 4,
                width: 112.w,
                widget: Text(
                    "remarks.financialRatiosAnalysis.dataNotAvailable".tr()),
              ),
              StackedHeader(
                startIndex: 5,
                endIndex: 5,
                width: 112.w,
                widget: Text(
                    "remarks.financialRatiosAnalysis.dataNotAvailable".tr()),
              ),
            ],
            stackedHeaders: [
              StackedHeader(
                  startIndex: 0,
                  endIndex: 0,
                  width: 200.w,
                  widget: Text(
                    "remarks.financialRatiosAnalysis.auditor".tr(),
                  )),
              StackedHeader(
                  startIndex: 1,
                  endIndex: 1,
                  width: 112.w,
                  widget: Text("remarks.financialRatiosAnalysis.audited".tr())),
              StackedHeader(
                  startIndex: 2,
                  endIndex: 2,
                  width: 112.w,
                  widget: Text("remarks.financialRatiosAnalysis.audited".tr())),
              StackedHeader(
                  startIndex: 3,
                  endIndex: 3,
                  width: 112.w,
                  widget: Text("remarks.financialRatiosAnalysis.audited".tr())),
              StackedHeader(
                  startIndex: 4,
                  endIndex: 4,
                  width: 112.w,
                  widget: Text("remarks.financialRatiosAnalysis.inhouse".tr())),
              StackedHeader(
                  startIndex: 5,
                  endIndex: 5,
                  width: 112.w,
                  widget:
                      Text("remarks.financialRatiosAnalysis.estimated".tr())),
            ],
            rows: getRows()),
        const Gap(size: GapSize.small),
        AddTableRows(
          viewModel: viewModel,
          type: StatementType.income,
          text: "remarks.financialRatiosAnalysis.addFinancials".tr(),
        ),
        const Gap(size: GapSize.small),
        GuarantorDropdownWidget(
          width: AppStyle.groupBorrowersTextField,
          label: "remarks.guarantorFinancials.guarantorhealth".tr(),
          child: CustomDropdown<Reference>(
            semanticLabel: "remarks.guarantorFinancials.guarantorhealth".tr(),
            items: viewModel.balanceSheetHealth,
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
      ],
    );
  }

  List<TableColumn> getColumns() {
    final showAction = viewModel.hasIncomeNewRows;
    return [
      TableColumn(
        isStacked: true,
        width: 200.w,
        label: Text("remarks.financialRatiosAnalysis.positions".tr()),
      ),
      TableColumn(
        isStacked: true,
        width: 112.w,
        label: Text("remarks.financialRatiosAnalysis.dec2017".tr()),
      ),
      TableColumn(
        isStacked: true,
        width: 112.w,
        label: Text("remarks.financialRatiosAnalysis.dec2018".tr()),
      ),
      TableColumn(
        isStacked: true,
        width: 112.w,
        label: Text("remarks.financialRatiosAnalysis.dec2019".tr()),
      ),
      TableColumn(
        isStacked: true,
        width: 112.w,
        label: Text("remarks.financialRatiosAnalysis.mar2020".tr()),
      ),
      TableColumn(
        isStacked: true,
        width: 112.w,
        label: Text("remarks.financialRatiosAnalysis.dec2020".tr()),
      ),
      if (showAction) const TableColumn(label: SizedBox()),
    ];
  }

  List<List<Widget>> getRows() {
    return viewModel.incomeStatementRows.map((row) {
      final cells = <Widget>[];

      // Company Name
      cells.add(
        row.isNew
            ? Center(
                child: CustomTextField(
                  initialValue: row.incomePositions,
                  validator: CustomValidator.twoDecimalNumeric,
                  inputFormatters: [AlphanumericOrTwoDecimalInputFormatter()],
                  onChanged: (v) => row.incomePositions = v,
                ),
              )
            : Text(row.incomePositions),
      );

      // 3 Audited columns
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
                : Text(value),
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
              : Text(row.inhouse),
        ),
      );

      // Estimated
      cells.add(
        Center(
          child: row.isNew
              ? CustomTextField(
                  initialValue: row.estimated,
                  validator: CustomValidator.twoDecimalNumeric,
                  inputFormatters: [AlphanumericOrTwoDecimalInputFormatter()],
                  onChanged: (v) => row.estimated = v,
                )
              : Text(row.estimated),
        ),
      );

      // Optional delete action
      if (viewModel.hasIncomeNewRows) {
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
    }).toList();
  }
}
