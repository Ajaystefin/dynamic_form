// Customer.dart
// ignore_for_file: avoid_annotating_with_dynamic

import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/group.dart";

/// Represents a customer associated with a request, including
/// customer profile, relationship, business, and compliance details.
class Customer {
  /// Creates a [Customer] instance.
  Customer({
    this.groups,
    this.branchCode,
    this.segment,
    this.issuedIdent,
    this.id,
    this.customerRimNo,
    this.customerName,
    this.primaryBusinessActivity,
    this.existingSICCode,
    this.proposedSICCode,
    this.preferredName,
    this.isBorrower,
    this.isBorrowerBelowGrade,
    this.isSelected = false,
    this.isSelectedBelowGrade = false,
    this.custInfoId,
    this.applicationRefNo,
    this.groupName,
    this.groupId,
    this.legalStatus,
    this.tradeLicenseNumber,
    this.tlIssuingAuthority,
    this.tlExpiryDate,
    this.industryDescription,
    this.industrySicCode,
    this.incorporateCountry,
    this.establishmentDate,
    this.relatnStartDate,
    this.borrowRelationShipDate,
    this.healthCode,
    this.purpose,
    this.cccStatus,
    this.locationAddress,
    this.correspondanceAddress,
    this.createdDate,
    this.createdBy,
    this.updatedDate,
    this.updatedBy,
    this.cbrbClassification,
    this.cbdCBRBClassification,
    this.countriesTradedWith,
    this.countryRiskWith,
    this.countriesofBussinessOperation,
    this.borrowRelnDateEditable,
    this.ifrsStaging,
    this.deviationBreachJustification,
    this.policyDeviations,
    this.worldRank,
    this.countryRank,
    this.category,
    this.type,
    this.poBox,
    this.addressLine1,
    this.addressLine2,
    this.addressLine3,
    this.emailAddress,
    this.phone,
    this.reasonForWaiver,
    this.isLimitWithinPolicy = true,
    this.residentCountry,
    this.nationality,
    this.relationshipMgr,
    this.partyStatus,
    this.tLIssueCountry,
    this.partyIdType,
    this.resident,
    this.firstName,
    this.lastName,
    this.middleName,
    this.customerAddress1,
    this.customerAddress2,
    this.customerGroupId,
    this.customerTlExpiryDate,
    this.classCode,
    this.classCodeDesc,
    this.businessSegment,
    this.isCountryFI = false,
    this.isSelectedCountryFI = false,
    this.tlExpiryDateLong,
    this.groupOwner,
  });

  /// Creates a [Customer] instance from CCSYS customer data.
  Customer.fromJsonCustomerCCSYS(Map<String, dynamic> json) {
    customerRimNo = json["rimNo"];
    customerName = json["customerName"];
    segment = json["segment"];
    branch = json["branchName"];
    branchNo = json["branchNo"];
  }

  /// Creates a [Customer] instance from group child RIM data.
  Customer.fromJsonGetChildRimsForGroup(Map<String, dynamic> json) {
    customerRimNo = json["customerRimNo"];
    customerName = json["customerName"];
    groupName = json["groupName"];
    groupId = json["groupId"];
    groupOwner = json["groupOwner"];
    firstName = json["firstName"];
    middleName = json["middleName"];
    lastName = json["lastName"];
    preferredName = json["preferredName"];

    if (json["rimType"] != null) {
      type = customerTypeFromJson(json["rimType"]); // converts safely
    }

    // If API provided a name, prefer it; otherwise build "First Middle Last"
    final String? fullName = (json["customerName"] as String?)?.trim();
    final String computed = concatNonEmpty([firstName, middleName, lastName]);
    customerName = (fullName?.isNotEmpty ?? false) ? fullName : computed;

    // customerStatus = json['customerStatus'];
    // groupStatus = json['groupStatus'];
  }

