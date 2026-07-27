import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/widgets/account_conduct_table.dart";

/// Builds the RIM list accordion containing account conduct details
/// and transaction information for each customer.
Widget rimListAccordian(AccountConductViewModel viewModel) {
  return ListView.builder(
    shrinkWrap: true,
    itemCount: viewModel.customers.length,
    itemBuilder: (BuildContext context, int index) {
      final dto = viewModel.customers[index];

      return CustomAccordion(
        title: "${"profitabilityAccountConduct.accountConduct.rimNo".tr()} "
            ": ${dto.rimNo ?? ""}  -  ${dto.custName ?? ""}",
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "approval.groupPosition.aed".tr(),
                style: AppStyle.tableSuffixHeaderStyle,
              ),
            ],
          ),
          const Gap(),
          accountConductTable(viewModel, index),
          const Gap(customValue: 26),
          accountTransactionTable(viewModel, index),
          const Gap(customValue: 26),
        ],
      );
    },
  );
}
