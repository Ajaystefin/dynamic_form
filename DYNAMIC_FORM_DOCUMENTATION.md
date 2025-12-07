# Dynamic Form Component Documentation

## Overview

The Dynamic Form component is a flexible, data-driven form system that generates form fields dynamically based on JSON configuration received from the backend API. It is currently used in the Security Creation screen (`create_security`) to handle type-specific form fields that vary based on the selected security type.

## Architecture

### Component Structure

```
lib/core/components/dynamic_form/
├── dynamic_form.dart          # Main form widget
├── field.dart                 # Field rendering logic
├── field_dependencies.dart    # Dependency management system
├── fields/                    # Individual field type implementations
│   ├── textfield.dart
│   ├── dropdown.dart
│   ├── date_picker.dart
│   ├── currency_dropdown.dart
│   ├── grid.dart
│   ├── single_check_box.dart
│   ├── text_area.dart
│   ├── country_dropdown.dart
│   ├── reference_data_dropdown.dart
│   ├── conditional_textbox.dart
│   ├── multiselect.dart
│   ├── radio_button.dart
│   ├── search_entity.dart
│   └── dropdown_textfield.dart
└── models/
    ├── field.dart             # Field model and FieldType enum
    ├── section.dart           # Section model
    ├── row_element.dart       # Row model
    └── grid_field.dart        # Grid column model
```

### Data Models

#### Section
- `number`: Section number (int)
- `type`: Section class/type (String, e.g., "outline")
- `rows`: List of RowElement objects

#### RowElement
- `number`: Row number (int)
- `fields`: List of DynamicField objects

#### DynamicField
- `controlType`: FieldType enum (determines which widget to render)
- `key`: Unique identifier for the field (String)
- `label`: Display label (String)
- `required`: Whether field is required (bool)
- `maxLength`: Maximum input length (int?)
- `rowData`: Row data value (int)
- `optionList`: List of options for dropdowns (List<Option>?)
- `message`: Validation/error message (String?)
- `validationPattern`: Regex pattern for validation (String?)
- `directiveType`: Directive type code (String?)
- `dependentList`: List of dependent fields (List<Option>?)
- `operationKey`: Operation key for reference data (String?)
- `enabledDefault`: Whether field is enabled by default (bool)
- `isDisable`: Whether field is disabled (bool)
- `isActive`: Whether field is active (bool)
- `defaultValue`: Default value (dynamic)
- `columnInfoList`: List of grid columns (List<DynamicGridField>?)

#### Option
- `key`: Option key/value (String?)
- `pairValue`: Display value (String?)
- `metaData`: Additional metadata (dynamic)

## Input Format (API Response)

The component receives JSON data from the backend API endpoint `getSecurityDynamicForm`. The structure follows this format:

```json
{
  "responseData": {
    "sectionList": [
      {
        "sectionNumber": 1,
        "sectionClass": "outline",
        "rowList": [
          {
            "rowNumber": 1,
            "controlList": [
              {
                "controlType": "conditionalDropdown",
                "key": "typeOfInsurance",
                "label": "Type Of Insurance",
                "required": true,
                "maxLength": 15,
                "rowData": 3,
                "optionList": [
                  {
                    "value": "Asset Insurance",
                    "key": "assetInsurance"
                  }
                ],
                "message": "Type of Insurance is mandatory",
                "directiveType": "13",
                "dependentList": [
                  {
                    "value": "creditInsurance",
                    "key": "approvedCounterpartyInTermsOfCreditInsurance"
                  }
                ],
                "enabledDefault": true,
                "isDisable": false,
                "defaultValue": null
              }
            ]
          }
        ]
      }
    ]
  }
}
```

### Key Input Properties

- **controlType**: Maps to FieldType enum (e.g., "textbox", "dropdown", "datePicker", "grid", "currency", etc.)
- **dependentList**: Defines field visibility/enablement dependencies. When a source field's value matches a dependency's `value`, the dependent field (specified by `key`) is shown/enabled.
- **columnInfoList**: Used for Grid fields. Contains column definitions with nested control configurations.

