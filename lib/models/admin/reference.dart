/// Represents the available status values for a reference.
enum Status {
  /// Active status.
  active,

  /// Inactive status.
  inactive,
}

/// Represents a reference item with metadata, reference values,
/// audit details, and active status.
class Reference {
  /// Creates a [Reference] instance.
  Reference({
    this.id,
    this.name,
    this.description,
    this.status,
    this.reference1,
    this.reference2,
    this.reference3,
    this.reference4,
    this.reference5,
    this.createdBy,
    this.typeId,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.isActive,
  });

  /// Creates a [Reference] instance from a JSON map.
  ///
  /// Supports `referenceDataListId` as either an integer or a string value.
  /// Also supports `createdDate` and `updatedDate` as either milliseconds
  /// since epoch or a date string.
  Reference.fromJson(Map<String, dynamic> json) {
    // Updated: guard against referenceDataListId as String or int
    final rawId = json["referenceDataListId"];
    if (rawId is int) {
      id = rawId;
    } else if (rawId is String) {
      id = int.tryParse(rawId);
    }

    name = json["name"];
    description = json["description"];
    status =
        (json["isActive"] ?? false) ? Status.active.name : Status.inactive.name;
    reference1 = json["reference1"];
    reference2 = json["reference2"];
    reference3 = json["reference3"];
    reference4 = json["reference4"];
    reference5 = json["reference5"];
    createdBy = json["createdBy"];

    // Updated: check createdDate runtime type before parsing
    final rawCreated = json["createdDate"];
    if (rawCreated is int) {
      createdDate = DateTime.fromMillisecondsSinceEpoch(rawCreated);
    } else if (rawCreated is String) {
      createdDate = DateTime.tryParse(rawCreated);
    }

    updatedBy = json["updatedBy"];

    // Updated: check updatedDate runtime type before parsing
    final rawUpdated = json["updatedDate"];
    if (rawUpdated is int) {
      updatedDate = DateTime.fromMillisecondsSinceEpoch(rawUpdated);
    } else if (rawUpdated is String) {
      updatedDate = DateTime.tryParse(rawUpdated);
    }

    if (json["isActive"] != null) {
      isActive = json["isActive"] ?? false;
    }
  }

  /// Unique identifier of the reference item.
  int? id;

  /// Name of the reference item.
  String? name;

  /// Description of the reference item.
  String? description;

  /// Status value of the reference item.
  String? status;

  /// First reference value.
  String? reference1;

  /// Second reference value.
  String? reference2;

  /// Third reference value.
  String? reference3;

  /// Fourth reference value.
  String? reference4;

  /// Fifth reference value.
  String? reference5;

  /// User who created the reference item.
  String? createdBy;

  /// Reference data type identifier.
  int? typeId;

  /// Date and time when the reference item was created.
  DateTime? createdDate;

  /// User who last updated the reference item.
  String? updatedBy;

  /// Date and time when the reference item was last updated.
  DateTime? updatedDate;

  /// Indicates whether the reference item is active.
  bool? isActive = false;

  /// Converts this [Reference] instance into a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["referenceDataListId"] = id;
    data["name"] = name;
    data["description"] = description;
    data["isActive"] = status?.toLowerCase() == Status.active.name;
    data["reference1"] = reference1;
    data["reference2"] = reference2;
    data["reference3"] = reference3;
    data["reference4"] = reference4;
    data["reference5"] = reference5;
    data["referenceDataTypeId"] = typeId;
    data["createdBy"] = "WCASTSP01";
    data["createdDate"] = DateTime.now().millisecondsSinceEpoch;
    data["updatedBy"] = "wcastsp01";
    data["updatedDate"] = DateTime.now().millisecondsSinceEpoch;
    data["srcMigratedId"] = 0;

    return data;
  }
}

/// Represents a grouped list of request type references.
class RequestTypeGroup {
  /// Creates a [RequestTypeGroup] instance.
  RequestTypeGroup({
    required this.requestTypeName,
    required this.requestType,
    required this.requestTypes,
  });

  /// Display name of the request type group.
  final String requestTypeName;

  /// Request type value of the group.
  final String requestType;

  /// List of request type references in this group.
  final List<Reference> requestTypes;
}
