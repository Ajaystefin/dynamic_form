import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/form_access_provider.dart";

class CustomRadioButton<T> extends StatefulWidget {
  const CustomRadioButton({
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    super.key,
    this.textStyle,
    this.validator,
    this.isRequired = false,
    this.scrollDirection = Axis.vertical,
    this.selectedColor,
    this.unselectedColor,
    this.isEnabled = true, // Default to enabled
    this.itemBuilder,
  });
  final List<T> options;
  final T selectedValue;
  final Function(T) onChanged;
  final Color? selectedColor; // Custom selected circle color
  final Color? unselectedColor; // Custom unselected circle color
  final bool isEnabled; // Enable/Disable radio buttons
  final bool isRequired; // Enable/Disable radio buttons
  final String? Function(T?)? validator;
  final Axis scrollDirection;
  final TextStyle? textStyle;

  final Widget Function(
    BuildContext,
    T option,
    bool isSelected,
    bool isEnabled,
  )? itemBuilder;

  @override
  State<CustomRadioButton<T>> createState() => _CustomRadioButtonState<T>();
}

class _CustomRadioButtonState<T> extends State<CustomRadioButton<T>> {
  String? _errorMessage;
  T? selectedValue;

  @override
  Widget build(BuildContext context) {
    return widget.isRequired
        ? CustomTooltip(
            message: _errorMessage ?? "",
            decoration: BoxDecoration(
              color: AppColors.lightFailure,
              borderRadius: BorderRadius.circular(6),
            ),
            textStyle: const TextStyle(color: AppColors.failure),
            child: _radioBuilder(),
          )
        : _radioBuilder();
  }

  Widget _radioBuilder() {
    if (widget.options.isEmpty) {
      // Fallback to an empty option (disabled by default)
      return const ExcludeFocus(
        child: Radio<int>(
          value: 1,
          groupValue: null, // No selection
          onChanged: null, // Disables the radio button
        ),
      );
    } else if (widget.options.length == 1) {
      // Display a single option
      return _buildRadioTile(widget.options[0]);
    } else {
      return widget.scrollDirection == Axis.vertical
          ? ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.options.length,
              itemBuilder: (context, index) {
                return _buildRadioTile(widget.options[index]);
              },
            )
          : Wrap(
              children: List.generate(
                widget.options.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildRadioTile(widget.options[index]),
                ),
              ),
            );
    }
  }

  String? _getSemanticLabel(T? option) {
    if (option == null) return null;

    final nameProperty = _tryGetName(option);
    return nameProperty ?? option.toString();
  }

  String? _tryGetName(Object? option) {
    try {
      if (option == null) return null;
      final dynamic dyn = option;
      return dyn?.name; // returns null if no such getter
    } catch (_) {
      return null;
    }
  }

  Widget _buildRadioTile(T? option) {
    // Combine the widget's own isEnabled flag with any ancestor
    // FormAccessProvider.
    final bool effectiveIsEnabled =
        widget.isEnabled && !FormAccessProvider.of(context);
    final bool isOptionEnabled = effectiveIsEnabled && option != null;

    return Semantics(
      label: _getSemanticLabel(option),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FormField<T>(
            onSaved: (newValue) {},
            validator: _groupValidator,
            builder: (field) => Radio<T>(
              value: option as T,
              groupValue: widget.selectedValue,
              onChanged: isOptionEnabled
                  ? (value) {
                      selectedValue = value;
                      widget.onChanged(value as T);
                      field.didChange(value);
                    }
                  : null,
              fillColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (!isOptionEnabled) {
                    return AppColors.darkGrey;
                  }
                  return _errorMessage != null
                      ? AppColors.failure
                      : states.contains(WidgetState.selected)
                          ? widget.selectedColor ?? AppColors.primary
                          : widget.unselectedColor ?? AppColors.darkGrey;
                },
              ),
            ),
          ),

          /// Custom itemBuilder or fallback to Text
          widget.itemBuilder != null && option != null
              ? widget.itemBuilder!(
                  context,
                  option,
                  widget.selectedValue == option,
                  isOptionEnabled,
                )
              : Text(
                  option != null ? option.toString() : "Disabled",
                  style: widget.textStyle ??
                      TextStyle(
                        fontSize: 15,
                        color: isOptionEnabled
                            ? AppColors.black
                            : AppColors.darkGrey,
                      ),
                ),
        ],
      ),
    );
  }

  String? _groupValidator(value) {
    // Use widget.selectedValue instead of local selectedValue
    if (widget.options.contains(widget.selectedValue) &&
        widget.selectedValue != null) {
      _errorMessage = null;
      return null;
    }

    if (widget.validator != null) {
      _errorMessage = widget.validator!(widget.selectedValue);
      setState(() {});
      if (_errorMessage == null) {
        return null;
      }
      return "";
    }

    if (widget.isRequired && widget.selectedValue == null) {
      _errorMessage = "common.validation.emptyField".tr();
      setState(() {});
      return "";
    }

    return null;
  }
}
