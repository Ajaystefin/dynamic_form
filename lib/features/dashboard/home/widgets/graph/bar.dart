import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/dashboard/home/model.dart';
import 'package:wcas_frontend/models/home/documentation_summary.dart';

class BarGraph extends StatelessWidget {
  final HomeViewModel viewModel;
  const BarGraph(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              child: Column(
                spacing: 6,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: viewModel.selectedSummary == SummaryType.creditcontrol
                    ? [
                        barLine(
                            text: "Limit Release Instructions With Maker",
                            docStage: viewModel
                                .barGraph?.limitReleaseInstructionsWithMaker),
                        barLine(
                            text: "Limit Release Instructions With Checker",
                            docStage: viewModel
                                .barGraph?.limitReleaseInstructionsWithChecker),
                        barLine(
                            text: "Limit Release Queries With RO/RM",
                            docStage: viewModel
                                .barGraph?.limitReleaseQueriesWithRORM),
                        barLine(
                            text: "Limit Release Queries With CDU",
                            docStage:
                                viewModel.barGraph?.limitReleaseQueriesWithCDU),
                        barLine(
                            text: "Limit Release Queries With Credit",
                            docStage: viewModel
                                .barGraph?.limitReleaseQueriesWithCredit),
                      ]
                    : [
                        barLine(
                            text: "Fol Draft Under Preparation",
                            docStage:
                                viewModel.barGraph?.folDraftUnderPreparation),
                        barLine(
                            text: "Fol Draft Under RM/RO Review",
                            docStage:
                                viewModel.barGraph?.folDraftUnderRmRoReview),
                        barLine(
                            text: "Fol Draft Under DC Review",
                            docStage:
                                viewModel.barGraph?.folDraftUnderDcReview),
                        barLine(
                            text: "Fol Draft Under Finalization",
                            docStage:
                                viewModel.barGraph?.folDraftUnderFinalization),
                        barLine(
                            text: "Fol Under Client SignOff",
                            docStage:
                                viewModel.barGraph?.folUnderClientSignOff),
                        barLine(
                            text: "Fol Not Required",
                            docStage:
                                viewModel.barGraph?.folNotRequired),
                        barLine(
                            text: "Executed Documents Under Review",
                            docStage: viewModel
                                .barGraph?.executedDocumentsUnderReview),
                        barLine(
                            text: "Discrepancies Advised To RM",
                            docStage:
                                viewModel.barGraph?.discrepanciesAdvisedToRm),
                        barLine(
                            text: "Final Fit To Lend Checks",
                            docStage: viewModel.barGraph?.finalFitToLendChecks),
                        barLine(
                            text: "Final Fit To Lend Checks Review With DC",
                            docStage: viewModel
                                .barGraph?.finalFitToLendChecksReviewWithDc),
                        barLine(
                            text: "Fit To Lend Checks Completed",
                            docStage:
                                viewModel.barGraph?.fitToLendChecksCompleted),
                      ],
              ),
            ),
          ],
        ),
        SizedBox(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(barGraphEnumMap.length, (index) {
              final List<String> values = barGraphEnumMap.values.toList();
              return barHint(
                barGraphHelper: viewModel.selectedBarGraphLegend,
                helperText: values[index],
              );
            }),
          ),
        )
      ],
    );
  }

  Widget barHint(
      {required BarGraphHelper barGraphHelper, required String helperText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => viewModel.onClickBarGraphLegend(barGraphHelper),
        child: Text(helperText,
            style: TextStyle(
                decoration: helperText == barGraphEnumMap[barGraphHelper]
                    ? TextDecoration.underline
                    : TextDecoration.none,
                fontSize: 12.w)),
      ),
    );
  }

  Widget barLine(
      {required String text, required DocumentationStage? docStage}) {
    final int totalCount = docStage?.totalCount ?? 0;
    final List<Map<BarGraphHelper, int>> barGraphHelperMap =
        docStage?.toMapList() ?? [];
    return CustomTooltip(
      message: text,
      child: Row(
        spacing: 6,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 100.w,
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          viewModel.selectedGraphValue == text
              ? SizedBox(
                  height: 20,
                  width: 505,
                  child: Row(
                    spacing: 4,
                    children: List.generate(barGraphHelperMap.length, (index) {
                      final Map<BarGraphHelper, int> currentDocStage =
                          barGraphHelperMap[index];
                      return CustomTooltip(
                        message:
                            "${barGraphEnumMap[currentDocStage.keys.first]} - ${currentDocStage.values.first}",
                        child: InkWell(
                          onTap: () {
                            viewModel.onClickBarGraphLegend(
                                currentDocStage.keys.first);
                          },
                          child: Container(
                            height: 20,
                            width: 35,
                            decoration: BoxDecoration(
                                color: viewModel.selectedBarGraphLegend ==
                                        currentDocStage.keys.first
                                    ? AppColors.limeGreen
                                    : currentDocStage.values.first == 0
                                        ? AppColors.darkGrey
                                        : AppColors.limeGreen
                                            .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(4)),
                            child: Center(
                              child: Text(
                                "${currentDocStage.values.first}",
                                style: const TextStyle(
                                    fontSize: AppStyle.fontSizeSmall),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                )
              : Container(
                  height: 20,
                  width: 505,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: totalCount == 0
                            ? [AppColors.darkGrey, AppColors.darkGrey]
                            : [
                                AppColors.teal,
                                AppColors.teal.withValues(alpha: 0.3),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(4)),
                ),
          InkWell(
            onTap: () => viewModel.onTapGraph(text: text),
            child: Text(
              "$totalCount",
              style: TextStyle(
                  decoration: TextDecoration.underline, fontSize: 12.w),
            ),
          )
        ],
      ),
    );
  }
}
