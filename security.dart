import 'dart:convert';

import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/country.dart';

class Security {
  // Existing fields
  String? appRefNo;
  int? securityId;
  Reference? securityGroup;
  Reference? securityType;
  int? rim;

  String? securityCode;

  String? securityNumber;
  bool? isTangibleSecurity;
  Map<String, dynamic>? dynamicFormDocument;
  Reference? isLimitCtrlSecurity;
  Reference? isPariPassu;
  bool? isCashCollateral;
  Reference? presentSecurityAmtCurrency;
  double? presentSecurityAmount;
  Reference? proposedSecurityAmtCurrency;
  double? proposedSecurityAmount;
  Reference? borrowerRole;
  bool? isSecurityProviderCbdCustomer;
  bool? isSecurityExpiryOpenEnded;
  DateTime? securityExpireDate;
  String? securityProvidedRim;
  String? securityProvidedName;
  Country? countryOfIncorporate;
  Reference? securityProvidedCategory;

  String? securityProvidedNumber;
  Country? securityProvidedCountry;

  Country? securityProviderNationality;
  Country? countryOfSecurity;
  Reference? emirates;
  String? deferredWaived;

  Reference? securityStatus;
  String? remarks;
  String? cmoRemarks;
  bool? allFacilities;
  bool? isDeletable;

  // Existing selected values
  Reference? selectedCashCollateralValue;
  Reference? selectedIsSecurityProviderCbdCustomerValue;

  //  New fields from API
  String? associatedCovenant;
  Reference? securityHeldAs;

  double? aedEquivalentPresentSecurity;
  double? aedEquivalentProposedSecurity;
  String? updatedBy;
  DateTime? updatedDate;
  String? createdBy;
  DateTime? createdDate;
  String? wcasSecurityNo;
  String? countryIncorporation;
  int? srcMigratedId;
  int? facilitySecurityLinkId;
  String? securityProviderCategory;
  Reference? securityProviderLegalStatus;
  String? securityProviderTlNo;
  String? securityProviderAddress;
  int? securityProviderEmiratesId;

  String? deferredWaivedBy;
  DateTime? deferredDate;
  String? cmoRemark;
  String? emirate;

  int? securityMasterId;

  int? facilitySecurityMasterLinkId;

  Reference? nameOfZone;

  String? currentDepositAccountNumber;
  List<String>? facilityNoList;

  Security(
      {
      // Existing fields
      this.appRefNo,
      this.dynamicFormDocument,
      this.securityType,
      this.rim,
      this.securityGroup,
      this.securityId,
      this.securityCode,
      this.securityNumber,
      this.isTangibleSecurity,
      this.isLimitCtrlSecurity,
      this.isCashCollateral,
      this.presentSecurityAmtCurrency,
      this.presentSecurityAmount,
      this.proposedSecurityAmtCurrency,
      this.proposedSecurityAmount,
      this.borrowerRole,
      this.isSecurityProviderCbdCustomer,
      this.isSecurityExpiryOpenEnded = true,
      this.securityExpireDate,
      this.securityProvidedRim,
      this.securityProvidedName,
      this.countryOfIncorporate,
      this.securityProvidedCategory,
      this.securityProvidedNumber,
      this.securityProvidedCountry,
      this.securityProviderNationality,
      this.countryOfSecurity,
      this.emirates,
      this.deferredWaived,
      this.securityStatus,
      this.remarks,
      this.cmoRemarks,
      this.isDeletable,
      this.allFacilities,
      this.selectedCashCollateralValue,
      this.selectedIsSecurityProviderCbdCustomerValue,

      // New fields
      this.associatedCovenant,
      this.nameOfZone,
      this.isPariPassu,
      this.securityHeldAs,
      this.aedEquivalentPresentSecurity,
      this.aedEquivalentProposedSecurity,
      this.updatedBy,
      this.updatedDate,
      this.securityMasterId,
      this.createdBy,
      this.createdDate,
      this.wcasSecurityNo,
      this.countryIncorporation,
      this.srcMigratedId,
      this.facilitySecurityLinkId,
      this.currentDepositAccountNumber,
      this.securityProviderCategory,
      this.securityProviderLegalStatus,
      this.securityProviderTlNo,
      this.securityProviderAddress,
      this.securityProviderEmiratesId,
      this.deferredWaivedBy,
      this.deferredDate,
      this.cmoRemark,
      this.emirate,
      this.facilitySecurityMasterLinkId,
      this.facilityNoList});

