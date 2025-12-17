import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/model.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/state.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/security.dart';

class FacilitySecurityTableField extends StatelessWidget {
  const FacilitySecurityTableField(
      {super.key, required this.viewModel, required this.state});

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
                key: ValueKey(viewModel.securities.length),
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
      BuildContext context, FacilitySecurityLinkageViewModel viewModel) {
    List<List<Widget>> rowModels = [];
    final List<Security> securities = viewModel.securities;

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
    for (Security security in securities) {
      rowModels.add(
        [
          TextButton(
            onPressed: () {
            DialogHelper.showCustomDialog(
                      barrierDismissible: false,
                      width: 700.w,
                      title:
                          "security.securityFacilityLinkage.select_facilities"
                              .tr(),
                      content:
                          SelectFacilitiesDialogView(securityItem: security),
                      context: context,
                    );
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
            (security.securityType == null
                    ? "--"
                    : viewModel.securityTypeOptions
                        .firstWhere(
                          (e) => e.id == security.securityType?.id,
                          orElse: () => Reference(id: 0, name: "--"),
                        )
                        .name) ??
                "--",
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              security.presentSecurityAmount.toString(),
              style: const TextStyle(color: AppColors.highlightedTextColor),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              security.proposedSecurityAmount.toString(),
              style: const TextStyle(color: AppColors.highlightedTextColor),
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

    List<List<Widget>> finalRow =
        addFilter(rows: rowModels, filterRow: filterRow, rowsPerPage: 10);
    return finalRow.isEmpty ? [filterRow] : finalRow;

    // if ((securities).isEmpty) {
    //   return [filterRow];
    // }

    // final finalRows = addFilterForRowModel(
    //   rows: rowModels,
    //   filterRow: filterRow,
    //   rowsPerPage: 9,
    // );

    // return finalRows;
  }

  // Widget _filterField({required Function(String) onSubmitted}) {
  //   return CustomTextField(
  //     fillColor: AppColors.white,
  //     filled: true,
  //     counterText: '',
  //     maxLength: 50,
  //     textStyle: const TextStyle(fontSize: 14),
  //     onSubmitted: onSubmitted,
  //   );
  // }

  Widget _filterField(String? text, FilterType filterType) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: CustomTextField(
        initialValue: text,
        semanticLabel: filterType.name,
        maxLength: 50,
        counterText: '',
        onSubmitted: (String value) {
          viewModel.onFilter(value: value, filterType: filterType);
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
