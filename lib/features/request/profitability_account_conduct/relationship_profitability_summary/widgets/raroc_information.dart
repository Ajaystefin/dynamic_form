import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/model.dart';

class RoracInformation extends StatelessWidget {
  final RelationshipProfitabilitySummaryViewModel viewModel;

  const RoracInformation({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final rarocList =
        viewModel.relationshipProfitabilitySummaryData?.rarocInformation ?? [];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomRawTable(
        topStackedHeaders: _topStackedHeaders(),
        stackedHeaders: _stackedHeaders(),
        columns: _tableColumns(),
        autoFitWidth: true,
        columnHeaderHeight: 45.w,
        rows: _tableRows(rarocList),
      ),
    ]);
  }

  List<StackedHeader> _topStackedHeaders() {
    return [
      StackedHeader(
        startIndex: 2,
        endIndex: 3,
        widget: Center(
          child: Text(
              'profitabilityAccountConduct.relationshipProfitabilitySummary.existing'
                  .tr()),
        ),
        width: 190.w,
      ),
      StackedHeader(
        startIndex: 4,
        endIndex: 5,
        widget: Center(
          child: Text(
              'profitabilityAccountConduct.relationshipProfitabilitySummary.proposed'
                  .tr()),
        ),
        width: 190.w,
      ),
    ];
  }

  List<StackedHeader> _stackedHeaders() {
    return [
      StackedHeader(
        startIndex: 4,
        endIndex: 4,
        widget: Center(
          child: Text(
              'profitabilityAccountConduct.relationshipProfitabilitySummary.proposedByCoverage'
                  .tr()),
        ),
        width: 95.w,
      ),
      StackedHeader(
        startIndex: 5,
        endIndex: 5,
        widget: Center(
          child: Text(
              'profitabilityAccountConduct.relationshipProfitabilitySummary.exAnteRaroc'
                  .tr()),
        ),
        width: 95.w,
      ),
    ];
  }

  List<TableColumn> _tableColumns() {
    return [
      TableColumn(
          label: Text(
            'profitabilityAccountConduct.relationshipProfitabilitySummary.customerRim'
                .tr(),
          ),
          width: 105.w),
      TableColumn(
          label: Text(
              'profitabilityAccountConduct.relationshipProfitabilitySummary.customerName'
                  .tr()),
          width: 95.w),
      TableColumn(
        label: RichText(
            text: TextSpan(
                text:
                    'profitabilityAccountConduct.relationshipProfitabilitySummary.realizedRaroc'
                        .tr(),
                children: [
              if (Utils.checkRequestType(RequestType.fullCA))
                const TextSpan(
                    text: "*", style: TextStyle(color: AppColors.failure))
            ])),
        width: 95.w,
      ),
      TableColumn(
          label: Text(
              'profitabilityAccountConduct.relationshipProfitabilitySummary.lastApprovedRaroc'
                  .tr()),
          width: 95.w),
      TableColumn(
          label: RichText(
              text: TextSpan(
                  text:
                      'profitabilityAccountConduct.relationshipProfitabilitySummary.rarocpercnt'
                          .tr(),
                  children: [
                if (Utils.checkRequestType(RequestType.fullCA))
                  const TextSpan(
                      text: "*", style: TextStyle(color: AppColors.failure))
              ])),
          width: 95.w,
          isStacked: true),
      TableColumn(
          label: RichText(
              text: TextSpan(
                  text:
                      'profitabilityAccountConduct.relationshipProfitabilitySummary.finalRaroc'
                          .tr(),
                  children: [
                if (Utils.checkRequestType(RequestType.fullCA))
                  const TextSpan(
                      text: "*", style: TextStyle(color: AppColors.failure))
              ])),
          width: 95.w,
          isStacked: true),
      TableColumn(
          label: Text(
              'profitabilityAccountConduct.relationshipProfitabilitySummary.comments'
                  .tr()),
          width: 180.w),
    ];
  }

  List<List<Widget>> _tableRows(rarocList) {
    return rarocList.isNotEmpty
        ? List.generate(rarocList.length, (index) {
            final data = rarocList[index];

            return [
              Center(child: Text('${data.customerRim}')),
              Center(child: Text('${data.customerName}')),
              if (index < viewModel.realizedRarocControllers!.length)
                Center(
                  child: CustomTextField(
                    key: ValueKey('realizedRaroc_$index'),
                    width: 118,
                    inputFormatters: [DecimalInputFormatter()],
                    validator: !viewModel.isFIApplication
                        ? CustomValidator.requiredField
                        : null,
                    initialValue:
                        data.existingRealizedRarocPercent.toStringAsFixed(2),
                    controller: viewModel.realizedRarocControllers![index],
                    onChanged: (newValue) => viewModel.updateRoracField(
                        index, newValue, RoracFieldType.realizedRaroc),
                  ),
                ),
              Center(
                  child: Text(
                      data.existingLastApprovedRarocPercent.toStringAsFixed(2),
                      style: const TextStyle(color: AppColors.primary))),
              if (index < viewModel.proposedRarocControllers!.length)
                Center(
                  child: CustomTextField(
                    key: ValueKey('proposedRaroc_$index'),
                    width: 118,
                    inputFormatters: [DecimalInputFormatter()],
                    validator: !viewModel.isFIApplication
                        ? CustomValidator.requiredField
                        : null,
                    initialValue: data.existingLastApprovedRarocPercent
                        .toStringAsFixed(2),
                    controller: viewModel.proposedRarocControllers![index],
                    onChanged: (newValue) => viewModel.updateRoracField(
                        index, newValue, RoracFieldType.proposedRaroc),
                  ),
                ),
              if (index < viewModel.finalRarocControllers!.length)
                Center(
                  child: CustomTextField(
                    key: ValueKey('finalRaroc_$index'),
                    width: 118,
                    inputFormatters: [DecimalInputFormatter()],
                    validator: !viewModel.isFIApplication
                        ? CustomValidator.requiredField
                        : null,
                    initialValue: data.proposedFinalRarocPercentExAnteRaroc
                        .toStringAsFixed(2),
                    controller: viewModel.finalRarocControllers![index],
                    onChanged: (newValue) => viewModel.updateRoracField(
                        index, newValue, RoracFieldType.finalRaroc),
                  ),
                ),
              if (index < viewModel.commentsControllers!.length)
                Center(
                  child: CustomTextField(
                    key: ValueKey('comments_$index'),
                    width: 160.w,
                    initialValue: '${data.comments}',
                    controller: viewModel.commentsControllers![index],
                    validator: !viewModel.isFIApplication
                        ? CustomValidator.requiredField
                        : null,
                    onChanged: (newValue) => viewModel.updateRoracField(
                        index, newValue, RoracFieldType.comments),
                  ),
                ),
            ];
          })
        : [];
  }
}
