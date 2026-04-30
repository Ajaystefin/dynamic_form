import "dart:convert";

import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/country.dart";

class Security {
  Security({
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
    this.isSecurityExpiryOpenEnded = true,
    this.securityExpireDate,
    this.securityProvidedRim,
    this.securityProvidedName,
    this.countryOfIncorporate,
    this.securityProvidedNumber,
    this.securityProvidedCountry,
    this.securityProviderNationality,
    this.countryOfSecurity,
    this.emirates,
    this.deferredWaived,
    this.securityStatus,
    this.remarks,
    this.remarksFi,
    this.cmoRemarksFi,
    this.isDeletable = true,
    this.allFacilities,
    this.selectedCashCollateralValue,
    this.selectedIsSecurityProviderCbdCustomerValue,

    // New fields
    this.associatedCovenant,
    this.nameOfZone,
    this.isPariPassu,
    this.securityHeldAs,
    this.aedPresentSecurity,
    this.aedProposedSecurity,
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
    this.facilityNoList,
  });

  factory Security.fromJson(
    Map<String, dynamic> json, {
    List<Reference>? emirates,
    List<Reference>? statuses,
    List<Country>? countries,
  }) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      return false;
    }

    final bool isSecurityProvidedCBDCustomer =
        parseBool(json["isSecurityProvidedCBDCustomer"]);

    return Security(
      isSecurityExpiryOpenEnded: parseBool((json["isSecurityOpenEnded"])),
      cmoRemark: json["cmoRemark"],
      remarks: json["remarks"],
      remarksFi: json["remarksFi"],
      cmoRemarksFi: json["cmoRemarksFi"],
      selectedIsSecurityProviderCbdCustomerValue: isSecurityProvidedCBDCustomer
          ? Reference(id: ServerConstants.optionYESid)
          : Reference(id: ServerConstants.optionNOid),
      appRefNo: json["appRefNo"],
      countryOfIncorporate: json["countryIncorporation"],
      facilitySecurityMasterLinkId: json["facilitySecurityMasterLinkId"],
      securityMasterId: json["securityMasterId"],
      rim: json["rimNo"],
      securityCode: json["securityCode"],

      securityNumber: json["securityNo"],
      securityProvidedNumber: json["wcasSecurityNumber"],
      presentSecurityAmount: (json["presentSecurity"] as num?)?.toDouble(),
      proposedSecurityAmount: (json["proposedSecurity"] as num?)?.toDouble(),
      aedPresentSecurity: json["aedPresentSecurity"],
      aedProposedSecurity: json["aedProposedSecurity"],
      securityGroup: Reference(reference4: json["securityGroup"].toString()),
      securityProvidedName: "${json['securityProviderName'] ?? ""}",
      securityProvidedRim: isSecurityProvidedCBDCustomer
          ? "${json['securityProviderRim'] ?? ""}"
          : null,
      securityProviderTlNo: "${json['securityProviderTlNo'] ?? ""}",
      securityProviderCategory: json["securityProviderCategory"],
      securityProviderLegalStatus:
          Reference(name: json["securityProviderLegalStatus"]),
      securityProviderAddress: json["securityProviderAddress"],
      securityProviderEmiratesId: json["securityProviderEmiratesId"],
      securityProviderNationality: json["securityProviderNationality"],
      securityProvidedCountry: json["countryIncorporation"] != null
          ? countries?.firstWhere(
              (country) => country.code == json["countryIncorporation"],
              orElse: Country.new,
            )
          : null,
      currentDepositAccountNumber: json["currentTimeDeposiAccNo"],
      countryOfSecurity: json["countryOfSecurity"],
      emirates: json["emirate"] != null
          ? emirates?.firstWhere(
              (emirate) => emirate.id.toString() == json["emirate"],
            )
          : null,
      securityStatus: json["securityStatus"] != null
          ? statuses?.firstWhere(
              (status) => status.id == json["securityStatus"],
              orElse: () => Reference(id: json["securityStatus"]),
            )
          : null,
      deferredWaivedBy: json["deferredWaivedBy"],
      deferredDate: json["deferredDate"] != null
          ? DateTime.tryParse(json["deferredDate"])
          : null,
      securityExpireDate: json["securityExpiryDate"] != null
          ? DateTime.tryParse(json["securityExpiryDate"])
          : null,
      updatedDate: json["updatedDate"] != null
          ? DateTime.tryParse(json["updatedDate"])
          : null,
      createdDate: json["createdDate"] != null
          ? DateTime.tryParse(json["createdDate"])
          : null,
      updatedBy: json["updatedBy"],
      borrowerRole: Reference(name: json["borrowerRole"]),
      createdBy: json["createdBy"],
      associatedCovenant: json["associatedCovenant"],
      securityHeldAs: Reference(id: json["securityHeldAs"]),
      proposedSecurityAmtCurrency: Reference(name: json["currency"]),
      securityId: json["securityId"],
      securityType: json["securityType"] != null
          ? Reference(id: json["securityType"], name: json["securityCodeFi"])
          : null,
      allFacilities: json["allFacilities"],
      isCashCollateral: parseBool(json["isCashCollateral"]), // == 1,
      isTangibleSecurity: parseBool(json["isTangibleSecurity"]), // == 1,
      isLimitCtrlSecurity: parseBool(json["isLimitControlling"]), //?? 0) == 1,
      //Reference(id: (json['isLimitControlling'] == 1) ?
      //ServerConstants.optionYESid : ServerConstants.optionNOid),
      isDeletable: json["isDraft"] == 1,

      wcasSecurityNo: json["wcasSecurityNo"],
      // countryIncorporation: json['countryIncorporation'],
      srcMigratedId: json["srcMigratedId"],
      facilityNoList: _getFacilityNumbers(json["facilityNoList"]),
      facilitySecurityLinkId: json["facilitySecurityLinkId"],
    )..dynamicFormDocument =
        {}; // Initialize empty, will be populated by repository
  }
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
  //Reference? isLimitCtrlSecurity;
  bool? isLimitCtrlSecurity;
  Reference? isPariPassu;
  bool? isCashCollateral;
  Reference? presentSecurityAmtCurrency;
  double? presentSecurityAmount;
  Reference? proposedSecurityAmtCurrency;
  double? proposedSecurityAmount;
  Reference? borrowerRole;
  bool? isSecurityExpiryOpenEnded;
  DateTime? securityExpireDate;
  String? securityProvidedRim;
  String? securityProvidedName;
  String? countryOfIncorporate;

  String? securityProvidedNumber;
  Country? securityProvidedCountry;

  String? securityProviderNationality;
  String? countryOfSecurity;

  Reference? emirates;
  String? deferredWaived;

  Reference? securityStatus;
  String? cmoRemark;
  String? remarks;
  String? remarksFi;
  String? cmoRemarksFi;

  bool? allFacilities;
  bool? isDeletable;
  String? coRemarksFi;
  // Existing selected values
  Reference? selectedCashCollateralValue;
  Reference? selectedIsSecurityProviderCbdCustomerValue;

  //  New fields from API
  String? associatedCovenant;
  Reference? securityHeldAs;

  double? aedPresentSecurity;
  double? aedProposedSecurity;
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

  String? emirate;

  int? securityMasterId;

  int? facilitySecurityMasterLinkId;

  Reference? nameOfZone;

  String? currentDepositAccountNumber;
  List<String?>? facilityNoList;

  Map<String, dynamic> toJson(String? securityCode) {
    final Map<String, dynamic> data = <String, dynamic>{};

    // Existing fields
    data["isSecurityOpenEnded"] = (isSecurityExpiryOpenEnded ?? false) ? 1 : 0;
    data["appRefNo"] = Globals.request?.applicationRefNo;
    data["isSecurityProvidedCBDCustomer"] =
        selectedIsSecurityProviderCbdCustomerValue?.id ==
                ServerConstants.optionNOid
            ? 0
            : 1;
    data["currentTimeDeposiAccNo"] = currentDepositAccountNumber;
    data["rimNo"] = rim ?? Globals.request?.customerRimNo;
    if (Utils.checkBusinessSegment(BusinessSegment.financialInstitution)) {
      data["remarksFi"] = remarks;
      data["coRemarksFi"] = cmoRemark;
      data["securityCodeFi"] = (securityType
          ?.name); // Other Security Type Description manually entered by user
    } else {
      data["remarks"] = remarks;
      data["cmoRemark"] = cmoRemark;
    }
    // curreency fields
    data["presentSecurity"] = presentSecurityAmount;
    data["proposedSecurity"] = proposedSecurityAmount;
    data["aedPresentSecurity"] = aedPresentSecurity;
    data["aedProposedSecurity"] = aedProposedSecurity;

    data["securityCode"] =
        (securityType?.reference3 ?? securityCode ?? ""); //--
    data["additionalDetails"] = json.encode(dynamicFormDocument);
    data["otherNonPanelEvaluator"] =
        dynamicFormDocument?["enterNonpanelValuatorName"];
    data["emirate"] = emirates?.id; //check null occuring
    data["securityNo"] = securityNumber;
    data["wcasSecurityNumber"] = securityProvidedNumber;
    data["securityGroup"] = securityGroup?.reference4; //--
    data["securityProviderName"] = securityProvidedName;
    data["securityProviderRim"] = securityProvidedRim;
    data["securityProviderTlNo"] = securityProviderTlNo;
    data["securityProviderCategory"] = securityProviderCategory;
    data["securityProviderLegalStatus"] = securityProviderLegalStatus?.name;
    data["securityProviderAddress"] = securityProviderAddress;
    data["securityProviderEmiratesId"] = securityProviderEmiratesId;
    data["securityProviderNationality"] = securityProviderNationality;

    data["countryOfSecurity"] = countryOfSecurity;
    data["deferredWaivedBy"] = deferredWaivedBy;
    data["deferredDate"] = deferredDate?.toIso8601String();
    data["securityExpiryDate"] = securityExpireDate == null
        ? DateTime(2099, 12, 30)
            .toIso8601String() //Setting defualt expire date as per requirement
        : securityExpireDate?.toIso8601String();
    data["updatedDate"] = DateTime.now().toIso8601String();
    data["createdDate"] = DateTime.now().toIso8601String();
    data["updatedBy"] = Globals.user?.id.toString();
    data["createdBy"] = Globals.user?.id.toString();
    data["associatedCovenant"] = associatedCovenant;
    data["securityHeldAs"] = securityHeldAs?.id; //check null occuring
    data["currency"] = proposedSecurityAmtCurrency?.name;
    data["securityId"] = securityId;
    data["securityType"] = securityType?.id;
    data["allFacilities"] = allFacilities ?? false;
    data["isTangibleSecurity"] = isTangibleSecurity == true ? 1 : 0;
    data["isCashCollateral"] = isCashCollateral == true ? 1 : 0;
    data["isLimitControlling"] = isLimitCtrlSecurity == true ? 1 : 0;

    data["isDraft"] = isDeletable == true ? 1 : 0;

    data["wcasSecurityNo"] = wcasSecurityNo;
    data["countryIncorporation"] = securityProvidedCountry?.code;

    data["srcMigratedId"] = srcMigratedId;
    data["borrowerRole"] = borrowerRole?.name;
    data["securityStatus"] = securityStatus?.id;
    return data;
  }

  Map<String, dynamic> toSaveFacilityLinkageJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["appRefNo"] = appRefNo;
    data["allFacilitiesPresent"] = allFacilities ?? false;
    data["facilityNoList"] = facilityNoList;
    data["securityNo"] = securityNumber;
    if (facilitySecurityLinkId != 0 && facilitySecurityLinkId != null) {
      data["facilitySecurityLinkId"] = facilitySecurityLinkId;
    }
    return data;
  }
}

List<String?>? _getFacilityNumbers(dynamic value) {
  if (value != null) {
    if (value is List<dynamic>) {
      return List<String?>.from(value.toList());
    } else {
      if (value.contains(",")) {
        return List<String?>.from(value.split(","));
      } else {
        return [value];
      }
    }
  }
  return [];
}
