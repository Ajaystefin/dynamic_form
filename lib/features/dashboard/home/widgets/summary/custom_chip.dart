import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";

/// Displays a selectable summary chip with count and navigation indicator.
class ChipWidget extends StatelessWidget {
  /// Creates a [ChipWidget].
  const ChipWidget({
    required this.viewModel,
    required this.summaryType,
    this.count,
    super.key,
  });

  /// Home dashboard view model used to handle chip selection.
  final HomeViewModel viewModel;

  /// Count displayed inside the chip.
  final int? count;

  /// Summary type represented by this chip.
  final SummaryType summaryType;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async => viewModel.getAgeingSummary(summaryType),
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: viewModel.selectedSummary == summaryType
              ? AppColors.primary
              : AppColors.tableActivatedColor.withValues(alpha: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(direction: Axis.horizontal),
            Text(
              "${viewModel.summaryTypeStringMap[summaryType]} (${count ?? 0})",
              style: TextStyle(
                color: viewModel.selectedSummary != summaryType
                    ? AppColors.black
                    : AppColors.white,
              ),
            ),
            const Gap(direction: Axis.horizontal),
            Icon(
              Icons.arrow_forward_ios,
              size: 10,
              weight: 0.5,
              color: viewModel.selectedSummary != summaryType
                  ? AppColors.black
                  : AppColors.white,
            ),
            const Gap(direction: Axis.horizontal),
          ],
        ),
      ),
    );
  }
}
