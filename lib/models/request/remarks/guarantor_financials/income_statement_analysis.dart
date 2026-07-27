/// Represents an income statement with various financial metrics.
class IncomeStatement {
  /// Creates an [IncomeStatement] instance.
  ///
  /// [id] is required and uniquely identifies the income statement.
  /// Other fields default to empty values if not provided.
  IncomeStatement({
    required this.id,
    this.incomePositions = "",
    this.audited1 = "",
    this.audited2 = "",
    this.audited3 = "",
    this.inhouse = "",
    this.estimated = "",
    this.isNew = false,
  });

  /// Unique identifier for the income statement.
  final String id;

  /// Description or name of income positions.
  final String incomePositions;

  /// First audited value.
  final String audited1;

  /// Second audited value.
  final String audited2;

  /// Third audited value.
  final String audited3;

  /// In-house calculated value.
  final String inhouse;

  /// Estimated value.
  final String estimated;

  /// Indicates whether this record is newly created.
  final bool isNew;
}
