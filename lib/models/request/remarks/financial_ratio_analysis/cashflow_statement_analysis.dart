class CashFlowSheetAnalysisRow {
  String id;
  String cashFlowItems;
  String audited1;
  String audited2;
  String audited3;
  String inhouse;
  String estimated;
  bool isNew;

  CashFlowSheetAnalysisRow({
    required this.id,
    this.cashFlowItems = '',
    this.audited1 = '',
    this.audited2 = '',
    this.audited3 = '',
    this.inhouse = '',
    this.estimated = '',
    this.isNew = false,
  });
}
