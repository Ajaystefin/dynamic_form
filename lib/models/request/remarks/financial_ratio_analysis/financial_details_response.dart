class FinancialDetailsResponse {
  final int entityId;
  final String longName;
  final String shortName;
  final List<Statement> statements;
  final Map<String, List<MacroItem>> macros;

  FinancialDetailsResponse({
    required this.entityId,
    required this.longName,
    required this.shortName,
    required this.statements,
    required this.macros,
  });

  factory FinancialDetailsResponse.fromJson(Map<String, dynamic> json) {
    final stmts = (json['statements'] as List<dynamic>)
        .map((e) => Statement.fromJson(e as Map<String, dynamic>))
        .toList();
    final macrosJson = json['macros'] as Map<String, dynamic>;
    final macroMap = macrosJson.map<String, List<MacroItem>>(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>)
            .map((e) => MacroItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );

    return FinancialDetailsResponse(
      entityId: json['EntityId'] as int,
      longName: json['LongName'] as String,
      shortName: json['ShortName'] as String,
      statements: stmts,
      macros: macroMap,
    );
  }

  Map<String, dynamic> toJson() => {
        'EntityId': entityId,
        'LongName': longName,
        'ShortName': shortName,
        'statements': statements.map((s) => s.toJson()).toList(),
        'macros': macros.map((k, v) =>
            MapEntry(k, v.map((item) => item.toJson()).toList())),
      };
}

class Statement {
  final int id;
  final DateTime date;
  final int periods;
  final List<StatementConst> statementConsts;

  Statement({
    required this.id,
    required this.date,
    required this.periods,
    required this.statementConsts,
  });

  factory Statement.fromJson(Map<String, dynamic> json) {
    return Statement(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      periods: json['periods'] as int,
      statementConsts: (json['statementConsts'] as List<dynamic>)
          .map((e) => StatementConst.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'periods': periods,
        'statementConsts':
            statementConsts.map((c) => c.toJson()).toList(),
      };
}

class StatementConst {
  final int id;
  final String value;

  StatementConst({
    required this.id,
    required this.value,
  });

  factory StatementConst.fromJson(Map<String, dynamic> json) {
    return StatementConst(
      id: json['id'] as int,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'value': value,
      };
}

class MacroItem {
  final int stmtID;
  final DateTime stmtDate;
  final String value;

  MacroItem({
    required this.stmtID,
    required this.stmtDate,
    required this.value,
  });

  factory MacroItem.fromJson(Map<String, dynamic> json) {
    return MacroItem(
      stmtID: json['stmtID'] as int,
      stmtDate: DateTime.parse(json['stmtDate'] as String),
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'stmtID': stmtID,
        'stmtDate': stmtDate.toIso8601String(),
        'value': value,
      };
}
