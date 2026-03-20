import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/features/dashboard/home/model.dart';
import 'package:wcas_frontend/models/home/documentation_summary.dart';

import 'bar_graph_helper.dart';
import 'bar_graph_legend_item.dart';
import 'bar_graph_row.dart';

/// A widget that displays a bar graph of documentation summaries.
class BarGraph extends StatelessWidget {
  /// The view model containing the business logic and state.
  final HomeViewModel viewModel;

  /// Creates a [BarGraph].
  const BarGraph(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final DocumentationSummary? summary = viewModel.barGraph;
    final List<String> stageNames = BarGraphHelper.stageDisplayOrder(summary, viewModel);

    // Build dynamic bar rows
    final List<String> categoryOrder = BarGraphHelper.categoryOrder(
      summary: summary,
      stageForPriority: viewModel.docStage,
    );

    final List<Widget> barLines = stageNames.map((String stageKey) {
      final DocumentationStage? docStage = summary?.stages[stageKey];
      final String display = BarGraphHelper.prettifyStage(stageKey);
      return BarGraphRow(
        text: display,
        docStage: docStage,
        globalCategoryOrder: categoryOrder,
        viewModel: viewModel,
      );
    }).toList();

    // Legends: use the same global category order; counts from currently selected stage
    final DocumentationStage? selectedStage = viewModel.docStage;
    final List<List<String>> legendRows = BarGraphHelper.chunk<String>(categoryOrder, 4);

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
                children: barLines,
              ),
            ),
          ],
        ),
        const Gap(),
        // Legends (dynamic, rows of 4), values from the selected stage row
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...legendRows.map((List<String> row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((String label) {
                    final int count = selectedStage?.categories[label] ?? 0;
                    return Row(
                      children: [
                        BarGraphLegendItem(
                          helperText: label,
                          count: count,
                          viewModel: viewModel,
                        ),
                        const Gap(direction: Axis.horizontal),
                      ],
                    );
                  }).toList(),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}
