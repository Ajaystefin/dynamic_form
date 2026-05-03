import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";
import "package:wcas_frontend/features/dashboard/home/widgets/summary/custom_chip.dart";

class ReturnedRequest extends StatelessWidget {
  const ReturnedRequest(this.viewModel, {super.key});
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    Widget chip(SummaryType summaryType, int? count) => ChipWidget(
          viewModel: viewModel,
          summaryType: summaryType,
          count: count,
        );
    final int? returnedRequestDocumentation = viewModel.firstKeyForSummaryCount(
      viewModel.summaryData?.returnedRequestDocumentation,
    );
    final int? returnedToDocumentation = viewModel.firstKeyForSummaryCount(
      viewModel.summaryData?.returnedToDocumentation,
    );
    final int? returnedToRO =
        viewModel.firstKeyForSummaryCount(viewModel.summaryData?.returnedToRO);
    final int? returnedToRM =
        viewModel.firstKeyForSummaryCount(viewModel.summaryData?.returnedToRM);
    final int? returnedToCCUM = viewModel
        .firstKeyForSummaryCount(viewModel.summaryData?.returnedToCCUM);
    final int? returnedToCA =
        viewModel.firstKeyForSummaryCount(viewModel.summaryData?.returnedToCA);
    final int? returnedToSHD =
        viewModel.firstKeyForSummaryCount(viewModel.summaryData?.returnedToSHD);
    final int? returnedToSHC =
        viewModel.firstKeyForSummaryCount(viewModel.summaryData?.returnedToSHC);
    final int? returnedToCCPA = viewModel
        .firstKeyForSummaryCount(viewModel.summaryData?.returnedToCCPA);
    final int? returnedToBDP =
        viewModel.firstKeyForSummaryCount(viewModel.summaryData?.returnedToBDP);
    final int? returnedToCCP =
        viewModel.firstKeyForSummaryCount(viewModel.summaryData?.returnedToCCP);
    final int? returnedToRMB =
        viewModel.firstKeyForSummaryCount(viewModel.summaryData?.returnedToRMB);
    final int? returnedToSHB1 = viewModel
        .firstKeyForSummaryCount(viewModel.summaryData?.returnedToSHB1);
    final int? returnedToSHLvlB = viewModel
        .firstKeyForSummaryCount(viewModel.summaryData?.returnedToSHLvlB);
    final int? returnedToSHB =
        viewModel.firstKeyForSummaryCount(viewModel.summaryData?.returnedToSHB);
    final int? returnedToTLB =
        viewModel.firstKeyForSummaryCount(viewModel.summaryData?.returnedToTLB);
    final int? returnedToCAM =
        viewModel.firstKeyForSummaryCount(viewModel.summaryData?.returnedToCAM);
    final int? returnedToTLD1 = viewModel
        .firstKeyForSummaryCount(viewModel.summaryData?.returnedToTLD1);
    final int? returnedToCCOOD = viewModel
        .firstKeyForSummaryCount(viewModel.summaryData?.returnedToCCOOD);
    int? returnedToUnitHead = -1;
    if (returnedToCAM != -1 ||
        returnedToRMB != -1 ||
        returnedToTLB != -1 ||
        returnedToSHB != -1) {
      final List<int?> returnedToUHs = [
        returnedToCAM,
        returnedToRMB,
        returnedToTLB,
        returnedToSHB,
      ]..removeWhere((int? count) => count == -1);
      returnedToUnitHead = returnedToUHs
          .reduce((value, element) => (value ?? 0) + (element ?? 0));
    }
    final bool isVisible = [
      returnedRequestDocumentation,
      returnedToDocumentation,
      returnedToRO,
      returnedToRM,
      returnedToCA,
      returnedToUnitHead,
      returnedToTLD1,
      returnedToSHB1,
      returnedToSHLvlB,
      returnedToSHD,
      returnedToSHC,
      returnedToCCPA,
      returnedToBDP,
      returnedToCCP,
      returnedToCCUM,
      returnedToCCOOD,
    ].any((count) => count != -1);

    if (!isVisible) return const SizedBox.shrink();
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
            if (returnedRequestDocumentation != -1)
              chip(
                SummaryType.documentationrequest,
                returnedRequestDocumentation,
              ),
            if (returnedToDocumentation != -1)
              chip(
                SummaryType.documentationrequest,
                returnedToDocumentation,
              ),
            if (returnedToRO != -1)
              chip(
                SummaryType.ro,
                returnedToRO,
              ),
            if (returnedToRM != -1)
              chip(
                SummaryType.rm,
                returnedToRM,
              ),
            // if (returnedToCA != -1)
            //   chip(
            //     SummaryType.creditCordinator,
            //     returnedToCA,
            //   ),
            if (returnedToCA != -1)
              chip(
                SummaryType.ca,
                returnedToCA,
              ),
            if (returnedToUnitHead != -1)
              chip(
                SummaryType.unitHead,
                returnedToUnitHead,
              ),
            if (returnedToTLD1 != -1)
              chip(
                SummaryType.tld1,
                returnedToTLD1,
              ),
            if (returnedToSHB1 != -1)
              chip(
                SummaryType.shlb1,
                returnedToSHB1,
              ),
            if (returnedToSHLvlB != -1)
              chip(
                SummaryType.shlb,
                returnedToSHLvlB,
              ),
            if (returnedToSHD != -1)
              chip(
                SummaryType.shld,
                returnedToSHD,
              ),
            if (returnedToSHC != -1)
              chip(
                SummaryType.shlc,
                returnedToSHC,
              ),
            if (returnedToCCPA != -1)
              chip(
                SummaryType.ccProxyApprover,
                returnedToCCPA,
              ),
            if (returnedToBDP != -1)
              chip(
                SummaryType.bdProxy,
                returnedToBDP,
              ),
            if (returnedToCCP != -1)
              chip(
                SummaryType.ccProxy,
                returnedToCCP,
              ),
            if (returnedToCCUM != -1)
              chip(
                SummaryType.ccuMaker,
                returnedToCCUM,
              ),
            if (returnedToCCOOD != -1)
              chip(
                SummaryType.ccood,
                returnedToCCOOD,
              ),
          ],
        ),
      ],
    );
  }
}
