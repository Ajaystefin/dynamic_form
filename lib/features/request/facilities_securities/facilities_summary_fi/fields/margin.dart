import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';

class Margin extends StatelessWidget {
  final Facility? facility;
  final CustomerFacility customer;

  const Margin({super.key, required this.customer, required this.facility});
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
        initialValue: facility?.margin,
        validator: CustomValidator.requiredField,
        onSaved: (String? value) {
          facility?.margin = (value);
        });
  }
}
