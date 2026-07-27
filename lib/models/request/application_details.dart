import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// Represents the lifecycle status and workflow assignment
/// details of an application.
class ApplicationLifeCycle {
  /// Creates an [ApplicationLifeCycle] instance.
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

  /// Creates an [ApplicationLifeCycle] instance from a JSON map.
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

  /// Current status of the application.
  String? status;

  /// User currently assigned to the application.
  String? assignedTo;

  /// User who assigned the application.
  String? assignedBy;

  /// Name of the current workflow activity.
  String? activityName;

  /// Role identifier of the assigned user.
  int? assignedToRole;

  /// Role identifier of the assigning user.
  int? assignedByRole;

  /// Action performed by the user.
  int? userAction;

  /// BPM role of the application initiator.
  String? initiatorBpmRole;

  /// Current stage of the application workflow.
  String? stage;

  /// Priority role identifier for processing the application.
  int? priorityRole;
}

/// Represents application details including customer information,
/// workflow status, review dates, approvals, and lifecycle data.
class ApplicationDetails {
  /// Creates an [ApplicationDetails] instance.
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
    this.createdByRole,
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
    this.dateAllDocumentReceived,
    this.isOverrideNextReviewDate,
    this.shariaApproval,
    this.ermApproval,
    this.esgApproval,
    this.pricingCommitteApproval,
    this.interimReviewDateRequired,
    this.isRightFirstTime,
    this.isAutoSave = "0",
    this.applicationSubType,
  });

  /// Creates an [ApplicationDetails] instance from a JSON map.
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
      enabledForView = json["enabledForView"] != 0;
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
    groupApplication = json["isGroupApplication"] != 0;

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

    conventional = (json["conventional"] ?? json["isConventional"]) != 0;

    islamic = (json["islamic"] ?? json["isIslamic"]) != 0;

    purpose = json["purpose"];
    reconAppReNumber = json["reconAppReNumber"] ?? json["reconAppRefNum"];
    region = json["region"];
    requestType = json["requestType"];

    if (json["tpanRequired"] != null) {
      tpanRequired = json["tpanRequired"] != 0;
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
      final dynamic raw = json["policyDeviation"];

      if (raw is String && raw.trim().isNotEmpty) {
        final List<String> list = raw
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty && e.toLowerCase() != "null")
            .toList();

        policyDeviations = list.map((e) {
          final int? id = int.tryParse(e);

          return id != null ? Reference(id: id) : Reference(name: e);
        }).toList();
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
      isOverrideNextReviewDate = json["isOverrideNextReviewDate"] != 0;
    }

    if (json["shariaApproval"] != null) {
      shariaApproval = json["shariaApproval"] != 0;
    }

    if (json["ermApproval"] != null) {
      ermApproval = json["ermApproval"] != 0;
    }

    if (json["esgApproval"] != null) {
      esgApproval = json["esgApproval"] != 0;
    }

    if (json["pricingCommitteApproval"] != null) {
      pricingCommitteApproval = json["pricingCommitteApproval"] != 0;
    }

    if (json["interimReviewDateRequired"] != null) {
      interimReviewDateRequired = json["interimReviewDateRequired"] != 0;
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

    if (json["applicationSubType"] != null) {
      applicationSubType = json["applicationSubType"];
    }

    if (json["applicationLifeCycleStatus"] != null) {
      applicationLifeCycle =
          ApplicationLifeCycle.fromJson(json["applicationLifeCycleStatus"]);
      createdByRole = json["applicationLifeCycleStatus"]["createdByRole"];
    }
  }

  /// Application reference number.
  String? applicationRefNo;

  /// Date on which all documents were received.
  int? allDocRecievedDate;

  /// Branch associated with the application.
  String? branch;

  /// Business segment of the application.
  String? businessSegment;

  /// Credit application date.
  int? creditAppDate;

  /// Current review date.
  DateTime? presentReviewDate;

  /// Date on which the customer request was received.
  DateTime? custRequestReceived;

  /// Date on which the request was marked forward.
  DateTime? markForwardDate;

  /// Workflow instance identifier.
  String? instanceId;

  /// Indicates whether the application is conventional.
  bool? conventional;

  /// Indicates whether the application is Islamic.
  bool? islamic;

  /// Date of the last approved application.
  String? lastApprovedAppDate;

  /// Reference number of the last approved application.
  String? lastApprovedAppRefNum;

  /// Next review date.
  DateTime? nextReviewDate;

  /// Date on which all documents were received.
  DateTime? dateAllDocumentReceived;

  /// Interim review date.
  DateTime? interimReviewDate;

  /// Purpose of the application.
  String? purpose;

  /// Reconsideration application reference number.
  dynamic reconAppReNumber;

  /// Region associated with the application.
  String? region;

  /// Type of request.
  String? requestType;

  /// Application status.
  int? status;

  /// Application subtype.
  String? subType;

  /// TPAN received date.
  DateTime? tpanRecievedDate;

  /// TPAN request date.
  DateTime? tpanRequestDate;

  /// Indicates whether TPAN is required.
  bool? tpanRequired;

  /// Indicates whether the application is a group application.
  bool? groupApplication;

  /// User who created the application.
  String? createdBy;

  /// Role of the user who created the application.
  String? createdByRole;

  /// Date when the application was created.
  String? createdDate;

  /// Role currently pending action on the application.
  dynamic pendingWithRole;

  /// User currently pending action on the application.
  dynamic pendingWith;

  /// Deferral reason code.
  int? deferralReasonCode;

  /// Deferred next review date.
  dynamic deferredNextReviewDate;

  /// Application approval date.
  dynamic approvedDate;

  /// Relationship owner of the application.
  String? relationshipOwner;

  /// Indicates whether the application is enabled for viewing.
  bool? enabledForView;

  /// Indicates whether highlighting is enabled.
  bool? highlightEnabled;

  /// Group identifier.
  int? groupID;

  /// Customer name.
  String? customerName;

  /// Group name.
  String? groupName;

  /// Customer RIM number.
  int? rimNo;

  /// Customer information associated with the application.
  ApplicationCustomerInformation? customerInformation;

  /// Indicates whether the application was worked on by a credit analyst.
  bool? appWorkedByCA;

  /// Indicates whether the application is under audit.
  bool? audit;

  /// Indicates whether the application is closed.
  bool? closed;

  /// Credit approval date.
  String? cda;

  /// Ultimate ownership details.
  String? ultimateOwnership;

  /// Restructured or rescheduled details.
  String? rescheduledRestructed;

  /// Exposure strategy information.
  String? exposureStrategy;

  /// Main sector or industry.
  String? mainSectorIndustry;

  /// Deviation or breach justification.
  String? deviationBreachJustification;

  /// Customer type.
  String? customerType;

  /// Policy deviations associated with the application.
  List<Reference>? policyDeviations;

  /// Indicates whether the next review date is overridden.
  bool? isOverrideNextReviewDate;

  /// Indicates whether Sharia approval is required.
  bool? shariaApproval;

  /// Indicates whether ERM approval is required.
  bool? ermApproval;

  /// Indicates whether ESG approval is required.
  bool? esgApproval;

  /// Indicates whether Pricing Committee approval is required.
  bool? pricingCommitteApproval;

  /// Indicates whether an interim review date is required.
  bool? interimReviewDateRequired;

  /// List of borrower customers.
  List<Customer>? borrowers = [];

  /// List of non-borrower customers.
  List<Customer>? nonBorrowers = [];

  /// Application business segment.
  String? appBusinessSegment;

  /// Indicates whether access rights are initialized for the first time.
  int? isRightFirstTime;

  /// Application type reference identifier.
  int? appTypeReferenceId;

  /// Application subtype code.
  String? applicationSubType;

  /// Application lifecycle information.
  ApplicationLifeCycle? applicationLifeCycle;

  /// Auto-save indicator.
  String isAutoSave = "";

  /// Converts this [ApplicationDetails] instance to a JSON map.
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
    data["applicationSubType"] = applicationSubType;
    return data;
  }

  /// Converts this [ApplicationDetails] instance to an application save payload.
  ///
  /// Dont change any thing below tosaveApplicationJson function its working on create request
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
    data["tpanRequired"] = tpanRequired ?? false ? 1 : 0; //
    data["enabledForView"] = enabledForView ?? false ? 1 : 0; //
    data["isShariaApproval"] = shariaApproval ?? false ? 1 : 0; //
    data["isERMApproval"] = ermApproval ?? false ? 1 : 0; //
    data["isEsgApproval"] = esgApproval ?? false ? 1 : 0; //
    data["isPricingCommitteeApproval"] =
        pricingCommitteApproval ?? false ? 1 : 0; //
    data["isConventional"] = conventional ?? false ? 1 : 0; //
    data["isIslamic"] = islamic ?? false ? 1 : 0; //
    data["isGroupApplication"] = groupApplication ?? false ? 1 : 0; //
    data["interimReviewDateRequired"] =
        interimReviewDateRequired ?? false ? 1 : 0; //
    data["isOverrideNextReviewDate"] =
        isOverrideNextReviewDate ?? false ? 1 : 0; //
    data["ultimateOwnership"] = ultimateOwnership; //
    data["restructuredRescheduled"] = rescheduledRestructed; //
    data["exposureStrategy"] = exposureStrategy; //
    data["mainSec"] = mainSectorIndustry; //
    data["deviationJustification"] = deviationBreachJustification; //
    data["appBusinessSegment"] = appBusinessSegment; //
    data["isRightFirstTime"] = isRightFirstTime; //
    data["applicationSubType"] =
        Globals.request?.applicationSubType == ServerConstants.manualEntry
            ? "ME"
            : "";

    if (policyDeviations != null && policyDeviations!.isNotEmpty) {
      data["policyDeviation"] = policyDeviations! //
          .where((e) => e.id != null || (e.name?.trim().isNotEmpty ?? false))
          .map((e) => e.id?.toString() ?? (e.name ?? "").trim())
          .join(", ");
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

  /// Converts this [ApplicationDetails] instance to a CCSYS application save payload.
  ///
  /// Dont change any thing below CCSYS tosaveApplicationJson function its working on create request
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
    data["enabledForView"] = enabledForView ?? false ? 1 : 0; //
    data["lastApprovedAppDate"] = lastApprovedAppDate; //
    data["createdBy"] = Globals.user?.id;
    data["createdDate"] = DateTime.now().toIso8601String();
    data["updatedBy"] = Globals.user?.id;
    data["updatedDate"] = DateTime.now().toIso8601String();
    return data;
  }
}

