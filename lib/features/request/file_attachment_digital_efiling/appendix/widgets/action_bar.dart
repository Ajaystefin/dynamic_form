import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";

/// ActionBar stateless widget

class ActionBar extends StatelessWidget {
  /// Creates [ActionBar] instance
  const ActionBar({required this.viewModel, super.key});

  /// AppendixViewModel view model to handle actions
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
              await viewModel.onSavePress();
              // }
            },
          ),
        const Gap(direction: Axis.horizontal),
        if (!viewModel.isAppendixReadOnly)
          CustomButton(
            label: "eDigitalFilingFileAttachments.appendix.saveContinue".tr(),
            onPressed: () async {
              // if (viewModel.formKey.currentState?.validate() ?? false) {
              await viewModel.onSavePress(isContinue: true);
              // }
            },
          ),
        if (viewModel.isAppendixReadOnly)
          CustomButton(
            label: "eDigitalFilingFileAttachments.appendix.continue".tr(),
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
