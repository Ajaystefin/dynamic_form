import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";

class SectionBackground extends StatelessWidget {
  const SectionBackground({required this.child, super.key});
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
