import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/model.dart';

class FacilitiesColumnHeaderBuilder {
  final SelectFacilitiesDialogViewModel viewModel;

  FacilitiesColumnHeaderBuilder(this.viewModel);

  List<TableColumn> createColumns() {
    return <TableColumn>[
      if (viewModel.showCheckboxColumn)
        TableColumn(
          forcedWidth: 20,
          label: Checkbox(
            visualDensity: VisualDensity.compact,
            value: viewModel.isSelectAll,
            onChanged: (v) {
              viewModel.toggleSelectAll(v);
            },
          ),
        ),
      TableColumn(
          forcedWidth: 100.w,
          label: Text("covenantsConditions.selectFacilityDialog.rimNo".tr())),
      TableColumn(
          forcedWidth: 100.w,
          label: Text(
              "covenantsConditions.selectFacilityDialog.limitNumber".tr())),
      TableColumn(
          forcedWidth: 100.w,
          label: Text(
              "covenantsConditions.selectFacilityDialog.projectName".tr())),
      TableColumn(
        forcedWidth: 100.w,
        label: SizedBox(
          child: Text(
            "covenantsConditions.selectFacilityDialog.limitDescription".tr(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      TableColumn(
        forcedWidth: 100.w,
        label: Text(
          "covenantsConditions.selectFacilityDialog.proposedLimit".tr(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];
  }
}
