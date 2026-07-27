/// Represents the response returned from a group borrower search.
class GroupBorrowerSearchResponse {
  /// Creates a [GroupBorrowerSearchResponse] instance.
  GroupBorrowerSearchResponse({this.responseData});

  /// Creates a [GroupBorrowerSearchResponse] instance from a JSON map.
  factory GroupBorrowerSearchResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroupBorrowerSearchResponse(
      responseData: json["responseData"] != null
          ? ResponseData.fromJson(json["responseData"])
          : null,
    );
  }

  /// Response data containing party and group information.
  final ResponseData? responseData;

  /// Converts this [GroupBorrowerSearchResponse] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "responseData": responseData?.toJson(),
    };
  }
}

/// Represents response data returned from the party information service.
class ResponseData {
  /// Creates a [ResponseData] instance.
  ResponseData({
    this.partyId,
    this.partyInfo,
    this.groupKeys,
  });

  /// Creates a [ResponseData] instance from a JSON map.
  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      partyId: json["PartyId"] as String?,
      partyInfo: json["PartyInfo"] != null
          ? PartyInfo.fromJson(json["PartyInfo"])
          : null,
      groupKeys: json["GroupKeys"] != null
          ? GroupKeys.fromJson(json["GroupKeys"])
          : null,
    );
  }

  /// Party identifier.
  final String? partyId;

  /// Party information.
  final PartyInfo? partyInfo;

  /// Group information.
  final GroupKeys? groupKeys;

  /// Converts this [ResponseData] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "PartyId": partyId,
      "PartyInfo": partyInfo?.toJson(),
      "GroupKeys": groupKeys?.toJson(),
    };
  }
}

/// Represents detailed party information including personal,
/// contact, financial, and compliance-related data.
class PartyInfo {
  /// Creates a [PartyInfo] instance.
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

  /// Creates a [PartyInfo] instance from a JSON map.
  factory PartyInfo.fromJson(Map<String, dynamic> json) {
    return PartyInfo(
      partyIdType: json["PartyIdType"] as String?,
      classCode: json["ClassCode"] as String?,
      classCodeDesc: json["ClassCodeDesc"] as String?,
      partyStatus: json["PartyStatus"] as String?,
      originatingBranchCode: json["OriginatingBranchCode"] as String?,
      originatingBranchName: json["OriginatingBranchName"] as String?,
      issuingAuthority: json["IssuingAuthority"] as String?,
      annualTurnover: json["AnnualTurnover"] as String?,
      idType: json["IdType"] as String?,
      netWorth: json["NetWorth"] as String?,
      organizationType: json["OrganizationType"] as String?,
      commercialActivity: json["CommercialActivity"] as String?,
      registrationOffice: json["RegistrationOffice"] as String?,
      listedStockExchange: json["ListedStockExchange"] as String?,
      stockMarket: json["StockMarket"] as String?,
      emplCategory: json["EmplCategory"] as String?,
      monthlyDeposit: json["MonthlyDeposit"] as String?,
      pepCategoryId: json["PepCategoryId"] as String?,
      personData: json["PersonData"] != null
          ? PersonData.fromJson(json["PersonData"])
          : null,
      birthDt: json["BirthDt"] as String?,
      cbdRelationshipStartDate: json["CBDRelationshipStartDate"] as String?,
      birthPlace: json["BirthPlace"] as String?,
      gender: json["Gender"] as String?,
      qualification: json["Qualification"] as String?,
      maritalStat: json["MaritalStat"] as String?,
      occupation: json["Occupation"] as String?,
      dependents: json["Dependents"] as String?,

      // list of IssuedIdent
      issuedIdent: (json["IssuedIdent"] is List)
          ? (json["IssuedIdent"] as List)
              .whereType<Map<String, dynamic>>()
              .map(IssuedIdent.fromJson)
              .toList(growable: false)
          : const [],

      passportIssuedDt: json["PassportIssuedDt"] as String?,
      tlExpiryDt: json["TLExpiryDt"] as String?,
      passportIssuedCountryCode: json["PassportIssuedCountryCode"] as String?,
      passportIssuedCity: json["PassportIssuedCity"] as String?,
      emiratesIDExpiryDt: json["EmiratesIDExpiryDt"] as String?,
      visaExpiryDt: json["VisaExpiryDt"] as String?,

      // list of String?
      nationality: (json["Nationality"] is List)
          ? (json["Nationality"] as List)
              .map((e) => e?.toString())
              .toList(growable: false)
          : const [],

      segmentation: json["Segmentation"] != null
          ? Segmentation.fromJson(json["Segmentation"])
          : null,
      resident: json["Resident"] as String?,
      residentCountry: json["ResidentCountry"] as String?,
      fatcaDetails: json["FatcaDetails"] != null
          ? FatcaDetails.fromJson(json["FatcaDetails"])
          : null,
      partyAffiliateData: json["PartyAffiliateData"] != null
          ? PartyAffiliateData.fromJson(json["PartyAffiliateData"])
          : null,
      financialData: json["FinancialData"] != null
          ? FinancialData.fromJson(json["FinancialData"])
          : null,
      openReason: json["OpenReason"] as String?,

      // list of RelationshipMgr
      relationshipMgr: (json["RelationshipMgr"] is List)
          ? (json["RelationshipMgr"] as List)
              .whereType<Map<String, dynamic>>()
              .map(RelationshipMgr.fromJson)
              .toList(growable: false)
          : const [],

      preferredLang: json["PreferredLang"] as String?,
      creditRisk: json["CreditRisk"] != null
          ? CreditRisk.fromJson(json["CreditRisk"])
          : null,
      formW8: json["FormW8"] as String?,
      formW9: json["FormW9"] as String?,
      politicallyExposed: json["PoliticallyExposed"] as String?,
      tlIssueCountry: json["TLIssueCountry"] as String?,
      pepCategory: json["PepCategory"] as String?,
    );
  }

