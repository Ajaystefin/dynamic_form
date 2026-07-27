import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";
import "package:wcas_frontend/features/dashboard/home/widgets/summary/custom_chip.dart";

/// Displays the recommended request summary chip section.
class RecommentedRequest extends StatelessWidget {
  /// Creates a [RecommentedRequest].
  const RecommentedRequest(
    this.viewModel, {
    this.recommentedRequestCount,
    super.key,
  });

  /// Home dashboard view model used to handle summary selection.
  final HomeViewModel viewModel;

  /// Recommended request count displayed in the chip.
  final int? recommentedRequestCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "dashboard.home.filter.recommentedRequest".tr(),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Wrap(
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
