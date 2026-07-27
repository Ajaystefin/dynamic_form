import "package:decimal/decimal.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Represents facilities maintained with other banks,
/// including limits, securities, and facility details.
class Facility {
  /// Creates a [Facility] instance.
  Facility({
    this.facilityOtherbanksId,
    this.appRefNo,
    this.customerName,
    this.customerRimNo,
    this.bankNameId,
    this.comments,
    this.fundedLimit,
    this.nonFundedLimit,
    this.deleted,
    this.total,
    this.parsedFundedLimit,
    this.parsedNonFundedLimit,
    this.parsedTotal,
    this.news,
    // this.facilityId,
    // this.securityId,
    this.facilityWith,
    this.securityWith,
    this.isDeletable = false,
    this.hasRim,
  });

  /// Creates a [Facility] instance from a JSON map.
  Facility.fromJson(Map<String, dynamic> json) {
    facilityOtherbanksId = json["facilityOtherBankId"];
    appRefNo = json["appRefNo"];
    customerName = json["customerName"];
    customerRimNo = json["rimNo"];
    bankNameId = json["bankName"];
    comments = json["comments"];
    fundedLimit = Decimal.parse((json["fundedLimitStr"] ?? "0").toString());
    nonFundedLimit =
        Decimal.parse((json["nonFundedLimitStr"] ?? "0").toString());
    deleted = json["deleted"];
    total = Decimal.parse((json["totalStr"] ?? "0").toString());
    parsedFundedLimit = Decimal.tryParse(json["parsedFundedLimit"].toString());
    parsedNonFundedLimit =
        Decimal.tryParse(json["parsedNonFundedLimit"].toString());
    parsedTotal = Decimal.tryParse(json["parsedTotal"].toString());
    // facilityId = json['facilityName'];
    // securityId = json['securityName'];
    isDeletable = json["isDeletable"] == 1;
    hasRim = (int.tryParse(json["rimNo"]?.toString() ?? "0") ?? 0) > 0;

    if (json["facilityType"] != null) {
      final raw = json["facilityType"];
      if (raw is String) {
        final list = raw.split(",").map((e) => e.trim()).toList();
        facilityWith = list.map((e) => Reference(id: int.tryParse(e))).toList();
      }
    }
    if (json["securityCode"] != null) {
      final raw = json["securityCode"];
      if (raw is String) {
        final list = raw.split(",").map((e) => e.trim()).toList();
        securityWith = list.map((e) => Reference(id: int.tryParse(e))).toList();
      }
    }

    // if (json['facilityName'] != null) {
    //   final facilityRaw = json['facilityName'];
    //   if (facilityRaw is String) {
    //     final list = facilityRaw.split(',').map((e) => e.trim()).toList();
    //     facilityWith = list.map(parseReference).toList();
    //   }
    // }
    // if (json['securityName'] != null) {
    //   final securityRaw = json['securityName'];
    //   if (securityRaw is String) {
    //     final list = securityRaw.split(',').map((e) => e.trim()).toList();
    //     securityWith = list.map((e) => Reference(id:
    // int.tryParse(e))).toList();
    //   }
    // }
  }

  /// Facility with other banks identifier.
  int? facilityOtherbanksId;

  /// Application reference number.
  String? appRefNo;

  /// Customer name.
  String? customerName;

  /// Customer RIM number.
  int? customerRimNo;

  /// Bank identifier.
  int? bankNameId;

  /// Comments.
  String? comments;

  /// Funded limit.
  Decimal? fundedLimit;

  /// Non-funded limit.
  Decimal? nonFundedLimit;

  /// Indicates whether the record is deleted.
  bool? deleted;

  /// Total limit.
  Decimal? total;

  /// Parsed funded limit.
  Decimal? parsedFundedLimit;

  /// Parsed non-funded limit.
  Decimal? parsedNonFundedLimit;

  /// Parsed total limit.
  Decimal? parsedTotal;

  /// Indicates whether the record is new.
  bool? news;

  /// Indicates whether the record can be deleted.
  bool? isDeletable;

  /// Indicates whether a valid RIM exists.
  bool? hasRim;

  /// Facility types associated with the record.
  List<Reference>? facilityWith;

  /// Security types associated with the record.
  List<Reference>? securityWith;

  // int? facilityId;
  // int? securityId;

  // Reference parseReference(String value) {
  //   if (value.trim() == '1') {
  //     return Reference(id: 1, reference4: 'Not Disclosed');
  //   }
  //   return Reference(id: int.tryParse(value));
  // }

  /// Converts this [Facility] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["facilityOtherbanksId"] = facilityOtherbanksId;
    data["appRefNo"] = appRefNo ??= Globals.request?.applicationRefNo;
    data["customerName"] = customerName;
    data["rimNo"] = customerRimNo ??= 0;
    data["bankName"] = bankNameId;
    data["comments"] = comments;
    data["fundedLimit"] = fundedLimit.toString();
    data["nonFundedLimit"] = nonFundedLimit.toString();
    data["deleted"] = deleted;
    data["total"] = ((Decimal.tryParse(fundedLimit.toString()) ??
                Decimal.parse("0")) +
            (Decimal.tryParse(nonFundedLimit.toString()) ?? Decimal.parse("0")))
        .toString();
    data["parsedFundedLimit"] = parsedFundedLimit;
    data["parsedNonFundedLimit"] = parsedNonFundedLimit;
    data["parsedTotal"] = parsedTotal;
    data["new"] = news;
    // data['facilityName'] = facilityId;
    // data['securityName'] = securityId;
    if (facilityWith != null && facilityWith!.isNotEmpty) {
      data["facilityType"] = facilityWith!.map((e) => e.id).join(", ");
    }
    if (securityWith != null && securityWith!.isNotEmpty) {
      data["securityCode"] = securityWith!.map((e) => e.id).join(", ");
    }
    return data;
  }
}