  /// Party identifier type.
  final String? partyIdType;

  /// Party classification code.
  final String? classCode;

  /// Party classification description.
  final String? classCodeDesc;

  /// Party status.
  final String? partyStatus;

  /// Originating branch code.
  final String? originatingBranchCode;

  /// Originating branch name.
  final String? originatingBranchName;

  /// Issuing authority.
  final String? issuingAuthority;

  /// Annual turnover.
  final String? annualTurnover;

  /// Identification type.
  final String? idType;

  /// Net worth.
  final String? netWorth;

  /// Organization type.
  final String? organizationType;

  /// Commercial activity.
  final String? commercialActivity;

  /// Registration office.
  final String? registrationOffice;

  /// Listed stock exchange.
  final String? listedStockExchange;

  /// Stock market.
  final String? stockMarket;

  /// Employee category.
  final String? emplCategory;

  /// Monthly deposit.
  final String? monthlyDeposit;

  /// PEP category identifier.
  final String? pepCategoryId;

  /// Person data.
  final PersonData? personData;

  /// Date of birth.
  final String? birthDt;

  /// CBD relationship start date.
  final String? cbdRelationshipStartDate;

  /// Place of birth.
  final String? birthPlace;

  /// Gender.
  final String? gender;

  /// Qualification.
  final String? qualification;

  /// Marital status.
  final String? maritalStat;

  /// Occupation.
  final String? occupation;

  /// Number of dependents.
  final String? dependents;

  /// Issued identification records.
  final List<IssuedIdent> issuedIdent;

  /// Passport issue date.
  final String? passportIssuedDt;

  /// Trade license expiry date.
  final String? tlExpiryDt;

  /// Passport issuing country code.
  final String? passportIssuedCountryCode;

  /// Passport issuing city.
  final String? passportIssuedCity;

  /// Emirates ID expiry date.
  final String? emiratesIDExpiryDt;

  /// Visa expiry date.
  final String? visaExpiryDt;

  /// Nationalities.
  final List<String?> nationality;

  /// Segmentation information.
  final Segmentation? segmentation;

  /// Resident status.
  final String? resident;

  /// Resident country.
  final String? residentCountry;

  /// FATCA details.
  final FatcaDetails? fatcaDetails;

  /// Party affiliate information.
  final PartyAffiliateData? partyAffiliateData;

  /// Financial information.
  final FinancialData? financialData;

  /// Account opening reason.
  final String? openReason;

  /// Relationship managers.
  final List<RelationshipMgr> relationshipMgr;

  /// Preferred language.
  final String? preferredLang;

  /// Credit risk information.
  final CreditRisk? creditRisk;

  /// Form W-8 status.
  final String? formW8;

  /// Form W-9 status.
  final String? formW9;

