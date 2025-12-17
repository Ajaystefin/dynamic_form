import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/dashboard/home/model.dart';

class ChipWidget extends StatelessWidget {
  final HomeViewModel viewModel;
  final int? count;
  final SummaryType summaryType;
  const ChipWidget(
      {required this.viewModel,
      required this.summaryType,
      this.count,
      super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async => await viewModel.getAgeingSummary(summaryType),
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
                      : AppColors.white),
            ),
            const Gap(direction: Axis.horizontal),
            Icon(Icons.arrow_forward_ios,
                size: 10,
                weight: 0.5,
                color: viewModel.selectedSummary != summaryType
                    ? AppColors.black
                    : AppColors.white),
            const Gap(direction: Axis.horizontal),
          ],
        ),
      ),
    );
  }
}
