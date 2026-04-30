class LimitDetail {
  LimitDetail({
    this.custName,
    this.rimNo,
    this.limitNumber,
    this.proposedLimit,
    this.presentLimit,
  });

  LimitDetail.fromJson(Map<String, dynamic> json) {
    custName = json["custName"];
    rimNo = json["rimNo"];
    limitNumber = json["limitNumber"] ?? "";
    proposedLimit = json["proposedLimit"] ?? 0;
    presentLimit = json["presentLimit"] ?? 0;
  }
  String? custName;
  int? rimNo;
  String? limitNumber;
  int? proposedLimit;
  int? presentLimit;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["custName"] = custName;
    data["rimNo"] = rimNo;
    data["limitNumber"] = limitNumber;
    data["proposedLimit"] = proposedLimit;
    data["presentLimit"] = presentLimit;
    return data;
  }
}
