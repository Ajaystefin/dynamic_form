import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Represents CCSYS customer information including borrower details,
/// legal identifiers, partner/shareholder details, audit information,
/// and country risk utilization details.
class CcsysCustomerInformation {
  /// Creates a [CcsysCustomerInformation] instance.
  CcsysCustomerInformation({
    this.auditor,
    this.pslei,
    this.borrowingSubsidiary,
    this.capital,
    this.dateAuditedFS,
    this.emirateLicense,
    this.emirateEstablishment,
    this.emiratesIdExpiry,
    this.emiratesIdPartner,
    this.gender,
    this.groupImmediateParent,
    this.groupUltimateParent,
    this.legalEntityIdentifier,
    this.legalStatusPartners,
    this.leiNumberPartner,
    this.leiNumber,
    this.residencyStatus,
    this.nationalityPartner,
    this.networkPartner,
    this.numberEmployees,
    this.tradeLicenseNumber,
    this.shareholding,
    this.shareholderType,
    this.placeOfIssue,
    this.passportNumber,
    this.passportExpiryDate,
    this.partnerShareholderResidence,
    this.partnerEng,
    this.radioButtonItems,
    this.ccsysCustomerId,
    this.rimNo,
    this.groupId,
    this.customerName,
    this.groupName,
    this.borrowerSubsidiary,
    this.emiEst,
    this.emiLic,
    this.turnover,
    this.dateAuditedFs,
    this.numberOfEmployee,
    this.countryOfRiskFundUtilization,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.appRefNo,
    this.ccsysCustomerPartnerShareholderList,
  });