  /// Creates a [Customer] instance from a JSON map.
  Customer.fromJson(Map<String, dynamic> json) {
    bool isValid(value) =>
        value != null && value != "null" && value.toString().isNotEmpty;

    if (json["rimType"] != null) {
      type = customerTypeFromJson(json["rimType"]); // converts safely
    }

    groups =
        isValid(json["GroupKeys"]) ? Group.fromJson(json["GroupKeys"]) : null;
    id = json["PartyId"];
    namePrefix = json["PartyInfo"]?["PersonData"]?["PersonName"]
            ?["NamePrefix"] ??
        json["firstName"];
    firstName = json["PartyInfo"]?["PersonData"]?["PersonName"]?["FirstName"] ??
        json["firstName"];
    middleName = json["PartyInfo"]?["PersonData"]?["PersonName"]
            ?["MiddleName"] ??
        json["middleName"] ??
        "";
    lastName = json["PartyInfo"]?["PersonData"]?["PersonName"]?["LastName"] ??
        json["PartyInfo"]?["PersonData"]?["PersonName"]?["LastNameLocalLang"] ??
        json["lastName"];
    preferredName = json["PartyInfo"]?["PersonData"]?["PersonName"]
            ?["PreferredName"] ??
        json["preferredName"];
    tLIssueCountry = json["PartyInfo"]?["TLIssueCountry"];
    resident = json["PartyInfo"]?["Resident"];

    customerRimNo = int.tryParse(json["PartyId"] ?? " ") ??
        json["rimNo"] ??
        json["customerRimNumber"] ??
        json["customerRimNo"];
    customerName = json["PersonData"]?["PersonName"]?["LastName"] ??
        json["customerName"] ??
        json["name"] ??
        json["custName"];
    primaryBusinessActivity = json["primaryBusinessActivity"];
    existingSICCode = json["existingSICCode"];
    proposedSICCode =
        isValid(json["proposedSicCode"]) ? json["proposedSicCode"] : null;

    isBorrower = json["isBorrower"];
    custInfoId = json["custInfoId"];
    applicationRefNo = json["appRefNo"] ?? json["applicationRefNo"];
    groupName = json["groupName"];
    groupId = json["groupId"];
    if (json["groupOwner"] != null) {
      groupOwner = json["groupOwner"];
    }
    legalStatus = isValid(json["legalStatus"]) ? json["legalStatus"] : null;
    tradeLicenseNumber =
        isValid(json["tradeLicenseNo"]) ? json["tradeLicenseNo"] : null;
    tlIssuingAuthority =
        isValid(json["tlIssuingAuthority"]) ? json["tlIssuingAuthority"] : null;

    // tlExpiryDate = DateTimeUtils.intToDateTime(json['tlExpiryDate']);
    tlExpiryDate = json["tlExpiryDate"];
    establishmentDate = json["establishmentDate"];
    relatnStartDate = json["cbdRltnStartDate"];
    borrowRelationShipDate = json["borrowRltnFrom"];

    industryDescription = json["industryDescription"];
    industrySicCode = json["industryCbdSicCode"];
    incorporateCountry = isValid(json["countryOfIncorporation"])
        ? json["countryOfIncorporation"]
        : null;

    healthCode = json["healthCode"];
    purpose = json["purpose"];
    cccStatus = isValid(json["cccStatus"]) ? json["cccStatus"] : null;
    locationAddress =
        isValid(json["locationAddress"]) ? json["locationAddress"] : null;
    correspondanceAddress = isValid(json["correspondenceAddress"])
        ? json["correspondenceAddress"]
        : null;

    createdDate = json["createdDate"];
    createdBy = json["createdBy"];
    updatedDate = json["updatedDate"];
    updatedBy = json["updatedBy"];
    cbrbClassification =
        isValid(json["cbrbClassification"]) ? json["cbrbClassification"] : null;

    cbdCBRBClassification = isValid(json["cbdCBRBClassification"])
        ? json["cbdCBRBClassification"]
        : null;
    if (json["ifrsStaging"] != null) {
      ifrsStaging = json["ifrsStaging"];
    }
    if (json["deviationJustification"] != null) {
      deviationBreachJustification = json["deviationJustification"];
    }
    partyIdType = json["PartyInfo"]?["PartyIdType"] ?? json["PartyIdType"];
    worldRank = isValid(json["worldRank"]) ? json["worldRank"] : null;
    countryRank = isValid(json["countryRank"]) ? json["countryRank"] : null;
    category = isValid(json["custCategory"]) ? json["custCategory"] : null;
    poBox = isValid(json["poBox"]) ? json["poBox"] : null;
    addressLine1 = isValid(json["addressLine1"]) ? json["addressLine1"] : null;
    addressLine2 = isValid(json["addressLine2"]) ? json["addressLine2"] : null;
    addressLine3 = isValid(json["addressLine3"]) ? json["addressLine3"] : null;
    emailAddress = isValid(json["emailAddress"]) ? json["emailAddress"] : null;
    phone = isValid(json["phone"]) ? json["phone"] : null;
    residentCountry = json["PartyInfo"]?["ResidentCountry"]?.trim();
    final dynamic postAddr =
        json["PartyInfo"]?["PersonData"]?["Contact"]?["Locator"]?["PostAddr"];

    customerAddress1 =
        isValid(postAddr?["Addr1"]) ? (postAddr?["Addr1"]) : null;
    customerAddress2 =
        isValid(postAddr?["Addr2"]) ? (postAddr?["Addr2"]) : null;
    customerAddress3 =
        isValid(postAddr?["Addr3"]) ? (postAddr?["Addr3"]) : null;
    city = isValid(postAddr?["city"]) ? (postAddr?["city"]) : null;
    country = isValid(postAddr?["city"]) ? (postAddr?["country"]) : null;

    // customerGroupId= json['GroupKeys']['GroupId'];
    customerTlExpiryDate = json["PartyInfo"]?["TLExpiryDt"];
    nationality =
        (json["Nationality"] as List?)?.map((e) => e.toString()).toList();
    if (json["reasonForWaiver"] != null) {
      reasonForWaiver = json["reasonForWaiver"];
    }

    if (json["countriesTradedWith"] != null) {
      final raw = json["countriesTradedWith"];
      if (raw is String) {
        final list = raw.split(",").map((e) => e.trim()).toList();
        countriesTradedWith = list.map((e) => Country(description: e)).toList();
      }
    }
    if (json["countryOfBusiness"] != null) {
      final raw = json["countryOfBusiness"];
      if (raw is String) {
        final list = raw.split(",").map((e) => e.trim()).toList();
        countriesofBussinessOperation =
            list.map((e) => Country(description: e)).toList();
      }
    }
    if (json["countryOfRisk"] != null) {
      final raw = json["countryOfRisk"];
      if (raw is String) {
        final list = raw.split(",").map((e) => e.trim()).toList();
        countryRiskWith = list.map((e) => Country(description: e)).toList();
      }
    }
    if (json["policyDeviation"] != null) {
      final dynamic raw = json["policyDeviation"];
      if (raw is String) {
        // final list = raw.split(",").map((e) => e.trim()).toList();
        // policyDeviations = list.map((e) => Reference(name: e)).toList();
        final List<String> list = raw.split(",").map((e) => e.trim()).toList();
        policyDeviations = list.map((e) {
          final bool isId = int.tryParse(e) != null;
          return isId
              ? Reference(id: int.tryParse(e)) // store as ID
              : Reference(name: e); // store as NAME
        }).toList();
      }
    }

    if (json["applicationBorrowerId"] != null) {
      applicationBorrowerId = json["applicationBorrowerId"];
    }

    if (json["isLimitWithinPolicy"] != null) {
      isLimitWithinPolicy = json["isLimitWithinPolicy"];
    }
    borrowRelnDateEditable = json["borrowRelnDateEditable"];
    isBorrowerBelowGrade = json["isBorrowerBelowGrade"];

    // Handle issuedIdent
    if (json["PartyInfo"] != null) {
      final issued = json["PartyInfo"]?["IssuedIdent"];
      if (issued != null && issued is List) {
        issuedIdent = issued
            .map<Reference>(
              (item) => Reference(
                name: item["IssuedIdentName"] ?? "",
                description: item["IssuedIdentValue"] ?? "",
              ),
            )
            .toList();
      }
      if (json["PartyInfo"]?["OriginatingBranchCode"] != null) {
        branchCode = json["PartyInfo"]?["OriginatingBranchCode"];
      }
      if (json["PartyInfo"]?["Segmentation"] != null) {
        if (json["PartyInfo"]?["Segmentation"]["SegmentDesc"] != null) {
          segment = json["PartyInfo"]?["Segmentation"]["SegmentDesc"];
        }
      }
      if (json["PartyInfo"]?["OriginatingBranchName"] != null) {
        if (json["PartyInfo"]?["OriginatingBranchName"] != null) {
          branch = json["PartyInfo"]?["OriginatingBranchName"];
        }
      }

      if (json["PartyInfo"]?["PartyStatus"] != null) {
        if (json["PartyInfo"]?["PartyStatus"] != null) {
          partyStatus = json["PartyInfo"]?["PartyStatus"];
        }
      }

      if (json["PartyInfo"]?["ClassCode"] != null) {
        if (json["PartyInfo"]?["ClassCode"] != null) {
          classCode = json["PartyInfo"]?["ClassCode"];
        }
      }

      if (json["PartyInfo"]?["ClassCodeDesc"] != null) {
        if (json["PartyInfo"]?["ClassCodeDesc"] != null) {
          classCodeDesc = json["PartyInfo"]?["ClassCodeDesc"];
        }
      }

      // Parse RelationshipMgr list from PartyInfo

      final relationshipManagersJson = json["PartyInfo"]?["RelationshipMgr"];
      if (relationshipManagersJson is List) {
        relationshipMgr =
            // Map JSON
            relationshipManagersJson.map<Map<String, String>>((managerJson) {
          return {
            "RelationshipMgrIdent":
                managerJson["RelationshipMgrIdent"]?.toString() ?? "",
            "RelationshipMgrName":
                managerJson["RelationshipMgrName"]?.toString() ?? "",
            "RelationshipMgrUserId":
                managerJson["RelationshipMgrUserId"]?.toString() ?? "",
          };
        }).toList();
      }
    }
  }

