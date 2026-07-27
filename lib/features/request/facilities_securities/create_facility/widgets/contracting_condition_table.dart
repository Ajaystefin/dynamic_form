import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/std_conditions_table.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";

/// Widget for displaying and managing contracting standard conditions.
class ContractingStandardConditionsTable extends StatelessWidget {
  /// Creates a contracting standard conditions table widget.
  const ContractingStandardConditionsTable({
    required this.viewModel,
    super.key,
  });

  /// View model containing contracting standard conditions data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final List<TableColumn> columns = <TableColumn>[
      TableColumn(
        forcedWidth: 520.w,
        label:
            Text("facilities.createFacility.contractingStandardCondition".tr()),
      ),
      TableColumn(
        forcedWidth: 40,
        label: Text("facilities.createFacility.select".tr()),
      ),
      TableColumn(
        forcedWidth: 40,
        label: Text("facilities.createFacility.action".tr()),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomRawTable(
          rowsPerPage: 5,
          key: UniqueKey(),
          initialPage: viewModel.initialPageContractingConditions,
          onPageChange: (int pageNo) {
            viewModel.initialPageContractingConditions = pageNo;
          },
          columns: columns,
          rowHeight: 80,
          rows: List<List<Widget>>.generate(
              viewModel.contractingStandardCondition.length, (int index) {
            final Condition item =
                viewModel.contractingStandardCondition[index];

            final bool isWaivedOff =
                viewModel.contractingStandardCondition[index].isWaivedOff ??
                    false;
            final TextStyle descriptionStyle = TextStyle(
              color: isWaivedOff ? AppColors.tableCellColorGroupedRow : null,
            );

            final String description = item.description ?? "";
            String stripBrackets(String s) =>
                s.replaceAll("[", "").replaceAll("]", "");
            // Detect if there is at least one dots run
            // final RegExp dotsRegex = RegExp(r"\.{3,}");
            // final bool hasDots = dotsRegex.hasMatch(description);

            // Build description cell with multi editable placeholders when
            // needed
            final Widget descriptionCell =
                (viewModel.contractingStandardCondition[index].isAmended ??
                        false)
                    ? MultiEditableText(
                        text: description,
                        style: descriptionStyle,
                        enabled: !isWaivedOff,
                        onSubmittedFullText: (String newFullText) {
                          viewModel.contractingStandardCondition[index]
                              .description = newFullText;
                        },
                      )
                    : Text(
                        stripBrackets(description),
                        style: descriptionStyle,
                        textAlign: TextAlign.left,
                      );

            return <Widget>[
              // FIRST COLUMN: description (with multiple editable placeholders
              // if "..." exist)
              descriptionCell,

              // SECOND COLUMN: Select checkbox (disabled if waived-off)
              Center(
                child: CustomCheckbox(
                  isEnabled: !(viewModel
                          .contractingStandardCondition[index].isWaivedOff ??
                      false),
                  value:
                      viewModel.contractingStandardCondition[index].isSelected,
                  onChange: ({bool? value}) {
                    final bool next = value ?? false;
                    viewModel.changeContractingStandardConditionSelect(
                      index,
                      value: next,
                    );
                  },
                ),
              ),

              // THIRD COLUMN: actions (Amend & Waive-off)
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
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
                          isEnabled: !(viewModel
                                  .contractingStandardCondition[index]
                                  .isWaivedOff ??
                              false),
                          value: viewModel
                              .contractingStandardCondition[index].isAmended,
                          onChange: ({bool? value}) {
                            viewModel
                                .changeAmendContractingStandardConditionSelect(
                              index,
                              value: value ?? false,
                            );
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
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
                              .contractingStandardCondition[index].isWaivedOff,
                          onChange: ({bool? value}) {
                            final bool next = value ?? false;
                            // Waived-off standard condition selection
                            viewModel
                                .selectWaivedOffContractingStandardCondition(
                              index,
                              value: next,
                            );
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
        if (viewModel.contractingStandardCondition.isEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: AppStyle.spacingColum),
            child: Center(
              child: Text(
                "facilities.createFacility."
                        "contractingStandardConditionEmptyMessage"
                    .tr(),
              ),
            ),
          ),
      ],
    );
  }
}
