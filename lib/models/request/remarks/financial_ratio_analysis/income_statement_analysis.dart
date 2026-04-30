import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_details_response.dart";

class IncomeStatementAnalysisRow {
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

  factory IncomeStatementAnalysisRow.fromJson(Map<String, dynamic> json) {
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
  String id;
  String incomePositions;
  String audited1;
  String audited2;
  String audited3;
  String inhouse;
  String estimated;
  bool isNew;

  Map<String, dynamic> toJson() {
    return {
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

class SectionData {
  List<IncomeStatementAnalysisRow> rows = [];
  List<Statement> statements = [];
  Reference? health;
  String? longName;
}
