class GroupBorrowerSearchResponse {
  final ResponseData? responseData;
  GroupBorrowerSearchResponse({this.responseData});
  factory GroupBorrowerSearchResponse.fromJson(Map<String, dynamic> json) {
    return GroupBorrowerSearchResponse(
      responseData: json['responseData'] != null
          ? ResponseData.fromJson(json['responseData'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'responseData': responseData?.toJson(),
    };
  }
}

class ResponseData {
  final String? partyId;
  final PartyInfo? partyInfo;
  final GroupKeys? groupKeys;
  ResponseData({
    this.partyId,
    this.partyInfo,
    this.groupKeys,
  });
  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      partyId: json['PartyId'] as String?,
      partyInfo: json['PartyInfo'] != null
          ? PartyInfo.fromJson(json['PartyInfo'])
          : null,
      groupKeys: json['GroupKeys'] != null
          ? GroupKeys.fromJson(json['GroupKeys'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'PartyId': partyId,
      'PartyInfo': partyInfo?.toJson(),
      'GroupKeys': groupKeys?.toJson(),
    };
  }
}

class PartyInfo {
  final String? partyIdType;
  final String? classCode;
  final String? classCodeDesc;
  final String? partyStatus;
  final String? originatingBranchCode;
  final String? originatingBranchName;
  final String? issuingAuthority;
  final String? annualTurnover;
  final String? idType;
  final String? netWorth;
  final String? organizationType;
  final String? commercialActivity;
  final String? registrationOffice;
  final String? listedStockExchange;
  final String? stockMarket;
  final String? emplCategory;
  final String? monthlyDeposit;
  final String? pepCategoryId;
  final PersonData? personData;
  final String? birthDt;
  final String? cbdRelationshipStartDate;
  final String? birthPlace;
  final String? gender;
  final String? qualification;
  final String? maritalStat;
  final String? occupation;
  final String? dependents;
  final List<IssuedIdent> issuedIdent;
  final String? passportIssuedDt;
  final String? tlExpiryDt;
  final String? passportIssuedCountryCode;
  final String? passportIssuedCity;
  final String? emiratesIDExpiryDt;
  final String? visaExpiryDt;
  final List<String?> nationality;
  final Segmentation? segmentation;
  final String? resident;
  final String? residentCountry;
  final FatcaDetails? fatcaDetails;
  final PartyAffiliateData? partyAffiliateData;
  final FinancialData? financialData;
  final String? openReason;
  final List<RelationshipMgr> relationshipMgr;
  final String? preferredLang;
  final CreditRisk? creditRisk;
  final String? formW8;
  final String? formW9;
  final String? politicallyExposed;
  final String? tlIssueCountry;
  final String? pepCategory;
  PartyInfo({
    this.partyIdType,
    this.classCode,
    this.classCodeDesc,
    this.partyStatus,
    this.originatingBranchCode,
    this.originatingBranchName,
    this.issuingAuthority,
    this.annualTurnover,
    this.idType,
    this.netWorth,
    this.organizationType,
    this.commercialActivity,
    this.registrationOffice,
    this.listedStockExchange,
    this.stockMarket,
    this.emplCategory,
    this.monthlyDeposit,
    this.pepCategoryId,
    this.personData,
    this.birthDt,
    this.cbdRelationshipStartDate,
    this.birthPlace,
    this.gender,
    this.qualification,
    this.maritalStat,
    this.occupation,
    this.dependents,
    List<IssuedIdent>? issuedIdent,
    this.passportIssuedDt,
    this.tlExpiryDt,
    this.passportIssuedCountryCode,
    this.passportIssuedCity,
    this.emiratesIDExpiryDt,
    this.visaExpiryDt,
    List<String?>? nationality,
    this.segmentation,
    this.resident,
    this.residentCountry,
    this.fatcaDetails,
    this.partyAffiliateData,
    this.financialData,
    this.openReason,
    List<RelationshipMgr>? relationshipMgr,
    this.preferredLang,
    this.creditRisk,
    this.formW8,
    this.formW9,
    this.politicallyExposed,
    this.tlIssueCountry,
    this.pepCategory,
  })  : issuedIdent = issuedIdent ?? const [],
        nationality = nationality ?? const [],
        relationshipMgr = relationshipMgr ?? const [];
  factory PartyInfo.fromJson(Map<String, dynamic> json) {
    return PartyInfo(
      partyIdType: json['PartyIdType'] as String?,
      classCode: json['ClassCode'] as String?,
      classCodeDesc: json['ClassCodeDesc'] as String?,
      partyStatus: json['PartyStatus'] as String?,
      originatingBranchCode: json['OriginatingBranchCode'] as String?,
      originatingBranchName: json['OriginatingBranchName'] as String?,
      issuingAuthority: json['IssuingAuthority'] as String?,
      annualTurnover: json['AnnualTurnover'] as String?,
      idType: json['IdType'] as String?,
      netWorth: json['NetWorth'] as String?,
      organizationType: json['OrganizationType'] as String?,
      commercialActivity: json['CommercialActivity'] as String?,
      registrationOffice: json['RegistrationOffice'] as String?,
      listedStockExchange: json['ListedStockExchange'] as String?,
      stockMarket: json['StockMarket'] as String?,
      emplCategory: json['EmplCategory'] as String?,
      monthlyDeposit: json['MonthlyDeposit'] as String?,
      pepCategoryId: json['PepCategoryId'] as String?,
      personData:
          json['PersonData'] != null ? PersonData.fromJson(json['PersonData']) : null,
      birthDt: json['BirthDt'] as String?,
      cbdRelationshipStartDate: json['CBDRelationshipStartDate'] as String?,
      birthPlace: json['BirthPlace'] as String?,
      gender: json['Gender'] as String?,
      qualification: json['Qualification'] as String?,
      maritalStat: json['MaritalStat'] as String?,
      occupation: json['Occupation'] as String?,
      dependents: json['Dependents'] as String?,

      // list of IssuedIdent
      issuedIdent: (json['IssuedIdent'] is List)
          ? (json['IssuedIdent'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => IssuedIdent.fromJson(e))
              .toList(growable: false)
          : const [],

      passportIssuedDt: json['PassportIssuedDt'] as String?,
      tlExpiryDt: json['TLExpiryDt'] as String?,
      passportIssuedCountryCode: json['PassportIssuedCountryCode'] as String?,
      passportIssuedCity: json['PassportIssuedCity'] as String?,
      emiratesIDExpiryDt: json['EmiratesIDExpiryDt'] as String?,
      visaExpiryDt: json['VisaExpiryDt'] as String?,

      // list of String?
      nationality: (json['Nationality'] is List)
          ? (json['Nationality'] as List)
              .map((e) => e?.toString())
              .toList(growable: false)
          : const [],

      segmentation: json['Segmentation'] != null
          ? Segmentation.fromJson(json['Segmentation'])
          : null,
      resident: json['Resident'] as String?,
      residentCountry: json['ResidentCountry'] as String?,
      fatcaDetails: json['FatcaDetails'] != null
          ? FatcaDetails.fromJson(json['FatcaDetails'])
          : null,
      partyAffiliateData: json['PartyAffiliateData'] != null
          ? PartyAffiliateData.fromJson(json['PartyAffiliateData'])
          : null,
      financialData: json['FinancialData'] != null
          ? FinancialData.fromJson(json['FinancialData'])
          : null,
      openReason: json['OpenReason'] as String?,

      // list of RelationshipMgr
      relationshipMgr: (json['RelationshipMgr'] is List)
          ? (json['RelationshipMgr'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => RelationshipMgr.fromJson(e))
              .toList(growable: false)
          : const [],

      preferredLang: json['PreferredLang'] as String?,
      creditRisk:
          json['CreditRisk'] != null ? CreditRisk.fromJson(json['CreditRisk']) : null,
      formW8: json['FormW8'] as String?,
      formW9: json['FormW9'] as String?,
      politicallyExposed: json['PoliticallyExposed'] as String?,
      tlIssueCountry: json['TLIssueCountry'] as String?,
      pepCategory: json['PepCategory'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'PartyIdType': partyIdType,
      'ClassCode': classCode,
      'ClassCodeDesc': classCodeDesc,
      'PartyStatus': partyStatus,
      'OriginatingBranchCode': originatingBranchCode,
      'OriginatingBranchName': originatingBranchName,
      'IssuingAuthority': issuingAuthority,
      'AnnualTurnover': annualTurnover,
      'IdType': idType,
      'NetWorth': netWorth,
      'OrganizationType': organizationType,
      'CommercialActivity': commercialActivity,
      'RegistrationOffice': registrationOffice,
      'ListedStockExchange': listedStockExchange,
      'StockMarket': stockMarket,
      'EmplCategory': emplCategory,
      'MonthlyDeposit': monthlyDeposit,
      'PepCategoryId': pepCategoryId,
      'PersonData': personData?.toJson(),
      'BirthDt': birthDt,
      'CBDRelationshipStartDate': cbdRelationshipStartDate,
      'BirthPlace': birthPlace,
      'Gender': gender,
      'Qualification': qualification,
      'MaritalStat': maritalStat,
      'Occupation': occupation,
      'Dependents': dependents,
      'IssuedIdent': issuedIdent.map((e) => e.toJson()).toList(),
      'PassportIssuedDt': passportIssuedDt,
      'TLExpiryDt': tlExpiryDt,
      'PassportIssuedCountryCode': passportIssuedCountryCode,
      'PassportIssuedCity': passportIssuedCity,
      'EmiratesIDExpiryDt': emiratesIDExpiryDt,
      'VisaExpiryDt': visaExpiryDt,
      'Nationality': nationality,
      'Segmentation': segmentation?.toJson(),
      'Resident': resident,
      'ResidentCountry': residentCountry,
      'FatcaDetails': fatcaDetails?.toJson(),
      'PartyAffiliateData': partyAffiliateData?.toJson(),
      'FinancialData': financialData?.toJson(),
      'OpenReason': openReason,
      'RelationshipMgr': relationshipMgr.map((e) => e.toJson()).toList(),
      'PreferredLang': preferredLang,
      'CreditRisk': creditRisk?.toJson(),
      'FormW8': formW8,
      'FormW9': formW9,
      'PoliticallyExposed': politicallyExposed,
      'TLIssueCountry': tlIssueCountry,
      'PepCategory': pepCategory,
    };
  }
}

class PersonData {
  final PersonName? personName;
  final Contact? contact;
  PersonData({this.personName, this.contact});
  factory PersonData.fromJson(Map<String, dynamic> json) {
    return PersonData(
      personName: json['PersonName'] != null
          ? PersonName.fromJson(json['PersonName'])
          : null,
      contact:
          json['Contact'] != null ? Contact.fromJson(json['Contact']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'PersonName': personName?.toJson(),
      'Contact': contact?.toJson(),
    };
  }
}

class PersonName {
  final String? namePrefix;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? firstNameLocalLang;
  final String? middleNameLocalLang;
  final String? lastNameLocalLang;
  final String? preferredName;
  final String? paternalName;
  final String? maternalName;
  PersonName({
    this.namePrefix,
    this.firstName,
    this.middleName,
    this.lastName,
    this.firstNameLocalLang,
    this.middleNameLocalLang,
    this.lastNameLocalLang,
    this.preferredName,
    this.paternalName,
    this.maternalName,
  });
  factory PersonName.fromJson(Map<String, dynamic> json) {
    return PersonName(
      namePrefix: json['NamePrefix'] as String?,
      firstName: json['FirstName'] as String?,
      middleName: json['MiddleName'] as String?,
      lastName: json['LastName'] as String?,
      firstNameLocalLang: json['FirstNameLocalLang'] as String?,
      middleNameLocalLang: json['MiddleNameLocalLang'] as String?,
      lastNameLocalLang: json['LastNameLocalLang'] as String?,
      preferredName: json['PreferredName'] as String?,
      paternalName: json['PaternalName'] as String?,
      maternalName: json['MaternalName'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'NamePrefix': namePrefix,
      'FirstName': firstName,
      'MiddleName': middleName,
      'LastName': lastName,
      'FirstNameLocalLang': firstNameLocalLang,
      'MiddleNameLocalLang': middleNameLocalLang,
      'LastNameLocalLang': lastNameLocalLang,
      'PreferredName': preferredName,
      'PaternalName': paternalName,
      'MaternalName': maternalName,
    };
  }
}

class Contact {
  final Locator? locator;
  Contact({this.locator});
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      locator:
          json['Locator'] != null ? Locator.fromJson(json['Locator']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'Locator': locator?.toJson(),
    };
  }
}

class Locator {
  final PostAddr? postAddr;
  final List<PhoneNum> phoneNum;
  final List<Email> email;
  Locator({
    this.postAddr,
    List<PhoneNum>? phoneNum,
    List<Email>? email,
  })  : phoneNum = phoneNum ?? const [],
        email = email ?? const [];
  factory Locator.fromJson(Map<String, dynamic> json) {
    return Locator(
      postAddr:
          json['PostAddr'] != null ? PostAddr.fromJson(json['PostAddr']) : null,

      // list of PhoneNum
      phoneNum: (json['PhoneNum'] is List)
          ? (json['PhoneNum'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => PhoneNum.fromJson(e))
              .toList(growable: false)
          : const [],

      // list of Email
      email: (json['Email'] is List)
          ? (json['Email'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => Email.fromJson(e))
              .toList(growable: false)
          : const [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'PostAddr': postAddr?.toJson(),
      'PhoneNum': phoneNum.map((e) => e.toJson()).toList(),
      'Email': email.map((e) => e.toJson()).toList(),
    };
  }
}

class PostAddr {
  final String? addressIdent;
  final String? addr1;
  final String? addr2;
  final String? addr3;
  final String? city;
  final String? country;
  final String? postalCode;
  PostAddr({
    this.addressIdent,
    this.addr1,
    this.addr2,
    this.addr3,
    this.city,
    this.country,
    this.postalCode,
  });
  factory PostAddr.fromJson(Map<String, dynamic> json) {
    return PostAddr(
      addressIdent: json['AddressIdent'] as String?,
      addr1: json['Addr1'] as String?,
      addr2: json['Addr2'] as String?,
      addr3: json['Addr3'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['PostalCode'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'AddressIdent': addressIdent,
      'Addr1': addr1,
      'Addr2': addr2,
      'Addr3': addr3,
      'city': city,
      'country': country,
      'PostalCode': postalCode,
    };
  }
}

class PhoneNum {
  final String? phoneType;
  final String? phone;
  PhoneNum({this.phoneType, this.phone});
  factory PhoneNum.fromJson(Map<String, dynamic> json) {
    return PhoneNum(
      phoneType: json['PhoneType'] as String?,
      phone: json['Phone'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'PhoneType': phoneType,
      'Phone': phone,
    };
  }
}

// Email entry
class Email {
  final String? emailType;
  final String? emailAddr;
  Email({this.emailType, this.emailAddr});
  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      emailType: json['EmailType'] as String?,
      emailAddr: json['EmailAddr'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'EmailType': emailType,
      'EmailAddr': emailAddr,
    };
  }
}

// IssuedIdent entry
class IssuedIdent {
  final String? issuedIdentName;
  final String? issuedIdentValue;
  IssuedIdent({this.issuedIdentName, this.issuedIdentValue});
  factory IssuedIdent.fromJson(Map<String, dynamic> json) {
    return IssuedIdent(
      issuedIdentName: json['IssuedIdentName'] as String?,
      issuedIdentValue: json['IssuedIdentValue'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'IssuedIdentName': issuedIdentName,
      'IssuedIdentValue': issuedIdentValue,
    };
  }
}

// Segmentation object
class Segmentation {
  final String? segmentDesc;
  Segmentation({this.segmentDesc});
  factory Segmentation.fromJson(Map<String, dynamic> json) {
    return Segmentation(
      segmentDesc: json['SegmentDesc'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'SegmentDesc': segmentDesc,
    };
  }
}

// FatcaDetails object
class FatcaDetails {
  final String? tin;
  final String? ssn;
  final String? usResidentStatus;
  FatcaDetails({this.tin, this.ssn, this.usResidentStatus});
  factory FatcaDetails.fromJson(Map<String, dynamic> json) {
    return FatcaDetails(
      tin: json['TIN'] as String?,
      ssn: json['SSN'] as String?,
      usResidentStatus: json['USResidentStatus'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'TIN': tin,
      'SSN': ssn,
      'USResidentStatus': usResidentStatus,
    };
  }
}

// PartyAffiliateData object with OrgContact
class PartyAffiliateData {
  final String? orgName;
  final String? positionHeld;
  final String? relEstablishedDt;
  final OrgContact? orgContact;
  PartyAffiliateData({
    this.orgName,
    this.positionHeld,
    this.relEstablishedDt,
    this.orgContact,
  });
  factory PartyAffiliateData.fromJson(Map<String, dynamic> json) {
    return PartyAffiliateData(
      orgName: json['OrgName'] as String?,
      positionHeld: json['PositionHeld'] as String?,
      relEstablishedDt: json['RelEstablishedDt'] as String?,
      orgContact: json['OrgContact'] != null
          ? OrgContact.fromJson(json['OrgContact'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'OrgName': orgName,
      'PositionHeld': positionHeld,
      'RelEstablishedDt': relEstablishedDt,
      'OrgContact': orgContact?.toJson(),
    };
  }
}

// OrgContact with its own Locator
class OrgContact {
  final Locator? locator;
  OrgContact({this.locator});
  factory OrgContact.fromJson(Map<String, dynamic> json) {
    return OrgContact(
      locator:
          json['Locator'] != null ? Locator.fromJson(json['Locator']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'Locator': locator?.toJson(),
    };
  }
}

// FinancialData object
class FinancialData {
  final String? financialType;
  final num? financialAmt; // may be null or numeric
  final String? relEstablishedDt;
  final String? incomeCurrency;
  FinancialData({
    this.financialType,
    this.financialAmt,
    this.relEstablishedDt,
    this.incomeCurrency,
  });
  factory FinancialData.fromJson(Map<String, dynamic> json) {
    return FinancialData(
      financialType: json['FinancialType'] as String?,
      financialAmt: json['FinancialAmt'] is num ? json['FinancialAmt'] : null,
      relEstablishedDt: json['RelEstablishedDt'] as String?,
      incomeCurrency: json['IncomeCurrency'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'FinancialType': financialType,
      'FinancialAmt': financialAmt,
      'RelEstablishedDt': relEstablishedDt,
      'IncomeCurrency': incomeCurrency,
    };
  }
}

// RelationshipMgr entry
class RelationshipMgr {
  final String? relationshipMgrIdent;
  final String? relationshipMgrName;
  RelationshipMgr({this.relationshipMgrIdent, this.relationshipMgrName});
  factory RelationshipMgr.fromJson(Map<String, dynamic> json) {
    return RelationshipMgr(
      relationshipMgrIdent: json['RelationshipMgrIdent'] as String?,
      relationshipMgrName: json['RelationshipMgrName'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'RelationshipMgrIdent': relationshipMgrIdent,
      'RelationshipMgrName': relationshipMgrName,
    };
  }
}

// CreditRisk object
class CreditRisk {
  final String? riskCategory;
  final String? internalScore;
  CreditRisk({this.riskCategory, this.internalScore});
  factory CreditRisk.fromJson(Map<String, dynamic> json) {
    return CreditRisk(
      riskCategory: json['RiskCategory'] as String?,
      internalScore: json['InternalScore'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'RiskCategory': riskCategory,
      'InternalScore': internalScore,
    };
  }
}

// GroupKeys object under responseData
class GroupKeys {
  final String? groupId;
  final String? groupOwner;
  final String? groupName;
  final String? groupStatus;
  GroupKeys({
    this.groupId,
    this.groupOwner,
    this.groupName,
    this.groupStatus,
  });
  factory GroupKeys.fromJson(Map<String, dynamic> json) {
    return GroupKeys(
      groupId: json['GroupId'] as String?,
      groupOwner: json['GroupOwner'] as String?,
      groupName: json['GroupName'] as String?,
      groupStatus: json['GroupStatus'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'GroupId': groupId,
      'GroupOwner': groupOwner,
      'GroupName': groupName,
      'GroupStatus': groupStatus,
    };
  }
}