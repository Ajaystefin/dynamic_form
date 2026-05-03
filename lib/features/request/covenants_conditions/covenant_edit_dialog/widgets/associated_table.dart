import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";

class AssociatedTable extends StatefulWidget {
  const AssociatedTable({required this.viewModel, super.key, this.row});
  final CovenantEditDialogViewModel viewModel;
  final Covenant? row;

  @override
  State<AssociatedTable> createState() => _AssociatedTableState();
}

class _AssociatedTableState extends State<AssociatedTable> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(size: GapSize.small),
        LabelWidget(
          icon: Icons.edit,
          onIconTap: () async {
            final List<Facility> currentList =
                widget.row?.facilityDetailList ?? widget.viewModel.facilityList;

            final dynamic data = await DialogHelper.showCustomDialog(
              barrierDismissible: false,
              title: "security.securityFacilityLinkage.select_facilities".tr(),
              content: SelectFacilitiesDialogView(
                selectedFacility: currentList,
                preselectedAllFacilities: widget.row == null
                    ? widget.viewModel.selectedAllFacilitiesYesNo
                    : widget.viewModel.getRowAllFacilitiesRef(widget.row!),
                isCovenant: true,
              ),
              context: context,
            );

            if (data != null) {
              if (widget.row != null) {
                widget.viewModel.setRowFacility(widget.row!, data);
              } else {
                await widget.viewModel.setFacility(data);
              }
            }
          },
          label: "covenantsConditions.conditionsEditDialog.associatedFacility"
              .tr(),
          child: CustomRawTable(
            key: UniqueKey(),
            rowHeight: 28,
            columns: getTableColumns(),
            rows: ((widget.row?.facilityDetailList ??
                        widget.viewModel.facilityList)
                    .isEmpty)
                ? emptyRow()
                : List.generate(
                    (widget.row?.facilityDetailList ??
                            widget.viewModel.facilityList)
                        .length, (index) {
                    final List<Facility> list =
                        widget.row?.facilityDetailList ??
                            widget.viewModel.facilityList;
                    return [
                      Text("${list[index].rimNo}"),
                      Text(list[index].limitNumber ?? " "),
                      Text(list[index].limitLabel ?? " "),
                      Text(list[index].limitDescription ?? " "),
                      Text("${list[index].proposedLimit}"),
                    ];
                  }),
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
      "covenantsConditions.conditionsEditDialog.proposedLimit".tr(),
    ]
        .map((label) => TableColumn(label: Text(key: UniqueKey(), label)))
        .toList();
  }

  List<List<Widget>> emptyRow() {
    return [
      [
        const Text(
          "  ",
        ),
        const Text(
          "  ",
        ),
        const Text(
          "  ",
        ),
        const Text(
          "  ",
        ),
        const Text(
          "  ",
        ),
      ]
    ];
  }
}
