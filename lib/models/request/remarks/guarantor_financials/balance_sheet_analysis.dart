/// Represents a balance sheet analysis row containing
/// audited, in-house, and estimated values.
class BalanceSheet {
  /// Creates a [BalanceSheet] instance.
  BalanceSheet({
    required this.id,
    this.balanceSheet = "",
    this.audited1 = "",
    this.audited2 = "",
    this.audited3 = "",
    this.inhouse = "",
    this.estimated = "",
    this.isNew = false,
  });

  /// Unique identifier for the balance sheet.
  String id;

  /// Main balance sheet value or reference.
  String balanceSheet;

  /// First audited value.
  String audited1;

  /// Second audited value.
  String audited2;

  /// Third audited value.
  String audited3;

  /// In-house calculated value.
  String inhouse;

  /// Estimated value.
  String estimated;

  /// Indicates whether this is a newly created balance sheet.
  bool isNew;
}
