import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";

class ApplicationFilters extends StatelessWidget {
  const ApplicationFilters(
    this.viewModel, {
    required this.applicationTypes,
    super.key,
  });
  final HomeViewModel viewModel;
  final Map<ApplicationFilterType, String> applicationTypes;

  @override
  Widget build(BuildContext context) {
    final int applicationsOverdue = viewModel.firstKeyForSummaryCount(
          viewModel.summaryData?.applicationsOverdue,
        ) ??
        0;
    final int applicationsDueForReview = viewModel.firstKeyForSummaryCount(
          viewModel.summaryData?.applicationsDueForReview,
        ) ??
        0;
    final int recentApplications = viewModel.firstKeyForSummaryCount(
          viewModel.summaryData?.recentApplications,
        ) ??
        0;
    final int pendingWithSegment = viewModel.firstKeyForSummaryCount(
          viewModel.summaryData?.pendingWithSegment,
        ) ??
        0;
    return Padding(
      padding: const EdgeInsets.only(top: AppStyle.spacing),
      child: Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10,
        alignment: WrapAlignment.start,
        children: [
          // if (Utils.checkRoles(
          //   [
          //     UserRole.relationshipOfficer,
          //     UserRole.relationshipManager,
          //     UserRole.relationshipManagerBussiness,
          //   ],
          // )) ...[
          if (applicationsOverdue != -1)
            applicationDetails(
              color: AppColors.applicationOverdue,
              label:
                  applicationTypes[ApplicationFilterType.applicationOverdue] ??
                      "",
              onTap: () => router.go(
                Routes.closedRequest,
                extra: ApplicationFilterType.applicationOverdue,
              ),
              count: "$applicationsOverdue",
            ),
          const Gap(direction: Axis.horizontal),
          if (applicationsDueForReview != -1)
            applicationDetails(
              color: AppColors.dueForReview,
              label: applicationTypes[ApplicationFilterType.dueForReview] ?? "",
              onTap: () => router.go(
                Routes.closedRequest,
                extra: ApplicationFilterType.dueForReview,
              ),
              count: "$applicationsDueForReview",
            ),
          const Gap(direction: Axis.horizontal),
          if (recentApplications != -1)
            applicationDetails(
              color: AppColors.recentApplication,
              label:
                  applicationTypes[ApplicationFilterType.recentApplication] ??
                      "",
              onTap: () => router.go(
                Routes.closedRequest,
                extra: ApplicationFilterType.recentApplication,
              ),
              count: "$recentApplications",
            ),
          const Gap(direction: Axis.horizontal),
          if (pendingWithSegment != -1)
            applicationDetails(
              color: AppColors.applicationSegment,
              label:
                  applicationTypes[ApplicationFilterType.applicationSegment] ??
                      "",
              onTap: () => router.go(
                Routes.closedRequest,
                extra: ApplicationFilterType.applicationSegment,
              ),
              count: "$pendingWithSegment",
            ),
        ],
        // ],
      ),
    );
  }

  Widget applicationDetails({
    required Color color,
    required String label,
    required String count,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 35,
        // width: 190.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.accordionPrimary,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Container(
              width: 40,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  topLeft: Radius.circular(8),
                ),
                color: color,
              ),
              child: Center(
                child: Text(
                  count,
                  style: const TextStyle(color: AppColors.white, fontSize: 12),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [Text(label), const Icon(Icons.keyboard_arrow_right)],
            ),
          ],
        ),
      ),
    );
  }
}
