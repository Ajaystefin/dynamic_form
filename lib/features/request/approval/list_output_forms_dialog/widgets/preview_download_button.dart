import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';

class PreviewDownloadButton extends StatelessWidget {
  const PreviewDownloadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
            label: "approval.listOutputForms.preview".tr(),
            semanticLabel: "approval.listOutputForms.preview".tr(),
            onPressed: () {}),
        const Gap(
          direction: Axis.horizontal,
        ),
        CustomButton(
            label: "approval.listOutputForms.download".tr(),
            semanticLabel: "approval.listOutputForms.download".tr(),
            onPressed: () {}),
      ],
    );
  }
}
