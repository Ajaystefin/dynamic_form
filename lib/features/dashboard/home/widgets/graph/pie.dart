import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/dashboard/home/model.dart';

class PieChartView extends StatefulWidget {
  final HomeViewModel viewModel;
  final bool isMobile;
  const PieChartView(this.viewModel, {this.isMobile = false, super.key});

  @override
  State<PieChartView> createState() => _PieChartViewState();
}

class _PieChartViewState extends State<PieChartView> {
  @override
  Widget build(BuildContext context) {
    return widget.isMobile
        ? Column(
            children: graphWidgets(isMobile: widget.isMobile),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: graphWidgets(),
          );
  }

  ValueNotifier<int> touchedIndex = ValueNotifier(-1);
  List<Widget> graphWidgets({bool isMobile = false}) {
    double zeroToSevenDays =
        widget.viewModel.ageingSummary?.zeroToSevenDays ?? 0;
    double eightToFifteenDays =
        widget.viewModel.ageingSummary?.eightToFifteenDays ?? 0;
    double sixteenToThirtyDays =
        widget.viewModel.ageingSummary?.sixteenToThirtyDays ?? 0;
    double above30Days = widget.viewModel.ageingSummary?.aboveThirtyDays ?? 0;
    double totalCount = zeroToSevenDays +
        eightToFifteenDays +
        sixteenToThirtyDays +
        above30Days;
    return [
      ValueListenableBuilder<int>(
          valueListenable: touchedIndex,
          builder: (context, int touchedint, _) {
            return SizedBox(
              height: isMobile ? 400 : 200,
              width: isMobile ? 300.3 : 150,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                        pieTouchData: PieTouchData(
                          enabled: true,
                          touchCallback:
                              (FlTouchEvent event, PieTouchResponse? resposne) {
                            if (event.isInterestedForInteractions) {
                              touchedIndex.value =
                                  resposne!.touchedSection!.touchedSectionIndex;
                              return;
                            } else {
                              touchedIndex.value = -1;
                              return;
                            }
                          },
                        ),
                        centerSpaceRadius: 5,
                        borderData: FlBorderData(show: true),
                        sectionsSpace: 2,
                        sections: totalCount == 0
                            ? [
                                PieChartSectionData(
                                    badgePositionPercentageOffset: 1,
                                    showTitle: false,
                                    value: 360,
                                    color: AppColors.darkGrey
                                        .withValues(alpha: 0.5),
                                    radius: 100)
                              ]
                            : [
                                PieChartSectionData(
                                    badgePositionPercentageOffset: 1,
                                    badgeWidget: touchedint == 0
                                        ? _tooltip(
                                            "${"dashboard.home.07days".tr()} \n $zeroToSevenDays")
                                        : null,
                                    showTitle: false,
                                    value: zeroToSevenDays,
                                    color:
                                        AppColors.teal.withValues(alpha: 0.5),
                                    radius: touchedint == 0 ? 110 : 100),
                                PieChartSectionData(
                                    badgePositionPercentageOffset: 1,
                                    badgeWidget: touchedint == 1
                                        ? _tooltip(
                                            "${"dashboard.home.815days".tr()} \n $eightToFifteenDays")
                                        : null,
                                    showTitle: false,
                                    value: eightToFifteenDays,
                                    color: AppColors.teal,
                                    radius: touchedint == 1 ? 110 : 100),
                                PieChartSectionData(
                                    badgePositionPercentageOffset: 1,
                                    badgeWidget: touchedint == 2
                                        ? _tooltip(
                                            "${"dashboard.home.1630days".tr()} \n $sixteenToThirtyDays")
                                        : null,
                                    showTitle: false,
                                    value: sixteenToThirtyDays,
                                    color: AppColors.limeGreen,
                                    radius: touchedint == 2 ? 110 : 100),
                                PieChartSectionData(
                                    badgePositionPercentageOffset: 1,
                                    badgeWidget: touchedint == 3
                                        ? _tooltip(
                                            "${"dashboard.home.above30Days".tr()} \n $above30Days")
                                        : null,
                                    showTitle: false,
                                    value: above30Days,
                                    color: AppColors.limeGreen
                                        .withValues(alpha: 0.5),
                                    radius: touchedint == 3 ? 110 : 100),
                              ]),
                  ),
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: isMobile ? 400 : 150,
                          width: isMobile ? 150 : 100,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                totalCount.toString(),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text("dashboard.home.total".tr()),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      SizedBox(
        width: 250,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "dashboard.home.filter.ageing".tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 2),
            graphLegend(
                colors: AppColors.teal.withValues(alpha: 0.5),
                text: "dashboard.home.07days".tr(),
                type: DashboardAgeingType.zeroToSevenDays,
                value: zeroToSevenDays),
            graphLegend(
                type: DashboardAgeingType.eightToFifteenDays,
                colors: AppColors.teal,
                text: "dashboard.home.815days".tr(),
                value: eightToFifteenDays),
            graphLegend(
                type: DashboardAgeingType.sixteenToThirtyDays,
                colors: AppColors.limeGreen,
                text: "dashboard.home.1630days".tr(),
                value: sixteenToThirtyDays),
            graphLegend(
                colors: AppColors.limeGreen.withValues(alpha: 0.5),
                type: DashboardAgeingType.aboveThirtyDays,
                text: "dashboard.home.above30Days".tr(),
                value: above30Days),
          ]),
        ),
      ),
    ];
  }

  Widget _tooltip(String text) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.customToolTipBg,
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppColors.white, fontSize: AppStyle.columnName),
        ),
      ),
    );
  }

  Widget graphLegend({
    required Color colors,
    required String text,
    required double value,
    required DashboardAgeingType type,
  }) {
    bool isSelected = type == widget.viewModel.selectedGraphFilter;
    Color? textColor = isSelected ? AppColors.teal : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          spacing: 6,
          children: [
            CircleAvatar(
              radius: 6,
              backgroundColor: colors,
            ),
            Text(
              text,
              style: TextStyle(color: textColor),
            ),
          ],
        ),
        TextButton(
            onPressed: () => widget.viewModel.onSelectGraphFilter(type),
            child: Text(
              "$value",
              style: TextStyle(
                  decoration: isSelected ? TextDecoration.underline : null,
                  color: textColor),
            ))
      ],
    );
  }
}