  /// Customer group information.
  Group? groups;

  /// Type of customer.
  CustomerType? type;

  /// Unique customer identifier.
  String? id;

  /// Customer name prefix.
  String? namePrefix;

  /// Customer last name.
  String? lastName;

  /// Customer first name.
  String? firstName;

  /// Customer middle name.
  String? middleName;

  /// Preferred customer name.
  String? preferredName;

  /// Trade license issuing country.
  String? tLIssueCountry;

  /// Customer residency status.
  String? resident;

  /// Customer RIM number.
  int? customerRimNo;

  /// Customer name.
  String? customerName;

  /// Primary business activity.
  String? primaryBusinessActivity;

  /// Proposed SIC code.
  String? proposedSICCode;

  /// Existing SIC code.
  String? existingSICCode;

  /// Indicates whether the customer is a borrower.
  bool? isBorrower;

  /// Indicates whether the borrower is below investment grade.
  bool? isBorrowerBelowGrade;

  /// Indicates whether the customer is selected.
  bool? isSelected;

  /// Customer information identifier.
  int? custInfoId;

  /// Indicates whether the below-grade borrower is selected.
  bool? isSelectedBelowGrade;

  /// Application reference number.
  String? applicationRefNo;

  /// Customer group name.
  String? groupName;

  /// Group owner identifier.
  int? groupOwner;

