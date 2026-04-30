import "package:flutter/material.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/approval/proposed_facilities/model.dart";
import "package:wcas_frontend/models/request/approval/group_position.dart";

// Autosave implementation by extended team
class ProposedFacilitiesDraftHandler
    extends DraftHandler<ProposedFacilitiesViewModel> {
  @override
  Map<String, dynamic> buildDraftData(ProposedFacilitiesViewModel vm) {
    final Map<String, String> exposureControllers = {
      for (final entry in vm.cleanExposureControllers!.entries)
        entry.key: entry.value.text,
    };
    return {
      "exposureControllers": exposureControllers,
      "proposed": _serializeExposureRows(
        vm,
        vm.groupPositionList?.proposedPosition,
        isProposed: true,
      ),
      "present": _serializeExposureRows(
        vm,
        vm.groupPositionList?.presentPosition,
        isProposed: false,
      ),
    };
  }

  /// Serializes rows into [{ rimNo: "...", cleanExposure: "123.45" }, ...]
  List<Map<String, dynamic>> _serializeExposureRows(
    ProposedFacilitiesViewModel vm,
    List<Position>? rows, {
    required bool isProposed,
  }) {
    if (rows == null) return [];

    return List.generate(rows.length, (index) {
      final p = rows[index];
      final key = "${p.rimNo}_${isProposed ? "proposed" : "present"}";
      final ctrl = vm.cleanExposureControllers?[key];

      return {
        "rimNo": p.rimNo,
        "cleanExposure": ctrl?.text.trim() ?? "",
      };
    });
  }

  @override
  void applyDraft(ProposedFacilitiesViewModel vm, Map<String, dynamic> data) {
    final Map<String, dynamic>? exposureControllers =
        data["exposureControllers"] as Map<String, dynamic>?;
    debugPrint("exposureData get : ${exposureControllers.toString()}");

    if (exposureControllers != null) {
      vm.cleanExposureControllers ??= {};
      for (final entry in exposureControllers.entries) {
        if (vm.cleanExposureControllers == null) {
          vm.cleanExposureControllers?[entry.key] =
              TextEditingController(text: entry.value);
        } else {
          vm.cleanExposureControllers?[entry.key]?.text = entry.value;
        }
        debugPrint(
          "controller get ${entry.key}: ${entry.value} "
          "${vm.cleanExposureControllers?[entry.key]?.text}",
        );
      }
    }

    _applyExposureDraft(
      vm,
      data["proposed"],
      vm.groupPositionList?.proposedPosition,
      isProposed: true,
    );

    _applyExposureDraft(
      vm,
      data["present"],
      vm.groupPositionList?.presentPosition,
      isProposed: false,
    );
  }

  void _applyExposureDraft(
    ProposedFacilitiesViewModel vm,
    dynamic draftList,
    List<Position>? rows, {
    required bool isProposed,
  }) {
    if (draftList == null || rows == null) return;

    if (draftList is! List) return;

    final int count =
        (draftList.length < rows.length) ? draftList.length : rows.length;

    for (int i = 0; i < count; i++) {
      final draft = draftList[i];
      if (draft is! Map) continue;

      final rimNo = draft["rimNo"];
      final exposure = draft["cleanExposure"]?.toString();

      if (rimNo == null || exposure == null) continue;

      final position = rows[i];

      // Ensure rimNo matches the row
      if (position.rimNo != rimNo) continue;

      final key = "${rimNo}_${isProposed ? "proposed" : "present"}";
      final ctrl = vm.cleanExposureControllers?[key];

      if (ctrl != null) {
        ctrl.text = exposure;

        // Mirror into ViewModel logic (keeps model updated)
        vm.updateExposureField(
          i,
          rimNo,
          exposure,
          isProposed,
        );
      }
    }
  }
}
