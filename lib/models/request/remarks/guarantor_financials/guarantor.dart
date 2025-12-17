class Guarantor {
  final int? entityId;
  final String name;
  final String analysisHtml;
  final String spreadsmartUrl;
  final bool canDelete;

  Guarantor({
    required this.entityId,
    required this.name,
    required this.analysisHtml,
    required this.spreadsmartUrl,
    this.canDelete = false,
  });

  Guarantor copyWith({
    int? entityId,
    String? name,
    String? analysisHtml,
    String? spreadsmartUrl,
    bool? canDelete,
  }) {
    return Guarantor(
      entityId: entityId ?? this.entityId,
      name: name ?? this.name,
      analysisHtml: analysisHtml ?? this.analysisHtml,
      spreadsmartUrl: spreadsmartUrl ?? this.spreadsmartUrl,
      canDelete: canDelete ?? this.canDelete,
    );
  }
}
