import "package:decimal/decimal.dart";

class CBRB {
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
    this.directLimit,
    this.indirectLimit,
    this.directOutstanding,
    this.indirectOutstanding,
    this.isDeletable,
  });

  CBRB.fromJson(Map<String, dynamic> json) {
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
    isDeletable = json["isDeletable"] == 1 ? true : false;
    directLimit = Decimal.tryParse(json["directLimit"]?.toString() ?? "0");
    indirectLimit = Decimal.tryParse(json["indirectLimit"]?.toString() ?? "0");
    directOutstanding =
        Decimal.tryParse(json["directOutstanding"]?.toString() ?? "0");
    indirectOutstanding =
        Decimal.tryParse(json["indirectOutstanding"]?.toString() ?? "0");
  }
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
  double? shareOfWalletLimit;
  double? shareOfWalletOutstanding;
  int? noOfBanks;
  String? cbrbClassifications;
  bool? news;
  bool? deleted;
  bool? isDeletable;

  Decimal? directLimit;
  Decimal? indirectLimit;
  Decimal? directOutstanding;
  Decimal? indirectOutstanding;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
