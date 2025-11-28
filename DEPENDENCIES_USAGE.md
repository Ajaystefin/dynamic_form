# Dynamic Form Field Dependencies - Usage Guide

## Overview

The dynamic form now supports field dependencies where one field's value can automatically update based on values from other fields. This is useful for:
- Concatenating fields (e.g., full name from first + last name)
- Copying values (e.g., billing address from shipping address)
- Calculating values (e.g., total from quantity × price)

## Key Features

- ✅ **Per-screen configuration**: Each screen can define its own dependencies
- ✅ **Multiple source fields**: A dependent field can use values from multiple source fields
- ✅ **Supports textfields and currency dropdowns**
- ✅ **Always auto-updates**: When source fields change, dependent fields recalculate
- ✅ **Editable**: Dependent fields remain editable (manual edits will be overwritten on next source change)

## How to Use

### Step 1: Define Dependencies

Create a `FieldDependencies` object with your dependency rules:

```dart
import 'package:wcas_frontend/core/components/dynamic_form/field_dependencies.dart';

// Example 1: Simple concatenation
final myFormDependencies = FieldDependencies([
  FieldDependency(
    dependentFieldKey: 'fullName',
    sourceFieldKeys: ['firstName', 'lastName'],
    calculator: (document) {
      final firstName = document['firstName']?.toString() ?? '';
      final lastName = document['lastName']?.toString() ?? '';
      return '$firstName $lastName'.trim();
    },
  ),
]);
```

### Step 2: Pass Dependencies to DynamicForm

When creating your `DynamicForm`, pass the dependencies:

```dart
DynamicForm(
  formKey: _formKey,
  sections: sections,
  document: document,
  dependencies: myFormDependencies, // Add this parameter
)
```

### Step 3: That's it!

The form will automatically:
1. Detect when source fields change
2. Run the calculator function
3. Update the dependent field's UI and document map

## Complete Examples

### Example 1: Full Name from First + Last Name

```dart
final nameDependencies = FieldDependencies([
  FieldDependency(
    dependentFieldKey: 'fullName',
    sourceFieldKeys: ['firstName', 'lastName'],
    calculator: (document) {
      final firstName = document['firstName']?.toString() ?? '';
      final lastName = document['lastName']?.toString() ?? '';
      return '$firstName $lastName'.trim();
    },
  ),
]);

// In your widget:
DynamicForm(
  formKey: _formKey,
  sections: sections,
  document: document,
  dependencies: nameDependencies,
)
```

**Result**: When user types in `firstName` or `lastName`, the `fullName` field automatically updates.

### Example 2: Full Address from Multiple Fields

```dart
final addressDependencies = FieldDependencies([
  FieldDependency(
    dependentFieldKey: 'fullAddress',
    sourceFieldKeys: ['street', 'city', 'state', 'zipCode'],
    calculator: (document) {
      final street = document['street']?.toString() ?? '';
      final city = document['city']?.toString() ?? '';
      final state = document['state']?.toString() ?? '';
      final zip = document['zipCode']?.toString() ?? '';

      final parts = [street, city, state, zip].where((s) => s.isNotEmpty);
      return parts.join(', ');
    },
  ),
]);
```

**Result**: When any address field changes, `fullAddress` updates with the formatted address.

### Example 3: Copy Billing from Shipping Address

```dart
final billingDependencies = FieldDependencies([
  FieldDependency(
    dependentFieldKey: 'billingAddress',
    sourceFieldKeys: ['shippingAddress'],
    calculator: (document) {
      return document['shippingAddress']?.toString() ?? '';
    },
  ),
]);
```

**Result**: When `shippingAddress` changes, `billingAddress` automatically copies the value.

### Example 4: Calculate Total Amount

```dart
final calculationDependencies = FieldDependencies([
  FieldDependency(
    dependentFieldKey: 'totalAmount',
    sourceFieldKeys: ['quantity', 'unitPrice'],
    calculator: (document) {
      final qty = double.tryParse(document['quantity']?.toString() ?? '0') ?? 0;
      final price = double.tryParse(document['unitPrice']?.toString() ?? '0') ?? 0;
      final total = qty * price;
      return total.toStringAsFixed(2);
    },
  ),
]);
```

**Result**: When `quantity` or `unitPrice` changes, `totalAmount` automatically calculates.

### Example 5: Currency Dropdown Dependency

