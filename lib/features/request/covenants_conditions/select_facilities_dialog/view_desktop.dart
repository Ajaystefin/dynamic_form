import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/gap.dart';

import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/fields/dynamic_radio_button.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/fields/facilities_column_header_builder.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/widgets/data_row_builder.dart';
import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectFacilitiesDialogViewModel,
        SelectFacilitiesDialogState>(builder: (context, state) {
      final viewModel = context.read<SelectFacilitiesDialogViewModel>();

      final filterManager = FacilitiesColumnHeaderBuilder(viewModel);
      final dataRowBuilder = FacilitiesDataRowBuilder(viewModel);
      switch (state.loaderStatus) {
        case LoadingStatus.loading:
          return const Center(
            child: CircularProgressIndicator(),
          );
        case LoadingStatus.empty:
          return Center(
            child: Text('common.noData'.tr()),
          );
        case LoadingStatus.error:
          return Center(
            child: Text('common.error'.tr()),
          );
        default:
          return Column(
            children: [
              if (viewModel.filteredData.isNotEmpty)
                FormRow(
                  children: [
                    if (!viewModel.isFromSecuritySummary)
                      DynamicRadioButton(
                        viewModel: viewModel,
                      ),
                    const SizedBox(),
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
              if (viewModel.filteredData.isNotEmpty)
                CustomRawTable(
                  key: UniqueKey(),
                  columns: filterManager.createColumns(),
                  rows: dataRowBuilder.buildRows(),
                  rowsPerPage: viewModel.rowsPerPage,
                  showPagination: true,
                  isFilterTable: true,
                  headerColor: AppColors.tableHeadingColor,
                ),
              if (viewModel.filteredData.isEmpty)
                Center(
                  child: Text('common.emptyState'.tr()),
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
                                ? () {
                                    viewModel
                                        .saveSelectionAndCloseDialog(context);
                                  }
                                : null),
                      ],
                    )),
            ],
          );
      }
    });
  }
}
