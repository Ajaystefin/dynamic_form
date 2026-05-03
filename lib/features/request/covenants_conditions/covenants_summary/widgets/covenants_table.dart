import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/icon_button.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/view.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenants_summary/model.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";
import "package:wcas_frontend/models/request/customer.dart";

class CovenantTableWidget extends StatelessWidget {
  const CovenantTableWidget({required this.viewModel, super.key});
  final CovenantsSummaryViewModel viewModel;

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
    final List<TableColumn> columnNames = [
      TableColumn(
        forcedWidth: 60.w,
        label: Text("covenantsConditions.covenantsSummary.rimNumber".tr()),
      ),
      TableColumn(
        forcedWidth: 50.w,
        label: Text(
          "covenantsConditions.covenantsSummary.covenantsNumber".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 80.w,
        label: Text("covenantsConditions.covenantsSummary.covenantsTypes".tr()),
      ),
      TableColumn(
        forcedWidth: 140.w,
        label: Text("covenantsConditions.covenantsSummary.description".tr()),
      ),
      TableColumn(
        forcedWidth: 60.w,
        label: Text("covenantsConditions.covenantsSummary.frequency".tr()),
      ),
      TableColumn(
        forcedWidth: 60.w,
        label: Text(
          "covenantsConditions.covenantsSummary.nextMonitoringDate".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 50.w,
        label: Text(
          "covenantsConditions.covenantsSummary.generalSpecific".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 50.w,
        label: Text(
          "covenantsConditions.covenantsSummary.covenantsToBeTestedOn".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 40.w,
        label: Text("covenantsConditions.covenantsSummary.status".tr()),
      ),
      TableColumn(
        forcedWidth: 40.w,
        label: Text("covenantsConditions.covenantsSummary.action".tr()),
      ),
      TableColumn(forcedWidth: 40.w, label: Text("common.delete".tr())),
    ];

    return columnNames;
  }

  List<List<Widget>> _getCovenantRows(BuildContext context) {
    if (viewModel.covenant.isEmpty) return [];
    return List.generate(viewModel.covenant.length, (index) {
      final Covenant covenant = viewModel.covenant[index];

      // Primary borrower derived from the model (if present)
      final Customer? primaryBorrower =
          (covenant.borrowers?.isNotEmpty ?? false)
              ? covenant.borrowers!.first
              : null;

      // Common labels used in the row
      final String rimDisplayText =
          primaryBorrower?.customerRimNo?.toString() ?? "";

      // Decide which RIM we will display/inspect for special-case logic
      final int? displayRimNo =
          primaryBorrower?.customerRimNo ?? covenant.rimNo;

      // Treat "9999" as a special dummy rim number coming from the API
      // (alias the server constant into a local, intention-revealing name)
      const int rimWithName = ServerConstants.covenantToBeTestedName;
      final bool isRimWithName =
          displayRimNo == ServerConstants.covenantToBeTestedName;

      // If dummy rim, try to get the name from borrowerIdList.rimNo==9999; else fall back to existing borrower/customer name
      String? testedOnName;
      try {
        // Prefer the API's borrowerIdList structure for (rimNo==9999 ->
        // custName)
        // Adjust the typing if your model already has a typed list.
        final List<dynamic>? borrowerIdList =
            covenant.borrowers as List<dynamic>?;
        final Map<String, dynamic>? dummyEntry =
            borrowerIdList?.cast<Map<String, dynamic>>().firstWhere(
                  (m) =>
                      (m["rimNo"] is num
                          ? (m["rimNo"] as num).toInt()
                          : m["rimNo"]) ==
                      rimWithName,
                  orElse: () => const <String, dynamic>{},
                );

        final String? apiCustName =
            (dummyEntry?["custName"] as String?)?.trim();

        testedOnName = (apiCustName != null && apiCustName.isNotEmpty)
            ? apiCustName
            : primaryBorrower?.customerName;
      } catch (_) {
        // Ignore parsing errors, we’ll rely on the safe fallbacks below.
        testedOnName = primaryBorrower?.customerName;
      }

      final bool isFinancialCovenant = covenant.covenantType ==
          ServerConstants.covenantTypeId[CovenantType.financial];

      final String testedOnDisplay = isFinancialCovenant
          ? (covenant.creditLensId?.toString() ?? "")
          : (isRimWithName
              ? (testedOnName?.isNotEmpty == true
                  ? testedOnName!
                  : rimWithName.toString())
              : rimDisplayText);

      return [
        Text(covenant.rimNo?.toString() ?? ""),
        Text(covenant.covenantConditionNo?.toString() ?? ""),
        Text(
          viewModel.getReferenceName(
            viewModel.covenantType,
            covenant.covenantType,
          ),
        ),
        CustomTooltip(
          message: covenant.description?.toString() ?? "",
          child: InkWell(
            onTap: () {
              DialogHelper.showCustomDialog(
                context: context,
                width: Scale.scaleHorizontally(800),
                title:
                    "covenantsConditions.covenantEditDialog.covenantInfo".tr(),
                content: CovenantEditDialogView(
                  isNew: false,
                  overridePageMode: viewModel.covenantPageMode,
                  covenant: covenant,
                ),
              ).then((_) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  viewModel.fetchCovenants();
                });
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
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
        Text(
          viewModel.getReferenceName(
            viewModel.frequency,
            covenant.frequency,
          ),
        ),
        Text(formatDateForUI(covenant.nextMonitorDate?.toString() ?? "")),
        Text(
          viewModel.getGeneralSpecificName(
            viewModel.covenantGeneralSpecific,
            covenant.isGeneric == true
                ? ServerConstants.covenantGeneralId
                : ServerConstants.covenantSpecificId,
          ),
        ),
        Text(testedOnDisplay),
        Text(covenant.status!),
        Text(viewModel.getReferenceName(viewModel.action, covenant.action)),
        dynamicIcon(
          icon: Icons.delete,
          iconSize: 16,
          iconColor: AppColors.buttonBackground,
          borderColor: AppColors.textFieldBorder,
          padding: 4,
          borderRadius: 4,
          onTap: !viewModel.canEdit
              ? null
              : () async {
                  await viewModel.onDeleteCovenant(covenant, index);
                },
        ),
      ];
    });
  }

  String formatDateForUI(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      final DateTime date = DateTime.parse(dateStr); // expects yyyy-MM-dd
      return "${date.day.toString().padLeft(2, '0')}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.year.toString().padLeft(4, '0')}";
    } catch (_) {
      return dateStr; // fallback to original if parsing fails
    }
  }
}
