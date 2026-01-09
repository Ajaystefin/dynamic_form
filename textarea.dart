import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';

/// Custom TextInputFormatter that shows an alert when maxLength is exceeded
class _MaxLengthAlertFormatter extends TextInputFormatter {
  final int maxLength;
  final String alertMessage;

  _MaxLengthAlertFormatter({
    required this.maxLength,
    required this.alertMessage,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value exceeds maxLength, truncate and show alert
    if (newValue.text.length > maxLength) {
      AlertManager().showFailureToast(alertMessage);
      // Truncate to maxLength instead of rejecting completely
      return oldValue;
    }
    return newValue; // Accept the change
  }
}

class CustomTextArea extends StatelessWidget {
  const CustomTextArea({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.hintStyle,
    this.labelStyle,
    this.textStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.maxLines = 10,
    this.minLines = 10,
    this.fillColor,
    this.filled = false,
    this.border,
    this.focusedBorder,
    this.semanticLabel,
    this.enabledBorder,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.autoFocus = false,
    this.validator,
    this.width,
    this.onSaved,
    this.counterText,
  });
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final String? semanticLabel;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final String? errorText;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final int? maxLines;
  final int minLines;
  final Color? fillColor;
  final bool filled;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool autoFocus;
  final String? Function(String?)? validator;
  final double? width;
  final dynamic Function(String?)? onSaved;
  final String? counterText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: CustomTextField(
        controller: controller,
        counterText: counterText ?? '',
        onSaved: onSaved,
        semanticLabel: semanticLabel ?? labelText ?? hintText,
        maxLines: maxLines,
        autoFocus: autoFocus,
        border: border,
        initialValue: initialValue,
        enabledBorder: enabledBorder,
        errorText: errorText,
        fillColor: fillColor,
        filled: filled,
        focusedBorder: focusedBorder,
        helperText: helperText,
        hintStyle: hintStyle,
        hintText: hintText,
        key: key,
        isPassword: false,
        keyboardType: keyboardType,
        labelStyle: labelStyle,
        labelText: labelText,
        maxLength: maxLength,
        minLines: minLines,
        // Add custom formatter to show alert when maxLength is exceeded
        inputFormatters: maxLength != null
            ? [
                _MaxLengthAlertFormatter(
                  maxLength: maxLength!,
                  alertMessage: "Maximum $maxLength characters allowed",
                ),
              ]
            : null,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        prefixIcon: prefixIcon,
        readOnly: readOnly,
        suffixIcon: suffixIcon,
        textInputAction: textInputAction,
        textStyle: textStyle,
        validator: validator,
        width: width,
      ),
    );
  }
}
