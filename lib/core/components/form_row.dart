import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/gap.dart";

/// A layout widget for arranging up to three form fields in a row.
class FormRow extends StatelessWidget {
  /// Creates a [FormRow].
  const FormRow({
    required this.children,
    super.key,
    this.stretch = true,
    this.crossAxisAlignment = CrossAxisAlignment.end,
  }) : assert(children.length <= 3, "Maximum of 3 widgets allowed");

  /// Child widgets displayed in the row.
  final List<Widget> children;

  /// Indicates whether children should stretch to fill available space.
  final bool stretch;

  /// Cross-axis alignment of the row.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (children.length == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Expanded(child: children[0]),
          const Gap(
            size: GapSize.form,
            direction: Axis.horizontal,
          ),
          Expanded(child: children.length > 1 ? children[1] : const SizedBox()),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Expanded(child: children[0]),
          const Gap(
            size: GapSize.form,
            direction: Axis.horizontal,
          ),
          Expanded(child: children.length > 1 ? children[1] : const SizedBox()),
          const Gap(
            size: GapSize.form,
            direction: Axis.horizontal,
          ),
          Expanded(child: children.length > 2 ? children[2] : const SizedBox()),
        ],
      );
    }
  }
}
