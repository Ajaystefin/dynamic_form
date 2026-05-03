import "dart:collection";

/// A single stage's data: total count + dynamic categories.
/// Only `totalCount` is fixed; categories are keyed by `crApprovalDesc` values
/// dynamically.
class DocumentationStage {
  DocumentationStage({
    required this.totalCount,
    required Map<String, int> categories,
  }) : categories = UnmodifiableMapView(Map<String, int>.from(categories));

  /// Build from a list of flat rows for this stage only.
  /// Each row must contain: "total", "stage", "crApprovalDesc".
  factory DocumentationStage.fromFlatRows(List<Map<String, dynamic>> rows) {
    int total = 0;
    final Map<String, int> cats = {};

    for (final r in rows) {
      final rawDesc = r["crApprovalDesc"];
      if (rawDesc == null) continue;

      final desc = rawDesc.toString().trim();
      if (desc.isEmpty) continue;

      final normalized = desc.toLowerCase();
      final count = _asInt(r["total"]);

      if (normalized == "total") {
        total = count;
      } else {
        // Keep the original case for the public key, but aggregate by
        // normalized desc
        cats[desc] = count;
      }
    }

    return DocumentationStage(totalCount: total, categories: cats);
  }

  /// The value for `crApprovalDesc == "TOTAL"` (case-insensitive). If absent,
  /// defaults to 0.
  final int totalCount;

  /// Dynamic bucket of categories keyed by the exact `crApprovalDesc` TEXT as
  /// provided by backend.
  /// Example keys: "New to Bank", "Annual Review - Increase", "Isolated Memo",
  /// etc.
  /// This map is case-sensitive as returned by backend, but we parse in a
  /// tolerant way.
  final Map<String, int> categories;

  /// Serialize to a flat JSON-like map for consistency.
  /// Note: this doesn’t recreate the flat list; it preserves the stage
  /// structure.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "totalCount": totalCount,
      "categories": categories, // { "New to Bank": 3, "Isolated Memo": 1, ... }
    };
    // If you want to emit a *flat list* again, I can add a helper that does
    // that.
  }

  /// Convenience accessor: returns the count for a category (case/space-insensitive).
  int category(String crApprovalDesc) {
    final key = _normalize(crApprovalDesc);
    if (key == null) return 0;
    for (final entry in categories.entries) {
      if (_normalize(entry.key) == key) return entry.value;
    }
    return 0;
  }
}

/// Summary that holds ALL stages dynamically.
/// Keys are normalized stage names (lowercase, trimmed) for stability.
/// Values are `DocumentationStage`.
class DocumentationSummary {
  DocumentationSummary(Map<String, DocumentationStage> stages)
      : stages =
            UnmodifiableMapView(Map<String, DocumentationStage>.from(stages));

  /// Build from a flat list of backend rows, where each row contains:
  ///   - "stage": String
  ///   - "crApprovalDesc": String
  ///   - "total": number
  factory DocumentationSummary.fromJson(List<Map<String, dynamic>> rows) {
    // Group rows by normalized stage name
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final r in rows) {
      final s = _normalize(r["stage"]);
      if (s == null) continue;
      grouped.putIfAbsent(s, () => []).add(r);
    }

    // Build a DocumentationStage for each stage
    final Map<String, DocumentationStage> built = {};
    grouped.forEach((normalizedStage, stageRows) {
      built[normalizedStage] = DocumentationStage.fromFlatRows(stageRows);
    });

    return DocumentationSummary(built);
  }

  /// All stages keyed by normalized name.
  /// Example key: "fol not required"
  final Map<String, DocumentationStage> stages;

  /// Get a stage by name (case/space-insensitive).
  /// Returns null if not present.
  DocumentationStage? getStage(String stageName) {
    final key = _normalize(stageName);
    if (key == null) return null;
    return stages[key];
  }

  /// Optional: back-compat getters (non-breaking).
  /// These return an empty stage if the key doesn’t exist.
  DocumentationStage get folNotRequired =>
      getStage("FOL not required") ?? _zeroStage();

  // You can add more getters to mirror your old structure if needed:
  // DocumentationStage get folDraftUnderPreparation => getStage('FOL draft
  // under preparation') ?? _zeroStage();
  // ...

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    stages.forEach((normalizedName, stage) {
      map[normalizedName] = stage.toJson();
    });
    return map;
  }

  /// Empty/default stage
  static DocumentationStage _zeroStage() => DocumentationStage(
        totalCount: 0,
        categories: const {},
      );
}

// -------------------- helpers --------------------

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

String? _normalize(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

/// Central parse function that accepts either:
/// - List<dynamic> (flat rows)  --> uses fromFlatList
/// - Map<String, dynamic> (object) --> uses fromJson
/// - Anything else -> throws a descriptive error
class DocumentationSummaryParser {
  static DocumentationSummary parse(dynamic data) {
    if (data is List) {
      // Ensure it's a List<Map<String, dynamic>>
      final rows = data
          .where((e) => e != null)
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      return DocumentationSummary.fromJson(rows);
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      return DocumentationSummary.fromJson(map as List<Map<String, dynamic>>);
    }

    throw FormatException(
      "Unsupported JSON shape for DocumentationSummary: ${data.runtimeType}. "
      "Expected List (flat rows) or Map (hierarchy).",
    );
  }
}
