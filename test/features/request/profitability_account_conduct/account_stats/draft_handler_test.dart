// ignore_for_file: prefer_const_constructors

import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_stats/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_stats/model.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/profitability/account_stat.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AccountStatsDraftHandler handler;
  late AccountStatsViewModel vm;

  setUp(() {
    handler = AccountStatsDraftHandler();
    vm = AccountStatsViewModel();

    // formKey is FINAL — do not reassign
    vm.comment = "Initial comment";
    vm.customerWiseAccountStat = {};
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------
  group("buildDraftData", () {
    test("serializes comments and groups stats by customerRimNo", () {
      final customer1 = Customer(customerRimNo: 111);
      final customer2 = Customer(customerRimNo: 222);

      final row1 = AccountStat()..accountCommitmentNumber = "A1";
      final row2 = AccountStat()..accountCommitmentNumber = "A2";
      final row3 = AccountStat()..accountCommitmentNumber = "B1";

      vm.customerWiseAccountStat = {
        customer1: [row1, row2],
        customer2: [row3],
      };

      final draft = handler.buildDraftData(vm);

      expect(draft["comments"], "Initial comment");

      final byCustomer =
          draft["accountStatsByCustomer"] as Map<String, dynamic>;

      expect(byCustomer.keys, containsAll(["111", "222"]));
      expect((byCustomer["111"] as List).length, 2);
      expect((byCustomer["222"] as List).length, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // applyDraft
  // ---------------------------------------------------------------------------
  group("applyDraft", () {
    test("restores all fields when draft length matches", () {
      final customer = Customer(customerRimNo: 111);

      final row0 = AccountStat();
      final row1 = AccountStat();

      vm.customerWiseAccountStat = {
        customer: [row0, row1],
      };

      handler.applyDraft(vm, {
        "comments": "Drafted comment",
        "accountStatsByCustomer": {
          "111": [
            {
              "accountCommitmentNumber": "ACN-0",
              "highBalancePreviousYear": "HBPY-0",
              "lowBalancePreviousYear": "LBPY-0",
              "averageBalancePreviousYear": "ABPY-0",
              "turnoverPreviousYear": "TPY-0",
              "highBalanceCurrentYear": "HBCY-0",
              "lowBalanceCurrentYear": "LBCY-0",
              "averageBalanceCurrentYear": "ABCY-0",
              "turnoverCurrentYear": "TCY-0",
            },
            {
              "accountCommitmentNumber": "ACN-1",
              "highBalancePreviousYear": "HBPY-1",
              "lowBalancePreviousYear": "LBPY-1",
              "averageBalancePreviousYear": "ABPY-1",
              "turnoverPreviousYear": "TPY-1",
              "highBalanceCurrentYear": "HBCY-1",
              "lowBalanceCurrentYear": "LBCY-1",
              "averageBalanceCurrentYear": "ABCY-1",
              "turnoverCurrentYear": "TCY-1",
            },
          ],
        },
      });

      expect(vm.comment, "Drafted comment");

      expect(row0.accountCommitmentNumber, "ACN-0");
      expect(row0.highBalancePreviousYear, "HBPY-0");
      expect(row0.lowBalancePreviousYear, "LBPY-0");
      expect(row0.averageBalancePreviousYear, "ABPY-0");
      expect(row0.turnoverPreviousYear, "TPY-0");
      expect(row0.highBalanceCurrentYear, "HBCY-0");
      expect(row0.lowBalanceCurrentYear, "LBCY-0");
      expect(row0.averageBalanceCurrentYear, "ABCY-0");
      expect(row0.turnoverCurrentYear, "TCY-0");

      expect(row1.accountCommitmentNumber, "ACN-1");
      expect(row1.highBalancePreviousYear, "HBPY-1");
      expect(row1.lowBalancePreviousYear, "LBPY-1");
      expect(row1.averageBalancePreviousYear, "ABPY-1");
      expect(row1.turnoverPreviousYear, "TPY-1");
      expect(row1.highBalanceCurrentYear, "HBCY-1");
      expect(row1.lowBalanceCurrentYear, "LBCY-1");
      expect(row1.averageBalanceCurrentYear, "ABCY-1");
      expect(row1.turnoverCurrentYear, "TCY-1");
    });

    test("does nothing when draft list length mismatches", () {
      final customer = Customer(customerRimNo: 999);

      final row0 = AccountStat();
      final row1 = AccountStat();

      vm.customerWiseAccountStat = {
        customer: [row0, row1],
      };

      handler.applyDraft(vm, {
        "accountStatsByCustomer": {
          "999": [
            {"accountCommitmentNumber": "SHOULD-NOT-APPLY"},
          ],
        },
      });

      expect(row0.accountCommitmentNumber, isNull);
      expect(row1.accountCommitmentNumber, isNull);
    });

    test("handles missing or null accountStatsByCustomer safely", () {
      final customer = Customer(customerRimNo: 100);
      final row = AccountStat();

      vm.customerWiseAccountStat = {
        customer: [row],
      };

      handler.applyDraft(vm, {});
      handler.applyDraft(vm, {"accountStatsByCustomer": null});

      expect(row.accountCommitmentNumber, isNull);
    });

    test("skips null or missing fields inside draft row", () {
      final customer = Customer(customerRimNo: 111);
      final row = AccountStat();

      vm.customerWiseAccountStat = {
        customer: [row],
      };

      handler.applyDraft(vm, {
        "accountStatsByCustomer": {
          "111": [
            {
              "accountCommitmentNumber": "ONLY-THIS",
              "highBalancePreviousYear": "AND-THIS",
            },
          ],
        },
      });

      expect(row.accountCommitmentNumber, "ONLY-THIS");
      expect(row.highBalancePreviousYear, "AND-THIS");

      expect(row.lowBalancePreviousYear, isNull);
      expect(row.averageBalancePreviousYear, isNull);
      expect(row.turnoverPreviousYear, isNull);
      expect(row.highBalanceCurrentYear, isNull);
      expect(row.lowBalanceCurrentYear, isNull);
      expect(row.averageBalanceCurrentYear, isNull);
      expect(row.turnoverCurrentYear, isNull);
    });
  });
}
