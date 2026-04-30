import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";
import "package:wcas_frontend/features/dashboard/home/widgets/summary/custom_chip.dart";

class PendingWith extends StatelessWidget {
  const PendingWith(this.viewModel, {super.key});
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final int? pendingWithMe =
        viewModel.firstKeyForSummaryCount(viewModel.summaryData?.pendingWithMe);
    final int? pendingWithTeam = viewModel
        .firstKeyForSummaryCount(viewModel.summaryData?.pendingWithTeam);
    final int? pendingWithBusiness = viewModel
        .firstKeyForSummaryCount(viewModel.summaryData?.pendingWithBusiness);
    final int? pendingWithCredit = viewModel
        .firstKeyForSummaryCount(viewModel.summaryData?.pendingWithCredit);
    final int? pendingWithApprovingAuthority =
        viewModel.firstKeyForSummaryCount(
      viewModel.summaryData?.pendingWithApprovingAuthority,
    );
    final int? pendingWithDocumentation = viewModel.firstKeyForSummaryCount(
      viewModel.summaryData?.pendingWithDocumentation,
    );
    final int? pendingWithCreditControl = viewModel.firstKeyForSummaryCount(
      viewModel.summaryData?.pendingWithCreditControl,
    );
    final int? pendingWithPool = viewModel
        .firstKeyForSummaryCount(viewModel.summaryData?.pendingWithPool);
    final int? pendingWithRelationShipTeam = viewModel.firstKeyForSummaryCount(
      viewModel.summaryData?.pendingWithRelationShipTeam,
    );
    final int? pendingWithBusinessTeam = viewModel.firstKeyForSummaryCount(
      viewModel.summaryData?.pendingWithBusinessTeam,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        LabelWidget(
          label: "dashboard.home.filter.pendingWith".tr(),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Wrap(
          runAlignment: WrapAlignment.start,
          runSpacing: AppStyle.spacing,
          spacing: AppStyle.spacing,
          children: [
            if (pendingWithMe != -1)
              ChipWidget(
                viewModel: viewModel,
                summaryType: SummaryType.me,
                count: pendingWithMe,
              ),
            if (pendingWithTeam != -1)
              ChipWidget(
                viewModel: viewModel,
                summaryType: SummaryType.team,
                count: pendingWithTeam,
              ),
            if (pendingWithBusiness != -1)
              ChipWidget(
                viewModel: viewModel,
                summaryType: SummaryType.business,
                count: pendingWithBusiness,
              ),
            if (pendingWithCredit != -1)
              ChipWidget(
                viewModel: viewModel,
                summaryType: SummaryType.credit,
                count: pendingWithCredit,
              ),
            if (pendingWithApprovingAuthority != -1)
              ChipWidget(
                viewModel: viewModel,
                summaryType: SummaryType.approvingauthority,
                count: pendingWithApprovingAuthority,
              ),
            if (pendingWithDocumentation != -1)
              ChipWidget(
                viewModel: viewModel,
                summaryType: SummaryType.documentation,
                count: pendingWithDocumentation,
              ),
            if (pendingWithCreditControl != -1)
              ChipWidget(
                viewModel: viewModel,
                summaryType: SummaryType.creditcontrol,
                count: pendingWithCreditControl,
              ),
            if (pendingWithPool != -1)
              ChipWidget(
                viewModel: viewModel,
                summaryType: SummaryType.pool,
                count: pendingWithPool,
              ),
            if (pendingWithRelationShipTeam != -1)
              ChipWidget(
                viewModel: viewModel,
                summaryType: SummaryType.pendingWithRelationShipTeam,
                count: pendingWithRelationShipTeam,
              ),
            if (pendingWithBusinessTeam != -1)
              ChipWidget(
                viewModel: viewModel,
                summaryType: SummaryType.pendingWithBusinessTeam,
                count: pendingWithBusinessTeam,
              ),
          ],
        ),
      ],
    );
  }
}
