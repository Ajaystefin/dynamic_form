class AccountStatType {
  int? rim;
  String? customerName;
  AccountStat? accountConduct;

  AccountStatType({this.rim, this.customerName, this.accountConduct});

  AccountStatType.fromJson(Map<String, dynamic> json) {
    rim = json['rim'];
    customerName = json['customerName'];
    accountConduct = json['accountConduct'] != null
        ? AccountStat.fromJson(json['accountConduct'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rim'] = rim;
    data['customerName'] = customerName;
    if (accountConduct != null) {
      data['accountConduct'] = accountConduct!.toJson();
    }
    return data;
  }
}

class AccountStat {
  double? odHardcorePreviousYear;
  double? odHardcoreCurrentYearYtd;
  int? chequeReturnsInwardPreviousYear;
  int? chequeReturnsInwardCurrentYearYtd;
  int? chequeReturnsOutwardPreviousYear;
  int? chequeReturnsOutwardCurrentYearYtd;
  int? lbdReturnsPreviousYear;
  int? lbdReturnsCurrentYearYtd;
  double? passDueOrExcesses;
  double? chequeReturns;
  double? turnoverInTheAccount;
  double? odHardcore;
  double? unusualTransactions;
  double? transparencyAndDisclosureLevels;

  String? product;
  String? accountCommitmentNumber;
  double? highBalancePreviousYear;
  double? lowBalancePreviousYear;
  double? averageBalancePreviousYear;
  double? turnoverPreviousYear;
  double? highBalanceCurrentYear;
  double? lowBalanceCurrentYear;
  double? averageBalanceCurrentYear;
  double? turnoverCurrentYear;

  AccountStat(
      {this.odHardcorePreviousYear,
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
      this.turnoverCurrentYear});

  AccountStat.fromJson(Map<String, dynamic> json) {
    odHardcorePreviousYear = json['odHardcorePreviousYear'];
    odHardcoreCurrentYearYtd = json['odHardcoreCurrentYearYtd'];
    chequeReturnsInwardPreviousYear = json['chequeReturnsInwardPreviousYear'];
    chequeReturnsInwardCurrentYearYtd =
        json['chequeReturnsInwardCurrentYearYtd'];
    chequeReturnsOutwardPreviousYear = json['chequeReturnsOutwardPreviousYear'];
    chequeReturnsOutwardCurrentYearYtd =
        json['chequeReturnsOutwardCurrentYearYtd'];
    lbdReturnsPreviousYear = json['lbdReturnsPreviousYear'];
    lbdReturnsCurrentYearYtd = json['lbdReturnsCurrentYearYtd'];
    passDueOrExcesses = json['passDueOrExcesses'];
    chequeReturns = json['chequeReturns'];
    turnoverInTheAccount = json['turnoverInTheAccount'];
    odHardcore = json['odHardcore'];
    unusualTransactions = json['unusualTransactions'];
    transparencyAndDisclosureLevels = json['transparencyAndDisclosureLevels'];
    product = json['productDescription'];
    accountCommitmentNumber = json['accountCommitmentNo'];
    highBalancePreviousYear = json['maxBalPrvYr'];
    lowBalancePreviousYear = json['minBalPrvYr'];
    averageBalancePreviousYear = json['avgBalPrvYrCr'];
    turnoverPreviousYear = json['creditTrovPrvYr'];
    highBalanceCurrentYear = json['maxBalCurYr'];
    lowBalanceCurrentYear = json['minBalCurYr'];
    averageBalanceCurrentYear = json['avgBalCurYrCr'];
    turnoverCurrentYear = json['creditTrovCurYr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['odHardcorePreviousYear'] = odHardcorePreviousYear;
    data['odHardcoreCurrentYearYtd'] = odHardcoreCurrentYearYtd;
    data['chequeReturnsInwardPreviousYear'] = chequeReturnsInwardPreviousYear;
    data['chequeReturnsInwardCurrentYearYtd'] =
        chequeReturnsInwardCurrentYearYtd;
    data['chequeReturnsOutwardPreviousYear'] = chequeReturnsOutwardPreviousYear;
    data['chequeReturnsOutwardCurrentYearYtd'] =
        chequeReturnsOutwardCurrentYearYtd;
    data['lbdReturnsPreviousYear'] = lbdReturnsPreviousYear;
    data['lbdReturnsCurrentYearYtd'] = lbdReturnsCurrentYearYtd;
    data['passDueOrExcesses'] = passDueOrExcesses;
    data['chequeReturns'] = chequeReturns;
    data['turnoverInTheAccount'] = turnoverInTheAccount;
    data['odHardcore'] = odHardcore;
    data['unusualTransactions'] = unusualTransactions;
    data['transparencyAndDisclosureLevels'] = transparencyAndDisclosureLevels;
    data['productDescription'] = product;
    data['accountCommitmentNo'] = accountCommitmentNumber;
    data['maxBalPrvYr'] = highBalancePreviousYear;
    data['minBalPrvYr'] = lowBalancePreviousYear;
    data['avgBalPrvYrCr'] = averageBalancePreviousYear;
    data['creditTrovPrvYr'] = turnoverPreviousYear;
    data['maxBalCurYr'] = highBalanceCurrentYear;
    data['minBalCurYr'] = lowBalanceCurrentYear;
    data['avgBalCurYrCr'] = averageBalanceCurrentYear;
    data['creditTrovCurYr'] = turnoverCurrentYear;
    return data;
  }
}
