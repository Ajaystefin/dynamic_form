import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";
import "package:wcas_frontend/features/dashboard/home/widgets/summary/pending_with.dart";
import "package:wcas_frontend/features/dashboard/home/widgets/summary/recommented_request.dart";
import "package:wcas_frontend/features/dashboard/home/widgets/summary/returned_request.dart";

class ChipFilters extends StatelessWidget {
  const ChipFilters(this.viewModel, {super.key});
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final int? recommentedRequestCount = viewModel
        .firstKeyForSummaryCount(viewModel.summaryData?.requestToRecommended);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
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
