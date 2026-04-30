import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

// Adjust paths based on your structure:
import "package:wcas_frontend/features/request/approval/proposed_facilities/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/proposed_facilities/model.dart";
import "package:wcas_frontend/models/request/approval/group_position.dart";

/// ---------------------------------------------------------------------------
/// TEST VIEWMODEL (lightweight stub)
/// ---------------------------------------------------------------------------
class _TestProposedFacilitiesVM extends ProposedFacilitiesViewModel {
  _TestProposedFacilitiesVM() {
    cleanExposureControllers = {};
  }

  // Spy fields to validate the handler invokes updateExposureField correctly
  int? spyIndex;
  int? spyRimNo;
  String? spyValue;
  bool? spyIsProposed;
  int spyCallCount = 0;

  @override
  Future<void> updateExposureField(
    int index,
    int? rimNo,
    String newVal,
    bool isProposed,
  ) async {
    spyCallCount++;
    spyIndex = index;
    spyRimNo = rimNo;
    spyValue = newVal;
    spyIsProposed = isProposed;
  }
}

/// Helper to create a Position row
Position makePosition(int rimNo, [String name = "Customer"]) {
  return Position(
    customerName: name,
    rimNo: rimNo,
    overriddenCRR: 1,
    modelGeneratedCRR: 2,
    fundBasedLimits: 100,
    nonFundBasedLimits: 50,
    totalLimits: 150,
    totalTangibleSecurity: 20,
    ofWhichCashCollateral: 10,
    totalLimitsNetOfTotalTangibleSecurity: 130,
    totalLimitsNetOfCashCollateralOnly: 140,
  );
}

void main() {
  group("ProposedFacilitiesDraftHandler", () {
    late ProposedFacilitiesDraftHandler handler;

    setUp(() {
      handler = ProposedFacilitiesDraftHandler();
    });

    // ---------------------------------------------------------------------
    // buildDraftData TESTS
    // ---------------------------------------------------------------------
    test("buildDraftData → serializes cleanExposure for proposed & present",
        () {
      final vm = _TestProposedFacilitiesVM();

      vm.groupPositionList = GroupPosition(
        proposedPosition: [
          makePosition(101),
          makePosition(102),
        ],
        presentPosition: [
          makePosition(201),
        ],
      );

      vm.cleanExposureControllers?["101_proposed"] =
          TextEditingController(text: "11.11");
      vm.cleanExposureControllers?["102_proposed"] =
          TextEditingController(text: "22.22");
      vm.cleanExposureControllers?["201_present"] =
          TextEditingController(text: "33.33");

      final draft = handler.buildDraftData(vm);

      final proposed = draft["proposed"];
      final present = draft["present"];

      expect(proposed.length, 2);
      expect(present.length, 1);

      expect(proposed[0]["rimNo"], 101);
      expect(proposed[0]["cleanExposure"], "11.11");

      expect(proposed[1]["cleanExposure"], "22.22");
      expect(present[0]["cleanExposure"], "33.33");
    });

    test("buildDraftData → missing controller returns empty string", () {
      final vm = _TestProposedFacilitiesVM();

      vm.groupPositionList = GroupPosition(
        proposedPosition: [makePosition(500)],
        presentPosition: [],
      );

      // No controller added → should produce ""
      final draft = handler.buildDraftData(vm);

      final proposed = draft["proposed"];

      expect(proposed.length, 1);
      expect(proposed[0]["cleanExposure"], "");
    });

    // ---------------------------------------------------------------------
    // applyDraft TESTS
    // ---------------------------------------------------------------------
    test(
        "applyDraft → restores values to controllers"
        " & calls updateExposureField", () async {
      final vm = _TestProposedFacilitiesVM();

      vm.groupPositionList = GroupPosition(
        proposedPosition: [makePosition(101)],
        presentPosition: [makePosition(201)],
      );

      vm.cleanExposureControllers?["101_proposed"] =
          TextEditingController(text: "0");
      vm.cleanExposureControllers?["201_present"] =
          TextEditingController(text: "0");

      final draft = {
        "proposed": [
          {"rimNo": 101, "cleanExposure": "999.01"},
        ],
        "present": [
          {"rimNo": 201, "cleanExposure": "888.02"},
        ],
      };

      handler.applyDraft(vm, draft);

      expect(vm.cleanExposureControllers?["101_proposed"]!.text, "999.01");
      expect(vm.cleanExposureControllers?["201_present"]!.text, "888.02");

      expect(vm.spyCallCount, 2);
      expect(vm.spyRimNo, 201);
      expect(vm.spyValue, "888.02");
      expect(vm.spyIsProposed, false);
    });

    test("applyDraft → mismatch rimNo should not overwrite anything", () {
      final vm = _TestProposedFacilitiesVM();

      vm.groupPositionList = GroupPosition(
        proposedPosition: [makePosition(101)],
        presentPosition: [],
      );

      vm.cleanExposureControllers?["101_proposed"] =
          TextEditingController(text: "INITIAL");

      final draft = {
        "proposed": [
          {"rimNo": 999, "cleanExposure": "NOPE"},
        ],
        "present": [],
      };

      handler.applyDraft(vm, draft);

      expect(vm.cleanExposureControllers?["101_proposed"]!.text, "INITIAL");
      expect(vm.spyCallCount, 0);
    });

    test("applyDraft → handles draft shorter than rows safely", () {
      final vm = _TestProposedFacilitiesVM();

      vm.groupPositionList = GroupPosition(
        proposedPosition: [
          makePosition(101),
          makePosition(102),
        ],
        presentPosition: [],
      );

      vm.cleanExposureControllers?["101_proposed"] =
          TextEditingController(text: "A");
      vm.cleanExposureControllers?["102_proposed"] =
          TextEditingController(text: "B");

      final draft = {
        "proposed": [
          {"rimNo": 101, "cleanExposure": "FIRST_ONLY"},
        ],
      };

      handler.applyDraft(vm, draft);

      expect(vm.cleanExposureControllers?["101_proposed"]!.text, "FIRST_ONLY");
      expect(
        vm.cleanExposureControllers?["102_proposed"]!.text,
        "B",
      ); // unchanged
      expect(vm.spyCallCount, 1);
    });

    test("applyDraft → handles null / invalid sections gracefully", () {
      final vm = _TestProposedFacilitiesVM();

      vm.groupPositionList = GroupPosition(
        proposedPosition: [makePosition(123)],
        presentPosition: [],
      );

      vm.cleanExposureControllers?["123_proposed"] =
          TextEditingController(text: "X");

      final draft = {
        "proposed": null,
        "present": "invalid",
      };

      handler.applyDraft(vm, draft);

      expect(vm.cleanExposureControllers?["123_proposed"]!.text, "X");
      expect(vm.spyCallCount, 0);
    });
  });
}
