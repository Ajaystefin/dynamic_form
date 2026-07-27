/// Represents financial ratio analysis information,
/// including analysis content and Spreadsmart integration details.
class FinancialRatioAnalysis {
  /// Creates a [FinancialRatioAnalysis] instance.
  FinancialRatioAnalysis({
    required this.entityId,
    required this.name,
    required this.analysisHtml,
    required this.spreadsmartUrl,
    this.canDelete = false,
  });

  /// Entity identifier.
  final String entityId;

  /// Name of the analysis.
  final String name;

  /// Financial ratio analysis content in HTML format.
  final String analysisHtml;

  /// Spreadsmart URL associated with the analysis.
  final String spreadsmartUrl;

  /// Indicates whether the analysis can be deleted.
  final bool canDelete;

  /// Creates a copy of this [FinancialRatioAnalysis]
  /// with the specified fields replaced.
  FinancialRatioAnalysis copyWith({
    String? entityId,
    String? name,
    String? analysisHtml,
    String? spreadsmartUrl,
    bool? canDelete,
  }) {
    return FinancialRatioAnalysis(
      entityId: entityId ?? this.entityId,
      name: name ?? this.name,
      analysisHtml: analysisHtml ?? this.analysisHtml,
      spreadsmartUrl: spreadsmartUrl ?? this.spreadsmartUrl,
      canDelete: canDelete ?? this.canDelete,
    );
  }
}
