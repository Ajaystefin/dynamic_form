import "dart:convert";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";

/// Represents security information including collateral,
/// provider details, facility linkage, and related metadata.
class Security {
  /// Creates a [Security] instance.
  Security({
    // Existing fields
    this.appRefNo,
    this.dynamicFormDocument,
    this.securityType,
    this.rim,
    this.securityGroup,
    this.securityId,
    this.isDraft = true,
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
    this.isDeletable,
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
    this.selectedFacilitiesByRim,
    this.selectedFacilityNoList,
  });

  /// Creates a [Security] instance from a JSON map.
  factory Security.fromJson(
    Map<String, dynamic> json, {
    List<Reference>? emirates,
    List<Reference>? statuses,
    List<Country>? countries,
  }) {
    bool parseBool(value) {
      if (value is bool) {
        return value;
      }
      if (value is int) {
        return value == 1;
      }
      return false;
    }

    final bool isSecurityProvidedCBDCustomer =
        parseBool(json["isSecurityProvidedCBDCustomer"]);

    return Security(
      isSecurityExpiryOpenEnded: parseBool(json["isSecurityOpenEnded"]),
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
      aedPresentSecurity: _toDoubleOrNull(json["aedPresentSecurity"]),
      aedProposedSecurity: _toDoubleOrNull(json["aedProposedSecurity"]),
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
      allFacilities: (json["isAllFacilities"] as int? ?? 0) == 1,
      isCashCollateral: parseBool(json["isCashCollateral"]), // == 1,
      isTangibleSecurity: parseBool(json["isTangibleSecurity"]), // == 1,
      isLimitCtrlSecurity: parseBool(json["isLimitControlling"]), //?? 0) == 1,
      isDeletable: (json["securityMasterId"] ?? 0) <= 0,
      wcasSecurityNo: json["wcasSecurityNo"],
      // countryIncorporation: json['countryIncorporation'],
      srcMigratedId: json["srcMigratedId"],
      facilityNoList: _getFacilityNumbers(json["facilityNoList"]),
      selectedFacilityNoList: (json["selectedFacilityNoList"] as List<dynamic>?)
          ?.map(
            (e) => Facility(
              limitNumber: e["facilityNo"] as String?,
              rimNo: e["rimNo"] as int?,
            ),
          )
          .toList(),
      facilitySecurityLinkId: json["facilitySecurityLinkId"],
    )..dynamicFormDocument =
        {}; // Initialize empty, will be populated by repository
  }

  /// Application reference number.
  String? appRefNo;

  /// Security identifier.
  int? securityId;

  /// Security group.
  Reference? securityGroup;

  /// Security type.
  Reference? securityType;

  /// Customer RIM number.
  int? rim;

  /// Security code.
  String? securityCode;

  /// Security number.
  String? securityNumber;

  /// Indicates whether the security is tangible.
  bool? isTangibleSecurity;

  /// Dynamic form data for the security.
  Map<String, dynamic>? dynamicFormDocument;

  /// Indicates whether the security is limit controlling.
  bool? isLimitCtrlSecurity;

  /// Draft status.
  bool isDraft;

  /// Pari passu indicator.
  Reference? isPariPassu;

  /// Indicates whether the security is cash collateral.
  bool? isCashCollateral;

  /// Present security amount currency.
  Reference? presentSecurityAmtCurrency;

  /// Present security amount.
  double? presentSecurityAmount;

  /// Proposed security amount currency.
  Reference? proposedSecurityAmtCurrency;

  /// Proposed security amount.
  double? proposedSecurityAmount;

  /// Borrower role.
  Reference? borrowerRole;

  /// Indicates whether security expiry is open-ended.
  bool? isSecurityExpiryOpenEnded;

  /// Security expiry date.
  DateTime? securityExpireDate;

  /// Security provider RIM number.
  String? securityProvidedRim;

  /// Security provider name.
  String? securityProvidedName;

  /// Country of incorporation.
  String? countryOfIncorporate;

  /// Security provider number.
  String? securityProvidedNumber;

  /// Security provider country.
  Country? securityProvidedCountry;

  /// Security provider nationality.
  String? securityProviderNationality;

  /// Country of security.
  String? countryOfSecurity;

  /// Emirate reference.
  Reference? emirates;

  /// Deferred or waived information.
  String? deferredWaived;

  /// Security status.
  Reference? securityStatus;

  /// CMO remarks.
  String? cmoRemark;

  /// Remarks.
  String? remarks;

  /// FI remarks.
  String? remarksFi;

  /// CMO FI remarks.
  String? cmoRemarksFi;

