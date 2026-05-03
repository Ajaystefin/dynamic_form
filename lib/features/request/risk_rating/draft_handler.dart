import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/risk_rating/model.dart";
import "package:wcas_frontend/models/request/risk_rating/external_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/internal_rating.dart";

/// Draft handler for Risk Rating screen.
///
/// Stores ONLY user-entered data:
/// - Internal & External rating inputs
/// - Comments
/// Avoids server-derived or recalculated fields.
class RiskRatingDraftHandler extends DraftHandler<RiskRatingViewModel> {
  @override
  Map<String, dynamic> buildDraftData(RiskRatingViewModel vm) {
    // Do NOT wipe model during init
    if (vm.formKey.currentState != null && vm.formKey.currentState!.mounted) {
      vm.formKey.currentState?.save();
    }

    return {
      "internalRatingList":
          vm.riskRating.internalRatings.map(_internalRatingToDraft).toList(),
      "externalRatingList": (vm.riskRating.externalRatings ?? [])
          .map(_externalRatingToDraft)
          .toList(),
      "comments": (vm.isFiFlow)
          ? vm.internalRatingControler.currentText
          : vm.internalRatingTextController.text,
      "externalComments": vm.externalRatingControler.currentText,
    };
  }

  @override
  void applyDraft(RiskRatingViewModel vm, Map<String, dynamic> data) {
    // ---------------- INTERNAL RATINGS ----------------
    final List<dynamic>? internalDrafts =
        data["internalRatingList"] as List<dynamic>?;

    if (internalDrafts != null && internalDrafts.isNotEmpty) {
      vm.riskRating.internalRatings = [];
      for (final dynamic draft in internalDrafts) {
        if (draft is! Map<String, dynamic>) continue;

        final int? rim = _asInt(draft["rimNo"]);
        if (rim == null) continue;

        // ALWAYS CREATE ROW
        final InternalRating ir = InternalRating(
          customerRimNo: rim,
          fromWcasDB: false,
          isDeletable: true,
        );

        _applyInternalDraft(ir, draft);
        vm.riskRating.internalRatings.add(ir);
      }
    }

    // ---------------- EXTERNAL RATINGS ----------------
    final List<dynamic>? externalDrafts =
        data["externalRatingList"] as List<dynamic>?;

    if (externalDrafts != null && externalDrafts.isNotEmpty) {
      vm.riskRating.externalRatings = [];
      for (final dynamic draft in externalDrafts) {
        if (draft is! Map<String, dynamic>) continue;

        final int? rim = _asInt(draft["rimNo"]);
        final String? customerName = draft["customerName"];
        if (rim == null) continue;

        // ALWAYS CREATE ROW
        final ExternalRating er = ExternalRating(
          customerRimNo: rim,
          customerName: customerName,
          isDeleted: false,
          isDeletable: true,
        );

        _applyExternalDraft(er, draft, vm);
        vm.riskRating.externalRatings!.add(er);
      }
    }

    // ---------------- COMMENTS ----------------
    TextEditingController commentCtrls() => vm.internalRatingTextController;
    UnifiedEditorController intrlCntrl() => vm.internalRatingControler;
    UnifiedEditorController extrlCntrl() => vm.externalRatingControler;

    final String? comments = data["comments"]?.toString();
    final String? externalComments = data["externalComments"]?.toString();
    // Restore comments
    if (comments != null) {
      vm.riskRating.comments = comments;
      if (!vm.isFiFlow) {
        commentCtrls().text = comments;
      } else {
        intrlCntrl().setText(comments);
      }
    }
    if (externalComments != null) {
      vm.riskRating.externalComments = externalComments;
      extrlCntrl().setText(externalComments);
    }

    // vm.riskRating.comments =
    //     data['comments']?.toString() ?? vm.riskRating.comments;

    // vm.riskRating.externalComments =
    //     data['externalComments']?.toString() ??
    // vm.riskRating.externalComments;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _internalRatingToDraft(InternalRating ir) {
    return {
      // ---------- Identity ----------
      "rimNo": ir.customerRimNo,
      "customerName": ir.customerName,
      "entityId": ir.entityId,

      // ---------- Borrower ----------
      "borrowerGuarantor": ir.borrowerGuarantor,

      // ---------- Existing ----------
      "crr": ir.crr,
      "existingBasisOfCrr": ir.existingBasisOfCrr,
      "prevRatingSource": ir.prevRatingSrc,
      "prevCrr": ir.previousCRR,

      // ---------- Proposed ----------
      "proposedModel": ir.proposedModel,
      "proposedCrr": ir.proposedCRR,
      "proposedBasisOfCrr": ir.proposedBasisOfCrr,
      "proposedRatingSource": ir.proposedRatingSrc,

      // ---------- Override / Cascade ----------
      "detailsOverride": ir.detailsOverride,
      "overrideComment": ir.overrideComment,
      "cascadeNote": ir.cascadeNote,

      // ---------- Credit ----------
      "proposedByCredit": ir.proposedByCredit,

      // ---------- Flags ----------
      "internalRatingType": ir.internalRatingType?.name,
      "isOverrideCRR": ir.internalRatingType == InternalRatingtype.override,
      "isCascade": ir.internalRatingType == InternalRatingtype.cascade,

      // ---------- FI flow ----------
      "secondBestRating": ir.secondBestRating,

      "isDeleted": ir.isDeleted,
    };
  }

