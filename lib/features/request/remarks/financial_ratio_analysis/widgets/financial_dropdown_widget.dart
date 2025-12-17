import 'package:flutter/widgets.dart';
import 'package:wcas_frontend/core/components/label.dart';

class FinancialDropdownWidget extends StatelessWidget {
  final double width;
  final String label;
  final Widget child;
  final bool isRequired;

  const FinancialDropdownWidget({
    super.key,
    required this.width,
    required this.label,
    required this.child,
    this.isRequired = false,
  });

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
