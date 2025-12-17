import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/model.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/widgets/relationship_utilization_table.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/widgets/turnover_details.dart';

class RimListAccordion extends StatelessWidget {
  final RelationshipUtilizationViewModel viewModel;

  const RimListAccordion({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return viewModel.relationshipUtilizationData.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: viewModel.relationshipUtilizationData.length,
            itemBuilder: (BuildContext context, int index) {
              final data = viewModel.relationshipUtilizationData[index];
              return CustomAccordion(
                title:
                    "${"profitabilityAccountConduct.accountConduct.rimNo".tr()} : ${data.rim}",
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    CustomSelectableText(
                      semanticsLabel:
                          'profitabilityAccountConduct.shareOfWallet.aed'.tr(),
                      text:
                          'profitabilityAccountConduct.shareOfWallet.aed'.tr(),
                      textAlign: TextAlign.right,
                      style: AppStyle.tableSuffixHeaderStyle,
                    )
                  ]),
                  RelationshipUtilTable(viewModel: viewModel, index: index),
                  const Gap(),
                  TurnOverDetails(
                    relationshipUtilization:
                        viewModel.relationshipUtilizationData[index],
                    index: index,
                    viewModel: viewModel,
                  ),
                  const Gap(),
                ],
              );
            },
          )
        : Center(
            child: Text(
                semanticsLabel: 'common.noData'.tr(), 'common.noData'.tr()),
          );
  }
}
