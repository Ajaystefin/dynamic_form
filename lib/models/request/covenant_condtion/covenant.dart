import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";

class Covenant {
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
      facilityIdList: (json["facilityIdList"]),
    );
  }
  int? covenantConditionId;
  int? covenantType;
  int? conditionType;
  String? covenantConditionNo;
  String? description;
  int? category;
  int? frequency;
  int? monitorDate;
  String? nextMonitorDate;
  bool? isGeneric;
  bool? isNew;
  bool? isCovenant;
  bool? isDeleted;
  bool? deleted;
  bool? isStandard;
  bool? isInternalFinancial;

  String? status;
  int? action;
  int? covConMasterId;
  int? rimNo;
  int? groupId;
  int? limitCode;
  int? threshold;
  int? timeForSubmition;

  String? refNo;
  String? appRefNum;
  String? customerName;
  String? entityName;
  String? creditLensId;
  int? periodTerm;
  int? basisOfPreparation;
  int? auditStatus;
  int? covenantSubType;
  int? thresholdType;
  String? financialYearEndDate;
  String? mode;
  List<Facility>? facilityDetailList;
  List<dynamic>? facilityIdList;
  List<Customer>? borrowers;

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

  Map<String, dynamic> toSaveNewJson() {
    final data = <String, dynamic>{};

    data["covenantConditionMasterId"] = covConMasterId ?? 0;
    data["appRefNum"] = Globals.request?.applicationRefNo;
    data["rimNo"] = rimNo;
    data["isCovenant"] = isCovenant ?? true;
    data["covenantType"] = covenantType;
    data["isGeneric"] = isGeneric ?? true;
    data["isNew"] = true;
    data["description"] = description?.trim().isNotEmpty == true
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

    data["borrowerIdList"] = (borrowers?.isNotEmpty == true)
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

class FacilityNew {
  FacilityNew({
    this.rimNo,
    this.limitNo,
    this.facilityTypeName,
    this.projectName,
    this.proposedLimit,
  });

  factory FacilityNew.fromJson(Map<String, dynamic> json) {
    return FacilityNew(
      rimNo: json["rimNo"],
      limitNo: json["limitNo"],
      facilityTypeName: json["facilityTypeName"],
      projectName: json["projectName"],
      proposedLimit: json["proposedLimit"],
    );
  }
  int? rimNo;
  String? limitNo;
  String? facilityTypeName;
  String? projectName;
  num? proposedLimit;

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
