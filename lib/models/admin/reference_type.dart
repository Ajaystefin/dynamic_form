import 'package:wcas_frontend/models/admin/reference.dart';

class ReferenceType {
  int? id;
  String? name;
  String? description;
  String? status;
  List<Reference>? references;
  String? columnsInformation;

  ReferenceType({
    this.id,
    this.name,
    this.description,
    this.status,
    this.references,
    this.columnsInformation
  });

  ReferenceType.fromJson(Map<String, dynamic> json) {
    // Updated: guard against referenceDataTypeId coming in as String or int
    final rawId = json['referenceDataTypeId'];
    if (rawId is int) {
      id = rawId;
    } else if (rawId is String) {
      id = int.tryParse(rawId);
    }

    name = json['name'];
    description = json['description'];
    status = json['status'];

    if (json['referenceDataList'] != null) {
      references = <Reference>[];
      json['referenceDataList'].forEach((v) {
        references!.add(Reference.fromJson(v));
      });
    }

    columnsInformation = json['columnsInfo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['referenceDataTypeId'] = id;
    data['name'] = name;
    data['description'] = description;
    data['status'] = status;
    if (references != null) {
      data['referenceDataList'] = references!.map((v) => v.toJson()).toList();
    }
    data['columnsInfo'] = columnsInformation;
    return data;
  }
}
