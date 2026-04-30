import "package:decimal/decimal.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class Facility {
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
  });

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
    isDeletable = json["isDeletable"] == 1 ? true : false;

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
  int? facilityOtherbanksId;
  String? appRefNo;
  String? customerName;
  int? customerRimNo;
  int? bankNameId;
  String? comments;
  Decimal? fundedLimit;
  Decimal? nonFundedLimit;
  bool? deleted;
  Decimal? total;
  Decimal? parsedFundedLimit;
  Decimal? parsedNonFundedLimit;
  Decimal? parsedTotal;
  bool? news;
  // int? facilityId;
  // int? securityId;
  bool? isDeletable;

  List<Reference>? facilityWith;
  List<Reference>? securityWith;

  // Reference parseReference(String value) {
  //   if (value.trim() == '1') {
  //     return Reference(id: 1, reference4: 'Not Disclosed');
  //   }
  //   return Reference(id: int.tryParse(value));
  // }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["facilityOtherbanksId"] = facilityOtherbanksId;
    data["appRefNo"] = appRefNo ??= Globals.request?.applicationRefNo;
    data["customerName"] = customerName;
    data["rimNo"] = customerRimNo;
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