## Output Format (API Request)

The form data is collected in a `Map<String, dynamic>` called `dynamicFormDocument` and is serialized to JSON string in the `additionalDetails` field when saving:

```json
{
  "requestData": {
    "additionalDetails": "{\"typeOfInsurance\":\"assetInsurance\",\"nameOfTheInsuranceCompany\":\"1793\",\"policyNumber\":\"12\",\"policyExpiryDate\":{\"date\":{\"year\":2025,\"month\":12,\"day\":11},\"jsdate\":\"2025-12-10T20:00:00.000Z\",\"formatted\":\"11/12/2025\",\"epoc\":1765396800},\"premiumAmount\":{\"fromCurrency\":\"AED\",\"fromVal\":12,\"aedEquivalent\":12}}"
  }
}
```

### Data Format by Field Type

- **Text fields**: Stored as String
- **Dropdowns**: Stored as the option's `key` value (String)
- **Date pickers**: Stored as object with `date`, `jsdate`, `formatted`, and `epoc` properties
- **Currency fields**: Stored as object with `fromCurrency`, `fromVal`, and `aedEquivalent` properties
- **Checkboxes**: Stored as boolean
- **Grids**: Stored as array of objects (one per row)

## Supported Field Types

The component supports the following field types (defined in `FieldType` enum):

1. **textField** - Standard text input
2. **dropdown** - Single-select dropdown
3. **conditionaldropdown** - Dropdown with conditional logic
4. **datePicker** - Date selection picker
5. **singleCheckBox** - Single checkbox
6. **currency** - Currency input with dropdown
7. **grid** - Dynamic table/grid with add/delete rows
8. **table** - Read-only table (uses grid implementation)
9. **textArea** - Multi-line text input
10. **percentage** - Numeric input for percentages
11. **amount** - Numeric input for amounts
12. **multiSelect** - Multi-select dropdown
13. **customerSearch** - Customer search field
14. **entityIdField** - Entity ID search field
15. **tenorControl** - Tenor control with dropdown
16. **conditionalTextbox** - Conditional text input
17. **radioButton** - Radio button group
18. **refDataDropdown** - Reference data dropdown (fetches from API)
19. **countryDropdown** - Country selection dropdown

## Field Dependencies System

The component supports two types of dependencies:

### 1. Simple Dependencies (via dependentList)

Defined in the field configuration's `dependentList` property. When a source field's value matches a dependency entry's `value`, the dependent field (specified by `key`) is shown/enabled.

**Example:**
```json
{
  "controlType": "singleCheckBox",
  "key": "mortgagedInFavourOfCBD",
  "dependentList": [
    {
      "value": "true",
      "key": "mortgagedAmount"
    },
    {
      "value": "true",
      "key": "dateOfAcknowledgement"
    }
  ]
}
```

When `mortgagedInFavourOfCBD` is checked (value = "true"), `mortgagedAmount` and `dateOfAcknowledgement` fields are shown/enabled.

### 2. Calculated Dependencies (via FieldDependencies)

For more complex dependencies that require calculations, the component uses `FieldDependencies` class with calculator functions.

**Example from create_security:**
```dart
FieldDependencies([
  FieldDependency(
    dependentFieldKey: 'maximumLendingValue',
    sourceFieldKeys: ['securityvalueadjustedtoLTV'],
    calculator: (document) {
      final adjustedValue = document['securityvalueadjustedtoLTV']?.toString() ?? '';
      return adjustedValue.trim();
    },
  ),
])
```

This allows dependent fields to be calculated based on source field values.

## Usage Example

### In Create Security Screen

