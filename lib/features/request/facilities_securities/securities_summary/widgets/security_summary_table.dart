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

/// Widget for displaying security summary information in a table format.
class SecuritySummaryTable extends StatelessWidget {
  /// Creates a security summary table widget.
  const SecuritySummaryTable({
    required this.viewModel,
    super.key,
  });

  /// View model containing security summary data and actions.
  final SecuritiesSummaryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      rowsPerPage: 5,
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
              onPressed: security.securityId != null
                  ? () {
                      router.go(
                        Routes.createSecurity,
                        extra: {
                          "security": security,
                          "pageMode": viewModel.createSecurityPageMode,
                        },
                      );
                    }
                  : null,
              child: Text(
                security.securityNumber ?? "",
                style: security.securityId != null
                    ? const TextStyle(
                        fontSize: AppStyle.fontSizeSmall,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.darkBlue,
                      )
                    : const TextStyle(
                        fontSize: AppStyle.fontSizeSmall,
                      ),
                maxLines: 1,
              ),
            ),
            Text(
              viewModel.securityTypeReferenceName(security),
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
            if ((security.isDeletable ?? false) &&
                viewModel.canCreateOrDeleteSecurity)
              Center(
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
            else
              const SizedBox(),
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

  /// Returns the column definitions used by the security summary table.
  ///
  /// Configures columns for security details, security values,
  /// linked facilities, and available actions.
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
