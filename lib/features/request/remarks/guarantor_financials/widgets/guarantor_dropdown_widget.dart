import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/components/label.dart";

/// Dropdown wrapper widget with a label and optional required indicator.
class GuarantorDropdownWidget extends StatelessWidget {
  /// Creates a labeled dropdown widget.
  const GuarantorDropdownWidget({
    required this.width,
    required this.label,
    required this.child,
    super.key,
    this.isRequired = false,
  });

  /// Width of the dropdown container.
  final double width;

  /// Label displayed above the dropdown.
  final String label;

  /// Dropdown widget content.
  final Widget child;

  /// Indicates whether the field is mandatory.
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: LabelWidget(
        label: label,
        isRequired: isRequired,
        child: child,
      ),
    );
  }
}
