import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// Represents a request submitted for credit assessment,
/// review, approval, or maintenance processes.
class Request {
  /// Creates a [Request] instance.
  Request({
    this.businessSegment,
    this.isCreateRequest,
    this.businessSegm,
    this.requestType,
    this.businessSegmentEnum,
    this.applicationType,
    this.applicationSubType,
    this.customerType,
    this.dateOfCreation,
    this.customerRimNo,
    this.caDate,
    this.customerName,
    this.groupName,
    this.groupId,
    this.applicationRefNo,
    this.requestRefNo,
    this.applicantRim,
    this.applicantName,
    this.requestedBy,
    this.createdDate,
    this.purpose,
    this.status,
    this.tpanRecievedDate,
    this.creditAppDate,
    this.terminatedReason,
    this.assignToRole,
    this.customers,
    this.cda,
    this.region,
    this.branch,
    this.presentReviewDate,
    this.nextReviewDate,
    this.customerRequestReceived,
    this.dateAllDocumentReceived,
    this.islamic = false,
    this.lastApprovedAppRefNum,
    this.conventional = false,
    this.tpanRequired = false,
    this.tpanRequestDate,
    this.interimReviewDate,
    this.markForwardDate,
    this.mainSectorIndustry,
    this.ultimateOwnership,
    this.deviationBreachJustification,
    this.ermApproval = false,
    this.esg = false,
    this.shariaApproval = false,
    this.pricingCommittee = false,
    this.interimReviewDateRequired = false,
    this.exposureStrategy,
    this.productType,
    this.reconsiderations,
    this.policyDeviations,
    this.requestSubType,
    this.requestStatus,
    this.coBorrower,
    this.groupOwner,
    this.purposeOfApplicationSummary,
    this.purposeOfApplicationDetailed,
    this.restructuredRescheduled,
    this.borrowers,
    this.pendingSince,
    this.pendingWith,
    this.receivedFrom,
    this.nonBorrowers,
    this.ccsysLifeCycleStatus,
    this.enabledForView,
    this.ccsysCanEditReadOnly,
    this.appBusinessSegment,
    this.appTypeReferenceId,
    this.reqRefType,
  });

