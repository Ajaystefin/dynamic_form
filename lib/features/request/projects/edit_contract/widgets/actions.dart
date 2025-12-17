import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/model.dart';

class ActionsWidget extends StatelessWidget {
  final EditContractViewModel viewModel;
  const ActionsWidget(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
            label: "project.viewEditContractDetails.submit".tr(),
            semanticLabel: "project.viewEditContractDetails.submit".tr(),
            onPressed: () async => await viewModel.onSubmit()),
        const Gap(direction: Axis.horizontal),
        CustomButton(
            label: "project.viewEditContractDetails.reset".tr(),
            semanticLabel: "project.viewEditContractDetails.reset".tr(),
            onPressed: () async => await viewModel.onReset())
      ],
    );
  }
}
