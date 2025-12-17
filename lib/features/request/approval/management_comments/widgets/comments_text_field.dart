import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/validators.dart';

/// A reusable widget that displays a required label followed by a text area.
class CommentsTextField extends StatelessWidget {
  final String label;
  final String initialValue;
  final dynamic onSaved;

  const CommentsTextField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * .8;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: label,
          isRequired: true,
          labelStyle: AppStyle.tableHeaderStyle,
          child: CustomTextArea(
            semanticLabel: label,
            width: fieldWidth,
            autoFocus: false,
            maxLength: 5000,
            validator: CustomValidator.requiredField,
            initialValue: initialValue,
            onSaved: onSaved,
          ),
        ),
      ],
    );
  }
}
