import "package:decimal/decimal.dart";

/// Represents CBRB information for a customer,
/// including limits, outstanding amounts, and classifications.
class CBRB {
  /// Creates a [CBRB] instance.
  CBRB({
    this.cbrbDataId,
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
    this.directLimit,
    this.indirectLimit,
    this.directOutstanding,
    this.indirectOutstanding,
    this.isDeletable,
    this.hasRim,
  });

  /// Creates a [CBRB] instance from a JSON map.
  CBRB.fromJson(Map<String, dynamic> json) {
    cbrbDataId = json["cbrbDataId"];
    rimNo = json["rimNo"];
    customerName = json["customerName"];
    fundedLimitAllBanks = json["fundedLimitAllBanks"];
    nonFundedLimitAllBanks = json["nonFundedLimitAllBanks"];
    fundedOutstandingAllBanks = json["fundedOutstandingAllBanks"];
    nonFundedOutstandingAllBanks = json["nonFundedOutstandingAllBanks"];
    fundedLimitCBD = json["fundedLimitCBD"];
    nonFundedLimitCBD = json["nonFundedLimitCBD"];
    fundedOutstandingCBD = json["fundedOutstandingCBD"];
    nonFundedOutstandingCBD = json["nonFundedOutstandingCBD"];
    shareOfWalletLimit = json["shareOfWalletLimit"];
    shareOfWalletOutstanding = json["shareOfWalletOutstanding"];
    noOfBanks = json["noOfBanks"];
    cbrbClassifications = json["cbrbClassifications"];
    deleted = json["deleted"];
    news = json["new"];
    isDeletable = json["isDeletable"] == 1;
    directLimit = Decimal.tryParse(json["directLimit"]?.toString() ?? "0");
    indirectLimit = Decimal.tryParse(json["indirectLimit"]?.toString() ?? "0");
    directOutstanding =
        Decimal.tryParse(json["directOutstanding"]?.toString() ?? "0");
    indirectOutstanding =
        Decimal.tryParse(json["indirectOutstanding"]?.toString() ?? "0");
    hasRim = (int.tryParse(json["rimNo"]?.toString() ?? "0") ?? 0) > 0;
  }

  /// CBRB data identifier.
  int? cbrbDataId;

  /// Customer RIM number.
  int? rimNo;

  /// Customer name.
  String? customerName;

  /// Funded limit across all banks.
  int? fundedLimitAllBanks;

  /// Non-funded limit across all banks.
  int? nonFundedLimitAllBanks;

  /// Funded outstanding amount across all banks.
  int? fundedOutstandingAllBanks;

  /// Non-funded outstanding amount across all banks.
  int? nonFundedOutstandingAllBanks;

  /// Funded limit with CBD.
  int? fundedLimitCBD;

  /// Non-funded limit with CBD.
  int? nonFundedLimitCBD;

  /// Funded outstanding amount with CBD.
  int? fundedOutstandingCBD;

  /// Non-funded outstanding amount with CBD.
  int? nonFundedOutstandingCBD;

  /// Share of wallet limit percentage.
  double? shareOfWalletLimit;

  /// Share of wallet outstanding percentage.
  double? shareOfWalletOutstanding;

  /// Number of banks.
  int? noOfBanks;

  /// CBRB classifications.
  String? cbrbClassifications;

  /// Indicates whether the record is new.
  bool? news;

  /// Indicates whether the record is deleted.
  bool? deleted;

  /// Indicates whether the record can be deleted.
  bool? isDeletable;

  /// Indicates whether a valid RIM exists.
  bool? hasRim;

  /// Direct limit amount.
  Decimal? directLimit;

  /// Indirect limit amount.
  Decimal? indirectLimit;

  /// Direct outstanding amount.
  Decimal? directOutstanding;

  /// Indirect outstanding amount.
  Decimal? indirectOutstanding;

  /// Converts this [CBRB] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["cbrbDataId"] = cbrbDataId;
    data["rimNo"] = rimNo;
    data["customerName"] = customerName;
    data["fundedLimitAllBanks"] = fundedLimitAllBanks;
    data["nonFundedLimitAllBanks"] = nonFundedLimitAllBanks;
    data["fundedOutstandingAllBanks"] = fundedOutstandingAllBanks;
    data["nonFundedOutstandingAllBanks"] = nonFundedOutstandingAllBanks;
    data["fundedLimitCBD"] = fundedLimitCBD;
    data["nonFundedLimitCBD"] = nonFundedLimitCBD;
    data["fundedOutstandingCBD"] = fundedOutstandingCBD;
    data["nonFundedOutstandingCBD"] = nonFundedOutstandingCBD;
    data["shareOfWalletLimit"] = shareOfWalletLimit;
    data["shareOfWalletOutstanding"] = shareOfWalletOutstanding;
    data["noOfBanks"] = noOfBanks.toString();
    data["cbrbClassifications"] = cbrbClassifications;
    data["new"] = news;
    data["deleted"] = deleted;
    data["directLimit"] = directLimit.toString();
    data["indirectLimit"] = indirectLimit.toString();
    data["directOutstanding"] = directOutstanding.toString();
    data["indirectOutstanding"] = indirectOutstanding.toString();
    return data;
  }
}
