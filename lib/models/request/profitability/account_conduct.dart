/// Represents account conduct response data,
/// including customer account conduct summaries and labels.
class AccountConductResponseData {
  /// Creates an [AccountConductResponseData] instance.
  AccountConductResponseData({
    this.accountConductDtoList,
    this.previousYearLable,
    this.currentYearLable,
  });

  /// Creates an [AccountConductResponseData] instance from a JSON map.
  factory AccountConductResponseData.fromJson(
    Map<String, dynamic> json,
  ) {
    final list = (json["accountConductDtoList"] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(AccountConductDto.fromJson)
            .toList() ??
        [];

    return AccountConductResponseData(
      accountConductDtoList: list,
      previousYearLable: json["previousYearLable"] as String?,
      currentYearLable: json["currentYearLable"] as String?,
    );
  }

  /// Backend label for the previous year.
  final String? previousYearLable;

  /// Backend label for the current year.
  final String? currentYearLable;

  /// List of account conduct records.
  List<AccountConductDto>? accountConductDtoList = [];

  /// Returns the normalized previous year label.
  String? get previousYearLabel => previousYearLable;

  /// Returns the normalized current year label.
  String? get currentYearLabel => currentYearLable;

  /// Creates a copy of this [AccountConductResponseData]
  /// with the specified fields replaced.
  AccountConductResponseData copyWith({
    List<AccountConductDto>? accountConductDtoList,
    String? previousYearLable,
    String? currentYearLable,
  }) {
    return AccountConductResponseData(
      accountConductDtoList:
          accountConductDtoList ?? this.accountConductDtoList,
      previousYearLable: previousYearLable ?? this.previousYearLable,
      currentYearLable: currentYearLable ?? this.currentYearLable,
    );
  }

  /// Converts this [AccountConductResponseData] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "previousYearLable": previousYearLable,
      "currentYearLable": currentYearLable,
      "accountConductDtoList":
          (accountConductDtoList ?? []).map((e) => e.toJson()).toList(),
    };
  }
}

/// Per-customer Account Conduct summary + details.
/// Matches keys: rimNo, custName, passDueOrExcesses, chequeReturns,
/// turnoverInAcc,
/// odHardcore, unusualTransactions, transparencyDisclosureLevels,
/// accountConductDetailsList

/// Represents account conduct information for a customer.
class AccountConductDto {
  /// Creates an [AccountConductDto] instance.
  const AccountConductDto({
    required this.accountConductDetailsList,
    this.rimNo,
    this.custName,
    this.passDueOrExcesses,
    this.chequeReturns,
    this.turnoverInAcc,
    this.odHardcore,
    this.unusualTransactions,
    this.transparencyDisclosureLevels,
  });

