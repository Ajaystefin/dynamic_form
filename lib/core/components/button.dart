import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final Function()? onPressed;
  final bool isLoading;
  final String? tooltip;
  final String? semanticLabel;
  final Color? backgroundColor;
  final Color? disabledColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final TextStyle? textStyle;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.tooltip,
    this.semanticLabel,
    this.backgroundColor,
    this.disabledColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius = 4.0,
    this.textStyle,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _internalLoading = false;

  Future<void> _handlePressed() async {
    setState(() => _internalLoading = true);
    try {
      if (widget.onPressed != null) {
        await widget.onPressed!();
      }
    } finally {
      if (mounted) setState(() => _internalLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.isLoading || _internalLoading;
    final button = Semantics(
      label: widget.label,
      enabled: widget.onPressed != null,
      button: true,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                widget.backgroundColor ?? AppColors.buttonBackground,
            disabledBackgroundColor:
                widget.disabledColor ?? AppColors.disabledButton,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          onPressed:
              (widget.onPressed == null || isLoading) ? null : _handlePressed,
          child: isLoading
              ? SizedBox(
                  height:
                      (widget.height ?? Theme.of(context).buttonTheme.height) *
                          0.5,
                  width:
                      (widget.height ?? Theme.of(context).buttonTheme.height) *
                          0.5,
                  child: CircularProgressIndicator(
                    semanticsLabel: "Button Loading",
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.textColor ?? Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.leadingIcon != null) ...[
                      widget.leadingIcon!,
                      const SizedBox(width: 8.0),
                    ],
                    Text(
                      widget.label,
                      style: widget.textStyle ??
                          TextStyle(
                            color: widget.textColor ?? Colors.white,
                            fontSize: AppStyle.fontSizeMedium,
                          ),
                    ),
                    if (widget.trailingIcon != null) ...[
                      const SizedBox(width: 8.0),
                      widget.trailingIcon!,
                    ],
                  ],
                ),
        ),
      ),
    );

    return Semantics(
        label: widget.semanticLabel ?? widget.label,
        button: true,
        enabled: widget.onPressed != null,
        child: widget.tooltip != null
            ? Tooltip(
                message: widget.tooltip!,
                child: button,
              )
            : button);
  }
}
