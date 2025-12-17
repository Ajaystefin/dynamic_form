class FacilityCondition {
  final int? referenceDataListId;
  final String? name;
  final String? description;
  final String? reference1;
  final String? reference2;
  final String? reference3;
  final String? reference4;
  final String? reference5;
  final bool? isActive;
  final String? createdBy;
  final DateTime? createdDate;
  final String? updatedBy;
  final DateTime? updatedDate;

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

  factory FacilityCondition.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? v) =>
        v == null || v.isEmpty ? null : DateTime.tryParse(v);

    return FacilityCondition(
      referenceDataListId: json['referenceDataListId'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      reference1: json['reference1'] as String?,
      reference2: json['reference2'] as String?,
      reference3: json['reference3'] as String?,
      reference4: json['reference4'] as String?,
      reference5: json['reference5'] as String?,
      isActive: json['isActive'] as bool?,
      createdBy: json['createdBy'] as String?,
      createdDate: parseDate(json['createdDate'] as String?),
      updatedBy: json['updatedBy'] as String?,
      updatedDate: parseDate(json['updatedDate'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'referenceDataListId': referenceDataListId,
        'name': name,
        'description': description,
        'reference1': reference1,
        'reference2': reference2,
        'reference3': reference3,
        'reference4': reference4,
        'reference5': reference5,
        'isActive': isActive,
        'createdBy': createdBy,
        'createdDate': createdDate?.toIso8601String(),
        'updatedBy': updatedBy,
        'updatedDate': updatedDate?.toIso8601String(),
      };
}

class FacilityConditionsFilter {
  final String condition;
  final String limitGroup;
  final String limitDesc;
  final String limitCode;
  final String limitType;

  const FacilityConditionsFilter({
    required this.condition,
    required this.limitGroup,
    required this.limitDesc,
    required this.limitCode,
    required this.limitType,
  });

  Map<String, dynamic> toJson() => {
        'condition': condition,
        'limitGroup': limitGroup,
        'limitDesc': limitDesc,
        'limitCode': limitCode,
        'limitType': limitType,
      };
}