```dart
// 1. Fetch dynamic form configuration
sections = await securityRepository.getSecurityDynamicForm(
  typeID: ServerConstants.dynamicFormSecurityID,
  subTypeID: security.securityType?.id,
);

// 2. Initialize document map
Map<String, dynamic> dynamicFormDocument = {};

// 3. Render the form
DynamicForm(
  sections: sections,
  document: dynamicFormDocument,
  formKey: dynamicFormKey,
  dependencies: getDynamicFormDependencies(),
)

// 4. Save form data
dynamicFormKey.currentState!.save();
security.dynamicFormDocument = dynamicFormDocument;
await repository.saveSecurityDetails(security);
```

### Field Dependencies Setup

```dart
FieldDependencies getDynamicFormDependencies() {
  return FieldDependencies([
    FieldDependency(
      dependentFieldKey: 'maximumLendingValue',
      sourceFieldKeys: ['securityvalueadjustedtoLTV'],
      calculator: (document) {
        final adjustedValue = document['securityvalueadjustedtoLTV']?.toString() ?? '';
        return adjustedValue.trim();
      },
    ),
  ]);
}
```

## Programmatic Field Updates

The dynamic form supports programmatic field updates from parent modules through the `DynamicFormState` class. This allows ViewModels and other components to update field values externally.

### Accessing the Form State

Use a `GlobalKey<DynamicFormState>` to access the form state:

```dart
GlobalKey<DynamicFormState> dynamicFormKey = GlobalKey<DynamicFormState>();

DynamicForm(
  formKey: dynamicFormKey,
  sections: sections,
  document: document,
  dependencies: dependencies,
)
```

### Available Methods

#### validate()

Validates all form fields. Returns true if all fields pass validation, false otherwise.

**Returns:** bool - true if all fields are valid, false otherwise

**Example:**
```dart
if (dynamicFormKey.currentState?.validate() ?? false) {
  // All fields are valid, proceed with save
  dynamicFormKey.currentState?.save();
} else {
  // Show validation errors
  AlertManager().showFailureToast('Please fix validation errors');
}
```

#### save()

Saves all form fields by calling the onSaved callback for each field.

**Example:**
```dart
// Validate first, then save
if (dynamicFormKey.currentState?.validate() ?? false) {
  dynamicFormKey.currentState?.save();
  // Now you can access the saved data from the document map
  final formData = dynamicFormKey.currentState?.getAllFieldValues();
}
```

#### updateFieldValue(fieldKey, value, {triggerDependencies})

Updates a single field value by its key. The method automatically updates the UI and triggers dependent field recalculations.

**Parameters:**
- `fieldKey` (String): The unique key of the field to update
- `value` (dynamic): The new value for the field
- `triggerDependencies` (bool, optional): Whether to recalculate dependent fields (default: true)

**Example:**
```dart
// Update a text field
dynamicFormKey.currentState?.updateFieldValue('policyNumber', '12345');

// Update a currency field
dynamicFormKey.currentState?.updateFieldValue('premiumAmount', {
  'fromCurrency': 'USD',
  'fromVal': 100,
  'aedEquivalent': 367.3
});

// Update a checkbox
dynamicFormKey.currentState?.updateFieldValue('mortgagedInFavourOfCBD', true);

// Update without triggering dependencies
dynamicFormKey.currentState?.updateFieldValue(
  'someField', 
  'value',
  triggerDependencies: false,
);
```

#### updateFields(updates, {triggerDependencies})

Updates multiple fields at once. This is more efficient than calling `updateFieldValue` multiple times as it only triggers a single rebuild and dependency calculation pass.

**Parameters:**
- `updates` (Map<String, dynamic>): Map of field keys to their new values
- `triggerDependencies` (bool, optional): Whether to recalculate dependent fields (default: true)

**Example:**
```dart
dynamicFormKey.currentState?.updateFields({
  'policyNumber': '12345',
  'premiumAmount': {
    'fromCurrency': 'AED',
    'fromVal': 50,
    'aedEquivalent': 50
  },
  'mortgagedInFavourOfCBD': true,
  'policyExpiryDate': {
    'date': {'year': 2025, 'month': 12, 'day': 31},
    'jsdate': '2025-12-31T00:00:00.000Z',
    'formatted': '31/12/2025',
    'epoc': 1767225600
  },
});
```

