import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/components/label.dart";

class GuarantorDropdownWidget extends StatelessWidget {
  const GuarantorDropdownWidget({
    required this.width,
    required this.label,
    required this.child,
    super.key,
    this.isRequired = false,
  });
  final double width;
  final String label;
  final Widget child;
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
