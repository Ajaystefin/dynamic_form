import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";

class ActionWidget extends StatelessWidget {
  const ActionWidget({required this.viewModel, super.key});
  final ConditionEditDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (viewModel.canEdit)
          CustomButton(
            label: "covenantsConditions.covenantEditDialog.save".tr(),
            semanticLabel: "covenantsConditions.covenantEditDialog.save".tr(),
            onPressed: () async {
              if (Utils.checkBusinessSegment(
                BusinessSegment.financialInstitution,
              )) {
                viewModel.formKey.currentState?.save();
                await viewModel.onSavePress();
              } else {
                if (viewModel.formKey.currentState?.validate() ?? false) {
                  viewModel.formKey.currentState?.save();
                  await viewModel.onSavePress();
                }
              }
            },
          ),
        const Gap(
          direction: Axis.horizontal,
        ),
        if (viewModel.canEdit)
          CustomButton(
            label: "covenantsConditions.covenantEditDialog.cancel".tr(),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
      ],
    );
  }
}
