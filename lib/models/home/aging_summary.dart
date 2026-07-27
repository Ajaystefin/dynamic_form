/// Represents aging summary data across different time buckets.
class AgingSummary {
  /// Creates an [AgingSummary] instance.
  const AgingSummary({
    required this.zeroToSevenDays,
    required this.eightToFifteenDays,
    required this.sixteenToThirtyDays,
    required this.aboveThirtyDays,
  });

  /// Creates an [AgingSummary] instance from a JSON map.
  factory AgingSummary.fromJson(Map<String, dynamic> json) {
    return AgingSummary(
      zeroToSevenDays: json["0_7_days"] ?? 0,
      eightToFifteenDays: json["8_15_days"] ?? 0,
      sixteenToThirtyDays: json["16_30_days"] ?? 0,
      aboveThirtyDays: json["abv_30_days"] ?? 0,
    );
  }

  /// Amount for 0–7 days.
  final double zeroToSevenDays;

  /// Amount for 8–15 days.
  final double eightToFifteenDays;

  /// Amount for 16–30 days.
  final double sixteenToThirtyDays;

  /// Amount for above 30 days.
  final double aboveThirtyDays;

  /// Converts this object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "0_7_days": zeroToSevenDays,
      "8_15_days": eightToFifteenDays,
      "16_30_days": sixteenToThirtyDays,
      "abv_30_days": aboveThirtyDays,
    };
  }
}
