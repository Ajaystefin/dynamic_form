import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart";

/// Displays a formatted remarks editor with a label.
class FinancialFormattableText extends StatelessWidget {
  /// Creates a formatted text editor widget for financial remarks.
  const FinancialFormattableText({
    required this.label,
    required this.viewModel,
    required this.isRequired,
    super.key,
  });

  /// Label displayed above the editor.
  final String label;

  /// Indicates whether the field is required.
  final bool isRequired;

  /// Financial Ratio Analysis view model.
  final FinancialRatioAnalysisViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: label,
      isRequired: isRequired,
      labelStyle: AppStyle.tableHeaderStyle,
      child: SizedBox(
        height: AppStyle.customTextEditorWidgetForRemark,
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
