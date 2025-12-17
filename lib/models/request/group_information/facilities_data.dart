import 'package:wcas_frontend/models/admin/reference.dart';

class Facility {
  int? facilityOtherbanksId;
  String? appRefNo;
  String? customerName;
  int? customerRimNo;
  int? bankNameId;
  String? comments;
  int? fundedLimit;
  int? nonFundedLimit;
  bool? deleted;
  int? total;
  int? parsedFundedLimit;
  int? parsedNonFundedLimit;
  int? parsedTotal;
  bool? news;
  // int? facilityId;
  // int? securityId;

  List<Reference>? facilityWith;
  List<Reference>? securityWith;

  Facility(
      {this.facilityOtherbanksId,
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
      this.securityWith});

  Facility.fromJson(Map<String, dynamic> json) {
    facilityOtherbanksId = json['facilityOtherbanksId'];
    appRefNo = json['appRefNo'];
    customerName = json['customerName'];
    customerRimNo = json['customerRimNo'];
    bankNameId = json['bankName'];
    comments = json['comments'];
    fundedLimit = json['fundedLimit'];
    nonFundedLimit = json['nonFundedLimit'];
    deleted = json['deleted'];
    total = json['total'];
    parsedFundedLimit = json['parsedFundedLimit'];
    parsedNonFundedLimit = json['parsedNonFundedLimit'];
    parsedTotal = json['parsedTotal'];
    // facilityId = json['facilityName'];
    // securityId = json['securityName'];

    if (json['facilityName'] != null) {
      final raw = json['facilityName'];
      if (raw is String) {
        final list = raw.split(',').map((e) => e.trim()).toList();
        facilityWith = list.map((e) => Reference(id: int.tryParse(e))).toList();
      }
    }
    if (json['securityName'] != null) {
      final raw = json['securityName'];
      if (raw is String) {
        final list = raw.split(',').map((e) => e.trim()).toList();
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
    //     securityWith = list.map((e) => Reference(id: int.tryParse(e))).toList();
    //   }
    // }
  }

  // Reference parseReference(String value) {
  //   if (value.trim() == '1') {
  //     return Reference(id: 1, reference4: 'Not Disclosed');
  //   }
  //   return Reference(id: int.tryParse(value));
  // }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['facilityOtherbanksId'] = facilityOtherbanksId;
    data['appRefNo'] = appRefNo;
    data['customerName'] = customerName;
    data['customerRimNo'] = customerRimNo;
    data['bankName'] = bankNameId;
    data['comments'] = comments;
    data['fundedLimit'] = fundedLimit;
    data['nonFundedLimit'] = nonFundedLimit;
    data['deleted'] = deleted;
    data['total'] = total;
    data['parsedFundedLimit'] = parsedFundedLimit;
    data['parsedNonFundedLimit'] = parsedNonFundedLimit;
    data['parsedTotal'] = parsedTotal;
    data['new'] = news;
    // data['facilityName'] = facilityId;
    // data['securityName'] = securityId;
    if (facilityWith != null && facilityWith!.isNotEmpty) {
      data['facilityName'] = facilityWith!.map((e) => e.id).join(', ');
    }
    if (securityWith != null && securityWith!.isNotEmpty) {
      data['securityName'] = securityWith!.map((e) => e.id).join(', ');
    }
    return data;
  }
}
