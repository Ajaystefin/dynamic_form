class CBRB {
  int? rimNo;
  String? customerName;
  int? fundedLimitAllBanks;
  int? nonFundedLimitAllBanks;
  int? fundedOutstandingAllBanks;
  int? nonFundedOutstandingAllBanks;
  int? fundedLimitCBD;
  int? nonFundedLimitCBD;
  int? fundedOutstandingCBD;
  int? nonFundedOutstandingCBD;
  String? shareOfWalletLimit;
  String? shareOfWalletOutstanding;
  int? noOfBanks;
  String? cbrbClassifications;
  bool? news;
  bool? deleted;

  CBRB({
    this.rimNo,
    this.customerName,
    this.fundedLimitAllBanks,
    this.nonFundedLimitAllBanks,
    this.fundedOutstandingAllBanks,
    this.nonFundedOutstandingAllBanks,
    this.fundedLimitCBD,
    this.nonFundedLimitCBD,
    this.fundedOutstandingCBD,
    this.nonFundedOutstandingCBD,
    this.shareOfWalletLimit,
    this.shareOfWalletOutstanding,
    this.noOfBanks,
    this.cbrbClassifications,
    this.news,
    this.deleted,
  });

  CBRB.fromJson(Map<String, dynamic> json) {
    rimNo = json['rimNo'];
    customerName = json['customerName'];
    fundedLimitAllBanks = json['fundedLimitAllBanks'];
    nonFundedLimitAllBanks = json['nonFundedLimitAllBanks'];
    fundedOutstandingAllBanks = json['fundedOutstandingAllBanks'];
    nonFundedOutstandingAllBanks = json['nonFundedOutstandingAllBanks'];
    fundedLimitCBD = json['fundedLimitCBD'];
    nonFundedLimitCBD = json['nonFundedLimitCBD'];
    fundedOutstandingCBD = json['fundedOutstandingCBD'];
    nonFundedOutstandingCBD = json['nonFundedOutstandingCBD'];
    shareOfWalletLimit = json['shareOfWalletLimit'];
    shareOfWalletOutstanding = json['shareOfWalletOutstanding'];
    noOfBanks = json['noOfBanks'];
    cbrbClassifications = json['cbrbClassifications'];
    deleted = json['deleted'];
    news = json['new'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rimNo'] = rimNo;
    data['customerName'] = customerName;
    data['fundedLimitAllBanks'] = fundedLimitAllBanks;
    data['nonFundedLimitAllBanks'] = nonFundedLimitAllBanks;
    data['fundedOutstandingAllBanks'] = fundedOutstandingAllBanks;
    data['nonFundedOutstandingAllBanks'] = nonFundedOutstandingAllBanks;
    data['fundedLimitCBD'] = fundedLimitCBD;
    data['nonFundedLimitCBD'] = nonFundedLimitCBD;
    data['fundedOutstandingCBD'] = fundedOutstandingCBD;
    data['nonFundedOutstandingCBD'] = nonFundedOutstandingCBD;
    data['shareOfWalletLimit'] = shareOfWalletLimit;
    data['shareOfWalletOutstanding'] = shareOfWalletOutstanding;
    data['noOfBanks'] = noOfBanks;
    data['cbrbClassifications'] = cbrbClassifications;
    data['new'] = news;
    data['deleted'] = deleted;
    return data;
  }
}
