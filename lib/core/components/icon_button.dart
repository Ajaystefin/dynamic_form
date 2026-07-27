import "package:flutter/material.dart";

/// Builds a tappable icon widget with customizable styling and accessibility.
Widget dynamicIcon({
  IconData icon = Icons.edit,
  double iconSize = 16,
  Color iconColor = Colors.blue,
  Color borderColor = Colors.grey,
  double padding = 4,
  double borderRadius = 4,
  VoidCallback? onTap,
  /// Semantic label for accessibility.
  String? semanticLabel,
}) {
  return Semantics(
    label: semanticLabel,
    button: true,
    child: Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
        ),
      ),
    ),
  );
}
