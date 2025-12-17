import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';

class OutstandingAmount extends StatelessWidget {
  final Facility? facility;
  const OutstandingAmount({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    return Text(
      "${facility?.outstanding ?? ""}",
      style: const TextStyle(
        color: AppColors.darkBlue,
      ),
    );
  }
}
