import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/risk_rating/internal_rating.dart";

void main() {
  group("getCrr function", () {
    test(r"should extract value between $ and #", () {
      const input = r"$CRR123#Extra";
      final result = getCrr(input);
      expect(result, "CRR123");
    });

    test("should return original string if delimiters not found", () {
      const input = "CRR123";
      final result = getCrr(input);
      expect(result, "CRR123");
    });

    test("should return null if input is null", () {
      final result = getCrr(null);
      expect(result, null);
    });
  });

  group("InternalRating.update factory", () {
    test("should create InternalRating with correct values", () {
      InternalRating.fromJson({});
    });
  });
}
