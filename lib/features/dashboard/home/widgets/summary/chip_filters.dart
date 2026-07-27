import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";
import "package:wcas_frontend/features/dashboard/home/widgets/summary/pending_with.dart";
import "package:wcas_frontend/features/dashboard/home/widgets/summary/recommented_request.dart";
import "package:wcas_frontend/features/dashboard/home/widgets/summary/returned_request.dart";

/// Displays dashboard chip filters for pending, returned, and recommended requests.
class ChipFilters extends StatelessWidget {
  /// Creates a [ChipFilters] widget.
  const ChipFilters(this.viewModel, {super.key});

  /// Home dashboard view model used to provide summary data.
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final int? recommentedRequestCount = viewModel
        .firstKeyForSummaryCount(viewModel.summaryData?.requestToRecommended);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(),
        PendingWith(viewModel),
        const Gap(),
        ReturnedRequest(viewModel),
        if (recommentedRequestCount != -1) ...[
          const Gap(),
          RecommentedRequest(
            viewModel,
            recommentedRequestCount: recommentedRequestCount,
          ),
        ],
      ],
    );
  }
}
