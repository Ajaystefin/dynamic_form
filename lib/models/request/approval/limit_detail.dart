class LimitDetail {
  String? custName;
  int? rimNo;
  int? limitNumber;
  int? proposedLimit;
  int? presentLimit;

  LimitDetail(
      {this.custName,
      this.rimNo,
      this.limitNumber,
      this.proposedLimit,
      this.presentLimit});

  LimitDetail.fromJson(Map<String, dynamic> json) {
    custName = json['custName'];
    rimNo = json['rimNo'];
    limitNumber = json['limitNumber'];
    proposedLimit = json['proposedLimit'];
    presentLimit = json['presentLimit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['custName'] = custName;
    data['rimNo'] = rimNo;
    data['limitNumber'] = limitNumber;
    data['proposedLimit'] = proposedLimit;
    data['presentLimit'] = presentLimit;
    return data;
  }
}
