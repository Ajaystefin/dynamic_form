import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";

/// A reusable widget that displays a required label followed by a text area.
class CommentsTextField extends StatelessWidget {
  /// Creates a comments text field with a label and text area.
  const CommentsTextField({
    required this.label,
    required this.initialValue,
    required this.onSaved,
    required this.isReadOnly,
    super.key,
    this.onChange,
  });

  /// Label displayed above the text area.
  final String label;

  /// Initial value displayed in the text area.
  final String initialValue;

  /// Callback triggered when the form field is saved.
  final dynamic onSaved;

  /// Indicates whether the text area should be read-only.
  final bool isReadOnly;

  /// Callback triggered when the text area value changes.
  final ValueChanged<String>? onChange;

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
            maxLength: 5000,
            validator: CustomValidator.requiredField,
            initialValue: initialValue,
            onSaved: onSaved,
            onChanged: onChange,
            readOnly: isReadOnly,
          ),
        ),
      ],
    );
  }
}