  /// Creates a [Request] instance from a JSON map.
  Request.fromJson(
    Map<String, dynamic> json, {
    List<Reference>? bussinessSegments,
    List<ApplicationLifeCycle>? ccsysLifeCycleStatusList,
  }) {
    ccsysLifeCycleStatus = ccsysLifeCycleStatusList;
    businessSegment = (bussinessSegments ?? []).firstWhere(
      (Reference value) =>
          value.name == (json["BusinessSegment"] ?? json["businessSegment"]),
      orElse: () =>
          Reference(name: json["BusinessSegment"] ?? json["businessSegment"]),
    );
    status = json["status"] is int?
        ? "${json['status'] ?? ""}"
        : json["status"] as String? ?? json["requestStatus"];
    businessSegm = json["businessSegment"];
    requestType = json["RequestType"] != null
        ? Reference.fromJson(json["RequestType"])
        : json["requestType"] != null
            ? Reference(reference1: json["requestType"])
            : null;
    applicationType = json["ApplicationType"] != null
        ? Reference.fromJson(json["ApplicationType"])
        : json["subType"] != null
            ? Reference(reference1: json["subType"])
            : null;
    applicationSubType =
        json["applicationSubType"] ?? json["applicationSubType"];
    customerType = json["CustomerType"] != null
        ? Reference.fromJson(json["CustomerType"])
        : json["cusType"] != null
            ? Reference(name: json["cusType"])
            : null;
    applicationSubType = json["applicationSubType"];
    customerRimNo = json["CustomerRimNo"] ?? json["rimNo"];
    applicationRefNo = json["applicationRefNo"];
    customerName = json["CustomerName"] ?? json["customerName"];
    groupName = json["GroupName"] ?? json["groupName"];
    groupId = json["GroupId"] ?? json["groupID"] ?? json["groupId"];
    groupOwner = json["GroupOwner"] ?? json["groupOwner"];
    terminatedReason = json["terminatedReason"];
    purpose = json["purpose"];
    requestedBy = json["requestedBy"];
    tpanRecievedDate = DateTimeUtils.intToDateTime(json["tpanRecievedDate"]);
    creditAppDate = json["creditAppDate"];
    createdDate = DateTimeUtils.intToDateTime(json["createdDate"]);
    cda = json["CDA"];
    region = json["Region"];
    branch = json["Branch"];
    presentReviewDate = DateTimeUtils.intToDateTime(json["PresentReviewDate"]);
    nextReviewDate = DateTimeUtils.intToDateTime(json["NextReviewDate"]);
    customerRequestReceived =
        DateTimeUtils.intToDateTime(json["CustomerRequestReceived"]);
    dateAllDocumentReceived =
        DateTimeUtils.intToDateTime(json["DateAllDocumentReceived"]);
    tpanRequestDate = DateTimeUtils.intToDateTime(json["tpanRequestDate"]);
    tpanRecievedDate = DateTimeUtils.intToDateTime(json["tpanRecievedDate"]);
    interimReviewDate = DateTimeUtils.intToDateTime(json["interimReviewDate"]);
    markForwardDate = DateTimeUtils.intToDateTime(json["markForwardDate"]);
    purposeOfApplicationSummary = json["PurposeOfApplicationSummary"];
    purposeOfApplicationDetailed = json["PurposeOfApplicationDetailed"];

    // businessSegment = (requestStatuses ?? []).firstWhere(
    //   (Reference value) => value.id == json["status"],
    //   orElse: () => Reference(id: json["status"]),
    // );
    islamic = json["islamic"] == 1;
    conventional = json["conventional"] == 1;
    tpanRequired = json["tpanRequired"] == 1;
    mainSectorIndustry = json["mainSectorIndustry"];
    ultimateOwnership = json["ultimateOwnership"];
    deviationBreachJustification = json["deviationBreachJustification"];
    ermApproval = json["ermApproval"] == 1;
    // esg = json['esg'] ?? false;
    shariaApproval = json["shariaApproval"] == 1;
    pricingCommittee = json["pricingCommittee"] == 1;
    restructuredRescheduled = json["restructuredRescheduled"];
    // x` = json['interimReviewDateRequired'] ?? false;
    exposureStrategy = json["exposureStrategy"];
    productType = json["productType"];
    reconsiderations = json["reconsiderations"];
    appBusinessSegment = json["appBusinessSegment"];
    lastApprovedAppRefNum = json["lastApprovedAppRefNum"];
    if (json["policyDeviations"] != null) {
      policyDeviations = <Reference>[];
      json["policyDeviations"].forEach((v) {
        policyDeviations!.add(Reference.fromJson(v));
      });
    }
    if (json["coBorrowerMappings"] != null) {
      coBorrower = <CoBorrowers>[];
      json["coBorrowerMappings"].forEach((v) {
        coBorrower!.add(CoBorrowers.fromJson(v));
      });
    }

    if (json["appBorrower"] != null) {
      borrowers = <Customer>[];
      customers = <Customer>[];
      json["appBorrower"].forEach((v) {
        borrowers!.add(Customer.fromJson(v));
        customers!.add(Customer.fromJson(v));
      });
    }

    if (json["customerInformation"] != null) {
      customerInformation = json["customerInformation"] != null
          ? ApplicationCustomerInformation.fromJson(json["customerInformation"])
          : null;
      if (customerInformation != null) {
        groupBorrowers = <Customer>[];
        for (final dynamic v in (customerInformation?.groupMappings ?? [])) {
          groupBorrowers!.add(Customer.fromJson(v.toJson()));
        }
      }
    }

    if (json["appNonBorrower"] != null) {
      nonBorrowers = <Customer>[];
      json["appNonBorrower"].forEach((v) {
        nonBorrowers!.add(Customer.fromJson(v));
      });
    }

    if (json["enabledForView"] != null) {
      enabledForView = json["enabledForView"] != 0;
    }

    if (json["appTypeReferenceId"] != null) {
      appTypeReferenceId = json["appTypeReferenceId"];
    }
  }