  /// Customer group identifier.
  int? groupId;

  /// Customer group code.
  String? customerGroupId;

  /// Customer address line 1.
  String? customerAddress1;

  /// Customer address line 2.
  String? customerAddress2;

  /// Customer address line 3.
  String? customerAddress3;

  /// City of the customer.
  String? city;

  /// Country of the customer.
  String? country;

  /// Customer trade license expiry date.
  String? customerTlExpiryDate;

  /// Customer legal status.
  String? legalStatus;

  /// Trade license number.
  String? tradeLicenseNumber;

  /// Trade license issuing authority.
  String? tlIssuingAuthority;

  /// Trade license expiry date.
  String? tlExpiryDate;

  /// Industry description.
  String? industryDescription;

  /// Industry SIC code.
  String? industrySicCode;

  /// Country of incorporation.
  String? incorporateCountry;

  /// Business establishment date.
  String? establishmentDate;

  /// Relationship start date.
  String? relatnStartDate;

  /// Borrowing relationship start date.
  String? borrowRelationShipDate;

  /// Health code.
  int? healthCode;

  /// Purpose code.
  int? purpose;

  /// CCC status.
  String? cccStatus;

  /// Location address.
  String? locationAddress;

  /// Correspondence address.
  String? correspondanceAddress;

  /// Record creation date.
  String? createdDate;

  /// User who created the record.
  String? createdBy;

  /// Record update date.
  String? updatedDate;

  /// User who updated the record.
  String? updatedBy;

  /// CBRB classification.
  String? cbrbClassification;

  /// CBD CBRB classification.
  String? cbdCBRBClassification;

  /// Indicates whether borrowing relationship date is editable.
  bool? borrowRelnDateEditable;

  /// Countries traded with.
  List<Country>? countriesTradedWith;

  /// Countries of risk exposure.
  List<Country>? countryRiskWith;

  /// Countries of business operation.
  List<Country>? countriesofBussinessOperation;

  /// IFRS staging classification.
  String? ifrsStaging;

  /// Deviation or breach justification.
  String? deviationBreachJustification;

  /// Application borrower identifier.
  int? applicationBorrowerId;

  /// World ranking.
  int? worldRank;

  /// Country ranking.
  int? countryRank;

  /// Customer category.
  String? category;

  /// PO Box number.
  String? poBox;

  /// Address line 1.
  String? addressLine1;

  /// Address line 2.
  String? addressLine2;

  /// Address line 3.
  String? addressLine3;

  /// Email address.
  String? emailAddress;

  /// Phone number.
  String? phone;

  /// Reason for waiver.
  String? reasonForWaiver;

  /// Indicates whether limits are within policy.
  bool? isLimitWithinPolicy = true;

  /// Issued identification details.
  List<Reference>? issuedIdent;

  /// Policy deviations.
  List<Reference>? policyDeviations;

  /// Relationship manager details.
  List<Map<String, String>>? relationshipMgr;

