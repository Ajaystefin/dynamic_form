import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/dynamic_form/field.dart';
import 'package:wcas_frontend/core/components/dynamic_form/field_dependencies.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/section.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class DynamicForm extends StatefulWidget {
  final List<Section> sections;
  final Map<String, dynamic> document;
  final FieldDependencies? dependencies;

  const DynamicForm({
    super.key,
    required this.sections,
    required this.document,
    this.dependencies,
  });

  @override
  State<DynamicForm> createState() => DynamicFormState();
}

class DynamicFormState extends State<DynamicForm> {
  final Map<String, TextEditingController> dependentControllers = {};
  final GlobalKey<FormState> _internalFormKey = GlobalKey<FormState>();

  /// Validates all form fields
  ///
  /// Returns true if all fields pass validation, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (dynamicFormKey.currentState?.validate() ?? false) {
  ///   // All fields are valid
  /// }
  /// ```
  bool validate() {
    return _internalFormKey.currentState?.validate() ?? false;
  }

  /// Saves all form fields
  ///
  /// Calls the onSaved callback for each field.
  ///
  /// Example:
  /// ```dart
  /// dynamicFormKey.currentState?.save();
  /// ```
  void save() {
    _internalFormKey.currentState?.save();
  }

  /// Updates a single field value by its key
  ///
  /// This method updates the document map and triggers any dependent field calculations.
  /// If the field has a controller (text fields, currency fields), it also updates the controller.
  ///
  /// Parameters:
  ///   - fieldKey: The unique key of the field to update
  ///   - value: The new value for the field
  ///   - triggerDependencies: Whether to recalculate dependent fields (default: true)
  ///
  /// Example:
  /// ```dart
  /// dynamicFormKey.currentState?.updateFieldValue('premiumAmount', {
  ///   'fromCurrency': 'USD',
  ///   'fromVal': 100,
  ///   'aedEquivalent': 367.3
  /// });
  /// ```
  void updateFieldValue(
    String fieldKey,
    dynamic value, {
    bool triggerDependencies = true,
  }) {
    // Update document map
    widget.document[fieldKey] = value;

    // Update controller if field has one
    if (dependentControllers.containsKey(fieldKey)) {
      final controller = dependentControllers[fieldKey]!;

      // Handle different value types
      if (value is String) {
        controller.text = value;
      } else if (value is num) {
        controller.text = value.toString();
      } else if (value is Map<String, dynamic>) {
        // For currency fields, extract the numeric value
        if (value.containsKey('fromVal')) {
          controller.text = value['fromVal']?.toString() ?? '';
        }
      }
    }

    // Trigger dependent field recalculations
    if (triggerDependencies && widget.dependencies != null) {
      final dependencies =
          widget.dependencies!.getDependenciesForSource(fieldKey);
      for (var dependency in dependencies) {
        _updateDependentField(dependency.dependentFieldKey);
      }
    }

    // Rebuild to reflect changes
    setState(() {});
  }

  /// Updates multiple field values at once
  ///
  /// This is more efficient than calling updateFieldValue multiple times
  /// as it only triggers a single rebuild and dependency calculation pass.
  ///
  /// Parameters:
  ///   - updates: Map of field keys to their new values
  ///   - triggerDependencies: Whether to recalculate dependent fields (default: true)
  ///
  /// Example:
  /// ```dart
  /// dynamicFormKey.currentState?.updateFields({
  ///   'policyNumber': '12345',
  ///   'premiumAmount': {'fromCurrency': 'AED', 'fromVal': 50, 'aedEquivalent': 50},
  ///   'mortgagedInFavourOfCBD': true,
  /// });
  /// ```
  void updateFields(
    Map<String, dynamic> updates, {
    bool triggerDependencies = true,
  }) {
    // Track all affected source fields for dependency calculation
    final Set<String> affectedFields = {};

    // Update all fields
    for (var entry in updates.entries) {
      final fieldKey = entry.key;
      final value = entry.value;

      // Update document map
      widget.document[fieldKey] = value;
      affectedFields.add(fieldKey);

      // Update controller if field has one
      if (dependentControllers.containsKey(fieldKey)) {
        final controller = dependentControllers[fieldKey]!;

        if (value is String) {
          controller.text = value;
        } else if (value is num) {
          controller.text = value.toString();
        } else if (value is Map<String, dynamic> &&
            value.containsKey('fromVal')) {
          controller.text = value['fromVal']?.toString() ?? '';
        }
      }
    }

    // Trigger dependent field recalculations for all affected fields
    if (triggerDependencies && widget.dependencies != null) {
      final Set<String> dependentsToUpdate = {};

      for (var fieldKey in affectedFields) {
        final dependencies =
            widget.dependencies!.getDependenciesForSource(fieldKey);
        for (var dependency in dependencies) {
          dependentsToUpdate.add(dependency.dependentFieldKey);
        }
      }

      for (var dependentKey in dependentsToUpdate) {
        _updateDependentField(dependentKey);
      }
    }

    // Single rebuild for all changes
    setState(() {});
  }

