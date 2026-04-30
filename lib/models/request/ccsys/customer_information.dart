import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class CcsysCustomerInformation {
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
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        return DateTime.parse(value);
      }
      return null;
    }

    return CcsysCustomerInformation(
      ccsysCustomerId: json["ccsysCustomerId"],
      rimNo: json["rimNo"],
      groupId: json["groupId"],
      customerName: json["customerName"],
      groupName: json["groupName"],
      borrowerSubsidiary: json["borrowerSubsidiary"] != null
          ? (json["borrowerSubsidiary"] == "N")
              ? false
              : true
          : false,
      groupUltimateParent: json["groupUltimateParent"],
      groupImmediateParent: json["groupImmediateParent"],
      legalEntityIdentifier: json["legalEntityIdentifier"] != null
          ? (json["legalEntityIdentifier"] == "N")
              ? false
              : true
          : false,
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
  String? auditor;
  Reference? borrowingSubsidiary;
  String? capital;
  int? dateAuditedFS;
  String? emirateLicense;
  String? emirateEstablishment;
  int? emiratesIdExpiry;
  String? emiratesIdPartner;
  Reference? gender;
  // List<Country>? countryRiskWith;
  String? groupImmediateParent;
  String? groupUltimateParent;
  bool? legalEntityIdentifier;
  String? legalStatusPartners;
  String? leiNumberPartner;
  String? leiNumber;
  Reference? pslei;
  Reference? residencyStatus;
  Reference? nationalityPartner;
  String? networkPartner;
  int? numberEmployees;
  String? tradeLicenseNumber;
  double? shareholding;
  Reference? shareholderType;
  Reference? placeOfIssue;
  String? passportNumber;
  int? passportExpiryDate;
  Reference? partnerShareholderResidence;
  String? partnerEng;
  Reference? radioButtonItems;

  int? ccsysCustomerId;
  int? rimNo;
  int? groupId;
  String? customerName;
  String? groupName;
  bool? borrowerSubsidiary;
  String? emiEst;
  String? emiLic;
  String? turnover;
  DateTime? dateAuditedFs;
  int? numberOfEmployee;
  String? createdBy;
  DateTime? createdDate;
  String? updatedBy;
  DateTime? updatedDate;
  String? appRefNo;
  List<PartnerShareholder>? ccsysCustomerPartnerShareholderList;
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
      "borrowerSubsidiary": (borrowerSubsidiary == true) ? "Y" : "N",
      "groupUltimateParent": groupUltimateParent,
      "groupImmediateParent": groupImmediateParent,
      "legalEntityIdentifier": (legalEntityIdentifier == true) ? "Y" : "N",
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

  factory PartnerShareholder.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
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
  int? ccsysCustomerPartnerShareholderId;
  int? ccsysCustomerId;
  String? partnerShareholderInEnglish;
  String? partnerShareholderResidence;
  String? partnerShareholderType;
  int? shareholdingPartnershipPercentage;
  String? networthPartnerShareholderAed;
  String? legalStatusOfPartnerShareholder;
  String? emiratesIdPartnerShareholder;
  DateTime? emiratesIdExpiryDatePartnerShareholder;
  String? passportNumberPartnerShareholder;
  DateTime? passportNumberExpiryDatePartnerShareholder;
  String? nationalityPartnerShareholder;
  String? tradeLicenseNumberPartnerShareholder;
  String? placeIssueTradeLicenseNumberPartnerShareholder;
  String? psLei;
  String? leiNumberPartnerShareholder;
  String? gender;

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
