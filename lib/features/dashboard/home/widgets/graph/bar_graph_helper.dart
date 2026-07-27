import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";
import "package:wcas_frontend/models/home/documentation_summary.dart";

/// A helper class containing data transformation and grouping logic for the
/// BarGraph.
class BarGraphHelper {
  /// Builds a global category order based on occurrences across all stages.
  /// Prioritizes the counts of the [stageForPriority] if provided, then falls
  /// back to alphabetical.
  static List<String> categoryOrder({
    required DocumentationSummary? summary,
    required DocumentationStage? stageForPriority,
    List<String>? override,
  }) {
    if (override != null && override.isNotEmpty) {
      final Set<String> seen = <String>{};
      final List<String> ordered = <String>[];
      for (final String label in override) {
        if (label.trim().isEmpty) {
          continue;
        }
        if (seen.add(label)) {
          ordered.add(label);
        }
      }
      final Set<String> all = _allCategories(summary);
      final List<String> extras =
          all.where((String c) => !seen.contains(c)).toList()..sort();
      return <String>[...ordered, ...extras];
    }

    final List<String> labels = _allCategories(summary).toList();
    if (labels.isEmpty) {
      return labels;
    }

    // if (stageForPriority != null) {
    //   labels.sort((String a, String b) {
    //     final int av = stageForPriority.categories[a] ?? 0;
    //     final int bv = stageForPriority.categories[b] ?? 0;
    //     if (av != bv) return bv.compareTo(av); // desc
    //     return a.toLowerCase().compareTo(b.toLowerCase());
    //   });
    // } else {
    //   labels.sort(
    //       (String a, String b) =>
    // a.toLowerCase().compareTo(b.toLowerCase()));
    // }
    return labels;
  }

  /// Extracts all unique categories found across all stages in the summary.
  static Set<String> _allCategories(DocumentationSummary? summary) {
    if (summary == null) {
      return const {};
    }
    return summary.stages.values
        .expand((DocumentationStage stage) => stage.categories.keys)
        .toSet();
  }

  /// Returns all stage keys in a stable order. Applies specific top-level
  /// organization
  /// for CCU roles and Credit Control summary type.
  static List<String> stageDisplayOrder(
    DocumentationSummary? summary,
    HomeViewModel viewModel,
  ) {
    if (summary == null) {
      return const [];
    }

    final bool isCCURole =
        Utils.checkRoles(const [UserRole.ccuChecker, UserRole.ccuMaker]);
    final bool isCreditControl =
        viewModel.selectedSummary == SummaryType.creditcontrol;

    final List<String> names = summary.stages.keys.toList();

    if (isCCURole || isCreditControl) {
      final List<String> limitRelease = <String>[];
      final List<String> others = <String>[];

      for (final String s in names) {
        if (s.toLowerCase().contains("limit release")) {
          limitRelease.add(s);
        } else {
          others.add(s);
        }
      }

      limitRelease.sort();
      others.sort();
      return <String>[...limitRelease, ...others];
    }

    names.sort((String a, String b) => a.compareTo(b));
    return names;
  }

  /// Splits a list into chunks of a given maximum [size].
  static List<List<T>> chunk<T>(List<T> list, int size) {
    if (list.isEmpty) {
      return <List<T>>[];
    }
    return <List<T>>[
      for (int i = 0; i < list.length; i += size)
        list.sublist(i, i + size > list.length ? list.length : i + size),
    ];
  }
}
