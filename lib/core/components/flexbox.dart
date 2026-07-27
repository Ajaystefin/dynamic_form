import "package:flutter/material.dart";

/// A flexible layout widget based on [Wrap].
class FlexBox extends StatelessWidget {
  /// Creates a [FlexBox].
  const FlexBox({
    required this.children,
    super.key,
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
  });

  /// Layout direction.
  final Axis direction;

  /// Main-axis alignment.
  final WrapAlignment alignment;

  /// Cross-axis alignment.
  final WrapCrossAlignment crossAxisAlignment;

  /// Spacing between children.
  final double spacing;

  /// Spacing between runs.
  final double runSpacing;

  /// Child widgets.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: direction,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: children,
    );
  }
}
