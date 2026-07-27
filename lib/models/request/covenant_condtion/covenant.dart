import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";

/// Represents covenant details including borrower details, facility details,
/// monitoring information, financial covenant values, and status.
class Covenant {
  /// Creates a [Covenant] instance.
  Covenant({
    this.covenantConditionId,
    this.covenantType,
    this.conditionType,
    this.covenantConditionNo,
    this.description,
    this.category,
    this.frequency,
    this.monitorDate,
    this.nextMonitorDate,
    this.isGeneric,
    this.isNew,
    this.isCovenant,
    this.isDeleted,
    this.deleted,
    this.isStandard,
    this.isInternalFinancial,
    this.status,
    this.action,
    this.covConMasterId,
    this.rimNo,
    this.groupId,
    this.limitCode,
    this.threshold,
    this.timeForSubmition,
    this.refNo,
    this.appRefNum,
    this.customerName,
    this.entityName,
    this.creditLensId,
    this.periodTerm,
    this.basisOfPreparation,
    this.auditStatus,
    this.covenantSubType,
    this.thresholdType,
    this.financialYearEndDate,
    this.mode,
    this.borrowers = const [],
    this.facilityDetailList = const [],
    this.facilityIdList = const [],
  });

  /// Creates a [Covenant] instance from a JSON map.
  factory Covenant.fromJson(Map<String, dynamic> json) {
    return Covenant(
      covenantConditionId: json["covenantConditionId"],
      covenantConditionNo: json["covenantConditionNo"],
      covenantType: json["covenantType"],
      conditionType: json["conditionType"],
      description: json["description"],
      category: json["category"],
      frequency: json["frequency"],
      monitorDate: json["monitorDate"],
      nextMonitorDate: json["nextMonitorDate"],
      isGeneric: json["isGeneric"],
      isNew: json["isNew"],
      isCovenant: json["isCovenant"],
      isDeleted: json["isDeleted"],
      deleted: json["deleted"],
      isStandard: json["isStandard"],
      isInternalFinancial: json["isInternalFinancial"],
      status: json["status"],
      action: json["action"],
      covConMasterId:
          json["covenantConditionMasterId"] ?? json["covConMasterId"],
      rimNo: json["rimNo"],
      groupId: json["groupId"],
      limitCode: json["limitCode"],
      threshold: json["threshold"],
      timeForSubmition: json["timeForSubmition"],
      refNo: json["refNo"],
      appRefNum: json["appRefNum"],
      customerName: json["customerName"],
      entityName: json["entityName"],
      creditLensId: json["creditLensId"],
      periodTerm: json["periodTerm"],
      basisOfPreparation: json["basisOfPreparation"],
      auditStatus: json["auditStatus"],
      covenantSubType: json["covenantSubType"],
      thresholdType: json["thresholdType"],
      financialYearEndDate: json["financialYearEndDate"],
      mode: json["mode"],
      borrowers: (json["borrowerIdList"] as List<dynamic>?)
              ?.map((e) => Customer.fromJson(e))
              .toList() ??
          [],
      facilityDetailList: json["facilityDetailList"] != null
          ? (json["facilityDetailList"] as List<dynamic>)
              .map((e) => Facility.fromJson(e))
              .toList()
          : [],
      facilityIdList: json["facilityIdList"],
    );
  }

  /// Covenant condition identifier.
  int? covenantConditionId;

  /// Covenant type identifier.
  int? covenantType;

  /// Condition type identifier.
  int? conditionType;

  /// Covenant condition number.
  String? covenantConditionNo;

  /// Covenant description.
  String? description;

  /// Covenant category identifier.
  int? category;

  /// Covenant frequency identifier.
  int? frequency;

  /// Monitor date value.
  int? monitorDate;

  /// Next monitor date value.
  String? nextMonitorDate;

  /// Indicates whether the covenant is generic.
  bool? isGeneric;

  /// Indicates whether the covenant is new.
  bool? isNew;

  /// Indicates whether this item is a covenant.
  bool? isCovenant;

  /// Indicates whether the covenant is deleted.
  bool? isDeleted;

  /// Deleted flag.
  bool? deleted;

  /// Indicates whether the covenant is standard.
  bool? isStandard;

  /// Indicates whether the covenant is internal financial.
  bool? isInternalFinancial;

  /// Covenant status value.
  String? status;

  /// Action identifier.
  int? action;

  /// Covenant condition master identifier.
  int? covConMasterId;

  /// Customer RIM number.
  int? rimNo;

  /// Group identifier.
  int? groupId;

  /// Limit code.
  int? limitCode;

  /// Threshold value.
  num? threshold;