  /// Creates a [Request] instance from worklist data.
  Request.fromWorkList(
    Map<String, dynamic> json, {
    required List<Reference> requestStatuses,
    required List<Reference> applicationTypes,
    required List<Reference> customApplicationType,
    required List<Reference> transactionTypes,
    required List<Reference> requestTypes,
    required List<Reference> roleTypes,
  }) {
    applicationRefNo = json["appRefNo"];
    applicationSubType = json["applicationSubType"];
    requestType = requestTypes.firstWhere(
      (Reference value) =>
          value.reference1?.toLowerCase().trim() ==
          (json["requestType"] ?? "").toLowerCase().trim(),
      orElse: () => Reference(reference1: json["requestType"]),
    );
    customerRimNo = json["rimNo"];
    customerName = json["customerName"];
    businessSegment = Reference(name: json["businessSegment"]);
    businessSegmentEnum = convertToBusinessSegmentEnum(json["businessSegment"]);
    pendingSince = DateTimeUtils.getDateAsString(
      json["pendingSince"] ?? "",
    );
    ageing = json["ageing"];
    dateOfCreation = DateTimeUtils.getDateAsString(
      json["dateOfCreation"] ?? "",
    );
    final pendingWithRole = roleTypes.firstWhere(
      (Reference value) => value.id == (json["assignToRole"] ?? ""),
      orElse: () => Reference(id: json["assignToRole"]),
    );
    pendingWith =
        "${json["pendingWith"] ?? ''} - ${pendingWithRole.name ?? ''}";
    purpose = json["purpose"];
    requestStatus = requestStatuses.firstWhere(
      (Reference value) =>
          value.name?.toLowerCase().trim() ==
          (json["requestStatus"] ?? "").toLowerCase().trim(),
      orElse: () => Reference(name: json["requestStatus"]),
    );
    status = json["requestStatus"];
    receivedFrom = json["receivedFrom"];
    customerType = Reference(name: json["customerType"]);
    groupId = json["groupId"];
    groupName = json["groupName"];
    groupOwner = json["groupOwner"];
    requestedBy = json["requestedBy"];
    assignToRole = json["assignToRole"];

    terminatedReason = json["terminatedReason"];

    applicationType =
        Reference(name: json["applicationType"], id: json["applicationTypeid"]);

    final List<Reference> possibleRequestSubTypes = [
      ...applicationTypes,
      ...customApplicationType,
      ...transactionTypes,
    ];
    requestSubType = possibleRequestSubTypes.firstWhere(
      (Reference value) =>
          value.reference1?.toLowerCase().trim() ==
          (json["requestSubType"] ?? json["subType"] ?? "")
              .toLowerCase()
              .trim(),
      orElse: () =>
          Reference(reference1: json["requestSubType"] ?? json["subType"]),
    );
    logger.i(requestSubType);
  }

  /// Creates a [Request] instance from close request data.
  Request.fromCloseRequestJson(Map<String, dynamic> json) {
    requestType = json["requestType"] != null
        ? Reference(
            reference1: json["requestType"],
            id: json["requestTypeId"],
            name: json["requestTypeName"],
          )
        : null;
    requestSubType = json["requestSubType"] != null
        ? Reference(reference1: json["requestSubType"])
        : null;
    customerRimNo = json["customerRim"];
    applicationRefNo = json["applicationRefNo"];
    applicationSubType = json["applicationSubType"];
    customerName = json["customerName"];
    groupId = json["groupId"];
    groupName = json["groupName"];
    groupOwner = json["groupOwner"];
    businessSegmentEnum =
        convertToBusinessSegmentEnum(json["businessSegment"]); //need to remove
    terminatedReason = json["terminatedReason"] ?? "";
    purpose = json["purpose"];
    requestedBy = json["requestedBy"];
    status = json["requestStatus"];
    tpanRecievedDate = DateTimeUtils.intToDateTime(json["tpanRecievedDate"]);
    creditAppDate = json["creditAppDate"];
    createdDate = DateTimeUtils.intToDateTime(json["createdDate"]);

    businessSegment = Reference(
      id: json["businessSegmentId"],
      name: json["businessSegment"],
    ); //important
    applicationType = Reference(
      id: json["applicationTypeId"],
      name: json["applicationType"],
    ); //important
  }

  /// Business segment associated with the request.
  Reference? businessSegment;

  /// Business segment name.
  String? businessSegm;

  /// Business segment enumeration value.
  BusinessSegment? businessSegmentEnum;

  /// Request type.
  Reference? requestType;

  /// Request subtype.
  Reference? requestSubType;

  /// Application type.
  Reference? applicationType;

  /// Application subtype.
  String? applicationSubType;

  /// Customer type.
  Reference? customerType;

  /// Request status.
  Reference? requestStatus;