  /// Politically exposed status.
  final String? politicallyExposed;

  /// Trade license issuing country.
  final String? tlIssueCountry;

  /// PEP category.
  final String? pepCategory;

  /// Converts this [PartyInfo] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "PartyIdType": partyIdType,
      "ClassCode": classCode,
      "ClassCodeDesc": classCodeDesc,
      "PartyStatus": partyStatus,
      "OriginatingBranchCode": originatingBranchCode,
      "OriginatingBranchName": originatingBranchName,
      "IssuingAuthority": issuingAuthority,
      "AnnualTurnover": annualTurnover,
      "IdType": idType,
      "NetWorth": netWorth,
      "OrganizationType": organizationType,
      "CommercialActivity": commercialActivity,
      "RegistrationOffice": registrationOffice,
      "ListedStockExchange": listedStockExchange,
      "StockMarket": stockMarket,
      "EmplCategory": emplCategory,
      "MonthlyDeposit": monthlyDeposit,
      "PepCategoryId": pepCategoryId,
      "PersonData": personData?.toJson(),
      "BirthDt": birthDt,
      "CBDRelationshipStartDate": cbdRelationshipStartDate,
      "BirthPlace": birthPlace,
      "Gender": gender,
      "Qualification": qualification,
      "MaritalStat": maritalStat,
      "Occupation": occupation,
      "Dependents": dependents,
      "IssuedIdent": issuedIdent.map((e) => e.toJson()).toList(),
      "PassportIssuedDt": passportIssuedDt,
      "TLExpiryDt": tlExpiryDt,
      "PassportIssuedCountryCode": passportIssuedCountryCode,
      "PassportIssuedCity": passportIssuedCity,
      "EmiratesIDExpiryDt": emiratesIDExpiryDt,
      "VisaExpiryDt": visaExpiryDt,
      "Nationality": nationality,
      "Segmentation": segmentation?.toJson(),
      "Resident": resident,
      "ResidentCountry": residentCountry,
      "FatcaDetails": fatcaDetails?.toJson(),
      "PartyAffiliateData": partyAffiliateData?.toJson(),
      "FinancialData": financialData?.toJson(),
      "OpenReason": openReason,
      "RelationshipMgr": relationshipMgr.map((e) => e.toJson()).toList(),
      "PreferredLang": preferredLang,
      "CreditRisk": creditRisk?.toJson(),
      "FormW8": formW8,
      "FormW9": formW9,
      "PoliticallyExposed": politicallyExposed,
      "TLIssueCountry": tlIssueCountry,
      "PepCategory": pepCategory,
    };
  }
}

/// Represents personal data information,
/// including person name and contact details.
class PersonData {
  /// Creates a [PersonData] instance.
  PersonData({
    this.personName,
    this.contact,
  });

  /// Creates a [PersonData] instance from a JSON map.
  factory PersonData.fromJson(Map<String, dynamic> json) {
    return PersonData(
      personName: json["PersonName"] != null
          ? PersonName.fromJson(json["PersonName"])
          : null,
      contact:
          json["Contact"] != null ? Contact.fromJson(json["Contact"]) : null,
    );
  }

  /// Person name information.
  final PersonName? personName;

  /// Contact information.
  final Contact? contact;

  /// Converts this [PersonData] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "PersonName": personName?.toJson(),
      "Contact": contact?.toJson(),
    };
  }
}

/// Represents a person's name information,
/// including local language and parental name details.
class PersonName {
  /// Creates a [PersonName] instance.
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

  /// Creates a [PersonName] instance from a JSON map.
  factory PersonName.fromJson(Map<String, dynamic> json) {
    return PersonName(
      namePrefix: json["NamePrefix"] as String?,
      firstName: json["FirstName"] as String?,
      middleName: json["MiddleName"] as String?,
      lastName: json["LastName"] as String?,
      firstNameLocalLang: json["FirstNameLocalLang"] as String?,
      middleNameLocalLang: json["MiddleNameLocalLang"] as String?,
      lastNameLocalLang: json["LastNameLocalLang"] as String?,
      preferredName: json["PreferredName"] as String?,
      paternalName: json["PaternalName"] as String?,
      maternalName: json["MaternalName"] as String?,
    );
  }

  /// Name prefix.
  final String? namePrefix;

  /// First name.
  final String? firstName;

  /// Middle name.
  final String? middleName;

