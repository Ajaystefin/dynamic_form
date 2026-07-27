import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// Displays a styled section header with an optional leading indicator.
class CustomSectionHeader extends StatelessWidget {
  /// Creates a [CustomSectionHeader].
  const CustomSectionHeader({
    required this.title,
    super.key,
    this.textStyle,
    this.leadingColor,
    this.leadingWidth,
    this.color,
    this.enableEllipsis = false,
    this.maxLines,
    this.ellipsisCharLimit,
  });

  /// Title text to show.
  final String title;

  /// Custom text style for the title.
  final TextStyle? textStyle;

  /// Color of the leading indicator.
  final Color? leadingColor;

  /// Width of the leading indicator.
  final double? leadingWidth;

  /// Background color of the header.
  final Color? color;

  /// Enables truncated title display with ellipsis.
  final bool enableEllipsis;

  /// Maximum number of lines when ellipsis is enabled.
  final int? maxLines;

  /// Maximum number of characters displayed before truncation.
  final int? ellipsisCharLimit;

  /// Returns the title text to display, applying truncation when configured.
  String get _displayTitle {
    if (!enableEllipsis || ellipsisCharLimit == null) {
      return title;
    }

    if (title.length <= ellipsisCharLimit!) {
      return title;
    }

    return "${title.substring(0, ellipsisCharLimit)}...";
  }

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
              _displayTitle,
              maxLines: enableEllipsis ? (maxLines ?? 2) : null,
              overflow:
                  enableEllipsis ? TextOverflow.ellipsis : TextOverflow.visible,
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
