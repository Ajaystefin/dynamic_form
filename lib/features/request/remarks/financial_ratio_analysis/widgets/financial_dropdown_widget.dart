import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/components/label.dart";

/// Dropdown widget with a label and optional required indicator.
class FinancialDropdownWidget extends StatelessWidget {
  /// Creates a financial dropdown widget.
  const FinancialDropdownWidget({
    required this.width,
    required this.label,
    required this.child,
    super.key,
    this.isRequired = false,
  });

  /// Width of the widget.
  final double width;

  /// Label displayed above the dropdown.
  final String label;

  /// Dropdown content widget.
  final Widget child;

  /// Indicates whether the field is required.
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty("width", width))
      ..add(StringProperty("label", label))
      ..add(FlagProperty("isRequired", value: isRequired))
      ..add(DiagnosticsProperty<Widget>("child", child));
  }
}
