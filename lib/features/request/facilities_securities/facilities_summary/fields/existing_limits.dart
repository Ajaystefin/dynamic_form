import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';

class ExistingLimits extends StatelessWidget {
  final FacilitiesSummaryViewModel viewModel;

  final Facility? facility;
  const ExistingLimits(
      {super.key, required this.viewModel, required this.facility});

  @override
  Widget build(BuildContext context) {
    return Text(
      "${facility?.existingLimits ?? ""}",
      style: const TextStyle(
        color: AppColors.darkBlue,
      ),
    );
  }
}
