import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view.dart';

class AssociatedTable extends StatefulWidget {
  final CovenantEditDialogViewModel viewModel;

  const AssociatedTable({super.key, required this.viewModel});

  @override
  State<AssociatedTable> createState() => _AssociatedTableState();
}

class _AssociatedTableState extends State<AssociatedTable> {
  @override
  Widget build(BuildContext context) {
    final facilityList = widget.viewModel.covenant?.facilityIdList ?? [];

    return Column(
      children: [
        const Gap(size: GapSize.small),
        LabelWidget(
          icon: Icons.edit,
          onIconTap: () {
            DialogHelper.showCustomDialog(
              barrierDismissible: false,
              title: "covenantsConditions.conditionsEditDialog.selectFacilities"
                  .tr(),
              content: const SelectFacilitiesDialogView(),
              context: context,
            );
          },
          label: "covenantsConditions.conditionsEditDialog.associatedFacility"
              .tr(),
          child: CustomRawTable(
            key: UniqueKey(),
            rowHeight: 28,
            columns: getTableColumns(),
            rows: facilityList.map((selectedFacilities) {
              return [
                Text(selectedFacilities.rimNo?.toString() ?? " "),
                Text(selectedFacilities.limitNo ?? " "),
                Text(selectedFacilities.projectName ?? " "),
                Text(selectedFacilities.facilityTypeName ?? " "),
                Text(selectedFacilities.proposedLimit?.toString() ?? ""),
              ];
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<TableColumn> getTableColumns() {
    return [
      "covenantsConditions.conditionsEditDialog.rimNo".tr(),
      "covenantsConditions.conditionsEditDialog.limitNumber".tr(),
      "covenantsConditions.conditionsEditDialog.projectName".tr(),
      "covenantsConditions.conditionsEditDialog.limitDescription".tr(),
      "covenantsConditions.conditionsEditDialog.proposedLimit".tr()
    ]
        .map((label) => TableColumn(label: Text(key: UniqueKey(), label)))
        .toList();
  }
}
