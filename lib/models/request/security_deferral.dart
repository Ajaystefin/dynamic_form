import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";

/// Represents a security deferral record, including
/// security details, facility mappings, and deferral information.
class SecurityDeferral {
  /// Creates a [SecurityDeferral] instance.
  SecurityDeferral({
    this.securityNo,
    this.securityId,
    this.securityType,
    this.present,
    this.proposed,
    this.aedPresent,
    this.aedProposed,
    this.allFacilities,
    this.selected,
    this.draft,
    this.isChecked = false,
    this.facilityDetails,
    this.dateDeferral,
  });

  /// Creates a [SecurityDeferral] instance from a JSON map.
  SecurityDeferral.fromJson(Map<String, dynamic> json) {
    //  Safe string fields
    securityNo = safeString(json["securityNo"]);
    securityType = safeString(json["securityType"]);
    present = safeString(json["presentSecurity"]);
    proposed = safeString(json["proposedSecurity"]);

    // Safe numeric fields
    securityId = safeInt(json["securityMasterId"]);
    aedPresent = safeDouble(json["aedequivalentPresentSecurity"]);
    aedProposed = safeDouble(json["aedequivalentProposedSecurity"]);

    // Safe boolean fields
    allFacilities = safeBool(json["allFacilities"]);
    selected = safeBool(json["selected"]);
    isChecked = selected ?? false;
    draft = safeBool(json["draft"]);

    // Safe date handling
    if (json["deferralDate"] != null &&
        json["deferralDate"].toString().toLowerCase() != "null") {
      dateDeferral = DateTimeUtils.intToDateTime(json["deferralDate"]);
    }

    // Facility list (null‑safe & type‑safe)
    if (json["facilityDetailsList"] is List) {
      facilityDetails = (json["facilityDetailsList"] as List)
          .map((e) => FacilityDetail.fromJson(e))
          .toList();
    } else {
      facilityDetails = [];
    }

    // UI helper field (never from backend)
    //isChecked = false;
  }

  /// Security reference number.
  String? securityNo;

  /// Unique identifier of the security.
  int? securityId;

  /// Type of security.
  String? securityType;

  /// Current security details.
  String? present;

  /// Proposed security details.
  String? proposed;

  /// Present AED equivalent value of the security.
  double? aedPresent;

  /// Proposed AED equivalent value of the security.
  double? aedProposed;

  /// Indicates whether the security applies to all facilities.
  bool? allFacilities;

  /// Indicates whether the security is selected.
  bool? selected;

  /// Indicates whether the record is saved as draft.
  bool? draft;

  /// UI flag indicating whether the security is checked.
  bool isChecked = false;

  /// List of facility details linked to the security.
  List<FacilityDetail>? facilityDetails;

  /// Deferral date of the security.
  DateTime? dateDeferral;

  /// Converts this [SecurityDeferral] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["appRefNo"] = Globals.request?.applicationRefNo;
    data["securityNo"] = securityNo;
    data["securityMasterId"] = securityId;
    data["securityType"] = securityType;
    data["presentSecurity"] = present;
    data["proposedSecurity"] = proposed;
    data["selected"] = isChecked;
    data["facilityDetailsList"] = facilityDetails;
    try {
      data["deferralDate"] = dateDeferral != null
          ? DateFormat("yyyy-MM-dd").format(dateDeferral!)
          : null; //
    } on Object catch (_) {
      data["deferralDate"] = null;
    }
    return data;
  }
}

/// Represents facility details associated with a security deferral.
class FacilityDetail {
  /// Creates a [FacilityDetail] instance.
  FacilityDetail({
    required this.limitNumber,
    required this.rimNo,
    required this.limitDescription,
    required this.limitAmountAED000s,
    required this.amountToBeReleased,
    this.facilityMasterId,
  });

  /// Creates a [FacilityDetail] instance from a JSON map.
  factory FacilityDetail.fromJson(Map<String, dynamic> json) {
    return FacilityDetail(
      limitNumber: json["limitNumber"]?.toString(),
      rimNo: json["rimNo"]?.toString(),
      limitDescription: json["limitDescription"]?.toString(),
      limitAmountAED000s: json["presentLimit"],
      amountToBeReleased: json["amountToBeReleased"],
      facilityMasterId: json["facilityMasterId"],
    );
  }

  /// Facility limit number.
  String? limitNumber;

  /// RIM number associated with the facility.
  String? rimNo;

  /// Description of the facility.
  String? limitDescription;

  /// Facility limit amount in AED thousands.
  int? limitAmountAED000s;

  /// Unique identifier of the facility.
  int? facilityMasterId;

  /// Amount proposed to be released.
  double? amountToBeReleased;

  /// Converts this [FacilityDetail] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "limitNumber": limitNumber,
      "rimNo": rimNo,
      "Limit Description": limitDescription,
      "presentLimit": limitAmountAED000s,
      "amountToBeReleased": amountToBeReleased,
      "facilityMasterId": facilityMasterId,
    };
  }
}

/// Returns a sanitized string value by handling null,
/// empty, and literal "null" values.
String safeString(Object? value) {
  if (value == null) {
    return "";
  }
  final str = value.toString().trim();
  return (str.isEmpty || str.toLowerCase() == "null") ? "" : str;
}

/// Returns a boolean value from the supplied object.
bool safeBool(Object? value) {
  if (value == null) {
    return false;
  }
  if (value is bool) {
    return value;
  }
  return value.toString().toLowerCase() == "true";
}

/// Safely converts the supplied value to a double.
double? safeDouble(Object? value) {
  if (value == null || value.toString().toLowerCase() == "null") {
    return null;
  }
  return double.tryParse(value.toString());
}

/// Safely converts the supplied value to an integer.
int? safeInt(Object? value) {
  if (value == null || value.toString().toLowerCase() == "null") {
    return null;
  }
  return int.tryParse(value.toString());
}
