import 'package:wcas_frontend/core/components/dynamic_form/models/row_element.dart';

class Section {
  int? number;
  String? type;
  List<RowElement>? rows;

  Section({this.number, this.type, this.rows});

  Section.fromJson(Map<String, dynamic> json) {
    number = json["sectionNumber"];
    type = json["sectionClass"];
    rows = json["rowList"] == null
        ? null
        : (json["rowList"] as List).map((e) => RowElement.fromJson(e)).toList();
  }

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
