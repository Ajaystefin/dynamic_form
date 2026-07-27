/// Represents ESG certification information associated with an application,
/// including exclusions, sustainability requirements, risk ratings,
/// and approval-related details.
class EsgCertification {
  /// Creates an [EsgCertification] instance.
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

  /// Creates an [EsgCertification] instance from a JSON map.
  factory EsgCertification.fromJson(Map<String, dynamic> json) {
    return EsgCertification(
      esgCertificationsId: json["esgCertificationsId"] as int?,
      appRefNo: json["appRefNo"] as String?,
      applicationType: json["applicationType"] as String?,
      role: json["role"] as String?,
      excludedActivity: json["excludedActivity"]?.toString(),
      isRequestInfoEsgExcluded: json["isRequestInfoEsgExcluded"] as bool?,
      listOfExcludedActivities:
          (json["listOfExcludedActivities"] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
      sffRequired: json["sffRequired"] is int
          ? json["sffRequired"] == 1
          : json["sffRequired"] as bool?,
      sffCategories: (json["sffCategories"] as List<dynamic>?)
          ?.map((e) => SffCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      sllRequired: json["sllRequired"] as bool?,
      esRiskRating: (json["esRiskRating"] as List<dynamic>?)
          ?.map((e) => FacilityRiskRating.fromJson(e as Map<String, dynamic>))
          .toList(),
      isRequestInfoEsgRestricted: json["isRequestInfoEsgRestricted"] as bool?,
      adverseMedia: json["adverseMedia"] is int
          ? json["adverseMedia"] == 1
          : json["adverseMedia"] as bool?,
      adverseMediaSummary: json["adverseMediaSummary"] as String?,
      requestInfoEsgMediaScan: json["requestInfoEsgMediaScan"] as bool?,
      additionalChecklist: json["additionalChecklist"] as String?,
      section1Guidance: json["section1Guidance"] as int?,
      section2Guidance: json["section2Guidance"] as int?,
      section3Guidance: json["section3Guidance"] as int?,
      section4AGuidance: json["section4AGuidance"] as int?,
      section4BGuidance: json["section4BGuidance"] as int?,
      createdBy: json["createdBy"] as String?,
      createdDate: json["createdDate"] == null
          ? null
          : DateTime.parse(json["createdDate"] as String),
      updatedBy: json["updatedBy"] as String?,
      updatedDate: json["updatedDate"] == null
          ? null
          : DateTime.parse(json["updatedDate"] as String),
    );
  }

  /// Unique identifier of the ESG certification record.
  final int? esgCertificationsId;

  /// Application reference number.
  final String? appRefNo;

  /// Type of application.
  final String? applicationType;

  /// User role associated with the certification.
  final String? role;

  /// Excluded activity details.
  final String? excludedActivity;

  /// Indicates whether the request contains ESG excluded activities.
  final bool? isRequestInfoEsgExcluded;

  /// List of excluded activities.
  final List<String>? listOfExcludedActivities;

  /// Indicates whether Sustainable Finance Framework (SFF) is required.
  final bool? sffRequired;

  /// List of selected SFF categories.
  final List<SffCategory>? sffCategories;

  /// Indicates whether Sustainability Linked Loan (SLL) is required.
  final bool? sllRequired;

  /// ESG risk ratings for facilities.
  final List<FacilityRiskRating>? esRiskRating;

  /// Indicates whether the request contains ESG restricted activities.
  final bool? isRequestInfoEsgRestricted;

  /// Indicates whether adverse media was identified.
  final bool? adverseMedia;

  /// Summary of adverse media findings.
  final String? adverseMediaSummary;

  /// Indicates whether ESG media screening was performed.
  final bool? requestInfoEsgMediaScan;

  /// Additional ESG checklist information.
  final String? additionalChecklist;

  /// Guidance status for section 1.
  final int? section1Guidance;

  /// Guidance status for section 2.
  final int? section2Guidance;

  /// Guidance status for section 3.
  final int? section3Guidance;

  /// Guidance status for section 4A.
  final int? section4AGuidance;

  /// Guidance status for section 4B.
  final int? section4BGuidance;

  /// User who created the record.
  final String? createdBy;

  /// Date when the record was created.
  final DateTime? createdDate;

  /// User who last updated the record.
  final String? updatedBy;

  /// Date when the record was last updated.
  final DateTime? updatedDate;

  /// Converts this [EsgCertification] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "appRefNo": appRefNo,
      "applicationType": applicationType,
      "role": role,
      "excludedActivity": excludedActivity,
      "isRequestInfoEsgExcluded": isRequestInfoEsgExcluded,
      "listOfExcludedActivities": listOfExcludedActivities,
      "sffRequired": sffRequired,
      "sffCategories": sffCategories?.map((e) => e.toJson()).toList(),
      "sllRequired": sllRequired,
      "esRiskRating": esRiskRating?.map((e) => e.toJson()).toList(),
      "isRequestInfoEsgRestricted": isRequestInfoEsgRestricted,
      "adverseMedia": adverseMedia,
      "adverseMediaSummary": adverseMediaSummary,
      "requestInfoEsgMediaScan": requestInfoEsgMediaScan,
      "additionalChecklist": additionalChecklist,
      "createdBy": createdBy,
      "createdDate": createdDate?.toIso8601String(),
      "updatedBy": updatedBy,
      "updatedDate": updatedDate?.toIso8601String(),
    };
  }

