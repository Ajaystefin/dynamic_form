import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class BoxLayout extends StatelessWidget {
  final Widget child;
  final bool extraPadding;
  final Color? borderColor;
  final AlignmentGeometry? alignment;

  const BoxLayout(
      {super.key,
      required this.child,
      this.extraPadding = false,
      this.borderColor,
      this.alignment});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: alignment,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: borderColor ?? AppColors.scaffoldBorder,
            width: 6,
          ),
        ),
        padding: EdgeInsets.all(
            extraPadding ? AppStyle.spacingLarge : AppStyle.spacing),
        child: child);
  }
}
