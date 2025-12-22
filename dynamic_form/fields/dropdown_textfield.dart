import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/dropdown_textbox.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/label.dart';

class DynamicFormDropdownTextfield extends StatefulWidget {
  final DynamicField fieldData;
  final Function(Map<String, dynamic>) onSubmit;
  final bool showLabel;
  final List<TextInputFormatter>? inputFormatters;
  const DynamicFormDropdownTextfield(
      {super.key,
      required this.fieldData,
      required this.onSubmit,
      this.showLabel = false,
      this.inputFormatters});

  @override
  State<DynamicFormDropdownTextfield> createState() =>
      _DynamicFormDropdownTextfieldState();
}

class _DynamicFormDropdownTextfieldState
    extends State<DynamicFormDropdownTextfield> {
  @override
  void initState() {
    super.initState();
    // Autofill the first option if no initial value is present
    final hasInitialValue = widget.fieldData.defaultValue != null &&
        widget.fieldData.defaultValue.toString().isNotEmpty;

    if (!hasInitialValue &&
        widget.fieldData.optionList != null &&
        widget.fieldData.optionList!.isNotEmpty) {
      // Schedule the autofill to happen after the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final firstOption = widget.fieldData.optionList!.first;
        // Submit the first option with empty text field value
        widget.onSubmit({firstOption.value ?? '': ''});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the initial option: use defaultValue if present, otherwise use first option
    final hasInitialValue = widget.fieldData.defaultValue != null &&
        widget.fieldData.defaultValue.toString().isNotEmpty;

    final String? initialOption = hasInitialValue
        ? widget.fieldData.defaultValue
        : (widget.fieldData.optionList != null &&
                widget.fieldData.optionList!.isNotEmpty)
            ? widget.fieldData.optionList!.first.value
            : null;

    Widget child = CustomDropdownTextbox(
      // textFieldWidth: 185.w,
      options: widget.fieldData.optionList ?? [],
      initialOption: initialOption,
      maxLength: widget.fieldData.maxLength,
      onChanged: (value) {
        widget.onSubmit(value);
      },
    );
    return widget.showLabel
        ? LabelWidget(
            showLabel: widget.showLabel,
            label: widget.fieldData.label,
            isRequired: widget.fieldData.isRequired,
            exponent: widget.fieldData.isCMOUpdate ? "#" : null,
            child: child)
        : child;
  }
}
