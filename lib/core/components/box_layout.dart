import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/form_access_provider.dart";

/// Box layout container.
class BoxLayout extends StatelessWidget {
  /// Creates a [BoxLayout].
  const BoxLayout({
    required this.child,
    super.key,
    this.extraPadding = false,
    this.borderColor,
    this.alignment,
    this.disabled = false,
  });

  /// Child widget.
  final Widget child;

  /// Extra padding.
  final bool extraPadding;

  /// Border color.
  final Color? borderColor;

  /// Content alignment.
  final AlignmentGeometry? alignment;

  /// Disabled state.
  final bool disabled;

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
        extraPadding ? AppStyle.spacingLarge : AppStyle.spacing,
      ),
      // Use FormAccessProvider instead of IgnorePointer so that
      // scrollable widgets (tables, rich text) still receive scroll events.
      child: FormAccessProvider(
        disabled: disabled,
        child: Opacity(
          opacity: disabled ? 0.9 : 1.0,
          child: child,
        ),
      ),
    );
  }
}
