import "package:flutter/material.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";
import "package:wcas_frontend/models/home/documentation_summary.dart";

/// A stateless widget representing a single legend item in the bar graph.
class BarGraphLegendItem extends StatelessWidget {
  /// Creates a [BarGraphLegendItem].
  const BarGraphLegendItem({
    required this.helperText,
    required this.count,
    required this.viewModel,
    super.key,
    this.docStage,
  });

  /// The label text of the legend item.
  final String helperText;

  /// The documentation stage data for the row.
  final DocumentationStage? docStage;

  /// The count associated with this legend item.
  final int count;

  /// The view model containing interaction logic.
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String? selectedLabel = viewModel.selectedBarGraphLegendLabel;

    return SizedBox(
      width: 250,
      child: InkWell(
        onTap: () => viewModel.onClickBarGraphLegend(
          helperText,
          selectedDocStage: docStage,
        ),
        child: Text(
          "► $helperText ($count)",
          style: TextStyle(
            decoration: helperText == selectedLabel
                ? TextDecoration.underline
                : TextDecoration.none,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