  /// Last name.
  final String? lastName;

  /// First name in local language.
  final String? firstNameLocalLang;

  /// Middle name in local language.
  final String? middleNameLocalLang;

  /// Last name in local language.
  final String? lastNameLocalLang;

  /// Preferred name.
  final String? preferredName;

  /// Paternal name.
  final String? paternalName;

  /// Maternal name.
  final String? maternalName;

  /// Converts this [PersonName] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "NamePrefix": namePrefix,
      "FirstName": firstName,
      "MiddleName": middleName,
      "LastName": lastName,
      "FirstNameLocalLang": firstNameLocalLang,
      "MiddleNameLocalLang": middleNameLocalLang,
      "LastNameLocalLang": lastNameLocalLang,
      "PreferredName": preferredName,
      "PaternalName": paternalName,
      "MaternalName": maternalName,
    };
  }
}

/// Represents contact information.
class Contact {
  /// Creates a [Contact] instance.
  Contact({this.locator});

  /// Creates a [Contact] instance from a JSON map.
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      locator:
          json["Locator"] != null ? Locator.fromJson(json["Locator"]) : null,
    );
  }

  /// Contact locator information.
  final Locator? locator;

  /// Converts this [Contact] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "Locator": locator?.toJson(),
    };
  }
}

/// Represents contact location information,
/// including address, phone numbers, and email addresses.
class Locator {
  /// Creates a [Locator] instance.
  Locator({
    this.postAddr,
    List<PhoneNum>? phoneNum,
    List<Email>? email,
  })  : phoneNum = phoneNum ?? const [],
        email = email ?? const [];

  /// Creates a [Locator] instance from a JSON map.
  factory Locator.fromJson(Map<String, dynamic> json) {
    return Locator(
      postAddr:
          json["PostAddr"] != null ? PostAddr.fromJson(json["PostAddr"]) : null,

      // list of PhoneNum
      phoneNum: (json["PhoneNum"] is List)
          ? (json["PhoneNum"] as List)
              .whereType<Map<String, dynamic>>()
              .map(PhoneNum.fromJson)
              .toList(growable: false)
          : const [],

      // list of Email
      email: (json["Email"] is List)
          ? (json["Email"] as List)
              .whereType<Map<String, dynamic>>()
              .map(Email.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  /// Postal address information.
  final PostAddr? postAddr;

  /// Phone numbers.
  final List<PhoneNum> phoneNum;

  /// Email addresses.
  final List<Email> email;

  /// Converts this [Locator] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "PostAddr": postAddr?.toJson(),
      "PhoneNum": phoneNum.map((e) => e.toJson()).toList(),
      "Email": email.map((e) => e.toJson()).toList(),
    };
  }
}

/// Represents a postal address.
class PostAddr {
  /// Creates a [PostAddr] instance.
  PostAddr({
    this.addressIdent,
    this.addr1,
    this.addr2,
    this.addr3,
    this.city,
    this.country,
    this.postalCode,
  });

  /// Creates a [PostAddr] instance from a JSON map.
  factory PostAddr.fromJson(Map<String, dynamic> json) {
    return PostAddr(
      addressIdent: json["AddressIdent"] as String?,
      addr1: json["Addr1"] as String?,
      addr2: json["Addr2"] as String?,
      addr3: json["Addr3"] as String?,
      city: json["city"] as String?,
      country: json["country"] as String?,
      postalCode: json["PostalCode"] as String?,
    );
  }

  /// Address identifier.
  final String? addressIdent;

  /// Address line 1.
  final String? addr1;

  /// Address line 2.
  final String? addr2;

  /// Address line 3.
  final String? addr3;

  /// City.
  final String? city;

  /// Country.
  final String? country;

  /// Postal code.
  final String? postalCode;

  /// Converts this [PostAddr] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "AddressIdent": addressIdent,
      "Addr1": addr1,
      "Addr2": addr2,
      "Addr3": addr3,
      "city": city,
      "country": country,
      "PostalCode": postalCode,
    };
  }
}

/// Represents a phone number and its associated type.
class PhoneNum {
  /// Creates a [PhoneNum] instance.
  PhoneNum({
    this.phoneType,
    this.phone,
  });

  /// Creates a [PhoneNum] instance from a JSON map.
  factory PhoneNum.fromJson(Map<String, dynamic> json) {
    return PhoneNum(
      phoneType: json["PhoneType"] as String?,
      phone: json["Phone"] as String?,
    );
  }

