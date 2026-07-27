import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/fields/dynamic_radio_button.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/state.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/widgets/select_facilities_table.dart";

/// Mobile view for the select facilities dialog.
class ViewMobile extends StatelessWidget {
  /// Creates the mobile view.
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<SelectFacilitiesDialogViewModel>();
    return BlocBuilder<SelectFacilitiesDialogViewModel,
        SelectFacilitiesDialogState>(
      builder: (context, state) {
        final viewModel = context.read<SelectFacilitiesDialogViewModel>();
        switch (state.loaderStatus) {
          case LoadingStatus.loading:
            return const Center(
              child: CircularProgressIndicator(),
            );
          case LoadingStatus.empty:
            return Center(
              child: Text("common.emptyState".tr()),
            );
          case LoadingStatus.error:
            return Center(
              child: Text("common.errorState".tr()),
            );
          default:
            return Column(
              children: [
                if (viewModel.filteredData.isNotEmpty)
                  if (!viewModel.isFromSecuritySummary)
                    DynamicRadioButton(
                      viewModel: viewModel,
                    ),
                const Gap(),
                if (viewModel.filteredData.isNotEmpty)
                  SelectFacilitiesTable(
                    viewModel: viewModel,
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "security.securitySummary.aed".tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const Gap(),
                if (viewModel.filteredData.isEmpty)
                  Center(
                    child: Text("common.emptyState".tr()),
                  ),
                const Gap(),
                if (!viewModel.isFromSecuritySummary)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomButton(
                            label:
                                "covenantsConditions.selectFacilityDialog.save"
                                    .tr(),
                            onPressed: (viewModel.filteredData.isNotEmpty)
                                ? viewModel.canEdit
                                    ? () {
                                        viewModel.saveSelectionAndCloseDialog(
                                          context,
                                        );
                                      }
                                    : null
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
        }
      },
    );
  }
}
