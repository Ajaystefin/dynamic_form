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

/// Widget for displaying facility and security linkage information
/// in a table format.
class FacilitySecurityTableField extends StatelessWidget {
  /// Creates a facility security table field widget.
  const FacilitySecurityTableField({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// View model containing facility-security linkage data and actions.
  final FacilitySecurityLinkageViewModel viewModel;

  /// Current state of the facility-security linkage screen.
  final FacilitySecurityLinkageState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.loaderStatus == LoadingStatus.loading)
          const Center(child: CircularProgressIndicator())
        else
          CustomRawTable(
            key: ValueKey(viewModel.originalSecurities.length),
            rowsPerPage: 10,
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
                (security.securityType?.name?.isNotEmpty ?? false
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
            child: Text(
              (security.allFacilities ?? false)
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
        onSubmitted: (String value) {
          viewModel.onFilter(
            value: value,
            filterType: filterType,
          );
        },
      ),
    );
  }

  /// Returns the column definitions used by the facility-security linkage
  /// table.
  ///
  /// Configures columns for security details, security values, and
  /// facility allocation information.
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
