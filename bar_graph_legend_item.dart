import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/dashboard/home/model.dart';

/// A stateless widget representing a single legend item in the bar graph.
class BarGraphLegendItem extends StatelessWidget {
  /// The label text of the legend item.
  final String helperText;

  /// The count associated with this legend item.
  final int count;

  /// The view model containing interaction logic.
  final HomeViewModel viewModel;

  /// Creates a [BarGraphLegendItem].
  const BarGraphLegendItem({
    super.key,
    required this.helperText,
    required this.count,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final String? selectedLabel = viewModel.selectedBarGraphLegendLabel;
    
    return SizedBox(
      width: 250,
      child: InkWell(
        onTap: () => viewModel.onClickBarGraphLegend(helperText),
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
