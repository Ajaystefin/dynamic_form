import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";

void main() {
  group("Security.fromJson AED amounts", () {
    Security parse(Object? present, Object? proposed) {
      return Security.fromJson(<String, dynamic>{
        "presentSecurity": 0,
        "proposedSecurity": 230,
        "aedPresentSecurity": present,
        "aedProposedSecurity": proposed,
        "currency": "AUD",
      });
    }

    test("accepts whole numbers sent as ints", () {
      // The shape issue/getSecurityDetails.json returns: whole AED amounts
      // arrive unquoted and without a decimal point.
      final Security security = parse(0, 578);

      expect(security.aedPresentSecurity, 0.0);
      expect(security.aedProposedSecurity, 578.0);
    });

    test("accepts doubles", () {
      final Security security = parse(111.4, 578.53);

      expect(security.aedPresentSecurity, 111.4);
      expect(security.aedProposedSecurity, 578.53);
    });

    test("accepts quoted amounts", () {
      final Security security = parse("0", "578.53");

      expect(security.aedPresentSecurity, 0.0);
      expect(security.aedProposedSecurity, 578.53);
    });

    test("leaves a missing amount null", () {
      final Security security = parse(null, null);

      expect(security.aedPresentSecurity, isNull);
      expect(security.aedProposedSecurity, isNull);
    });
  });
}
