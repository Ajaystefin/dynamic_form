import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/draft_handler.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/model.dart";
import "package:wcas_frontend/models/request/esg_certification.dart";

class MockEsgCertificationViewModel extends Mock
    implements EsgCertificationViewModel {}

void main() {
  // Initialize the test binding to allow GlobalKey and other widget-related
  // logic to function
  TestWidgetsFlutterBinding.ensureInitialized();

  late EsgCertificationDraftHandler handler;
  late MockEsgCertificationViewModel mockVm;

  setUpAll(() {
    registerFallbackValue(ExclusionStatus.unknown);
    registerFallbackValue(<SffCategory>[]);
    registerFallbackValue(<FacilityRiskRating>[]);
  });

  setUp(() {
    handler = EsgCertificationDraftHandler();
    mockVm = MockEsgCertificationViewModel();
  });

  group("EsgCertificationDraftHandler", () {
    test("buildDraftData should convert ViewModel state to a Map", () {
      // Arrange: Set up mock values for the ViewModel
      final GlobalKey<FormState> mockFormKey = GlobalKey<FormState>();
      when(() => mockVm.formKey).thenReturn(mockFormKey);

      // when(() => mockVm.sffRequired).thenReturn(null);
      // when(() => mockVm.sllRequired).thenReturn(false);
      when(() => mockVm.isAdverseMedia).thenReturn(true);
      when(() => mockVm.adverseMediaSummary).thenReturn("Some summary");
      when(() => mockVm.isExcluded).thenReturn("YES");
      when(() => mockVm.excludedStatus).thenReturn(ExclusionStatus.excluded);
      when(() => mockVm.excludedActivities)
          .thenReturn(["Activity 1", "Activity 2"]);
      when(() => mockVm.additionalChecklist).thenReturn("Checklist content");

      final List<SffCategory> categories = [
        SffCategory(
          sffCategory: "Cat 1",
          isSelected: true,
          briefDesc: "Desc 1",
        ),
      ];
      when(() => mockVm.esgSffCategoriess).thenReturn(categories);

      final List<FacilityRiskRating> riskRatings = [
        FacilityRiskRating(
          borrowerRim: "RIM1",
          facilityName: "Fac 1",
          sicCode: "SIC1",
          esRating: "R1",
          pctTotalLimit: 10,
        ),
      ];
      when(() => mockVm.facilitiesRiskRatings).thenReturn(riskRatings);

      when(() => mockVm.inputsByRefId)
          .thenReturn({101: "Input 1", 102: "Input 2"});

      // Act: Build the draft data map
      final Map<String, dynamic> result = handler.buildDraftData(mockVm);

      // Assert: Verify the map content
      // expect(result['sffRequired'], isTrue);
      // expect(result['sllRequired'], isFalse);
      expect(result["isAdverseMedia"], isTrue);
      expect(result["adverseMediaSummary"], "Some summary");
      expect(result["isExcluded"], "YES");
      expect(
        result["excludedStatus"],
        "YES",
      ); // ExclusionStatus.excluded.apiValue is 'YES'
      expect(result["excludedActivities"], ["Activity 1", "Activity 2"]);
      expect(result["additionalChecklist"], "Checklist content");
      expect(result["esgSffCategoriess"], isA<List>());
      expect((result["esgSffCategoriess"] as List).length, 1);
      // expect(result['facilitiesRiskRatings'], isA<List>());
      // expect((result['facilitiesRiskRatings'] as List).length, 1);
      expect(result["inputsByRefId"], {"101": "Input 1", "102": "Input 2"});
    });

    test("applyDraft should update ViewModel state from a Map", () {
      // Arrange: Prepare draft data
      final Map<String, dynamic> draftData = {
        "sffRequired": true,
        "sllRequired": true,
        "isAdverseMedia": false,
        "adverseMediaSummary": "Updated summary",
        "isExcluded": "NO",
        "excludedStatus": "NO",
        "excludedActivities": ["Updated Activity"],
        "additionalChecklist": "Updated checklist",
        "esgSffCategoriess": [
          {
            "sffCategory": "New Cat",
            "isSelected": true,
            "briefDesc": "New Desc",
          }
        ],
        "facilitiesRiskRatings": [
          {
            "borrowerRim": "RIM2",
            "facilityName": "Fac 2",
            "sicCode": "SIC2",
            "esRating": "R2",
            "pctTotalLimit": 20.0,
          }
        ],
        "inputsByRefId": {"201": "New Input 1", "202": "New Input 2"},
      };

      // Mock dependencies and default values
      when(() => mockVm.sffRequired).thenReturn(false);
      when(() => mockVm.sllRequired).thenReturn(false);
      when(() => mockVm.isAdverseMedia).thenReturn(true);
      when(() => mockVm.adverseMediaSummary).thenReturn("");
      when(() => mockVm.isExcluded).thenReturn("");
      when(() => mockVm.additionalChecklist).thenReturn("");
      final Map<int, String> mockInputs = {};
      when(() => mockVm.inputsByRefId).thenReturn(mockInputs);
      when(() => mockVm.fieldVersion).thenReturn(0);

      // Act: Apply the draft data to the mock ViewModel
      handler.applyDraft(mockVm, draftData);

      // Assert: Verify setters were called with expected values
      // verify(() => mockVm.sffRequired = true).called(1);
      // verify(() => mockVm.sllRequired = true).called(1);
      verify(() => mockVm.isAdverseMedia = false).called(1);
      verify(() => mockVm.adverseMediaSummary = "Updated summary").called(1);
      verify(() => mockVm.isExcluded = "NO").called(1);
      verify(() => mockVm.excludedStatus = ExclusionStatus.included).called(1);
      verify(() => mockVm.excludedActivities = ["Updated Activity"]).called(1);
      verify(() => mockVm.additionalChecklist = "Updated checklist").called(1);
      verify(() => mockVm.esgSffCategoriess = any()).called(1);
      // verify(() => mockVm.facilitiesRiskRatings = any()).called(1);
      verify(() => mockVm.fieldVersion = any()).called(1);

      expect(mockInputs[201], "New Input 1");
      expect(mockInputs[202], "New Input 2");
    });

    test("applyDraft should use existing values if keys are missing in Map",
        () {
      // Arrange: Prepare an empty map
      final Map<String, dynamic> emptyDraftData = {};

      when(() => mockVm.sffRequired).thenReturn(false);
      when(() => mockVm.sllRequired).thenReturn(true);
      when(() => mockVm.isAdverseMedia).thenReturn(false);
      when(() => mockVm.adverseMediaSummary).thenReturn("Old summary");
      when(() => mockVm.isExcluded).thenReturn("N/A");
      when(() => mockVm.additionalChecklist).thenReturn("Old checklist");
      when(() => mockVm.fieldVersion).thenReturn(10);

      // Act: Apply empty draft data
      handler.applyDraft(mockVm, emptyDraftData);

      // Assert: Verify existing values were reapplied or maintained
      // verify(() => mockVm.sffRequired = false).called(1);
      // verify(() => mockVm.sllRequired = true).called(1);
      verify(() => mockVm.isAdverseMedia = false).called(1);
      verify(() => mockVm.adverseMediaSummary = "Old summary").called(1);
      verify(() => mockVm.isExcluded = "N/A").called(1);
      verify(() => mockVm.additionalChecklist = "Old checklist").called(1);
      verify(() => mockVm.fieldVersion = 11).called(1);
    });
  });
}
