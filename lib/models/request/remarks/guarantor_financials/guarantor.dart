/// Represents guarantor analysis information,
/// including analysis content and Spreadsmart integration details.
class Guarantor {
  /// Creates a [Guarantor] instance.
  Guarantor({
    required this.entityId,
    required this.name,
    required this.analysisHtml,
    required this.spreadsmartUrl,
    this.canDelete = false,
  });

  /// Entity identifier.
  final int? entityId;

  /// Name of the guarantor.
  final String name;

  /// Guarantor analysis content in HTML format.
  final String analysisHtml;

  /// Spreadsmart URL associated with the guarantor analysis.
  final String spreadsmartUrl;

  /// Indicates whether the guarantor analysis can be deleted.
  final bool canDelete;

  /// Creates a copy of this [Guarantor]
  /// with the specified fields replaced.
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
