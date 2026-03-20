import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/dashboard/home/model.dart';
import 'package:wcas_frontend/models/home/documentation_summary.dart';

/// A stateless widget representing a single row (stage) in the bar graph.
class BarGraphRow extends StatelessWidget {
  /// The display text for the row.
  final String text;

  /// The documentation stage data for the row.
  final DocumentationStage? docStage;

  /// The globally ordered list of categories to align segments consistently.
  final List<String> globalCategoryOrder;

  /// The view model containing interaction logic.
  final HomeViewModel viewModel;

  /// Creates a [BarGraphRow].
  const BarGraphRow({
    super.key,
    required this.text,
    required this.docStage,
    required this.globalCategoryOrder,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final int totalCount = docStage?.totalCount ?? 0;
    final Map<String, int> categories = docStage?.categories ?? const {};
    final List<String> orderedLabels = globalCategoryOrder;

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
                  child: Row(
                    spacing: 4,
                    children: List.generate(orderedLabels.length, (int index) {
                      final String label = orderedLabels[index];
                      final int value = categories[label] ?? 0;

                      return CustomTooltip(
                        message: "$label - $value",
                        child: InkWell(
                          onTap: () {
                            viewModel.onClickBarGraphLegend(
                              label,
                              selectedDocStage: docStage,
                            );
                          },
                          child: Container(
                            height: 20,
                            width: 35,
                            decoration: BoxDecoration(
                              color: viewModel.selectedBarGraphLegendLabel == label
                                  ? AppColors.limeGreen
                                  : value == 0
                                      ? AppColors.darkGrey
                                      : AppColors.limeGreen.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                "$value",
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
                  width: 464,
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
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
          InkWell(
            onTap: () => viewModel.onTapGraph(text: text),
            child: Text(
              "$totalCount",
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: 12.w,
              ),
            ),
          )
        ],
      ),
    );
  }
}
