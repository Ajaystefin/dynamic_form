import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/core/utils/date_time_utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/customer.dart';

class Request {
  Reference? businessSegment;
  BusinessSegment? businessSegmentEnum;
  Reference? requestType;
  Reference? requestSubType;
  Reference? applicationType;
  Reference? customerType;
  Reference? requestStatus;
  int? customerRimNo;
  String? customerName;
  String? groupName;
  String? ageing;
  int? caDate;
  int? groupId, groupOwner;
  String? applicationRefNo;
  String? requestRefNo;
  String? applicantRim;
  String? applicantName;
  String? requestedBy;
  DateTime? createdDate;
  String? dateOfCreation;
  String? purpose;
  String? status;
  int? creditAppDate;
  String? terminatedReason;
  List<Customer>? customers;
  bool? isCreateRequest = false;

  String? cda;
  String? region;
  String? branch;
  DateTime? presentReviewDate;
  DateTime? nextReviewDate;
  DateTime? customerRequestReceived;
  DateTime? dateAllDocumentReceived;
  DateTime? tpanRequestDate;
  DateTime? tpanRecievedDate;
  DateTime? interimReviewDate;
  DateTime? markForwardDate;
  String? purposeOfApplicationSummary;
  String? purposeOfApplicationDetailed;
  String? mainSectorIndustry;
  String? ultimateOwnership;
  String? deviationBreachJustification;
  String? restructuredRescheduled;
  String? exposureStrategy;
  String? pendingSince;
  String? pendingWith;
  String? productType;
  String? reconsiderations;
  bool islamic = false;
  bool conventional = false;
  bool tpanRequired = false;
  bool ermApproval = false;
  bool esg = false;
  bool shariaApproval = false;
  bool pricingCommittee = false;
  bool interimReviewDateRequired = false;
  List<Reference>? policyDeviations;
  List<CoBorrowers>? coBorrower;
  List<Customer>? borrowers;
  List<Customer>? nonBorrowers;
  String? receivedFrom;
  int? assignToRole;

  bool get isGroupRequest {
    return groupId != null;
  }

  bool get isRequestCreated {
    return applicationRefNo?.isNotEmpty ?? false;
  }

  Request(
      {this.businessSegment,
      this.isCreateRequest,
      this.requestType,
      this.businessSegmentEnum,
      this.applicationType,
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
      this.nonBorrowers});

  BusinessSegment convertToBusinessSegmentEnum(String? businessSegment) {
    switch ((businessSegment?.toLowerCase().trim()) ?? "") {
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
        return BusinessSegment.financialInstitutionCF;
      default:
        return BusinessSegment.na;
    }
  }