  /// Creates a copy of this [EsgCertification] with updated values.
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

/// Represents a Sustainable Finance Framework (SFF) category.
class SffCategory {
  /// Creates an [SffCategory] instance.
  SffCategory({
    this.sffCategoryId,
    this.isSelected,
    this.sffCategory,
    this.briefDesc,
  });

  /// Creates an [SffCategory] instance from a JSON map.
  factory SffCategory.fromJson(Map<String, dynamic> json) {
    return SffCategory(
      sffCategoryId: json["sffCategoryId"] as int?,
      isSelected: json["selected"] as bool?,
      sffCategory: json["sffCategory"] as String? ?? "",
      briefDesc: json["briefDescription"] as String? ?? "",
    );
  }

  /// Unique identifier of the SFF category.
  final int? sffCategoryId;

  /// Indicates whether the category is selected.
  bool? isSelected;

  /// Name of the SFF category.
  String? sffCategory;

  /// Brief description of the category.
  String? briefDesc;

  /// Converts this [SffCategory] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "sffCategoryId": sffCategoryId,
      "selected": isSelected,
      "sffCategory": sffCategory,
      "briefDescription": briefDesc,
    };
  }
}

/// Represents ESG risk rating information for a facility.
class FacilityRiskRating {
  /// Creates a [FacilityRiskRating] instance.
  FacilityRiskRating({
    this.esgFaciliyId,
    this.borrowerRim,
    this.facilityName,
    this.sicCode,
    this.pctTotalLimit,
    this.esRating,
    this.eSRiskRatingFacilityDto,
  });

  /// Creates a [FacilityRiskRating] instance from a JSON map.
  factory FacilityRiskRating.fromJson(Map<String, dynamic> json) {
    // Safe helpers
    String? asString(v) => v?.toString();

    double? asDouble(v) {
      if (v == null) {
        return null;
      }
      if (v is num) {
        return v.toDouble();
      }
      if (v is String) {
        final parsed = double.tryParse(v);
        return parsed;
      }
      return null;
    }

    return FacilityRiskRating(
      borrowerRim: asString(json["borrowerRim"]),
      // If eSRiskRatingFacilityDto is a nested object, change this to a proper
      // parse:
      // eSRiskRatingFacilityDto:
      // ESRiskRatingFacilityDto.fromJson(json['eSRiskRatingFacilityDto']),
      eSRiskRatingFacilityDto: json["eSRiskRatingFacilityDto"] != null
          ? (json["eSRiskRatingFacilityDto"] as List<dynamic>?)
              ?.map(
                (e) => EskRiskRatingFacilityDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList()
          : [],
      facilityName: asString(json["facilityName"]),
      sicCode: asString(json["sicCode"]),
      pctTotalLimit: asDouble(json["pctTotalLimit"]),
      esRating: asString(json["esRating"]),
    );
  }

  /// Unique identifier of the ESG facility record.
  final int? esgFaciliyId;

  /// Borrower RIM number.
  final String? borrowerRim;

  /// Name of the facility.
  final String? facilityName;

  /// SIC code associated with the facility.
  final String? sicCode;

  /// Percentage of total limit.
  final double? pctTotalLimit;

  /// ESG rating assigned to the facility.
  final String? esRating;

  /// Detailed ESG risk rating information for the facility.
  final List<EskRiskRatingFacilityDto>? eSRiskRatingFacilityDto;

  /// Converts this [FacilityRiskRating] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "borrowerRim": borrowerRim,
      "facilityName": facilityName,
      "sicCode": sicCode,
      "pctTotalLimit": pctTotalLimit,
      "esRating": esRating,
    };
  }
}

/// Represents detailed ESG risk rating information for a facility.
class EskRiskRatingFacilityDto {
  /// Creates an [EskRiskRatingFacilityDto] instance.
  EskRiskRatingFacilityDto({
    this.borrowerRim,
    this.facilityName,
    this.sicCode,
    this.pctTotalLimit,
    this.esRating,
  });

  /// Creates an [EskRiskRatingFacilityDto] instance from a JSON map.
  factory EskRiskRatingFacilityDto.fromJson(Map<String, dynamic> json) {
    // Safe helpers
    String? asString(v) => v?.toString();

    double? asDouble(v) {
      if (v == null) {
        return null;
      }
      if (v is num) {
        return v.toDouble();
      }
      if (v is String) {
        final parsed = double.tryParse(v);
        return parsed;
      }
      return null;
    }

    return EskRiskRatingFacilityDto(
      facilityName: asString(json["facilityName"]),
      sicCode: asString(json["sicCode"]),
      pctTotalLimit: asDouble(json["pctTotalLimit"]),
      esRating: asString(json["esRating"]),
    );
  }

  /// Borrower RIM number.
  final String? borrowerRim;

  /// Name of the facility.
  final String? facilityName;

  /// SIC code associated with the facility.
  final String? sicCode;

  /// Percentage of total limit.
  final double? pctTotalLimit;

  /// ESG rating assigned to the facility.
  final String? esRating;

  /// Converts this [EskRiskRatingFacilityDto] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "facilityName": facilityName,
      "sicCode": sicCode,
      "pctTotalLimit": pctTotalLimit,
      "esRating": esRating,
    };
  }
}
