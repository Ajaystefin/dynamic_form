import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  group("APIEndpoints", () {
    test("all static endpoints match expected values", testEndpoints);
  });
}
