import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/components/icon_button.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/view.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenants_summary/model.dart';
import 'package:wcas_frontend/models/request/covenant_condtion/covenant.dart';

class CovenantTableWidget extends StatelessWidget {
  final CovenantsSummaryViewModel viewModel;

  const CovenantTableWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      rowsPerPage: viewModel.rowsPerPage,
      showPagination: true,
      autoFitWidth: true,
      columnSpacing: 70.w,
      columnHeaderHeight: 50.w,
      columns: _getCovenantColumns(),
      rows: _getCovenantRows(context),
    );
  }

  List<TableColumn> _getCovenantColumns() {
    List<TableColumn> columnNames = [
      TableColumn(
          forcedWidth: 60.w,
          label: Text("covenantsConditions.covenantsSummary.rimNumber".tr())),
      TableColumn(
          forcedWidth: 50.w,
          label: Text(
              "covenantsConditions.covenantsSummary.covenantsNumber".tr())),
      TableColumn(
          forcedWidth: 80.w,
          label:
              Text("covenantsConditions.covenantsSummary.covenantsTypes".tr())),
      TableColumn(
          forcedWidth: 140.w,
          label: Text("covenantsConditions.covenantsSummary.description".tr())),
      TableColumn(
          forcedWidth: 60.w,
          label: Text("covenantsConditions.covenantsSummary.frequency".tr())),
      TableColumn(
          forcedWidth: 60.w,
          label: Text(
              "covenantsConditions.covenantsSummary.nextMonitoringDate".tr())),
      TableColumn(
          forcedWidth: 50.w,
          label: Text(
              "covenantsConditions.covenantsSummary.generalSpecific".tr())),
      TableColumn(
          forcedWidth: 50.w,
          label: Text(
              "covenantsConditions.covenantsSummary.covenantsToBeTestedOn"
                  .tr())),
      TableColumn(
          forcedWidth: 40.w,
          label: Text("covenantsConditions.covenantsSummary.status".tr())),
      TableColumn(
          forcedWidth: 40.w,
          label: Text("covenantsConditions.covenantsSummary.action".tr())),
      TableColumn(forcedWidth: 40.w, label: Text("common.delete".tr()))
    ];

    return columnNames;
  }

  List<List<Widget>> _getCovenantRows(BuildContext context) {
    if (viewModel.covenant.isEmpty) return [];
    return List.generate(viewModel.covenant.length, (index) {
      final Covenant covenant = viewModel.covenant[index];

      final borrower = (covenant.borrowers?.isNotEmpty ?? false)
          ? covenant.borrowers!.first
          : null;

      final rimLabel = borrower?.customerRimNo?.toString() ?? "";

      return [
        Text(covenant.rimNo?.toString() ?? ""),
        Text(covenant.covenantConditionNo?.toString() ?? ""),
        Text(viewModel.getReferenceName(
            viewModel.covenantType, covenant.covenantType)),
        CustomTooltip(
          message: covenant.description?.toString() ?? "",
          child: InkWell(
            onTap: viewModel.isReadOnly
                ? null
                : () {
                    DialogHelper.showCustomDialog(
                      context: context,
                      width: Scale.scaleHorizontally(800),
                      title:
                          "covenantsConditions.covenantEditDialog.covenantInfo"
                              .tr(),
                      content: CovenantEditDialogView(
                          isNew: false, covenant: covenant),
                    ).then((_) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        viewModel.fetchCovenants();
                      });
                    });
                  },
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                covenant.description?.toString() ?? "",
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.highlightedTextColor,
                  color: AppColors.highlightedTextColor,
                ),
              ),
            ),
          ),
        ),
        Text(viewModel.getReferenceName(
            viewModel.frequency, covenant.frequency)),
        Text(formatDateForUI(covenant.nextMonitorDate?.toString() ?? "")),
        Text(viewModel.getGeneralSpecificName(
          viewModel.covenantGeneralSpecific,
          covenant.isGeneric == true ? 13851 : 13852,
        )),
        covenant.covenantType == 11144
            ? Text(covenant.creditLensId.toString())
            : Text(rimLabel),
        Text(viewModel.getReferenceName(viewModel.status, covenant.status)),
        Text(viewModel.getReferenceName(viewModel.action, covenant.action)),
        dynamicIcon(
          icon: Icons.delete,
          iconSize: 16,
          iconColor: AppColors.buttonBackground,
          borderColor: AppColors.textFieldBorder,
          padding: 4,
          borderRadius: 4,
          onTap: viewModel.isReadOnly
              ? null
              : () async {
                  await viewModel.onDeleteCovenant(covenant, index);
                },
        ),
      ];
    });
  }

  String formatDateForUI(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr); // expects yyyy-MM-dd
      return "${date.day.toString().padLeft(2, '0')}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.year.toString().padLeft(4, '0')}";
    } catch (_) {
      return dateStr; // fallback to original if parsing fails
    }
  }
}
