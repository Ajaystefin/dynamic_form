import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';

class RowElement {
  int? number;
  List<DynamicField>? fields;

  RowElement({this.number, this.fields});

  RowElement.fromJson(Map<String, dynamic> json) {
    number = json["rowNumber"];
    fields = json["controlList"] == null
        ? null
        : (json["controlList"] as List)
            .map((e) => DynamicField.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["rowNumber"] = number;
    if (fields != null) {
      data["controlList"] = fields?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
