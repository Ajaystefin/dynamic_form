class FeeStructure {
  final String id;
  bool isNew;
  String feeType;
  double? amount;
  String comments;
  String? appRefNo;
  int? rimNo;

  FeeStructure({
    required this.id,
    this.isNew = false,
    required this.feeType,
    this.amount = 0.0,
    this.comments = '',
    this.appRefNo,
    this.rimNo,
  });

  factory FeeStructure.fromJson(Map<String, dynamic> json) {
    final double rawAmt =
        double.tryParse(json['amountOrPercentage']?.toString() ?? '') ?? 0.0;
    return FeeStructure(
      id: json['id'] as String? ?? '',
      isNew: json['isNew'] as bool? ?? false,
      feeType: json['feeType'] as String? ?? '',
      amount: rawAmt,
      comments: json['feeComment'] as String? ?? '',
      rimNo: json['rimNo'] is int ? json['rimNo'] as int : null,
      appRefNo: json['appRefNo'] is String && json['appRefNo'].isNotEmpty
          ? json['appRefNo'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final String amountOrPercentage = (amount ?? 0.0).toString();
    return {
      'feeType': feeType,
      'amountOrPercentage': amountOrPercentage,
      'feeComment': comments,
      'rimNo': rimNo,
      'appRefNo': appRefNo,
    };
  }
}
