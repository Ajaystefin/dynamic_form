import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/model.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/widgets/relationship_profit_detail_table.dart';

class AccountConductAccordion extends StatelessWidget {
  final RelationshipProfitabilityDetailedViewModel viewModel;

  const AccountConductAccordion({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: viewModel.relProfitDet.length,
      itemBuilder: (BuildContext context, int index) {
        final detail = viewModel.relProfitDet[index];
        return CustomAccordion(
          title:
              "${"profitabilityAccountConduct.accountConduct.rimNo".tr()} : ${detail.rim}",
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              CustomSelectableText(
                semanticsLabel:
                    'profitabilityAccountConduct.shareOfWallet.aed'.tr(),
                text: 'profitabilityAccountConduct.shareOfWallet.aed'.tr(),
                textAlign: TextAlign.right,
                style: AppStyle.tableSuffixHeaderStyle,
              )
            ]),
            RelationshipProfitDetailTable(
              details: detail.relationshipProfitabilityDetail,
            ),
          ],
        );
      },
    );
  }
}
