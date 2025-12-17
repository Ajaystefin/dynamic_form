class BalanceSheet {
  String id;
  String balanceSheet;
  String audited1;
  String audited2;
  String audited3;
  String inhouse;
  String estimated;
  bool isNew;

  BalanceSheet({
    required this.id,
    this.balanceSheet = '',
    this.audited1 = '',
    this.audited2 = '',
    this.audited3 = '',
    this.inhouse = '',
    this.estimated = '',
    this.isNew = false,
  });
}
