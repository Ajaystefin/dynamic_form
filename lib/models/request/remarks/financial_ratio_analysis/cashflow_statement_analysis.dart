/// Represents a cash flow analysis row containing
/// audited, in-house, and estimated values.
class CashFlowSheetAnalysisRow {
  /// Creates a [CashFlowSheetAnalysisRow] instance.
  CashFlowSheetAnalysisRow({
    required this.id,
    this.cashFlowItems = "",
    this.audited1 = "",
    this.audited2 = "",
    this.audited3 = "",
    this.inhouse = "",
    this.estimated = "",
    this.isNew = false,
  });

  /// Creates a [CashFlowSheetAnalysisRow] instance from a JSON map.
  factory CashFlowSheetAnalysisRow.fromJson(Map<String, dynamic> json) {
    return CashFlowSheetAnalysisRow(
      id: json["id"] as String,
      cashFlowItems: json["cashFlowItems"] as String? ?? "",
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

  /// cashFlowItems
  String cashFlowItems;

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

  /// Converts this [CashFlowSheetAnalysisRow] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "cashFlowItems": cashFlowItems,
      "audited1": audited1,
      "audited2": audited2,
      "audited3": audited3,
      "inhouse": inhouse,
      "estimated": estimated,
      "isNew": isNew,
    };
  }
}