  /// Creates an instance from a JSON map.
  factory CcsysCustomerInformation.fromJsonGetCCSYSCustomerInfo(
    Map<String, dynamic> json,
  ) {
    // Helper to parse DateTime or return null
    DateTime? parseDate(value) {
      if (value == null) {
        return null;
      }
      if (value is String && value.isNotEmpty) {
        return DateTime.parse(value);
      }
      return null;
    }

    bool? toBoolYN(value) {
      if (value == null) {
        return false;
      }

      final str = value.toString().trim().toUpperCase();
      if (str == "Y") {
        return true;
      }
      if (str == "N") {
        return false;
      }

      return false; // optional fallback
    }

    return CcsysCustomerInformation(
      ccsysCustomerId: json["ccsysCustomerId"],
      rimNo: json["rimNo"],
      groupId: json["groupId"],
      customerName: json["customerName"],
      groupName: json["groupName"],
      borrowerSubsidiary: toBoolYN(json["borrowerSubsidiary"]),
      groupUltimateParent: json["groupUltimateParent"],
      groupImmediateParent: json["groupImmediateParent"],
      legalEntityIdentifier: toBoolYN(json["legalEntityIdentifier"]),
      leiNumber: json["leiNumber"],
      emiEst: json["emiEst"],
      emiLic: json["emiLic"],
      capital: json["capital"],
      turnover: json["turnover"],
      auditor: json["auditor"],
      dateAuditedFs: parseDate(
        json["dateAuditedFs"] ?? json["dateAuditedFS"],
      ),
      numberOfEmployee: json["numberOfEmployee"],
      countryOfRiskFundUtilization:
          (json["countryOfRiskFundUtilization"] != null &&
                  (json["countryOfRiskFundUtilization"] as String)
                      .trim()
                      .isNotEmpty)
              ? (json["countryOfRiskFundUtilization"] as String)
                  .split(",")
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .map((e) => Reference(name: e))
                  .toList()
              : [], // <-- typed empty list
      appRefNo: json["appRefNo"],
      ccsysCustomerPartnerShareholderList:
          (json["ccsysCustomerPartnerShareholderList"] as List<dynamic>? ?? [])
              .map(
                (e) => PartnerShareholder.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  /// Creates a [CcsysCustomerInformation] instance from a JSON map.
  factory CcsysCustomerInformation.fromJson(Map<String, dynamic> json) {
    return CcsysCustomerInformation(
      auditor: json["auditor"],
      borrowingSubsidiary: json["borrowingSubsidiary"] != null
          ? Reference.fromJson(json["borrowingSubsidiary"])
          : null,
      capital: json["capital"],
      dateAuditedFS: json["dateAuditedFS"],
      emirateLicense: json["emirateLicense"],
      emirateEstablishment: json["emirateEstablishment"],
      emiratesIdExpiry: json["emiratesIdExpiry"],
      emiratesIdPartner: json["emiratesIdPartner"],
      gender:
          json["gender"] != null ? Reference.fromJson(json["gender"]) : null,
      groupImmediateParent: json["groupImmediateParent"],
      groupUltimateParent: json["groupUltimateParent"],
      legalEntityIdentifier: json["legalEntityIdentifier"],
      legalStatusPartners: json["legalStatusPartners"],
      leiNumberPartner: json["leiNumberPartner"],
      leiNumber: json["leiNumber"],
      residencyStatus: json["residencyStatus"] != null
          ? Reference.fromJson(json["residencyStatus"])
          : null,
      nationalityPartner: json["nationalityPartner"] != null
          ? Reference.fromJson(json["nationalityPartner"])
          : null,
      networkPartner: json["networkPartner"],
      numberEmployees: json["numberEmployees"],
      turnover: json["turnOver"],
      tradeLicenseNumber: json["tradeLicenseNumber"],
      shareholding: (json["shareholding"] as num?)?.toDouble(),
      shareholderType: json["shareholderType"] != null
          ? Reference.fromJson(json["shareholderType"])
          : null,
      placeOfIssue: json["placeOfIssue"] != null
          ? Reference.fromJson(json["placeOfIssue"])
          : null,
      passportNumber: json["passportNumber"],
      passportExpiryDate: json["passportExpiryDate"],
      partnerShareholderResidence: json["partnerShareholderResidence"] != null
          ? Reference.fromJson(json["partnerShareholderResidence"])
          : null,
      partnerEng: json["partnerEng"],
      radioButtonItems: json["radioButtonItems"] != null
          ? Reference.fromJson(json["radioButtonItems"])
          : null,
    );
  }

  /// Auditor name or auditor details.
  String? auditor;

  /// Borrowing subsidiary reference.
  Reference? borrowingSubsidiary;

  /// Capital value.
  String? capital;

  /// Date audited financial statement value.
  int? dateAuditedFS;

  /// Emirate license value.
  String? emirateLicense;

  /// Emirate establishment value.
  String? emirateEstablishment;

  /// Emirates ID expiry value.
  int? emiratesIdExpiry;

  /// Emirates ID partner value.
  String? emiratesIdPartner;

  /// Gender reference.
  Reference? gender;

  // List<Country>? countryRiskWith;

  /// Immediate parent group value.
  String? groupImmediateParent;

  /// Ultimate parent group value.
  String? groupUltimateParent;

  /// Indicates whether legal entity identifier is available.
  bool? legalEntityIdentifier;

  /// Legal status of partners.
  String? legalStatusPartners;

  /// LEI number of partner.
  String? leiNumberPartner;

  /// Legal entity identifier number.
  String? leiNumber;

  /// PS LEI reference.
  Reference? pslei;

  /// Residency status reference.
  Reference? residencyStatus;

  /// Nationality partner reference.
  Reference? nationalityPartner;

  /// Network partner value.
  String? networkPartner;

  /// Number of employees.
  int? numberEmployees;

  /// Trade license number.
  String? tradeLicenseNumber;

  /// Shareholding percentage.
  double? shareholding;

  /// Shareholder type reference.
  Reference? shareholderType;

  /// Place of issue reference.
  Reference? placeOfIssue;

  /// Passport number.
  String? passportNumber;

  /// Passport expiry date value.
  int? passportExpiryDate;

  /// Partner shareholder residence reference.
  Reference? partnerShareholderResidence;

  /// Partner name in English.
  String? partnerEng;

  /// Radio button selected reference item.
  Reference? radioButtonItems;

  /// CCSYS customer identifier.
  int? ccsysCustomerId;

  /// Customer RIM number.
  int? rimNo;

  /// Group identifier.
  int? groupId;

  /// Customer name.
  String? customerName;

  /// Group name.
  String? groupName;

  /// Indicates whether the customer is a borrower subsidiary.
  bool? borrowerSubsidiary;

  /// EMI establishment value.
  String? emiEst;

  /// EMI license value.
  String? emiLic;

  /// Customer turnover value.
  String? turnover;

  /// Date audited financial statement.
  DateTime? dateAuditedFs;

  /// Number of employees.
  int? numberOfEmployee;

  /// User who created the record.
  String? createdBy;

  /// Date and time when the record was created.
  DateTime? createdDate;

  /// User who updated the record.
  String? updatedBy;

  /// Date and time when the record was updated.
  DateTime? updatedDate;

  /// Application reference number.
  String? appRefNo;

  /// List of CCSYS customer partner shareholders.
  List<PartnerShareholder>? ccsysCustomerPartnerShareholderList;

  /// Country of risk fund utilization references.
  List<Reference>? countryOfRiskFundUtilization;

  /// Converts the instance back to a JSON map.
  Map<String, dynamic> toJsonGetCCSYSCustomerInfo() {
    String? formatDate(DateTime? dt) => dt?.toIso8601String();

    return {
      "ccsysCustomerId": ccsysCustomerId,
      "rimNo": Globals.request?.customerRimNo,
      "groupId": groupId,
      "customerName": customerName,
      "groupName": groupName,
      "borrowerSubsidiary": (borrowerSubsidiary ?? false) ? "Y" : "N",
      "groupUltimateParent": groupUltimateParent,
      "groupImmediateParent": groupImmediateParent,
      "legalEntityIdentifier": (legalEntityIdentifier ?? false) ? "Y" : "N",
      "leiNumber": leiNumber,
      "emiEst": emiEst,
      "emiLic": emiLic,
      "capital": capital,
      "turnover": turnover,
      "auditor": auditor,
      "dateAuditedFs": formatDate(dateAuditedFs),
      "numberOfEmployee": numberOfEmployee,
      "countryOfRiskFundUtilization": (countryOfRiskFundUtilization != null &&
              (countryOfRiskFundUtilization ?? []).isNotEmpty)
          ? countryOfRiskFundUtilization!.map((e) => e.name).join(", ")
          : "",
      "appRefNo": appRefNo,
      "ccsysCustomerPartnerShareholderList":
          ccsysCustomerPartnerShareholderList?.map((e) => e.toJson()).toList(),
      "createdBy": Globals.user?.id,
      "createdDate": DateTime.now().toIso8601String(),
      "updatedBy": Globals.user?.id,
      "updatedDate": DateTime.now().toIso8601String(),
    };
  }

  /// Converts this [CcsysCustomerInformation] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "auditor": auditor,
      "borrowingSubsidiary": borrowingSubsidiary?.toJson(),
      "capital": capital,
      "dateAuditedFS": dateAuditedFS,
      "emirateLicense": emirateLicense,
      "emirateEstablishment": emirateEstablishment,
      "emiratesIdExpiry": emiratesIdExpiry,
      "emiratesIdPartner": emiratesIdPartner,
      "gender": gender?.toJson(),
      "groupImmediateParent": groupImmediateParent,
      "groupUltimateParent": groupUltimateParent,
      "legalEntityIdentifier": legalEntityIdentifier,
      "legalStatusPartners": legalStatusPartners,
      "leiNumberPartner": leiNumberPartner,
      "leiNumber": leiNumber,
      "residencyStatus": residencyStatus?.toJson(),
      "nationalityPartner": nationalityPartner?.toJson(),
      "networkPartner": networkPartner,
      "numberEmployees": numberEmployees,
      "turnOver": turnover,
      "tradeLicenseNumber": tradeLicenseNumber,
      "shareholding": shareholding,
      "shareholderType": shareholderType?.toJson(),
      "placeOfIssue": placeOfIssue?.toJson(),
      "passportNumber": passportNumber,
      "passportExpiryDate": passportExpiryDate,
      "partnerShareholderResidence": partnerShareholderResidence?.toJson(),
      "partnerEng": partnerEng,
      "radioButtonItems": radioButtonItems?.toJson(),
    };
  }
}

/// Model representing each item in 'ccsysCustomerPartnerShareholderList'.
class PartnerShareholder {
  /// Creates a [PartnerShareholder] instance.
  PartnerShareholder({
    this.ccsysCustomerPartnerShareholderId,
    this.ccsysCustomerId,
    this.partnerShareholderInEnglish,
    this.partnerShareholderResidence,
    this.partnerShareholderType,
    this.shareholdingPartnershipPercentage,
    this.networthPartnerShareholderAed,
    this.legalStatusOfPartnerShareholder,
    this.emiratesIdPartnerShareholder,
    this.emiratesIdExpiryDatePartnerShareholder,
    this.passportNumberPartnerShareholder,
    this.passportNumberExpiryDatePartnerShareholder,
    this.nationalityPartnerShareholder,
    this.tradeLicenseNumberPartnerShareholder,
    this.placeIssueTradeLicenseNumberPartnerShareholder,
    this.psLei,
    this.leiNumberPartnerShareholder,
    this.gender,
  });