  /// Phone type.
  final String? phoneType;

  /// Phone number.
  final String? phone;

  /// Converts this [PhoneNum] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "PhoneType": phoneType,
      "Phone": phone,
    };
  }
}

/// Represents an email address and its associated type.
class Email {
  /// Creates an [Email] instance.
  Email({
    this.emailType,
    this.emailAddr,
  });

  /// Creates an [Email] instance from a JSON map.
  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      emailType: json["EmailType"] as String?,
      emailAddr: json["EmailAddr"] as String?,
    );
  }

  /// Email type.
  final String? emailType;

  /// Email address.
  final String? emailAddr;

  /// Converts this [Email] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "EmailType": emailType,
      "EmailAddr": emailAddr,
    };
  }
}

/// Represents an issued identification record.
class IssuedIdent {
  /// Creates an [IssuedIdent] instance.
  IssuedIdent({
    this.issuedIdentName,
    this.issuedIdentValue,
  });

  /// Creates an [IssuedIdent] instance from a JSON map.
  factory IssuedIdent.fromJson(Map<String, dynamic> json) {
    return IssuedIdent(
      issuedIdentName: json["IssuedIdentName"] as String?,
      issuedIdentValue: json["IssuedIdentValue"] as String?,
    );
  }

  /// Issued identification name.
  final String? issuedIdentName;

  /// Issued identification value.
  final String? issuedIdentValue;

  /// Converts this [IssuedIdent] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "IssuedIdentName": issuedIdentName,
      "IssuedIdentValue": issuedIdentValue,
    };
  }
}

/// Represents customer segmentation information.
class Segmentation {
  /// Creates a [Segmentation] instance.
  Segmentation({this.segmentDesc});

  /// Creates a [Segmentation] instance from a JSON map.
  factory Segmentation.fromJson(Map<String, dynamic> json) {
    return Segmentation(
      segmentDesc: json["SegmentDesc"] as String?,
    );
  }

  /// Segment description.
  final String? segmentDesc;

  /// Converts this [Segmentation] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "SegmentDesc": segmentDesc,
    };
  }
}

/// Represents FATCA (Foreign Account Tax Compliance Act)
/// details for a customer.
class FatcaDetails {
  /// Creates a [FatcaDetails] instance.
  FatcaDetails({
    this.tin,
    this.ssn,
    this.usResidentStatus,
  });

  /// Creates a [FatcaDetails] instance from a JSON map.
  factory FatcaDetails.fromJson(Map<String, dynamic> json) {
    return FatcaDetails(
      tin: json["TIN"] as String?,
      ssn: json["SSN"] as String?,
      usResidentStatus: json["USResidentStatus"] as String?,
    );
  }

  /// Taxpayer Identification Number.
  final String? tin;

  /// Social Security Number.
  final String? ssn;

  /// US resident status.
  final String? usResidentStatus;

  /// Converts this [FatcaDetails] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "TIN": tin,
      "SSN": ssn,
      "USResidentStatus": usResidentStatus,
    };
  }
}

/// Represents affiliate party information and associated
/// organization details.
class PartyAffiliateData {
  /// Creates a [PartyAffiliateData] instance.
  PartyAffiliateData({
    this.orgName,
    this.positionHeld,
    this.relEstablishedDt,
    this.orgContact,
  });

  /// Creates a [PartyAffiliateData] instance from a JSON map.
  factory PartyAffiliateData.fromJson(Map<String, dynamic> json) {
    return PartyAffiliateData(
      orgName: json["OrgName"] as String?,
      positionHeld: json["PositionHeld"] as String?,
      relEstablishedDt: json["RelEstablishedDt"] as String?,
      orgContact: json["OrgContact"] != null
          ? OrgContact.fromJson(json["OrgContact"])
          : null,
    );
  }

  /// Organization name.
  final String? orgName;

  /// Position held in the organization.
  final String? positionHeld;

  /// Relationship established date.
  final String? relEstablishedDt;

  /// Organization contact information.
  final OrgContact? orgContact;

  /// Converts this [PartyAffiliateData] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "OrgName": orgName,
      "PositionHeld": positionHeld,
      "RelEstablishedDt": relEstablishedDt,
      "OrgContact": orgContact?.toJson(),
    };
  }
}

