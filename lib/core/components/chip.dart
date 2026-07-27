import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// A selectable chip widget.
class CustomChip extends StatelessWidget {
  /// Creates a [CustomChip].
  const CustomChip({
    required this.onPressed,
    required this.isActive,
    required this.label,
    super.key,
    this.showAsterisk = false,
  });

  /// Callback invoked when the chip is pressed.
  final VoidCallback onPressed;

  /// Indicates whether the chip is active.
  final bool isActive;

  /// Text displayed on the chip.
  final String label;

  /// Whether to display a required-field asterisk.
  final bool showAsterisk;
  
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isActive ? AppColors.primary : null,
        side: BorderSide(
          color: isActive ? AppColors.white : AppColors.primary,
          width: 0,
        ),
      ),
      child: Text.rich(
        TextSpan(
          text: label,
          children: showAsterisk
              ? [
                  const TextSpan(
                    text: " *",
                    style: TextStyle(color: AppColors.failure),
                  ),
                ]
              : [],
        ),
        style: TextStyle(
          fontSize: 16,
          color: isActive ? AppColors.white : AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
