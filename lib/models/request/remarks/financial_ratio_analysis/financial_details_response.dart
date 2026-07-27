/// Represents financial details response data.
class FinancialDetailsResponse {
  /// Creates a [FinancialDetailsResponse] instance.
  FinancialDetailsResponse({
    required this.entityId,
    required this.longName,
    required this.shortName,
    required this.statements,
    required this.macros,
  });

  /// Creates a [FinancialDetailsResponse] instance from a JSON map.
  factory FinancialDetailsResponse.fromJson(Map<String, dynamic> json) {
    final List<Statement> stmts = (json["statements"] as List<dynamic>)
        .map((e) => Statement.fromJson(e as Map<String, dynamic>))
        .toList();
    final Map<String, dynamic> macrosJson =
        json["macros"] as Map<String, dynamic>;
    final Map<String, List<MacroItem>> macroMap =
        macrosJson.map<String, List<MacroItem>>(
      (String key, value) => MapEntry(
        key,
        (value as List<dynamic>)
            .map((e) => MacroItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );

    return FinancialDetailsResponse(
      entityId: json["EntityId"] as int,
      longName: json["LongName"] as String,
      shortName: json["ShortName"] as String,
      statements: stmts,
      macros: macroMap,
    );
  }

  /// Unique entity identifier.
  final int entityId;

  /// Entity long name.
  final String longName;

  /// Entity short name.
  final String shortName;

  /// Financial statements.
  final List<Statement> statements;

  /// Financial macros grouped by category.
  final Map<String, List<MacroItem>> macros;

  /// Converts this [FinancialDetailsResponse] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "EntityId": entityId,
        "LongName": longName,
        "ShortName": shortName,
        "statements": statements.map((s) => s.toJson()).toList(),
        "macros": macros.map(
          (String k, v) => MapEntry(k, v.map((item) => item.toJson()).toList()),
        ),
      };
}

/// Represents a financial statement.
class Statement {
  /// Creates a [Statement] instance.
  Statement({
    required this.id,
    required this.date,
    required this.periods,
    required this.statementConsts,
  });

  /// Creates a [Statement] instance from a JSON map.
  factory Statement.fromJson(Map<String, dynamic> json) {
    return Statement(
      id: json["id"] as int,
      date: DateTime.parse(json["date"] as String),
      periods: json["periods"] as int,
      statementConsts: (json["statementConsts"] as List<dynamic>)
          .map((e) => StatementConst.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Statement identifier.
  final int id;

  /// Statement date.
  final DateTime date;

  /// Reporting period count.
  final int periods;

  /// Statement constants.
  final List<StatementConst> statementConsts;

  /// Converts this [Statement] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date.toIso8601String(),
        "periods": periods,
        "statementConsts": statementConsts.map((c) => c.toJson()).toList(),
      };
}

/// Represents a statement constant.
class StatementConst {
  /// Creates a [StatementConst] instance.
  StatementConst({
    required this.id,
    required this.value,
  });

  /// Creates a [StatementConst] instance from a JSON map.
  factory StatementConst.fromJson(Map<String, dynamic> json) {
    return StatementConst(
      id: json["id"] as int,
      value: json["value"] as String,
    );
  }

  /// Constant identifier.
  final int id;

  /// Constant value.
  final String value;

  /// Converts this [StatementConst] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "id": id,
        "value": value,
      };
}

/// Represents a macro item associated with a financial statement.
class MacroItem {
  /// Creates a [MacroItem] instance.
  MacroItem({
    required this.stmtID,
    required this.stmtDate,
    required this.value,
  });

  /// Creates a [MacroItem] instance from a JSON map.
  factory MacroItem.fromJson(Map<String, dynamic> json) {
    return MacroItem(
      stmtID: json["stmtId"] as int,
      stmtDate: DateTime.parse(json["stmtDate"] as String),
      value: json["value"] as String,
    );
  }

  /// Statement identifier.
  final int stmtID;

  /// Statement date.
  final DateTime stmtDate;

  /// Macro value.
  final String value;

  /// Converts this [MacroItem] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "stmtId": stmtID,
        "stmtDate": stmtDate.toIso8601String(),
        "value": value,
      };
}
