import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/text_editor.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart';

class FinancialFormattableText extends StatelessWidget {
  final String label;
  final bool isRequired;
  final FinancialRatioAnalysisViewModel viewModel;
  const FinancialFormattableText(
      {super.key,
      required this.label,
      required this.viewModel,
      required this.isRequired});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: label,
      isRequired: isRequired,
      labelStyle: AppStyle.tableHeaderStyle,
      child: SizedBox(
        height: AppStyle.customTextEditorWidget,
        child: CustomTextEditorWidget(
          showVideoUpload: false,
          semanticLabel: label,
          controller: viewModel.controller,
          characterLimit: 5000,
        ),
      ),
    );
  }
}
