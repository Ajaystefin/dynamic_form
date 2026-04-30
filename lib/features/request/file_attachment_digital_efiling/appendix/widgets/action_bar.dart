import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";

class ActionBar extends StatelessWidget {
  const ActionBar({required this.viewModel, super.key});
  final AppendixViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!viewModel.isAppendixReadOnly)
          CustomButton(
            label: "eDigitalFilingFileAttachments.appendix.save".tr(),
            onPressed: () async {
              // if (viewModel.formKey.currentState?.validate() ?? false) {
              await viewModel.onSavePress(isContinue: false);
              // }
            },
          ),
        const Gap(direction: Axis.horizontal),
        CustomButton(
          label: "eDigitalFilingFileAttachments.appendix.saveContinue".tr(),
          onPressed: () async {
            // if (viewModel.formKey.currentState?.validate() ?? false) {
            await viewModel.onSavePress(isContinue: true);
            // }
          },
        ),
      ],
    );
  }
}