  /// Request reference type.
  Reference? reqRefType;

  /// Customer RIM number.
  int? customerRimNo;

  /// Name of the customer.
  String? customerName;

  /// Name of the customer group.
  String? groupName;

  /// Ageing information for the request.
  String? ageing;

  /// Credit approval date.
  int? caDate;

  /// Customer group identifier.
  int? groupId;

  /// Group owner identifier.
  int? groupOwner;

  /// Application reference number.
  String? applicationRefNo;

  /// Request reference number.
  String? requestRefNo;

  /// Applicant RIM number.
  String? applicantRim;

  /// Applicant name.
  String? applicantName;

  /// User who submitted the request.
  String? requestedBy;

  /// Date when the request was created.
  DateTime? createdDate;

  /// Request creation date as a formatted string.
  String? dateOfCreation;

  /// Purpose of the request.
  String? purpose;

  /// Current request status.
  String? status;

  /// Credit application date.
  int? creditAppDate;

  /// Reason for request termination.
  String? terminatedReason;

  /// List of customers associated with the request.
  List<Customer>? customers = [];

  /// Indicates whether the request is newly created.
  bool? isCreateRequest = false;

  /// Credit approving authority.
  String? cda;

  /// Region associated with the request.
  String? region;

  /// Branch associated with the request.
  String? branch;

  /// Current review date.
  DateTime? presentReviewDate;

  /// Next scheduled review date.
  DateTime? nextReviewDate;

  /// Date on which the customer request was received.
  DateTime? customerRequestReceived;

  /// Date on which all required documents were received.
  DateTime? dateAllDocumentReceived;

  /// TPAN request date.
  DateTime? tpanRequestDate;

  /// TPAN received date.
  DateTime? tpanRecievedDate;

  /// Interim review date.
  DateTime? interimReviewDate;

  /// Date on which the request was marked forward.
  DateTime? markForwardDate;

  /// Summary of the application purpose.
  String? purposeOfApplicationSummary;

  /// Detailed application purpose.
  String? purposeOfApplicationDetailed;

  /// Main sector or industry of the customer.
  String? mainSectorIndustry;

  /// Ultimate ownership details.
  String? ultimateOwnership;

  /// Justification for deviations or breaches.
  String? deviationBreachJustification;

  /// Restructured or rescheduled facility details.
  String? restructuredRescheduled;

  /// Exposure strategy details.
  String? exposureStrategy;

  /// Duration for which the request has been pending.
  String? pendingSince;

  /// User or role currently holding the request.
  String? pendingWith;

  /// Product type associated with the request.
  String? productType;

  /// Reconsideration details.
  String? reconsiderations;

  /// Last approved application reference number.
  String? lastApprovedAppRefNum;

  /// Indicates whether the request is Islamic banking related.
  bool islamic = false;

  /// Indicates whether the request is Conventional banking related.
  bool conventional = false;

  /// Indicates whether TPAN is required.
  bool tpanRequired = false;

  /// Indicates whether ERM approval is required.
  bool ermApproval = false;

  /// Indicates whether ESG assessment is required.
  bool esg = false;

  /// Indicates whether Sharia approval is required.
  bool shariaApproval = false;

  /// Indicates whether Pricing Committee approval is required.
  bool pricingCommittee = false;

  /// Indicates whether an interim review date is required.
  bool interimReviewDateRequired = false;

  /// Policy deviations linked to the request.
  List<Reference>? policyDeviations;

  /// Co-borrower mappings associated with the request.
  List<CoBorrowers>? coBorrower;

  /// List of borrower customers.
  List<Customer>? borrowers = [];

  /// List of non-borrower customers.
  List<Customer>? nonBorrowers = [];

  /// Source from which the request was received.
  String? receivedFrom;

  /// Identifier of the assigned role.
  int? assignToRole;

  /// List of FI customers by country.
  List<Customer?> fiCustomerListCountry = [];

  /// Application lifecycle statuses.
  List<ApplicationLifeCycle>? ccsysLifeCycleStatus;

  /// Indicates whether the request is enabled for viewing.
  bool? enabledForView;

  /// Indicates whether the request is editable in read-only mode.
  bool? ccsysCanEditReadOnly = true;

  /// Application business segment.
  String? appBusinessSegment;

  /// Customer type code.
  String? cusType;

  /// Application type reference identifier.
  int? appTypeReferenceId;

