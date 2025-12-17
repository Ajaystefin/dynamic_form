class ShareOfWalletData {
  int? rim;
  String? customerName;
  int? allBankTotalLimit;
  int? allBankTotalOutstanding;
  int? cbdTotalLimit;
  int? cbdTotalOutstanding;
  String? shareOfWalletLimit;
  String? shareOfWalletOutstanding;

  ShareOfWalletData(
      {this.rim,
      this.customerName,
      this.allBankTotalLimit,
      this.allBankTotalOutstanding,
      this.cbdTotalLimit,
      this.cbdTotalOutstanding,
      this.shareOfWalletLimit,
      this.shareOfWalletOutstanding});

  ShareOfWalletData.fromJson(Map<String, dynamic> json) {
    rim = json['rim'];
    customerName = json['customerName'];
    allBankTotalLimit = json['allBankTotalLimit'];
    allBankTotalOutstanding = json['allBankTotalOutstanding'];
    cbdTotalLimit = json['cbdTotalLimit'];
    cbdTotalOutstanding = json['cbdTotalOutstanding'];
    shareOfWalletLimit = json['shareOfWalletLimit'];
    shareOfWalletOutstanding = json['shareOfWalletOutstanding'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rim'] = rim;
    data['customerName'] = customerName;
    data['allBankTotalLimit'] = allBankTotalLimit;
    data['allBankTotalOutstanding'] = allBankTotalOutstanding;
    data['cbdTotalLimit'] = cbdTotalLimit;
    data['cbdTotalOutstanding'] = cbdTotalOutstanding;
    data['shareOfWalletLimit'] = shareOfWalletLimit;
    data['shareOfWalletOutstanding'] = shareOfWalletOutstanding;
    return data;
  }
}
