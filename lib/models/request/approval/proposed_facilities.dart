class ProposedFacilities {
  ProposedFacilities({
    required this.applicationRefNo,
    required this.purpose,
    required this.requestType,
    required this.tpanReceivedDate,
    required this.customerRimNumber,
    required this.groupId,
    required this.creditAppDate,
    required this.customerName,
    required this.cleanExposure,
    this.status,
  });

  factory ProposedFacilities.fromJson(Map<String, dynamic> json) =>
      ProposedFacilities(
        applicationRefNo: json["applicationRefNo"] as String,
        purpose: json["purpose"] ?? "",
        requestType: json["requestType"] as String,
        status: json["status"] ?? "",
        tpanReceivedDate: DateTime.parse(json["tpanRecievedDate"] as String),
        customerRimNumber: json["customerRimNumber"] as int,
        groupId: json["groupId"] as int,
        creditAppDate: DateTime.parse(json["creditAppDate"] as String),
        customerName: json["customerName"] as String,
        cleanExposure: json["cleanExposure"] ?? 0,
      );
  final String applicationRefNo;
  final String purpose;
  final String requestType;
  final String? status;
  final DateTime tpanReceivedDate;
  final int customerRimNumber;
  final int groupId;
  final DateTime creditAppDate;
  final String customerName;
  final int cleanExposure; // check the key

  Map<String, dynamic> toJson() => {
        "applicationRefNo": applicationRefNo,
        "purpose": purpose,
        "requestType": requestType,
        "status": status,
        "tpanRecievedDate": tpanReceivedDate.toUtc().toIso8601String(),
        "customerRimNumber": customerRimNumber,
        "groupId": groupId,
        "creditAppDate": creditAppDate.toUtc().toIso8601String(),
        "customerName": customerName,
      };
}
