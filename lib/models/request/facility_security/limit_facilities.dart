class LimitsResponse {
  // keep as String to avoid extra date parsing

  const LimitsResponse({
    this.limitsFacilityId,
    this.rimNo,
    this.commitmentAccountNumber,
    this.controllingLimitNo,
    this.limitType,
    this.limitAmount,
    this.limitCurrency,
    this.pastDues,
    this.outstandingAmount,
    this.createdOn,
    this.limitDescription,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  factory LimitsResponse.fromJson(Map<String, dynamic> json) {
    return LimitsResponse(
      limitsFacilityId: json["limitsFacilityId"] is int
          ? json["limitsFacilityId"] as int
          : (json["limitsFacilityId"] is String
              ? int.tryParse(json["limitsFacilityId"] as String)
              : null),
      rimNo: json["rimNo"] is int
          ? json["rimNo"] as int
          : (json["rimNo"] is String
              ? int.tryParse(json["rimNo"] as String)
              : null),
      commitmentAccountNumber: json["commitmentAccountNumber"] as String?,
      controllingLimitNo: json["controllingLimitNo"]?.toString(),
      limitType: json["limitType"] as String?,
      limitAmount: json["limitAmount"] is num
          ? json["limitAmount"] as num
          : (json["limitAmount"] is String
              ? num.tryParse(json["limitAmount"] as String)
              : null),
      limitCurrency: json["limitCurrency"] as String?,
      pastDues: json["pastDues"] is num
          ? json["pastDues"] as num
          : (json["pastDues"] is String
              ? num.tryParse(json["pastDues"] as String)
              : null),
      outstandingAmount: json["outstandingAmount"] is num
          ? json["outstandingAmount"] as num
          : (json["outstandingAmount"] is String
              ? num.tryParse(json["outstandingAmount"] as String)
              : null),
      createdOn: json["createdOn"] as String?,
      limitDescription: json["limitDescription"] as String?,
      createdBy: json["createdBy"] as String?,
      createdDate: json["createdDate"] as String?,
      updatedBy: json["updatedBy"] as String?,
      updatedDate: json["updatedDate"] as String?,
    );
  }
  final int? limitsFacilityId;
  final int? rimNo;
  final String? commitmentAccountNumber;
  final String? controllingLimitNo;
  final String? limitType;
  final num? limitAmount;
  final String? limitCurrency;
  final num? pastDues;
  final num? outstandingAmount;
  final String? createdOn; // keep as String to avoid extra date parsing
  final String? limitDescription;
  final String? createdBy;
  final String? createdDate; // keep as String to avoid extra date parsing
  final String? updatedBy;
  final String? updatedDate;

  Map<String, dynamic> toJson() {
    return {
      "limitsFacilityId": limitsFacilityId,
      "rimNo": rimNo,
      "commitmentAccountNumber": commitmentAccountNumber,
      "controllingLimitNo": controllingLimitNo,
      "limitType": limitType,
      "limitAmount": limitAmount,
      "limitCurrency": limitCurrency,
      "pastDues": pastDues,
      "outstandingAmount": outstandingAmount,
      "createdOn": createdOn,
      "limitDescription": limitDescription,
      "createdBy": createdBy,
      "createdDate": createdDate,
      "updatedBy": updatedBy,
      "updatedDate": updatedDate,
    };
  }
}
