import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/model.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/widgets/relationship_profitability_table.dart';

class RimListAccordion extends StatelessWidget {
  final RelationshipProfitabilitySummaryViewModel viewModel;

  const RimListAccordion({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: viewModel.relationshipProfitabilitySummaryData
            ?.relationshipProfitability?.length,
        itemBuilder: (BuildContext context, int index) {
          final data = viewModel.relationshipProfitabilitySummaryData
              ?.relationshipProfitability?[index];
          return CustomAccordion(
            title: "${data?.customerName} (${data?.customerRim})",
            children: [
              RelationshipProfitabilityTable(
                viewModel: viewModel,
                index: index,
              ),
              const Gap(size: GapSize.medium),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: LabelWidget(
                  label:
                      "profitabilityAccountConduct.relationshipProfitabilitySummary.comments"
                          .tr(),
                  child: CustomTextArea(
                    semanticLabel:
                        "profitabilityAccountConduct.relationshipProfitabilitySummary.comments"
                            .tr(),
                    maxLength: 5000,
                    initialValue: data?.comments ?? "",
                    validator: CustomValidator.requiredField,
                    onSaved: (String? value) {
                      data?.comments = value;
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
