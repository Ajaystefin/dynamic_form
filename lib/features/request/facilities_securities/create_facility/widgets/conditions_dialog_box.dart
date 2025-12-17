import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/non_std_condition_table.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/std_conditions_table.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';

class ConditionsDialogBox extends StatelessWidget {
  final CreateFacilityViewModel viewModel;

  final List<StandardCondition>? conditions;
  const ConditionsDialogBox(
      {super.key, required this.viewModel, this.conditions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConditionsTable(
          viewModel: viewModel,
          conditions: viewModel.conditions,
        ),
        const Gap(),
        NonStdConditionTable(
          viewModel: viewModel,
          conditions: viewModel.nonStandardCondition,
        ),
      ],
    );
  }
}
