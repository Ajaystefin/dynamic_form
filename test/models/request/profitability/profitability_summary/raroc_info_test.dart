import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/raroc_info.dart";

void main() {
  group("RarocInformation", () {
    test("fromJson creates a valid instance", () {
      final Map<String, dynamic> json = {
        "customerRim": "RIM123",
        "customerName": "Test Customer",
        "existingLastApprovedRarocPercent": "12.0",
        // 'proposedRarocPercentProposedByCoverage': 11.0,
        "proposedFinalRarocPercentExAnteRaroc": "13.0",
        "comments": "Some comments",
      };

      final rarocInformation = RarocInformation.fromJson(json);

      expect(rarocInformation.customerRim, "RIM123");
      expect(rarocInformation.customerName, "Test Customer");
      expect(rarocInformation.existingLastApprovedRarocPercent, "12.0");
      // expect(rarocInformation.proposedRarocPercentProposedByCoverage, 11.0);
      expect(rarocInformation.proposedFinalRarocPercentExAnteRaroc, "13.0");
      expect(rarocInformation.comments, "Some comments");
    });
  });
}