  /// Indicates whether borrower relationship date is used.
  bool isBorrowerRelationshipDate = false;

  /// Borrowing relationship date as epoch value.
  int? borrowRelationShipDateLong;

  /// Establishment date as epoch value.
  int? establishmentDateLong;

  /// Relationship start date as epoch value.
  int? relatnStartDateLong;

  /// Trade license expiry date as epoch value.
  int? tlExpiryDateLong;

  /// Country of residence.
  String? residentCountry;

  /// Nationalities associated with the customer.
  List<String>? nationality;

  /// Originating branch code.
  String? branchCode;

  /// Branch name.
  String? branch;

  /// Branch number.
  int? branchNo;

  /// Party status.
  String? partyStatus;

  /// Party identifier type.
  String? partyIdType;

  /// Customer segment.
  String? segment;

  /// Class code.
  String? classCode;

  /// Class code description.
  String? classCodeDesc;

  /// Business segment.
  String? businessSegment;

  /// Indicates whether the customer belongs to a country FI category.
  bool? isCountryFI = false;

  /// Indicates whether the country FI customer is selected.
  bool? isSelectedCountryFI = false;

  /// Region associated with the customer.
  String? region;

  /// Indicates whether the customer is primary.
  bool isPrimary = false;

  /// Returns the preferred display name of the customer.
  String? get displayName =>
      customerName ??
      firstName ??
      preferredName ??
      lastName ??
      middleName ??
      "";

  /// Returns the customer's full name assembled from individual name parts.
  String get fullName => concatNonEmpty([firstName, middleName, lastName]);

  /// Returns the customer name to be displayed with priority-based fallbacks.
  ///
  /// Its working for Request info(Coborrow)and Customer info(Ownership)
  String? get displayRIMName {
    final c = customerName?.trim();
    if (c != null && c.isNotEmpty) {
      return c;
    }

    final f = firstName?.trim();
    if (f != null && f.isNotEmpty) {
      return f;
    }

    final p = preferredName?.trim();
    if (p != null && p.isNotEmpty) {
      return p;
    }

    final l = lastName?.trim();
    if (l != null && l.isNotEmpty) {
      return l;
    }

    final m = middleName?.trim();
    if (m != null && m.isNotEmpty) {
      return m;
    }

    return null; // or "" if you prefer non-null return type
  }

  /// Joins non-empty string values using the specified separator.
  ///
  /// Helper to join non-empty parts with a separator (defaults to a space).
  String concatNonEmpty(List<String?> parts, {String sep = " "}) {
    return parts
        .map((p) => p?.trim())
        .where((p) => p != null && p.isNotEmpty)
        .map((p) => p ?? "")
        .join(sep);
  }

  /// Returns a final display name string:
  /// - If customerName exists → use it directly
  /// - Else: (firstName or preferredName) + middleName + lastName
  /// Returns empty string if nothing is available.
  String get concatCustomerFullName {
    // Prefer customerName as a direct display if present.
    // final customer = customerName?.trim();
    // if (customer != null && customer.isNotEmpty) {
    //   return customer;
    // }

    // Choose first name: prefer firstName, fallback to preferredName.
    final first =
        (firstName?.trim().isNotEmpty ?? false) ? firstName!.trim() : null;

    final middle =
        (middleName?.trim().isNotEmpty ?? false) ? middleName!.trim() : null;
    final last =
        (lastName?.trim().isNotEmpty ?? false) ? lastName!.trim() : null;

    final result = concatNonEmpty([first, middle, last]);
    return result.isNotEmpty ? result : "";
  }

