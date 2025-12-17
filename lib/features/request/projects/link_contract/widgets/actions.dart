import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/model.dart';

class ActionsSection extends StatelessWidget {
  final LinkContractViewModel viewModel;
  const ActionsSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
            label: "project.linkContract.createContract".tr(),
            semanticLabel: "project.linkContract.createContract".tr(),
            onPressed: () async {
              viewModel.onSave(context);
            }),
        const Gap(direction: Axis.horizontal),
        CustomButton(
            label: "project.linkContract.save".tr(),
            semanticLabel: "project.linkContract.save".tr(),
            onPressed: () {
              viewModel.onSave(context);
            }),
        const Gap(direction: Axis.horizontal),
        CustomButton(
            label: "project.linkContract.discard".tr(),
            semanticLabel: "project.linkContract.discard".tr(),
            onPressed: () {
              viewModel.clearAll();
              if (context.mounted) {
                context.go(Routes.editContract);
              }
            }),
      ],
    );
  }
}
