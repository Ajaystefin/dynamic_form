import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

/// A dynamic form field that displays a styled label/header
///
/// This field type is used for section headers or informational text
/// within a dynamic form. It does not accept user input.
class DynamicFormLabelField extends StatelessWidget {
  final DynamicField fieldData;

  const DynamicFormLabelField({
    super.key,
    required this.fieldData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        fieldData.label,
        style: const TextStyle(
          fontSize: AppStyle.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
