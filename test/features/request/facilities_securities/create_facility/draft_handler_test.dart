import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/draft_handler.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("CreateFacilityDraftHandler", () {
    late CreateFacilityViewModel viewModel;
    late CreateFacilityDraftHandler handler;

    setUp(() {
      viewModel = CreateFacilityViewModel();
      handler = CreateFacilityDraftHandler();
    });

    test("buildDraftData serializes state to JSON", () {
      // Arrange
      final facility = viewModel.getFacility;
      facility.facilityDescription =
          Reference(id: 1, name: "Facility 1", isActive: true);
      facility.proposedLimit = 1000;
      facility.facilityTitle = "Test Title";
      facility.limitExpireDate = DateTime(2025, 12, 31);

      viewModel.feeDefualtRate = [FeeRate(feeType: "Fee 1")];
      viewModel.isLimitCaps = true;
      viewModel.proposedLimitController.text = "1000";
      viewModel.dynamicFormDocument = {"testKey": "testValue"};

      // Act
      final draftData = handler.buildDraftData(viewModel);

      // Assert
      expect(draftData["facilityDescription"]["id"], 1);
      expect(draftData["facilityDescription"]["name"], "Facility 1");
      expect(draftData["proposedLimit"], 1000);
      expect(draftData["facilityTitle"], "Test Title");
      expect(
        draftData["limitExpireDate"],
        DateTime(2025, 12, 31).toIso8601String(),
      );
      expect(draftData["feeDefualtRate"][0]["feeType"], "Fee 1");
      expect(draftData["isLimitCaps"], true);
      expect(draftData["proposedLimitControllerText"], "1000");
      expect(draftData["dynamicFormDocument"]["testKey"], "testValue");
    });

    test("applyDraft restores draft values into live state", () {
      // Arrange
      final draftJson = {
        "facilityDescription": {
          "id": 2,
          "name": "Facility 2",
          "isActive": true,
        },
        "proposedLimit": 2000,
        "facilityTitle": "Restored Title",
        "limitExpireDate": DateTime(2026, 1, 1).toIso8601String(),
        "feeDefualtRate": [
          {"feeType": "Fee 2"},
        ],
        "isLimitCaps": false,
        "proposedLimitControllerText": "2000",
        "dynamicFormDocument": {"restoredKey": "restoredValue"},
      };

      // Act
      handler.applyDraft(viewModel, draftJson);

      // Assert
      final facility = viewModel.getFacility;
      expect(facility.facilityDescription?.id, 2);
      expect(facility.facilityDescription?.name, "Facility 2");
      expect(facility.proposedLimit, 2000);
      expect(facility.facilityTitle, "Restored Title");
      expect(facility.limitExpireDate, DateTime(2026, 1, 1));
      expect(viewModel.feeDefualtRate[0].feeType, "Fee 2");
      expect(viewModel.isLimitCaps, false);
      expect(viewModel.proposedLimitController.text, "2000");
      expect(viewModel.dynamicFormDocument["restoredKey"], "restoredValue");
    });

    test("applyDraft handles missing draft fields gracefully", () {
      // Arrange
      final facility = viewModel.getFacility;
      facility.facilityDescription = Reference(id: 1, name: "Original");
      facility.proposedLimit = 500;
      viewModel.dynamicFormDocument = {"original": true};

      final Map<String, dynamic> emptyDraftJson = {};

      // Act
      handler.applyDraft(viewModel, emptyDraftJson);

      // Assert - Should remain unchanged
      expect(facility.facilityDescription?.name, "Original");
      expect(facility.proposedLimit, 500);
      expect(viewModel.dynamicFormDocument["original"], true);
    });
  });
}
