import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";

class SecurityDeferral {
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
  String? securityNo;
  int? securityId;
  String? securityType;
  String? present;
  String? proposed;
  double? aedPresent;
  double? aedProposed;
  bool? allFacilities;
  bool? selected;
  bool? draft;
  bool isChecked = false;
  List<FacilityDetail>? facilityDetails;
  DateTime? dateDeferral;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["appRefNo"] = Globals.request?.applicationRefNo;
    data["securityNo"] = securityNo;
    data["securityMasterId"] = securityId;
    data["securityType"] = securityType;
    data["presentSecurity"] = present;
    data["proposedSecurity"] = proposed;
    data["selected"] = selected;
    data["facilityDetailsList"] = facilityDetails;
    try {
      data["deferralDate"] = dateDeferral != null
          ? DateFormat("yyyy-MM-dd").format(dateDeferral!)
          : null; //
    } catch (_) {
      data["deferralDate"] = null;
    }

    return data;
  }
}

class FacilityDetail {
  FacilityDetail({
    required this.limitNumber,
    required this.rimNo,
    required this.limitDescription,
    required this.limitAmountAED000s,
    required this.amountToBeReleased,
    this.facilityMasterId,
  });

  // Factory constructor to create an instance from JSON
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
  String? limitNumber;
  String? rimNo;
  String? limitDescription;
  int? limitAmountAED000s;
  int? facilityMasterId;
  double? amountToBeReleased;

  // Method to convert an instance to JSON
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

String safeString(dynamic value) {
  if (value == null) return "";
  final str = value.toString().trim();
  return (str.isEmpty || str.toLowerCase() == "null") ? "" : str;
}

bool safeBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  return value.toString().toLowerCase() == "true";
}

double? safeDouble(dynamic value) {
  if (value == null || value.toString().toLowerCase() == "null") return null;
  return double.tryParse(value.toString());
}

int? safeInt(dynamic value) {
  if (value == null || value.toString().toLowerCase() == "null") return null;
  return int.tryParse(value.toString());
}
