import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/checkbox.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class SffCheckbox extends StatelessWidget {
  final bool value;
  final double? width;
  final ValueChanged<bool?> onChanged;
  final bool? isReadOnly;

  const SffCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.width,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomCheckbox(
        value: value,

        onChange:
            isReadOnly == true ? (v) {} : onChanged, // ✅ No-op when read-only
        activeColor: AppColors.primary,
      ),
    );
  }
}
