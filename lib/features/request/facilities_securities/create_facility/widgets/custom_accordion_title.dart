import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion.dart";

/// Widget for displaying an accordion section with a title and content.
class CustomAccordionTitleWidget extends StatelessWidget {
  /// Creates a custom accordion title widget.
  const CustomAccordionTitleWidget({
    required this.title,
    required this.children,
    super.key,
  });

  /// Title displayed in the accordion header.
  final String title;

  /// Widgets displayed within the accordion content area.
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