  void _applyInternalDraft(InternalRating ir, Map<String, dynamic> draft) {
    // ---------- Identity ----------
    ir
      ..customerRimNo = _asInt(draft["rimNo"])
      ..customerName = draft["customerName"]
      ..entityId = _asInt(draft["entityId"])

      // ---------- Borrower ----------
      ..borrowerGuarantor = draft["borrowerGuarantor"]

      // ---------- Existing ----------
      ..crr = _asInt(draft["crr"])
      ..existingBasisOfCrr = draft["existingBasisOfCrr"]
      ..prevRatingSrc = _asInt(draft["prevRatingSource"])
      ..previousCRR = _asInt(draft["prevCrr"])

      // ---------- Proposed ----------
      ..proposedModel = draft["proposedModel"]
      ..proposedCRR = _asInt(draft["proposedCrr"])
      ..proposedBasisOfCrr = draft["proposedBasisOfCrr"]
      ..proposedRatingSrc = draft["proposedRatingSource"]

      // ---------- Override / Cascade ----------
      ..detailsOverride = draft["detailsOverride"]
      ..overrideComment = draft["overrideComment"]
      ..cascadeNote = draft["cascadeNote"]

      // ---------- Credit ----------
      ..proposedByCredit = draft["proposedByCredit"]?.toString();

    // ---------- Rating Type ----------
    final String? type = draft["internalRatingType"];
    if (type != null) {
      ir.internalRatingType = InternalRatingtype.values.firstWhere(
        (e) => e.name == type,
        orElse: () => InternalRatingtype.none,
      );
    }

    // ---------- FI flow ----------
    ir
      ..secondBestRating = draft["secondBestRating"]
      ..isDeleted = draft["isDeleted"];
  }

  Map<String, dynamic> _externalRatingToDraft(ExternalRating er) {
    return {
      "rimNo": er.customerRimNo,
      "customerName": er.customerName,
      "sAndP": er.sAndP?.id,
      "moodys": er.moodys?.id,
      "fitch": er.fitch?.id,
      "isDeleted": er.isDeleted,
    };
  }

  void _applyExternalDraft(
    ExternalRating er,
    Map<String, dynamic> draft,
    RiskRatingViewModel vm,
  ) {
    er.isDeleted = draft["isDeleted"];
    final int? sAndPId = _asInt(draft["sAndP"]);
    final int? moodysId = _asInt(draft["moodys"]);
    final int? fitchId = _asInt(draft["fitch"]);

    if (sAndPId != null) {
      er.sAndP = vm.sAndP.firstWhereOrNull((e) => e.id == sAndPId);
    }

    if (moodysId != null) {
      er.moodys = vm.moodys.firstWhereOrNull((e) => e.id == moodysId);
    }

    if (fitchId != null) {
      er.fitch = vm.fitch.firstWhereOrNull((e) => e.id == fitchId);
    }
  }

  int? _asInt(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

extension FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E e) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}

extension FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
