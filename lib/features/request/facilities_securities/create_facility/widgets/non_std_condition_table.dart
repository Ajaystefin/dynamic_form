import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/add_item_button.dart';
import 'package:wcas_frontend/core/components/checkbox.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_detail.dart';

class NonStdConditionTable extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  final List<Condition>? conditions;
  const NonStdConditionTable({
    super.key,
    required this.viewModel,
    this.conditions,
  });

  @override
  Widget build(BuildContext context) {
    final columns = <TableColumn>[
      TableColumn(
        forcedWidth: 500.w,
        label: Text('facilities.createFacility.nonStandardCondition'.tr()),
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
          rows: List.generate((conditions ?? []).length, (index) {
            return [
              (viewModel.actionsNonStandardWaiveOffSelected[index]) ||
                      (!viewModel.isNewlyAddedNonStandardCondition[index])
                  ? Text(
                      conditions?[index].conditionType?.name ?? "",
                      style: viewModel.actionsNonStandardWaiveOffSelected[index]
                          ? const TextStyle(
                              color: AppColors.tableCellColorGroupedRow)
                          : null,
                    )
                  : CustomTextField(
                      initialValue: conditions?[index].description ?? "",
                      onChanged: (value) {
                        conditions?[index].description = value;
                      },
                    ),
              Center(
                child: CustomCheckbox(
                  value: viewModel.nonStandardConditionsSelected[index],
                  onChange: (value) {
                    viewModel.actionsNonStandardWaiveOffSelected[index]
                        ? null
                        : viewModel.changeNonStandardConditionSelect(
                            index, value ?? false);
                  },
                ),
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conditions![index].isAmended ?? false
                                ? "Amend"
                                : "Non Amend",
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.darkBlue,
                            ),
                          ),
                        ),
                       CustomCheckbox(
  value: viewModel.actionsNonStandardAmendSelected[index],
  onChange: (value) {
    viewModel.actionsNonStandardWaiveOffSelected[index]
        ? null
        : viewModel.changeAmendNonStandardConditionSelect(index, value ?? false);
  },
),
                      ],
                    ),
                    // const Gap(),
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
                          value: viewModel
                              .actionsNonStandardWaiveOffSelected[index],
                          onChange: (value) {
                            viewModel.changeWaivedOffNonStandardConditionSelect(
                                index, value ?? false);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ];
          }),
        ),
        AddItemButton(
          onTap: () => viewModel.addNonStandardCondition(),
          isLeftSided: true,
          child: Text("facilities.createFacility.addNonStdCondition".tr()),
        ),
        const Gap(size: GapSize.medium),
      ],
    );
  }
}
