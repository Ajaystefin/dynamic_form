import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";

class CustomSectionHeader extends StatelessWidget {
  const CustomSectionHeader({
    required this.title,
    super.key,
    this.textStyle,
    this.leadingColor,
    this.leadingWidth,
    this.color,
  });

  /// Title text to show
  final String title;

  /// Customize title text
  final TextStyle? textStyle;

  /// To change the leading box color
  final Color? leadingColor;

  /// To change the width of leading box
  final double? leadingWidth;

  /// To change the color of the widget
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          VerticalDivider(
            color: leadingColor ?? AppColors.primary,
            width: leadingWidth ?? 8,
            thickness: leadingWidth ?? 8,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(15, 6, 30, 6),
            decoration: BoxDecoration(
              color: color ?? AppColors.secondary,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Text(
              title,
              style: textStyle ??
                  const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
