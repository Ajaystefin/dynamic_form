import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/state.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";

class FacilitySecurityTableField extends StatelessWidget {
  const FacilitySecurityTableField({
    required this.viewModel,
    required this.state,
    super.key,
  });

  final FacilitySecurityLinkageViewModel viewModel;
  final FacilitySecurityLinkageState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        state.loaderStatus == LoadingStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : CustomRawTable(
                key: ValueKey(viewModel.originalSecurities.length),
                rowsPerPage: 10,
                showPagination: true,
                isFilterTable: true,
                columns: getColumns(),
                rows: _buildRows(context, viewModel),
              ),
      ],
    );
  }

  List<List<Widget>> _buildRows(
    BuildContext context,
    FacilitySecurityLinkageViewModel viewModel,
  ) {
    final formatter = NumberFormat("#,##0");
    final List<List<Widget>> rowModels = [];
    final List<Security> securities = viewModel.originalSecurities;

    final filterRow = <Widget>[
      // color: AppColors.tableHeadingColor,
      // isFilterRow: true,
      // widget: [
      _filterField(viewModel.securityNumberFilter, FilterType.securityNumber),
      _filterField(viewModel.securityTypeFilter, FilterType.securityType),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
    ];

    //Data rows
    rowModels.add(filterRow);
    for (final Security security in securities) {
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
        [
          TextButton(
            onPressed: () {
              viewModel.onPressedItemSecurityNo(context, security: security);
            },
            child: Text(
              security.securityNumber.toString(),
              style: const TextStyle(
                fontSize: AppStyle.fontSizeSmall,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.darkBlue,
              ),
            ),
          ),
          Text(
            (security.securityCode ?? "") +
                (security.securityType?.name?.isNotEmpty == true
                    ? " - ${security.securityType?.name}"
                    : ""),
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
          Align(
            alignment: Alignment.center,
            child: Text(
              (security.allFacilities == true)
                  ? "security.securityFacilityLinkage.yes".tr()
                  : "security.securityFacilityLinkage.no".tr(),
            ),
          ),
        ],
      );
    }

    final List<List<Widget>> finalRow =
        addFilter(rows: rowModels, filterRow: filterRow, rowsPerPage: 10);
    return finalRow.isEmpty ? [filterRow] : finalRow;
  }

  Widget _filterField(String? text, FilterType filterType) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: CustomTextField(
        key: ValueKey('${filterType.name}-${text ?? ''}'), // <— forces refresh
        initialValue: text,
        semanticLabel: filterType.name,
        maxLength: 50,
        counterText: "",
        onSubmitted: (String value) {
          viewModel.onFilter(
            value: value,
            filterType: filterType,
            caseInsensitive: true, // user-friendly matching
            useContains: true,
          );
        },
      ),
    );
  }

  List<TableColumn> getColumns() {
    return [
      TableColumn(
        label: Text("security.securityFacilityLinkage.securityNumber".tr()),
      ),
      TableColumn(
        label: Text("security.securityFacilityLinkage.typeOfSecurity".tr()),
      ),
      TableColumn(
        label: Text("security.securityFacilityLinkage.presentSecurity".tr()),
      ),
      TableColumn(
        label: Text("security.securityFacilityLinkage.proposedSecurity".tr()),
      ),
      TableColumn(
        label:
            Text("security.securityFacilityLinkage.allFacilitiesPresent".tr()),
      ),
    ];
  }
}
