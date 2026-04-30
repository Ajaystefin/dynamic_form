class BalanceSheetAnalysisRow {
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
  String id;
  String balanceSheet;
  String audited1;
  String audited2;
  String audited3;
  String inhouse;
  String estimated;
  bool isNew;

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
