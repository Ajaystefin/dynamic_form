import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";

class PPC {
  PPC({
    this.ppcId,
    this.ppc,
    this.grossPPCValue,
    this.cumulativePPCValue,
    this.workDonePercent,
    this.cumulativeWorkDonePercent,
    this.netPPCValue,
    this.contractorId,
    this.ppcNo,
    this.ppcDate,
    this.grossPpcValue,
    this.cumulativePpcValue,
    this.workDone,
    this.cumulativeWorkDone,
    this.advancePaymentDeduction,
    this.retentionDeduction,
    this.netPpcValue,
    this.vatAmount,
    this.otherPayment,
    this.netCertifiedAmountVat,
    this.actualPaymentReceived,
    this.datePaymentReceived,
    this.comments,
  });

  factory PPC.fromJson(Map<String, dynamic> json) {
    return PPC(
      // Numerics -> double?
      ppcId: json["ppcId"],
      ppc: ProjectContractNumericHelper.toDoubleOrNull(json["ppc"]),
      grossPPCValue:
          ProjectContractNumericHelper.toDoubleOrNull(json["grossPPCValue"]),
      cumulativePPCValue: ProjectContractNumericHelper.toDoubleOrNull(
        json["cumulativePPCValue"],
      ),
      workDonePercent:
          ProjectContractNumericHelper.toDoubleOrNull(json["workDonePercent"]),
      cumulativeWorkDonePercent: ProjectContractNumericHelper.toDoubleOrNull(
        json["cumulativeWorkDonePercent"],
      ),
      netPPCValue:
          ProjectContractNumericHelper.toDoubleOrNull(json["netPPCValue"]),

      // Strings: sanitize
      contractorId:
          ProjectContractNumericHelper.sanitizeString(json["contractorId"]),
      ppcNo: ProjectContractNumericHelper.sanitizeString(json["ppcNo"]),
      ppcDate: ProjectContractNumericHelper.sanitizeString(json["ppcDate"]),

      // Remaining numerics -> double?
      grossPpcValue:
          ProjectContractNumericHelper.toDoubleOrNull(json["grossPpcValue"]),
      cumulativePpcValue: ProjectContractNumericHelper.toDoubleOrNull(
        json["cumulativePpcValue"],
      ),
      workDone: ProjectContractNumericHelper.toDoubleOrNull(json["workDone"]),
      cumulativeWorkDone: ProjectContractNumericHelper.toDoubleOrNull(
        json["cumulativeWorkDone"],
      ),
      advancePaymentDeduction: ProjectContractNumericHelper.toDoubleOrNull(
        json["advancePaymentDeduction"],
      ),
      retentionDeduction: ProjectContractNumericHelper.toDoubleOrNull(
        json["retentionDeduction"],
      ),
      netPpcValue:
          ProjectContractNumericHelper.toDoubleOrNull(json["netPpcValue"]),
      vatAmount: ProjectContractNumericHelper.toDoubleOrNull(json["vatAmount"]),
      otherPayment:
          ProjectContractNumericHelper.toDoubleOrNull(json["otherPayment"]),
      netCertifiedAmountVat: ProjectContractNumericHelper.toDoubleOrNull(
        json["netCertifiedAmountVat"],
      ),
      actualPaymentReceived: ProjectContractNumericHelper.toDoubleOrNull(
        json["actualPaymentReceived"],
      ),

      // Strings: sanitize
      datePaymentReceived: ProjectContractNumericHelper.sanitizeString(
        json["datePaymentReceived"],
      ),
      comments: ProjectContractNumericHelper.sanitizeString(json["comments"]),
    );
  }
  // Numerics: all as double?
  int? ppcId;
  double? ppc;
  double? grossPPCValue;
  double? cumulativePPCValue;
  double? workDonePercent;
  double? cumulativeWorkDonePercent;

  double? netPPCValue;

  // Strings
  String? contractorId;
  String? ppcNo;
  String? ppcDate;

  // Remaining numerics, converted to double?
  double? grossPpcValue;
  double? cumulativePpcValue;
  double? workDone;
  double? cumulativeWorkDone;
  double? advancePaymentDeduction;
  double? retentionDeduction;
  double? netPpcValue;
  double? vatAmount;
  double? otherPayment;
  double? netCertifiedAmountVat;
  double? actualPaymentReceived;