  Request.fromJson(
    Map<String, dynamic> json, {
    List<Reference>? requestStatuses,
    List<Reference>? bussinessSegments,
  }) {
    businessSegment = (bussinessSegments ?? []).firstWhere(
      (Reference value) =>
          value.name == (json["BusinessSegment"] ?? json["businessSegment"]),
      orElse: () => Reference(
          reference1: (json["BusinessSegment"] ?? json["businessSegment"])),
    );

    requestType = json['RequestType'] != null
        ? Reference.fromJson(json['RequestType'])
        : json['requestType'] != null
            ? Reference(reference1: json['requestType'])
            : null;
    applicationType = json['ApplicationType'] != null
        ? Reference.fromJson(json['ApplicationType'])
        : json['subType'] != null
            ? Reference(reference1: json['subType'])
            : null;
    customerType = json['CustomerType'] != null
        ? Reference.fromJson(json['CustomerType'])
        : null;
    customerRimNo = json['CustomerRimNo'] ?? json['rimNo'];
    applicationRefNo = json['applicationRefNo'];
    customerName = json['CustomerName'] ?? json['customerName'];
    groupName = json['GroupName'] ?? json['groupName'];
    groupId = json['GroupId'] ?? json['groupID'] ?? json['groupId'];
    groupOwner = json['GroupOwner'] ?? json['groupOwner'];
    terminatedReason = json['terminatedReason'];
    purpose = json['purpose'];
    requestedBy = json['requestedBy'];
    tpanRecievedDate = DateTimeUtils.intToDateTime(json['tpanRecievedDate']);
    creditAppDate = json['creditAppDate'];
    createdDate = DateTimeUtils.intToDateTime(json['createdDate']);
    cda = json['CDA'];
    region = json['Region'];
    branch = json['Branch'];
    presentReviewDate = DateTimeUtils.intToDateTime(json['PresentReviewDate']);
    nextReviewDate = DateTimeUtils.intToDateTime(json['NextReviewDate']);
    customerRequestReceived =
        DateTimeUtils.intToDateTime(json['CustomerRequestReceived']);
    dateAllDocumentReceived =
        DateTimeUtils.intToDateTime(json['DateAllDocumentReceived']);
    tpanRequestDate = DateTimeUtils.intToDateTime(json['tpanRequestDate']);
    tpanRecievedDate = DateTimeUtils.intToDateTime(json['tpanRecievedDate']);
    interimReviewDate = DateTimeUtils.intToDateTime(json['interimReviewDate']);
    markForwardDate = DateTimeUtils.intToDateTime(json['markForwardDate']);
    purposeOfApplicationSummary = json['PurposeOfApplicationSummary'];
    purposeOfApplicationDetailed = json['PurposeOfApplicationDetailed'];

    businessSegment = (requestStatuses ?? []).firstWhere(
      (Reference value) => value.id == json["status"],
      orElse: () => Reference(id: json["status"]),
    );
    islamic = json['islamic'] == 1;
    conventional = json['conventional'] == 1;
    tpanRequired = json['tpanRequired'] == 1;
    mainSectorIndustry = json['mainSectorIndustry'];
    ultimateOwnership = json['ultimateOwnership'];
    deviationBreachJustification = json['deviationBreachJustification'];
    ermApproval = json['ermApproval'] == 1;
    // esg = json['esg'] ?? false;
    shariaApproval = json['shariaApproval'] == 1;
    pricingCommittee = json['pricingCommittee'] == 1;
    restructuredRescheduled = json['restructuredRescheduled'];
    // x` = json['interimReviewDateRequired'] ?? false;
    exposureStrategy = json['exposureStrategy'];
    productType = json['productType'];
    reconsiderations = json['reconsiderations'];
    if (json['policyDeviations'] != null) {
      policyDeviations = <Reference>[];
      json['policyDeviations'].forEach((v) {
        policyDeviations!.add(Reference.fromJson(v));
      });
    }
    if (json['coBorrowerMappings'] != null) {
      coBorrower = <CoBorrowers>[];
      json['coBorrowerMappings'].forEach((v) {
        coBorrower!.add(CoBorrowers.fromJson(v));
      });
    }
    if (json['appBorrower'] != null) {
      borrowers = <Customer>[];
      json['appBorrower'].forEach((v) {
        borrowers = <Customer>[];
        borrowers!.add(Customer.fromJson(v));
      });
      customers = borrowers;
    }
    if (json['appNonBorrower'] != null) {
      nonBorrowers = <Customer>[];
      json['appNonBorrower'].forEach((v) {
        nonBorrowers!.add(Customer.fromJson(v));
      });
    }
  }

  Request.fromWorkList(
    Map<String, dynamic> json, {
    required List<Reference> requestStatuses,
    required List<Reference> applicationTypes,
    required List<Reference> transactionTypes,
    required List<Reference> requestTypes,
  }) {
    applicationRefNo = json["appRefNo"];
    requestType = requestTypes.firstWhere(
      (Reference value) =>
          value.reference1?.toLowerCase().trim() ==
          (json["requestType"] ?? "").toLowerCase().trim(),
      orElse: () => Reference(reference1: json["requestType"]),
    );
    customerRimNo = json["rimNo"];
    customerName = json["customerName"];
    businessSegment = Reference(name: json['businessSegment']);
    pendingSince = json["pendingSince"];
    ageing = json["ageing"];
    dateOfCreation =
        DateTimeUtils.getDateAsString(json["dateOfCreation"] ?? "");
    pendingWith = json["pendingWith"];
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

    applicationType =
        Reference(name: json["applicationType"], id: json['applicationTypeid']);

    List<Reference> possibleRequestSubTypes = [
      ...applicationTypes,
      ...transactionTypes
    ];
    requestSubType = possibleRequestSubTypes.firstWhere(
      (Reference value) =>
          value.reference1?.toLowerCase().trim() ==
          (json["requestSubType"] ?? "").toLowerCase().trim(),
      orElse: () => Reference(reference1: json["requestSubType"]),
    );
    logger.i(requestSubType);
  }