  /// Time for submission value.
  int? timeForSubmition;

  /// Reference number.
  String? refNo;

  /// Application reference number.
  String? appRefNum;

  /// Customer name.
  String? customerName;

  /// Entity name.
  String? entityName;

  /// Credit lens identifier.
  String? creditLensId;

  /// Period term identifier.
  int? periodTerm;

  /// Basis of preparation identifier.
  int? basisOfPreparation;

  /// Audit status identifier.
  int? auditStatus;

  /// Covenant subtype identifier.
  int? covenantSubType;

  /// Threshold type identifier.
  int? thresholdType;

  /// Financial year end date value.
  String? financialYearEndDate;

  /// Mode value.
  String? mode;

  /// List of facility details associated with the covenant.
  List<Facility>? facilityDetailList;

  /// List of facility identifiers associated with the covenant.
  List<dynamic>? facilityIdList;

  /// List of borrowers associated with the covenant.
  List<Customer>? borrowers;

  /// Converts this [Covenant] instance into a delete request JSON map.
  Map<String, dynamic> toDeleteJson(String? appRefNo) {
    final data = <String, dynamic>{};
    data["covenantConditionId"] = covenantConditionId;
    data["covenantConditionMasterId"] = covConMasterId ?? 0;
    data["appRefNum"] = appRefNum ?? Globals.request?.applicationRefNo;
    data["rimNo"] = rimNo;
    data["covenantConditionNo"] = covenantConditionNo;
    data["isCovenant"] = isCovenant ?? false;
    data["covenantType"] = covenantType;
    data["isGeneric"] = isGeneric ?? false;
    data["isNew"] = false;
    data["description"] = description;
    data["frequency"] = frequency;
    data["facilityIdList"] = facilityIdList;
    data["facilityDetailList"] = facilityDetailList;
    data["status"] = status;
    data["action"] = action;
    data["isStandard"] = isStandard ?? true;
    data["groupId"] = groupId;
    data["periodTerm"] = periodTerm;
    data["basisOfPreparation"] = basisOfPreparation;
    data["auditStatus"] = auditStatus;
    data["timeForSubmition"] = timeForSubmition;
    data["covenantSubType"] = covenantSubType;
    data["isInternalFinancial"] = isInternalFinancial ?? false;
    data["threshold"] = threshold;
    data["thresholdType"] = thresholdType;
    data["financialYearEndDate"] = financialYearEndDate;
    data["nextMonitorDate"] = nextMonitorDate;
    data["conditionType"] = conditionType;
    data["isDeleted"] = isDeleted ?? false;
    data["customerName"] = customerName ?? "";
    data["entityName"] = entityName ?? "";
    data["creditLensId"] = creditLensId ?? "";
    data["borrowerIdList"] = borrowers
            ?.map(
              (e) => {
                "rimNo": e.customerRimNo,
                "custName": e.customerName,
              },
            )
            .toList() ??
        [];

    return data;
  }

  /// Converts this [Covenant] instance into a save request JSON map.
  Map<String, dynamic> toSaveJson() {
    final data = <String, dynamic>{};
    data["covenantConditionId"] = covenantConditionId;
    data["covenantConditionMasterId"] = covConMasterId ?? 0;
    data["appRefNum"] = appRefNum ?? Globals.request?.applicationRefNo;
    data["rimNo"] = rimNo;
    data["covenantConditionNo"] = covenantConditionNo;
    data["isCovenant"] = isCovenant ?? false;
    data["covenantType"] = covenantType;
    data["isGeneric"] = isGeneric ?? false;
    data["isNew"] = isNew;
    data["description"] = description;
    data["frequency"] = frequency;
    data["facilityIdList"] = facilityDetailList
            ?.map((f) => f.limitNumber)
            .whereType<String>()
            .toList() ??
        <String>[];
    data["facilityDetailList"] =
        facilityDetailList?.map((e) => e.toJson()).toList() ?? [];

    data["status"] = status;
    data["action"] = action;
    data["isStandard"] = isStandard ?? true;
    data["groupId"] = groupId;
    data["periodTerm"] = periodTerm;
    data["basisOfPreparation"] = basisOfPreparation;
    data["auditStatus"] = auditStatus;
    data["timeForSubmition"] = timeForSubmition;
    data["covenantSubType"] = covenantSubType;
    data["isInternalFinancial"] = isInternalFinancial ?? false;
    data["threshold"] = threshold;
    data["thresholdType"] = thresholdType;
    data["financialYearEndDate"] = financialYearEndDate;
    data["nextMonitorDate"] = nextMonitorDate;
    data["conditionType"] = conditionType;
    data["isDeleted"] = isDeleted ?? false;
    data["customerName"] = customerName ?? "";
    data["entityName"] = entityName ?? "";
    data["creditLensId"] = creditLensId ?? "";
    data["borrowerIdList"] = borrowers
            ?.map(
              (e) => {
                "rimNo": e.customerRimNo,
                "custName": e.customerName,
              },
            )
            .toList() ??
        [];

    return data;
  }