/// Represents customer information associated with an application,
/// including group mappings and co-borrower details.
class ApplicationCustomerInformation {
  /// Creates an [ApplicationCustomerInformation] instance.
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

  /// Creates an [ApplicationCustomerInformation] instance from a JSON map.
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
    } else if (json["groupMapping"] != null) {
      groupMappings = <GroupMapping>[];
      json["groupMapping"].forEach((v) {
        groupMappings!.add(GroupMapping.fromJson(v));
      });
    }
    if (json["coBorrowerMappings"] != null) {
      coBorrower = <CoBorrower>[];
      json["coBorrowerMappings"].forEach((v) {
        coBorrower!.add(CoBorrower.fromJson(v));
      });
    }
    if (json["message"] != null) {
      message = json["message"];
    }
    if (json["outstandingAmount"] != null) {
      outstandingAmount = json["outstandingAmount"];
    }
  }

  /// Unique identifier of the customer information record.
  int? custInfoId;

  /// Application reference number.
  String? applicationRefNo;

  /// Customer RIM number.
  int? customerRimNumber;

  /// Name of the customer.
  String? customerName;

  /// Name of the customer group.
  String? groupName;

  /// Identifier of the customer group.
  int? groupId;

  /// SIC code associated with the customer.
  String? sicCode;

  /// List of customer group mappings.
  List<GroupMapping>? groupMappings;

  /// List of co-borrowers associated with the customer.
  List<CoBorrower>? coBorrower;

  /// Indicates whether the application is a group application.
  bool? isGroup;

  /// Validation or informational message.
  String? message;

  /// Outstanding amount associated with the customer.
  double? outstandingAmount;

  /// Converts this [ApplicationCustomerInformation] instance to a JSON map.
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
    data["isGroup"] = isGroup ?? false ? "1" : "0";
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

  /// Converts this [ApplicationCustomerInformation] instance to a
  /// prior-validation cancellation JSON payload.
  Map<String, dynamic> toCancelPriorValidationJson() {
    return {
      "customerBasicInformation": {
        "customerRimNumber":
            (customerRimNumber ?? Globals.request?.customerRimNo ?? "")
                .toString(),
        "groupId": groupId.toString(),
        "groupMappings":
            groupMappings?.map((e) => e.toCancelJson()).toList() ?? [],
      },
      "groupApplication": isGroup ?? false,
    };
  }
}

