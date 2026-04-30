class FeeStructure {
  FeeStructure({
    required this.id,
    required this.feeType,
    this.isNew = false,
    this.amountRaw,
    this.amount = 0.0,
    this.comments = "",
    this.appRefNo,
    this.rimNo,
    this.feeStructureId,
  });

  factory FeeStructure.fromJson(Map<String, dynamic> json) {
    // Read server id from either int or string
    final dynamic fsIdDyn = json["feeStructureId"];
    final int? fsId =
        (fsIdDyn is int) ? fsIdDyn : int.tryParse(fsIdDyn?.toString() ?? "");

    final String raw = (json["amountOrPercentage"]?.toString() ?? "").trim();
    return FeeStructure(
      id: (fsId != null)
          ? fsId.toString()
          : (json["id"] as String? ??
              DateTime.now().microsecondsSinceEpoch.toString()),
      feeStructureId: fsId,
      isNew: json["isNew"] as bool? ?? false,
      feeType: json["feeType"] as String? ?? "",
      amount: double.tryParse(raw) ?? 0.0,
      amountRaw: raw,
      comments: json["feeComment"] as String? ?? "",
      rimNo: json["rimNo"] is int ? json["rimNo"] as int : null,
      appRefNo: json["appRefNo"] is String && json["appRefNo"].isNotEmpty
          ? json["appRefNo"] as String
          : null,
    );
  }
  final String id;
  bool isNew;
  String feeType;
  double? amount;
  String comments;
  String? appRefNo;
  int? rimNo;
  String? amountRaw;
  int? feeStructureId;

  Map<String, dynamic> toJson() {
    // Prefer the exact typed value; normalize N/A to a safe numeric
    final String raw = (amountRaw ?? "").trim();
    final String amountOrPercentage =
        raw.isEmpty ? "0.00" : (raw.toUpperCase() == "N/A" ? "0.00" : raw); //

    return {
      "feeStructureId": feeStructureId,
      "feeType": feeType,
      "amountOrPercentage": amountOrPercentage,
      "feeComment": comments,
      "rimNo": rimNo,
      "appRefNo": appRefNo,
    };
  }
}
