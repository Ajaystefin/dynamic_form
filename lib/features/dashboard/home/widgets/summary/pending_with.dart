import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/dashboard/home/model.dart';
import 'package:wcas_frontend/features/dashboard/home/widgets/summary/custom_chip.dart';

class PendingWith extends StatelessWidget {
  final HomeViewModel viewModel;
  const PendingWith(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        LabelWidget(
            label: "dashboard.home.filter.pendingWith".tr(),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          runAlignment: WrapAlignment.start,
          runSpacing: AppStyle.spacing,
          spacing: AppStyle.spacing,
          children: [
            if (!(Utils.checkRoles([UserRole.admin, UserRole.inquiryUser])))
              ChipWidget(
                  viewModel: viewModel,
                  summaryType: SummaryType.me,
                  count: viewModel.summaryData?.pendingWithMe),
            if (!Utils.checkRoles([
              UserRole.relationshipManager,
              UserRole.relationshipManagerBussiness,
              UserRole.relationshipOfficer,
              UserRole.commercialAreaManager,
              UserRole.segmentHeadBusiness,
              UserRole.teamLeaderBusiness,
            ]))
              ChipWidget(
                  viewModel: viewModel,
                  summaryType: SummaryType.team,
                  count: viewModel.summaryData?.pendingWithTeam),
            if (Utils.checkRoles([
              UserRole.relationshipManager,
              UserRole.relationshipManagerBussiness,
              UserRole.relationshipOfficer,
              UserRole.admin,
              UserRole.inquiryUser,
            ])) ...[
              ChipWidget(
                  viewModel: viewModel,
                  summaryType: SummaryType.business,
                  count: viewModel.summaryData?.pendingWithBusiness),
              if (!(Utils.checkRole(UserRole.admin))) ...[
                ChipWidget(
                    viewModel: viewModel,
                    summaryType: SummaryType.credit,
                    count: viewModel.summaryData?.pendingWithCredit),
                ChipWidget(
                    viewModel: viewModel,
                    summaryType: SummaryType.approvingauthority,
                    count:
                        viewModel.summaryData?.pendingWithApprovingAuthority),
              ],
            ],
            if (Utils.checkRoles([
              UserRole.relationshipManager,
              UserRole.relationshipManagerBussiness,
              UserRole.relationshipOfficer,
              UserRole.commercialAreaManager,
              UserRole.segmentHeadBusiness,
              UserRole.teamLeaderBusiness,
              UserRole.inquiryUser,
              UserRole.ccuMaker,
              UserRole.ccuChecker,
            ]))
              ChipWidget(
                  viewModel: viewModel,
                  summaryType: SummaryType.documentation,
                  count: viewModel.summaryData?.pendingWithDocumentation),
            if (Utils.checkRoles([
              UserRole.relationshipManager,
              UserRole.relationshipManagerBussiness,
              UserRole.relationshipOfficer,
              UserRole.inquiryUser,
            ]))
              ChipWidget(
                  viewModel: viewModel,
                  summaryType: SummaryType.creditcontrol,
                  count: viewModel.summaryData?.pendingWithCreditControl),
            if (Utils.checkRoles([
              UserRole.creditCordinator,
              UserRole.ccuChecker,
              UserRole.ccuMaker,
            ]))
              ChipWidget(
                  viewModel: viewModel,
                  summaryType: SummaryType.pool,
                  count: viewModel.summaryData?.pendingWithPool),
          ],
        ),
      ],
    );
  }
}
