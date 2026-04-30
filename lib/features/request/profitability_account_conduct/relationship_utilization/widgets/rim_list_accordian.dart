import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/state.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/widgets/relationship_utilization_table.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/widgets/turnover_details.dart";

class RimListAccordion extends StatelessWidget {
  const RimListAccordion({
    required this.viewModel,
    required this.state,
    super.key,
  });
  final RelationshipUtilizationViewModel viewModel;
  final RelationshipUtilizationState state;

  @override
  Widget build(BuildContext context) {
    final items = viewModel.relationshipUtilizationData;

    if (items.isEmpty) {
      return Center(
        child: Text(
          "common.noData".tr(),
          semanticsLabel: "common.noData".tr(),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        // Guard against any out-of-range issues
        if (index < 0 || index >= items.length) {
          return const SizedBox.shrink();
        }

        final data = items[index];

        // Safe rim text (rim can be null)
        final rimText =
            '${"profitabilityAccountConduct.accountConduct.rimNo".tr()} '
            ': ${data.rim?.toString() ?? ''}';

        return CustomAccordion(
          title: rimText,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomSelectableText(
                  semanticsLabel:
                      "profitabilityAccountConduct.shareOfWallet.aed".tr(),
                  text: "profitabilityAccountConduct.shareOfWallet.aed".tr(),
                  textAlign: TextAlign.right,
                  style: AppStyle.tableSuffixHeaderStyle,
                ),
              ],
            ),

            // RelationshipUtilization table (now null-safe in your previous
            // fix)
            RelationshipUtilTable(viewModel: viewModel, index: index),
            const Gap(),

            // Turnover details section (safe handling below)
            TurnOverDetails(
              relationshipUtilization: data,
              index: index,
              viewModel: viewModel,
              state: state,
            ),
            const Gap(),
          ],
        );
      },
    );
  }
}