```dart
final currencyDependencies = FieldDependencies([
  FieldDependency(
    dependentFieldKey: 'convertedAmount',
    sourceFieldKeys: ['originalAmount'], // originalAmount is a currency field
    calculator: (document) {
      // Currency fields store Map<String, dynamic> like {'USD': '1000'}
      final originalAmount = document['originalAmount'] as Map<String, dynamic>?;

      if (originalAmount == null || originalAmount.isEmpty) {
        return '';
      }

      // Get the first (and only) entry
      final entry = originalAmount.entries.first;
      final currency = entry.key;
      final amount = double.tryParse(entry.value?.toString() ?? '0') ?? 0;

      // Convert to EUR (example rate)
      final converted = amount * 0.85;

      return converted.toStringAsFixed(2);
    },
  ),
]);
```

**Result**: When `originalAmount` currency field changes, `convertedAmount` recalculates based on the currency and value.

### Example 6: Multiple Dependencies in One Form

```dart
final complexDependencies = FieldDependencies([
  // Dependency 1: Full name
  FieldDependency(
    dependentFieldKey: 'fullName',
    sourceFieldKeys: ['firstName', 'lastName'],
    calculator: (document) {
      final firstName = document['firstName']?.toString() ?? '';
      final lastName = document['lastName']?.toString() ?? '';
      return '$firstName $lastName'.trim();
    },
  ),

  // Dependency 2: Full address
  FieldDependency(
    dependentFieldKey: 'fullAddress',
    sourceFieldKeys: ['street', 'city', 'zipCode'],
    calculator: (document) {
      final street = document['street']?.toString() ?? '';
      final city = document['city']?.toString() ?? '';
      final zip = document['zipCode']?.toString() ?? '';
      return '$street, $city $zip'.trim();
    },
  ),

  // Dependency 3: Total calculation
  FieldDependency(
    dependentFieldKey: 'total',
    sourceFieldKeys: ['subtotal', 'tax'],
    calculator: (document) {
      final subtotal = double.tryParse(document['subtotal']?.toString() ?? '0') ?? 0;
      final tax = double.tryParse(document['tax']?.toString() ?? '0') ?? 0;
      return (subtotal + tax).toStringAsFixed(2);
    },
  ),
]);
```

**Result**: All three dependencies work independently in the same form.

### Example 7: Chained Dependencies

```dart
final chainedDependencies = FieldDependencies([
  // First dependency: fullName from firstName + lastName
  FieldDependency(
    dependentFieldKey: 'fullName',
    sourceFieldKeys: ['firstName', 'lastName'],
    calculator: (document) {
      final firstName = document['firstName']?.toString() ?? '';
      final lastName = document['lastName']?.toString() ?? '';
      return '$firstName $lastName'.trim();
    },
  ),

  // Second dependency: greeting uses fullName (which is a dependent field)
  FieldDependency(
    dependentFieldKey: 'greeting',
    sourceFieldKeys: ['fullName'],
    calculator: (document) {
      final fullName = document['fullName']?.toString() ?? 'Guest';
      return 'Hello, $fullName!';
    },
  ),
]);
```

**Result**: When `firstName` or `lastName` changes:
1. `fullName` updates
2. `greeting` updates (because it depends on `fullName`)

## Important Notes

### Field Keys Must Match

The `dependentFieldKey` and `sourceFieldKeys` must match the `key` property in your `DynamicField` model from the server.

### Calculator Function

The calculator function:
- Receives the entire `document` map
- Should handle null values gracefully (use `?.toString() ?? ''`)
- Must return a `String`
- Should be pure (no side effects, same inputs = same output)

### Supported Field Types

Currently supports:
- ✅ `FieldType.textField`
- ✅ `FieldType.percentage`
- ✅ `FieldType.amount`
- ✅ `FieldType.customerSearch`
- ✅ `FieldType.currency`

Other field types (dropdown, date, etc.) are not yet supported for dependencies.

### User Manual Edits

If a user manually edits a dependent field, their changes will be overwritten the next time a source field changes. This is by design for simplicity.

### Performance

The calculator function runs every time a source field changes. Keep calculations simple and fast. Avoid:
- Heavy computations
- API calls (use async operations outside the form)
- Complex string operations

### No Circular Dependencies

Do NOT create circular dependencies:

