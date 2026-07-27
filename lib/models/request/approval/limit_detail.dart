/// Represents limit detail information for a customer.
class LimitDetail {
  /// Creates a [LimitDetail] instance.
  LimitDetail({
    this.custName,
    this.rimNo,
    this.limitNumber,
    this.proposedLimit,
    this.presentLimit,
  });

  /// Creates a [LimitDetail] instance from a JSON map.
  LimitDetail.fromJson(Map<String, dynamic> json) {
    custName = json["custName"];
    rimNo = json["rimNo"];
    limitNumber = json["limitNumber"] ?? "";
    proposedLimit = json["proposedLimit"] ?? 0;
    presentLimit = json["presentLimit"] ?? 0;
  }

  /// Customer name.
  String? custName;

  /// Customer RIM number.
  int? rimNo;

  /// Limit number.
  String? limitNumber;

  /// Proposed limit amount.
  int? proposedLimit;

  /// Present limit amount.
  int? presentLimit;

  /// Converts this [LimitDetail] instance into a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data["custName"] = custName;
    data["rimNo"] = rimNo;
    data["limitNumber"] = limitNumber;
    data["proposedLimit"] = proposedLimit;
    data["presentLimit"] = presentLimit;
    return data;
  }
}
