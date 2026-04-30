import "package:intl/intl.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";

import "package:wcas_frontend/features/request/information/security_perfection/model.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/security_covenant_condition.dart";
import "package:wcas_frontend/models/request/security_deferral.dart";
import "package:wcas_frontend/models/request/security_perfection.dart";

class SecurityPerfectionDraftHandler
    extends DraftHandler<SecurityPerfectionViewModel> {
  /* ============================================================
   * BUILD DRAFT
   * ============================================================ */
  @override
  Map<String, dynamic> buildDraftData(SecurityPerfectionViewModel vm) {
    vm.formKey.currentState?.save();

    return {
      "formKey": vm.draftFormKey,
      "moduleKey": vm.draftModuleKey,

      // COMMENTS (as requested)
      "commentList": vm.comments.map((c) => c.toSaveJson()).toList(),

      // SECURITY PERFECTION
      "securityPerfection": {
        "securityDeferralList": _serializeSecurityDeferralList(
          vm.securityDeferral.securityDeferralList,
        ),
        "covenant":
            _serializeCovenantConditionList(vm.securityDeferral.covenant),
        "condition":
            _serializeCovenantConditionList(vm.securityDeferral.condition),
      },
    };
  }

  /* ============================================================
   * APPLY DRAFT
   * ============================================================ */
  @override
  void applyDraft(SecurityPerfectionViewModel vm, Map<String, dynamic> data) {
    try {
      /* ---------------- Restore Comments ---------------- */
      final rawComments = data["commentList"];
      if (rawComments is List) {
        vm.comments = rawComments
            .map((e) => Comment.fromJson(_mapToStringDynamic(e)))
            .toList();
        vm.comment = vm.comments.first;
      }

      if (vm.comments.isEmpty) {
        vm.comments = [Comment()];
      }

      /* ---------------- Restore Security Perfection ---------------- */
      final rawSecurity = data["securityPerfection"];
      if (rawSecurity is Map<String, dynamic>) {
        vm.securityDeferral =
            SecurityPerfection.fromJson(_mapToStringDynamic(rawSecurity));
      }

      /* ---------------- Sync SecurityDeferral ---------------- */
      for (final item in vm.securityDeferral.securityDeferralList ?? []) {
        item.isChecked = item.selected ?? false;
      }

      /* ---------------- Restore Covenant / Condition ---------------- */
      void restore(List<SecurityCovenantCondition>? list) {
        if (list == null) return;
        for (final item in list) {
          item.isChecked = item.isChecked;
          if (item.deferralDate != null) {
            item.date = item.deferralDate;
          }
        }
      }

      restore(vm.securityDeferral.covenant);
      restore(vm.securityDeferral.condition);

      // FORCE UI REBUILD
      vm.emit(
        vm.state.copyWith(
          refreshKey: vm.state.refreshKey + 1,
        ),
      );
    } catch (e) {
      // logger.e('SecurityPerfection draft restore failed', e, st);
    }
  }

  /* ============================================================
   * SERIALIZERS
   * ============================================================ */
  List<Map<String, dynamic>> _serializeSecurityDeferralList(
    List<SecurityDeferral>? list,
  ) {
    if (list == null) return [];

    return list.map((e) {
      final Map<String, dynamic> json = Map<String, dynamic>.from(e.toJson());

      // Force sync checkbox state
      json["selected"] = e.selected;
      json["isChecked"] = e.isChecked;

      // Persist UI date safely
      if (e.dateDeferral != null) {
        json["dateDeferral"] = DateFormat("yyyy-MM-dd").format(e.dateDeferral!);
      } else {
        json["dateDeferral"] = null;
      }

      return json; // ALWAYS Map<String, dynamic>
    }).toList();
  }

  List<Map<String, dynamic>> _serializeCovenantConditionList(
    List<SecurityCovenantCondition>? list,
  ) {
    if (list == null) return [];

    return list.map((e) {
      // Start from model toJson (already formats deferralDate)
      final Map<String, dynamic> json = Map<String, dynamic>.from(
        e.toJson(isCovenant: e.isCovenant),
      );

      //  Persist UI checkbox state
      json["isChecked"] = e.isChecked;

      // Persist UI date separately (for draft restore)
      if (e.date != null) {
        json["date"] = e.date!.toIso8601String();
      } else {
        json["date"] = null;
      }

      return json; // Always Map<String, dynamic>
    }).toList();
  }
  /* ============================================================
   * JSON SAFETY
   * ============================================================ */

  Map<String, dynamic> _mapToStringDynamic(Map map) {
    return map.map(
      (key, value) => MapEntry(key.toString(), value),
    );
  }
}
