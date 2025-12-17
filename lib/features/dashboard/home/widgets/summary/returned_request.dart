import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/dashboard/home/model.dart';
import 'package:wcas_frontend/features/dashboard/home/widgets/summary/custom_chip.dart';

class ReturnedRequest extends StatelessWidget {
  final HomeViewModel viewModel;
  const ReturnedRequest(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    // Small helper to remove ChipWidget repetition while keeping conditions intact
    Widget chip(SummaryType summaryType, int? count) => ChipWidget(
        viewModel: viewModel, summaryType: summaryType, count: count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        LabelWidget(
          label: "dashboard.home.filter.returnedRequest".tr(),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Wrap(
          runAlignment: WrapAlignment.start,
          spacing: 10,
          runSpacing: 10,
          children: [
            // RO + RMB
            if (Utils.checkRoles([
              UserRole.relationshipOfficer,
              UserRole.relationshipManager,
            ]))
              chip(
                SummaryType.documentationrequest,
                viewModel.summaryData?.returnedRequestDocumentation,
              ),

            // RMB only
            if (Utils.checkRoles([UserRole.relationshipManagerBussiness]))
              chip(
                SummaryType.relationshipOfficer,
                viewModel.summaryData?.returnedRequestDocumentation,
              ),

            // Credit side (multiple roles)
            if (Utils.checkRoles([
              UserRole.creditCordinator,
              UserRole.creditAnalyst,
              UserRole.segmentHeadBusiness,
              UserRole.commercialAreaManager,
              UserRole.teamLeaderBusiness,
            ])) ...[
              chip(
                SummaryType.relationshipOfficer,
                viewModel.summaryData?.returnedToRO,
              ),
              chip(
                SummaryType.relationshipManager,
                viewModel.summaryData?.returnedToRM,
              ),
            ],

            // Credit Coordinator
            if (Utils.checkRoles([UserRole.creditCordinator])) ...[
              chip(
                SummaryType.unitHead,
                viewModel.summaryData?.returnedRequestDocumentation,
              ),
            ],

            // Credit Analyst
            if (Utils.checkRoles([UserRole.creditAnalyst])) ...[
              chip(
                SummaryType.unitHead,
                viewModel.summaryData?.returnedRequestDocumentation,
              ),
              chip(
                SummaryType.creditAnalyst,
                viewModel.summaryData?.returnedRequestDocumentation,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
