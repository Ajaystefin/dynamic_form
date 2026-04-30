class FinancialRatioAnalysis {
  FinancialRatioAnalysis({
    required this.entityId,
    required this.name,
    required this.analysisHtml,
    required this.spreadsmartUrl,
    this.canDelete = false,
  });
  final String entityId;
  final String name;
  final String analysisHtml;
  final String spreadsmartUrl;
  final bool canDelete;

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
