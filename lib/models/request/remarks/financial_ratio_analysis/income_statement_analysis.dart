/// Represents an income statement analysis row containing
/// audited, in-house, and estimated values.
class IncomeStatementAnalysisRow {
  /// Creates an [IncomeStatementAnalysisRow] instance.
  IncomeStatementAnalysisRow({
    required this.id,
    this.incomePositions = "",
    this.audited1 = "",
    this.audited2 = "",
    this.audited3 = "",
    this.inhouse = "",
    this.estimated = "",
    this.isNew = false,
  });

  /// Creates an [IncomeStatementAnalysisRow] instance from a JSON map.
  factory IncomeStatementAnalysisRow.fromJson(
    Map<String, dynamic> json,
  ) {
    return IncomeStatementAnalysisRow(
      id: json["id"] as String,
      incomePositions: json["incomePositions"] as String? ?? "",
      audited1: json["audited1"] as String? ?? "",
      audited2: json["audited2"] as String? ?? "",
      audited3: json["audited3"] as String? ?? "",
      inhouse: json["inhouse"] as String? ?? "",
      estimated: json["estimated"] as String? ?? "",
      isNew: json["isNew"] as bool? ?? false,
    );
  }

  /// Identifier of the income statement row.
  String id;

  /// Income statement position.
  String incomePositions;

  /// Audited value for period 1.
  String audited1;

  /// Audited value for period 2.
  String audited2;

  /// Audited value for period 3.
  String audited3;

  /// In-house value.
  String inhouse;

  /// Estimated value.
  String estimated;

  /// Indicates whether the row was added by the user.
  bool isNew;

  /// Converts this [IncomeStatementAnalysisRow] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "incomePositions": incomePositions,
      "audited1": audited1,
      "audited2": audited2,
      "audited3": audited3,
      "inhouse": inhouse,
      "estimated": estimated,
      "isNew": isNew,
    };
  }
}
