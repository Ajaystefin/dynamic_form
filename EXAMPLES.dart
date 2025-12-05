import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/dynamic_form/dynamic_form.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/section.dart';

/// Example ViewModel demonstrating how to use the Dynamic Form field update feature.
///
/// This example shows:
/// - How to set up the GlobalKey for DynamicFormState
/// - How to update single fields
/// - How to update multiple fields at once
/// - How to get field values
/// - How to reset fields
class ExampleViewModel extends Cubit<ExampleState> {
  ExampleViewModel() : super(ExampleState());

  /// GlobalKey to access DynamicFormState methods
  /// This key should be passed to the DynamicForm widget
  GlobalKey<DynamicFormState> dynamicFormKey = GlobalKey<DynamicFormState>();

  /// Document map that stores all form field values
  /// This is shared with the DynamicForm widget
  Map<String, dynamic> dynamicFormDocument = {};

  /// Form key for validation
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Form sections (loaded from API or configured)
  List<Section> sections = [];

  // ============================================================================
  // EXAMPLE 1: Update a single text field
  // ============================================================================

  void updateFacilityTitle(String newTitle) {
    dynamicFormKey.currentState?.updateFieldValue('facilityTitle', newTitle);
  }

  // ============================================================================
  // EXAMPLE 2: Update a dropdown field
  // ============================================================================

  void updateSector(String sectorId) {
    // For dropdowns, pass the option key/id
    dynamicFormKey.currentState?.updateFieldValue('sector', sectorId);
  }

  // ============================================================================
  // EXAMPLE 3: Update a currency field
  // ============================================================================

  void updateProposedLimit(String currency, String amount) {
    // Currency fields require a map with 'currency' and 'value'
    dynamicFormKey.currentState?.updateFieldValue('proposedLimit', {
      'currency': currency,
      'value': amount,
    });
  }

  // ============================================================================
  // EXAMPLE 4: Update a date field
  // ============================================================================

  void updateLimitAvailabilityDate(DateTime selectedDate) {
    // Date fields require a specific map structure
    dynamicFormKey.currentState?.updateFieldValue('limitAvailabilityDate', {
      'date': {
        'year': selectedDate.year,
        'month': selectedDate.month,
        'day': selectedDate.day,
      },
      'jsdate': selectedDate.toIso8601String(),
      'formatted': '${selectedDate.day.toString().padLeft(2, '0')}/'
          '${selectedDate.month.toString().padLeft(2, '0')}/'
          '${selectedDate.year}',
      'epoc': selectedDate.millisecondsSinceEpoch ~/ 1000,
    });
  }

  // ============================================================================
  // EXAMPLE 5: Update a checkbox field
  // ============================================================================

  void updateIsCommitted(bool isCommitted) {
    dynamicFormKey.currentState?.updateFieldValue('isCommitted', isCommitted);
  }

  // ============================================================================
  // EXAMPLE 6: Update multiple fields at once (RECOMMENDED for batch updates)
  // ============================================================================

  void initializeFormWithDefaults() {
    // Use updateMultipleFields for better performance when updating multiple fields
    dynamicFormKey.currentState?.updateMultipleFields({
      'facilityTitle': 'Default Facility Title',
      'sector': '356',
      'proposedLimit': {
        'currency': 'AED',
        'value': '0',
      },
      'isCommitted': true,
      'discountFactor': '0.0',
    });
  }

  // ============================================================================
  // EXAMPLE 7: Get current field value
  // ============================================================================

  String? getCurrentFacilityTitle() {
    return dynamicFormKey.currentState?.getFieldValue('facilityTitle');
  }

  Map<String, dynamic>? getCurrentProposedLimit() {
    return dynamicFormKey.currentState?.getFieldValue('proposedLimit');
  }

  // ============================================================================
  // EXAMPLE 8: Reset specific fields
  // ============================================================================

  void clearFacilityTitle() {
    dynamicFormKey.currentState?.resetField('facilityTitle');
  }

