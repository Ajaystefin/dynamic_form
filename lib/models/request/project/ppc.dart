import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";

/// Represents a Progress Payment Certificate (PPC) record.
class PPC {
  /// Creates a [PPC] instance.
  PPC({
    this.ppcId,
    this.ppcNo,
    this.ppcDate,
    this.grossValue,
    this.cumulativeValue,
    this.workDone,
    this.cumulativeWorkDone,
    this.advancePaymentDeduction,
    this.retentionDeduction,
    this.netValue,
    this.vatAmount,
    this.otherPayment,
    this.totalWithVat,
    this.actualPaymentReceived,
    this.datePaymentReceived,
    this.comments,
  });

  /// Creates a [PPC] instance from a JSON map.
  factory PPC.fromJson(Map<String, dynamic> json) {
    return PPC(
      ppcId: json["ppcId"],

      //FIXED (string safe)
      ppcNo: json["ppcNo"]?.toString(),

      ppcDate: json["ppcDate"]?.toString(),

      //Correct mapping from API
      grossValue:
          ProjectContractNumericHelper.toDoubleOrNull(json["grossPpcValue"]),
      cumulativeValue: ProjectContractNumericHelper.toDoubleOrNull(
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

      netValue:
          ProjectContractNumericHelper.toDoubleOrNull(json["netPpcValue"]),

      vatAmount: ProjectContractNumericHelper.toDoubleOrNull(json["vatAmount"]),
      otherPayment:
          ProjectContractNumericHelper.toDoubleOrNull(json["otherPayment"]),

      totalWithVat: ProjectContractNumericHelper.toDoubleOrNull(
        json["netCertifiedAmountVat"],
      ),

      actualPaymentReceived: ProjectContractNumericHelper.toDoubleOrNull(
        json["actualPaymentReceived"],
      ),

      datePaymentReceived: json["datePaymentReceived"]?.toString(),
      comments: json["comments"]?.toString(),
    );
  }

  /// ppcId
  int? ppcId;

  /// ppcNo
  String? ppcNo;

  /// ppcDate
  String? ppcDate;

  /// grossValue
  double? grossValue;

  /// cumulativeValue
  double? cumulativeValue;

  /// workDone
  double? workDone;

  /// cumulativeWorkDone
  double? cumulativeWorkDone;

  /// advancePaymentDeduction
  double? advancePaymentDeduction;

  /// retentionDeduction
  double? retentionDeduction;

  /// netValue
  double? netValue;

  /// vatAmount
  double? vatAmount;

  /// otherPayment
  double? otherPayment;

  /// totalWithVat
  double? totalWithVat;

  /// actualPaymentReceived
  double? actualPaymentReceived;

  /// datePaymentReceived
  String? datePaymentReceived;

  /// comments
  String? comments;

  /// Returns the PPC number for display purposes.
  String get ppcDisplayNo =>
      (ppcNo?.trim().isNotEmpty ?? false) ? ppcNo! : (ppcId?.toString() ?? "");

  /// Converts this [PPC] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "ppcId": ppcId,
      "ppcNo": ppcNo ?? "",
      "ppcDate": ppcDate ?? "",
      "grossPpcValue": grossValue,
      "cumulativePpcValue": cumulativeValue,
      "workDone": workDone,
      "cumulativeWorkDone": cumulativeWorkDone,
      "advancePaymentDeduction": advancePaymentDeduction,
      "retentionDeduction": retentionDeduction,
      "netPpcValue": netValue,
      "vatAmount": vatAmount,
      "otherPayment": otherPayment,
      "netCertifiedAmountVat": totalWithVat,
      "actualPaymentReceived": actualPaymentReceived,
      "datePaymentReceived": datePaymentReceived ?? "",
      "comments": comments ?? "",
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

// return {
//       // 'ppcId': ppcNoResolved,
//       "ppcNo": ppcNoResolved, // ppcid & null
//       "ppcDate": ppcDateResolved, //ppcDate
//       "grossPpcValue": grossPpcValueResolved, //grossvalue
//       "cumulativePpcValue": cumulativePpcValueResolved, //cumulativeValue
//       "workDone": workDoneResolved, // workDone d
//       "cumulativeWorkDone": cumulativeWorkDoneResolved, //cumulativeWorkDone d
//       "advancePaymentDeduction":
//           advancePaymentDeduction, //advancePaymentDeduction
//       "retentionDeduction": retentionDeduction, //retentionDeduction
//       "netPpcValue": netPpcValueResolved, //netvalue
//       "vatAmount": vatAmount, //vatAmount
//       "otherPayment": otherPayment, //otherPayment
//       "netCertifiedAmountVat": totalWithVat, //totalWithVat
//       "actualPaymentReceived": actualPaymentReceived, //actualPaymentReceived

//       "datePaymentReceived": datePaymentReceived ?? "",
//       "comments": comments ?? "",
//       // If needed:
//       // 'contractorId': contractorId ?? '',
//     };
//   }
