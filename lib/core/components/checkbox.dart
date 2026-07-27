import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/form_access_provider.dart";

/// A customizable checkbox widget with validation support.
class CustomCheckbox extends StatefulWidget {
  /// Creates a [CustomCheckbox].
  const CustomCheckbox({
    required this.onChange,
    super.key,
    this.value = false,
    this.validation,
    this.isError,
    this.activeColor,
    this.semanticsLabel,
    this.fillColor,
    this.checkColor,
    this.child,
    this.width,
    this.contentPadding,
    this.isEnabled = true,
    this.onSaved,
  });

  /// Selected value.
  final bool? value;

  /// Whether the checkbox is enabled.
  final bool isEnabled;

  /// Callback invoked when the value changes.
  final Function({bool? value}) onChange;

  /// Callback invoked when the value is saved.
  final Function({bool? value})? onSaved;

  /// Validation callback.
  final String? Function({bool? value})? validation;

  /// Color of the checkbox when selected.
  final Color? activeColor;

  /// Color of the check icon.
  final Color? checkColor;

  /// Fill color of the checkbox.
  final Color? fillColor;

  /// Semantic label for accessibility.
  final String? semanticsLabel;

  /// Widget displayed beside the checkbox.
  final Widget? child;

  /// Custom width of the widget.
  final double? width;

  /// Padding around the child widget.
  final EdgeInsetsGeometry? contentPadding;

  /// Indicates whether the checkbox is in an error state.
  final bool? isError;

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    // Combine the widget's own isEnabled flag with any ancestor
    // FormAccessProvider.
    final bool effectiveIsEnabled =
        widget.isEnabled && !FormAccessProvider.of(context);

    return FormField<bool>(
      validator: (value) {
        if (widget.validation != null) {
          _errorMessage = widget.validation!(value: value);
          return " ";
        }
        _errorMessage = null;
        return null;
      },
      onSaved: (newValue) {
        if (newValue != null) {
          widget.onSaved?.call(value: newValue);
        }
      },
      builder: (state) => CustomTooltip(
        message: _errorMessage ?? "",
        decoration: BoxDecoration(
          color: AppColors.lightFailure,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(color: AppColors.failure),
        child: SizedBox(
          width: widget.width,
          child: widget.child != null
              ? ListTile(
                  dense: true,
                  contentPadding: widget.contentPadding ??
                      const EdgeInsets.symmetric(horizontal: 10),
                  tileColor: widget.fillColor,
                  leading: Semantics(
                    label: widget.semanticsLabel,
                    child: Checkbox(
                      value: widget.value,
                      // onChanged: (value) {
                      //   onChange(value);
                      //   state.didChange(value);
                      // },

                      onChanged: effectiveIsEnabled
                          ? (value) {
                              widget.onChange(value: value);
                              state.didChange(value);
                            }
                          : null,
                      isError: widget.isError ?? _errorMessage != null,
                      activeColor: widget.activeColor ?? AppColors.primary,
                      checkColor: widget.checkColor ?? AppColors.white,
                      side: BorderSide(
                        color: effectiveIsEnabled
                            ? (widget.activeColor ?? AppColors.primary)
                            : AppColors.textFieldBorder,
                        width: 2.5,
                      ),
                    ),
                  ),
                  title: widget.child,
                )
              : Semantics(
                  label: widget.semanticsLabel,
                  child: Checkbox(
                    value: widget.value,
                    onChanged: effectiveIsEnabled
                        ? (value) {
                            widget.onChange(value: value);
                            state.didChange(value);
                          }
                        : null,
                    activeColor: widget.activeColor ?? AppColors.primary,
                    checkColor: widget.checkColor ?? AppColors.white,
                    side: BorderSide(
                      color: effectiveIsEnabled
                          ? (widget.activeColor ?? AppColors.primary)
                          : AppColors.textFieldBorder,
                      width: 1.5,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

/// A group of checkboxes that allows selecting a single item.
class GroupCheckbox extends StatefulWidget {
  /// Creates a [GroupCheckbox].
  const GroupCheckbox({
    required this.widgets,
    required this.selectedCheckboxIndex,
    super.key,
    this.validation,
    this.onChange,
    this.activeColor,
    this.checkColor,
    this.fillColor,
    this.width,
    this.direction = Axis.horizontal,
    this.childWidth = 200,
    this.contentPadding,
  });

  /// Checkbox items.
  final List<Widget> widgets;

  /// Content padding for child widgets.
  final EdgeInsetsGeometry? contentPadding;

  /// Index of the selected item.
  final int selectedCheckboxIndex;

  /// Callback invoked when a checkbox is selected.
  final Function(
    int index, {
    bool? value,
  })? onChange;

  /// Color of the checkbox when selected.
  final Color? activeColor;

  /// Color of the check icon.
  final Color? checkColor;

  /// Fill color of the checkbox.
  final Color? fillColor;

  /// Custom width of the widget.
  final double? width;

  /// Layout direction.
  final Axis? direction;

  /// Width of each child when displayed horizontally.
  final double childWidth;

  /// Validation callback.
  final String? Function(int selectedIndex)? validation;

  @override
  State<GroupCheckbox> createState() => _GroupCheckboxState();
}

class _GroupCheckboxState extends State<GroupCheckbox> {
  String? _errorMessage;
  int _selectedValueIndex = -1;
  @override
  Widget build(BuildContext context) {
    return CustomTooltip(
      message: _errorMessage ?? "",
      decoration: BoxDecoration(
        color: AppColors.lightFailure,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: const TextStyle(color: AppColors.failure),
      child: widget.direction == Axis.vertical
          ? Column(
              children: List.generate(
                widget.widgets.length,
                buildLoader,
              ),
            )
          : Wrap(
              spacing: 8,
              children: List.generate(
                widget.widgets.length,
                (index) => SizedBox(
                  width: widget.childWidth,
                  child: buildLoader(index),
                ),
              ),
            ),
    );
  }

  Widget buildLoader(int index) {
    return FormField<bool>(
      validator: (value) {
        if (widget.validation != null) {
          _errorMessage = widget.validation!(_selectedValueIndex);
          setState(() {});
          return _errorMessage;
        }
        return null;
      },
      builder: (field) => CustomCheckbox(
        isError: _errorMessage != null,
        width: widget.width,
        onChange: ({bool? value}) {
          _selectedValueIndex = index;
          widget.onChange!(value: value, index);
        },
        contentPadding: widget.contentPadding,
        value: widget.selectedCheckboxIndex == index,
        fillColor: widget.fillColor,
        activeColor: widget.activeColor ?? AppColors.primary,
        checkColor: widget.checkColor ?? AppColors.white,
        child: widget.widgets[index],
      ),
    );
  }
}