#### getFieldValue(fieldKey)

Retrieves the current value of a field by its key.

**Parameters:**
- `fieldKey` (String): The unique key of the field

**Returns:** The current value of the field, or null if the field doesn't exist

**Example:**
```dart
final premiumAmount = dynamicFormKey.currentState?.getFieldValue('premiumAmount');
if (premiumAmount is Map<String, dynamic>) {
  final aedValue = premiumAmount['aedEquivalent'];
  print('AED Equivalent: $aedValue');
}

final policyNumber = dynamicFormKey.currentState?.getFieldValue('policyNumber');
print('Policy Number: $policyNumber');
```

#### getAllFieldValues()

Retrieves all current field values as a map.

**Returns:** A copy of the document map containing all field values

**Example:**
```dart
final allValues = dynamicFormKey.currentState?.getAllFieldValues();
print('All form data: $allValues');

// Use for validation or processing
if (allValues != null) {
  final hasRequiredFields = allValues.containsKey('policyNumber') &&
                           allValues.containsKey('premiumAmount');
}
```

#### recalculateDependencies(dependentFieldKey)

Manually triggers dependency recalculation for a specific field. Useful when you need to recalculate a dependent field without changing its source fields.

**Parameters:**
- `dependentFieldKey` (String): The key of the dependent field to recalculate

**Example:**
```dart
// Recalculate mortgagedAmount based on current premiumAmount
dynamicFormKey.currentState?.recalculateDependencies('mortgagedAmount');
```

### Common Use Cases

#### Auto-fill Fields from API

```dart
void loadSecurityData(Map<String, dynamic> apiData) {
  // Load data from API and populate form fields
  dynamicFormKey.currentState?.updateFields({
    'typeOfInsurance': apiData['typeOfInsurance'],
    'policyNumber': apiData['policyNumber'],
    'premiumAmount': apiData['premiumAmount'],
    'policyExpiryDate': apiData['policyExpiryDate'],
  });
}
```

#### Update Fields Based on External Events

```dart
void onSecurityTypeChanged(int securityTypeId) async {
  // Fetch default values for this security type
  final defaults = await repository.getDefaultValues(securityTypeId);
  
  // Auto-fill form fields with defaults
  dynamicFormKey.currentState?.updateFields({
    'currency': defaults['currency'],
    'securityHeldAs': defaults['securityHeldAs'],
    'securityStatus': defaults['securityStatus'],
  });
}
```

#### Reset Specific Form Sections

```dart
void resetInsuranceSection() {
  // Clear all insurance-related fields
  dynamicFormKey.currentState?.updateFields({
    'typeOfInsurance': null,
    'nameOfTheInsuranceCompany': null,
    'policyNumber': '',
    'premiumAmount': null,
    'policyExpiryDate': null,
  });
}
```

#### Calculate and Update Based on Other Fields

```dart
void calculateMortgageAmount() {
  // Get current premium amount
  final premium = dynamicFormKey.currentState?.getFieldValue('premiumAmount');
  
  if (premium is Map<String, dynamic>) {
    final aedValue = premium['aedEquivalent'] ?? 0;
    
    // Calculate mortgage amount (e.g., 80% of premium)
    final mortgageAmount = aedValue * 0.8;
    
    // Update the mortgage amount field
    dynamicFormKey.currentState?.updateFieldValue('mortgagedAmount', {
      'fromCurrency': 'AED',
      'fromVal': mortgageAmount,
      'aedEquivalent': mortgageAmount,
    });
  }
}
```

#### Conditional Field Updates

