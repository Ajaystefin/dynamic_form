import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/features/request/approval/list_output_forms_dialog/model.dart';

class PreviewDownloadButton extends StatelessWidget {
  final ListOutputFormsDialogViewModel viewModel;
  const PreviewDownloadButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
            label: "approval.listOutputForms.preview".tr(),
            semanticLabel: "approval.listOutputForms.preview".tr(),
            onPressed: () {
              viewModel.downloadOutputForm();
            }),
        const Gap(
          direction: Axis.horizontal,
        ),
        CustomButton(
            label: "approval.listOutputForms.download".tr(),
            semanticLabel: "approval.listOutputForms.download".tr(),
            onPressed: () {
              viewModel.downloadOutputForm();
            }),
      ],
    );
  }
}
