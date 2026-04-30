import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/icon_button.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/covenants_conditions/conditions_summary/model.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant_condition.dart";

class ConditionsTableWidget extends StatelessWidget {
  const ConditionsTableWidget({required this.viewModel, super.key});
  final ConditionsSummaryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      rowsPerPage: viewModel.rowsPerPage,
      showPagination: true,
      autoFitWidth: true,
      columns: _getConditionsColumns(),
      rows: _getConditionsRows(context),
    );
  }

  List<TableColumn> _getConditionsColumns() {
    final List<TableColumn> columnNames = [
      TableColumn(
        forcedWidth: 70.w,
        label: Text("covenantsConditions.covenantsSummary.rimNumber".tr()),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: Text(
          "covenantsConditions.conditionsSummary.conditionsNumber".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: Text(
          "covenantsConditions.conditionsSummary.conditionsType".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 170.w,
        label: Text("covenantsConditions.covenantsSummary.description".tr()),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: Text("covenantsConditions.conditionsSummary.targetDate".tr()),
      ),
      TableColumn(
        forcedWidth: 100.w,
        label: Text(
          "covenantsConditions.covenantsSummary.generalSpecific".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 50.w,
        label: Text("covenantsConditions.covenantsSummary.status".tr()),
      ),
      TableColumn(
        forcedWidth: 50.w,
        label: Text("covenantsConditions.covenantsSummary.action".tr()),
      ),
      TableColumn(forcedWidth: 50.w, label: Text("common.delete".tr())),
    ];

    return columnNames;
  }

  List<List<Widget>> _getConditionsRows(BuildContext context) {
    if (viewModel.conditions.isEmpty) return [];
    return List.generate(viewModel.conditions.length, (index) {
      final CovenantCondition condition = viewModel.conditions[index];
      return [
        Text(condition.rimNo?.toString() ?? ""),
        Text(condition.covenantConditionNo?.toString() ?? ""),
        Text(
          viewModel.getReferenceName(
            viewModel.referenceData[ReferenceDataKeys.covenantConditionType],
            condition.conditionType,
          ),
          textAlign: TextAlign.left,
          // maxLines: 1,
        ),
        CustomTooltip(
          isRichMessage: true,
          message: condition.description?.toString() ?? "",
          child: InkWell(
            onTap: () {
              viewModel.showConditionCreate(context, condition: condition);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                condition.description?.toString() ?? "",
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
        Text(condition.targetDate ?? " "),
        Text(
          viewModel.getReferenceName(
            viewModel.referenceData[ReferenceDataKeys.conditionGeneral],
            condition.isGeneric == true
                ? ServerConstants.conditionGeneralId
                : ServerConstants.conditionSpecificId,
          ),
        ),
        Text(
          viewModel.getReferenceName(
            viewModel.referenceData[ReferenceDataKeys.conditionStatus],
            condition.status,
          ),
        ),
        Text(
          viewModel.getReferenceName(
            viewModel.referenceData[ReferenceDataKeys.conditionAction],
            condition.action,
          ),
        ),
        dynamicIcon(
          icon: Icons.delete,
          iconSize: AppStyle.fontSizeLarge,
          iconColor: AppColors.buttonBackground,
          borderColor: AppColors.textFieldBorder,
          padding: 4,
          borderRadius: 4,
          onTap: !viewModel.canEdit
              ? null
              : () async {
                  await viewModel.onDeleteCondition(condition, index);
                },
        ),
      ];
    });
  }
}
