/// Represents a facility limit response returned by the API.
class LimitsResponse {
  /// Creates a [LimitsResponse] instance.
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

  /// Creates a [LimitsResponse] instance from a JSON map.
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

  /// Limits facility identifier.
  final int? limitsFacilityId;

  /// Customer RIM number.
  final int? rimNo;

  /// Commitment account number.
  final String? commitmentAccountNumber;

  /// Controlling limit number.
  final String? controllingLimitNo;

  /// Limit type.
  final String? limitType;

  /// Limit amount.
  final num? limitAmount;

  /// Limit currency.
  final String? limitCurrency;

  /// Past dues amount.
  final num? pastDues;

  /// Outstanding amount.
  final num? outstandingAmount;

  /// Record creation timestamp.
  ///
  /// Kept as a string to avoid extra date parsing.
  final String? createdOn;

  /// Limit description.
  final String? limitDescription;

  /// User who created the record.
  final String? createdBy;

  /// Record creation date.
  ///
  /// Kept as a string to avoid extra date parsing.
  final String? createdDate;

  /// User who last updated the record.
  final String? updatedBy;

  /// Record last update date.
  final String? updatedDate;

  /// Converts this [LimitsResponse] instance to a JSON map.
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
