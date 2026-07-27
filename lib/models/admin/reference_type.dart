import "package:wcas_frontend/models/admin/reference.dart";

/// Represents a reference type with its metadata, status,
/// associated reference list, column information, and validation regex.
class ReferenceType {
  /// Creates a [ReferenceType] instance.
  ReferenceType({
    this.id,
    this.name,
    this.description,
    this.status,
    this.references,
    this.columnsInformation,
    this.allowedRegex,
  });

  /// Creates a [ReferenceType] instance from a JSON map.
  ///
  /// Supports `referenceDataTypeId` as either an integer or a string value.
  ReferenceType.fromJson(Map<String, dynamic> json) {
    // Updated: guard against referenceDataTypeId coming in as String or int
    final rawId = json["referenceDataTypeId"];
    if (rawId is int) {
      id = rawId;
    } else if (rawId is String) {
      id = int.tryParse(rawId);
    }

    name = json["name"];
    description = json["description"];
    status = json["status"];

    if (json["referenceDataList"] != null) {
      references = <Reference>[];
      json["referenceDataList"].forEach((v) {
        references!.add(Reference.fromJson(v));
      });
    }

    columnsInformation = json["columnsInfo"];
    allowedRegex = json["allowedRegex"];
  }

  /// Unique identifier of the reference type.
  int? id;

  /// Name of the reference type.
  String? name;

  /// Description of the reference type.
  String? description;

  /// Status of the reference type.
  String? status;

  /// List of references associated with this reference type.
  List<Reference>? references;

  /// Column information associated with this reference type.
  String? columnsInformation;

  /// Allowed regular expression used for validating reference values.
  String? allowedRegex;

  /// Converts this [ReferenceType] instance into a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["referenceDataTypeId"] = id;
    data["name"] = name;
    data["description"] = description;
    data["status"] = status;
    if (references != null) {
      data["referenceDataList"] = references!.map((v) => v.toJson()).toList();
    }
    data["columnsInfo"] = columnsInformation;
    return data;
  }
}
