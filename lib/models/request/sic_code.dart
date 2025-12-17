class SicCodeReview {
  int? sicCodeReviewId;
  int? custInfoId;
  String? appRefNo;
  int? rimNo;
  int? facilityId;
  int? customerRimNo;
  String? customerName;
  String? primaryBusinessActivity;
  String? existingSicCode;
  String? proposedSicCode;
  String? accountLevelSicCode;
  String? createdBy;
  String? createdDate;
  String? updatedBy;
  String? updatedDate;

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

  factory SicCodeReview.fromJson(Map<String, dynamic> json) {
    return SicCodeReview(
      sicCodeReviewId: json['sicCodeReviewId'],
      custInfoId: json['custInfoId'],
      appRefNo: json['appRefNo'],
      rimNo: json['rimNo'],
      facilityId: json['facilityId'],
      customerRimNo: json['rimNo'],
      customerName: json['customerName'],
      primaryBusinessActivity: json['primaryBusinessActivity'],
      existingSicCode: json['industryCbdSicCode'],
      proposedSicCode: json['proposedSicCode'],
      accountLevelSicCode: json['accountLevelSicCode'],
      createdBy: json['createdBy'],
      createdDate: json['createdDate'],
      updatedBy: json['updatedBy'],
      updatedDate: json['updatedDate'],
    );
  }

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
