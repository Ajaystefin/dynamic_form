import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";

class ActionsSection extends StatelessWidget {
  const ActionsSection({required this.viewModel, super.key});
  final LinkContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          label: "project.linkContract.createContract".tr(),
          semanticLabel: "project.linkContract.createContract".tr(),
          onPressed: viewModel.canEdit
              ?
              //  viewModel.viewAccessRolesCheck() ? null :
              () async {
                  await viewModel.onSave(context, isCreate: true);
                }
              : null,
        ),
        const Gap(direction: Axis.horizontal),
        CustomButton(
          label: "project.linkContract.save".tr(),
          semanticLabel: "project.linkContract.save".tr(),
          onPressed: viewModel.canEdit
              ?
              //  viewModel.viewAccessRolesCheck() ? null :
              () {
                  viewModel.onSave(context);
                }
              : null,
        ),
        const Gap(direction: Axis.horizontal),
        CustomButton(
          label: "project.linkContract.discard".tr(),
          semanticLabel: "project.linkContract.discard".tr(),
          onPressed: viewModel.canEdit
              ?
              //  viewModel.viewAccessRolesCheck() ? null :
              () {
                  viewModel
                    ..clearAll()
                    ..onDiscard(context);
                }
              : null,
        ),
      ],
    );
  }
}
