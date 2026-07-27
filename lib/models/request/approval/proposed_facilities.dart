/// Represents proposed facility details for an application,
/// including request information, customer details, dates, and exposure value.
class ProposedFacilities {
  /// Creates a [ProposedFacilities] instance.
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

  /// Creates a [ProposedFacilities] instance from a JSON map.
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

  /// Application reference number.
  final String applicationRefNo;

  /// Purpose of the proposed facility.
  final String purpose;

  /// Request type of the proposed facility.
  final String requestType;

  /// Current status of the proposed facility.
  final String? status;

  /// TPAN received date.
  final DateTime tpanReceivedDate;

  /// Customer RIM number.
  final int customerRimNumber;

  /// Group identifier.
  final int groupId;

  /// Credit application date.
  final DateTime creditAppDate;

  /// Customer name.
  final String customerName;

  /// Clean exposure value.
  final int cleanExposure; // check the key

  /// Converts this [ProposedFacilities] instance into a JSON map.
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
