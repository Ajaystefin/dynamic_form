import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/information/security_perfection/model.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/security_covenant_condition.dart";
import "package:wcas_frontend/models/request/security_deferral.dart";

/// Draft handler for the Security Perfection section.
class SecurityPerfectionDraftHandler
    extends DraftHandler<SecurityPerfectionViewModel> {
  /* ============================================================
   *  BUILD DRAFT
   * ============================================================ */
  @override
  Map<String, dynamic> buildDraftData(SecurityPerfectionViewModel vm) {
    vm.formKey.currentState?.save();

    return {
      "formKey": vm.draftFormKey,
      "moduleKey": vm.draftModuleKey,

      ///  COMMENTS
      "commentList": vm.comments.map((c) => c.toSaveJson()).toList(),

      ///  SECURITY PERFECTION
      "securityPerfection": {
        ///  SECURITY  using toJson
        "securityDeferralList": (vm.securityDeferral.securityDeferralList ?? [])
            .map((s) => s.toJson())
            .toList(),

        ///  COVENANT
        "covenant": (vm.securityDeferral.covenant ?? [])
            .map((c) => c.toJson(isCovenant: true))
            .toList(),

        ///  CONDITION
        "condition": (vm.securityDeferral.condition ?? [])
            .map((c) => c.toJson(isCovenant: false))
            .toList(),
      },
    };
  }

  /* ============================================================
   * APPLY DRAFT
   * ============================================================ */
  @override
  void applyDraft(
    SecurityPerfectionViewModel vm,
    Map<String, dynamic> data,
  ) {
    try {
      /// KEYS
      // vm.draftFormKey = data["formKey"];
      // vm.draftModuleKey = data["moduleKey"];

      /// COMMENTS
      final rawComments = data["commentList"];
      if (rawComments is List) {
        vm
          ..comments = rawComments
              .map((e) => Comment.fromJson(_mapToStringDynamic(e)))
              .toList()
          ..comment = vm.comments.first;
      }

      if (vm.comments.isEmpty) {
        vm.comments = [Comment()];
      }

      /// ROOT
      final securityData = data["securityPerfection"] ?? {};

      /* ================================
       * SECURITY DEFERRAL LIST
       * ================================ */
      final secList = securityData["securityDeferralList"] as List? ?? [];

      vm.securityDeferral.securityDeferralList =
          secList.map((sec) => SecurityDeferral.fromJson(sec)).toList();

      /* ================================
       * COVENANT
       * ================================ */
      final covList = securityData["covenant"] as List? ?? [];

      vm.securityDeferral.covenant = covList
          .map((sec) => SecurityCovenantCondition.fromJson(sec))
          .toList();

      /* ================================
       * CONDITION
       * ================================ */
      final condList = securityData["condition"] as List? ?? [];

      vm.securityDeferral.condition = condList
          .map((sec) => SecurityCovenantCondition.fromJson(sec))
          .toList();
    } on Object {
      //print("Draft Apply Error: $e");
    }
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