/// Represents a customer-to-group mapping record.
class GroupMapping {
  /// Creates a [GroupMapping] instance.
  GroupMapping({
    this.rimNumber,
    this.name,
    this.isPrimary,
    this.sicCode,
    this.isApplicant,
  });

  /// Creates a [GroupMapping] instance from a JSON map.
  GroupMapping.fromJson(Map<String, dynamic> json) {
    rimNumber = json["customerRimNumber"] ?? json["rimNo"];
    name = json["customerName"];
    isPrimary = json["isPrimary"];
    sicCode = json["sicCode"];
    isApplicant = json["isApplicant"];
  }

  /// Customer RIM number.
  int? rimNumber;

  /// Customer name.
  String? name;

  /// Indicates whether the customer is the primary member of the group.
  bool? isPrimary;

  /// SIC code associated with the customer.
  String? sicCode;

  /// Indicates whether the customer is the applicant.
  bool? isApplicant;

  /// Converts this [GroupMapping] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["rimNo"] = rimNumber;
    data["customerName"] = name;
    data["isPrimary"] = isPrimary;
    data["sicCode"] = sicCode;
    data["isApplicant"] = isApplicant;
    return data;
  }

  /// Converts this [GroupMapping] instance to a cancellation JSON payload.
  Map<String, dynamic> toCancelJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["customerRimNumber"] = rimNumber.toString();
    data["customerName"] = name;
    data["isPrimary"] = isPrimary;
    data["sicCode"] = sicCode ??= "";
    data["isApplicant"] = isApplicant;
    return data;
  }
}

/// Represents a co-borrower associated with an application.
class CoBorrower {
  /// Creates a [CoBorrower] instance.
  CoBorrower({
    this.borrowerId,
    this.customerName,
    this.customerRimNumber,
    this.deleted,
    this.added,
  });

  /// Creates a [CoBorrower] instance from a JSON map.
  CoBorrower.fromJson(Map<String, dynamic> json) {
    borrowerId = json["borrowerId"];
    customerName = json["customerName"];
    customerRimNumber = json["customerRimNumber"];
    deleted = json["delete"];
    added = json["added"];
  }

  /// Unique identifier of the borrower.
  int? borrowerId;

  /// Name of the co-borrower.
  String? customerName;

  /// RIM number of the co-borrower.
  int? customerRimNumber;

  /// Indicates whether the co-borrower is marked for deletion.
  bool? deleted;

  /// Indicates whether the co-borrower was newly added.
  bool? added;

  /// Converts this [CoBorrower] instance to a JSON map.
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