  // Strings
  String? datePaymentReceived;
  String? comments;

// In model.dart, inside class PPC { ... }
// ADD these getters; do NOT remove existing fields or fromJson/toJson

// Display PPC# consistently (prefer ppcNo, then ppcId, then numeric ppc)
  String get ppcDisplayNo => (ppcNo?.toString().trim().isNotEmpty == true)
      ? ppcNo!.toString()
      : (ppcId != null ? ppcId!.toString() : (ppc?.toString() ?? ""));

// Resolve synonymous numeric fields
  double? get grossPpcResolved => grossPpcValue ?? grossPPCValue;
  double? get cumulativePpcResolved => cumulativePpcValue ?? cumulativePPCValue;
  double? get workDonePercentResolved => workDone ?? workDonePercent;
  double? get cumulativeWorkDonePercentResolved =>
      cumulativeWorkDone ?? cumulativeWorkDonePercent;
  double? get netPpcResolved => netPpcValue ?? netPPCValue;

  Map<String, dynamic> toJson() {
    // Pick first non-null among synonymous fields
    final ppcNoResolved = ppcNo ?? (ppc?.toString()) ?? ppcId ?? "";
    final ppcDateResolved = ppcDate ?? "";

    // Numerics: prefer lowerCamel fields; fallback to legacy ones
    final grossPpcValueResolved = grossPpcValue ?? grossPPCValue;
    final cumulativePpcValueResolved = cumulativePpcValue ?? cumulativePPCValue;
    final workDoneResolved = workDone ?? workDonePercent;
    final cumulativeWorkDoneResolved =
        cumulativeWorkDone ?? cumulativeWorkDonePercent;
    final netPpcValueResolved = netPpcValue ?? netPPCValue;

    return {
      // 'ppcId': ppcNoResolved,
      "ppcNo": ppcNoResolved,
      "ppcDate": ppcDateResolved,
      "grossPpcValue": grossPpcValueResolved,
      "cumulativePpcValue": cumulativePpcValueResolved,
      "workDone": workDoneResolved,
      "cumulativeWorkDone": cumulativeWorkDoneResolved,
      "advancePaymentDeduction": advancePaymentDeduction,
      "retentionDeduction": retentionDeduction,
      "netPpcValue": netPpcValueResolved,
      "vatAmount": vatAmount,
      "otherPayment": otherPayment,
      "netCertifiedAmountVat": netCertifiedAmountVat,
      "actualPaymentReceived": actualPaymentReceived,

      "datePaymentReceived": datePaymentReceived ?? "",
      "comments": comments ?? "",
      // If needed:
      // 'contractorId': contractorId ?? '',
    };
  }

  Map<String, dynamic> toJsond() {
    return {
      // Numerics (double or null)
      "ppc": ppc,
      "grossPPCValue": grossPPCValue,
      "cumulativePPCValue": cumulativePPCValue,
      "workDonePercent": workDonePercent,
      "cumulativeWorkDonePercent": cumulativeWorkDonePercent,
      "netPPCValue": netPPCValue,

      // Strings: never output 'null'
      "contractorId": contractorId ?? "",

      "ppcNo": ppcNo ?? "", //
      "ppcDate": ppcDate ?? "", //

      // Remaining numerics (double or null)
      "grossPpcValue": grossPpcValue, //
      "cumulativePpcValue": cumulativePpcValue, //
      "workDone": workDone ?? workDonePercent, //
      "cumulativeWorkDone": cumulativeWorkDone, //
      "advancePaymentDeduction": advancePaymentDeduction, //
      "retentionDeduction": retentionDeduction, //
      "netPpcValue": netPpcValue, //
      "vatAmount": vatAmount, //
      "otherPayment": otherPayment, //
      "netCertifiedAmountVat": netCertifiedAmountVat, //
      "actualPaymentReceived": actualPaymentReceived, //

      // Strings
      "datePaymentReceived": datePaymentReceived ?? "", //
      "comments": comments ?? "", //
    };
  }
}

// { "ppcDate":"04/03/2021",
//        "datePaymentReceived":"04/03/2021",
// "grossPpcValue":1,
// "cumulativePpcValue":5,
// "workDone":2.5,
// "cumulativeWorkDone":5,
// "advancePaymentDeduction":4,
// "retentionDeduction":4,
// "netPpcValue":5,
// "vatAmount":5,
// "otherPayment":4,
// "netCertifiedAmountVat":4,
// "actualPaymentReceived":4,
// "comments":"ppc 202512CONT000012"}
