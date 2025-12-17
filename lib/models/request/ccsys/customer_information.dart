import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/country.dart';

class CcsysCustomerInformation {
  String? auditor;
  Reference? borrowingSubsidiary;
  String? capital;
  int? dateAuditedFS;
  Reference? emirateLicense;
  Reference? emirateEstablishment;
  int? emiratesIdExpiry;
  String? emiratesIdPartner;
  Reference? gender;
  List<Country>? countryRiskWith;
  String? groupImmediateParent;
  String? groupUltimateParent;
  Reference? legalEntityIdentifier;
  Reference? legalStatusPartners;
  String? leiNumberPartner;
  String? leiNumber;
  Reference? pslei;
  Reference? residencyStatus;
  Reference? nationalityPartner;
  String? networkPartner;
  int? numberEmployees;
  double? turnOver;
  String? tradeLicenseNumber;
  double? shareholding;
  Reference? shareholderType;
  Reference? placeOfIssue;
  String? passportNumber;
  int? passportExpiryDate;
  Reference? partnerShareholderResidence;
  String? partnerEng;
  Reference? radioButtonItems;

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
    this.countryRiskWith,
    this.residencyStatus,
    this.nationalityPartner,
    this.networkPartner,
    this.numberEmployees,
    this.turnOver,
    this.tradeLicenseNumber,
    this.shareholding,
    this.shareholderType,
    this.placeOfIssue,
    this.passportNumber,
    this.passportExpiryDate,
    this.partnerShareholderResidence,
    this.partnerEng,
    this.radioButtonItems,
  });

  factory CcsysCustomerInformation.fromJson(Map<String, dynamic> json) {
    return CcsysCustomerInformation(
      auditor: json['auditor'],
      borrowingSubsidiary: json['borrowingSubsidiary'] != null
          ? Reference.fromJson(json['borrowingSubsidiary'])
          : null,
      capital: json['capital'],
      dateAuditedFS: json['dateAuditedFS'],
      emirateLicense: json['emirateLicense'] != null
          ? Reference.fromJson(json['emirateLicense'])
          : null,
      emirateEstablishment: json['emirateEstablishment'] != null
          ? Reference.fromJson(json['emirateEstablishment'])
          : null,
      emiratesIdExpiry: json['emiratesIdExpiry'],
      emiratesIdPartner: json['emiratesIdPartner'],
      gender:
          json['gender'] != null ? Reference.fromJson(json['gender']) : null,
      groupImmediateParent: json['groupImmediateParent'],
      groupUltimateParent: json['groupUltimateParent'],
      legalEntityIdentifier: json['legalEntityIdentifier'] != null
          ? Reference.fromJson(json['legalEntityIdentifier'])
          : null,
      legalStatusPartners: json['legalStatusPartners'] != null
          ? Reference.fromJson(json['legalStatusPartners'])
          : null,
      leiNumberPartner: json['leiNumberPartner'],
      leiNumber: json['leiNumber'],
      residencyStatus: json['residencyStatus'] != null
          ? Reference.fromJson(json['residencyStatus'])
          : null,
      nationalityPartner: json['nationalityPartner'] != null
          ? Reference.fromJson(json['nationalityPartner'])
          : null,
      networkPartner: json['networkPartner'],
      numberEmployees: json['numberEmployees'],
      turnOver: (json['turnOver'] as num?)?.toDouble(),
      tradeLicenseNumber: json['tradeLicenseNumber'],
      shareholding: (json['shareholding'] as num?)?.toDouble(),
      shareholderType: json['shareholderType'] != null
          ? Reference.fromJson(json['shareholderType'])
          : null,
      placeOfIssue: json['placeOfIssue'] != null
          ? Reference.fromJson(json['placeOfIssue'])
          : null,
      passportNumber: json['passportNumber'],
      passportExpiryDate: json['passportExpiryDate'],
      partnerShareholderResidence: json['partnerShareholderResidence'] != null
          ? Reference.fromJson(json['partnerShareholderResidence'])
          : null,
      partnerEng: json['partnerEng'],
      radioButtonItems: json['radioButtonItems'] != null
          ? Reference.fromJson(json['radioButtonItems'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auditor': auditor,
      'borrowingSubsidiary': borrowingSubsidiary?.toJson(),
      'capital': capital,
      'dateAuditedFS': dateAuditedFS,
      'emirateLicense': emirateLicense?.toJson(),
      'emirateEstablishment': emirateEstablishment?.toJson(),
      'emiratesIdExpiry': emiratesIdExpiry,
      'emiratesIdPartner': emiratesIdPartner,
      'gender': gender?.toJson(),
      'groupImmediateParent': groupImmediateParent,
      'groupUltimateParent': groupUltimateParent,
      'legalEntityIdentifier': legalEntityIdentifier?.toJson(),
      'legalStatusPartners': legalStatusPartners?.toJson(),
      'leiNumberPartner': leiNumberPartner,
      'leiNumber': leiNumber,
      'residencyStatus': residencyStatus?.toJson(),
      'nationalityPartner': nationalityPartner?.toJson(),
      'networkPartner': networkPartner,
      'numberEmployees': numberEmployees,
      'turnOver': turnOver,
      'tradeLicenseNumber': tradeLicenseNumber,
      'shareholding': shareholding,
      'shareholderType': shareholderType?.toJson(),
      'placeOfIssue': placeOfIssue?.toJson(),
      'passportNumber': passportNumber,
      'passportExpiryDate': passportExpiryDate,
      'partnerShareholderResidence': partnerShareholderResidence?.toJson(),
      'partnerEng': partnerEng,
      'radioButtonItems': radioButtonItems?.toJson(),
    };
  }
}
