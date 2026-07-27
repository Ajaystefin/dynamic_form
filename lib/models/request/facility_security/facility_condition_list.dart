/// Represents a facility condition reference item.
class FacilityCondition {
  /// Creates a [FacilityCondition] instance.
  const FacilityCondition({
    this.referenceDataListId,
    this.name,
    this.description,
    this.reference1,
    this.reference2,
    this.reference3,
    this.reference4,
    this.reference5,
    this.isActive,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  /// Creates a [FacilityCondition] instance from a JSON map.
  factory FacilityCondition.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? v) =>
        v == null || v.isEmpty ? null : DateTime.tryParse(v);

    return FacilityCondition(
      referenceDataListId: json["referenceDataListId"] as int?,
      name: json["name"] as String?,
      description: json["description"] as String?,
      reference1: json["reference1"] as String?,
      reference2: json["reference2"] as String?,
      reference3: json["reference3"] as String?,
      reference4: json["reference4"] as String?,
      reference5: json["reference5"] as String?,
      isActive: json["isActive"] as bool?,
      createdBy: json["createdBy"] as String?,
      createdDate: parseDate(json["createdDate"] as String?),
      updatedBy: json["updatedBy"] as String?,
      updatedDate: parseDate(json["updatedDate"] as String?),
    );
  }

  /// Reference data list identifier.
  final int? referenceDataListId;

  /// Condition name.
  final String? name;

  /// Condition description.
  final String? description;

  /// Reference field 1.
  final String? reference1;

  /// Reference field 2.
  final String? reference2;

  /// Reference field 3.
  final String? reference3;

  /// Reference field 4.
  final String? reference4;

  /// Reference field 5.
  final String? reference5;

  /// Indicates whether the condition is active.
  final bool? isActive;

  /// User who created the record.
  final String? createdBy;

  /// Record creation date.
  final DateTime? createdDate;

  /// User who last updated the record.
  final String? updatedBy;

  /// Record last update date.
  final DateTime? updatedDate;

  /// Converts this [FacilityCondition] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "referenceDataListId": referenceDataListId,
        "name": name,
        "description": description,
        "reference1": reference1,
        "reference2": reference2,
        "reference3": reference3,
        "reference4": reference4,
        "reference5": reference5,
        "isActive": isActive,
        "createdBy": createdBy,
        "createdDate": createdDate?.toIso8601String(),
        "updatedBy": updatedBy,
        "updatedDate": updatedDate?.toIso8601String(),
      };
}

/// Represents filter criteria for facility conditions.
class FacilityConditionsFilter {
  /// Creates a [FacilityConditionsFilter] instance.
  const FacilityConditionsFilter({
    required this.condition,
    required this.limitGroup,
    required this.limitDesc,
    required this.limitCode,
    required this.limitType,
  });

  /// Condition name.
  final String? condition;

  /// Limit group.
  final String? limitGroup;

  /// Limit description.
  final String? limitDesc;

  /// Limit code.
  final String? limitCode;

  /// Limit type.
  final String? limitType;

  /// Converts this [FacilityConditionsFilter] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "condition": condition,
        "limitGroup": limitGroup,
        "limitDesc": limitDesc,
        "limitCode": limitCode,
        "limitType": limitType,
      };
}
