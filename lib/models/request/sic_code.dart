/// Represents a SIC code review record for a customer,
/// including existing and proposed SIC code details.
class SicCodeReview {
  /// Creates a [SicCodeReview] instance.
  SicCodeReview({
    this.sicCodeReviewId,
    this.custInfoId,
    this.appRefNo,
    this.rimNo,
    this.facilityId,
    this.customerRimNo,
    this.customerName,
    this.primaryBusinessActivity,
    this.existingSicCode,
    this.proposedSicCode,
    this.accountLevelSicCode,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  /// Creates a [SicCodeReview] instance from a JSON map.
  factory SicCodeReview.fromJson(Map<String, dynamic> json) {
    return SicCodeReview(
      sicCodeReviewId: json["sicCodeReviewId"],
      custInfoId: json["custInfoId"],
      appRefNo: json["appRefNo"],
      rimNo: json["rimNo"],
      facilityId: json["facilityId"],
      customerRimNo: json["rimNo"],
      customerName: json["customerName"],
      primaryBusinessActivity: json["primaryBusinessActivity"],
      existingSicCode: json["industryCbdSicCode"],
      proposedSicCode: json["proposedSicCode"],
      accountLevelSicCode: json["accountLevelSicCode"],
      createdBy: json["createdBy"],
      createdDate: json["createdDate"],
      updatedBy: json["updatedBy"],
      updatedDate: json["updatedDate"],
    );
  }

  /// Unique identifier of the SIC code review record.
  int? sicCodeReviewId;

  /// Identifier of the associated customer information record.
  int? custInfoId;

  /// Application reference number.
  String? appRefNo;

  /// RIM number associated with the review.
  int? rimNo;

  /// Identifier of the related facility.
  int? facilityId;

  /// Customer RIM number.
  int? customerRimNo;

  /// Name of the customer.
  String? customerName;

  /// Primary business activity of the customer.
  String? primaryBusinessActivity;

  /// Existing SIC code assigned to the customer.
  String? existingSicCode;

  /// Proposed SIC code under review.
  String? proposedSicCode;

  /// Account-level SIC code.
  String? accountLevelSicCode;

  /// User who created the record.
  String? createdBy;

  /// Date when the record was created.
  String? createdDate;

  /// User who last updated the record.
  String? updatedBy;

  /// Date when the record was last updated.
  String? updatedDate;

  /// Converts this [SicCodeReview] instance to a JSON map.
  // Map<String, dynamic> toJson() {
  //   return {
  //     'sicCodeReviewId': sicCodeReviewId,
  //     'custInfoId': custInfoId,
  //     'appRefNo': appRefNo,
  //     'rimNo': rimNo,
  //     'facilityId': facilityId,
  //     'customerRimNo': customerRimNo,
  //     'customerName': customerName,
  //     'primaryBusinessActivity': primaryBusinessActivity,
  //     'existingSicCode': existingSicCode,
  //     'proposedSicCode': proposedSicCode,
  //     'accountLevelSicCode': accountLevelSicCode,
  //     'createdBy': createdBy,
  //     'createdDate': createdDate,
  //     'updatedBy': updatedBy,
  //     'updatedDate': updatedDate,
  //   };
  // }
}
