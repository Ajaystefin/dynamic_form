import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view.dart';
import 'package:wcas_frontend/features/request/facilities_securities/securities_summary/model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/models/request/facility_security/security.dart';

class SecuritySummaryTable extends StatelessWidget {
  const SecuritySummaryTable({super.key, required this.viewModel});
  final SecuritiesSummaryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      showPagination: true,
      rowsPerPage: 5,
      autoFitWidth: true,
      isFilterTable: true,
      columns: getColumns(),
      rowModels: _buildRows(context),
    );
  }

  List<RowModel> _buildRows(BuildContext context) {
    final formatter = NumberFormat('#,##0.00'); // For two decimal places

    List<RowModel> rowModels = [];
    RowModel filters = RowModel(widget: [
      SizedBox(
        child: CustomTextField(
          initialValue: viewModel.securityNumber,
          onSubmitted: (String filter) {
            viewModel.onFilter(Filter.securityNumber, value: filter);
          },
        ),
      ),
      SizedBox(
        child: CustomTextField(
          initialValue: viewModel.securityType,
          onSubmitted: (String filter) {
            viewModel.onFilter(Filter.securityType, value: filter);
          },
        ),
      ),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
    ], isFilterRow: true);
    //rowModels.add(filters);
    for (Security security in viewModel.filteredData) {
      rowModels.add(RowModel(isFilterRow: false, widget: [
        TextButton(
          onPressed: () {
            router.go(Routes.createSecurity, extra: security);
          },
          child: Text(
            security.securityNumber ?? "",
            style: const TextStyle(
              fontSize: AppStyle.fontSizeSmall,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.darkBlue,
            ),
            maxLines: 1,
          ),
        ),
        Text(security.securityCode ?? ""),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            formatter.format(security.presentSecurityAmount ?? 0),
            style: AppStyle.highlightedText,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(formatter.format(security.proposedSecurityAmount ?? 0),
              style: AppStyle.highlightedText),
        ),
        Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              DialogHelper.showCustomDialog(
                width: 700.w,
                barrierDismissible: false,
                title:
                    "${"security.securitySummary.dialog".tr()} ${security.securityNumber ?? ""} - ${security.securityCode ?? ""}",
                content:
                    const SelectFacilitiesDialogView(isSecuritySummary: true),
                context: context,
              );
            },
            icon: const Icon(
              Icons.link,
              color: AppColors.buttonBackground,
            ),
          ),
        ),
        security.isDeletable == true
            ? Center(
                child: IconButton(
                  onPressed: () {
                    viewModel.deleteSecurityDetails(security.securityId);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: AppColors.buttonBackground,
                  ),
                ),
              )
            : const SizedBox(),
      ]));
    }
    rowModels = addFilterForRowModel(
        rows: rowModels, filterRow: filters, rowsPerPage: 5);
    return rowModels.isEmpty ? [filters] : rowModels;
  }

  List<TableColumn> getColumns() {
    return [
      TableColumn(label: Text("security.securitySummary.securityNumber".tr())),
      TableColumn(label: Text("security.securitySummary.typeOfSecurity".tr())),
      TableColumn(label: Text("security.securitySummary.presentSecurity".tr())),
      TableColumn(
          label: Text("security.securitySummary.proposedSecurity".tr())),
      TableColumn(
          forcedWidth: 50,
          label: Text("security.securitySummary.linkedFacilities".tr())),
      TableColumn(
          forcedWidth: 50, label: Text("security.securitySummary.delete".tr())),
    ];
  }
}
