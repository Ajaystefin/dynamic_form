/// Represents a balance sheet analysis row containing
/// audited, in-house, and estimated financial values.
class BalanceSheetAnalysisRow {
  /// Creates a [BalanceSheetAnalysisRow] instance.
  BalanceSheetAnalysisRow({
    required this.id,
    this.balanceSheet = "",
    this.audited1 = "",
    this.audited2 = "",
    this.audited3 = "",
    this.inhouse = "",
    this.estimated = "",
    this.isNew = false,
  });

  /// Creates a [BalanceSheetAnalysisRow] instance from a JSON map.
  factory BalanceSheetAnalysisRow.fromJson(Map<String, dynamic> json) {
    return BalanceSheetAnalysisRow(
      id: json["id"] as String,
      balanceSheet: json["balanceSheet"] as String? ?? "",
      audited1: json["audited1"] as String? ?? "",
      audited2: json["audited2"] as String? ?? "",
      audited3: json["audited3"] as String? ?? "",
      inhouse: json["inhouse"] as String? ?? "",
      estimated: json["estimated"] as String? ?? "",
      isNew: json["isNew"] as bool? ?? false,
    );
  }

  /// id
  String id;

  /// balanceSheet
  String balanceSheet;

  /// audited1
  String audited1;

  /// audited2
  String audited2;

  /// audited3
  String audited3;

  /// inhouse
  String inhouse;

  /// estimated
  String estimated;

  /// isNew
  bool isNew;

  /// Converts this [BalanceSheetAnalysisRow] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "balanceSheet": balanceSheet,
      "audited1": audited1,
      "audited2": audited2,
      "audited3": audited3,
      "inhouse": inhouse,
      "estimated": estimated,
      "isNew": isNew,
    };
  }
}
