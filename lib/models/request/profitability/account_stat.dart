/// Represents account statistics information for a customer.
class AccountStatType {
  /// Creates an [AccountStatType] instance.
  AccountStatType({this.rim, this.customerName, this.accountConduct});

  /// Creates an [AccountStatType] instance from a JSON map.
  AccountStatType.fromJson(Map<String, dynamic> json) {
    rim = json["rim"];
    customerName = json["customerName"];
    accountConduct = json["accountConduct"] != null
        ? AccountStat.fromJson(json["accountConduct"])
        : null;
  }

  /// Customer RIM number.
  int? rim;

  /// Customer name.
  String? customerName;

  /// Account conduct statistics.
  AccountStat? accountConduct;

  /// Converts this [AccountStatType] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["rim"] = rim;
    data["customerName"] = customerName;
    if (accountConduct != null) {
      data["accountConduct"] = accountConduct!.toJson();
    }
    return data;
  }
}

/// Represents detailed account conduct statistics.
class AccountStat {
  /// Creates an [AccountStat] instance.
  AccountStat({
    this.odHardcorePreviousYear,
    this.odHardcoreCurrentYearYtd,
    this.chequeReturnsInwardPreviousYear,
    this.chequeReturnsInwardCurrentYearYtd,
    this.chequeReturnsOutwardPreviousYear,
    this.chequeReturnsOutwardCurrentYearYtd,
    this.lbdReturnsPreviousYear,
    this.lbdReturnsCurrentYearYtd,
    this.passDueOrExcesses,
    this.chequeReturns,
    this.turnoverInTheAccount,
    this.odHardcore,
    this.unusualTransactions,
    this.transparencyAndDisclosureLevels,
    this.product,
    this.accountCommitmentNumber,
    this.highBalancePreviousYear,
    this.lowBalancePreviousYear,
    this.averageBalancePreviousYear,
    this.turnoverPreviousYear,
    this.highBalanceCurrentYear,
    this.lowBalanceCurrentYear,
    this.averageBalanceCurrentYear,
    this.turnoverCurrentYear,
  });

  /// Creates an [AccountStat] instance from a JSON map.
  AccountStat.fromJson(Map<String, dynamic> json) {
    odHardcorePreviousYear = json["odHardcorePreviousYear"];
    odHardcoreCurrentYearYtd = json["odHardcoreCurrentYearYtd"];
    chequeReturnsInwardPreviousYear = json["chequeReturnsInwardPreviousYear"];
    chequeReturnsInwardCurrentYearYtd =
        json["chequeReturnsInwardCurrentYearYtd"];
    chequeReturnsOutwardPreviousYear = json["chequeReturnsOutwardPreviousYear"];
    chequeReturnsOutwardCurrentYearYtd =
        json["chequeReturnsOutwardCurrentYearYtd"];
    lbdReturnsPreviousYear = json["lbdReturnsPreviousYear"];
    lbdReturnsCurrentYearYtd = json["lbdReturnsCurrentYearYtd"];
    passDueOrExcesses = json["pastDueOrExcesses"];
    chequeReturns = json["chequeReturns"];
    turnoverInTheAccount = json["turnoverInTheAccount"];
    odHardcore = json["odHardcore"];
    unusualTransactions = json["unusualTransactions"];
    transparencyAndDisclosureLevels = json["transparencyAndDisclosureLevels"];
    product = json["productDescription"];
    accountCommitmentNumber = json["accountCommitmentNo"];
    highBalancePreviousYear = json["maxBalPrvYr"];
    lowBalancePreviousYear = json["minBalPrvYr"];
    averageBalancePreviousYear = json["avgBalPrvYrCr"];
    turnoverPreviousYear = json["creditTrovPrvYr"];
    highBalanceCurrentYear = json["maxBalCurYr"];
    lowBalanceCurrentYear = json["minBalCurYr"];
    averageBalanceCurrentYear = json["avgBalCurYrCr"];
    turnoverCurrentYear = json["creditTrovCurYr"];
  }

