import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion.dart";

class CustomAccordionTitleWidget extends StatelessWidget {
  const CustomAccordionTitleWidget({
    required this.title,
    required this.children,
    super.key,
  });
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CustomAccordion(
      isSubSection: true,
      title: title,
      children: children,
    );
  }
}