```dart
void onMortgageCheckboxChanged(bool isMortgaged) {
  if (isMortgaged) {
    // Enable and populate mortgage fields
    dynamicFormKey.currentState?.updateFields({
      'mortgagedInFavourOfCBD': true,
      'mortgagedAmount': {
        'fromCurrency': 'AED',
        'fromVal': 0,
        'aedEquivalent': 0
      },
      'dateOfAcknowledgement': null,
    });
  } else {
    // Clear mortgage fields
    dynamicFormKey.currentState?.updateFields({
      'mortgagedInFavourOfCBD': false,
      'mortgagedAmount': null,
      'dateOfAcknowledgement': null,
    });
  }
}
```

### Field Dependencies and External Updates

When you update a field using these methods, dependent fields are automatically recalculated if `triggerDependencies` is true (default).

**Example with Dependencies:**
```dart
// Define dependency: mortgagedAmount depends on premiumAmount
FieldDependencies([
  FieldDependency(
    dependentFieldKey: 'mortgagedAmount',
    sourceFieldKeys: ['premiumAmount'],
    calculator: (document) {
      final premium = document['premiumAmount'];
      if (premium is Map<String, dynamic>) {
        return premium['aedEquivalent']?.toString() ?? '';
      }
      return '';
    },
  ),
])

// When you update premiumAmount, mortgagedAmount is automatically recalculated
dynamicFormKey.currentState?.updateFieldValue('premiumAmount', {
  'fromCurrency': 'USD',
  'fromVal': 100,
  'aedEquivalent': 367.3
});
// mortgagedAmount is now automatically updated to '367.3'
```

### Best Practices

1. **Always check for null**: Use `?.` when calling methods on `currentState` since the state may not be initialized yet
   ```dart
   dynamicFormKey.currentState?.updateFieldValue('field', 'value');
   ```

2. **Batch updates**: Use `updateFields()` instead of multiple `updateFieldValue()` calls for better performance
   ```dart
   // ✅ Good - single rebuild
   dynamicFormKey.currentState?.updateFields({
     'field1': 'value1',
     'field2': 'value2',
     'field3': 'value3',
   });
   
   // ❌ Avoid - multiple rebuilds
   dynamicFormKey.currentState?.updateFieldValue('field1', 'value1');
   dynamicFormKey.currentState?.updateFieldValue('field2', 'value2');
   dynamicFormKey.currentState?.updateFieldValue('field3', 'value3');
   ```

3. **Type safety**: Ensure the value type matches what the field expects
   - Text fields: String
   - Currency fields: Map with `fromCurrency`, `fromVal`, `aedEquivalent`
   - Date fields: Map with `date`, `jsdate`, `formatted`, `epoc`
   - Checkboxes: bool
   - Dropdowns: String (option key)

4. **Dependency awareness**: Be aware that updating a field may trigger dependent field recalculations. Use `triggerDependencies: false` if you want to prevent this.

5. **Timing**: Ensure the form is built before calling update methods. Use `addPostFrameCallback` if updating immediately after form creation:
   ```dart
   WidgetsBinding.instance.addPostFrameCallback((_) {
     dynamicFormKey.currentState?.updateFields({...});
   });
   ```


## Key Implementation Details

### Form Rendering Flow

1. **DynamicForm** widget receives sections and document map
2. Iterates through sections → rows → fields
3. For each field, **DynamicFormField** determines the widget type based on `controlType`
4. Field widgets update the `document` map on value changes
5. Form validation uses Flutter's Form widget with GlobalKey

### Field Widget Selection

The `formWidget()` method in `DynamicFormField` uses a switch statement on `FieldType` to select the appropriate widget:

```dart
switch (widget.field.controlType) {
  case FieldType.textField:
    return DynamicFormTextField(...);
  case FieldType.dropdown:
    return DynamicFormDropdown(...);
  // ... etc
}
```

### Data Persistence

- All field values are stored in the `document` Map<String, dynamic>
- Keys match the field's `key` property
- On save, the document map is assigned to `security.dynamicFormDocument`
- The Security model's `toJson()` method serializes `dynamicFormDocument` to JSON string for the `additionalDetails` field

