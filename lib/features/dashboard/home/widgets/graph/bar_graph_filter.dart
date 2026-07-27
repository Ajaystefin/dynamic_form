import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";

/// Filter widget used to select a dashboard bar graph ageing type.
class BarGraphFilter extends StatelessWidget {
  /// Creates a [BarGraphFilter].
  const BarGraphFilter(
    this.viewModel, {
    required this.selectedGraphFilter,
    super.key,
  });

  /// View model used to manage dashboard graph filter selection.
  final HomeViewModel viewModel;

  /// Ageing filter represented by this widget.
  final DashboardAgeingType selectedGraphFilter;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = viewModel.isAgeingSelected &&
        viewModel.selectedGraphFilter == selectedGraphFilter;

    return InkWell(
      onTap: () => viewModel.onSelectGraphFilter(selectedGraphFilter),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: isSelected ? BorderRadius.circular(8) : null,
          color: isSelected ? AppColors.primary : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppStyle.spacing),
          child: Text(
            dashboardFilterMapToUI[selectedGraphFilter] ?? "",
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