/// Represents organization contact information.
class OrgContact {
  /// Creates an [OrgContact] instance.
  OrgContact({this.locator});

  /// Creates an [OrgContact] instance from a JSON map.
  factory OrgContact.fromJson(Map<String, dynamic> json) {
    return OrgContact(
      locator:
          json["Locator"] != null ? Locator.fromJson(json["Locator"]) : null,
    );
  }

  /// Contact locator information.
  final Locator? locator;

  /// Converts this [OrgContact] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "Locator": locator?.toJson(),
    };
  }
}

/// Represents financial data associated with a customer or relationship.
class FinancialData {
  /// Creates a [FinancialData] instance.
  FinancialData({
    this.financialType,
    this.financialAmt,
    this.relEstablishedDt,
    this.incomeCurrency,
  });

  /// Creates a [FinancialData] instance from a JSON map.
  factory FinancialData.fromJson(Map<String, dynamic> json) {
    return FinancialData(
      financialType: json["FinancialType"] as String?,
      financialAmt: json["FinancialAmt"] is num ? json["FinancialAmt"] : null,
      relEstablishedDt: json["RelEstablishedDt"] as String?,
      incomeCurrency: json["IncomeCurrency"] as String?,
    );
  }

  /// Financial type.
  final String? financialType;

  /// Financial amount.
  ///
  /// may be null or numeric
  final num? financialAmt;

  /// Relationship established date.
  final String? relEstablishedDt;

  /// Income currency.
  final String? incomeCurrency;

  /// Converts this [FinancialData] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "FinancialType": financialType,
      "FinancialAmt": financialAmt,
      "RelEstablishedDt": relEstablishedDt,
      "IncomeCurrency": incomeCurrency,
    };
  }
}

/// Represents relationship manager information.
class RelationshipMgr {
  /// Creates a [RelationshipMgr] instance.
  RelationshipMgr({
    this.relationshipMgrIdent,
    this.relationshipMgrName,
  });

  /// Creates a [RelationshipMgr] instance from a JSON map.
  factory RelationshipMgr.fromJson(Map<String, dynamic> json) {
    return RelationshipMgr(
      relationshipMgrIdent: json["RelationshipMgrIdent"] as String?,
      relationshipMgrName: json["RelationshipMgrName"] as String?,
    );
  }

  /// Relationship manager identifier.
  final String? relationshipMgrIdent;

  /// Relationship manager name.
  final String? relationshipMgrName;

  /// Converts this [RelationshipMgr] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "RelationshipMgrIdent": relationshipMgrIdent,
      "RelationshipMgrName": relationshipMgrName,
    };
  }
}

/// Represents credit risk information for a customer or entity.
class CreditRisk {
  /// Creates a [CreditRisk] instance.
  CreditRisk({
    this.riskCategory,
    this.internalScore,
  });

  /// Creates a [CreditRisk] instance from a JSON map.
  factory CreditRisk.fromJson(Map<String, dynamic> json) {
    return CreditRisk(
      riskCategory: json["RiskCategory"] as String?,
      internalScore: json["InternalScore"] as String?,
    );
  }

  /// Risk category.
  final String? riskCategory;

  /// Internal risk score.
  final String? internalScore;

  /// Converts this [CreditRisk] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "RiskCategory": riskCategory,
      "InternalScore": internalScore,
    };
  }
}

/// Represents group key information associated with a group.
class GroupKeys {
  /// Creates a [GroupKeys] instance.
  GroupKeys({
    this.groupId,
    this.groupOwner,
    this.groupName,
    this.groupStatus,
  });

  /// Creates a [GroupKeys] instance from a JSON map.
  factory GroupKeys.fromJson(Map<String, dynamic> json) {
    return GroupKeys(
      groupId: json["GroupId"] as String?,
      groupOwner: json["GroupOwner"] as String?,
      groupName: json["GroupName"] as String?,
      groupStatus: json["GroupStatus"] as String?,
    );
  }

  /// Group identifier.
  final String? groupId;

  /// Group owner.
  final String? groupOwner;

  /// Group name.
  final String? groupName;

  /// Group status.
  final String? groupStatus;

  /// Converts this [GroupKeys] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "GroupId": groupId,
      "GroupOwner": groupOwner,
      "GroupName": groupName,
      "GroupStatus": groupStatus,
    };
  }
}
