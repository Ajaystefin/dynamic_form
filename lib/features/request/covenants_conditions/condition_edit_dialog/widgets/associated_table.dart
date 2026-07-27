import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view.dart";

/// Associated facility table for the condition edit dialog.
class AssociatedTable extends StatefulWidget {
  /// Creates an associated table.
  const AssociatedTable({required this.viewModel, super.key});

  /// Condition edit dialog view model.
  final ConditionEditDialogViewModel viewModel;

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
    return LabelWidget(
      icon: Icons.edit,
      onIconTap: () async {
        final data = await DialogHelper.showCustomDialog(
          barrierDismissible: false,
          title: "security.securityFacilityLinkage.select_facilities".tr(),
          content: SelectFacilitiesDialogView(
            selectedFacility: widget.viewModel.facilityList,
          ),
          context: context,
        );

        if (data != null) {
          await widget.viewModel.setFacility(data);
        }
      },
      label: "covenantsConditions.conditionsEditDialog.associatedFacility".tr(),
      child: CustomRawTable(
        rowsPerPage: 5,
        key: UniqueKey(),
        columns: getTableColumns(),
        rows: widget.viewModel.facilityList.isEmpty
            ? emptyRow()
            : List.generate(widget.viewModel.facilityList.length, (index) {
                return [
                  Text(
                    "${widget.viewModel.facilityList[index].rimNo}",
                  ),
                  Text(
                    widget.viewModel.facilityList[index].limitNumber ?? " ",
                  ),
                  Text(
                    widget.viewModel.facilityList[index].limitLabel ?? " ",
                  ),
                  Text(
                    widget.viewModel.facilityList[index].limitDescription ??
                        " ",
                  ),
                  Text(
                    "${widget.viewModel.facilityList[index].proposedLimit}",
                  ),
                ];
              }),
      ),
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
