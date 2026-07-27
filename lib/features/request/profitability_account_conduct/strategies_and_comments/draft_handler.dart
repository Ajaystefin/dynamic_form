import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/model.dart";

/// Draft handler for strategies and comments.
class StrategiesAndCommentsDraftHandler
    extends DraftHandler<StrategiesAndCommentsViewModel> {
  @override
  Map<String, dynamic> buildDraftData(StrategiesAndCommentsViewModel vm) {
    final Map<String, dynamic> commentTextByCategoryId = <String, dynamic>{};

    for (final category in vm.commentCategories) {
      final int? categoryId = _asInt(category["id"]);
      if (categoryId == null) {
        continue;
      }

      final String value = _readFromVmCache(
        vm,
        categoryId,
        fallback: "",
      );

      commentTextByCategoryId[categoryId.toString()] = value;
    }

    return <String, dynamic>{
      "commentTextByCategoryId": commentTextByCategoryId,
      "existingCommentRecordIdsByCategoryId": {
        for (final entry in vm.existingCommentRecordIdsByCategoryId.entries)
          entry.key.toString(): entry.value,
      },
      "commentCategories":
          vm.commentCategories.map(Map<String, dynamic>.from).toList(),
    };
  }

  @override
  void applyDraft(
    StrategiesAndCommentsViewModel vm,
    Map<String, dynamic> data,
  ) {
    // -----------------------------
    // Restore categories
    // -----------------------------
    final dynamic rawCategories = data["commentCategories"];
    if (rawCategories is List) {
      vm.commentCategories = rawCategories
          .whereType<Map>()
          .map<Map<String, dynamic>>(
            (m) => m.map((k, v) => MapEntry(k.toString(), v)),
          )
          .toList();
    }

    // -----------------------------
    // Restore existing record ids
    // -----------------------------
    final dynamic rawExistingIds = data["existingCommentRecordIdsByCategoryId"];
    if (rawExistingIds is Map) {
      final parsedIds = <int, int>{};

      rawExistingIds.forEach((k, v) {
        final int? intKey = _parseIntKey(k);
        final int? intValue = _asInt(v);
        if (intKey != null && intValue != null) {
          parsedIds[intKey] = intValue;
        }
      });

      vm.existingCommentRecordIdsByCategoryId
        ..clear()
        ..addAll(parsedIds);
    }

    // -----------------------------
    // Restore comment text
    // -----------------------------
    final dynamic rawTextMap = data["commentTextByCategoryId"];
    if (rawTextMap is Map) {
      final parsedText = <int, String>{};

      rawTextMap.forEach((k, v) {
        final int? intKey = _parseIntKey(k);
        if (intKey != null) {
          parsedText[intKey] = (v ?? "").toString();
        }
      });

      vm.commentTextByCategoryId
        ..clear()
        ..addAll(parsedText);

      // IMPORTANT:
      // Let initialTextOnceFor() serve draft text again on next widget build.
      vm
        ..resetSeedForDraftCategories(parsedText.keys)

        // If any editors are already mounted, update them immediately.
        ..applyDraftTextToMountedEditors(parsedText);
    }

    vm.emit(vm.state.copyWith());
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _readFromVmCache(
    StrategiesAndCommentsViewModel vm,
    int categoryId, {
    required String fallback,
  }) {
    final String? cached = vm.commentTextByCategoryId[categoryId];
    if (cached != null && cached.trim().isNotEmpty) {
      return cached;
    }

    final String? lastSaved = vm.lastSavedPlainByCategoryId[categoryId];
    if (lastSaved != null && lastSaved.trim().isNotEmpty) {
      return lastSaved;
    }

    return fallback;
  }

  int? _parseIntKey(Object? key) {
    if (key == null) {
      return null;
    }
    if (key is int) {
      return key;
    }
    return int.tryParse(key.toString());
  }

  int? _asInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }
}