  factory Security.fromJson(Map<String, dynamic> json) {
    return Security(
      isSecurityExpiryOpenEnded: (json['isSecurityOpenEnded'] ?? 0) == 1,
      appRefNo: json['appRefNo'],
      facilitySecurityMasterLinkId: json['facilitySecurityMasterLinkId'],
      securityMasterId: json['securityMasterId'],
      rim: json['rimNo'],
      securityCode: json['securityCode'],
      securityNumber: json['securityNo'],
      securityProvidedNumber: json['wcasSecurityNumber'],
      presentSecurityAmount: (json['presentSecurity'] as num?)?.toDouble(),
      proposedSecurityAmount: (json['proposedSecurity'] as num?)?.toDouble(),
      aedEquivalentPresentSecurity:
          (json['aedequivalentPresentSecurity'] as num?)?.toDouble(),
      aedEquivalentProposedSecurity:
          (json['aedequivalentProposedSecurity'] as num?)?.toDouble(),
      securityGroup: Reference(reference4: json['securityGroup'].toString()),
      securityProvidedName: json['securityProviderName'],
      securityProvidedRim: json['securityProviderRim'],
      securityProviderTlNo: json['securityProviderTlNo'],
      securityProviderCategory: json['securityProviderCategory'],
      securityProviderLegalStatus:
          Reference(name: json['securityProviderLegalStatus']),
      securityProviderAddress: json['securityProviderAddress'],
      securityProviderEmiratesId: json['securityProviderEmiratesId'],
      securityProviderNationality:
          Country(code: json['securityProviderNationality']),
      countryOfSecurity: json['countryOfSecurity'] != null
          ? Country(code: json['countryOfSecurity'])
          : null,
      emirate: json['emirate'],
      deferredWaivedBy: json['deferredWaivedBy'],
      deferredDate: json['deferredDate'] != null
          ? DateTime.tryParse(json['deferredDate'])
          : null,
      securityExpireDate: json['securityExpiryDate'] != null
          ? DateTime.tryParse(json['securityExpiryDate'])
          : null,
      updatedDate: json['updatedDate'] != null
          ? DateTime.tryParse(json['updatedDate'])
          : null,
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'])
          : null,
      updatedBy: json['updatedBy'],
      createdBy: json['createdBy'],
      associatedCovenant: json['associatedCovenant'],
      securityHeldAs: Reference(id: json['securityHeldAs']),
      proposedSecurityAmtCurrency: Reference(name: json['currency']),
      securityId: json['securityId'],
      securityType: json['securityType'] != null
          ? Reference(id: json['securityType'])
          : null,
      allFacilities: json['allFacilities'],
      isCashCollateral: (json['isCashCollateral']) == 1,
      isTangibleSecurity: json['isTangibleSecurity'] == 1,
      isLimitCtrlSecurity:
          Reference(id: (json['isLimitControlling'] == 1) ? 1 : 0),
      isDeletable: json['isDraft'] == 1,
      cmoRemark: json['cmoRemark'],
      wcasSecurityNo: json['wcasSecurityNo'],
      countryIncorporation: json['countryIncorporation'],
      srcMigratedId: json['srcMigratedId'],
      facilitySecurityLinkId: json['facilitySecurityLinkId'],
      facilityNoList: json['facilityNoList'] != null
          ? List<String>.from(json['facilityNoList'])
          : [],
    )..dynamicFormDocument = _parseAdditionalDetails(json['additionalDetails']);
  }

