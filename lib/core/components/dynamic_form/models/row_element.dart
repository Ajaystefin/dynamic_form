import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";

/// Represents a row within a dynamic form section.
class RowElement {
  /// Creates a [RowElement].
  RowElement({this.number, this.fields});

  /// Creates a [RowElement] from JSON.
  RowElement.fromJson(Map<String, dynamic> json) {
    number = json["rowNumber"];
    fields = json["controlList"] == null
        ? null
        : (json["controlList"] as List)
            .map((e) => DynamicField.fromJson(e))
            .toList();
  }

  /// Row number.
  int? number;

  /// Fields contained in the row.
  List<DynamicField>? fields;

  /// Converts this row to JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["rowNumber"] = number;
    if (fields != null) {
      data["controlList"] = fields?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
