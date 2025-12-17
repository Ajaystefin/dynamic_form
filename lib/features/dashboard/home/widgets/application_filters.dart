import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/dashboard/home/model.dart';

class ApplicationFilters extends StatelessWidget {
  final HomeViewModel viewModel;
  final Map<ApplicationFilterType, String> applicationTypes;
  const ApplicationFilters(this.viewModel,
      {required this.applicationTypes, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppStyle.spacing),
      child: Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10,
        alignment: WrapAlignment.start,
        children: [
          if (Utils.checkRoles(
            [
              UserRole.relationshipOfficer,
              UserRole.relationshipManager,
              UserRole.relationshipManagerBussiness,
            ],
          )) ...[
            applicationDetails(
                color: AppColors.applicationOverdue,
                label: applicationTypes[
                        ApplicationFilterType.applicationOverdue] ??
                    "",
                onTap: () => router.go(Routes.closedRequest,
                    extra: ApplicationFilterType.applicationOverdue),
                count: "${viewModel.summaryData?.applicationsOverdue ?? 0}"),
            const Gap(direction: Axis.horizontal),
            applicationDetails(
                color: AppColors.dueForReview,
                label:
                    applicationTypes[ApplicationFilterType.dueForReview] ?? "",
                onTap: () => router.go(Routes.closedRequest,
                    extra: ApplicationFilterType.dueForReview),
                count:
                    "${viewModel.summaryData?.applicationsDueForReview ?? 0}"),
            const Gap(direction: Axis.horizontal),
            applicationDetails(
                color: AppColors.recentApplication,
                label:
                    applicationTypes[ApplicationFilterType.recentApplication] ??
                        "",
                onTap: () => router.go(Routes.closedRequest,
                    extra: ApplicationFilterType.recentApplication),
                count: "${viewModel.summaryData?.recentApplications ?? 0}"),
            const Gap(direction: Axis.horizontal),
            applicationDetails(
                color: AppColors.applicationSegment,
                label: applicationTypes[
                        ApplicationFilterType.applicationSegment] ??
                    "",
                onTap: () => router.go(Routes.closedRequest,
                    extra: ApplicationFilterType.applicationSegment),
                count: "${viewModel.summaryData?.pendingWithSegment ?? 0}"),
          ],
        ],
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
            color: AppColors.accordionPrimary),
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
                  color: color),
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
