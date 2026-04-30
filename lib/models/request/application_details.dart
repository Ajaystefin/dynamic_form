import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";

class ApplicationLifeCycle {
  // new added

  ApplicationLifeCycle({
    this.status,
    this.assignedTo,
    this.assignedBy,
    this.assignedToRole,
    this.assignedByRole,
    this.activityName,
    this.userAction,
    this.initiatorBpmRole,
    this.stage,
    this.priorityRole,
  });

  ApplicationLifeCycle.fromJson(Map<String, dynamic> json) {
    status = json["status"] ?? "";
    assignedTo = json["assignedTo"] ?? "";
    assignedBy = json["assignedBy"] ?? "";
    assignedToRole = json["assignedToRole"] ?? 0;
    assignedByRole = json["assignedByRole"] ?? 0;
    activityName = json["activityName"] ?? "";
    userAction = json["userAction"] ?? 0;
    initiatorBpmRole = json["initiatorBpmRole"] ?? "";
    stage = json["stage"] ?? "";
    priorityRole = json["priorityRole"] ?? 0;
  }
  String? status;
  String? assignedTo;
  String? assignedBy;
  String? activityName;
  int? assignedToRole;
  int? assignedByRole;
  int? userAction;
  String? initiatorBpmRole;
  String? stage;
  int? priorityRole;
}

class ApplicationDetails {
  ApplicationDetails({
    this.applicationRefNo,
    this.allDocRecievedDate,
    this.branch,
    this.businessSegment,
    this.creditAppDate,
    this.presentReviewDate,
    this.custRequestReceived,
    this.instanceId,
    this.conventional,
    this.islamic,
    this.lastApprovedAppDate,
    this.lastApprovedAppRefNum,
    this.nextReviewDate,
    this.purpose,
    this.reconAppReNumber,
    this.region,
    this.requestType,
    this.status,
    this.subType,
    this.tpanRecievedDate,
    this.tpanRequestDate,
    this.tpanRequired,
    this.groupApplication,
    this.createdBy,
    this.createdDate,
    this.pendingWithRole,
    this.pendingWith,
    this.deferralReasonCode,
    this.deferredNextReviewDate,
    this.approvedDate,
    this.relationshipOwner,
    this.enabledForView,
    this.highlightEnabled,
    this.groupID,
    this.customerName,
    this.groupName,
    this.rimNo,
    this.customerInformation,
    this.appWorkedByCA,
    this.audit,
    this.closed,
    this.cda,
    this.ultimateOwnership,
    this.rescheduledRestructed,
    this.exposureStrategy,
    this.mainSectorIndustry,
    this.deviationBreachJustification,
    this.interimReviewDate,
    this.markForwardDate,
    this.policyDeviations,
    this.customerType,
    this.appBusinessSegment,
    this.appTypeReferenceId,
    this.applicationLifeCycle,
    this.isAutoSave = "0",
  });

