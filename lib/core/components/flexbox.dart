import "package:flutter/material.dart";

class FlexBox extends StatelessWidget {
  const FlexBox({
    required this.children,
    super.key,
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
  });
  final Axis direction;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;
  final double spacing;
  final double runSpacing;
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
