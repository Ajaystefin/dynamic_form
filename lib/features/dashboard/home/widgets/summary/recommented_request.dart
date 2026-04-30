import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";
import "package:wcas_frontend/features/dashboard/home/widgets/summary/custom_chip.dart";

class RecommentedRequest extends StatelessWidget {
  const RecommentedRequest(
    this.viewModel, {
    this.recommentedRequestCount,
    super.key,
  });
  final HomeViewModel viewModel;
  final int? recommentedRequestCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        LabelWidget(
          label: "dashboard.home.filter.recommentedRequest".tr(),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Wrap(
          runAlignment: WrapAlignment.start,
          spacing: 10,
          runSpacing: 10,
          children: [
            ChipWidget(
              viewModel: viewModel,
              summaryType: SummaryType.requests,
              count: recommentedRequestCount,
            ),
          ],
        ),
      ],
    );
  }
}
