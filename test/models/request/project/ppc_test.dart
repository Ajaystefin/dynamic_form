import "package:test/test.dart";
import "package:wcas_frontend/models/request/project/ppc.dart";

void main() {
  group("PPC model", () {
    test("constructor assigns fields", () {
      final p = PPC(
        ppc: 1,
        grossPPCValue: 100,
        cumulativePPCValue: 150,
        workDonePercent: 60,
        cumulativeWorkDonePercent: 80,
        netPPCValue: 90,
        contractorId: "C-1",
        ppcNo: "PPC-001",
        ppcDate: "2025-12-01",
        grossPpcValue: 100,
        cumulativePpcValue: 150,
        workDone: 60,
        cumulativeWorkDone: 80,
        advancePaymentDeduction: 5,
        retentionDeduction: 10,
        netPpcValue: 85,
        vatAmount: 4.25,
        otherPayment: 2.5,
        netCertifiedAmountVat: 89.25,
        actualPaymentReceived: 80,
        datePaymentReceived: "2025-12-10",
        comments: "ok",
      );

      expect(p.ppc, 1.0);
      expect(p.grossPPCValue, 100.0);
      expect(p.cumulativePPCValue, 150.0);
      expect(p.workDonePercent, 60.0);
      expect(p.cumulativeWorkDonePercent, 80.0);
      expect(p.netPPCValue, 90.0);
      expect(p.contractorId, "C-1");
      expect(p.ppcNo, "PPC-001");
      expect(p.ppcDate, "2025-12-01");
      expect(p.grossPpcValue, 100.0);
      expect(p.cumulativePpcValue, 150.0);
      expect(p.workDone, 60.0);
      expect(p.cumulativeWorkDone, 80.0);
      expect(p.advancePaymentDeduction, 5.0);
      expect(p.retentionDeduction, 10.0);
      expect(p.netPpcValue, 85.0);
      expect(p.vatAmount, 4.25);
      expect(p.otherPayment, 2.5);
      expect(p.netCertifiedAmountVat, 89.25);
      expect(p.actualPaymentReceived, 80.0);
      expect(p.datePaymentReceived, "2025-12-10");
      expect(p.comments, "ok");
    });

    test("fromJson parses numerics and sanitizes strings", () {
      final json = {
        "ppc": "1.0",
        "grossPPCValue": 100,
        "cumulativePPCValue": "150.0",
        "workDonePercent": 60.0,
        "cumulativeWorkDonePercent": "80",
        "netPPCValue": "90.0",
        "contractorId": "  C-1  ", // should sanitize (trim)
        "ppcNo": "PPC-001",
        "ppcDate": "2025-12-01",
        "grossPpcValue": "100.00",
        "cumulativePpcValue": 150,
        "workDone": "60",
        "cumulativeWorkDone": 80.0,
        "advancePaymentDeduction": "5.0",
        "retentionDeduction": 10,
        "netPpcValue": "85.00",
        "vatAmount": "4.25",
        "otherPayment": 2.5,
        "netCertifiedAmountVat": "89.25",
        "actualPaymentReceived": 80,
        "datePaymentReceived": " 2025-12-10 ",
        "comments": " ok ",
      };

      final p = PPC.fromJson(json);

      // Numeric conversions (to double)
      expect(p.ppc, 1.0);
      expect(p.grossPPCValue, 100.0);
      expect(p.cumulativePPCValue, 150.0);
      expect(p.workDonePercent, 60.0);
      expect(p.cumulativeWorkDonePercent, 80.0);
      expect(p.netPPCValue, 90.0);
      expect(p.grossPpcValue, 100.0);
      expect(p.cumulativePpcValue, 150.0);
      expect(p.workDone, 60.0);
      expect(p.cumulativeWorkDone, 80.0);
      expect(p.advancePaymentDeduction, 5.0);
      expect(p.retentionDeduction, 10.0);
      expect(p.netPpcValue, 85.0);
      expect(p.vatAmount, 4.25);
      expect(p.otherPayment, 2.5);
      expect(p.netCertifiedAmountVat, 89.25);
      expect(p.actualPaymentReceived, 80.0);

      // String sanitization (trimmed)
      expect(p.contractorId, "C-1");
      expect(p.ppcNo, "PPC-001");
      expect(p.ppcDate, "2025-12-01");
      expect(p.datePaymentReceived, "2025-12-10");
      expect(p.comments, "ok");
    });

    test("toJsond outputs values and empty strings for null string fields", () {
      final p = PPC(
        ppc: 1,
        netPPCValue: 90,
        contractorId: null, // should become ''
        ppcNo: null, // should become ''
        ppcDate: null, // should become ''
        datePaymentReceived: null, // should become ''
        comments: null, // should become ''
      );

      final j = p.toJsond();
      expect(j["ppc"], 1.0);
      expect(j["netPPCValue"], 90.0);
      expect(j["contractorId"], "");
      expect(j["ppcNo"], "");
      expect(j["ppcDate"], "");
      expect(j["datePaymentReceived"], "");
      expect(j["comments"], "");
    });

    test("toJsond preserves numeric nulls and includes all keys", () {
      final p = PPC();
      final j = p.toJsond();

      expect(j.keys.contains("ppc"), isTrue);
      expect(j.keys.contains("grossPPCValue"), isTrue);
      expect(j.keys.contains("cumulativePPCValue"), isTrue);
      expect(j.keys.contains("workDonePercent"), isTrue);
      expect(j.keys.contains("cumulativeWorkDonePercent"), isTrue);
      expect(j.keys.contains("netPPCValue"), isTrue);
      expect(j.keys.contains("contractorId"), isTrue);
      expect(j.keys.contains("ppcNo"), isTrue);
      expect(j.keys.contains("ppcDate"), isTrue);
      expect(j.keys.contains("grossPpcValue"), isTrue);
      expect(j.keys.contains("cumulativePpcValue"), isTrue);
      expect(j.keys.contains("workDone"), isTrue);
      expect(j.keys.contains("cumulativeWorkDone"), isTrue);
      expect(j.keys.contains("advancePaymentDeduction"), isTrue);
      expect(j.keys.contains("retentionDeduction"), isTrue);
      expect(j.keys.contains("netPpcValue"), isTrue);
      expect(j.keys.contains("vatAmount"), isTrue);
      expect(j.keys.contains("otherPayment"), isTrue);
      expect(j.keys.contains("netCertifiedAmountVat"), isTrue);
      expect(j.keys.contains("actualPaymentReceived"), isTrue);
      expect(j.keys.contains("datePaymentReceived"), isTrue);
      expect(j.keys.contains("comments"), isTrue);

      expect(j["contractorId"], "");
      expect(j["ppcNo"], "");
      expect(j["ppcDate"], "");
      expect(j["datePaymentReceived"], "");
      expect(j["comments"], "");
      expect(j["ppc"], isNull);
      expect(j["netPPCValue"], isNull);
      expect(j["workDone"], isNull);
    });
  });
}
