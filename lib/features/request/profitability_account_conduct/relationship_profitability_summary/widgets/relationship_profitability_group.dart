import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/model.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/profitability_data.dart";

/// Relationship profitability group.
class RelationshipProfitabilityGroup extends StatelessWidget {
  /// Creates a relationship profitability group.
  const RelationshipProfitabilityGroup({required this.viewModel, super.key});

  /// Relationship profitability summary view model.
  final RelationshipProfitabilitySummaryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final ProfitabilityData? groupTotalSumData = viewModel.sumProfitabilityData;
    if (groupTotalSumData == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomRawTable(
          key: UniqueKey(),
          showPagination: false,
          rowsPerPage: 5,
          columns: [
            TableColumn(
              width: 120.w,
              label: Text(
                "profitabilityAccountConduct."
                        "relationshipProfitabilitySummary.aedMn"
                    .tr(),
              ),
            ),
            TableColumn(
              width: 100.w,
              label: Text(
                "profitabilityAccountConduct."
                        "relationshipProfitabilitySummary.nii"
                    .tr(),
              ),
            ),
            TableColumn(
              width: 100.w,
              label: Text(
                "profitabilityAccountConduct."
                        "relationshipProfitabilitySummary.nfi"
                    .tr(),
              ),
            ),
            TableColumn(
              width: 100.w,
              label: Text(
                "profitabilityAccountConduct."
                        "relationshipProfitabilitySummary.expectedNetIncome"
                    .tr(),
              ),
            ),
            TableColumn(
              width: 100.w,
              label: Text(
                "profitabilityAccountConduct."
                        "relationshipProfitabilitySummary.avgCASA"
                    .tr(),
              ),
            ),
            TableColumn(
              width: 100.w,
              label: Text(
                "profitabilityAccountConduct."
                        "relationshipProfitabilitySummary.rwa"
                    .tr(),
              ),
            ),
          ],
          rows: [
            // Projected totals
            [
              Text(
                "profitabilityAccountConduct."
                        "relationshipProfitabilitySummary"
                        ".projectedForNext12Month"
                    .tr(),
              ),
              Text(groupTotalSumData.nii ?? "0"),
              Text(groupTotalSumData.nfi ?? "0"),
              Text(groupTotalSumData.expectedNetIncome ?? "0"),
              Text(groupTotalSumData.avgCasa ?? "0"),
              Text(groupTotalSumData.rwa ?? "0"),
            ],
            // Realized totals
            [
              Text(
                "profitabilityAccountConduct."
                        "relationshipProfitabilitySummary.realizedLastYer"
                    .tr(),
              ),
              Text(groupTotalSumData.realizedNii ?? "0"),
              Text(groupTotalSumData.realizedNfi ?? "0"),
              Text(groupTotalSumData.realizedExpectedNetIncome ?? "0"),
              Text(groupTotalSumData.realizedAvgCasa ?? "0"),
              Text(groupTotalSumData.realizedRwa ?? "0"),
            ],
          ],
        ),
        const Gap(),
        LabelWidget(
          label: "profitabilityAccountConduct."
                  "relationshipProfitabilitySummary.comments"
              .tr(),
          labelStyle: AppStyle.tableHeaderStyle,
          child: CustomTextArea(
            key: ValueKey(viewModel.groupComments),
            semanticLabel: "profitabilityAccountConduct."
                    "relationshipProfitabilitySummary.comments"
                .tr(),
            width: double.infinity,
            maxLength: 5000,
            readOnly: true,
            filled: true,
            validator: !viewModel.isFIApplication
                ? CustomValidator.requiredField
                : null,
            initialValue: viewModel.groupComments,
            onSaved: (String? value) {
              viewModel.groupComments = value;
            },
          ),
        ),
      ],
    );
  }
}
