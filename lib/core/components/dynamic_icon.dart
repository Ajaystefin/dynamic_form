import "package:flutter/material.dart";

/// Builds a tappable icon widget with a customizable appearance.
Widget dynamicIcon({
  IconData icon = Icons.edit,
  double iconSize = 16,
  Color iconColor = Colors.blue,
  Color borderColor = Colors.grey,
  double padding = 4,
  double borderRadius = 4,
  VoidCallback? onTap,
  String? semanticLabel,
}) {
  return Center(
    child: Semantics(
      button: true,
      label: semanticLabel,
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
