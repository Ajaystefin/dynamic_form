import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
// import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary_list.dart';

class ApplicablePricing extends StatelessWidget {
  final Facility? facility;
  final FacilitySummaryList customer;

  const ApplicablePricing(
      {super.key, required this.facility, required this.customer});
  @override
  Widget build(BuildContext context) {
    return Text(
      facility?.applicablePricing ?? "",
      style: const TextStyle(
        color: AppColors.darkBlue,
      ),
    );
  }
}
