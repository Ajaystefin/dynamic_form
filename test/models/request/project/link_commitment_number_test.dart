import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/models/request/project/link_commitment_number.dart";

// Mock class (to satisfy mocktail usage requirement)
class MockJson extends Mock implements Map<String, dynamic> {}

class ServerConstants {
  static const String aedCurrency = "AED";
}

void main() {
  setUpAll(() {
    registerFallbackValue(MockJson());
  });

  group("LinkCommitmentNumber Model Tests", () {
    test("fromJson parses correctly when currency is NOT AED", () {
      final json = {
        "currency": "USD",
        "presentLimitAED": 5000,
        "presentLimit": 9999, // ignored
        "presentOutstanding": 2500,
        "commitmentAccountNumber": "ACC001",
        "limitDescription": 7,
      };

      final model = LinkCommitmentNumber.fromJson(json);

      expect(model.projectAllocationAccount, "ACC001");
      expect(model.facilityType, 7);
      expect(model.limitAmountInAED, 5000.0);
      expect(model.currentOSInAED, 2500.0);
    });

    test("fromJson parses correctly when currency IS AED", () {
      final json = {
        "currency": ServerConstants.aedCurrency,
        "presentLimit": 8888,
        "presentLimitAED": 1234, // ignored
        "presentOutstanding": 4444,
        "commitmentAccountNumber": "ACC-AED",
        "limitDescription": 20,
      };

      final model = LinkCommitmentNumber.fromJson(json);

      expect(model.projectAllocationAccount, "ACC-AED");
      expect(model.facilityType, 20);
      expect(model.limitAmountInAED, 8888.0);
      expect(model.currentOSInAED, 4444.0);
    });

    test("toJson returns correct mapping", () {
      final model = LinkCommitmentNumber(
        projectAllocationAccount: "ACC123",
        facilityType: 9,
        limitAmountInAED: 1000.5,
        currentOSInAED: 200.25,
      );

      final map = model.toJson();

      expect(map["commitmentAccountNumber"], "ACC123");
      expect(map["limitDescription"], 9);
      expect(map["presentLimitAED"], 1000.5);
      expect(map["presentOutstanding"], 200.25);
    });

    test("copyWith overrides only provided fields", () {
      final base = LinkCommitmentNumber(
        projectAllocationAccount: "ACC1",
        facilityType: 1,
        limitAmountInAED: 10,
        currentOSInAED: 5,
      );

      final updated = base.copyWith(
        projectAllocationAccount: "UPDATED",
        limitAmountInAED: 500,
      );

      expect(updated.projectAllocationAccount, "UPDATED");
      expect(updated.limitAmountInAED, 500.0);
      // unchanged fields:
      expect(updated.facilityType, 1);
      expect(updated.currentOSInAED, 5.0);
    });

    test("copyWith returns identical object when no fields provided", () {
      final base = LinkCommitmentNumber(
        projectAllocationAccount: "ACC",
        facilityType: 3,
        limitAmountInAED: 100,
        currentOSInAED: 50,
      );

      final clone = base.copyWith();

      expect(clone.projectAllocationAccount, "ACC");
      expect(clone.facilityType, 3);
      expect(clone.limitAmountInAED, 100.0);
      expect(clone.currentOSInAED, 50.0);
    });

    test("mocktail integration test (mock json)", () {
      final mockJson = MockJson();

      when(() => mockJson["currency"]).thenReturn(ServerConstants.aedCurrency);
      when(() => mockJson["presentLimit"]).thenReturn(3000);
      when(() => mockJson["presentOutstanding"]).thenReturn(1200);
      when(() => mockJson["commitmentAccountNumber"]).thenReturn("MOCK-ACC");
      when(() => mockJson["limitDescription"]).thenReturn(30);

      final model = LinkCommitmentNumber.fromJson(mockJson);

      expect(model.projectAllocationAccount, "MOCK-ACC");
      expect(model.facilityType, 30);
      expect(model.limitAmountInAED, 3000.0);
      expect(model.currentOSInAED, 1200.0);

      verify(() => mockJson["currency"]).called(1);
    });
  });
}
