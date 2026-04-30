import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/features/request/approval/group_position/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/group_position/model.dart";
import "package:wcas_frontend/models/request/approval/group_position.dart";

// -----------------------------------------------------------------------------
// Fake ViewModel — uses REAL GroupPosition model
// -----------------------------------------------------------------------------
class FakeGroupPositionViewModel extends GroupPositionViewModel {
  FakeGroupPositionViewModel() {
    cleanExposureControllers = {
      "101_proposed": TextEditingController(text: "100"),
      "101_present": TextEditingController(text: "200"),
      "102_proposed": TextEditingController(text: ""),
    };

    // - Use REAL model, not guessed types
    groupPositionList = GroupPosition()
      ..proposedPosition = [
        Position(rimNo: 101),
        Position(rimNo: 102),
      ]
      ..presentPosition = [
        Position(rimNo: 101),
      ];
  }

  final List<Map<String, dynamic>> updates = [];

  // - Exact signature from real ViewModel
  @override
  Future<void> updateExposureField(
    int index,
    String rimNo,
    String value,
    bool isProposed,
  ) async {
    updates.add({
      "index": index,
      "rimNo": rimNo,
      "value": value,
      "isProposed": isProposed,
    });
  }
}

// -----------------------------------------------------------------------------
// TESTS
// -----------------------------------------------------------------------------
void main() {
  late GroupPositionDraftHandler handler;
  late FakeGroupPositionViewModel vm;

  setUp(() {
    handler = GroupPositionDraftHandler();
    vm = FakeGroupPositionViewModel();
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------
  test("buildDraftData serializes exposure controllers", () {
    final data = handler.buildDraftData(vm);
    final exposure = data["exposureControllers"] as Map<String, String>;

    expect(exposure["101_proposed"], "100");
    expect(exposure["101_present"], "200");
    expect(exposure["102_proposed"], "");
  });

  test("buildDraftData serializes proposed rows", () {
    final proposed = handler.buildDraftData(vm)["proposed"] as List;

    expect(proposed.length, 2);
    expect(proposed[0]["rimNo"], 101);
    expect(proposed[0]["cleanExposure"], "100");
    expect(proposed[1]["cleanExposure"], "");
  });

  test("buildDraftData serializes present rows", () {
    final present = handler.buildDraftData(vm)["present"] as List;

    expect(present.length, 1);
    expect(present[0]["rimNo"], 101);
    expect(present[0]["cleanExposure"], "200");
  });

  // ---------------------------------------------------------------------------
  // applyDraft
  // ---------------------------------------------------------------------------
  test("applyDraft restores controller values", () async {
    handler.applyDraft(vm, {
      "exposureControllers": {
        "101_proposed": "999",
      },
    });

    expect(
      vm.cleanExposureControllers["101_proposed"]!.text,
      "999",
    );
  });

  test("applyDraft skips mismatched rimNo", () async {
    handler.applyDraft(vm, {
      "proposed": [
        {"rimNo": 999, "cleanExposure": "111"},
      ],
    });

    expect(vm.updates.isEmpty, true);
  });

  test("applyDraft skips invalid draft shapes", () async {
    handler.applyDraft(vm, {
      "proposed": "bad",
      "present": 123,
    });

    expect(vm.updates.isEmpty, true);
  });
}
