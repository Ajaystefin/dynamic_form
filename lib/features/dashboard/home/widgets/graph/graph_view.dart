import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";
import "package:wcas_frontend/features/dashboard/home/state.dart";
import "package:wcas_frontend/features/dashboard/home/widgets/graph/bar.dart";
import "package:wcas_frontend/features/dashboard/home/widgets/graph/bar_graph_filter.dart";
import "package:wcas_frontend/features/dashboard/home/widgets/graph/pie.dart";

class GraphView extends StatelessWidget {
  const GraphView({
    required this.viewModel,
    required this.state,
    super.key,
    this.isMobile = false,
  });
  final HomeViewModel viewModel;
  final HomeState state;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return BoxLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: headingWidgets(),
          ),
          const Gap(size: GapSize.large), //newly added
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: graphWidget()),
            ],
          ),
          const Gap(size: GapSize.large), //newly added
        ],
      ),
    );
  }

  List<Widget> headingWidgets() {
    return [
      Text(
        "${viewModel.graphTitle} - "
        "${summaryTypeMap[viewModel.selectedSummary]}",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      if (viewModel.visibleGraphType == VisibleGraphType.bar && !isMobile)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(direction: Axis.horizontal),
            Text(
              "dashboard.home.filter.ageing".tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Gap(direction: Axis.horizontal),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.tableBackgroundColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BarGraphFilter(
                    viewModel,
                    selectedGraphFilter: DashboardAgeingType.zeroToSevenDays,
                  ),
                  BarGraphFilter(
                    viewModel,
                    selectedGraphFilter: DashboardAgeingType.eightToFifteenDays,
                  ),
                  BarGraphFilter(
                    viewModel,
                    selectedGraphFilter:
                        DashboardAgeingType.sixteenToThirtyDays,
                  ),
                  BarGraphFilter(
                    viewModel,
                    selectedGraphFilter: DashboardAgeingType.aboveThirtyDays,
                  ),
                ],
              ),
            ),
            const Gap(direction: Axis.horizontal),
          ],
        ),
    ];
  }

  Widget graphWidget() {
    if (state.graphLoader == LoadingStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return viewModel.visibleGraphType == VisibleGraphType.pie
          ? PieChartView(
              viewModel,
              isMobile: isMobile,
            )
          : BarGraph(viewModel);
    }
  }
}