  /// Creates a [PartnerShareholder] instance from a JSON map.
  factory PartnerShareholder.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(value) {
      if (value == null) {
        return null;
      }
      if (value is String && value.isNotEmpty) {
        return DateTime.parse(value);
      }
      return null;
    }

    return PartnerShareholder(
      ccsysCustomerPartnerShareholderId:
          json["ccsysCustomerPartnerShareholderId"] as int?,
      ccsysCustomerId: json["ccsysCustomerId"] as int?,
      partnerShareholderInEnglish:
          json["partnerShareholderInEnglish"] as String?,
      partnerShareholderResidence:
          json["partnerShareholderResidence"] as String?,
      partnerShareholderType: json["partnerShareholderType"] as String?,
      shareholdingPartnershipPercentage:
          json["shareholdingPartnershipPercentage"] as int?,
      networthPartnerShareholderAed:
          json["networthPartnerShareholderAed"] as String?,
      legalStatusOfPartnerShareholder:
          json["legalStatusOfPartnerShareholder"] as String?,
      emiratesIdPartnerShareholder:
          json["emiratesIdPartnerShareholder"] as String?,
      emiratesIdExpiryDatePartnerShareholder:
          parseDate(json["emiratesIdExpiryDatePartnerShareholder"]),
      passportNumberPartnerShareholder:
          json["passportNumberPartnerShareholder"] as String?,
      passportNumberExpiryDatePartnerShareholder:
          parseDate(json["passportNumberExpiryDatePartnerShareholder"]),
      nationalityPartnerShareholder:
          json["nationalityPartnerShareholder"] as String?,
      tradeLicenseNumberPartnerShareholder:
          json["tradeLicenseNumberPartnerShareholder"] as String?,
      placeIssueTradeLicenseNumberPartnerShareholder:
          json["placeIssueTradeLicenseNumberPartnerShareholder"] as String?,
      psLei: json["psLei"] as String?,
      leiNumberPartnerShareholder:
          json["leiNumberPartnerShareholder"] as String?,
      gender: json["gender"] as String?,
    );
  }