❌ **Bad** (circular):
```dart
FieldDependencies([
  FieldDependency(
    dependentFieldKey: 'fieldA',
    sourceFieldKeys: ['fieldB'],
    calculator: (doc) => doc['fieldB']?.toString() ?? '',
  ),
  FieldDependency(
    dependentFieldKey: 'fieldB',
    sourceFieldKeys: ['fieldA'],
    calculator: (doc) => doc['fieldA']?.toString() ?? '',
  ),
])
```

✅ **Good** (one-way):
```dart
FieldDependencies([
  FieldDependency(
    dependentFieldKey: 'fieldB',
    sourceFieldKeys: ['fieldA'],
    calculator: (doc) => doc['fieldA']?.toString() ?? '',
  ),
])
```

## No Dependencies?

If your screen doesn't need dependencies, simply don't pass the parameter:

```dart
DynamicForm(
  formKey: _formKey,
  sections: sections,
  document: document,
  // No dependencies parameter = no dependencies
)
```

## Testing Dependencies

To test your dependencies:

1. Create a simple test form with source and dependent fields
2. Type in source fields
3. Verify dependent field updates immediately
4. Check document map contains correct values
5. Submit form and verify server receives correct data

## Example Screen Implementation

```dart
class MyFormScreen extends StatefulWidget {
  @override
  State<MyFormScreen> createState() => _MyFormScreenState();
}

class _MyFormScreenState extends State<MyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _document = {};

  // Define dependencies for this screen
  final _dependencies = FieldDependencies([
    FieldDependency(
      dependentFieldKey: 'fullName',
      sourceFieldKeys: ['firstName', 'lastName'],
      calculator: (document) {
        final firstName = document['firstName']?.toString() ?? '';
        final lastName = document['lastName']?.toString() ?? '';
        return '$firstName $lastName'.trim();
      },
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Form')),
      body: DynamicForm(
        formKey: _formKey,
        sections: _sections, // Your sections from server
        document: _document,
        dependencies: _dependencies, // Pass dependencies here
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            _formKey.currentState?.save();
            print('Document: $_document');
            // Submit to server
          }
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
```

## Advanced: Reusable Dependencies

You can create reusable dependency configurations:

```dart
// In a separate file: lib/core/components/dynamic_form/common_dependencies.dart

class CommonDependencies {
  static final FieldDependencies fullName = FieldDependencies([
    FieldDependency(
      dependentFieldKey: 'fullName',
      sourceFieldKeys: ['firstName', 'lastName'],
      calculator: (document) {
        final firstName = document['firstName']?.toString() ?? '';
        final lastName = document['lastName']?.toString() ?? '';
        return '$firstName $lastName'.trim();
      },
    ),
  ]);

  static final FieldDependencies address = FieldDependencies([
    FieldDependency(
      dependentFieldKey: 'fullAddress',
      sourceFieldKeys: ['street', 'city', 'state', 'zipCode'],
      calculator: (document) {
        final parts = [
          document['street']?.toString() ?? '',
          document['city']?.toString() ?? '',
          document['state']?.toString() ?? '',
          document['zipCode']?.toString() ?? '',
        ].where((s) => s.isNotEmpty);
        return parts.join(', ');
      },
    ),
  ]);

  // Combine multiple dependency sets
  static FieldDependencies combine(List<FieldDependencies> sets) {
    final allDeps = <FieldDependency>[];
    for (var set in sets) {
      allDeps.addAll(set.dependencies);
    }
    return FieldDependencies(allDeps);
  }
}

// Usage:
final myDependencies = CommonDependencies.combine([
  CommonDependencies.fullName,
  CommonDependencies.address,
]);
```

## Troubleshooting

### Dependent field not updating?

1. Check that `dependentFieldKey` matches the field's `key` property
2. Check that `sourceFieldKeys` match the source fields' `key` properties
3. Verify dependencies are passed to `DynamicForm`
4. Ensure calculator function returns a valid string

### Getting null values?

Always use null-safe operators in calculator:
```dart
calculator: (document) {
  final value = document['fieldKey']?.toString() ?? ''; // Good
  // NOT: document['fieldKey'].toString() // Bad - will crash
}
```

### Performance issues?

- Keep calculator functions simple
- Avoid expensive operations
- Don't perform API calls in calculator

### Want to preserve manual edits?

This is not currently supported. The design always overwrites dependent fields when source fields change. If you need this, please request a feature enhancement.

## Reference: Built-in Examples

See `field_dependencies.dart` for example implementations:
- `ExampleDependencies.fullNameExample`
- `ExampleDependencies.addressExample`
