import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";

import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/fields/dynamic_radio_button.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/state.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/widgets/select_facilities_table.dart";

/// Desktop view for the select facilities dialog.
class ViewDesktop extends StatelessWidget {
  /// Creates the desktop view.
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectFacilitiesDialogViewModel,
        SelectFacilitiesDialogState>(
      builder: (context, state) {
        final viewModel = context.read<SelectFacilitiesDialogViewModel>();

        final bool showNoData = viewModel.isLinkedSecuritiesMode
            ? viewModel.linkedSecuritiesForLimit.isEmpty
            : viewModel.filteredData.isEmpty;

        switch (state.loaderStatus) {
          case LoadingStatus.loading:
            return const Center(
              child: CircularProgressIndicator(),
            );

          case LoadingStatus.error:
            return Center(
              child: Text("common.error".tr()),
            );
          default:
            return BoxLayout(
              disabled: !viewModel.canEdit,
              child: Column(
                children: [
                  if (viewModel.filteredData.isNotEmpty)
                    FormRow(
                      children: [
                        if (!viewModel.isFromSecuritySummary)
                          DynamicRadioButton(
                            viewModel: viewModel,
                          ),
                        const SizedBox(),
                      ],
                    ),
                  const Gap(),
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
                  SelectFacilitiesTable(
                    viewModel: viewModel,
                  ),
                  const Gap(),
                  if (!viewModel.isFromSecuritySummary)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(
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
                        ],
                      ),
                    ),
                  if (showNoData)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("common.noData".tr()),
                    ),
                ],
              ),
            );
        }
      },
    );
  }
}
