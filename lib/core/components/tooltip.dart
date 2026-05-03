import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";

class CustomTooltip extends StatelessWidget {
  const CustomTooltip({
    required this.message,
    required this.child,
    super.key,
    this.textStyle,
    this.decoration,
    this.waitDuration,
    this.height,
    this.padding,
    this.margin,
    this.preferBelow,
    this.showDuration,
    this.verticalOffset,
    this.textAlign,
    this.showTooltip = true,
    this.isRichMessage = false,
  });

  final String message;
  final Widget child;
  final TextStyle? textStyle;
  final Decoration? decoration;
  final Duration? waitDuration;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool? preferBelow;
  final bool showTooltip;
  final Duration? showDuration;
  final double? verticalOffset;
  final TextAlign? textAlign;
  final bool isRichMessage;

  @override
  Widget build(BuildContext context) {
    if (!showTooltip) return child;
    return Tooltip(
      message: isRichMessage ? null : message,
      richMessage: isRichMessage
          ? WidgetSpan(
              child: SizedBox(
                width: 300,
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppStyle.columnName,
                  ),
                ),
              ),
            )
          : null,
      height: height,
      // constraints:
      //     height != null ? BoxConstraints(minHeight: height ?? 0) : null,
      textStyle: isRichMessage
          ? null
          : const TextStyle(
              color: AppColors.white,
              fontSize: AppStyle.columnName,
            ),
      decoration: BoxDecoration(
        color: AppColors.customToolTipBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.customToolTipBg, width: 1),
      ),
      waitDuration: waitDuration ?? const Duration(milliseconds: 00),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: margin ?? const EdgeInsets.only(top: 16, bottom: 16),
      preferBelow: preferBelow ?? false,
      showDuration: showDuration ?? const Duration(seconds: 2),
      verticalOffset: verticalOffset ?? 10.0,
      textAlign: textAlign ?? TextAlign.center,
      child: child,
    );
  }
}