  /// Indicates whether all facilities are associated.
  bool? allFacilities;

  /// Indicates whether record can be deleted.
  bool? isDeletable;

  /// Selected cash collateral value.
  Reference? selectedCashCollateralValue;

  /// Selected CBD customer value.
  Reference? selectedIsSecurityProviderCbdCustomerValue;

  /// Associated covenant.
  String? associatedCovenant;

  /// Security held as type.
  Reference? securityHeldAs;

  /// AED present security amount.
  double? aedPresentSecurity;

  /// AED proposed security amount.
  double? aedProposedSecurity;

  /// User who last updated the record.
  String? updatedBy;

  /// Record update date.
  DateTime? updatedDate;

  /// User who created the record.
  String? createdBy;

  /// Record creation date.
  DateTime? createdDate;

  /// WCAS security number.
  String? wcasSecurityNo;

  /// Country incorporation code.
  String? countryIncorporation;

  /// Source migrated identifier.
  int? srcMigratedId;

  /// Facility security linkage identifier.
  int? facilitySecurityLinkId;

  /// Security provider category.
  String? securityProviderCategory;

  /// Security provider legal status.
  Reference? securityProviderLegalStatus;

  /// Security provider trade license number.
  String? securityProviderTlNo;

  /// Security provider address.
  String? securityProviderAddress;

  /// Security provider Emirates ID.
  int? securityProviderEmiratesId;

  /// Deferred or waived by.
  String? deferredWaivedBy;

  /// Deferred date.
  DateTime? deferredDate;

  /// Emirate name.
  String? emirate;

  /// Security master identifier.
  int? securityMasterId;

  /// Facility security master linkage identifier.
  int? facilitySecurityMasterLinkId;

  /// Zone name.
  Reference? nameOfZone;

  /// Current deposit account number.
  String? currentDepositAccountNumber;

  /// Linked facility numbers.
  List<String?>? facilityNoList;
  List<String?>? selectedFacilitiesByRim;
  List<Facility?>? selectedFacilityNoList;

  /// Converts this [Security] instance to a JSON map.
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
      data["cmoRemarksFi"] = cmoRemark;
      data["securityCodeFi"] = securityType
          ?.name; // Other Security Type Description manually entered by user
    } else {
      data["remarks"] = remarks;
      data["cmoRemark"] = cmoRemark;
    }
    // curreency fields
    data["presentSecurity"] = presentSecurityAmount;
    data["proposedSecurity"] = proposedSecurityAmount;
    data["aedPresentSecurity"] = aedPresentSecurity;
    data["aedProposedSecurity"] = aedProposedSecurity;

    data["securityCode"] = securityType?.reference3 ?? securityCode ?? ""; //--
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
    data["securityMasterId"] = securityMasterId;
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
    data["isAllFacilities"] = allFacilities ?? false;
    data["isTangibleSecurity"] = isTangibleSecurity ?? false ? 1 : 0;
    data["isCashCollateral"] = isCashCollateral ?? false ? 1 : 0;
    data["isLimitControlling"] = isLimitCtrlSecurity ?? false ? 1 : 0;

    data["isDraft"] = isDraft ? 0 : 1;

    data["wcasSecurityNo"] = wcasSecurityNo;
    data["countryIncorporation"] = securityProvidedCountry?.code;

    data["srcMigratedId"] = srcMigratedId;
    data["borrowerRole"] = borrowerRole?.name;
    data["securityStatus"] = securityStatus?.id;
    return data;
  }

  /// Converts this [Security] instance to a facility
  /// linkage request payload.
  Map<String, dynamic> toSaveFacilityLinkageJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["appRefNo"] = appRefNo;
    data["allFacilitiesPresent"] = allFacilities ?? false;
    data["facilityNoList"] = facilityNoList;
    data["securityNo"] = securityNumber;
    data["selectedFacilitiesByRim"] = selectedFacilitiesByRim;
    if (facilitySecurityLinkId != 0 && facilitySecurityLinkId != null) {
      data["facilitySecurityLinkId"] = facilitySecurityLinkId;
    }

    return data;
  }
}

/// Converts a JSON value to a double if possible.
///
/// The AED amounts arrive as an `int` whenever the backend has nothing after
/// the decimal point (`"aedProposedSecurity": 578`), which a `double?` field
/// cannot hold without this conversion. Quoted amounts are accepted too.
double? _toDoubleOrNull(v) {
  if (v == null) {
    return null;
  }
  if (v is num) {
    return v.toDouble();
  }
  return double.tryParse(v.toString());
}

/// Extracts facility numbers from a list or comma-separated value.
List<String?>? _getFacilityNumbers(value) {
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
