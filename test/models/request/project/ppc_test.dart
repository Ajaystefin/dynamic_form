import "package:test/test.dart";
import "package:wcas_frontend/models/request/project/ppc.dart";

void main() {
  group("PPC model", () {
    test("constructor assigns all fields correctly", () {
      final p = PPC(
        ppcId: 1,
        ppcNo: "PPC-001",
        ppcDate: "2025-12-01",
        grossValue: 100,
        cumulativeValue: 150,
        workDone: 60,
        cumulativeWorkDone: 80,
        advancePaymentDeduction: 5,
        retentionDeduction: 10,
        netValue: 85,
        vatAmount: 4.25,
        otherPayment: 2.5,
        totalWithVat: 89.25,
        actualPaymentReceived: 80,
        datePaymentReceived: "2025-12-10",
        comments: "ok",
      );

      expect(p.ppcId, 1);
      expect(p.ppcNo, "PPC-001");
      expect(p.ppcDate, "2025-12-01");
      expect(p.grossValue, 100);
      expect(p.cumulativeValue, 150);
      expect(p.workDone, 60);
      expect(p.cumulativeWorkDone, 80);
      expect(p.advancePaymentDeduction, 5);
      expect(p.retentionDeduction, 10);
      expect(p.netValue, 85);
      expect(p.vatAmount, 4.25);
      expect(p.otherPayment, 2.5);
      expect(p.totalWithVat, 89.25);
      expect(p.actualPaymentReceived, 80);
      expect(p.datePaymentReceived, "2025-12-10");
      expect(p.comments, "ok");
    });

    test("fromJson parses all fields correctly", () {
      final json = {
        "ppcId": 1,
        "ppcNo": 123, // should convert to string
        "ppcDate": "2025-12-01",
        "grossPpcValue": "100.0",
        "cumulativePpcValue": 150,
        "workDone": "60",
        "cumulativeWorkDone": 80,
        "advancePaymentDeduction": "5",
        "retentionDeduction": 10,
        "netPpcValue": "85",
        "vatAmount": "4.25",
        "otherPayment": 2.5,
        "netCertifiedAmountVat": "89.25",
        "actualPaymentReceived": "80",
        "datePaymentReceived": "2025-12-10",
        "comments": "ok",
      };

      final p = PPC.fromJson(json);

      expect(p.ppcId, 1);
      expect(p.ppcNo, "123"); // converted to string
      expect(p.ppcDate, "2025-12-01");
      expect(p.grossValue, 100.0);
      expect(p.cumulativeValue, 150.0);
      expect(p.workDone, 60.0);
      expect(p.cumulativeWorkDone, 80.0);
      expect(p.advancePaymentDeduction, 5.0);
      expect(p.retentionDeduction, 10.0);
      expect(p.netValue, 85.0);
      expect(p.vatAmount, 4.25);
      expect(p.otherPayment, 2.5);
      expect(p.totalWithVat, 89.25);
      expect(p.actualPaymentReceived, 80.0);
      expect(p.datePaymentReceived, "2025-12-10");
      expect(p.comments, "ok");
    });

    test("ppcDisplayNo returns ppcNo when available", () {
      final p = PPC(ppcNo: "PPC-001", ppcId: 1);
      expect(p.ppcDisplayNo, "PPC-001");
    });

    test("ppcDisplayNo falls back to ppcId when ppcNo is empty", () {
      final p = PPC(ppcNo: "   ", ppcId: 5);
      expect(p.ppcDisplayNo, "5");
    });

    test("ppcDisplayNo returns empty string when both null", () {
      final p = PPC();
      expect(p.ppcDisplayNo, "");
    });

    test("toJson returns correct map with values", () {
      final p = PPC(
        ppcId: 1,
        ppcNo: "PPC-001",
        ppcDate: "2025-12-01",
        grossValue: 100,
        cumulativeValue: 150,
        workDone: 60,
        cumulativeWorkDone: 80,
        advancePaymentDeduction: 5,
        retentionDeduction: 10,
        netValue: 85,
        vatAmount: 4.25,
        otherPayment: 2.5,
        totalWithVat: 89.25,
        actualPaymentReceived: 80,
        datePaymentReceived: "2025-12-10",
        comments: "ok",
      );

      final j = p.toJson();

      expect(j["ppcId"], 1);
      expect(j["ppcNo"], "PPC-001");
      expect(j["ppcDate"], "2025-12-01");
      expect(j["grossPpcValue"], 100);
      expect(j["cumulativePpcValue"], 150);
      expect(j["workDone"], 60);
      expect(j["cumulativeWorkDone"], 80);
      expect(j["advancePaymentDeduction"], 5);
      expect(j["retentionDeduction"], 10);
      expect(j["netPpcValue"], 85);
      expect(j["vatAmount"], 4.25);
      expect(j["otherPayment"], 2.5);
      expect(j["netCertifiedAmountVat"], 89.25);
      expect(j["actualPaymentReceived"], 80);
      expect(j["datePaymentReceived"], "2025-12-10");
      expect(j["comments"], "ok");
    });

    test("toJson handles nulls correctly", () {
      final p = PPC();

      final j = p.toJson();

      expect(j["ppcId"], isNull);
      expect(j["ppcNo"], "");
      expect(j["ppcDate"], "");
      expect(j["datePaymentReceived"], "");
      expect(j["comments"], "");
      expect(j["grossPpcValue"], isNull);
      expect(j["netPpcValue"], isNull);
    });
  });
}