  Request.fromCloseRequestJson(Map<String, dynamic> json) {
    requestType = json['requestType'] != null
        ? Reference(
            reference1: json['requestType'],
            id: json['requestTypeId'],
            name: json['requestTypeName'])
        : null;
    requestSubType = json['requestSubType'] != null
        ? Reference(reference1: json['requestSubType'])
        : null;
    customerRimNo = json['customerRim'];
    applicationRefNo = json['applicationRefNo'];
    customerName = json['customerName'];
    groupId = json['groupId'];
    groupName = json['groupName'];
    groupOwner = json["groupOwner"] ?? 0;
    businessSegmentEnum =
        convertToBusinessSegmentEnum(json['businessSegment']); //need to remove
    terminatedReason = json['terminatedReason'] ?? '';
    purpose = json['purpose'];
    requestedBy = json['requestedBy'];
    status = json['requestStatus'];
    tpanRecievedDate = DateTimeUtils.intToDateTime(json['tpanRecievedDate']);
    creditAppDate = json['creditAppDate'];
    createdDate = DateTimeUtils.intToDateTime(json['createdDate']);
    businessSegment = Reference(
        id: json['businessSegmentId'],
        name: json['businessSegment']); //important
    applicationType = Reference(
        id: json['applicationTypeId'],
        name: json['applicationType']); //important
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (businessSegment != null) {
      data['BusinessSegment'] = businessSegment!.toJson();
    }

    if (requestType != null) {
      data['RequestType'] = requestType!.toJson();
    }
    if (applicationType != null) {
      data['ApplicationType'] = applicationType!.toJson();
    }
    if (customerType != null) {
      data['CustomerType'] = customerType!.toJson();
    }
    data['CustomerRimNo'] = customerRimNo;
    data['applicationRefNo'] = applicationRefNo;
    data['CustomerName'] = customerName;
    data['GroupName'] = groupName;
    data['GroupId'] = groupId;
    data['groupOwner'] = groupOwner;
    data['terminatedReason'] = terminatedReason;
    data['purpose'] = purpose;
    data['requestedBy'] = requestedBy;
    data['status'] = status;
    data['tpanRecievedDate'] = tpanRecievedDate;
    data['creditAppDate'] = creditAppDate;
    data['createdDate'] = createdDate;
    data['CDA'] = cda;
    data['Region'] = region;
    data['Branch'] = branch;
    data['PresentReviewDate'] = presentReviewDate;
    data['NextReviewDate'] = nextReviewDate;
    data['CustomerRequestReceived'] = customerRequestReceived;
    data['DateAllDocumentReceived'] = dateAllDocumentReceived;
    data['PurposeOfApplicationSummary'] = purposeOfApplicationSummary;
    data['PurposeOfApplicationDetailed'] = purposeOfApplicationDetailed;
    data['islamic'] = islamic;
    data['conventional'] = conventional;
    data['tpanRequired'] = tpanRequired;
    data['tpanRequestDate'] = tpanRequestDate;
    data['interimReviewDate'] = interimReviewDate;
    data['markForwardDate'] = markForwardDate;
    data['mainSectorIndustry'] = mainSectorIndustry;
    data['ultimateOwnership'] = ultimateOwnership;
    data['deviationBreachJustification'] = deviationBreachJustification;
    data['ermApproval'] = ermApproval;
    data['esg'] = esg;
    data['shariaApproval'] = shariaApproval;
    data['pricingCommittee'] = pricingCommittee;
    data['restructuredRescheduled'] = restructuredRescheduled;
    data['interimReviewDateRequired'] = interimReviewDateRequired;
    data['exposureStrategy'] = exposureStrategy;
    data['productType'] = productType;
    data['reconsiderations'] = reconsiderations;
    data['policyDeviations'] = policyDeviations;
    data['coBorrowerMappings'] = coBorrower;
    return data;
  }
}

class CoBorrowers {
  int? borrowerId;
  String? customerName;
  int? customerRimNumber;
  bool? deleted;
  bool? added;

  CoBorrowers(
      {this.borrowerId,
      this.customerName,
      this.customerRimNumber,
      this.deleted,
      this.added});

  CoBorrowers.fromJson(Map<String, dynamic> json) {
    borrowerId = json['borrowerId'];
    customerName = json['customerName'];
    customerRimNumber = json['customerRimNumber'];

    deleted = json['delete'];
    added = json['added'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['borrowerId'] = borrowerId;
    data['customerName'] = customerName;
    data['customerRimNumber'] = customerRimNumber;

    data['deleted'] = deleted;
    data['added'] = added;
    return data;
  }
}