  /// Converts this [Covenant] instance into a save request JSON map for a new covenant.
  Map<String, dynamic> toSaveNewJson() {
    final data = <String, dynamic>{};

    data["covenantConditionMasterId"] = covConMasterId ?? 0;
    data["appRefNum"] = Globals.request?.applicationRefNo;
    data["rimNo"] = rimNo;
    data["isCovenant"] = isCovenant ?? true;
    data["covenantType"] = covenantType;
    data["isGeneric"] = isGeneric ?? true;
    data["isNew"] = true;
    data["description"] = description?.trim().isNotEmpty ?? false
        ? description
        : category?.toString() ?? "No Description";
    data["frequency"] = frequency;
    data["facilityIdList"] = facilityDetailList
            ?.map((f) => f.limitNumber)
            .whereType<String>()
            .toList() ??
        <String>[];
    data["facilityDetailList"] =
        facilityDetailList?.map((e) => e.toJson()).toList() ?? [];

    data["status"] = status ??= "New";
    data["action"] = action;
    data["isStandard"] = isStandard ?? true;
    data["groupId"] = groupId;
    data["periodTerm"] = periodTerm;
    data["basisOfPreparation"] = basisOfPreparation;
    data["auditStatus"] = auditStatus;
    data["timeForSubmition"] = timeForSubmition;
    data["covenantSubType"] = covenantSubType;
    data["isInternalFinancial"] = isInternalFinancial ?? false;
    data["threshold"] = threshold;
    data["thresholdType"] = thresholdType;
    data["financialYearEndDate"] = financialYearEndDate;
    data["nextMonitorDate"] = nextMonitorDate;
    data["conditionType"] = conditionType;
    data["isDeleted"] = isDeleted ?? false;
    data["customerName"] = customerName ?? "";
    data["entityName"] = entityName ?? "";
    data["creditLensId"] = creditLensId ?? "";

    data["borrowerIdList"] = (borrowers?.isNotEmpty ?? false)
        ? borrowers!
            .map(
              (e) => {
                "rimNo": e.customerRimNo,
                "custName": e.customerName,
              },
            )
            .toList()
        : [];

    return data;
  }

  /// Links financial covenant details from the provided [source] covenant.
  void linkFinancialCovenant(Covenant source) {
    covenantSubType = source.covenantSubType;
    description = source.description;
    frequency = source.frequency;
    facilityIdList = source.facilityIdList;
    status = source.status;
    action = source.action;
    isStandard = source.isStandard;
    groupId = source.groupId;
    periodTerm = source.periodTerm;
    basisOfPreparation = source.basisOfPreparation;
    auditStatus = source.auditStatus;
    timeForSubmition = source.timeForSubmition;
    isInternalFinancial = source.isInternalFinancial;
    threshold = source.threshold;
    thresholdType = source.thresholdType;
    financialYearEndDate = source.financialYearEndDate;
    nextMonitorDate = source.nextMonitorDate;
    conditionType = source.conditionType;
    customerName = source.customerName;
    entityName = source.entityName;
    creditLensId = source.creditLensId;
    borrowers = source.borrowers;
  }
}

/// Represents new facility details used with covenant processing.
class FacilityNew {
  /// Creates a [FacilityNew] instance.
  FacilityNew({
    this.rimNo,
    this.limitNo,
    this.facilityTypeName,
    this.projectName,
    this.proposedLimit,
  });

  /// Creates a [FacilityNew] instance from a JSON map.
  factory FacilityNew.fromJson(Map<String, dynamic> json) {
    return FacilityNew(
      rimNo: json["rimNo"],
      limitNo: json["limitNo"],
      facilityTypeName: json["facilityTypeName"],
      projectName: json["projectName"],
      proposedLimit: json["proposedLimit"],
    );
  }

  /// Customer RIM number.
  int? rimNo;

  /// Limit number.
  String? limitNo;

  /// Facility type name.
  String? facilityTypeName;

  /// Project name.
  String? projectName;

  /// Proposed limit amount.
  num? proposedLimit;

  /// Converts this [FacilityNew] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "rimNo": rimNo,
      "limitNo": limitNo,
      "facilityTypeName": facilityTypeName,
      "projectName": projectName,
      "proposedLimit": proposedLimit,
    };
  }
}
