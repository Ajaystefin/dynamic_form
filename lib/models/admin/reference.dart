enum Status {
  active,
  inactive,
}

class Reference {
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
  int? id;
  String? name;
  String? description;
  String? status;
  String? reference1;
  String? reference2;
  String? reference3;
  String? reference4;
  String? reference5;
  String? createdBy;
  int? typeId;
  DateTime? createdDate;
  String? updatedBy;
  DateTime? updatedDate;
  bool? isActive = false;

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

class RequestTypeGroup {
  RequestTypeGroup({
    required this.requestTypeName,
    required this.requestType,
    required this.requestTypes,
  });
  final String requestTypeName;
  final String requestType;
  final List<Reference> requestTypes;
}
