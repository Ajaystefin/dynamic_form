import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/dashboard/home/model.dart';
import 'package:wcas_frontend/features/dashboard/home/widgets/summary/pending_with.dart';
import 'package:wcas_frontend/features/dashboard/home/widgets/summary/recommented_request.dart';
import 'package:wcas_frontend/features/dashboard/home/widgets/summary/returned_request.dart';

class ChipFilters extends StatelessWidget {
  final HomeViewModel viewModel;

  const ChipFilters(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Gap(),
        PendingWith(viewModel),
        const Gap(),
        if (Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.relationshipManager,
          UserRole.commercialAreaManager,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
          UserRole.segmentHeadBusiness,
          UserRole.teamLeaderBusiness,
          UserRole.relationshipManagerBussiness
        ]))
          ReturnedRequest(viewModel),
        const Gap(),
        if (Utils.checkRoles([
          UserRole.commercialAreaManager,
          UserRole.segmentHeadBusiness,
          UserRole.teamLeaderBusiness,
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.teamLeaderCreditLevelD1,
          UserRole.boardDirectorProxyApproval,
          UserRole.creditCommitteeProxyApprover,
          UserRole.segmentHeadLevelB,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.boardDirectorProxy,
        ]))
          RecommentedRequest(viewModel),
      ],
    );
  }
}
