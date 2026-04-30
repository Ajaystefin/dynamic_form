import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/constants/constants.dart";

class SffCheckbox extends StatelessWidget {
  const SffCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
    this.width,
    this.isReadOnly = false,
  });
  final bool value;
  final double? width;
  final ValueChanged<bool?> onChanged;
  final bool? isReadOnly;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomCheckbox(
        value: value,
        onChange:
            isReadOnly == true ? (v) {} : onChanged, //  No-op when read-only
        activeColor: AppColors.primary,
      ),
    );
  }
}
