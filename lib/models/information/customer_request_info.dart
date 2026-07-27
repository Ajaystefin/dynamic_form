/// Represents response details for an application request.
class Response {
  /// Creates a [Response] instance.
  Response({
    this.applicationRefNo,
    this.purpose,
    this.requestType,
    this.subType,
    this.status,
    this.tpanRecievedDate,
    this.customerRimNumber,
    this.groupId,
    this.creditAppDate,
    this.customerName,
  });

  /// Creates a [Response] object from a JSON map.
  Response.fromJson(Map<String, dynamic> json) {
    applicationRefNo = json["applicationRefNo"];
    purpose = json["purpose"];
    requestType = json["requestType"];
    subType = json["subType"];
    status = json["status"];
    tpanRecievedDate = json["tpanRecievedDate"];
    customerRimNumber = json["customerRimNumber"];
    groupId = json["groupId"];
    creditAppDate = json["creditAppDate"];
    customerName = json["customerName"];
  }

  /// Application reference number.
  String? applicationRefNo;

  /// Purpose of the request.
  String? purpose;

  /// Type of request.
  String? requestType;

  /// Subtype of request.
  String? subType;

  /// Current status of the response.
  String? status;

  /// TPAN received date.
  String? tpanRecievedDate;

  /// Customer RIM number.
  int? customerRimNumber;

  /// Group identifier.
  int? groupId;

  /// Credit application date.
  String? creditAppDate;

  /// Customer name.
  String? customerName;

  //##For Hide Unit testing coverage if need add unit testing also

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data['applicationRefNo'] = applicationRefNo;
  //   data['purpose'] = purpose;
  //   data['requestType'] = requestType;
  //   data['status'] = status;
  //   data['tpanRecievedDate'] = tpanRecievedDate;
  //   data['customerRimNumber'] = customerRimNumber;
  //   data['groupId'] = groupId;
  //   data['creditAppDate'] = creditAppDate;
  //   data['customerName'] = customerName;
  //   return data;
  // }
}
