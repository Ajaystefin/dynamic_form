import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// Checkbox widget used in the SFF table.
class SffCheckbox extends StatelessWidget {
  /// Creates an SFF checkbox.
  const SffCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
    this.width,
    this.isReadOnly = false,
  });

  /// Current checkbox value.
  final bool value;

  /// Optional width of the checkbox container.
  final double? width;

  /// Callback invoked when the checkbox value changes.
  final ValueChanged<bool?> onChanged;

  /// Indicates whether the checkbox is read-only.
  final bool? isReadOnly;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomCheckbox(
        value: value,
        onChange: isReadOnly ?? false
            ? ({bool? value}) {}
            : ({bool? value}) => onChanged(value), //  No-op when read-only
        activeColor: AppColors.primary,
      ),
    );
  }
}
