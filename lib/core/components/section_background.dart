import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// A container widget that provides consistent background styling
/// for a section.
class SectionBackground extends StatelessWidget {
  /// Creates a [SectionBackground].
  const SectionBackground({
    required this.child,
    super.key,
  });

  /// Content displayed within the section background.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            child,
          ],
        ),
      ),
    );
  }
}
