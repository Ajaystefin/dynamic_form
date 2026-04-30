class Exposure {
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
  int? id;
  int? rimNo;
  String? appRefNo;
  double? updatedProposedExposure;
  double? updatedPresentExposure;
  double? updatedGuarantorExposure;
  double? updatedSharedLimitPresent;
  double? updatedSharedLimitProposed;
  double? calculatedProposedExposure;
  double? calculatedPresentExposure;
  double? calculatedGuarantorExposure;
  double? calculatedSharedLimitPresent;
  double? calculatedSharedLimitProposed;
  String? createdBy;
  String? updatedBy;
  DateTime? createdDate;
  DateTime? updatedDate;

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

class CleanExposure {
  CleanExposure({
    this.exposures,
    this.totalProposedExposure,
    this.totalPresentExposure,
    this.totalGuarantorExposure,
    this.totalSharedLimitProposed,
    this.totalSharedLimitPresent,
    this.isGroup,
  });

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
  List<Exposure>? exposures;
  double? totalProposedExposure;
  double? totalPresentExposure;
  double? totalGuarantorExposure;
  double? totalSharedLimitProposed;
  double? totalSharedLimitPresent;
  bool? isGroup;

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
