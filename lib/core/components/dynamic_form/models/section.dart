import "package:wcas_frontend/core/components/dynamic_form/models/row_element.dart";

/// Represents a section within a dynamic form.
class Section {
  /// Creates a [Section].
  Section({this.number, this.type, this.rows});

  /// Creates a [Section] from JSON.
  Section.fromJson(Map<String, dynamic> json) {
    number = json["sectionNumber"];
    type = json["sectionClass"];
    rows = json["rowList"] == null
        ? null
        : (json["rowList"] as List).map((e) => RowElement.fromJson(e)).toList();
  }

  /// Section number.
  int? number;

  /// Section type or class.
  String? type;

  /// Rows contained in the section.
  List<RowElement>? rows;

  /// Converts this section to JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["sectionNumber"] = number;
    data["sectionClass"] = type;
    if (rows != null) {
      data["rowList"] = rows?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
