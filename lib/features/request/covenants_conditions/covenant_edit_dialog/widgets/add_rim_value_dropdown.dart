import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/state.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/add_name_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/add_rim_no_field.dart";

/// Add RIM value dropdown for the covenant edit dialog.
class AddRimValueDropdown extends StatelessWidget {
  /// Creates an add RIM value dropdown.
  const AddRimValueDropdown({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Covenant edit dialog state.
  final CovenantEditDialogState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(),
        ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppStyle.linkContractScopeField),
          child: BoxLayout(
            disabled: !viewModel.canEdit,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: AddCustomerRimField(viewModel: viewModel),
                    ),
                    const Gap(direction: Axis.horizontal),
                    if (state.searchLoaderStatus == LoadingStatus.loading)
                      const CircularProgressIndicator(),
                    Expanded(
                      child: AddCustomerNameField(viewModel: viewModel),
                    ),
                  ],
                ),
                const Gap(),
                if (viewModel.canEdit)
                  Row(
                    children: [
                      CustomButton(
                        semanticLabel:
                            "covenantsConditions.covenantEditDialog.add".tr(),
                        label:
                            "covenantsConditions.covenantEditDialog.add".tr(),
                        onPressed: viewModel.addSearchedRimToList,
                      ),
                      const Gap(direction: Axis.horizontal),
                      CustomButton(
                        semanticLabel:
                            "covenantsConditions.covenantEditDialog.cancel"
                                .tr(),
                        label: "covenantsConditions.covenantEditDialog.cancel"
                            .tr(),
                        onPressed: viewModel.onCancelPress,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
