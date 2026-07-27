import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";

/// CustomTextField stateless widget

class CustomTextField extends StatelessWidget {
  /// Creates [CustomTextField] instance

  const CustomTextField({
    required this.label,
    super.key,
  });

  /// Label
  final String label;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: label,
      child: const CustomTextArea(
        initialValue: "",
        maxLength: 5000,
      ),
    );
  }
}
