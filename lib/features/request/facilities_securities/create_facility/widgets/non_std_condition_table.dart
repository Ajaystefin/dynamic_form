import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

/// Widget for displaying and managing non-standard facility conditions.
class NonStdConditionTable extends StatelessWidget {
  /// Creates a non-standard condition table widget.
  const NonStdConditionTable({
    required this.viewModel,
    super.key,
  });

  /// View model containing non-standard condition data and actions.
  final CreateFacilityViewModel viewModel;

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
          initialPage: viewModel.initialPageNonStandardConditions,
          onPageChange: (int pageNo) {
            viewModel.initialPageNonStandardConditions = pageNo;
          },
          rowsPerPage: 5,
          key: UniqueKey(),
          columns: columns,
          rowHeight: 80,
          rows: List.generate(viewModel.nonStandardCondition.length, (index) {
            return [
              if ((viewModel.nonStandardCondition[index].isAmended ?? false) ||
                  (viewModel.nonStandardCondition[index].isShowAsTextField ??
                      false))
                CustomTextField(
                  readOnly: viewModel.nonStandardCondition[index].isWaivedOff ??
                      false,
                  maxLength: 500,
                  maxLines: 2,
                  initialValue:
                      (viewModel.nonStandardCondition[index].description ?? "")
                          .replaceAll("[", "")
                          .replaceAll("]", ""),
                  onChanged: (String? value) {
                    // Keep non-empty; empty string required by DB
                    viewModel.nonStandardCondition[index].description =
                        value ?? " ";
                  },
                )
              else
                Text(
                  (viewModel.nonStandardCondition[index].description ?? "")
                      .replaceAll("[", "")
                      .replaceAll("]", ""),
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              Center(
                child: CustomCheckbox(
                  isEnabled:
                      !(viewModel.nonStandardCondition[index].isWaivedOff ??
                          false),
                  value: viewModel.nonStandardCondition[index].isSelected,
                  onChange: ({value}) {
                    viewModel.changeNonStandardConditionSelect(
                      index,
                      value: value ?? false,
                    );
                  },
                ),
              ),
              Center(
                child: IgnorePointer(
                  ignoring: !viewModel.isConditionAbleToAmendWaivedOff(index),
                  child: Opacity(
                    opacity: viewModel.isConditionAbleToAmendWaivedOff(index)
                        ? 1
                        : 0.5,
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
                              isEnabled: !(viewModel.nonStandardCondition[index]
                                      .isWaivedOff ??
                                  false),
                              value: viewModel
                                      .nonStandardCondition[index].isAmended ??
                                  false,
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
                              value: viewModel.nonStandardCondition[index]
                                      .isWaivedOff ??
                                  false,
                              onChange: ({value}) {
                                viewModel
                                    .changeWaivedOffNonStandardConditionSelect(
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
                ),
              ),
              Center(
                child: Visibility(
                  visible: viewModel.isConditionNotApproved(index),
                  child: IconButton(
                    tooltip: "Delete",
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.buttonBackground,
                    ),
                    onPressed:
                        (viewModel.nonStandardCondition[index].isWaivedOff ??
                                    false) &&
                                viewModel.canEdit
                            ? null
                            : () {
                                viewModel.removeNonStandardCondition(
                                  index,
                                  facilityConditionID: viewModel
                                      .nonStandardCondition[index]
                                      .facilityConditionId,
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
            onTap: viewModel.addNonStandardCondition,
            isLeftSided: true,
            child:
                Text("facilities.createFacility.addNonStandardCondition".tr()),
          ),
        const Gap(),
      ],
    );
  }
}
