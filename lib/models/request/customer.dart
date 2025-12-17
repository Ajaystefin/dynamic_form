import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/country.dart';
import 'package:wcas_frontend/models/request/group.dart';

class Customer {
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
  bool? isLimitWithinPolicy;
  // bool? bankProposedLimit = false;
  List<Reference>? issuedIdent;
  List<Reference>? policyDeviations;
  List<Map<String, String>>? relationshipMgr;

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

  bool isPrimary = false;
  Customer(
      {this.groups,
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
      this.isLimitWithinPolicy,
      this.residentCountry,
      this.nationality,
      this.relationshipMgr,
      this.partyStatus,
      this.tLIssueCountry,
      this.partyIdType,
      this.resident,
      this.firstName,
      this.lastName,
      this.middleName,this.customerAddress1,this.customerAddress2,this.customerGroupId,this.customerTlExpiryDate});

  String? get displayName =>
      customerName ??
      firstName ??
      preferredName ??
      lastName ??
      middleName ??
      "";

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
  String concatNonEmpty(List<String?> parts, {String sep = ''}) {
    return parts
        .map((p) => p?.trim())
        .where((p) => p != null && (p).isNotEmpty)
        .map((p) => p ?? '')
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
    return result.isNotEmpty ? result : '';
  }

  Customer.fromJson(Map<String, dynamic> json) {
    bool isValid(dynamic value) =>
        value != null && value != 'null' && value.toString().isNotEmpty;

    groups =
        isValid(json['GroupKeys']) ? Group.fromJson(json['GroupKeys']) : null;
    id = json['PartyId'];
    namePrefix = json['PartyInfo']?['PersonData']?['PersonName']
            ?['NamePrefix'] ??
        json['firstName'];
    firstName = json['PartyInfo']?['PersonData']?['PersonName']?['FirstName'] ??
        json['firstName'];
    middleName =
        json['PartyInfo']?['PersonData']?['PersonName']?['MiddleName'] ?? '';
    lastName = json['PartyInfo']?['PersonData']?['PersonName']?['LastName'] ??
        json['PartyInfo']?['PersonData']?['PersonName']?['LastNameLocalLang'] ??
        json['lastName'];
    preferredName = json['PartyInfo']?['PersonData']?['PersonName']
            ?['PreferredName'] ??
        json['preferredName'];
    tLIssueCountry = json['PartyInfo']?['TLIssueCountry'];
    resident = json['PartyInfo']?['Resident'];

    customerRimNo = int.tryParse(json['PartyId'] ?? " ") ??
        json['rimNo'] ??
        json['customerRimNumber'] ??
        json['customerRimNo'];
    customerName = json['PersonData']?['PersonName']?['LastName'] ??
        json['customerName'] ??
        json['name'] ??
        json['custName'];
    primaryBusinessActivity = json['primaryBusinessActivity'];
    existingSICCode = json['existingSICCode'];
    proposedSICCode =
        isValid(json['proposedSicCode']) ? json['proposedSicCode'] : null;

    isBorrower = json['isBorrower'];
    custInfoId = json['custInfoId'];
    applicationRefNo = json['appRefNo'] ?? json['applicationRefNo'];
    groupName = json['groupName'];
    groupId = json['groupId'];
    if (json['groupOwner'] != null) {
      groupOwner = json['groupOwner'];
    }
    legalStatus = isValid(json['legalStatus']) ? json['legalStatus'] : null;
    tradeLicenseNumber =
        isValid(json['tradeLicenseNo']) ? json['tradeLicenseNo'] : null;
    tlIssuingAuthority =
        isValid(json['tlIssuingAuthority']) ? json['tlIssuingAuthority'] : null;

    // tlExpiryDate = DateTimeUtils.intToDateTime(json['tlExpiryDate']);
    tlExpiryDate = json['tlExpiryDate'];
    establishmentDate = json['establishmentDate'];
    relatnStartDate = json['cbdRltnStartDate'];
    borrowRelationShipDate = json['borrowRltnFrom'];

    industryDescription = json['industryDescription'];
    industrySicCode = json['industryCbdSicCode'];
    incorporateCountry = isValid(json['countryOfIncorporation'])
        ? json['countryOfIncorporation']
        : null;

    healthCode = json['healthCode'];
    purpose = json['purpose'];
    cccStatus = isValid(json['cccStatus']) ? json['cccStatus'] : null;
    locationAddress =
        isValid(json['locationAddress']) ? json['locationAddress'] : null;
    correspondanceAddress = isValid(json['correspondenceAddress'])
        ? json['correspondenceAddress']
        : null;

    createdDate = json['createdDate'];
    createdBy = json['createdBy'];
    updatedDate = json['updatedDate'];
    updatedBy = json['updatedBy'];
    cbrbClassification =
        isValid(json['cbrbClassification']) ? json['cbrbClassification'] : null;

    cbdCBRBClassification = isValid(json['cbdCBRBClassification'])
        ? json['cbdCBRBClassification']
        : null;
    if (json['ifrsStaging'] != null) {
      ifrsStaging = json['ifrsStaging'];
    }
    if (json['deviationJustification'] != null) {
      deviationBreachJustification = json['deviationJustification'];
    }
    partyIdType = json['PartyInfo']?['PartyIdType'] ??
        json['PartyIdType'];
    worldRank = isValid(json['worldRank']) ? json['worldRank'] : null;
    countryRank = isValid(json['countryRank']) ? json['countryRank'] : null;
    category = isValid(json['category']) ? json['category'] : null;
    poBox = isValid(json['poBox']) ? json['poBox'] : null;
    addressLine1 = isValid(json['addressLine1']) ? json['addressLine1'] : null;
    addressLine2 = isValid(json['addressLine2']) ? json['addressLine2'] : null;
    addressLine3 = isValid(json['addressLine3']) ? json['addressLine3'] : null;
    emailAddress = isValid(json['emailAddress']) ? json['emailAddress'] : null;
    phone = isValid(json['phone']) ? json['phone'] : null;
    residentCountry = json['PartyInfo']?['ResidentCountry']?.trim();
    customerAddress1=isValid(json['PartyInfo']?['PersonData']['Contact']['Locator']['PostAddr']['Addr1']) ? (json['PartyInfo']?['PersonData']['Contact']['Locator']['PostAddr']['Addr1']) : null;
    customerAddress2=isValid(json['PartyInfo']?['PersonData']['Contact']['Locator']['PostAddr']['Addr2']) ? (json['PartyInfo']?['PersonData']['Contact']['Locator']['PostAddr']['Addr2']) : null;
    // customerGroupId= json['GroupKeys']['GroupId'];
    customerTlExpiryDate=json['PartyInfo']?['TLExpiryDt'];
    nationality =
        (json['Nationality'] as List?)?.map((e) => e.toString()).toList();
    if (json['reasonForWaiver'] != null) {
      reasonForWaiver = json['reasonForWaiver'];
    }

    if (json['countriesTradedWith'] != null) {
      final raw = json['countriesTradedWith'];
      if (raw is String) {
        final list = raw.split(',').map((e) => e.trim()).toList();
        countriesTradedWith = list.map((e) => Country(description: e)).toList();
      }
    }
    if (json['countryOfBusiness'] != null) {
      final raw = json['countryOfBusiness'];
      if (raw is String) {
        final list = raw.split(',').map((e) => e.trim()).toList();
        countriesofBussinessOperation =
            list.map((e) => Country(description: e)).toList();
      }
    }
    if (json['countryOfRisk'] != null) {
      final raw = json['countryOfRisk'];
      if (raw is String) {
        final list = raw.split(',').map((e) => e.trim()).toList();
        countryRiskWith = list.map((e) => Country(description: e)).toList();
      }
    }
    if (json['policyDeviation'] != null) {
      final raw = json['policyDeviation'];
      if (raw is String) {
        final list = raw.split(',').map((e) => e.trim()).toList();
        policyDeviations = list.map((e) => Reference(name: e)).toList();
      }
    }

    if (json['isLimitWithinPolicy'] != null) {
      isLimitWithinPolicy = json['isLimitWithinPolicy'];
    }
    borrowRelnDateEditable = json['borrowRelnDateEditable'];
    isBorrowerBelowGrade = json['isBorrowerBelowGrade'];

    // Handle issuedIdent
    if (json['PartyInfo'] != null) {
      final issued = json['PartyInfo']?['IssuedIdent'];
      if (issued != null && issued is List) {
        issuedIdent = issued
            .map<Reference>((item) => Reference(
                  name: item['IssuedIdentName'] ?? '',
                  description: item['IssuedIdentValue'] ?? '',
                ))
            .toList();
      }
      if (json['PartyInfo']?["OriginatingBranchCode"] != null) {
        branchCode = json['PartyInfo']?["OriginatingBranchCode"];
      }
      if (json['PartyInfo']?["Segmentation"] != null) {
        if (json['PartyInfo']?["Segmentation"]["SegmentDesc"] != null) {
          segment = json['PartyInfo']?["Segmentation"]["SegmentDesc"];
        }
      }
      if (json['PartyInfo']?["OriginatingBranchName"] != null) {
        if (json['PartyInfo']?["OriginatingBranchName"] != null) {
          branch = json['PartyInfo']?["OriginatingBranchName"];
        }
      }

      if (json['PartyInfo']?["PartyStatus"] != null) {
        if (json['PartyInfo']?["PartyStatus"] != null) {
          partyStatus = json['PartyInfo']?["PartyStatus"];
        }
      }

      // Parse RelationshipMgr list from PartyInfo

      final relationshipManagersJson = json['PartyInfo']?['RelationshipMgr'];
      if (relationshipManagersJson is List) {
        relationshipMgr =
            relationshipManagersJson.map<Map<String, String>>((managerJson) {
          return {
            'RelationshipMgrIdent':
                managerJson['RelationshipMgrIdent']?.toString() ?? '',
            'RelationshipMgrName':
                managerJson['RelationshipMgrName']?.toString() ?? '',
          };
        }).toList();
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (groups != null) {
      data['GroupKeys'] = groups!.toJson();
    }
    data['PartyId'] = id;
    data['rimNo'] = customerRimNo;
    data['primaryBusinessActivity'] = primaryBusinessActivity;
    data['customerName'] = customerName;
    data['existingSICCode'] = existingSICCode;
    data['proposedSicCode'] = proposedSICCode;
    // data['isBorrower'] = isBorrower;
    data['custInfoId'] = custInfoId;
    data['appRefNo'] = applicationRefNo;
    data['groupName'] = groupName;
    data['groupId'] = groupId;
    data['legalStatus'] = legalStatus;
    data['tradeLicenseNo'] = tradeLicenseNumber;
    data['tlIssuingAuthority'] = tlIssuingAuthority;
    data['tlExpiryDate'] = tlExpiryDate;
    data['industryDescription'] = industryDescription;
    data['industryCbdSicCode'] = industrySicCode;
    data['countryOfIncorporation'] = incorporateCountry;
    data['countryOfBusiness'] = countriesofBussinessOperation;
    data['establishmentDate'] = establishmentDate;
    data['cbdRltnStartDate'] = relatnStartDate;
    data['borrowRltnFrom'] = borrowRelationShipDate;
    // data['healthCode'] = healthCode;
    // data['purpose'] = purpose;
    data['cccStatus'] = cccStatus;
    data['locationAddress'] = locationAddress;
    data['correspondanceAddress'] = correspondanceAddress;

    data['createdDate'] = createdDate;
    data['createdBy'] = createdBy;
    data['updatedDate'] = updatedDate;
    data['updatedBy'] = updatedBy;
    data['cbrbClasification'] = cbrbClassification;
    // data['tradedCountryList'] = tradedCountry;
    // data['countryOfRisk'] = countryOfRisk;
    data['cbdCBRBClassification'] = cbdCBRBClassification;
    // data['borrowRelnDateEditable'] = borrowRelnDateEditable;
    // data['isBorrowerBelowGrade'] = isBorrowerBelowGrade;
    data['ifrsStaging'] = ifrsStaging;
    data['deviationJustification'] = deviationBreachJustification;
    data['policyDeviation'] = policyDeviations;
    data['worldRank'] = worldRank;
    data['countryRank'] = countryRank;
    data['category'] = category;
    data['countriesTradedWith'] = countriesTradedWith;
    data['poBox'] = poBox;
    data['addressLine1'] = addressLine1;
    data['addressLine2'] = addressLine2;
    data['addressLine3'] = addressLine3 ?? 'DUBAI';
    data['emailAddress'] = emailAddress;
    data['phone'] = phone;
    data['reasonForWaiver'] = reasonForWaiver;
    data['cbrbClassification'] = cbrbClassification;
    data['isLimitWithinPolicy'] = isLimitWithinPolicy;
    return data;
  }

  Map<String, dynamic> toSaveJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    //final df = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

    if (groups != null) {
      data['GroupKeys'] = groups!.toJson();
    }

    data['PartyId'] = id;
    data['custInfoId'] = custInfoId;
    data['appRefNo'] = applicationRefNo;
    data['rimNo'] = customerRimNo;
    // data['business_segment'] = businessSegment;
    data['customerName'] = customerName;
    data['groupName'] = groupName;
    data['groupId'] = groupId;
    // data['groupOwner'] = groupOwner;

    if (primaryBusinessActivity != null) {
      data['primaryBusinessActivity'] = primaryBusinessActivity;
    }
    if (legalStatus != null) data['legalStatus'] = legalStatus;
    if (tradeLicenseNumber != null) data['tradeLicenseNo'] = tradeLicenseNumber;
    if (tlIssuingAuthority != null) {
      data['tlIssuingAuthority'] = tlIssuingAuthority;
    }

    data['industryDescription'] = industryDescription;
    data['industryCbdSicCode'] = industrySicCode;
    data['countryOfIncorporation'] = incorporateCountry;

    data['tlExpiryDate'] = tlExpiryDateLong;
    data['establishmentDate'] = establishmentDateLong;
    data['cbdRltnStartDate'] = relatnStartDateLong;
    data['borrowRltnFrom'] = borrowRelationShipDateLong;

    if (countriesofBussinessOperation != null &&
        countriesofBussinessOperation!.isNotEmpty) {
      data['countryOfBusiness'] =
          countriesofBussinessOperation!.map((e) => e.description).join(', ');
    }

    if (countryRiskWith != null && countryRiskWith!.isNotEmpty) {
      data['countryOfRisk'] =
          countryRiskWith!.map((e) => e.description).join(', ');
    }

    if (countriesTradedWith != null && countriesTradedWith!.isNotEmpty) {
      data['countriesTradedWith'] =
          countriesTradedWith!.map((e) => e.description).join(', ');
    }

    if (policyDeviations != null && policyDeviations!.isNotEmpty) {
      data['policyDeviation'] = policyDeviations!.map((e) => e.name).join(', ');
    }

    data['cbdCBRBClassification'] = cbdCBRBClassification;
    data['cbrbClassification'] = cbrbClassification;

    data['purposeCode'] = purpose;
    data['healthCode'] = healthCode;
    data['locationAddress'] = locationAddress;
    data['correspondenceAddress'] = correspondanceAddress;
    data['poBox'] = poBox;
    data['addressLine1'] = addressLine1;
    data['addressLine2'] = addressLine2;
    data['addressLine3'] = addressLine3 ?? 'DUBAI';
    data['emailAddress'] = emailAddress;
    data['phone'] = phone;
    data['cccStatus'] = cccStatus;
    // data['isPrimary'] = isPrimary;
    // data['isCoBorrower'] = isCoBorrower == true ? 1 : 0;
    data['proposedSicCode'] = proposedSICCode;
    data['ifrsStaging'] = ifrsStaging;
    // data['cusType'] = customerType;

    data['deviationJustification'] = deviationBreachJustification;
    data['reasonForWaiver'] = reasonForWaiver;
    data['worldRank'] = worldRank;
    data['isLimitWithinPolicy'] = isLimitWithinPolicy;
    data['countryRank'] = countryRank;
    return data;
  }

  //This to save json working on Save Application if change any thing not working.
  Map<String, dynamic> toSaveBorrowerJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    //final df = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    if (groups != null) {
      data['groupName'] = groups?.name ?? "0";
      data['groupId'] =
          (groups?.id != null && groups?.id.toString().toLowerCase() != 'null')
              ? int.tryParse(groups?.id.toString() ?? '0') ?? 0
              : 0;
      data['groupOwner'] = groups?.groupOwner ?? 0;
      data['groupStatus'] = "Active";
    }
    data['customerRimNo'] = customerRimNo;
    // data['customerName'] = displayName ?? '';
    data['firstName'] = concatCustomerFullName;
    data['middleName'] = concatCustomerFullName;
    data['lastName'] = concatCustomerFullName;
    data['preferredName'] = concatCustomerFullName;
    data['customerStatus'] = "Active";
    return data;
  }
}

