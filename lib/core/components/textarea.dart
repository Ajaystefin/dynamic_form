import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/form_access_provider.dart";

/// Custom [TextInputFormatter] that shows an alert when the maximum
/// character limit is exceeded.
class _MaxLengthAlertFormatter extends TextInputFormatter {
  _MaxLengthAlertFormatter({
    required this.maxLength,
    required this.alertMessage,
  });
  final int maxLength;
  final String alertMessage;

  bool _hasShownAlert = false;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // - Allow composing text (important for IME / predictive input)
    if (newValue.composing.isValid) {
      return newValue;
    }

    // - Allow up to maxLength (including exactly maxLength)
    if (newValue.text.length <= maxLength) {
      _hasShownAlert = false;
      return newValue;
    }

    // 🚫 Overflow
    if (!_hasShownAlert) {
      _hasShownAlert = true;
      AlertManager().showFailureToast(alertMessage);
    }

    // - Truncate overflow (handles paste)
    final truncated = newValue.text.substring(0, maxLength);

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: maxLength),
    );
  }
}

/// Multi-line text input widget with support for validation,
/// formatting, character limits, and access control.
class CustomTextArea extends StatelessWidget {
  /// Creates a [CustomTextArea].
  const CustomTextArea({
    super.key,
    this.controller,
    this.initialValue,
    this.ignoreProvider = false,
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
    this.alphanumericOnly = false,
    this.showMaximumLengthIndicator = true,
  });

  /// Controller for the text field.
  final TextEditingController? controller;

  /// Initial text value.
  final String? initialValue;

  /// Placeholder text displayed when the field is empty.
  final String? hintText;

  /// Label text displayed above the field.
  final String? labelText;

  /// Semantic label used for accessibility.
  final String? semanticLabel;

  /// Text style for the hint text.
  final TextStyle? hintStyle;

  /// Text style for the label.
  final TextStyle? labelStyle;

  /// Text style for the input text.
  final TextStyle? textStyle;

  /// Widget displayed before the input field.
  final Widget? prefixIcon;

  /// Widget displayed after the input field.
  final Widget? suffixIcon;

  /// Indicates whether the field is read-only.
  final bool readOnly;

  /// Error text displayed below the field.
  final String? errorText;

  /// Helper text displayed below the field.
  final String? helperText;

  /// Keyboard type used for text input.
  final TextInputType? keyboardType;

  /// Action button displayed on the keyboard.
  final TextInputAction? textInputAction;

  /// Maximum number of characters allowed.
  final int? maxLength;

  /// Controls whether the maximum-length indicator is shown.
  final bool showMaximumLengthIndicator;

  /// Maximum number of visible lines.
  final int? maxLines;

  /// Ignores the form access provider when `true`.
  final bool ignoreProvider;

  /// Minimum number of visible lines.
  final int minLines;

  /// Background fill color.
  final Color? fillColor;

  /// Indicates whether the field should be filled.
  final bool filled;

  /// Border displayed around the field.
  final InputBorder? border;

  /// Border displayed when the field is focused.
  final InputBorder? focusedBorder;

  /// Border displayed when the field is enabled.
  final InputBorder? enabledBorder;

  /// Callback invoked when the field is tapped.
  final VoidCallback? onTap;

  /// Callback invoked when the text changes.
  final Function(String)? onChanged;

  /// Callback invoked when the text is submitted.
  final Function(String)? onSubmitted;

  /// Indicates whether the field should autofocus.
  final bool autoFocus;

  /// Validation callback.
  final String? Function(String?)? validator;

  /// Width of the text area.
  final double? width;

  /// Callback invoked when the field value is saved.
  final dynamic Function(String?)? onSaved;

  /// Custom counter text.
  final String? counterText;

  /// Restricts input to alphanumeric characters only.
  final bool alphanumericOnly;
  
  @override
  Widget build(BuildContext context) {
    final bool effectiveIsEnabled =
        ignoreProvider || !FormAccessProvider.of(context);

    return IgnorePointer(
      ignoring: !effectiveIsEnabled,
      child: SizedBox(
        height: 100,
        child: CustomTextField(
          controller: controller,
          counterText: counterText ?? "",
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
          keyboardType: keyboardType,
          labelStyle: labelStyle,
          labelText: labelText,
          maxLength: maxLength,
          minLines: minLines,
          // Add custom formatter to show alert when maxLength is exceeded

          inputFormatters: [
            if (alphanumericOnly)
              FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z0-9\s]")),
            if (maxLength != null && showMaximumLengthIndicator)
              _MaxLengthAlertFormatter(
                maxLength: maxLength!,
                alertMessage: "Maximum $maxLength characters allowed",
              ),
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ],

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
          ignoreProvider: effectiveIsEnabled,
        ),
      ),
    );
  }
}
