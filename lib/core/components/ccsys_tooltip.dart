import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// A custom tooltip widget with configurable content width.
class CcsysTootltip extends StatelessWidget {
  /// Creates a [CcsysTootltip].
  const CcsysTootltip({
    required this.message,
    required this.child,
    super.key,
    this.maxWidth = 250,
  });

  /// Tooltip message.
  final String message;

  /// Maximum tooltip width.
  final double maxWidth;

  /// Child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      decoration: const BoxDecoration(color: AppColors.applicationSegment),
      richMessage: WidgetSpan(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: child,
    );
  }
}