  /// Converts this [Customer] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (groups != null) {
      data["GroupKeys"] = groups!.toJson();
    }
    data["PartyId"] = id;
    data["rimNo"] = customerRimNo;
    data["primaryBusinessActivity"] = primaryBusinessActivity;
    data["customerName"] = customerName;
    data["existingSICCode"] = existingSICCode;
    data["proposedSicCode"] = proposedSICCode;
    // data['isBorrower'] = isBorrower;
    data["custInfoId"] = custInfoId;
    data["appRefNo"] = applicationRefNo;
    data["groupName"] = groupName;
    data["groupId"] = groupId;
    data["legalStatus"] = legalStatus;
    data["tradeLicenseNo"] = tradeLicenseNumber;
    data["tlIssuingAuthority"] = tlIssuingAuthority;
    data["tlExpiryDate"] = tlExpiryDate;
    data["industryDescription"] = industryDescription;
    data["industryCbdSicCode"] = industrySicCode;
    data["countryOfIncorporation"] = incorporateCountry;
    data["countryOfBusiness"] = countriesofBussinessOperation;
    data["establishmentDate"] = establishmentDate;
    data["cbdRltnStartDate"] = relatnStartDate;
    data["borrowRltnFrom"] = borrowRelationShipDate;
    // data['healthCode'] = healthCode;
    // data['purpose'] = purpose;
    data["cccStatus"] = cccStatus;
    data["locationAddress"] = locationAddress;
    data["correspondanceAddress"] = correspondanceAddress;
    data["createdDate"] = createdDate;
    data["createdBy"] = createdBy;
    data["updatedDate"] = updatedDate;
    data["updatedBy"] = updatedBy;
    data["cbrbClasification"] = cbrbClassification;
    // data['tradedCountryList'] = tradedCountry;
    // data['countryOfRisk'] = countryOfRisk;
    data["cbdCBRBClassification"] = cbdCBRBClassification;
    // data['borrowRelnDateEditable'] = borrowRelnDateEditable;
    // data['isBorrowerBelowGrade'] = isBorrowerBelowGrade;
    data["ifrsStaging"] = ifrsStaging;
    data["deviationJustification"] = deviationBreachJustification;
    data["policyDeviation"] = policyDeviations;
    data["worldRank"] = worldRank;
    data["countryRank"] = countryRank ??= 0;
    data["custCategory"] = category;
    data["countriesTradedWith"] = countriesTradedWith;
    data["poBox"] = poBox;
    data["addressLine1"] = addressLine1;
    data["addressLine2"] = addressLine2;
    data["addressLine3"] = addressLine3 ?? "DUBAI";
    data["emailAddress"] = emailAddress;
    data["phone"] = phone;
    data["reasonForWaiver"] = reasonForWaiver;
    data["cbrbClassification"] = cbrbClassification;
    data["isLimitWithinPolicy"] = isLimitWithinPolicy;
    return data;
  }

  /// Converts this [Customer] instance to a JSON payload for saving.
  Map<String, dynamic> toSaveJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    //final df = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

    if (groups != null) {
      data["GroupKeys"] = groups!.toJson();
    }

    data["PartyId"] = id;
    data["custInfoId"] = custInfoId;
    data["appRefNo"] = applicationRefNo;
    data["rimNo"] = customerRimNo;
    data["businessSegment"] = businessSegment;
    data["customerName"] = customerName;
    data["groupName"] = groupName;
    data["groupId"] = groupId;
    // data['groupOwner'] = groupOwner;

    if (primaryBusinessActivity != null) {
      data["primaryBusinessActivity"] = primaryBusinessActivity;
    }
    if (legalStatus != null) {
      data["legalStatus"] = legalStatus;
    }
    if (tradeLicenseNumber != null) {
      data["tradeLicenseNo"] = tradeLicenseNumber;
    }
    if (tlIssuingAuthority != null) {
      data["tlIssuingAuthority"] = tlIssuingAuthority;
    }

    data["industryDescription"] = industryDescription;
    data["industryCbdSicCode"] = industrySicCode;
    data["countryOfIncorporation"] = incorporateCountry;

    data["tlExpiryDate"] = tlExpiryDateLong;
    data["establishmentDate"] = establishmentDateLong;
    data["cbdRltnStartDate"] = relatnStartDateLong;
    data["borrowRltnFrom"] = isBorrowerRelationshipDate
        ? borrowRelationShipDateLong
        : borrowRelationShipDate;

    if (countriesofBussinessOperation != null &&
        countriesofBussinessOperation!.isNotEmpty) {
      data["countryOfBusiness"] =
          countriesofBussinessOperation!.map((e) => e.description).join(", ");
    }

    if (countryRiskWith != null && countryRiskWith!.isNotEmpty) {
      data["countryOfRisk"] =
          countryRiskWith!.map((e) => e.description).join(", ");
    }

    if (countriesTradedWith != null && countriesTradedWith!.isNotEmpty) {
      data["countriesTradedWith"] =
          countriesTradedWith!.map((e) => e.description).join(", ");
    }

    if (policyDeviations != null && policyDeviations!.isNotEmpty) {
      data["policyDeviation"] = policyDeviations!.map((e) => e.id).join(", ");
    }

    data["cbdCBRBClassification"] = cbdCBRBClassification;
    data["cbrbClassification"] = cbrbClassification;

    data["purposeCode"] = purpose;
    data["healthCode"] = healthCode;
    data["locationAddress"] = locationAddress;
    data["correspondenceAddress"] = correspondanceAddress;
    data["poBox"] = poBox;
    data["addressLine1"] = addressLine1;
    data["addressLine2"] = addressLine2;
    data["addressLine3"] = addressLine3 ?? "DUBAI";
    data["emailAddress"] = emailAddress;
    data["phone"] = phone;
    data["cccStatus"] = cccStatus;
    // data['isPrimary'] = isPrimary;
    // data['isCoBorrower'] = isCoBorrower ?? false ? 1 : 0;
    data["proposedSicCode"] = proposedSICCode;
    data["ifrsStaging"] = ifrsStaging;
    // data['cusType'] = customerType;

    data["deviationJustification"] = deviationBreachJustification;
    data["reasonForWaiver"] = reasonForWaiver;
    data["worldRank"] = worldRank;
    data["isLimitWithinPolicy"] = isLimitWithinPolicy ??= true;
    data["countryRank"] = countryRank ??= 0;
    data["custCategory"] = category;
    return data;
  }

  /// Converts this [Customer] instance to a borrower JSON payload.
  ///
  /// This to save json working on Save Application if change any thing not working.
  Map<String, dynamic> toSaveBorrowerJson() {
    final bool isFI =
        Utils.checkBusinessSegment(BusinessSegment.financialInstitution);
    final Map<String, dynamic> data = <String, dynamic>{};
    //final df = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    if (groups != null) {
      data["groupName"] = groups?.name ?? "0";
      data["groupId"] =
          (groups?.id != null && groups?.id.toString().toLowerCase() != "null")
              ? int.tryParse(groups?.id.toString() ?? "0") ?? 0
              : 0;
      data["groupOwner"] = groups?.groupOwner ?? 0;
      data["groupStatus"] = "Active";
    } else {
      data["groupName"] = Globals.request?.groupName ?? "";
      data["groupId"] = Globals.request?.groupId ?? 0;
      data["groupOwner"] = Globals.request?.groupOwner ?? 0;
      data["groupStatus"] = "Active";
    }
    data["customerRimNo"] = customerRimNo;
    // data['customerName'] = displayName ?? '';
    data["firstName"] = firstName;
    data["middleName"] = middleName;
    data["lastName"] = lastName;
    data["preferredName"] = preferredName;
    data["customerStatus"] = "Active";

    data["rimType"] ??= isFI
        ? (isSelectedCountryFI ?? false)
            ? CustomerType.country.name
            : (isSelected ?? false)
                ? CustomerType.investmentGradeBanks.name
                : (isSelectedBelowGrade ?? false)
                    ? CustomerType.belowInvestmentGradeBanks.name
                    : null
        : (isSelected ?? false)
            ? BusinessSegment.corporate.name
            : null;
    return data;
  }
}

