import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/accordion.dart';

class CustomAccordionTitleWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const CustomAccordionTitleWidget({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAccordion(
        isSubSection: true, title: title, children: children);
  }
}