  ApplicationDetails.fromJson(Map<String, dynamic> json) {
    if (json["creditAppDate"] != null) {
      creditAppDate = json["creditAppDate"];
    }
    if (json["instanceId"] != null) {
      instanceId = json["instanceId"];
    } else if (json["instanceIdentifier"] != null) {
      instanceId = json["instanceIdentifier"];
    }
    if (json["lastApprovedAppDate"] != null) {
      lastApprovedAppDate = json["lastApprovedAppDate"];
    }

    if (json["lastApprovedAppRefNum"] != null) {
      lastApprovedAppRefNum = json["lastApprovedAppRefNum"];
    }

    if (json["status"] != null) {
      status = json["status"];
    }

    if (json["subType"] != null) {
      subType = json["subType"];
    }

    if (json["createdBy"] != null) {
      createdBy = json["createdBy"];
    }

    if (json["createdDate"] != null) {
      createdDate = json["createdDate"];
    }

    if (json["pendingWithRole"] != null) {
      pendingWithRole = json["pendingWithRole"];
    }

    if (json["pendingWith"] != null) {
      pendingWith = json["pendingWith"];
    }

    if (json["deferralReasonCode"] != null) {
      deferralReasonCode = json["deferralReasonCode"];
    }

    if (json["deferredNextReviewDate"] != null) {
      deferredNextReviewDate = json["deferredNextReviewDate"];
    }

    if (json["approvedDate"] != null) {
      approvedDate = json["approvedDate"];
    }

    if (json["relationshipOwner"] != null) {
      relationshipOwner = json["relationshipOwner"];
    }

    if (json["enabledForView"] != null) {
      enabledForView = json["enabledForView"] == 0 ? false : true;
    }

    if (json["highlightEnabled"] != null) {
      highlightEnabled = json["highlightEnabled"];
    }

    if (json["appWorkedByCA"] != null) {
      appWorkedByCA = json["appWorkedByCA"];
    }

    if (json["audit"] != null) {
      audit = json["audit"];
    }

    if (json["closed"] != null) {
      closed = json["closed"];
    }

    if (json["cusType"] != null) {
      customerType = json["cusType"];
    }

    groupApplication = json["isGroupApplication"] == 0 ? false : true;

    groupID = json["groupID"] ?? json["groupId"];
    customerName = json["customerName"];
    groupName = json["groupName"];
    rimNo = json["rimNo"];
    customerInformation = json["customerInformation"] != null
        ? ApplicationCustomerInformation.fromJson(json["customerInformation"])
        : null;

    cda = json["caDate"];
    applicationRefNo = json["applicationRefNo"];

    branch = json["branch"];
    businessSegment = json["businessSegment"];

    conventional =
        (json["conventional"] ?? json["isConventional"]) == 0 ? false : true;
    islamic = (json["islamic"] ?? json["isIslamic"]) == 0 ? false : true;

    purpose = json["purpose"];
    reconAppReNumber = json["reconAppReNumber"] ?? json["reconAppRefNum"];
    region = json["region"];
    requestType = json["requestType"];

    if (json["tpanRequired"] != null) {
      tpanRequired = json["tpanRequired"] == 0 ? false : true;
    }

    if (json["tpanRequestDate"] != null) {
      tpanRequestDate = DateTimeUtils.intToDateTime(json["tpanRequestDate"]);
    }

    if (json["tpanRecievedDate"] != null) {
      tpanRecievedDate = DateTimeUtils.intToDateTime(json["tpanRecievedDate"]);
    }

    if (json["purpose"] != null) {
      purpose = json["purpose"];
    }

    if (json["nextReviewDate"] != null) {
      nextReviewDate = DateTimeUtils.intToDateTime(json["nextReviewDate"]);
    }

    if (json["currentReviewDate"] != null) {
      presentReviewDate =
          DateTimeUtils.intToDateTime(json["currentReviewDate"]);
    }

    if (json["custRequestReceived"] != null) {
      //"custRequestReceived":
      custRequestReceived =
          DateTimeUtils.intToDateTime(json["custRequestReceived"]);
    }

    if (json["allDocRecievedDate"] != null) {
      allDocRecievedDate = json["allDocRecievedDate"];
    }
    if (json["allDocRecvdDate"] != null) {
      dateAllDocumentReceived =
          DateTimeUtils.intToDateTime(json["allDocRecvdDate"]);
    }
    if (json["ultimateOwnership"] != null) {
      ultimateOwnership = json["ultimateOwnership"];
    }
    if (json["restructuredRescheduled"] != null) {
      rescheduledRestructed = json["restructuredRescheduled"];
    }
    if (json["exposureStrategy"] != null) {
      exposureStrategy = json["exposureStrategy"];
    }
    if (json["mainSec"] != null) {
      mainSectorIndustry = json["mainSec"];
    }
    if (json["policyDeviation"] != null) {
      final raw = json["policyDeviation"];
      if (raw is String) {
        final list = raw.split(",").map((e) => e.trim()).toList();
        policyDeviations = list.map((e) => Reference(name: e)).toList();
      }
    }
    if (json["deviationJustification"] != null) {
      deviationBreachJustification = json["deviationJustification"];
    }
    if (json["interimReviewDate"] != null) {
      interimReviewDate =
          DateTimeUtils.intToDateTime(json["interimReviewDate"]);
    }
    if (json["markFwdDate"] != null) {
      markForwardDate = DateTimeUtils.intToDateTime(json["markFwdDate"]);
    }

    //reasonforcancell €

    if (json["isOverrideNextReviewDate"] != null) {
      isOverrideNextReviewDate =
          json["isOverrideNextReviewDate"] == 0 ? false : true;
    }

    if (json["shariaApproval"] != null) {
      shariaApproval = json["shariaApproval"] == 0 ? false : true;
    }

    if (json["ermApproval"] != null) {
      ermApproval = json["ermApproval"] == 0 ? false : true;
    }

    if (json["esgApproval"] != null) {
      esgApproval = json["esgApproval"] == 0 ? false : true;
    }

    if (json["pricingCommitteApproval"] != null) {
      pricingCommitteApproval =
          json["pricingCommitteApproval"] == 0 ? false : true;
    }

    if (json["interimReviewDateRequired"] != null) {
      interimReviewDateRequired =
          json["interimReviewDateRequired"] == 0 ? false : true;
    }

    if (json["appBorrower"] != null) {
      borrowers = <Customer>[];
      json["appBorrower"].forEach((v) {
        borrowers!.add(Customer.fromJson(v));
      });
    }
    if (json["appNonBorrower"] != null) {
      nonBorrowers = <Customer>[];
      json["appNonBorrower"].forEach((v) {
        nonBorrowers!.add(Customer.fromJson(v));
      });
    }

    if (json["appBusinessSegment"] != null) {
      appBusinessSegment = json["appBusinessSegment"];
    }

    if (json["appTypeReferenceId"] != null) {
      appTypeReferenceId = json["appTypeReferenceId"];
    }

    if (json["applicationLifeCycleStatus"] != null) {
      applicationLifeCycle =
          ApplicationLifeCycle.fromJson(json["applicationLifeCycleStatus"]);
    }
  }
  String? applicationRefNo;
  int? allDocRecievedDate;
  String? branch;
  String? businessSegment;
  int? creditAppDate;
  DateTime? presentReviewDate;
  DateTime? custRequestReceived;
  DateTime? markForwardDate;
  String? instanceId;
  bool? conventional;
  bool? islamic;
  String? lastApprovedAppDate;
  String? lastApprovedAppRefNum;
  DateTime? nextReviewDate;
  DateTime? dateAllDocumentReceived;
  DateTime? interimReviewDate;
  String? purpose;
  dynamic reconAppReNumber;
  String? region;
  String? requestType;
  int? status;
  String? subType;
  DateTime? tpanRecievedDate;
  DateTime? tpanRequestDate;
  bool? tpanRequired;
  bool? groupApplication;
  String? createdBy;
  String? createdDate;
  dynamic pendingWithRole;
  dynamic pendingWith;
  int? deferralReasonCode;
  dynamic deferredNextReviewDate;
  dynamic approvedDate;
  String? relationshipOwner;
  bool? enabledForView;
  bool? highlightEnabled;
  int? groupID;
  String? customerName;
  String? groupName;
  int? rimNo;
  ApplicationCustomerInformation? customerInformation;

