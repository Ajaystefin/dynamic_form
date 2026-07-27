import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";

/// A labeled radio button group widget.
class LabeledRadioButton extends StatelessWidget {
  /// Creates a labeled radio button group.
  const LabeledRadioButton({
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.enabled,
    super.key,
    this.isRequired = false,
  });

  /// Label displayed before the radio button group.
  final String label;

  /// Available radio button options.
  final List<String> options;

  /// Currently selected option value.
  final String selectedValue;

  /// Callback invoked when the selected value changes.
  final void Function(String) onChanged;

  /// Whether the radio button group is enabled.
  final bool enabled;

  /// Indicates whether the field is required.
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text.rich(
            TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: isRequired ? " *" : "",
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: CustomRadioButton(
            isRequired: true,
            isEnabled: enabled,
            options: options,
            scrollDirection: Axis.horizontal,
            selectedValue: selectedValue,
            // selectedColor: AppColors.black,
            // unselectedColor: Colors.grey,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
