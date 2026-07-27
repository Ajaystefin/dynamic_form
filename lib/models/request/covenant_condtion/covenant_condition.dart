import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";

/// Represents covenant condition details including covenant metadata,
/// borrower details, facility details, monitoring information, and status.
class CovenantCondition {
  /// Creates a [CovenantCondition] instance.
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

  /// Creates a [CovenantCondition] instance from a JSON map.
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

  /// Covenant condition identifier.
  int? covenantConditionId;

  /// Covenant type identifier.
  int? covenantType;

  /// Condition type identifier.
  int? conditionType;

  /// Covenant condition number.
  String? covenantConditionNo;

  /// Covenant condition description.
  String? description;

  /// Covenant category identifier.
  int? category;

  /// Covenant frequency identifier.
  int? frequency;

  /// Monitor date value.
  int? monitorDate;

  /// Next monitor date value.
  String? nextMonitorDate;

  /// Indicates whether the covenant condition is generic.
  bool? isGeneric;

  /// Indicates whether the covenant condition is new.
  bool? isNew;

  /// Indicates whether the item is a covenant.
  bool? isCovenant;

  /// Indicates whether the covenant condition is deleted.
  bool? isDeleted;

  /// Deleted flag.
  bool? deleted;

  /// Indicates whether the covenant condition is standard.
  bool? isStandard;

  /// Indicates whether the covenant condition is internal financial.
  bool? isInternalFinancial;

  /// Status identifier.
  int? status;

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
  int? threshold;

  /// Time for submission value.
  int? timeForSubmition;

  /// Indicates whether this covenant condition is included in terms.
  bool? includeInTerms;

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

  /// Target date value.
  String? targetDate;

  /// List of borrowers associated with the covenant condition.
  List<Customer>? borrowers;

  /// List of facility details associated with the covenant condition.
  List<Facility>? facilityDetailList;

  /// List of facility identifiers associated with the covenant condition.
  List<dynamic>? facilityIdList;

  /// Converts this [CovenantCondition] instance into a JSON map.
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

  /// Converts this [CovenantCondition] instance into a delete request JSON map.
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
      ..["isDeleted"] = (isDeleted ?? false ? 1 : 0)
      ..["isCovenant"] = (isCovenant ?? false ? 1 : 0)
      ..["mode"] = mode
      ..["isGeneric"] = (isGeneric ?? false ? 1 : 0)
      ..["isNew"] = (isNew ?? false ? 1 : 0);
  }

  /// Converts this [CovenantCondition] instance into a save request JSON map.
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