  /// Indicates whether the request is a group request.
  bool get isGroupRequest {
    return groupId != null;
  }

  /// Indicates whether the request has been created.
  bool get isRequestCreated {
    return applicationRefNo?.isNotEmpty ?? false;
  }

  /// List of customers associated with the request.
  List<Customer>? groupBorrowers = [];

  /// Customer information associated with the application.
  ApplicationCustomerInformation? customerInformation;

  /// Converts a business segment name to its corresponding enum value.
  BusinessSegment convertToBusinessSegmentEnum(String? businessSegment) {
    switch (businessSegment?.toLowerCase().trim() ?? "") {
      case "institutional":
        return BusinessSegment.financialInstitution;
      case "corporate":
        return BusinessSegment.corporate;
      case "business":
        return BusinessSegment.business;
      case "baf":
        return BusinessSegment.baf;
      case "personal":
        return BusinessSegment.personal;
      case "fininstandcf":
      case "fin inst and cf":
        return BusinessSegment.financialInstitutionCF;
      default:
        return BusinessSegment.na;
    }
  }

  /// Converts this [Request] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (businessSegment != null) {
      data["BusinessSegment"] = businessSegment!.toJson();
    }

    if (requestType != null) {
      data["RequestType"] = requestType!.toJson();
    }
    if (applicationType != null) {
      data["ApplicationType"] = applicationType!.toJson();
    }
    if (customerType != null) {
      data["CustomerType"] = customerType!.toJson();
    }
    data["CustomerRimNo"] = customerRimNo;
    data["applicationRefNo"] = applicationRefNo;
    data["CustomerName"] = customerName;
    data["GroupName"] = groupName;
    data["GroupId"] = groupId;
    data["groupOwner"] = groupOwner;
    data["terminatedReason"] = terminatedReason;
    data["purpose"] = purpose;
    data["requestedBy"] = requestedBy;
    data["status"] = status;
    data["tpanRecievedDate"] = tpanRecievedDate;
    data["creditAppDate"] = creditAppDate;
    data["createdDate"] = createdDate;
    data["CDA"] = cda;
    data["Region"] = region;
    data["Branch"] = branch;
    data["PresentReviewDate"] = presentReviewDate;
    data["NextReviewDate"] = nextReviewDate;
    data["CustomerRequestReceived"] = customerRequestReceived;
    data["DateAllDocumentReceived"] = dateAllDocumentReceived;
    data["PurposeOfApplicationSummary"] = purposeOfApplicationSummary;
    data["PurposeOfApplicationDetailed"] = purposeOfApplicationDetailed;
    data["islamic"] = islamic;
    data["conventional"] = conventional;
    data["tpanRequired"] = tpanRequired;
    data["tpanRequestDate"] = tpanRequestDate;
    data["interimReviewDate"] = interimReviewDate;
    data["markForwardDate"] = markForwardDate;
    data["mainSectorIndustry"] = mainSectorIndustry;
    data["ultimateOwnership"] = ultimateOwnership;
    data["deviationBreachJustification"] = deviationBreachJustification;
    data["ermApproval"] = ermApproval;
    data["esg"] = esg;
    data["shariaApproval"] = shariaApproval;
    data["pricingCommittee"] = pricingCommittee;
    data["restructuredRescheduled"] = restructuredRescheduled;
    data["interimReviewDateRequired"] = interimReviewDateRequired;
    data["exposureStrategy"] = exposureStrategy;
    data["productType"] = productType;
    data["reconsiderations"] = reconsiderations;
    data["policyDeviations"] = policyDeviations;
    data["coBorrowerMappings"] = coBorrower;
    return data;
  }
}

/// Represents a co-borrower associated with a request.
class CoBorrowers {
  /// Creates a [CoBorrowers] instance.
  CoBorrowers({
    this.borrowerId,
    this.customerName,
    this.customerRimNumber,
    this.deleted,
    this.added,
  });

  /// Creates a [CoBorrowers] instance from a JSON map.
  CoBorrowers.fromJson(Map<String, dynamic> json) {
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

  /// Converts this [CoBorrowers] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["borrowerId"] = borrowerId;
    data["customerName"] = customerName;
    data["customerRimNumber"] = customerRimNumber;
    data["deleted"] = deleted;
    data["added"] = added;
    return data;
  }
}
