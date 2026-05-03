import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view.dart";
import "package:wcas_frontend/features/request/facilities_securities/securities_summary/model.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";

class SecuritySummaryTable extends StatelessWidget {
  const SecuritySummaryTable({required this.viewModel, super.key});
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
    final formatter = NumberFormat("#,##0");

    List<RowModel> rowModels = [];
    final RowModel filters = RowModel(
      widget: [
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
      ],
      isFilterRow: true,
    );
    //rowModels.add(filters);
    for (final Security security in viewModel.filteredData) {
      String proposedAmount = "";
      String proposedAmountAlternateCurrency = "";

      if ((security.proposedSecurityAmtCurrency?.name ?? "").toUpperCase() !=
          ServerConstants.aedCurrency) {
        proposedAmount =
            formatter.format((security.aedProposedSecurity ?? 0) / 1000); //
        proposedAmountAlternateCurrency =
            "${security.proposedSecurityAmtCurrency?.name ?? ""} "
            "${formatter.format(
          (security.proposedSecurityAmount ?? 0) / 1000,
        )}";
      } else {
        proposedAmount =
            formatter.format((security.proposedSecurityAmount ?? 0) / 1000);
      }
      rowModels.add(
        RowModel(
          isFilterRow: false,
          widget: [
            TextButton(
              onPressed: () {
                router.go(
                  Routes.createSecurity,
                  extra: {
                    "security": security,
                    "pageMode": viewModel.createSecurityPageMode,
                  },
                );
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
            Text(
              (security.securityCode ?? "") +
                  (security.securityType?.name?.isNotEmpty == true
                      ? " - ${security.securityType?.name}"
                      : ""),
              textAlign: TextAlign.start,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatter
                        .format((security.presentSecurityAmount ?? 0) / 1000),
                    style: AppStyle.highlightedText,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    proposedAmount,
                    style: AppStyle.highlightedText,
                  ),
                  if (proposedAmountAlternateCurrency.isNotEmpty)
                    Text(
                      proposedAmountAlternateCurrency,
                    ),
                ],
              ),
            ),
            Center(
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  DialogHelper.showCustomDialog(
                    width: 700.w,
                    barrierDismissible: false,
                    title: "${"security.securitySummary.dialog".tr()} "
                        "${security.securityNumber ?? ""} - "
                        "${security.securityCode ?? ""}",
                    content: const SelectFacilitiesDialogView(
                      isSecuritySummary: true,
                    ),
                    context: context,
                  );
                },
                icon: const Icon(
                  Icons.link,
                  color: AppColors.buttonBackground,
                ),
              ),
            ),
            (security.isDeletable == false && viewModel.canEdit)
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
          ],
        ),
      );
    }
    rowModels = addFilterForRowModel(
      rows: rowModels,
      filterRow: filters,
      rowsPerPage: 500,
    );
    return rowModels.isEmpty ? [filters] : rowModels;
  }

  List<TableColumn> getColumns() {
    return [
      TableColumn(label: Text("security.securitySummary.securityNumber".tr())),
      TableColumn(
        label: Text("security.securitySummary.typeOfSecurity".tr()),
        forcedWidth: 80.w,
      ),
      TableColumn(label: Text("security.securitySummary.presentSecurity".tr())),
      TableColumn(
        label: Text("security.securitySummary.proposedSecurity".tr()),
      ),
      TableColumn(
        forcedWidth: 50,
        label: Text("security.securitySummary.linkedFacilities".tr()),
      ),
      TableColumn(
        forcedWidth: 50,
        label: Text("security.securitySummary.delete".tr()),
      ),
    ];
  }
}
