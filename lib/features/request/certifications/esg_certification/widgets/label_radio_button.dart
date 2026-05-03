import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";

class LabeledRadioButton extends StatelessWidget {
  const LabeledRadioButton({
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.enabled,
    super.key,
    this.isRequired = false,
  });
  final String label;
  final List<String> options;
  final String selectedValue;
  final void Function(String) onChanged;
  final bool enabled;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          fit: FlexFit.loose,
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
