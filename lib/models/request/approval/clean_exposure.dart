/// Represents exposure details including proposed, present, guarantor,
/// and shared limit exposure values.
class Exposure {
  /// Creates an [Exposure] instance.
  Exposure({
    this.id,
    this.rimNo,
    this.appRefNo,
    this.updatedProposedExposure,
    this.updatedPresentExposure,
    this.updatedGuarantorExposure,
    this.updatedSharedLimitPresent,
    this.updatedSharedLimitProposed,
    this.calculatedProposedExposure,
    this.calculatedPresentExposure,
    this.calculatedGuarantorExposure,
    this.calculatedSharedLimitPresent,
    this.calculatedSharedLimitProposed,
    this.createdBy,
    this.updatedBy,
    this.createdDate,
    this.updatedDate,
  });

  /// Creates an [Exposure] instance from a JSON map.
  Exposure.fromJson(Map<String, dynamic> json) {
    id = json["cleanExposureId"] ?? 0;
    rimNo = json["rimNo"] ?? 0;
    appRefNo = json["appRefNo"] ?? "";
    updatedProposedExposure = json["updatedProposedExposure"] ?? 0.0;
    updatedPresentExposure = json["updatedPresentExposure"] ?? 0.0;
    updatedGuarantorExposure = json["updatedGuarantorExposure"] ?? 0.0;
    updatedSharedLimitPresent = json["updatedSharedLimitPresent"] ?? 0.0;
    calculatedProposedExposure = json["calculatedProposedExposure"] ?? 0.0;
    calculatedPresentExposure = json["calculatedPresentExposure"] ?? 0.0;
    calculatedGuarantorExposure = json["calculatedGuarantorExposure"] ?? 0.0;
    calculatedSharedLimitPresent = json["calculatedSharedLimitPresent"] ?? 0.0;
    calculatedSharedLimitProposed =
        json["calculatedSharedLimitProposed"] ?? 0.0;
    createdBy = json["createdBy"] ?? "";
    updatedBy = json["updatedBy"] ?? "";
    createdDate = (json["createdDate"] != null)
        ? DateTime.parse(json["createdDate"] ?? "")
        : null;
    updatedDate = (json["updatedDate"] != null)
        ? DateTime.parse(json["updatedDate"] ?? "")
        : null;
  }

  /// Unique identifier of the clean exposure record.
  int? id;

  /// Customer RIM number.
  int? rimNo;

  /// Application reference number.
  String? appRefNo;

  /// Updated proposed exposure amount.
  double? updatedProposedExposure;

  /// Updated present exposure amount.
  double? updatedPresentExposure;

  /// Updated guarantor exposure amount.
  double? updatedGuarantorExposure;

  /// Updated shared limit present amount.
  double? updatedSharedLimitPresent;

  /// Updated shared limit proposed amount.
  double? updatedSharedLimitProposed;

  /// Calculated proposed exposure amount.
  double? calculatedProposedExposure;

  /// Calculated present exposure amount.
  double? calculatedPresentExposure;

  /// Calculated guarantor exposure amount.
  double? calculatedGuarantorExposure;

  /// Calculated shared limit present amount.
  double? calculatedSharedLimitPresent;

  /// Calculated shared limit proposed amount.
  double? calculatedSharedLimitProposed;

  /// User who created the exposure record.
  String? createdBy;

  /// User who updated the exposure record.
  String? updatedBy;

  /// Date and time when the exposure record was created.
  DateTime? createdDate;

  /// Date and time when the exposure record was updated.
  DateTime? updatedDate;