  bool? appWorkedByCA;
  bool? audit;
  bool? closed;
  String? cda;
  String? ultimateOwnership;
  String? rescheduledRestructed;
  String? exposureStrategy;
  String? mainSectorIndustry;
  String? deviationBreachJustification;
  String? customerType;

  List<Reference>? policyDeviations;
  bool? isOverrideNextReviewDate;
  bool? shariaApproval;
  bool? ermApproval;
  bool? esgApproval;
  bool? pricingCommitteApproval;
  bool? interimReviewDateRequired;

  List<Customer>? borrowers = [];
  List<Customer>? nonBorrowers = [];
  String? appBusinessSegment;
  int? isRightFirstTime;
  int? appTypeReferenceId;
  ApplicationLifeCycle? applicationLifeCycle;

  String isAutoSave = "";

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["applicationRefNo"] = applicationRefNo;
    data["allDocRecievedDate"] = allDocRecievedDate;
    data["branch"] = branch;
    data["businessSegment"] = businessSegment;
    data["creditAppDate"] = creditAppDate;
    data["presentReviewDate"] = presentReviewDate;
    data["custRequestRecieved"] = custRequestReceived;
    data["instanceId"] = instanceId;
    data["conventional"] = conventional;
    data["islamic"] = islamic;
    data["lastApprovedAppDate"] = lastApprovedAppDate;
    data["lastApprovedAppRefNum"] = lastApprovedAppRefNum;
    data["nextReviewDate"] = nextReviewDate;
    data["purpose"] = purpose;
    data["reconAppReNumber"] = reconAppReNumber;
    data["region"] = region;
    data["requestType"] = requestType;
    data["status"] = status;
    data["subType"] = subType;
    data["tpanRecievedDate"] = tpanRecievedDate;
    data["tpanRequestDate"] = tpanRequestDate;
    data["tpanRequired"] = tpanRequired;
    data["groupApplication"] = groupApplication;
    data["createdBy"] = createdBy;
    // data['createdDate'] = createdDate;
    data["pendingWithRole"] = pendingWithRole;
    data["pendingWith"] = pendingWith;
    data["deferralReasonCode"] = deferralReasonCode;
    data["deferredNextReviewDate"] = deferredNextReviewDate;
    data["approvedDate"] = approvedDate;
    data["relationshipOwner"] = relationshipOwner;
    data["enabledForView"] = enabledForView;
    data["highlightEnabled"] = highlightEnabled;
    data["groupID"] = groupID;
    data["customerName"] = customerName;
    data["groupName"] = groupName;
    data["rimNo"] = rimNo;
    if (customerInformation != null) {
      data["customerInformation"] = customerInformation!.toJson();
    }
    data["appWorkedByCA"] = appWorkedByCA;
    data["audit"] = audit;
    data["closed"] = closed;
    data["dateAllDocumentReceived"] = dateAllDocumentReceived;
    data["ultimateOwnership"] = ultimateOwnership;
    data["rescheduledRestructed"] = rescheduledRestructed;
    data["exposureStrategy"] = exposureStrategy;
    data["mainSectorIndustry"] = mainSectorIndustry;
    data["deviationBreachJustification"] = deviationBreachJustification;
    data["interimReviewDate"] = interimReviewDate;
    data["markForwardDate"] = markForwardDate;
    data["appTypeReferenceId"] = appTypeReferenceId;
    return data;
  }

  //### Dont change any thing below tosaveApplicationJson function ### its
  //working on create request ###
  Map<String, dynamic> toSaveApplicationJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["appRefNo"] = applicationRefNo; //
    data["instanceIdentifier"] = instanceId; //
    data["caDate"] = DateTimeUtils.toApiDate(cda); //
    data["branch"] = branch; //
    data["businessSegment"] = businessSegment; //
    data["cusType"] = customerType; //
    data["lastApprovedAppRefNum"] = lastApprovedAppRefNum; //
    data["purpose"] = purpose; //
    data["reconAppReNumber"] = reconAppReNumber; //
    data["region"] = region; //
    data["reqType"] = requestType; //
    data["status"] = status; //
    data["subType"] = subType; //
    data["createdBy"] = createdBy;
    data["deferralReasonCode"] = deferralReasonCode; //
    data["deferredNextReviewDate"] = deferredNextReviewDate; //
    data["approvedDate"] = approvedDate; //
    data["groupId"] = groupID ?? Globals.request?.groupId ?? 0; //
    data["customerName"] = customerName; //
    data["groupName"] = groupName ?? Globals.request?.groupName ?? ""; //
    data["rimNo"] = rimNo; //
    data["tpanRequired"] = tpanRequired == true ? 1 : 0; //
    data["enabledForView"] = enabledForView == true ? 1 : 0; //
    data["isShariaApproval"] = shariaApproval == true ? 1 : 0; //
    data["isERMApproval"] = ermApproval == true ? 1 : 0; //
    data["isEsgApproval"] = esgApproval == true ? 1 : 0; //
    data["isPricingCommitteeApproval"] =
        pricingCommitteApproval == true ? 1 : 0; //
    data["isConventional"] = conventional == true ? 1 : 0; //
    data["isIslamic"] = islamic == true ? 1 : 0; //
    data["isGroupApplication"] = groupApplication == true ? 1 : 0; //
    data["interimReviewDateRequired"] =
        interimReviewDateRequired == true ? 1 : 0; //
    data["isOverrideNextReviewDate"] =
        isOverrideNextReviewDate == true ? 1 : 0; //
    data["ultimateOwnership"] = ultimateOwnership; //
    data["restructuredRescheduled"] = rescheduledRestructed; //
    data["exposureStrategy"] = exposureStrategy; //
    data["mainSec"] = mainSectorIndustry; //
    data["deviationJustification"] = deviationBreachJustification; //
    data["appBusinessSegment"] = appBusinessSegment; //
    data["isRightFirstTime"] = isRightFirstTime; //

    if (policyDeviations != null && policyDeviations!.isNotEmpty) {
      data["policyDeviation"] =
          policyDeviations!.map((e) => e.name).join(", "); //
    }

    if (borrowers != null) {
      data["applicationBorrowers"] =
          borrowers!.map((v) => v.toSaveBorrowerJson()).toList(); //
    }

    if (nonBorrowers != null) {
      data["applicationNonBorrowers"] =
          nonBorrowers!.map((v) => v.toSaveBorrowerJson()).toList(); //
    }

    if (customerInformation != null) {
      data["customerInformation"] = customerInformation?.toJson();
    }

    data["nextReviewDate"] = nextReviewDate?.toIso8601String(); //
    data["tpanRecvdDate"] = tpanRecievedDate?.toIso8601String(); //
    data["tpanReqDate"] = tpanRequestDate?.toIso8601String(); //
    data["allDocRecvdDate"] = dateAllDocumentReceived?.toIso8601String(); //

    data["currentReviewDate"] = presentReviewDate?.toIso8601String(); //
    data["custReqRecvdDate"] = custRequestReceived?.toIso8601String(); //
    data["interimReviewDate"] = interimReviewDate?.toIso8601String(); //
    data["markFwdDate"] = markForwardDate?.toIso8601String(); //

    data["createdDate"] = createdDate;
    data["appTypeReferenceId"] = appTypeReferenceId;

    // data['caDate'] = cda; //
    // data['caDate'] = "2025-11-11T13:35:42.123456789"; //
    // data['creditAppDate'] = creditAppDate;
    data["lastApprovedAppDate"] = lastApprovedAppDate; //
    //
    // data['pendingWithRole'] = pendingWithRole;
    // data['pendingWith'] = pendingWith;
    // data['relationshipOwner'] = relationshipOwner;
    // data['highlightEnabled'] = highlightEnabled;
    // data['appWorkedByCA'] = appWorkedByCA;
    // data['audit'] = audit;
    // data['closed'] = closed;

    return data;
  }

  //### Dont change any thing below CCSYS tosaveApplicationJson function ### its
  //working on create request ###
  Map<String, dynamic> toSaveApplicationJsonCCSYS() {
    final Map<String, dynamic> data = <String, dynamic>{};
    final String currentDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    data["appRefNo"] = applicationRefNo; //
    data["instanceIdentifier"] = instanceId; //
    data["caDate"] = currentDate; //
    data["branch"] = branch; //
    data["requestType"] = requestType; //
    data["lastApprovedAppRefNum"] = lastApprovedAppRefNum; //
    data["region"] = region; //
    data["subType"] = subType; //
    data["customerName"] = customerName; //
    data["businessSegment"] = businessSegment; //
    data["rimNo"] = rimNo; //
    data["status"] = status;
    data["enabledForView"] = enabledForView == true ? 1 : 0; //
    data["lastApprovedAppDate"] = lastApprovedAppDate; //
    data["createdBy"] = Globals.user?.id;
    data["createdDate"] = DateTime.now().toIso8601String();
    data["updatedBy"] = Globals.user?.id;
    data["updatedDate"] = DateTime.now().toIso8601String();
    return data;
  }
}

