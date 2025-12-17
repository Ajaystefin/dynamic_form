import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/text_editor.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart';

class GuarantorTextArea extends StatelessWidget {
  final GuarantorFinancialViewModel viewModel;
  const GuarantorTextArea({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'remarks.guarantorFinancials.guarantorFinancialsRatio'.tr(),
      labelStyle: AppStyle.tableHeaderStyle,
      child: SizedBox(
        height: AppStyle.customTextEditorWidget,
        child: CustomTextEditorWidget(
          semanticLabel:
              'remarks.guarantorFinancials.guarantorFinancialsRatio'.tr(),
          controller: viewModel.controller,
          characterLimit: 5000,
          showVideoUpload: false,
        ),
      ),
    );
  }
}