### Grid/Table Fields

Grid fields support:
- Dynamic row addition/deletion
- Multiple column types (text, dropdown, date, checkbox, currency, etc.)
- Nested field configurations via `columnInfoList`
- Data stored as array in document map

## Current Features

1. ✅ Dynamic field rendering based on JSON configuration
2. ✅ Multiple field types (text, dropdown, date, currency, grid, etc.)
3. ✅ Field dependencies (show/hide based on other field values)
4. ✅ Calculated fields (dependent fields with calculator functions)
5. ✅ Form validation
6. ✅ Grid/table with add/delete rows
7. ✅ Reference data dropdowns (fetches from API)
8. ✅ Currency fields with conversion
9. ✅ Date pickers with formatted output
10. ✅ Field enable/disable based on dependencies
11. ✅ Default values support
12. ✅ Custom validation messages
13. ✅ **Programmatic field updates** (update fields externally from ViewModels)
14. ✅ **Batch field updates** (update multiple fields efficiently)
15. ✅ **Field value retrieval** (get current field values programmatically)

## File Locations

- **Main Component**: `lib/core/components/dynamic_form/dynamic_form.dart`
- **Field Rendering**: `lib/core/components/dynamic_form/field.dart`
- **Dependencies**: `lib/core/components/dynamic_form/field_dependencies.dart`
- **Models**: `lib/core/components/dynamic_form/models/`
- **Field Widgets**: `lib/core/components/dynamic_form/fields/`
- **Usage Example**: `lib/features/request/facilities_securities/create_security/`
- **Sample Input**: `assets/mocks/security_getDynamicFormData.json`
- **Sample Output**: `saveSecuritySampleRequest.json`

## Integration Points

1. **API Endpoint**: `getSecurityDynamicForm(typeID, subTypeID)` - Fetches form configuration
2. **Save API**: `saveSecurityDetails(security)` - Saves form data in `additionalDetails`
3. **Reference Data**: Uses `ReferenceDataService` for dropdown options
4. **Currency Codes**: Uses `Globals.dynamicFormCurrencyCodes`
5. **Form Validation**: Uses Flutter's `Form` widget with `GlobalKey<FormState>`

## Areas for Potential Enhancement

1. **Conditional Validation**: Add validation rules that depend on other field values
2. **Field Groups**: Support for grouping fields with collapsible sections
3. **File Upload**: Add file upload field type
4. **Rich Text Editor**: Add rich text/HTML editor field type
5. **Nested Forms**: Support for nested form structures
6. **Field Templates**: Reusable field templates/configurations
7. **Real-time Validation**: Show validation errors as user types
8. **Field Help Text**: Support for help text/tooltips on fields
9. **Custom Field Types**: Plugin system for custom field types
10. **Form State Management**: Better state management for complex forms
11. **Undo/Redo**: Form data undo/redo functionality
12. **Auto-save**: Auto-save form data at intervals
13. **Field Masking**: Input masking for specific formats (phone, ID, etc.)
14. **Multi-step Forms**: Support for wizard/multi-step form flows
15. **Field Dependencies UI**: Visual representation of field dependencies
16. **Form Analytics**: Track field interactions and completion rates
17. **Accessibility**: Enhanced accessibility features (ARIA labels, keyboard navigation)
18. **Internationalization**: Better i18n support for field labels and messages
19. **Field Formatting**: Auto-formatting for numbers, dates, currencies
20. **Conditional Required Fields**: Make fields required based on other field values

## Notes

- The component uses Flutter's `Form` widget for validation
- All field values are stored in a single `Map<String, dynamic>` document
- Field dependencies are handled both declaratively (via JSON) and programmatically (via FieldDependencies)
- Grid fields can contain nested fields of any type
- Date fields output a structured object with multiple date formats
- Currency fields support multiple currencies with AED conversion
- The component is designed to be reusable across different screens/features