class ApplicationCustomerInformation {
  ApplicationCustomerInformation({
    this.custInfoId,
    this.applicationRefNo,
    this.customerRimNumber,
    this.customerName,
    this.groupName,
    this.groupId,
    this.sicCode,
    this.groupMappings,
    this.coBorrower,
  });

  ApplicationCustomerInformation.fromJson(Map<String, dynamic> json) {
    custInfoId = json["custInfoId"];
    applicationRefNo = json["appRefNo"] ?? json["applicationRefNo"];
    customerRimNumber = json["customerRimNumber"] ?? json["rimNo"];
    customerName = json["customerName"];
    groupName = json["groupName"];
    groupId = json["groupId"];
    sicCode = json["sicCode"];
    if (json["groupMappings"] != null) {
      groupMappings = <GroupMapping>[];
      json["groupMappings"].forEach((v) {
        groupMappings!.add(GroupMapping.fromJson(v));
      });
    }
    if (json["coBorrowerMappings"] != null) {
      coBorrower = <CoBorrower>[];
      json["coBorrowerMappings"].forEach((v) {
        coBorrower!.add(CoBorrower.fromJson(v));
      });
    }
  }
  int? custInfoId;
  String? applicationRefNo;
  int? customerRimNumber;
  String? customerName;
  String? groupName;
  int? groupId;
  String? sicCode;
  List<GroupMapping>? groupMappings;
  List<CoBorrower>? coBorrower;
  bool? isGroup;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["custInfoId"] = custInfoId;
    data["appRefNo"] = applicationRefNo;
    data["customerRimNumber"] =
        customerRimNumber ?? Globals.request?.customerRimNo ?? "";
    data["customerName"] = customerName ?? Globals.request?.customerName ?? "";
    data["groupName"] = groupName ?? Globals.request?.groupName ?? "";
    data["groupId"] = groupId ?? Globals.request?.groupId ?? 0;
    data["sicCode"] = sicCode;
    data["isGroup"] = isGroup == true ? "1" : "0";
    data["primaryName"] = "";
    data["primaryRim"] = 0;
    if (groupMappings != null) {
      data["groupMappings"] = groupMappings!.map((v) => v.toJson()).toList();
    }
    if (coBorrower != null) {
      data["coBorrower"] = coBorrower!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GroupMapping {
  GroupMapping({
    this.rimNumber,
    this.name,
    this.isPrimary,
    this.sicCode,
    this.isApplicant,
  });

  GroupMapping.fromJson(Map<String, dynamic> json) {
    rimNumber = json["customerRimNumber"] ?? json["rimNo"];
    name = json["customerName"];
    isPrimary = json["isPrimary"];
    sicCode = json["sicCode"];
    isApplicant = json["isApplicant"];
  }
  int? rimNumber;
  String? name;
  bool? isPrimary;
  String? sicCode;
  bool? isApplicant;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["rimNo"] = rimNumber;
    data["customerName"] = name;
    data["isPrimary"] = isPrimary;
    data["sicCode"] = sicCode;
    data["isApplicant"] = isApplicant;
    return data;
  }
}

class CoBorrower {
  CoBorrower({
    this.borrowerId,
    this.customerName,
    this.customerRimNumber,
    this.deleted,
    this.added,
  });

  CoBorrower.fromJson(Map<String, dynamic> json) {
    borrowerId = json["borrowerId"];
    customerName = json["customerName"];
    customerRimNumber = json["customerRimNumber"];

    deleted = json["delete"];
    added = json["added"];
  }
  int? borrowerId;
  String? customerName;
  int? customerRimNumber;
  bool? deleted;
  bool? added;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["borrowerId"] = borrowerId;
    data["customerName"] = customerName;
    data["customerRimNumber"] = customerRimNumber;

    data["isDeleted"] = deleted;
    data["isAdded"] = added;
    return data;
  }
}
