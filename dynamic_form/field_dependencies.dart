// Calculator function that takes the document map and returns the calculated value
typedef DependencyCalculator = String Function(Map<String, dynamic> document);

// Represents a dependency between fields
class FieldDependency {
  final String dependentFieldKey;
  final List<String> sourceFieldKeys;
  final DependencyCalculator calculator;

  const FieldDependency({
    required this.dependentFieldKey,
    required this.sourceFieldKeys,
    required this.calculator,
  });
}

// Helper class to manage field dependencies
class FieldDependencies {
  final List<FieldDependency> dependencies;

  const FieldDependencies(this.dependencies);

  // Empty dependencies (no dependencies defined)
  static const FieldDependencies empty = FieldDependencies([]);

  // Helper: Get dependencies where this field is a source
  List<FieldDependency> getDependenciesForSource(String sourceKey) {
    return dependencies
        .where((dep) => dep.sourceFieldKeys.contains(sourceKey))
        .toList();
  }

  // Helper: Check if a field is dependent
  bool isDependent(String fieldKey) {
    return dependencies.any((dep) => dep.dependentFieldKey == fieldKey);
  }

  // Helper: Get dependency for a specific dependent field
  FieldDependency? getDependency(String dependentFieldKey) {
    try {
      return dependencies
          .firstWhere((d) => d.dependentFieldKey == dependentFieldKey);
    } catch (e) {
      return null;
    }
  }

  // Helper: Get source fields for a dependent field
  List<String>? getSourceFields(String fieldKey) {
    final dep = getDependency(fieldKey);
    return dep?.sourceFieldKeys;
  }
}

// Example dependencies - can be used as reference or in specific screens
class ExampleDependencies {
  static final FieldDependencies fullNameExample = FieldDependencies([
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

  static final FieldDependencies addressExample = FieldDependencies([
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
  ]);
}
