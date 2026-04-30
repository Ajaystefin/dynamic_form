import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/form_access_provider.dart";

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.initialValue,
    this.semanticLabel,
    this.errorTextStyle = const TextStyle(fontSize: 0),
    this.controller,
    this.hintText,
    this.labelText,
    this.showTooltipIRL,
    this.hintStyle,
    this.labelStyle,
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
    this.showToolTip = true,
    this.prefixText,
    this.onSearchChanged,
    this.searchDebounce = const Duration(milliseconds: 500),
    this.showSearchLoader = true,
    this.textAlign = TextAlign.start, // default keeps existing behavior
  });
  final TextEditingController? controller;
  final String? semanticLabel;
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final bool readOnly;
  final String? errorText;
  final TextStyle? errorTextStyle;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final int? maxLines;
  final int minLines;
  final Color? fillColor;
  final bool filled;
  final InputBorder? border;
  final bool showToolTip;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function(String?)? onSaved;
  final bool autoFocus;
  final String? Function(String?)? validator;
  final double? width;

  /// pass [counterText] as null, if want to show the default counters
  final String? counterText;
  final List<TextInputFormatter>? inputFormatters;
  final bool useUnderlineBorder;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefix;
  final String? prefixText;
  final bool? showTooltipIRL;

  /// Async function to call when text changes (for search functionality)
  /// This will be debounced based on [searchDebounce] duration
  final Future<void> Function(String)? onSearchChanged;

  /// Debounce duration for search functionality
  /// Defaults to 500 milliseconds
  final Duration searchDebounce;

  /// Whether to show a loading indicator while search is in progress
  /// Only applicable when [onSearchChanged] is provided
  final bool showSearchLoader;

  final TextAlign textAlign;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // String? _errorMessage;

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
  late final TextEditingController _internalController;
  late final TextEditingController _effectiveController;
  String? onChangeValue;

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

    // tooltip should NOT show by default
    onChangeValue = null;

    _effectiveController.addListener(() {
      if (widget.showTooltipIRL == true) {
        final text = _effectiveController.text;
        // show tooltip only when typing and not empty
        onChangeValue = text.isEmpty ? null : text;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // Cancel any pending debounce timer
    _debounceTimer?.cancel();

    // Dispose value notifiers
    _errorMessage.dispose();
    _isSearching.dispose();

    // Only dispose the controller if we created it
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
      } catch (e) {
        // Handle any errors from the search function
        debugPrint("Search error: $e");
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
    final bool isReadOnly = widget.readOnly || FormAccessProvider.of(context);

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
        return CustomTooltip(
          message: widget.showTooltipIRL == true
              ? (onChangeValue ?? "") // show only when typing
              : "", // default hidden

          decoration: widget.showToolTip
              ? BoxDecoration(
                  color: AppColors.lightFailure,
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          textStyle: const TextStyle(color: AppColors.failure),
          child: SizedBox(
            width: widget.width,
            // height: 55,
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
                if (widget.showTooltipIRL == true) {
                  setState(() {});
                }
              },
              onChanged: (value) {
                if (widget.showTooltipIRL == true) {
                  onChangeValue = value.trim().isEmpty ? null : value;
                  if (mounted) setState(() {});
                }
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
                // Trigger debounced search if configured
                _handleDebouncedSearch(value);
                // state.didChange(value);
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
                fillColor: (isReadOnly)
                    ? AppColors.textFieldDisabledFill
                    : widget.fillColor,
                isDense: true,

                // When readOnly: use the same subdued border everywhere (no
                // highlight)
                border:
                    isReadOnly ? _getReadOnlyBorder() : _getBorder(errorText),
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
          ),
        );
      },
    )
        // )
        ;
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
