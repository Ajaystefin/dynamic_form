import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
// import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart';
import 'package:wcas_frontend/features/request/remarks/guarantor_financials/widgets/add_table_rows.dart';
import 'package:wcas_frontend/features/request/remarks/guarantor_financials/widgets/guarantor_dropdown_widget.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class BalanceSheetAnalysis extends StatelessWidget {
  final GuarantorFinancialViewModel viewModel;
  const BalanceSheetAnalysis({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(size: GapSize.medium),
        CustomSectionHeader(
            title: "remarks.financialRatiosAnalysis.balanceSheetAnalysis".tr()),
        const Gap(size: GapSize.medium),
        CustomRawTable(
            key: UniqueKey(), columns: getColumns(), rows: getRows()),
        const Gap(size: GapSize.small),
        AddTableRows(
          viewModel: viewModel,
          type: StatementType.balance,
          text: "remarks.financialRatiosAnalysis.addbalanceSheetAnalysis".tr(),
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
      ],
    );
  }

  List<TableColumn> getColumns() {
    final showAction = viewModel.hasBalanceNewRows;
    return [
      TableColumn(
          label: Text(
              "remarks.guarantorFinancials.balanceSheetCapitalStructure".tr())),
      TableColumn(label: Text("remarks.financialRatiosAnalysis.dec2017".tr())),
      TableColumn(label: Text("remarks.financialRatiosAnalysis.dec2018".tr())),
      TableColumn(label: Text("remarks.financialRatiosAnalysis.dec2019".tr())),
      TableColumn(label: Text("remarks.financialRatiosAnalysis.mar2020".tr())),
      if (showAction) const TableColumn(label: SizedBox()),
    ];
  }

  List<List<Widget>> getRows() {
    return viewModel.balanceSheetRows.map((row) {
      final cells = <Widget>[];

      // Company Name
      cells.add(
        row.isNew
            ? Center(
                child: CustomTextField(
                  // width: 180.w,
                  initialValue: row.balanceSheet,
                  validator: CustomValidator.requiredField,
                  onChanged: (v) => row.balanceSheet = v,
                ),
              )
            : Text(row.balanceSheet),
      );

      for (var value in [row.audited1, row.audited2, row.audited3]) {
        cells.add(
          Center(
            child: CustomTextField(
              // width: 90.w,
              initialValue: value,
              validator: CustomValidator.requiredField,
              onChanged: (v) {
                if (value == row.audited1) {
                  row.audited1 = v;
                } else if (value == row.audited2) {
                  row.audited2 = v;
                } else {
                  row.audited3 = v;
                }
              },
            ),
          ),
        );
      }

      cells.add(
        Center(
          child: CustomTextField(
            // width: 90.w,
            initialValue: row.inhouse,
            validator: CustomValidator.requiredField,
            onChanged: (v) => row.inhouse = v,
          ),
        ),
      );

      // Optional delete action
      if (viewModel.hasBalanceNewRows) {
        cells.add(
          row.isNew
              ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => viewModel.deleteBalanceRow(row.id),
                )
              : const SizedBox.shrink(),
        );
      }

      return cells;
    }).toList();
  }
}
