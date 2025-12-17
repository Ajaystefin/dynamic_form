import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

/// [GuidelinesSection] is a reusable widget that displays a header (for example,
/// "Additional Guidance") together with a dynamic bulleted list of guideline items.
///
/// By combining both the header and the guideline list into one class, you save
/// duplication in every section view.
class GuidelinesSection extends StatelessWidget {
  final String headerText;
  final String guidelines;

  const GuidelinesSection({
    super.key,
    required this.headerText,
    required this.guidelines,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Split on newlines and trim empty lines
    final items = guidelines
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (items.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              headerText,
              semanticsLabel: headerText,
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Gap(size: GapSize.small),

          // 2. Render each line as its own bullet
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((line) {
              return Padding(
                padding: const EdgeInsets.only(left: 19, bottom: 4),
                child: Text(
                  '\u2022 $line',
                  semanticsLabel: '\u2022 $line',
                  style: const TextStyle(color: AppColors.black,fontSize: 13),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
