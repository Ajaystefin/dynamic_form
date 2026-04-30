import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

class AddRimButton extends StatelessWidget {
  const AddRimButton({
    required this.viewModel,
    super.key,
  });
  final CovenantEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: viewModel.onAddButtonPress,
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: AppColors.primary, size: 20),
                const SizedBox(width: 4),
                Text(
                  "covenantsConditions.covenantEditDialog.addRim".tr(),
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
