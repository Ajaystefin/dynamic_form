/// Represents an entry in an appendix with a label and value.
class AppendixEntry {
  /// Creates an [AppendixEntry] instance.
  ///
  /// [id] is required and uniquely identifies the entry.
  /// [label] and [value] default to empty strings.
  AppendixEntry({
    required this.id,
    this.label = "",
    this.value = "",
  });

  /// Unique identifier for the appendix entry.
  final String id;

  /// Descriptive label for the entry.
  final String label;

  /// Value associated with the entry.
  final String value;

  /// Creates a copy of this object with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  AppendixEntry copyWith({
    String? label,
    String? value,
  }) =>
      AppendixEntry(
        id: id,
        label: label ?? this.label,
        value: value ?? this.value,
      );
}
