import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// A customizable icon widget with optional tap handling and accessibility
/// support.
class CustomIcon extends StatelessWidget {
  /// Creates a [CustomIcon].
  const CustomIcon({
    required this.icon,
    super.key,
    this.size = 24.0,
    this.iconColor = AppColors.darkBlue,
    this.onTap,
    this.semanticLabel,
  });

  /// Icon to display.
  final IconData icon;

  /// Icon size.
  final double size;

  /// Icon color.
  final Color? iconColor;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// Callback invoked when the icon is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: FaIcon(
          icon,
          size: size,
          color: iconColor,
        ),
      ),
    );
  }
}
