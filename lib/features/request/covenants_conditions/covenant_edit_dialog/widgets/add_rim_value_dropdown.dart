import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/state.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/add_name_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/add_rim_no_field.dart';

class AddRimValueDropdown extends StatelessWidget {
  final CovenantEditDialogViewModel viewModel;
  final CovenantEditDialogState state;
  const AddRimValueDropdown(
      {super.key, required this.viewModel, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(),
        ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppStyle.linkContractScopeField),
          child: BoxLayout(
            child: Column(
              children: [
                Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 1,
                        child: AddCustomerRimField(viewModel: viewModel),
                      ),
                      const Gap(direction: Axis.horizontal),
                      if (state.searchLoaderStatus == LoadingStatus.loading)
                        const CircularProgressIndicator(),
                      Expanded(
                        flex: 1,
                        child: AddCustomerNameField(viewModel: viewModel),
                      ),
                    ]),
                const Gap(),
                Row(
                  children: [
                    CustomButton(
                      semanticLabel:
                          "covenantsConditions.covenantEditDialog.add".tr(),
                      label: "covenantsConditions.covenantEditDialog.add".tr(),
                      onPressed: viewModel.onAddRim,
                    ),
                    const Gap(direction: Axis.horizontal),
                    CustomButton(
                      semanticLabel:
                          "covenantsConditions.covenantEditDialog.cancel".tr(),
                      label: "covenantsConditions.covenantEditDialog.cancel".tr(),
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
