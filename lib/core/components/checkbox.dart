import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/form_access_provider.dart";

// ignore: must_be_immutable
class CustomCheckbox extends StatelessWidget {
  CustomCheckbox({
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

  /// selected value
  final bool? value;

  final bool isEnabled;

  /// on pressing the checkbox
  final Function(bool?) onChange;

  /// on saving the checkbox
  final Function(bool)? onSaved;

  /// on validation
  final String? Function(bool?)? validation;

  /// color of check box when selected
  final Color? activeColor;

  /// color of check in the checkbox icon
  final Color? checkColor;

  /// color of widget
  final Color? fillColor;

  final String? semanticsLabel;

  /// widget that shows after checkbox
  final Widget? child;

  /// custom width for the widget
  final double? width;

  ///spacing of child widget
  final EdgeInsetsGeometry? contentPadding;
  final bool? isError;
  String? _errorMessage;
  @override
  Widget build(BuildContext context) {
    // Combine the widget's own isEnabled flag with any ancestor
    // FormAccessProvider.
    final bool effectiveIsEnabled =
        isEnabled && !FormAccessProvider.of(context);

    return FormField<bool>(
      validator: (value) {
        if (validation != null) {
          _errorMessage = validation!(value);
          return " ";
        }
        _errorMessage = null;
        return null;
      },
      onSaved: (newValue) {
        if (newValue != null) {
          onSaved ?? newValue;
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
          width: width,
          child: child != null
              ? ListTile(
                  dense: true,
                  contentPadding: contentPadding ??
                      const EdgeInsets.symmetric(horizontal: 10),
                  tileColor: fillColor,
                  leading: Semantics(
                    label: semanticsLabel,
                    child: Checkbox(
                      value: value,
                      // onChanged: (value) {
                      //   onChange(value);
                      //   state.didChange(value);
                      // },

                      onChanged: effectiveIsEnabled
                          ? (value) {
                              onChange(value);
                              state.didChange(value);
                            }
                          : null,
                      isError: isError ?? _errorMessage != null,
                      activeColor: activeColor ?? AppColors.primary,
                      checkColor: checkColor ?? AppColors.white,
                      side: BorderSide(
                        color: effectiveIsEnabled
                            ? (activeColor ?? AppColors.primary)
                            : AppColors.textFieldBorder,
                        width: 2.5,
                      ),
                    ),
                  ),
                  title: child,
                )
              : Semantics(
                  label: semanticsLabel,
                  child: Checkbox(
                    value: value,
                    onChanged: effectiveIsEnabled
                        ? (value) {
                            onChange(value);
                            state.didChange(value);
                          }
                        : null,
                    activeColor: activeColor ?? AppColors.primary,
                    checkColor: checkColor ?? AppColors.white,
                    side: BorderSide(
                      color: effectiveIsEnabled
                          ? (activeColor ?? AppColors.primary)
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

class GroupCheckbox extends StatefulWidget {
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
  final List<Widget> widgets;

  /// content padding for the child widget
  final EdgeInsetsGeometry? contentPadding;

  /// index of selected item
  final int selectedCheckboxIndex;

  /// on clicking the check box
  final Function(bool? value, int index)? onChange;

  /// color of check box when selected
  final Color? activeColor;

  /// color of check in the checkbox icon
  final Color? checkColor;

  /// color of widget
  final Color? fillColor;

  /// custom width for the widget
  final double? width;

  /// Direction of list default to horizontal
  final Axis? direction;

  /// width of child widget is required when the axis is horizontal
  final double childWidth;

  /// on validation
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
        onChange: (value) {
          _selectedValueIndex = index;
          widget.onChange!(value, index);
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
