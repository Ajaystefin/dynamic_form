class AgingSummary {
  AgingSummary({
    required this.zeroToSevenDays,
    required this.eightToFifteenDays,
    required this.sixteenToThirtyDays,
    required this.aboveThirtyDays,
  });

  factory AgingSummary.fromJson(Map<String, dynamic> json) {
    return AgingSummary(
      zeroToSevenDays: json["0_7_days"] ?? 0,
      eightToFifteenDays: json["8_15_days"] ?? 0,
      sixteenToThirtyDays: json["16_30_days"] ?? 0,
      aboveThirtyDays: json["abv_30_days"] ?? 0,
    );
  }
  final double zeroToSevenDays;
  final double eightToFifteenDays;
  final double sixteenToThirtyDays;
  final double aboveThirtyDays;

  Map<String, dynamic> toJson() {
    return {
      "0_7_days": zeroToSevenDays,
      "8_15_days": eightToFifteenDays,
      "16_30_days": sixteenToThirtyDays,
      "abv_30_days": aboveThirtyDays,
      // 'total': total,
    };
  }
}
