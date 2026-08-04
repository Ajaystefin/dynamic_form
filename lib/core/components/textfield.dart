import "dart:async";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/form_access_provider.dart";
import "package:wcas_frontend/core/utils/logger.dart";

/// A customizable text input widget with support for validation,
/// formatting, search, accessibility, and theming.
class CustomTextField extends StatefulWidget {
  /// Creates a [CustomTextField].
  const CustomTextField({
    super.key,
    this.initialValue,
    this.semanticLabel,
    this.errorTextStyle = const TextStyle(fontSize: 0),
    this.controller,
    this.hintText,
    this.labelText,
    this.hintStyle,
    this.labelStyle,
    this.ignoreProvider = false,
    this.textStyle = const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
    ),
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.isPassword = false,
    this.readOnly = false,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.fillColor,
    this.filled = false,
    this.border,
    this.focusedBorder,
    this.enabledBorder,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.autoFocus = false,
    this.validator,
    this.width,
    this.counterText = "",
    this.onSaved,
    this.useUnderlineBorder = false,
    this.inputFormatters,
    this.focusNode,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.showToolTip = false,
    this.prefixText,
    this.onSearchChanged,
    this.searchDebounce = const Duration(milliseconds: 500),
    this.showSearchLoader = true,
    this.textAlign = TextAlign.start, // default keeps existing behavior
  });

  /// Controller for the text field.
  final TextEditingController? controller;

  /// Semantic label used for accessibility.
  final String? semanticLabel;

  /// Initial text value.
  final String? initialValue;

  /// Placeholder text displayed when the field is empty.
  final String? hintText;

  /// Label text displayed for the field.
  final String? labelText;

  /// Text style for the hint text.
  final TextStyle? hintStyle;

  /// Text style for the label.
  final TextStyle? labelStyle;

  /// Text style for the input text.
  final TextStyle? textStyle;

  /// Widget displayed before the editable text.
  final Widget? prefixIcon;

  /// Widget displayed after the editable text.
  final Widget? suffixIcon;

  /// Indicates whether the field should obscure text.
  final bool isPassword;

  /// Indicates whether the field is read-only.
  final bool readOnly;

  /// Ignores the form access provider when `true`.
  final bool ignoreProvider;

  /// Error text displayed below the field.
  final String? errorText;

  /// Style applied to the error text.
  final TextStyle? errorTextStyle;

  /// Helper text displayed below the field.
  final String? helperText;

  /// Keyboard type used for text input.
  final TextInputType? keyboardType;

  /// Action button displayed on the keyboard.
  final TextInputAction? textInputAction;

  /// Maximum number of characters allowed.
  final int? maxLength;

  /// Maximum number of visible lines.
  final int? maxLines;

  /// Minimum number of visible lines.
  final int minLines;

  /// Background fill color.
  final Color? fillColor;

  /// Indicates whether the field should be filled.
  final bool filled;

  /// Border displayed around the text field.
  final InputBorder? border;

  /// Indicates whether a tooltip should be shown.
  final bool showToolTip;

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

  /// Callback invoked when the field value is saved.
  final Function(String?)? onSaved;

  /// Indicates whether the field should automatically receive focus.
  final bool autoFocus;

  /// Validation callback.
  final String? Function(String?)? validator;

  /// Width of the text field.
  final double? width;

  /// Text displayed in the character counter.
  ///
  /// Pass `null` to show the default Flutter counter.
  final String? counterText;

  /// Input formatters applied to the field.
  final List<TextInputFormatter>? inputFormatters;

  /// Uses an underline border instead of the default border.
  final bool useUnderlineBorder;

  /// Focus node associated with the field.
  final FocusNode? focusNode;

  /// Padding applied to the input content.
  final EdgeInsetsGeometry? contentPadding;

  /// Widget displayed before the input.
  final Widget? prefix;

  /// Prefix text displayed before the input value.
  final String? prefixText;

  /// Async callback invoked when text changes.
  ///
  /// Primarily used for search functionality and debounced using
  /// [searchDebounce].
  final Future<void> Function(String)? onSearchChanged;

  /// Debounce duration used for search requests.
  ///
  /// Defaults to 500 milliseconds.
  final Duration searchDebounce;

  /// Indicates whether a loading indicator should be displayed while
  /// a search request is in progress.
  ///
  /// Only applicable when [onSearchChanged] is provided.
  final bool showSearchLoader;

  /// Alignment of the input text.
  final TextAlign textAlign;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  /// Uniform border for read-only state (no focus highlight)
  InputBorder _getReadOnlyBorder() {
    if (widget.useUnderlineBorder) {
      return const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.textFieldBorder),
      );
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(3),
      borderSide: const BorderSide(color: AppColors.textFieldBorder),
    );
  }

  final ValueNotifier<String?> _errorMessage = ValueNotifier(null);
  final ValueNotifier<String> _tooltipText = ValueNotifier("");
  late final TextEditingController _internalController;
  late final TextEditingController _effectiveController;

  // Debounce timer for search functionality
  Timer? _debounceTimer;

  // Loading state for search
  final ValueNotifier<bool> _isSearching = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    // Create an internal controller if none was provided
    // This ensures text persists when the widget rebuilds due to validation
    if (widget.controller == null) {
      _internalController = TextEditingController(text: widget.initialValue);
      _effectiveController = _internalController;
    } else {
      _effectiveController = widget.controller!;
      // If both a controller and an initialValue are provided,
      // seed the controller with that text once, but only if the controller is
      // empty.
      if (widget.initialValue != null && _effectiveController.text.isEmpty) {
        _effectiveController.text = widget.initialValue!;
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _errorMessage.dispose();
    _tooltipText.dispose();
    _isSearching.dispose();
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  /// Handles debounced search functionality
  void _handleDebouncedSearch(String value) {
    // Cancel any existing timer
    _debounceTimer?.cancel();

    // If no search function is provided, return early
    if (widget.onSearchChanged == null) {
      return;
    }

    // Create a new timer
    _debounceTimer = Timer(widget.searchDebounce, () async {
      // Set loading state to true
      if (widget.showSearchLoader) {
        _isSearching.value = true;
      }

      try {
        // Call the async search function
        await widget.onSearchChanged!(value);
      } on Object catch (e) {
        // Handle any errors from the search function
        logger.i("Search error: $e");
      } finally {
        // Set loading state to false
        if (widget.showSearchLoader && mounted) {
          _isSearching.value = false;
        }
      }
    });
  }

  /// Builds the suffix icon, showing a loader during search if configured
  Widget? _buildSuffixIcon() {
    // If search is configured and we should show the loader
    if (widget.onSearchChanged != null && widget.showSearchLoader) {
      return ValueListenableBuilder<bool>(
        valueListenable: _isSearching,
        builder: (context, isSearching, child) {
          if (isSearching) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            );
          }
          // Show the provided suffix icon when not searching
          return widget.suffixIcon ?? const SizedBox.shrink();
        },
      );
    }
    // Return the provided suffix icon if search is not configured
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    // Combine the widget's own readOnly flag with any ancestor
    // FormAccessProvider.
    final bool isReadOnly = widget.readOnly ||
        (!widget.ignoreProvider && FormAccessProvider.of(context));
    return
        // Semantics( if Enable this check this Request Information issue
        //   label: widget.semanticLabel ?? widget.hintText ?? widget.labelText
        // ?? 'text',
        //   // enabled: !widget.readOnly,
        //   textField: true,
        //   // height: 50,
        //   child:

        ValueListenableBuilder<String?>(
      valueListenable: _errorMessage,
      builder: (context, errorText, _) {
        final textField = SizedBox(
          width: widget.width,
          child: TextFormField(
            focusNode: widget.focusNode,
            controller: _effectiveController,
            onSaved: widget.onSaved,
            validator: (String? value) {
              // if (widget.validator != null) {
              //   if (value == null || value == '') {
              //     _errorMessage.value =
              //         widget.errorText ?? widget.validator!(value);
              //     return _errorMessage.value;
              //   } else {
              //     return null;
              //   }
              // }

              if (isReadOnly) {
                return null;
              }
              if (widget.validator == null &&
                  (isReadOnly || (value?.isNotEmpty ?? false))) {
                _errorMessage.value = null;
                return null;
              }

              if (widget.validator != null) {
                _errorMessage.value =
                    widget.errorText ?? widget.validator!(value);
                return _errorMessage.value;
              }

              //allow validation even if readOnly
              if (isReadOnly && widget.validator != null) {
                _errorMessage.value = widget.validator!(value);
                return _errorMessage.value;
              }

              return null;
            },
            obscureText: widget.isPassword,
            readOnly: isReadOnly,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            maxLength: (widget.maxLength ?? 0) > 0 ? widget.maxLength : null,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            autofocus: widget.autoFocus,
            style: widget.textStyle,
            textAlign: widget.textAlign,
            onTap: widget.onTap,
            onEditingComplete: () {
              widget.onChanged?.call(_effectiveController.text);
            },
            onChanged: (value) {
              widget.onChanged?.call(value);
              _handleDebouncedSearch(value);
            },
            onFieldSubmitted: widget.onSubmitted,
            inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
              errorStyle: widget.errorTextStyle,
              contentPadding: widget.contentPadding,
              hintText: widget.hintText,
              hintStyle: widget.hintStyle,
              labelText: widget.labelText,
              labelStyle: widget.labelStyle,
              helperText: widget.helperText,
              counterText: widget.counterText,
              prefix: widget.prefix,
              prefixIcon: widget.prefixIcon,
              prefixText: widget.prefixText,
              suffixIcon: _buildSuffixIcon(),
              filled: widget.filled || isReadOnly,
              fillColor: isReadOnly
                  ? AppColors.textFieldDisabledFill
                  : widget.fillColor,
              isDense: true,

              // When readOnly: use the same subdued border everywhere (no
              // highlight)
              border: isReadOnly ? _getReadOnlyBorder() : _getBorder(errorText),
              enabledBorder:
                  isReadOnly ? _getReadOnlyBorder() : _getBorder(errorText),
              errorBorder:
                  isReadOnly ? _getReadOnlyBorder() : _getBorder(errorText),

              focusedErrorBorder:
                  isReadOnly ? _getReadOnlyBorder() : _getBorder(errorText),
              focusedBorder: isReadOnly
                  ? _getReadOnlyBorder()
                  : (widget.useUnderlineBorder
                      ? _getBorder(errorText)
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          ),
                        )),
            ),
          ),
        );

        if (!widget.showToolTip) {
          return CustomTooltip(message: "", child: textField);
        }

        return ValueListenableBuilder<String>(
          valueListenable: _tooltipText,
          builder: (context, tooltipMessage, child) => MouseRegion(
            onEnter: (_) {
              _tooltipText.value = _effectiveController.text;
            },
            child: CustomTooltip(
              message: tooltipMessage,
              decoration: const BoxDecoration(
                color: AppColors.lightFailure,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              textStyle: const TextStyle(color: AppColors.failure),
              child: child!,
            ),
          ),
          child: textField,
        );
      },
    );
  }

  /// Returns the appropriate border based on the state
  InputBorder _getBorder(String? errorMessage) {
    if (widget.useUnderlineBorder) {
      return UnderlineInputBorder(
        borderSide: BorderSide(
          color: errorMessage == null
              ? AppColors.textFieldBorder
              : AppColors.failure,
        ),
      );
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(3),
      borderSide: BorderSide(
        color: errorMessage == null
            ? AppColors.textFieldBorder
            : AppColors.failure,
      ),
    );
  }
}
