import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class SectionBackground extends StatelessWidget {
  const SectionBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
        ),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                child,
              ],
            )));
  }
}