/// Represents customer ownership information, including ownership
/// percentages, identification details, and ownership type.
class CustomerOwnerShipInfo {
  /// Creates a [CustomerOwnerShipInfo] instance.
  CustomerOwnerShipInfo({
    this.custOwnId,
    this.custOwnershipName,
    this.custOwnershipRim,
    this.rim,
    this.nationality,
    this.shareHoldingPercentage,
    this.resident,
    this.beneficialOwnerhipPercentage,
    this.identificationDetail,
    this.identificationNumber,
    this.createdBy,
    this.updatedBy,
    this.custOwnershipType,
    this.isNewlyAdded = false,
    this.hasRim = false,
    this.hasRimInitialized = false,
  });

  /// Creates a [CustomerOwnerShipInfo] instance from a JSON map.
  CustomerOwnerShipInfo.fromJson(Map<String, dynamic> json) {
    custOwnId = json["custOwnershipId"];
    custOwnershipName = json["custOwnerName"];
    custOwnershipRim = json["custOwnerRim"];
    rim = json["custInfoId"];
    nationality = json["nationality"];
    shareHoldingPercentage = json["shareHoldingPerc"];
    resident = json["resident"];
    beneficialOwnerhipPercentage = json["beneficialOwnershipPerc"];
    identificationDetail = json["identificationDetails"];
    identificationNumber = json["identificationNumber"];
    createdBy = json["createdBy"];
    updatedBy = json["updatedBy"];
    custOwnershipType = json["custOwnerType"];
  }

  /// Unique identifier of the customer ownership record.
  int? custOwnId;

  /// Name of the customer owner.
  String? custOwnershipName;

  /// RIM number of the customer owner.
  int? custOwnershipRim;

  /// Nationality of the customer owner.
  String? nationality;

  /// Shareholding percentage owned by the customer owner.
  double? shareHoldingPercentage;

  /// Residency status of the customer owner.
  String? resident;

  /// Beneficial ownership percentage.
  double? beneficialOwnerhipPercentage;

  /// Identification detail type.
  String? identificationDetail;

