import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';

class DynamicGridField {
  final String? columnTitle;
  final DynamicField dynamicField;

  DynamicGridField({
    required this.columnTitle,
    required this.dynamicField,
  });
  factory DynamicGridField.fromJson(Map<String, dynamic> json) {
    return DynamicGridField(
        columnTitle: json['columnTitle'] ?? "",
        dynamicField: DynamicField.fromJson((json['control'])));
  }

  Map<String, dynamic> toJson() {
    return {'columnTitle': columnTitle, 'controlList': dynamicField.toJson()};
  }
}