  /// CCSYS customer partner shareholder identifier.
  int? ccsysCustomerPartnerShareholderId;

  /// CCSYS customer identifier.
  int? ccsysCustomerId;

  /// Partner or shareholder name in English.
  String? partnerShareholderInEnglish;

  /// Partner or shareholder residence value.
  String? partnerShareholderResidence;

  /// Partner or shareholder type.
  String? partnerShareholderType;

  /// Shareholding partnership percentage.
  int? shareholdingPartnershipPercentage;

  /// Net worth of partner or shareholder in AED.
  String? networthPartnerShareholderAed;

  /// Legal status of partner or shareholder.
  String? legalStatusOfPartnerShareholder;

  /// Emirates ID of partner or shareholder.
  String? emiratesIdPartnerShareholder;

  /// Emirates ID expiry date of partner or shareholder.
  DateTime? emiratesIdExpiryDatePartnerShareholder;

  /// Passport number of partner or shareholder.
  String? passportNumberPartnerShareholder;

  /// Passport expiry date of partner or shareholder.
  DateTime? passportNumberExpiryDatePartnerShareholder;

  /// Nationality of partner or shareholder.
  String? nationalityPartnerShareholder;

  /// Trade license number of partner or shareholder.
  String? tradeLicenseNumberPartnerShareholder;

  /// Place of issue for trade license number of partner or shareholder.
  String? placeIssueTradeLicenseNumberPartnerShareholder;

  /// PS LEI value.
  String? psLei;

  /// LEI number of partner or shareholder.
  String? leiNumberPartnerShareholder;

  /// Gender value.
  String? gender;

  /// Converts this [PartnerShareholder] instance into a JSON map.
  Map<String, dynamic> toJson() {
    String? formatDate(DateTime? dt) => dt?.toIso8601String();

    return {
      "ccsysCustomerPartnerShareholderId": ccsysCustomerPartnerShareholderId,
      "ccsysCustomerId": ccsysCustomerId,
      "partnerShareholderInEnglish": partnerShareholderInEnglish,
      "partnerShareholderResidence": partnerShareholderResidence,
      "partnerShareholderType": partnerShareholderType,
      "shareholdingPartnershipPercentage": shareholdingPartnershipPercentage,
      "networthPartnerShareholderAed": networthPartnerShareholderAed,
      "legalStatusOfPartnerShareholder": legalStatusOfPartnerShareholder,
      "emiratesIdPartnerShareholder": emiratesIdPartnerShareholder,
      "emiratesIdExpiryDatePartnerShareholder":
          formatDate(emiratesIdExpiryDatePartnerShareholder),
      "passportNumberPartnerShareholder": passportNumberPartnerShareholder,
      "passportNumberExpiryDatePartnerShareholder":
          formatDate(passportNumberExpiryDatePartnerShareholder),
      "nationalityPartnerShareholder": nationalityPartnerShareholder,
      "tradeLicenseNumberPartnerShareholder":
          tradeLicenseNumberPartnerShareholder,
      "placeIssueTradeLicenseNumberPartnerShareholder":
          placeIssueTradeLicenseNumberPartnerShareholder,
      "psLei": psLei ??= "N",
      "leiNumberPartnerShareholder": leiNumberPartnerShareholder,
      "gender": gender,
      "createdBy": Globals.user?.id,
      "createdDate": DateTime.now().toIso8601String(),
      "updatedBy": Globals.user?.id,
      "updatedDate": DateTime.now().toIso8601String(),
    };
  }
}