  void resetAllFields() {
    // Reset multiple fields
    dynamicFormKey.currentState?.updateMultipleFields({
      'facilityTitle': null,
      'sector': null,
      'proposedLimit': null,
      'isCommitted': null,
      'discountFactor': null,
    });
  }

  // ============================================================================
  // EXAMPLE 9: Update based on business logic
  // ============================================================================

  void onCurrencyChanged(String newCurrency) {
    // Get current amount
    Map<String, dynamic>? currentLimit =
        dynamicFormKey.currentState?.getFieldValue('proposedLimit');

    String currentAmount = currentLimit?['value'] ?? '0';

    // Update with new currency but keep the amount
    dynamicFormKey.currentState?.updateFieldValue('proposedLimit', {
      'currency': newCurrency,
      'value': currentAmount,
    });

    // You could also fetch exchange rates and update other fields
    // based on the new currency
  }

  // ============================================================================
  // EXAMPLE 10: Conditional field updates
  // ============================================================================

  void onLimitTypeChanged(bool isMainLimit) {
    if (isMainLimit) {
      // For main limits, clear certain fields
      dynamicFormKey.currentState?.updateMultipleFields({
        'controllingLimitNumber': null,
        'parentLimitId': null,
      });
    } else {
      // For sub-limits, you might want to set default values
      dynamicFormKey.currentState?.updateFieldValue(
        'controllingLimitNumber',
        'SELECT',
      );
    }
  }

  // ============================================================================
  // EXAMPLE 11: Auto-calculate fields
  // ============================================================================

  void calculateTotalAmount() {
    // Get values from multiple fields
    String? amount = dynamicFormKey.currentState?.getFieldValue('baseAmount');
    String? rate = dynamicFormKey.currentState?.getFieldValue('interestRate');

    if (amount != null && rate != null) {
      double baseAmount = double.tryParse(amount) ?? 0;
      double interestRate = double.tryParse(rate) ?? 0;
      double total = baseAmount * (1 + interestRate / 100);

      // Update the calculated field
      dynamicFormKey.currentState?.updateFieldValue(
        'totalAmount',
        total.toStringAsFixed(2),
      );
    }
  }

  // ============================================================================
  // EXAMPLE 12: Populate form from API data
  // ============================================================================

  void loadFacilityData(Map<String, dynamic> facilityData) {
    // Convert API data to form field values
    Map<String, dynamic> formUpdates = {};

    if (facilityData.containsKey('title')) {
      formUpdates['facilityTitle'] = facilityData['title'];
    }

    if (facilityData.containsKey('sectorId')) {
      formUpdates['sector'] = facilityData['sectorId'].toString();
    }

    if (facilityData.containsKey('currency') &&
        facilityData.containsKey('amount')) {
      formUpdates['proposedLimit'] = {
        'currency': facilityData['currency'],
        'value': facilityData['amount'].toString(),
      };
    }

    // Apply all updates at once
    dynamicFormKey.currentState?.updateMultipleFields(formUpdates);
  }

  // ============================================================================
  // EXAMPLE 13: Validation before update
  // ============================================================================

  bool updateWithValidation(String fieldKey, dynamic value) {
    // Perform custom validation before updating
    if (fieldKey == 'proposedLimit' && value is Map) {
      String amount = value['value'] ?? '0';
      double? numericAmount = double.tryParse(amount);

      if (numericAmount == null || numericAmount < 0) {
        // Invalid amount, don't update
        return false;
      }
    }

    // Update if validation passes
    dynamicFormKey.currentState?.updateFieldValue(fieldKey, value);
    return true;
  }

  // ============================================================================
  // EXAMPLE 14: Check if form state is ready
  // ============================================================================

  bool isFormReady() {
    return dynamicFormKey.currentState != null;
  }

  void safeUpdateField(String fieldKey, dynamic value) {
    if (isFormReady()) {
      dynamicFormKey.currentState!.updateFieldValue(fieldKey, value);
    }
    // If form not ready, you could store the value to apply later
    // or show an error message using your app's error handling mechanism
  }
}

// Simple state class for the example
class ExampleState {
  ExampleState();
}