  /// Creates an [AccountConductDto] instance from a JSON map.
  factory AccountConductDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return AccountConductDto(
      rimNo: _toInt(json["rimNo"]),
      custName: json["custName"] as String?,
      passDueOrExcesses: json["pastDueOrExcesses"].toString(),
      chequeReturns: json["chequeReturns"].toString(),
      turnoverInAcc: json["turnoverInAcc"].toString(),
      odHardcore: json["odHardcore"].toString(),
      unusualTransactions: json["unusualTransactions"].toString(),
      transparencyDisclosureLevels:
          json["transparencyDisclosureLevels"].toString(),
      accountConductDetailsList:
          (json["accountConductDetailsList"] as List? ?? [])
              .map(
                (e) => AccountConductDetail.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }

  /// Customer RIM number.
  final int? rimNo;

  /// Customer name.
  final String? custName;

  /// Past due or excesses information.
  final String? passDueOrExcesses;

  /// Cheque return information.
  final String? chequeReturns;

  /// Turnover in account information.
  final String? turnoverInAcc;

  /// OD hardcore information.
  final String? odHardcore;

  /// Unusual transaction information.
  final String? unusualTransactions;

  /// Transparency disclosure levels.
  final String? transparencyDisclosureLevels;

  /// Account conduct detail records.
  final List<AccountConductDetail> accountConductDetailsList;

  /// Creates a copy of this [AccountConductDto]
  /// with the specified fields replaced.
  AccountConductDto copyWith({
    int? rimNo,
    String? custName,
    String? passDueOrExcesses,
    String? chequeReturns,
    String? turnoverInAcc,
    String? odHardcore,
    String? unusualTransactions,
    String? transparencyDisclosureLevels,
    List<AccountConductDetail>? accountConductDetailsList,
  }) {
    return AccountConductDto(
      rimNo: rimNo ?? this.rimNo,
      custName: custName ?? this.custName,
      passDueOrExcesses: passDueOrExcesses ?? this.passDueOrExcesses,
      chequeReturns: chequeReturns ?? this.chequeReturns,
      turnoverInAcc: turnoverInAcc ?? this.turnoverInAcc,
      odHardcore: odHardcore ?? this.odHardcore,
      unusualTransactions: unusualTransactions ?? this.unusualTransactions,
      transparencyDisclosureLevels:
          transparencyDisclosureLevels ?? this.transparencyDisclosureLevels,
      accountConductDetailsList:
          accountConductDetailsList ?? this.accountConductDetailsList,
    );
  }

  /// Converts this [AccountConductDto] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "rimNo": rimNo,
      "custName": custName,
      "pastDueOrExcesses": passDueOrExcesses,
      "chequeReturns": chequeReturns,
      "turnoverInAcc": turnoverInAcc,
      "odHardcore": odHardcore,
      "unusualTransactions": unusualTransactions,
      "transparencyDisclosureLevels": transparencyDisclosureLevels,
      "accountConductDetailsList":
          accountConductDetailsList.map((e) => e.toJson()).toList(),
    };
  }
}

/// Detail row with label and previous/current values.
/// Keys: name, previousYear, currentYear, custName, rimNo

/// Represents account conduct detail information.
class AccountConductDetail {
  /// Creates an [AccountConductDetail] instance.
  const AccountConductDetail({
    this.name,
    this.previousYear,
    this.currentYear,
    this.custName,
    this.rimNo,
  });

  /// Creates an [AccountConductDetail] instance from a JSON map.
  factory AccountConductDetail.fromJson(
    Map<String, dynamic> json,
  ) {
    return AccountConductDetail(
      name: json["name"] as String?,
      previousYear: json["previousYear"] as String?,
      currentYear: json["currentYear"] as String?,
      custName: json["custName"] as String?,
      rimNo: _toInt(json["rimNo"]),
    );
  }

  /// Detail name.
  final String? name;

  /// Previous year value.
  ///
  /// backend sample uses empty strings
  final String? previousYear;

  /// Current year value.
  ///
  /// backend sample uses empty strings
  final String? currentYear;

  /// Customer name.
  final String? custName;

  /// Customer RIM number.
  final int? rimNo;

  /// Creates a copy of this [AccountConductDetail]
  /// with the specified fields replaced.
  AccountConductDetail copyWith({
    String? name,
    String? previousYear,
    String? currentYear,
    String? custName,
    int? rimNo,
  }) {
    return AccountConductDetail(
      name: name ?? this.name,
      previousYear: previousYear ?? this.previousYear,
      currentYear: currentYear ?? this.currentYear,
      custName: custName ?? this.custName,
      rimNo: rimNo ?? this.rimNo,
    );
  }

  /// Converts this [AccountConductDetail] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "previousYear": previousYear,
      "currentYear": currentYear,
      "custName": custName,
      "rimNo": rimNo,
    };
  }
}

/// Converts a value to an integer if possible.
int? _toInt(v) {
  if (v == null) {
    return null;
  }
  if (v is int) {
    return v;
  }
  if (v is num) {
    return v.toInt();
  }
  if (v is String && v.trim().isNotEmpty) {
    return int.tryParse(v.trim());
  }
  return null;
}
