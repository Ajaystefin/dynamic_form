/// Represents a fee structure associated with an application.
class FeeStructure {
  /// Creates a [FeeStructure] instance.
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

  /// Creates a [FeeStructure] instance from a JSON map.
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

  /// Unique identifier of the fee structure.
  final String id;

  /// Indicates whether the fee structure was newly added.
  bool isNew;

  /// Fee type.
  String feeType;

  /// Fee amount or percentage value.
  double? amount;

  /// Comments associated with the fee.
  String comments;

  /// Application reference number.
  String? appRefNo;

  /// Customer RIM number.
  int? rimNo;

  /// Raw amount or percentage value.
  String? amountRaw;

  /// Fee structure identifier.
  int? feeStructureId;

  /// Converts this [FeeStructure] instance to a JSON map.
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
