import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/label.dart";

/// A multi-checkbox widget for dynamic forms where multiple options can be
/// selected.
/// Uses Option objects from fieldData.optionList for checkbox items.
class DynamicFormMultiCheckBox extends StatefulWidget {
  const DynamicFormMultiCheckBox({
    required this.fieldData,
    required this.document,
    required this.onChanged,
    required this.onSaved,
    super.key,
    this.validation,
  });
  final DynamicField fieldData;
  final Map<String, dynamic> document;
  final Function(List<String>) onChanged;
  final Function(List<String>?) onSaved;
  final String? Function(List<String>?)? validation;

  @override
  State<DynamicFormMultiCheckBox> createState() =>
      _DynamicFormMultiCheckBoxState();
}

class _DynamicFormMultiCheckBoxState extends State<DynamicFormMultiCheckBox> {
  late Set<String> selectedKeys;

  @override
  void initState() {
    super.initState();
    _initializeSelectedKeys();
  }

  void _initializeSelectedKeys() {
    selectedKeys = {};
    final existingValue = widget.document[widget.fieldData.key];

    if (existingValue is List) {
      // Convert to Set<String> for efficient lookups
      selectedKeys = existingValue.map((e) => e.toString()).toSet();
      debugPrint(
        "MultiCheckBox initState: loaded "
        "${selectedKeys.length} items from document",
      );
    } else {
      debugPrint("MultiCheckBox initState: no existing data, starting empty");
    }
  }

  @override
  void didUpdateWidget(DynamicFormMultiCheckBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-initialize if document key changed
    if (oldWidget.fieldData.key != widget.fieldData.key) {
      _initializeSelectedKeys();
    }
  }

  void _toggleOption(String key, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedKeys.add(key);
      } else {
        selectedKeys.remove(key);
      }
    });

    final selectedList = selectedKeys.toList();
    widget.onChanged(selectedList);
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.fieldData.optionList ?? [];

    return FormField<List<String>>(
      initialValue: selectedKeys.toList(),
      validator: (value) {
        // Required field validation
        if (widget.fieldData.isRequired && selectedKeys.isEmpty) {
          return widget.fieldData.message ??
              "${widget.fieldData.label} is required";
        }
        // Custom validation
        return widget.validation?.call(value);
      },
      onSaved: (value) {
        widget.onSaved(selectedKeys.toList());
      },
      builder: (formState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            if (widget.fieldData.label.isNotEmpty)
              LabelWidget(
                label: widget.fieldData.label,
                isRequired: widget.fieldData.isRequired,
                exponent: widget.fieldData.isCMOUpdate ? "#" : null,
                child: const SizedBox.shrink(),
              ),
            // Checkboxes list
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: options.map((option) {
                final key = option.key ?? "";
                final label = option.pairValue ?? option.key ?? "";
                final isChecked = selectedKeys.contains(key);

                return CustomCheckbox(
                  value: isChecked,
                  isEnabled: !widget.fieldData.isDisable,
                  onChange: (value) {
                    _toggleOption(key, value ?? false);
                    formState.didChange(selectedKeys.toList());
                  },
                  child: Text(label),
                );
              }).toList(),
            ),
            // Error message
            if (formState.hasError && formState.errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  formState.errorText!.trim(),
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