class CustomerOwnerShipInfo {
  int? custOwnId;
  String? custOwnershipName;
  int? custOwnershipRim;
  int? rim;
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
  });

  CustomerOwnerShipInfo.fromJson(Map<String, dynamic> json) {
    custOwnId = json['custOwnershipId'];
    custOwnershipName = json['custOwnerName'];
    custOwnershipRim = json['custOwnerRim'];
    rim = json['custInfoId'];
    nationality = json['nationality'];
    shareHoldingPercentage = json['shareHoldingPerc'];
    resident = json['resident'];
    beneficialOwnerhipPercentage = json['beneficialOwnershipPerc'];
    identificationDetail = json['identificationDetails'];
    identificationNumber = json['identificationNumber'];
    createdBy = json['createdBy'];
    updatedBy = json['updatedBy'];
    custOwnershipType = json['custOwnerType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['custOwnershipId'] = custOwnId;
    data['custOwnerName'] = custOwnershipName;
    data['custOwnerRim'] = custOwnershipRim;
    data['custInfoId'] = rim;
    data['nationality'] = nationality;
    data['shareHoldingPerc'] = shareHoldingPercentage;
    data['resident'] = resident;
    data['beneficialOwnershipPerc'] = beneficialOwnerhipPercentage;
    data['identificationDetails'] = identificationDetail;
    data['identificationNumber'] = identificationNumber;
    data['createdBy'] = createdBy;
    data['updatedBy'] = updatedBy;
    data['custOwnerType'] = custOwnershipType;
    return data;
  }
}

class CustomerException {
  String? type;
  String? facilityId;
  int? exceptionId, custInfoId;
  String? description;
  String? dueDate;
  String? status;
  String? recommendations;
  bool? delete;

  int? dueDateLong;

  CustomerException(
      {this.type,
      this.facilityId,
      this.exceptionId,
      this.custInfoId,
      this.description,
      this.dueDate,
      this.status,
      this.recommendations,
      this.delete});

  CustomerException.fromJson(Map<String, dynamic> json) {
    exceptionId = json['exceptionId'];
    custInfoId = json['custInfoId'];
    type = json['typeCode'];
    facilityId = json['facility'];
    description = json['exceptionDescription'];
    dueDate = json['dueDate'];
    status = json['status'];
    recommendations = json['recommendation'];
    delete = json['delete'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['exceptionId'] = exceptionId;
    data['custInfoId'] = custInfoId;
    data['typeCode'] = type;
    data['facility'] = facilityId;
    data['exceptionDescription'] = description;
    data['dueDate'] = dueDateLong;
    data['status'] = status;
    data['recommendation'] = recommendations;
    data['delete'] = delete;
    return data;
  }
}
