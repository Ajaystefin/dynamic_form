import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";

/// Represents a column definition within a dynamic grid.
class DynamicGridField {
  /// Creates a [DynamicGridField].
  DynamicGridField({
    required this.columnTitle,
    required this.dynamicField,
  });

  /// Creates a [DynamicGridField] from JSON.
  factory DynamicGridField.fromJson(Map<String, dynamic> json) {
    return DynamicGridField(
      columnTitle: json["columnTitle"] ?? "",
      dynamicField: DynamicField.fromJson(json["control"]),
    );
  }

  /// Column title.
  final String? columnTitle;

  /// Field configuration for the column.
  final DynamicField dynamicField;

  /// Converts this grid field to JSON.
  Map<String, dynamic> toJson() {
    return {"columnTitle": columnTitle, "controlList": dynamicField.toJson()};
  }
}
