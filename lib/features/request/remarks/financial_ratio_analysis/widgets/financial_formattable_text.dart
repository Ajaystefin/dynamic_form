import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart";

class FinancialFormattableText extends StatelessWidget {
  const FinancialFormattableText({
    required this.label,
    required this.viewModel,
    required this.isRequired,
    super.key,
  });
  final String label;
  final bool isRequired;
  final FinancialRatioAnalysisViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: label,
      isRequired: isRequired,
      labelStyle: AppStyle.tableHeaderStyle,
      child: SizedBox(
        height: AppStyle.customTextEditorWidget,
        child: UnifiedTextEditor(
          showVideoUpload: false,
          semanticLabel: label,
          controller: viewModel.balanceSheetcontroller,
          initialText: viewModel.balanceSheetdescription,
        ),
      ),
    );
  }
}
