import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/profitability/account_stat.dart";

void main() {
  group("AccountStatType", () {
    test("fromJson creates a valid instance", () {
      final Map<String, dynamic> json = {
        "rim": 123,
        "customerName": "Test Customer",
        "accountConduct": {
          "odHardcorePreviousYear": 100.0,
          "odHardcoreCurrentYearYtd": 120.0,
          "chequeReturnsInwardPreviousYear": 5,
          "chequeReturnsInwardCurrentYearYtd": 3,
          "chequeReturnsOutwardPreviousYear": 2,
          "chequeReturnsOutwardCurrentYearYtd": 1,
          "lbdReturnsPreviousYear": 0,
          "lbdReturnsCurrentYearYtd": 0,
          "pastDueOrExcesses": 50.0,
          "chequeReturns": 10.0,
          "turnoverInTheAccount": 1000.0,
          "odHardcore": 200.0,
          "unusualTransactions": 50.0,
          "transparencyAndDisclosureLevels": 80.0,
          "product": "Savings",
          "accountCommitmentNumber": "ACC123",
          "highBalancePreviousYear": "5000.0",
          "lowBalancePreviousYear": "100.0",
          "averageBalancePreviousYear": "2500.0",
          "turnoverPreviousYear": "10000.0",
          "highBalanceCurrentYear": "6000.0",
          "lowBalanceCurrentYear": "200.0",
          "averageBalanceCurrentYear": "3000.0",
          "turnoverCurrentYear": "12000.0",
        },
      };

      final accountStatType = AccountStatType.fromJson(json);

      expect(accountStatType.rim, 123);
      expect(accountStatType.customerName, "Test Customer");
      expect(accountStatType.accountConduct, isNotNull);
      expect(accountStatType.accountConduct!.odHardcorePreviousYear, 100.0);
    });

    test("toJson converts instance to JSON correctly", () {
      final accountStat = AccountStat(
        odHardcorePreviousYear: 100,
        odHardcoreCurrentYearYtd: 120,
        chequeReturnsInwardPreviousYear: 5,
        chequeReturnsInwardCurrentYearYtd: 3,
        chequeReturnsOutwardPreviousYear: 2,
        chequeReturnsOutwardCurrentYearYtd: 1,
        lbdReturnsPreviousYear: 0,
        lbdReturnsCurrentYearYtd: 0,
        passDueOrExcesses: 50,
        chequeReturns: 10,
        turnoverInTheAccount: 1000,
        odHardcore: 200,
        unusualTransactions: 50,
        transparencyAndDisclosureLevels: 80,
        product: "Savings",
        accountCommitmentNumber: "ACC123",
        highBalancePreviousYear: "5000.0",
        lowBalancePreviousYear: "100.0",
        averageBalancePreviousYear: "2500.0",
        turnoverPreviousYear: "10000.0",
        highBalanceCurrentYear: "6000.0",
        lowBalanceCurrentYear: "200.0",
        averageBalanceCurrentYear: "3000.0",
        turnoverCurrentYear: "12000.0",
      );

      final accountStatType = AccountStatType(
        rim: 123,
        customerName: "Test Customer",
        accountConduct: accountStat,
      );

      final json = accountStatType.toJson();

      expect(json["rim"], 123);
      expect(json["customerName"], "Test Customer");
      expect(json["accountConduct"], isA<Map<String, dynamic>>());
      expect(json["accountConduct"]["odHardcorePreviousYear"], 100.0);
    });
  });

  group("AccountStat", () {
    test("fromJson creates a valid instance", () {
      final Map<String, dynamic> json = {
        "odHardcorePreviousYear": 100.0,
        "odHardcoreCurrentYearYtd": 120.0,
        "chequeReturnsInwardPreviousYear": 5,
        "chequeReturnsInwardCurrentYearYtd": 3,
        "chequeReturnsOutwardPreviousYear": 2,
        "chequeReturnsOutwardCurrentYearYtd": 1,
        "lbdReturnsPreviousYear": 0,
        "lbdReturnsCurrentYearYtd": 0,
        "pastDueOrExcesses": 50.0,
        "chequeReturns": 10.0,
        "turnoverInTheAccount": 1000.0,
        "odHardcore": 200.0,
        "unusualTransactions": 50.0,
        "transparencyAndDisclosureLevels": 80.0,
        "productDescription": "Savings",
        "accountCommitmentNo": "ACC123",
        "maxBalPrvYr": "5000.0",
        "minBalPrvYr": "100.0",
        "avgBalPrvYrCr": "2500.0",
        "creditTrovPrvYr": "10000.0",
        "maxBalCurYr": "6000.0",
        "minBalCurYr": "200.0",
        "avgBalCurYrCr": "3000.0",
        "creditTrovCurYr": "12000.0",
      };

      final accountStat = AccountStat.fromJson(json);

      expect(accountStat.odHardcorePreviousYear, 100.0);
      expect(accountStat.odHardcoreCurrentYearYtd, 120.0);
      expect(accountStat.chequeReturnsInwardPreviousYear, 5);
      expect(accountStat.chequeReturnsInwardCurrentYearYtd, 3);
      expect(accountStat.chequeReturnsOutwardPreviousYear, 2);
      expect(accountStat.chequeReturnsOutwardCurrentYearYtd, 1);
      expect(accountStat.lbdReturnsPreviousYear, 0);
      expect(accountStat.lbdReturnsCurrentYearYtd, 0);
      expect(accountStat.passDueOrExcesses, 50.0);
      expect(accountStat.chequeReturns, 10.0);
      expect(accountStat.turnoverInTheAccount, 1000.0);
      expect(accountStat.odHardcore, 200.0);
      expect(accountStat.unusualTransactions, 50.0);
      expect(accountStat.transparencyAndDisclosureLevels, 80.0);
      expect(accountStat.product, "Savings");
      expect(accountStat.accountCommitmentNumber, "ACC123");
      expect(accountStat.highBalancePreviousYear, "5000.0");
      expect(accountStat.lowBalancePreviousYear, "100.0");
      expect(accountStat.averageBalancePreviousYear, "2500.0");
      expect(accountStat.turnoverPreviousYear, "10000.0");
      expect(accountStat.highBalanceCurrentYear, "6000.0");
      expect(accountStat.lowBalanceCurrentYear, "200.0");
      expect(accountStat.averageBalanceCurrentYear, "3000.0");
      expect(accountStat.turnoverCurrentYear, "12000.0");
    });

    test("toJson converts instance to JSON correctly", () {
      final accountStat = AccountStat(
        odHardcorePreviousYear: 100,
        odHardcoreCurrentYearYtd: 120,
        chequeReturnsInwardPreviousYear: 5,
        chequeReturnsInwardCurrentYearYtd: 3,
        chequeReturnsOutwardPreviousYear: 2,
        chequeReturnsOutwardCurrentYearYtd: 1,
        lbdReturnsPreviousYear: 0,
        lbdReturnsCurrentYearYtd: 0,
        passDueOrExcesses: 50,
        chequeReturns: 10,
        turnoverInTheAccount: 1000,
        odHardcore: 200,
        unusualTransactions: 50,
        transparencyAndDisclosureLevels: 80,
        product: "Savings",
        accountCommitmentNumber: "ACC123",
        highBalancePreviousYear: "5000.0",
        lowBalancePreviousYear: "100.0",
        averageBalancePreviousYear: "2500.0",
        turnoverPreviousYear: "10000.0",
        highBalanceCurrentYear: "6000.0",
        lowBalanceCurrentYear: "200.0",
        averageBalanceCurrentYear: "3000.0",
        turnoverCurrentYear: "12000.0",
      );

      final json = accountStat.toJson();

      expect(json["odHardcorePreviousYear"], 100.0);
      expect(json["odHardcoreCurrentYearYtd"], 120.0);
      expect(json["chequeReturnsInwardPreviousYear"], 5);
      expect(json["chequeReturnsInwardCurrentYearYtd"], 3);
      expect(json["chequeReturnsOutwardPreviousYear"], 2);
      expect(json["chequeReturnsOutwardCurrentYearYtd"], 1);
      expect(json["lbdReturnsPreviousYear"], 0);
      expect(json["lbdReturnsCurrentYearYtd"], 0);
      expect(json["pastDueOrExcesses"], 50.0);
      expect(json["chequeReturns"], 10.0);
      expect(json["turnoverInTheAccount"], 1000.0);
      expect(json["odHardcore"], 200.0);
      expect(json["unusualTransactions"], 50.0);
      expect(json["transparencyAndDisclosureLevels"], 80.0);
      expect(json["productDescription"], "Savings");
      expect(json["accountCommitmentNo"], "ACC123");
      expect(json["maxBalPrvYr"], "5000.0");
      expect(json["minBalPrvYr"], "100.0");
      expect(json["avgBalPrvYrCr"], "2500.0");
      expect(json["creditTrovPrvYr"], "10000.0");
      expect(json["maxBalCurYr"], "6000.0");
      expect(json["minBalCurYr"], "200.0");
      expect(json["avgBalCurYrCr"], "3000.0");
      expect(json["creditTrovCurYr"], "12000.0");
    });
  });
}
