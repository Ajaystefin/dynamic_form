import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";

class CovenantCondition {
  CovenantCondition({
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
    this.includeInTerms,
    this.targetDate,
  });

  factory CovenantCondition.fromJson(Map<String, dynamic> json) {
    return CovenantCondition(
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
      borrowers: json["borrowerIdList"] == null
          ? null
          : (json["borrowerIdList"] as List)
              .map((e) => Customer.fromJson(e))
              .toList(),
      facilityDetailList: json["facilityDetailList"] != null
          ? (json["facilityDetailList"] as List<dynamic>)
              .map((e) => Facility.fromJson(e))
              .toList()
          : [],
      facilityIdList: json["facilityIdList"],
      includeInTerms: json["isIncludedInTermaSheet"],
      targetDate: json["targetDate"],
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

  int? status;
  int? action;
  int? covConMasterId;
  int? rimNo;
  int? groupId;
  int? limitCode;
  int? threshold;
  int? timeForSubmition;
  bool? includeInTerms;
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
  String? targetDate;

  List<Customer>? borrowers;
  List<Facility>? facilityDetailList;
  List<dynamic>? facilityIdList;

  Map<String, dynamic> toJson() {
    return {
      "covenantConditionId": covenantConditionId,
      "covenantConditionNo": covenantConditionNo,
      "covenantType": covenantType,
      "conditionType": conditionType,
      "description": description,
      "category": category,
      "frequency": frequency,
      "monitorDate": monitorDate,
      "nextMonitorDate": nextMonitorDate,
      "isGeneric": isGeneric,
      "isNew": isNew,
      "isCovenant": isCovenant,
      "isDeleted": isDeleted,
      "deleted": deleted,
      "isStandard": isStandard,
      "isInternalFinancial": isInternalFinancial,
      "status": status,
      "action": action,
      "covConMasterId": covConMasterId,
      "rimNo": rimNo,
      "groupId": groupId,
      "limitCode": limitCode,
      "threshold": threshold,
      "timeForSubmition": timeForSubmition,
      "refNo": refNo,
      "appRefNum": appRefNum,
      "customerName": customerName,
      "entityName": entityName,
      "creditLensId": creditLensId,
      "periodTerm": periodTerm,
      "basisOfPreparation": basisOfPreparation,
      "auditStatus": auditStatus,
      "covenantSubType": covenantSubType,
      "thresholdType": thresholdType,
      "financialYearEndDate": financialYearEndDate,
      "mode": mode,
      "borrowerIdList": borrowers?.map((e) => e.toJson()).toList(),
      "facilityDetailList": facilityDetailList?.map((e) => e.toJson()).toList(),
      "facilityIdList": facilityIdList,
      "isIncludedInTermaSheet": includeInTerms,
      "targetDate": targetDate,
    };
  }

  Map<String, dynamic> toDeleteJson(String? appRefNo) {
    return toJson()
      ..remove("covenantConditionNo")
      ..remove("deleted")
      ..remove("monitorDate")
      ..remove("covenantConditionMasterId")
      ..remove("appRefNum")
      ..["covConMasterId"] = covConMasterId
      ..["appRefNo"] = appRefNo
      ..["nextMonitorDate"] = nextMonitorDate
      ..["isDeleted"] = (isDeleted == true ? 1 : 0)
      ..["isCovenant"] = (isCovenant == true ? 1 : 0)
      ..["mode"] = mode
      ..["isGeneric"] = (isGeneric == true ? 1 : 0)
      ..["isNew"] = (isNew == true ? 1 : 0);
  }

  Map<String, dynamic> toSaveJson() {
    final data = <String, dynamic>{};
    data["covenantConditionId"] = covenantConditionId;
    data["covenantConditionMasterId"] = covConMasterId ?? 0;
    data["appRefNum"] = appRefNum;
    data["rimNo"] = rimNo;
    data["covenantConditionNo"] = covenantConditionNo;
    data["isCovenant"] = isCovenant ?? false;
    data["covenantType"] = covenantType;
    data["isGeneric"] = isGeneric ?? false;
    data["description"] = description;
    data["frequency"] = frequency;
    data["facilityIdList"] = facilityDetailList
            ?.map((f) => f.limitNumber)
            .whereType<String>()
            .toList() ??
        <String>[];
    data["facilityDetailList"] =
        facilityDetailList?.map((e) => e.toJson()).toList() ?? [];

    data["isNew"] = isNew;
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
    data["targetDate"] = targetDate;
    data["isIncludedInTermaSheet"] = includeInTerms;
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
}
