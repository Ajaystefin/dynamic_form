class EsgCertification {
  final int? esgCertificationsId;
  final String? appRefNo;
  final String? applicationType;
  final String? role;
  final String? excludedActivity;
  final bool? isRequestInfoEsgExcluded;
  final List<String>? listOfExcludedActivities;
  final bool? sffRequired;
  final List<SffCategory>? sffCategories;
  final bool? sllRequired;
  final List<FacilityRiskRating>? esRiskRating;
  final bool? isRequestInfoEsgRestricted;
  final bool? adverseMedia;
  final String? adverseMediaSummary;
  final bool? requestInfoEsgMediaScan;
  final String? additionalChecklist;
  final int? section1Guidance;
  final int? section2Guidance;
  final int? section3Guidance;
  final int? section4AGuidance;
  final int? section4BGuidance;
  final String? createdBy;
  final DateTime? createdDate;
  final String? updatedBy;
  final DateTime? updatedDate;

  EsgCertification({
    this.esgCertificationsId,
    this.appRefNo,
    this.applicationType,
    this.role,
    this.excludedActivity,
    this.isRequestInfoEsgExcluded,
    this.listOfExcludedActivities,
    this.sffRequired,
    this.sffCategories,
    this.sllRequired,
    this.esRiskRating,
    this.isRequestInfoEsgRestricted,
    this.adverseMedia,
    this.adverseMediaSummary,
    this.requestInfoEsgMediaScan,
    this.additionalChecklist,
    this.section1Guidance,
    this.section2Guidance,
    this.section3Guidance,
    this.section4AGuidance,
    this.section4BGuidance,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  factory EsgCertification.fromJson(Map<String, dynamic> json) {
    return EsgCertification(
      esgCertificationsId: json['esgCertificationsId'] as int?,
      appRefNo: json['appRefNo'] as String?,
      applicationType: json['applicationType'] as String?,
      role: json['role'] as String?,
      excludedActivity: json['excludedActivity']?.toString(),
      isRequestInfoEsgExcluded: json['isRequestInfoEsgExcluded'] as bool?,
      listOfExcludedActivities:
          (json['listOfExcludedActivities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
      sffRequired: json['sffRequired'] is int
          ? json['sffRequired'] == 1
          : json['sffRequired'] as bool?,
      sffCategories: (json['sffCategories'] as List<dynamic>?)
          ?.map((e) => SffCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      sllRequired: json['sllRequired'] as bool?,
      esRiskRating: (json['esRiskRating'] as List<dynamic>?)
          ?.map((e) => FacilityRiskRating.fromJson(e as Map<String, dynamic>))
          .toList(),
      isRequestInfoEsgRestricted: json['isRequestInfoEsgRestricted'] as bool?,
      adverseMedia: json['adverseMedia'] is int
          ? json['adverseMedia'] == 1
          : json['adverseMedia'] as bool?,
      adverseMediaSummary: json['adverseMediaSummary'] as String?,
      requestInfoEsgMediaScan: json['requestInfoEsgMediaScan'] as bool?,
      additionalChecklist: json['additionalChecklist'] as String?,
      section1Guidance: json['section1Guidance'] as int?,
      section2Guidance: json['section2Guidance'] as int?,
      section3Guidance: json['section3Guidance'] as int?,
      section4AGuidance: json['section4AGuidance'] as int?,
      section4BGuidance: json['section4BGuidance'] as int?,
      createdBy: json['createdBy'] as String?,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
      updatedBy: json['updatedBy'] as String?,
      updatedDate: json['updatedDate'] == null
          ? null
          : DateTime.parse(json['updatedDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appRefNo': appRefNo,
      'applicationType': applicationType,
      'role': role,
      'excludedActivity': excludedActivity,
      'isRequestInfoEsgExcluded': isRequestInfoEsgExcluded,
      'listOfExcludedActivities': listOfExcludedActivities,
      'sffRequired': sffRequired,
      'sffCategories': sffCategories?.map((e) => e.toJson()).toList(),
      'sllRequired': sllRequired,
      'esRiskRating': esRiskRating?.map((e) => e.toJson()).toList(),
      'isRequestInfoEsgRestricted': isRequestInfoEsgRestricted,
      'adverseMedia': adverseMedia,
      'adverseMediaSummary': adverseMediaSummary,
      'requestInfoEsgMediaScan': requestInfoEsgMediaScan,
      'additionalChecklist': additionalChecklist,
      'createdBy': createdBy,
      'createdDate': createdDate?.toIso8601String(),
      'updatedBy': updatedBy,
      'updatedDate': updatedDate?.toIso8601String(),
    };
  }

  EsgCertification copyWith({
    String? role,
    String? appRefNo,
    String? excludedActivity,
    bool? isRequestInfoEsgExcluded,
    List<String>? listOfExcludedActivities,
    bool? sffRequired,
    List<SffCategory>? sffCategories,
    bool? sllRequired,
    List<FacilityRiskRating>? esRiskRating,
    bool? isRequestInfoEsgRestricted,
    bool? adverseMedia,
    String? adverseMediaSummary,
    bool? requestInfoEsgMediaScan,
    String? additionalChecklist,
    int? section1Guidance,
    int? section2Guidance,
    int? section3Guidance,
    int? section4AGuidance,
    int? section4BGuidance,
    String? updatedBy,
    DateTime? updatedDate,
    String? applicationType,
    
  }) {
    return EsgCertification(
      appRefNo: appRefNo,
      applicationType: applicationType,
      role: role ?? this.role,
      excludedActivity: excludedActivity ?? this.excludedActivity,
      isRequestInfoEsgExcluded:
          isRequestInfoEsgExcluded ?? this.isRequestInfoEsgExcluded,
      listOfExcludedActivities:
          listOfExcludedActivities ?? this.listOfExcludedActivities,
      sffRequired: sffRequired ?? this.sffRequired,
      sffCategories: sffCategories ?? this.sffCategories,
      sllRequired: sllRequired ?? this.sllRequired,
      esRiskRating: esRiskRating ?? this.esRiskRating,
      isRequestInfoEsgRestricted:
          isRequestInfoEsgRestricted ?? this.isRequestInfoEsgRestricted,
      adverseMedia: adverseMedia ?? this.adverseMedia,
      adverseMediaSummary: adverseMediaSummary ?? this.adverseMediaSummary,
      requestInfoEsgMediaScan:
          requestInfoEsgMediaScan ?? this.requestInfoEsgMediaScan,
      additionalChecklist: additionalChecklist ?? this.additionalChecklist,
      section1Guidance: section1Guidance ?? this.section1Guidance,
      section2Guidance: section2Guidance ?? this.section2Guidance,
      section3Guidance: section3Guidance ?? this.section3Guidance,
      section4AGuidance: section4AGuidance ?? this.section4AGuidance,
      section4BGuidance: section4BGuidance ?? this.section4BGuidance,
      createdBy: createdBy,
      createdDate: createdDate,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }
}

class SffCategory {
  final int? sffCategoryId;
  bool? isSelected;
  String? sffCategory;
  String? briefDesc;

  SffCategory({
    this.sffCategoryId,
    this.isSelected,
    this.sffCategory,
    this.briefDesc,
  });

  factory SffCategory.fromJson(Map<String, dynamic> json) {
    return SffCategory(
      sffCategoryId: json['sffCategoryId'] as int?,
      isSelected: json['selected'] as bool?,
      sffCategory: json['sffCategory'] as String? ?? '',
      briefDesc: json['briefDescription'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sffCategoryId': sffCategoryId,
      'selected': isSelected,
      'sffCategory':sffCategory,
      'briefDescription': briefDesc,
    };
  }
}

class FacilityRiskRating {
  final int? esgFaciliyId;
  final String? borrowerRim;
  final String? facilityName;
  final String? sicCode;
  final double? pctTotalLimit;
  final String? esRating;

  FacilityRiskRating({
    this.esgFaciliyId,
    this.borrowerRim,
    this.facilityName,
    this.sicCode,
    this.pctTotalLimit,
    this.esRating,
  });

  factory FacilityRiskRating.fromJson(Map<String, dynamic> json) {
    return FacilityRiskRating(
      borrowerRim: json['borrowerRim']?.toString(),
      facilityName: json['facilityName'] as String?,
      sicCode: json['sicCode'] as String?,
      pctTotalLimit: json['pctTotalLimit'] == null
          ? null
          : (json['pctTotalLimit'] as num).toDouble(),
      esRating: json['esRating'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'borrowerRim': borrowerRim,
      'facilityName': facilityName,
      'sicCode': sicCode,
      'pctTotalLimit': pctTotalLimit,
      'esRating': esRating,
    };
  }
}
