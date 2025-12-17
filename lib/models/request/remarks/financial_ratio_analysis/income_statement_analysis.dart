class IncomeStatementAnalysisRow {
  String id;
  String incomePositions;
  String audited1;
  String audited2;
  String audited3;
  String inhouse;
  String estimated;
  bool isNew;

  IncomeStatementAnalysisRow({
    required this.id,
    this.incomePositions = '',
    this.audited1 = '',
    this.audited2 = '',
    this.audited3 = '',
    this.inhouse = '',
    this.estimated = '',
    this.isNew = false,
  });
}
