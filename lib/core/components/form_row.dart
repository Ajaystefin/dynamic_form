import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/gap.dart';

class FormRow extends StatelessWidget {
  final List<Widget> children;
  final bool stretch;
  final CrossAxisAlignment crossAxisAlignment;

  const FormRow({
    super.key,
    required this.children,
    this.stretch = true,
    this.crossAxisAlignment = CrossAxisAlignment.end,
  }) : assert(children.length <= 3, 'Maximum of 3 widgets allowed');

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