  /// Converts this [Exposure] instance into a JSON map.
  Map<String, dynamic> toJson() => {
        "cleanExposureId": id,
        "rimNo": rimNo,
        "appRefNo": appRefNo,
        "calculatedProposedExposure": calculatedProposedExposure,
        "calculatedPresentExposure": calculatedPresentExposure,
        "calculatedGuarantorExposure": calculatedGuarantorExposure,
        "calculatedSharedLimitPresent": calculatedSharedLimitPresent,
        "calculatedSharedLimitProposed": calculatedSharedLimitProposed,
        "updatedProposedExposure": updatedProposedExposure,
        "updatedPresentExposure": updatedPresentExposure,
        "updatedGuarantorExposure": updatedGuarantorExposure,
        "updatedSharedLimitPresent": updatedSharedLimitPresent,
        "updatedSharedLimitProposed": updatedSharedLimitProposed,
        "createdBy": createdBy,
        "updatedBy": updatedBy,
        "createdDate": createdDate?.toUtc().toIso8601String(),
        "updatedDate": updatedDate?.toUtc().toIso8601String(),
      };

  /// Converts this [Exposure] instance into a JSON map for insert requests.
  Map<String, dynamic> toInsertJson() => {
        "rimNo": rimNo,
        "appRefNo": appRefNo,
        "updatedProposedExposure": updatedProposedExposure ?? 0,
        "updatedPresentExposure": updatedPresentExposure ?? 0,
        "updatedGuarantorExposure": updatedGuarantorExposure ?? 0,
        "updatedSharedLimitPresent": updatedSharedLimitPresent ?? 0,
        "updatedSharedLimitProposed": updatedSharedLimitProposed ?? 0,
        "calculatedProposedExposure": calculatedProposedExposure ?? 0,
        "calculatedPresentExposure": calculatedPresentExposure ?? 0,
        "calculatedGuarantorExposure": calculatedGuarantorExposure ?? 0,
        "calculatedSharedLimitPresent": calculatedSharedLimitPresent ?? 0,
        "calculatedSharedLimitProposed": calculatedSharedLimitProposed ?? 0,
      };
}

/// Represents clean exposure summary details with exposure list and totals.
class CleanExposure {
  /// Creates a [CleanExposure] instance.
  CleanExposure({
    this.exposures,
    this.totalProposedExposure,
    this.totalPresentExposure,
    this.totalGuarantorExposure,
    this.totalSharedLimitProposed,
    this.totalSharedLimitPresent,
    this.isGroup,
  });

  /// Creates a [CleanExposure] instance from a JSON map.
  CleanExposure.fromJson(Map<String, dynamic> json) {
    exposures = (json["exposures"] != null
        ? (json["exposures"] as List)
            .map((exp) => Exposure.fromJson(exp))
            .toList()
        : []);
    totalProposedExposure = json["totalProposedExposure"] ?? 0.0;
    totalPresentExposure = json["totalPresentExposure"] ?? 0.0;
    totalGuarantorExposure = json["totalGuarantorExposure"] ?? 0.0;
    totalSharedLimitProposed = json["totalSharedLimitProposed"] ?? 0.0;
    totalSharedLimitPresent = json["totalSharedLimitPresent"] ?? 0.0;
    isGroup = json["isGroup"] ?? false;
  }

  /// List of exposure records.
  List<Exposure>? exposures;

  /// Total proposed exposure amount.
  double? totalProposedExposure;

  /// Total present exposure amount.
  double? totalPresentExposure;

  /// Total guarantor exposure amount.
  double? totalGuarantorExposure;

  /// Total shared limit proposed amount.
  double? totalSharedLimitProposed;

  /// Total shared limit present amount.
  double? totalSharedLimitPresent;

  /// Indicates whether the exposure is for a group.
  bool? isGroup;

  /// Converts this [CleanExposure] instance into a JSON map.
  Map<String, dynamic> toJson() => {
        "exposured": exposures?.map((exp) => exp.toJson()).toList(),
        "totalProposedExposure": totalProposedExposure,
        "totalPresentExposure": totalPresentExposure,
        "totalGuarantorExposure": totalGuarantorExposure,
        "totalSharedLimitProposed": totalSharedLimitProposed,
        "totalSharedLimitPresent": totalSharedLimitPresent,
        "isGroup": isGroup,
      };
}
