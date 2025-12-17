import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';

class ApplicablePricing extends StatelessWidget {
  final Facility? facility;
  final CustomerFacility customer;

  const ApplicablePricing(
      {super.key, required this.facility, required this.customer});
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      validator: CustomValidator.requiredField,
      initialValue: facility?.applicablePricing,
      onSaved: (String? value) {
        facility?.applicablePricing = value;
      },
    );
  }
}
