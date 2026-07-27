import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/profitability/relationship_utilization.dart";

void main() {
  group("RelationshipRevenueDetails", () {
    test("fromJson creates a valid instance", () {
      final Map<String, dynamic> json = {
        "product": "Loan",
        "accountCommitmentNumber": "ACC001",
        "accountLimit": "100000",
        "averageUtilization": "75000.0",
        "utilizationPercent": "75",
      };

      final detail = RelationshipRevenueDetails.fromJson(json);

      expect(detail.product, "Loan");
      expect(detail.accountCommitmentNumber, "ACC001");
      expect(detail.accountLimit, "100000");
      expect(detail.averageUtilization, "75000.0");
      expect(detail.utilizationPercent, "75");
    });

    test("toJson converts instance to JSON correctly", () {
      final detail = RelationshipRevenueDetails(
        product: "Loan",
        accountCommitmentNumber: "ACC001",
        accountLimit: "100000",
        averageUtilization: "75000.0",
        utilizationPercent: "75",
      );

      final json = detail.toJson();

      expect(json["product"], "Loan");
      expect(json["accountCommitmentNumber"], "ACC001");
      expect(json["accountLimit"], "100000");
      expect(json["averageUtilization"], "75000.0");
      expect(json["utilizationPercent"], "75");
    });
  });

  group("RelationshipUtilization", () {
    // test('fromJson creates a valid instance', () {
    //   final Map<String, dynamic> json = {
    //     'rim': 123,
    //     'customerName': 'Test Customer',
    //     'clientTurnover': 500000.0,
    //     'throughputToCbdPercentage': 80.0,
    //     'turnoverInCbdCua': 400000.0,
    //     'relationshipRevenueDetails': [
    //       {
    //         'product': 'Loan',
    //         'accountCommitmentNumber': 'ACC001',
    //         'accountLimit': 100000,
    //         'averageUtilization': 75000.0,
    //         'utilizationPercent': 75,
    //       },
    //       {
    //         'product': 'Credit Card',
    //         'accountCommitmentNumber': 'CC002',
    //         'accountLimit': 10000,
    //         'averageUtilization': 5000.0,
    //         'utilizationPercent': 50,
    //       },
    //     ],
    //   };

    //   final utilization = RelationshipUtilization.fromJson(json);

    //   expect(utilization.rim, 123);
    //   expect(utilization.customerName, 'Test Customer');
    //   expect(utilization.clientTurnover, 500000.0);
    //   expect(utilization.throughputToCbdPercentage, 80.0);
    //   expect(utilization.turnoverInCbdCua, 400000.0);
    //   expect(utilization.relationshipRevenueDetails, isNotNull);
    //   expect(utilization.relationshipRevenueDetails!.length, 2);
    //   expect(utilization.relationshipRevenueDetails![0].product, 'Loan');
    //   expect(utilization.relationshipRevenueDetails![1].product, 'Credit
    // Card');
    // });

    test("toJson converts instance to JSON correctly", () {
      final detail1 = RelationshipRevenueDetails(
        product: "Loan",
        accountCommitmentNumber: "ACC001",
        accountLimit: "100000",
        averageUtilization: "75000.0",
        utilizationPercent: "75",
      );

      final detail2 = RelationshipRevenueDetails(
        product: "Credit Card",
        accountCommitmentNumber: "CC002",
        accountLimit: "10000",
        averageUtilization: "5000.0",
        utilizationPercent: "50",
      );

      final utilization = RelationshipUtilization(
        rim: 123,
        customerName: "Test Customer",
        clientTurnover: "500000.0",
        throughputToCbdPercentage: "80.0",
        turnoverInCbdCua: "400000.0",
        relationshipRevenueDetails: [detail1, detail2],
      );

      final json = utilization.toJson();

      expect(json["rim"], 123);
      expect(json["customerName"], "Test Customer");
      expect(json["clientTurnover"], "500000.0");
      expect(json["throughputToCbdPercentage"], "80.0");
      expect(json["turnoverInCbdCua"], "400000.0");
      expect(json["relationshipRevenueDetails"], isA<List>());
      expect(json["relationshipRevenueDetails"].length, 2);
      expect(json["relationshipRevenueDetails"][0]["product"], "Loan");
      expect(json["relationshipRevenueDetails"][1]["product"], "Credit Card");
    });
  });
}
