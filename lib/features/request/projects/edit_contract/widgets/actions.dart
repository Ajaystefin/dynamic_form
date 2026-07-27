import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";

/// Actions widget for edit contract submit and reset actions.
class ActionsWidget extends StatelessWidget {
  /// Creates an actions widget.
  const ActionsWidget(this.viewModel, {super.key});

  /// Edit contract view model.
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          label: "project.viewEditContractDetails.submit".tr(),
          semanticLabel: "project.viewEditContractDetails.submit".tr(),
          onPressed: viewModel.canEdit
              ?
              //viewModel.viewAccessRolesCheck() ? null :
              () async => viewModel.onSubmit(context)
              : null,
        ),
        const Gap(direction: Axis.horizontal),
        CustomButton(
          label: "project.viewEditContractDetails.reset".tr(),
          semanticLabel: "project.viewEditContractDetails.reset".tr(),
          onPressed: viewModel.canEdit
              ?
              //viewModel.viewAccessRolesCheck() ? null :
              () async => viewModel.onReset(context)
              : null,
        ),
      ],
    );
  }
}