  /// odHardcorePreviousYear
  double? odHardcorePreviousYear;

  /// odHardcoreCurrentYearYtd
  double? odHardcoreCurrentYearYtd;

  /// chequeReturnsInwardPreviousYear
  int? chequeReturnsInwardPreviousYear;

  /// chequeReturnsInwardCurrentYearYtd
  int? chequeReturnsInwardCurrentYearYtd;

  /// chequeReturnsOutwardPreviousYear
  int? chequeReturnsOutwardPreviousYear;

  /// chequeReturnsOutwardCurrentYearYtd
  int? chequeReturnsOutwardCurrentYearYtd;

  /// lbdReturnsPreviousYear
  int? lbdReturnsPreviousYear;

  /// lbdReturnsCurrentYearYtd
  int? lbdReturnsCurrentYearYtd;

  /// passDueOrExcesses
  double? passDueOrExcesses;

  /// chequeReturns
  double? chequeReturns;

  /// turnoverInTheAccount
  double? turnoverInTheAccount;

  /// odHardcore
  double? odHardcore;

  /// unusualTransactions
  double? unusualTransactions;

  /// transparencyAndDisclosureLevels
  double? transparencyAndDisclosureLevels;

  /// product
  String? product;

  /// accountCommitmentNumber
  String? accountCommitmentNumber;

  /// highBalancePreviousYear
  String? highBalancePreviousYear;

  /// lowBalancePreviousYear
  String? lowBalancePreviousYear;

  /// averageBalancePreviousYear
  String? averageBalancePreviousYear;

  /// turnoverPreviousYear
  String? turnoverPreviousYear;

  /// highBalanceCurrentYear
  String? highBalanceCurrentYear;

  /// lowBalanceCurrentYear
  String? lowBalanceCurrentYear;

  /// averageBalanceCurrentYear
  String? averageBalanceCurrentYear;

  /// turnoverCurrentYear
  String? turnoverCurrentYear;

  /// Converts this [AccountStat] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["odHardcorePreviousYear"] = odHardcorePreviousYear;
    data["odHardcoreCurrentYearYtd"] = odHardcoreCurrentYearYtd;
    data["chequeReturnsInwardPreviousYear"] = chequeReturnsInwardPreviousYear;
    data["chequeReturnsInwardCurrentYearYtd"] =
        chequeReturnsInwardCurrentYearYtd;
    data["chequeReturnsOutwardPreviousYear"] = chequeReturnsOutwardPreviousYear;
    data["chequeReturnsOutwardCurrentYearYtd"] =
        chequeReturnsOutwardCurrentYearYtd;
    data["lbdReturnsPreviousYear"] = lbdReturnsPreviousYear;
    data["lbdReturnsCurrentYearYtd"] = lbdReturnsCurrentYearYtd;
    data["pastDueOrExcesses"] = passDueOrExcesses;
    data["chequeReturns"] = chequeReturns;
    data["turnoverInTheAccount"] = turnoverInTheAccount;
    data["odHardcore"] = odHardcore;
    data["unusualTransactions"] = unusualTransactions;
    data["transparencyAndDisclosureLevels"] = transparencyAndDisclosureLevels;
    data["productDescription"] = product;
    data["accountCommitmentNo"] = accountCommitmentNumber;
    data["maxBalPrvYr"] = highBalancePreviousYear;
    data["minBalPrvYr"] = lowBalancePreviousYear;
    data["avgBalPrvYrCr"] = averageBalancePreviousYear;
    data["creditTrovPrvYr"] = turnoverPreviousYear;
    data["maxBalCurYr"] = highBalanceCurrentYear;
    data["minBalCurYr"] = lowBalanceCurrentYear;
    data["avgBalCurYrCr"] = averageBalanceCurrentYear;
    data["creditTrovCurYr"] = turnoverCurrentYear;
    return data;
  }
}
