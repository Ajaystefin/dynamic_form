import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/group.dart";

class Customer {
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
  });

  Customer.fromJsonCustomerCCSYS(Map<String, dynamic> json) {
    customerRimNo = json["rimNo"];
    customerName = json["customerName"];
    segment = json["segment"];
    branch = json["branchName"];
  }

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

  Customer.fromJson(Map<String, dynamic> json) {
    bool isValid(dynamic value) =>
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
    customerAddress1 = isValid(
      json["PartyInfo"]?["PersonData"]["Contact"]["Locator"]["PostAddr"]
          ["Addr1"],
    )
        ? (json["PartyInfo"]?["PersonData"]["Contact"]["Locator"]["PostAddr"]
            ["Addr1"])
        : null;
    customerAddress2 = isValid(
      json["PartyInfo"]?["PersonData"]["Contact"]["Locator"]["PostAddr"]
          ["Addr2"],
    )
        ? (json["PartyInfo"]?["PersonData"]["Contact"]["Locator"]["PostAddr"]
            ["Addr2"])
        : null;
    customerAddress3 = isValid(
      json["PartyInfo"]?["PersonData"]["Contact"]["Locator"]["PostAddr"]
          ["Addr3"],
    )
        ? (json["PartyInfo"]?["PersonData"]["Contact"]["Locator"]["PostAddr"]
            ["Addr3"])
        : null;
    city = isValid(
      json["PartyInfo"]?["PersonData"]["Contact"]["Locator"]["PostAddr"]
          ["city"],
    )
        ? (json["PartyInfo"]?["PersonData"]["Contact"]["Locator"]["PostAddr"]
            ["city"])
        : null;
    country = isValid(
      json["PartyInfo"]?["PersonData"]["Contact"]["Locator"]["PostAddr"]
          ["city"],
    )
        ? (json["PartyInfo"]?["PersonData"]["Contact"]["Locator"]["PostAddr"]
            ["country"])
        : null;

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
      final raw = json["policyDeviation"];
      if (raw is String) {
        final list = raw.split(",").map((e) => e.trim()).toList();
        policyDeviations = list.map((e) => Reference(name: e)).toList();
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
            relationshipManagersJson.map<Map<String, String>>((managerJson) {
          return {
            "RelationshipMgrIdent":
                managerJson["RelationshipMgrIdent"]?.toString() ?? "",
            "RelationshipMgrName":
                managerJson["RelationshipMgrName"]?.toString() ?? "",
          };
        }).toList();
      }
    }
  }
  Group? groups;
  CustomerType? type;
  String? id;

  String? namePrefix;
  String? lastName;
  String? firstName;
  String? middleName;
  String? preferredName;
  String? tLIssueCountry;
  String? resident;
  int? customerRimNo;
  String? customerName;
  String? primaryBusinessActivity;
  String? proposedSICCode;
  String? existingSICCode;
  bool? isBorrower;
  bool? isBorrowerBelowGrade;
  bool? isSelected;
  int? custInfoId;
  bool? isSelectedBelowGrade;

  String? applicationRefNo;
  String? groupName;
  int? groupOwner;
  int? groupId;
  String? customerGroupId;
  String? customerAddress1;
  String? customerAddress2;
  String? customerAddress3;
  String? city;
  String? country;
  String? customerTlExpiryDate;
  String? legalStatus;
  String? tradeLicenseNumber;
  String? tlIssuingAuthority;
  String? tlExpiryDate;
  String? industryDescription;
  String? industrySicCode;
  String? incorporateCountry;
  String? establishmentDate;
  String? relatnStartDate;
  String? borrowRelationShipDate;
  int? healthCode;
  int? purpose;
  String? cccStatus;
  String? locationAddress;
  String? correspondanceAddress;
  String? createdDate;
  String? createdBy;
  String? updatedDate;
  String? updatedBy;
  String? cbrbClassification;
  String? cbdCBRBClassification;
  bool? borrowRelnDateEditable;
  List<Country>? countriesTradedWith;
  List<Country>? countryRiskWith;
  List<Country>? countriesofBussinessOperation;
  String? ifrsStaging;
  String? deviationBreachJustification;

  int? applicationBorrowerId;
  int? worldRank;
  int? countryRank;
  String? category;
  String? poBox,
      addressLine1,
      addressLine2,
      addressLine3,
      emailAddress,
      phone,
      reasonForWaiver;
  bool? isLimitWithinPolicy = true;
  List<Reference>? issuedIdent;
  List<Reference>? policyDeviations;
  List<Map<String, String>>? relationshipMgr;

  bool isBorrowerRelationshipDate = false;
  int? borrowRelationShipDateLong;
  int? establishmentDateLong;
  int? relatnStartDateLong;
  int? tlExpiryDateLong;
  String? residentCountry;
  List<String>? nationality;
  String? branchCode;
  String? branch;
  String? partyStatus;
  String? partyIdType;
  String? segment;
  String? classCode;
  String? classCodeDesc;
  String? businessSegment;
  bool? isCountryFI = false;
  bool? isSelectedCountryFI = false;
  String? region; // to save region from reference data

  bool isPrimary = false;

  String? get displayName =>
      customerName ??
      firstName ??
      preferredName ??
      lastName ??
      middleName ??
      "";
  String get fullName => concatNonEmpty([firstName, middleName, lastName]);

  //its working for Request info(Coborrow)and Customer info(Ownership)
  String? get displayRIMName {
    final c = customerName?.trim();
    if (c != null && c.isNotEmpty) return c;

    final f = firstName?.trim();
    if (f != null && f.isNotEmpty) return f;

    final p = preferredName?.trim();
    if (p != null && p.isNotEmpty) return p;

    final l = lastName?.trim();
    if (l != null && l.isNotEmpty) return l;

    final m = middleName?.trim();
    if (m != null && m.isNotEmpty) return m;

    return null; // or "" if you prefer non-null return type
  }

  /// Helper to join non-empty parts with a separator (defaults to a space).
  String concatNonEmpty(List<String?> parts, {String sep = " "}) {
    return parts
        .map((p) => p?.trim())
        .where((p) => p != null && (p).isNotEmpty)
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
        (firstName?.trim().isNotEmpty == true) ? firstName!.trim() : null;

    final middle =
        (middleName?.trim().isNotEmpty == true) ? middleName!.trim() : null;
    final last =
        (lastName?.trim().isNotEmpty == true) ? lastName!.trim() : null;

    final result = concatNonEmpty([first, middle, last]);
    return result.isNotEmpty ? result : "";
  }

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
    data["countryRank"] = countryRank;
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
    if (legalStatus != null) data["legalStatus"] = legalStatus;
    if (tradeLicenseNumber != null) data["tradeLicenseNo"] = tradeLicenseNumber;
    if (tlIssuingAuthority != null) {
      data["tlIssuingAuthority"] = tlIssuingAuthority;
    }

    data["industryDescription"] = industryDescription;
    data["industryCbdSicCode"] = industrySicCode;
    data["countryOfIncorporation"] = incorporateCountry;

    data["tlExpiryDate"] = tlExpiryDateLong;
    data["establishmentDate"] = establishmentDateLong;
    data["cbdRltnStartDate"] = relatnStartDateLong;
    data["borrowRltnFrom"] = (isBorrowerRelationshipDate)
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
      data["policyDeviation"] = policyDeviations!.map((e) => e.name).join(", ");
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
    // data['isCoBorrower'] = isCoBorrower == true ? 1 : 0;
    data["proposedSicCode"] = proposedSICCode;
    data["ifrsStaging"] = ifrsStaging;
    // data['cusType'] = customerType;

    data["deviationJustification"] = deviationBreachJustification;
    data["reasonForWaiver"] = reasonForWaiver;
    data["worldRank"] = worldRank;
    data["isLimitWithinPolicy"] = isLimitWithinPolicy ??= true;
    data["countryRank"] = countryRank;
    data["custCategory"] = category;
    return data;
  }

  //This to save json working on Save Application if change any thing not
  //working.
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
    }
    data["customerRimNo"] = customerRimNo;
    // data['customerName'] = displayName ?? '';
    data["firstName"] = firstName;
    data["middleName"] = middleName;
    data["lastName"] = lastName;
    data["preferredName"] = preferredName;
    data["customerStatus"] = "Active";

    data["rimType"] ??= (isFI)
        ? (isSelectedCountryFI == true)
            ? CustomerType.country.name
            : (isSelected == true)
                ? CustomerType.investmentGradeBanks.name
                : (isSelectedBelowGrade == true)
                    ? CustomerType.belowInvestmentGradeBanks.name
                    : null
        : (isSelected == true)
            ? BusinessSegment.corporate.name
            : null;
    return data;
  }
}

class CustomerOwnerShipInfo {
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
  int? custOwnId;
  String? custOwnershipName;
  int? custOwnershipRim;
  String? nationality;
  double? shareHoldingPercentage;
  String? resident;
  double? beneficialOwnerhipPercentage;
  String? identificationDetail;
  String? identificationNumber;
  String? createdBy;
  String? updatedBy;
  String? custOwnershipType;
  bool? isNewlyAdded;
  int? rim; // UI checkbox state: 1 = checked, 0 = unchecked
  bool hasRimInitialized = false; // UI-only flag
  bool hasRim = false; // UI-only flag

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

class CustomerException {
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
  String? type;
  String? facilityId;
  int? exceptionId, custInfoId;
  String? description;
  String? dueDate;
  String? status;
  String? recommendations;
  bool? delete;

  int? dueDateLong;

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

// --- Converters ---
CustomerType? customerTypeFromJson(dynamic value) {
  if (value == null) return null;

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

dynamic customerTypeToJson(CustomerType? value) {
  // Typically you want to send the string wire value
  return value?.name; // e.g., "belowInvestmentGradeBanks"
}
