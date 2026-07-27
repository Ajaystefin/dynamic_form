/// Represents share of wallet data for a customer,
/// including limits, outstanding amounts, and wallet percentages.
class ShareOfWalletData {
  /// Creates a [ShareOfWalletData] instance.
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

  /// Creates a [ShareOfWalletData] instance from a JSON map.
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

  /// Customer RIM number.
  int? rim;

  /// Customer name.
  String? customerName;

  /// Total limits across all banks.
  ///
  ///  amounts: use double? to handle both 0 and 0.00 consistently
  double? allBankTotalLimit;

  /// Total outstanding amount across all banks.
  double? allBankTotalOutstanding;

  /// Total limits with CBD.
  double? cbdTotalLimit;

  /// Total outstanding amount with CBD.
  double? cbdTotalOutstanding;

  /// Share of wallet limit percentage.
  double? shareOfWalletLimit;

  /// Share of wallet outstanding percentage.
  double? shareOfWalletOutstanding;

  /// Converts this [ShareOfWalletData] instance to a JSON map.
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

/// Tolerant helper methods for parsing int/double values
/// from int, double, string, or null inputs.
/// Converts a value to an integer if possible.
int? _asInt(v) {
  if (v == null) {
    return null;
  }
  if (v is int) {
    return v;
  }
  if (v is double) {
    return v.toInt();
  }
  if (v is String) {
    return int.tryParse(v);
  }
  return null;
}

/// Converts a value to a double if possible.
double? _asDouble(v) {
  if (v == null) {
    return null;
  }
  if (v is num) {
    return v.toDouble(); // handles int and double
  }
  if (v is String) {
    return double.tryParse(v);
  }
  return null;
}
