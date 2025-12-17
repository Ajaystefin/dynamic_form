import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';

class TenorDays extends StatelessWidget {
  final CustomerFacility customer;
  final Facility? facility;
  const TenorDays({super.key, required this.customer, required this.facility});
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
        initialValue: facility?.tenorDays.toString(),
        validator: CustomValidator.requiredField,
        onSaved: (String? value) {
          facility?.tenorDays = int.tryParse(value ?? "");
        });
  }
}