  /// Parses the additionalDetails JSON string into a Map
  static Map<String, dynamic> _parseAdditionalDetails(
      dynamic additionalDetails) {
    if (additionalDetails == null) {
      return {};
    }

    try {
      if (additionalDetails is String && additionalDetails.isNotEmpty) {
        return jsonDecode(additionalDetails) as Map<String, dynamic>;
      } else if (additionalDetails is Map<String, dynamic>) {
        return additionalDetails;
      }
    } catch (e) {
      logger.w('Failed to parse additionalDetails: $e');
    }

    return {};
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    // Existing fields
    data['isSecurityOpenEnded'] = (isSecurityExpiryOpenEnded ?? false) ? 1 : 0;
    data['appRefNo'] =
        ServerConstants.appRefNo; //Globals.request?.applicationRefNo;
    data['rimNo'] = rim ??
        ServerConstants.customerRIMNumberId; //Globals.request?.customerRimNo;
    data['securityCode'] = securityCode;
    data['additionalDetails'] =
        dynamicFormDocument != null && dynamicFormDocument!.isNotEmpty
            ? jsonEncode(dynamicFormDocument)
            : null;
    data['emirate'] = emirates?.name;
    data['securityNo'] = securityNumber ?? securityType?.reference1;
    data['wcasSecurityNumber'] = securityProvidedNumber;
    data['presentSecurity'] = presentSecurityAmount;
    data['proposedSecurity'] = proposedSecurityAmount;
    data['aedequivalentPresentSecurity'] = aedEquivalentPresentSecurity;
    data['aedequivalentProposedSecurity'] = aedEquivalentProposedSecurity;
    data['securityGroup'] = securityGroup?.reference4;
    data['securityProviderName'] = securityProvidedName;
    data['securityProviderRim'] = securityProvidedRim;
    data['securityProviderTlNo'] = securityProviderTlNo;
    data['securityProviderCategory'] = securityProviderCategory;
    data['securityProviderLegalStatus'] = securityProviderLegalStatus?.name;
    data['securityProviderAddress'] = securityProviderAddress;
    data['securityProviderEmiratesId'] = securityProviderEmiratesId;
    data['securityProviderNationality'] = securityProviderNationality?.code;
    data['countryOfSecurity'] =
        countryOfSecurity?.code ?? ServerConstants.aedCurrency;
    data['emirate'] = emirate;
    data['deferredWaivedBy'] = deferredWaivedBy;
    data['deferredDate'] = deferredDate?.toIso8601String();
    data['securityExpiryDate'] = securityExpireDate?.toIso8601String();
    data['updatedDate'] = DateTime.now().toIso8601String();
    data['createdDate'] = DateTime.now().toIso8601String();
    data['updatedBy'] = Globals.user?.userName;
    data['createdBy'] = Globals.user?.userName;
    data['associatedCovenant'] = associatedCovenant;
    data['securityHeldAs'] = securityHeldAs?.id;
    data['currency'] = proposedSecurityAmtCurrency?.name;
    data['securityId'] = securityId;
    data['securityType'] = securityType?.id;
    data['allFacilities'] = allFacilities ?? false;
    data['isTangibleSecurity'] = isTangibleSecurity == true ? 1 : 0;
    data['isCashCollateral'] = isCashCollateral == true ? 1 : 0;
    data['isLimitControlling'] =
        isLimitCtrlSecurity?.id == ServerConstants.optionYESid ? 1 : 0;
    data['isDraft'] = isDeletable;
    data['cmoRemark'] = cmoRemark;
    data['wcasSecurityNo'] = wcasSecurityNo;
    data['countryIncorporation'] = countryIncorporation;
    data['srcMigratedId'] = srcMigratedId;
    data['borrowerRole'] = borrowerRole?.name;

    return data;
  }

  Map<String, dynamic> toSaveFacilityLinkageJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['appRefNo'] = appRefNo;
    data['allFacilities'] = allFacilities ?? false;
    data['facilityNoList'] = facilityNoList;
    data['securityNo'] = securityNumber;
    data['facilitySecurityLinkId'] = facilitySecurityLinkId;
    return data;
  }
}