  /// Identification number of the customer owner.
  String? identificationNumber;

  /// User who created the record.
  String? createdBy;

  /// User who last updated the record.
  String? updatedBy;

  /// Ownership type of the customer owner.
  String? custOwnershipType;

  /// Indicates whether the ownership record was newly added.
  bool? isNewlyAdded;

  /// Identifier of the associated customer information record.
  ///
  /// UI checkbox state: 1 = checked, 0 = unchecked
  int? rim;

  /// Indicates whether the RIM flag has been initialized.
  ///
  /// UI-only flag
  bool hasRimInitialized = false;

  /// Indicates whether the ownership record has a RIM association.
  ///
  /// UI-only flag
  bool hasRim = false;

  /// Converts this [CustomerOwnerShipInfo] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["custOwnershipId"] = custOwnId;
    data["custOwnerName"] = custOwnershipName;
    data["custOwnerRim"] = custOwnershipRim;
    data["custInfoId"] = rim;
    data["nationality"] = nationality;
    data["shareHoldingPerc"] = shareHoldingPercentage;
    data["resident"] = resident;
    data["beneficialOwnershipPerc"] = beneficialOwnerhipPercentage;
    data["identificationDetails"] = identificationDetail;
    data["identificationNumber"] = identificationNumber;
    data["createdBy"] = createdBy;
    data["updatedBy"] = updatedBy;
    data["custOwnerType"] = custOwnershipType;
    return data;
  }
}

/// Represents a customer exception record, including exception details,
/// due date, status, and recommendations.
class CustomerException {
  /// Creates a [CustomerException] instance.
  CustomerException({
    this.type,
    this.facilityId,
    this.exceptionId,
    this.custInfoId,
    this.description,
    this.dueDate,
    this.status,
    this.recommendations,
    this.delete,
    this.dueDateLong,
  });

  /// Creates a [CustomerException] instance from a JSON map.
  CustomerException.fromJson(Map<String, dynamic> json) {
    exceptionId = json["exceptionId"];
    custInfoId = json["custInfoId"];
    type = json["typeCode"];
    facilityId = json["facility"];
    description = json["exceptionDescription"];
    dueDate = json["dueDate"];
    status = json["status"];
    recommendations = json["recommendation"];
    delete = json["delete"] ?? false;
  }

  /// Exception type code.
  String? type;

  /// Related facility identifier.
  String? facilityId;

  /// Unique identifier of the exception.
  int? exceptionId;

  /// Identifier of the associated customer information record.
  int? custInfoId;

  /// Description of the exception.
  String? description;

  /// Due date of the exception.
  String? dueDate;

  /// Current status of the exception.
  String? status;

  /// Recommended action for the exception.
  String? recommendations;

  /// Indicates whether the exception is marked for deletion.
  bool? delete;

  /// Due date represented as a numeric value.
  int? dueDateLong;

  /// Converts this [CustomerException] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["exceptionId"] = exceptionId;
    data["custInfoId"] = custInfoId;
    data["typeCode"] = type;
    data["facility"] = facilityId;
    data["exceptionDescription"] = description;
    data["dueDate"] = dueDateLong;
    data["status"] = status;
    data["recommendation"] = recommendations;
    data["delete"] = delete;
    return data;
  }
}

/// Converts a JSON value to a [CustomerType] enum value.
///
/// Supports:
/// - String enum names such as `belowInvestmentGradeBanks`.
/// - Integer enum indexes returned by the backend.
///
/// Returns `null` when the input value is null.
CustomerType? customerTypeFromJson(Object? value) {
  if (value == null) {
    return null;
  }

  // If the backend sends the exact enum name as string:
  if (value is String) {
    // Case-insensitive match; remove this .toLowerCase() if your API is strict
    final String lower = value.toLowerCase();
    for (final CustomerType value in CustomerType.values) {
      if (value.name.toLowerCase() == lower) {
        return value;
      }
    }
    // Optionally: return a default or throw
    // return CustomerType.country;
    throw ArgumentError.value(
      value,
      "rimType",
      "Unknown CustomerType literal",
    );
  }

  // If the backend sends an index (not common, but possible)
  if (value is int) {
    if (value >= 0 && value < CustomerType.values.length) {
      return CustomerType.values[value];
    }
    throw RangeError.index(value, CustomerType.values, "rimType");
  }

  throw ArgumentError.value(value, "rimType", "Unsupported type");
}

/// Converts a [CustomerType] enum value to its JSON string representation.
///
/// Returns the enum name used by the API, for example
/// `belowInvestmentGradeBanks`.
dynamic customerTypeToJson(CustomerType? value) {
  return value?.name;
}