  /// Retrieves the current value of a field by its key
  ///
  /// Returns the value from the document map, or null if the field doesn't exist.
  ///
  /// Example:
  /// ```dart
  /// final premiumAmount = dynamicFormKey.currentState?.getFieldValue('premiumAmount');
  /// if (premiumAmount is Map<String, dynamic>) {
  ///   final aedValue = premiumAmount['aedEquivalent'];
  /// }
  /// ```
  dynamic getFieldValue(String fieldKey) {
    return widget.document[fieldKey];
  }

  /// Retrieves all current field values
  ///
  /// Returns a copy of the document map to prevent external modifications.
  ///
  /// Example:
  /// ```dart
  /// final allValues = dynamicFormKey.currentState?.getAllFieldValues();
  /// print('Form data: $allValues');
  /// ```
  Map<String, dynamic> getAllFieldValues() {
    return Map<String, dynamic>.from(widget.document);
  }

  /// Manually triggers dependency recalculation for a specific field
  ///
  /// Useful when you need to recalculate a dependent field without changing its source fields.
  ///
  /// Example:
  /// ```dart
  /// dynamicFormKey.currentState?.recalculateDependencies('mortgagedAmount');
  /// ```
  void recalculateDependencies(String dependentFieldKey) {
    _updateDependentField(dependentFieldKey);
    setState(() {});
  }

  /// Helper method to update a dependent field
  ///
  /// Calculates the new value using the dependency's calculator function
  /// and updates both the controller (if exists) and the document map.
  void _updateDependentField(String dependentKey) {
    if (widget.dependencies == null) return;

    final dependency = widget.dependencies!.getDependency(dependentKey);
    if (dependency == null) return;

    // Calculate new value using the calculator function
    final newValue = dependency.calculator(widget.document);

    // Update UI via controller if exists
    if (dependentControllers.containsKey(dependentKey)) {
      dependentControllers[dependentKey]!.text = newValue;
    }

    // Update document map
    widget.document[dependentKey] = newValue;
  }

  @override
  Widget build(BuildContext context) {
    return BoxLayout(
      child: Form(
        key: _internalFormKey,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.sections.length,
          itemBuilder: (context, index) => widget.sections[index].rows != null
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.sections[index].rows!.length,
                  itemBuilder: (context, rowIndex) {
                    if (widget.sections[index].rows![rowIndex].fields == null) {
                      return const SizedBox();
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        (widget.sections[index].rows![rowIndex].fields ?? [])
                            .length,
                        (fieldIndex) => Expanded(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppStyle.spacing,
                            vertical: AppStyle.spacingSmall,
                          ),
                          child: DynamicFormField(
                            field: widget.sections[index].rows![rowIndex]
                                .fields![fieldIndex],
                            document: widget.document,
                            dependencies: widget.dependencies,
                            dependentControllers: dependentControllers,
                          ),
                        )),
                      ),
                    );
                  },
                )
              : Container(),
        ),
      ),
    );
  }
}
