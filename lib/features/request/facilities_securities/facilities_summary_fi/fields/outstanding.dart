import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';

class OutstandingAmount extends StatelessWidget {
  final CustomerFacility customer;
  final Facility? facility;
  const OutstandingAmount(
      {super.key, required this.customer, required this.facility});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
        validator: CustomValidator.requiredField,
        initialValue: facility?.outstanding.toString(),
        onSaved: (String? value) {
          facility?.outstanding = int.tryParse(value ?? '');
        });
  }
}
