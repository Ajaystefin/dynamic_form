import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/sublimit_conditions_dialog/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/sublimit_conditions_dialog/state.dart";
import "package:wcas_frontend/features/request/facilities_securities/sublimit_conditions_dialog/widgets/non_std_condition_table.dart";
import "package:wcas_frontend/features/request/facilities_securities/sublimit_conditions_dialog/widgets/std_conditions_table.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";

/// Dialog for viewing and managing sub-limit standard and
/// non-standard conditions.
///
/// Allows users to select conditions and save them back to the
/// corresponding sub-limit row.
class ConditionsDialog extends StatelessWidget {
  /// Creates a conditions dialog.
  const ConditionsDialog({
    required this.createFacilityViewModel,
    required this.rowIndex,
    super.key,
    this.conditions,
  });

  /// View model used to access and update facility data.
  final CreateFacilityViewModel createFacilityViewModel;

  /// Index of the sub-limit row being edited.
  final int rowIndex;

  /// Existing conditions associated with the selected sub-limit.
  final List<StandardCondition>? conditions;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SubLimitConditionsViewModel>(
      create: (_) => SubLimitConditionsViewModel(
        standardConditions:
            createFacilityViewModel.subLimitTableStandardCondition,
        nonStandardConditions:
            createFacilityViewModel.subLimitTableNonStandardCondition,
        canEdit: createFacilityViewModel.canEdit,
        initialPageStandard:
            createFacilityViewModel.subLimitTableInitialPageStandardConditions,
        initialPageNonStandard: createFacilityViewModel
            .subLimitTableInitialPageNonStandardConditions,
        onAddNonStandard: createFacilityViewModel.addNonStandardToSubLimitList,
      ),
      child: BlocBuilder<SubLimitConditionsViewModel, SubLimitConditionsState>(
        builder: (context, state) {
          final SubLimitConditionsViewModel vm =
              context.read<SubLimitConditionsViewModel>();
          return Column(
            children: [
              SublimitStdConditionsTable(viewModel: vm),
              const Gap(),
              SublimitNonStdConditionTable(viewModel: vm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    label: "Save",
                    onPressed: () {
                      final List<Condition> std = vm.standardConditions
                          .where((c) => c.isSelected ?? false)
                          .toList();
                      final List<Condition> nonStd = vm.nonStandardConditions
                          .where((c) => c.isSelected ?? false)
                          .toList();
                      createFacilityViewModel.setSubLimitConditions(
                        rowIndex,
                        [...std, ...nonStd],
                      );
                      context.pop();
                    },
                  ),
                  const Gap(direction: Axis.horizontal, size: GapSize.small),
                  CustomButton(
                    label: "Cancel",
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
