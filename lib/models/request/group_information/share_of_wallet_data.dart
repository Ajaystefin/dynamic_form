class ShareOfWalletData {
  ShareOfWalletData({
    this.rim,
    this.customerName,
    this.allBankTotalLimit,
    this.allBankTotalOutstanding,
    this.cbdTotalLimit,
    this.cbdTotalOutstanding,
    this.shareOfWalletLimit,
    this.shareOfWalletOutstanding,
  });

  factory ShareOfWalletData.fromJson(Map<String, dynamic> json) {
    return ShareOfWalletData(
      rim: _asInt(json["rim"]),
      customerName: json["customerName"] as String?,
      allBankTotalLimit: _asDouble(json["allBankTotalLimit"]),
      allBankTotalOutstanding: _asDouble(json["allBankTotalOutstanding"]),
      cbdTotalLimit: _asDouble(json["cbdTotalLimit"]),
      cbdTotalOutstanding: _asDouble(json["cbdTotalOutstanding"]),
      shareOfWalletLimit: _asDouble(json["shareOfWalletLimit"]),
      shareOfWalletOutstanding: _asDouble(json["shareOfWalletOutstanding"]),
    );
  }
  int? rim;
  String? customerName;

  // amounts: use double? to handle both 0 and 0.00 consistently
  double? allBankTotalLimit;
  double? allBankTotalOutstanding;
  double? cbdTotalLimit;
  double? cbdTotalOutstanding;
  double? shareOfWalletLimit;
  double? shareOfWalletOutstanding;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "rim": rim,
      "customerName": customerName,
      "allBankTotalLimit": allBankTotalLimit,
      "allBankTotalOutstanding": allBankTotalOutstanding,
      "cbdTotalLimit": cbdTotalLimit,
      "cbdTotalOutstanding": cbdTotalOutstanding,
      "shareOfWalletLimit": shareOfWalletLimit,
      "shareOfWalletOutstanding": shareOfWalletOutstanding,
    };
  }
}

/// ---- tolerant helpers (int/double/string/null) ----

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

double? _asDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble(); // handles int and double
  if (v is String) return double.tryParse(v);
  return null;
}
