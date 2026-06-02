import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/facilities_securities/sublimit_conditions/model.dart";

class SublimitNonStdConditionTable extends StatelessWidget {
  const SublimitNonStdConditionTable({
    required this.viewModel,
    super.key,
  });
  final SubLimitConditionsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final columns = <TableColumn>[
      TableColumn(
        forcedWidth: 500.w,
        label: Text("facilities.createFacility.nonStandardCondition".tr()),
      ),
      TableColumn(
        forcedWidth: 40,
        label: Text("facilities.createFacility.select".tr()),
      ),
      TableColumn(
        forcedWidth: 50,
        label: Text("facilities.createFacility.action".tr()),
      ),
      const TableColumn(
        forcedWidth: 40,
        label: Text("Delete"),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomRawTable(
          initialPage: viewModel.initialPageNonStandard,
          onPageChange: (int pageNo) {
            viewModel.initialPageNonStandard = pageNo;
          },
          rowsPerPage: 5,
          key: UniqueKey(),
          columns: columns,
          rowHeight: 80,
          rows: List.generate(
              viewModel.nonStandardConditions.length, (index) {
            return [
              if (viewModel.nonStandardConditions[index].isAmended ?? false)
                CustomTextField(
                  readOnly:
                      viewModel.nonStandardConditions[index].isWaivedOff ??
                          false,
                  maxLength: 500,
                  maxLines: 2,
                  initialValue: (viewModel
                              .nonStandardConditions[index].description ??
                          "")
                      .replaceAll("[", "")
                      .replaceAll("]", ""),
                  onChanged: (String? value) {
                    viewModel.nonStandardConditions[index].description =
                        value ?? " ";
                  },
                )
              else
                Text(
                  (viewModel.nonStandardConditions[index].description ?? "")
                      .replaceAll("[", "")
                      .replaceAll("]", ""),
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              Center(
                child: CustomCheckbox(
                  isEnabled: !(viewModel.nonStandardConditions[index].isWaivedOff ?? false),
                  value: viewModel.nonStandardConditions[index].isSelected,
                  onChange: ({value}) {
                    viewModel.changeNonStandardConditionSelect(
                      index,
                      value: value ?? false,
                    );
                  },
                ),
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Amend",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.darkBlue,
                            ),
                          ),
                        ),
                        CustomCheckbox(
                          isEnabled: !(viewModel.nonStandardConditions[index].isWaivedOff ?? false),
                          value: viewModel.nonStandardConditions[index].isAmended ?? false,
                          onChange: ({value}) {
                            viewModel.changeAmendNonStandardConditionSelect(
                              index,
                              value: value ?? false,
                            );
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
                          value: viewModel.nonStandardConditions[index].isWaivedOff ?? false,
                          onChange: ({value}) {
                            viewModel.changeWaivedOffNonStandardConditionSelect(
                              index,
                              value: value ?? false,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Center(
                child: Visibility(
                  visible: viewModel.canDeleteNonStandard(index),
                  child: IconButton(
                    tooltip: "Delete",
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.buttonBackground,
                    ),
                    onPressed: (viewModel.nonStandardConditions[index].isWaivedOff ?? false) &&
                            viewModel.canEdit
                        ? null
                        : () {
                            viewModel.removeNonStandard(
                              index,
                              facilityConditionId: viewModel
                                  .nonStandardConditions[index].facilityConditionId,
                            );
                          },
                  ),
                ),
              ),
            ];
          }),
        ),
        if (viewModel.canEdit)
          AddItemButton(
            onTap: viewModel.addNonStandard,
            isLeftSided: true,
            child: Text("facilities.createFacility.addNonStdCondition".tr()),
          ),
        const Gap(),
      ],
    );
  }
}
