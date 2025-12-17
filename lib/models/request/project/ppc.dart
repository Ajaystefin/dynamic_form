class PPC {
  final int? ppc;
  final int? ppcDate;
  final double? grossPPCValue;
  final double? cumulativePPCValue;
  final double? workDonePercent;
  final double? cumulativeWorkDonePercent;
  final double? advancePaymentDeduction;
  final double? retentionDeduction;
  final double? netPPCValue;
  final double? vatAmount;

  PPC({
    this.ppc,
    this.ppcDate,
    this.grossPPCValue,
    this.cumulativePPCValue,
    this.workDonePercent,
    this.cumulativeWorkDonePercent,
    this.advancePaymentDeduction,
    this.retentionDeduction,
    this.netPPCValue,
    this.vatAmount,
  });

  factory PPC.fromJson(Map<String, dynamic> json) {
    return PPC(
      ppc: json['PPC'],
      ppcDate: int.tryParse(json['PPCDate']),
      grossPPCValue: json['GrossPPCValue'].toDouble(),
      cumulativePPCValue: json['CumulativePPCValue'].toDouble(),
      workDonePercent: json['%WorkDone'].toDouble(),
      cumulativeWorkDonePercent: json['%CumulativeWorkDone'].toDouble(),
      advancePaymentDeduction: json['AdvancePaymentDeduction'].toDouble(),
      retentionDeduction: json['RetentionDeduction'].toDouble(),
      netPPCValue: json['NetPPCValue'].toDouble(),
      vatAmount: json['VATAmount'].toDouble(),
    );
  }
}
