class Response {
  String? applicationRefNo;
  String? purpose;
  String? requestType;
  String? status;
  String? tpanRecievedDate;
  int? customerRimNumber;
  int? groupId;
  String? creditAppDate;
  String? customerName;

  Response(
      {this.applicationRefNo,
      this.purpose,
      this.requestType,
      this.status,
      this.tpanRecievedDate,
      this.customerRimNumber,
      this.groupId,
      this.creditAppDate,
      this.customerName});

  Response.fromJson(Map<String, dynamic> json) {
    applicationRefNo = json['applicationRefNo'];
    purpose = json['purpose'];
    requestType = json['requestType'];
    status = json['status'];
    tpanRecievedDate = json['tpanRecievedDate'];
    customerRimNumber = json['customerRimNumber'];
    groupId = json['groupId'];
    creditAppDate = json['creditAppDate'];
    customerName = json['customerName'];
  }

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
