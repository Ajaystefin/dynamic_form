import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.label,
    super.key,
  });
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
