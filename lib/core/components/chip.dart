import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";

class CustomChip extends StatelessWidget {
  const CustomChip({
    required this.onPressed,
    required this.isActive,
    required this.label,
    super.key,
    this.showAsterisk = false,
  });
  final VoidCallback onPressed;
  final bool isActive;
  final String label;
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
