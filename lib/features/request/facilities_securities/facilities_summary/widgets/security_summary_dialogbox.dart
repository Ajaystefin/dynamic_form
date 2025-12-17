import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:wcas_frontend/core/components/selectable_text.dart';
// import 'package:wcas_frontend/core/constants/constants.dart';
// import 'package:wcas_frontend/core/utils/dialog_helper.dart';
// import 'package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view.dart';
// import 'package:wcas_frontend/models/request/covenant_condtion/covenant.dart';
// import 'package:wcas_frontend/models/request/facility_security/facility.dart';

// import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary_list.dart';

class SecuritySummaryTable extends StatelessWidget {
  final RimGroup? facilityGroup;
  const SecuritySummaryTable(this.facilityGroup, {super.key});
  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      showPagination: true,
      rowsPerPage: 4,
      columns: getColumns(),
      rows: _buildRows(context),
    );
  }

  List<List<Widget>> _buildRows(BuildContext context) {
    // List<List<Widget>> dataRows = <List<Widget>>[];
    // List<FacilityDis> facilities = facilityGroup?.facility;
    // facilityGroup?.facilities ?? [];
  //   (facilities).map((facility) {
  //     dataRows.add([
  //       TextButton(
  //         onPressed: () {
  //           DialogHelper.showCustomDialog(
  //             barrierDismissible: false,
  //             title: "facilities.facilitySummary.linkedFacility".tr(),
  //             content: const SelectFacilitiesDialogView(),
  //             context: context,
  //           );
  //         },
  //         child: Text(
  //           facility.id ?? "",
  //           style: const TextStyle(
  //             decoration: TextDecoration.underline,
  //             decorationColor: AppColors.darkBlue,
  //           ),
  //         ),
  //       ),
  //       // CustomSelectableText(text: facility.facilityDetails ?? ""),
  //       // CustomSelectableText(text: "${facility.presentLimit ?? ""}"),
  //       // CustomSelectableText(text: "${facility.proposedLimit ?? ""}"),
  //     ]);
  //   }).toList();
  //   return dataRows; // [filterTypes, ...dataRows];
  return [];
  }

  List<TableColumn> getColumns() {
    return [
      TableColumn(label: Text("security.securitySummary.securityNumber".tr())),
      TableColumn(label: Text("security.securitySummary.typeOfSecurity".tr())),
      TableColumn(label: Text("security.securitySummary.presentSecurity".tr())),
      TableColumn(
          label: Text("security.securitySummary.proposedSecurity".tr())),
    ];
  }
}
