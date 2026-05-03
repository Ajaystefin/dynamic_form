import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/risk_rating/updated_rating.dart";

void main() {
  group("UpdatedRating Model Tests", () {
    test("fromJson should parse correctly", () {
      final json = {
        "entityId": 1,
        "rimNo": 12345,
        "existingFinalGrade": r"$CRR1#",
        "existingMmodelId": "ModelX",
        "existingFinacialYearDate": "2024",
        "existingCascadeGrade": "B",
        "existingCascadeReason": "Risk downgrade",
        "existingCascadeNote": "Note A",
        "existinOverrideReason": "Manual override",
        "existinOverrideGrade": "A",
        "existinOverrideComment": "Comment A",
        "proposedFinalGrade": r"$CRR2#",
        "proposedModelId": "ModelY",
        "proposedFinacialYearDate": "2025",
        "sourceLongName": "Source A",
        "proposedCascadeGrade": "C",
        "proposedCascadeReason": "Reason B",
        "proposedCascadeNote": "Note B",
        "proposedOverrideReason": "Override B",
        "proposedOverrideGrade": "B",
        "proposedOverrideComment": "Comment B",
        "isLatestVersion": true,
        "latestStatementId": 999,
        "businessStatus": "Active",
      };

      final rating = UpdatedRating.fromJson(json);

      expect(rating.entityId, 1);
      expect(rating.rimNo, 12345);
      expect(rating.existingFinalGrade, r"$CRR1#");
      expect(rating.proposedFinalGrade, r"$CRR2#");
      expect(rating.isLatestVersion, true);
      expect(rating.businessStatus, "Active");
    });
  });
}
