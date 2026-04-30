import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/non_std_condition_table.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/std_conditions_table.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";

class ConditionsDialogBox extends StatelessWidget {
  const ConditionsDialogBox({
    required this.viewModel,
    required this.rowIndex,
    super.key,
    this.conditions,
  });
  final CreateFacilityViewModel viewModel;
  final int rowIndex;
  final List<StandardCondition>? conditions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConditionsTable(
          viewModel: viewModel,
        ),
        const Gap(),
        NonStdConditionTable(
          viewModel: viewModel,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomButton(
              label: "Save",
              onPressed: () {
                // 1) Gather STANDARD conditions that are selected
                final List<Condition> std = <Condition>[];
                for (var i = 0; i < viewModel.standardCondition.length; i++) {
                  if (viewModel.standardCondition[i].isSelected ?? false) {
                    final Condition c = viewModel.standardCondition[i];
                    // c.isAmended = viewModel.actionsStandardAmendSelected[i];
                    // c.isWaivedOff =
                    // viewModel.actionsStandardWaiveOffSelected[i];
                    std.add(c);
                  }
                }
                // 2) Gather NON-STANDARD conditions that are selected
                final List<Condition> nonStd = <Condition>[];
                for (var i = 0;
                    i < viewModel.nonStandardCondition.length;
                    i++) {
                  if (viewModel.nonStandardCondition[i].isSelected ?? false) {
                    final Condition c = viewModel.nonStandardCondition[i];
                    // c.isAmended =
                    // viewModel.actionsNonStandardAmendSelected[i];
                    // c.isWaivedOff =
                    //     viewModel.actionsNonStandardWaiveOffSelected[i];
                    nonStd.add(c);
                  }
                }
                // 3) Persist for this row
                viewModel.setSubLimitConditions(rowIndex, [...std, ...nonStd]);

                context.pop();
              },
            ),
            CustomButton(label: "Cancel", onPressed: () => context.pop()),
          ],
        ),
      ],
    );
  }
}
