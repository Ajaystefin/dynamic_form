import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/sublimit_conditions/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/sublimit_conditions/state.dart";
import "package:wcas_frontend/features/request/facilities_securities/sublimit_conditions/widgets/non_std_condition_table.dart";
import "package:wcas_frontend/features/request/facilities_securities/sublimit_conditions/widgets/std_conditions_table.dart";
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
    return BlocProvider<SubLimitConditionsViewModel>(
      create: (_) => SubLimitConditionsViewModel(
        standardConditions: viewModel.subLimitTableStandardCondition,
        nonStandardConditions: viewModel.subLimitTableNonStandardCondition,
        canEdit: viewModel.canEdit,
        initialPageStandard:
            viewModel.subLimitTableInitialPageStandardConditions,
        initialPageNonStandard:
            viewModel.subLimitTableInitialPageNonStandardConditions,
        onAddNonStandard: viewModel.addNonStandardToSubLimitList,
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
                      viewModel.setSubLimitConditions(
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
