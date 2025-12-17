import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/checkbox.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_condition_list.dart';

class ConditionsTable extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  final List<FacilityCondition> conditions;

  const ConditionsTable({
    super.key,
    required this.viewModel,
    required this.conditions,
  });

  @override
  Widget build(BuildContext context) {
    final columns = <TableColumn>[
      TableColumn(
        forcedWidth: 500.w,
        label: Text('facilities.createFacility.standardCondition'.tr()),
      ),
      TableColumn(
        forcedWidth: 50,
        label: Text('facilities.createFacility.select'.tr()),
      ),
      TableColumn(
        forcedWidth: 50,
        label: Text('facilities.createFacility.action'.tr()),
      ),
    ];

    // Ensure selection arrays have the right length (safe-guard, minimal)
    final int len = conditions.length;
    if (viewModel.standardConditionsSelected.length != len) {
      viewModel.standardConditionsSelected =
          List<bool>.filled(len, false, growable: false);
    }
    if (viewModel.actionsStandardAmendSelected.length != len) {
      viewModel.actionsStandardAmendSelected =
          List<bool>.filled(len, false, growable: false);
    }
    if (viewModel.actionsStandardWaiveOffSelected.length != len) {
      viewModel.actionsStandardWaiveOffSelected =
          List<bool>.filled(len, false, growable: false);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomRawTable(
          showPagination: true,
          rowsPerPage: 5,
          key: UniqueKey(),
          columns: columns,
          autoFitWidth: true,
          rowHeight: 80,
          rows: List.generate(conditions.length, (index) {
            final item = conditions[index];
            return [
              // FIRST COLUMN: use reference3 from API response
              Text(
                item.reference3 ?? "",
                style: TextStyle(
                  color: viewModel.actionsStandardWaiveOffSelected[index]
                      ? AppColors.tableCellColorGroupedRow
                      : null,
                ),
              ),

              // SECOND COLUMN: checkbox (reuse existing viewmodel arrays)
              Center(
                child: CustomCheckbox(
                  value: viewModel.standardConditionsSelected[index],
                  onChange: (value) {
                    viewModel.actionsStandardWaiveOffSelected[index]
                        ? null
                        : viewModel.changeStandardConditionSelect(
                            index, value ?? false);
                  },
                ),
              ),

              // THIRD COLUMN: actions (Amend & Waive-off)
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            // we don't have isAmended in FacilityCondition;
                            // keep the same label logic but drive underline only
                            (viewModel.actionsStandardAmendSelected[index])
                                ? "Amended"
                                : "Non Amend",
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.darkBlue,
                            ),
                          ),
                        ),
                        CustomCheckbox(
                          value: viewModel.actionsStandardAmendSelected[index],
                          onChange: (value) {
                            viewModel.changeAmendStandardConditionSelect(
                                index, value ?? false);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Waive-off",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.darkBlue,
                            ),
                          ),
                        ),
                        CustomCheckbox(
                          value:
                              viewModel.actionsStandardWaiveOffSelected[index],
                          onChange: (value) {
                            viewModel.changeWaivedOffStandardConditionSelect(
                                index, value ?? false);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ];
          }),
        ),
      ],
    );
  }
}
