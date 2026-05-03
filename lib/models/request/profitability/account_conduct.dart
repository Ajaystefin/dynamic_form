class AccountConductResponseData {
  AccountConductResponseData({
    this.accountConductDtoList,
    this.previousYearLable,
    this.currentYearLable,
  });

  factory AccountConductResponseData.fromJson(Map<String, dynamic> json) {
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

  /// Note: backend key is `previousYearLable` (typo). Kept as-is.
  final String? previousYearLable;
  final String? currentYearLable;

  /// Normalized getters (optional convenience)
  String? get previousYearLabel => previousYearLable;
  String? get currentYearLabel => currentYearLable;

  List<AccountConductDto>? accountConductDtoList = [];

  /// copyWith to preserve immutability while allowing updates
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
class AccountConductDto {
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

  factory AccountConductDto.fromJson(Map<String, dynamic> json) {
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
  final int? rimNo;
  final String? custName;

  final String? passDueOrExcesses;
  final String? chequeReturns;
  final String? turnoverInAcc;
  final String? odHardcore;
  final String? unusualTransactions;
  final String? transparencyDisclosureLevels;

  final List<AccountConductDetail> accountConductDetailsList;

  /// copyWith to allow UI edits (immutability friendly)
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
class AccountConductDetail {
  const AccountConductDetail({
    this.name,
    this.previousYear,
    this.currentYear,
    this.custName,
    this.rimNo,
  });

  factory AccountConductDetail.fromJson(Map<String, dynamic> json) {
    return AccountConductDetail(
      name: json["name"] as String?,
      previousYear: json["previousYear"] as String?,
      currentYear: json["currentYear"] as String?,
      custName: json["custName"] as String?,
      rimNo: _toInt(json["rimNo"]),
    );
  }
  final String? name;
  final String? previousYear; // backend sample uses empty strings
  final String? currentYear; // backend sample uses empty strings
  final String? custName;
  final int? rimNo;

  /// copyWith to support edits to detail rows if needed
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

// ---------- helpers ----------
int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String && v.trim().isNotEmpty) return int.tryParse(v.trim());
  return null;
}

// num? _toNum(dynamic v) {
//   if (v == null) return null;
//   if (v is num) return v;
//   if (v is String && v.trim().isNotEmpty) return num.tryParse(v.trim());
//   return null;
// }
