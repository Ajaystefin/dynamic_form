import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/button_dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// A combined dropdown and text input widget.
class CustomDropdownTextbox extends StatefulWidget {
  /// Creates a [CustomDropdownTextbox].
  const CustomDropdownTextbox({
    required this.options,
    super.key,
    this.controller,
    this.inputFormatters,
    this.textFieldLabel,
    this.dropdownLabel,
    this.textFieldWidth,
    this.initialOption,
    this.validator,
    this.onChanged,
    this.maxLength,
  });

  /// Text editing controller.
  final TextEditingController? controller;

  /// Text field label.
  final String? textFieldLabel;

  /// Dropdown label.
  final String? dropdownLabel;

  /// Width of the text field.
  final double? textFieldWidth;

  /// Available dropdown options.
  final List<CustomDropdownItem> options;

  /// Input formatters for the text field.
  final List<TextInputFormatter>? inputFormatters;

  /// Initially selected dropdown option.
  final String? initialOption;

  /// Validation callback.
  final String? Function(String?)? validator;

  /// Value change callback.
  final Function(Map<String, dynamic>)? onChanged;

  /// Maximum input length.
  final int? maxLength;

  @override
  State<CustomDropdownTextbox> createState() => _CustomDropdownTextboxState();
}

class _CustomDropdownTextboxState extends State<CustomDropdownTextbox> {
  late String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialOption;
  }

  @override
  void didUpdateWidget(CustomDropdownTextbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected option if initialOption changes
    if (widget.initialOption != oldWidget.initialOption) {
      _selectedOption = widget.initialOption;
    }
  }

  Widget makeExpandableWidget(
    Widget child, {
    required bool isExpanded,
  }) {
    return isExpanded ? Expanded(child: child) : child;
  }

  void _notifyChange() {
    if (widget.onChanged != null && _selectedOption != null) {
      widget.onChanged!({_selectedOption!: widget.controller?.text ?? ""});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textFieldBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        spacing: 2,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: widget.dropdownLabel,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textFieldBorder),
                borderRadius: BorderRadius.circular(4),
              ),
              child: CustomDropdownButton(
                borderRadius: 4,
                label: widget.dropdownLabel ?? "",
                disabledColor: AppColors.scaffoldBackground,
                textColor: AppColors.defaultTextColor,
                options: widget.options
                    .map(
                      (option) => CustomDropdownItem(
                        value: option.value,
                        label: option.value,
                        onPressed: option.onPressed,
                      ),
                    )
                    .toList(),
                height: 34,
                isSearchable: false,
                initialOption: CustomDropdownItem(
                  value: _selectedOption ?? "",
                  label: _selectedOption ?? "",
                ),
                callBack: (selectedValue) {
                  setState(() {
                    _selectedOption = selectedValue;
                    widget.controller?.clear();
                  });
                  // Notify parent of dropdown change
                  _notifyChange();
                },
              ),
            ),
          ),
          makeExpandableWidget(
            isExpanded: widget.textFieldWidth == null,
            CustomTextField(
              semanticLabel: widget.textFieldLabel,
              validator: widget.validator,
              controller: widget.controller,
              hintText: widget.textFieldLabel,
              width: widget.textFieldWidth,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              onChanged: (value) {
                // Notify parent of text field change
                _notifyChange();
              },
            ),
          ),
        ],
      ),
    );
  }
}
