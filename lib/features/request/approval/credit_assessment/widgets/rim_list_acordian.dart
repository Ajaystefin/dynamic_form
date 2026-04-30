import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment/model.dart";

class RimListAccordion extends StatelessWidget {
  const RimListAccordion({required this.viewModel, super.key});
  final CreditAssessmentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 3,
      itemBuilder: (BuildContext context, int index) {
        return CustomAccordion(
          initiallyExpanded: true,
          title: "Bank ${index + 1} Rim",
          children: [
            const Gap(size: GapSize.medium),
            UnifiedTextEditor(
              semanticLabel: "Bank ${index + 1} Rim",
              characterLimit: 5000,
              controller: viewModel.appraisalController,
            ),
          ],
        );
      },
    );
  }
}
