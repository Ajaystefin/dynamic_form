/// Represents a collection of currency exchange rates.
class CurrencyRates {
  /// Creates a [CurrencyRates] instance.
  const CurrencyRates({required this.rates});

  /// Creates a [CurrencyRates] instance from a JSON map.
  factory CurrencyRates.fromJson(Map<String, dynamic> json) {
    final parsedRates = <String, num>{};
  
    json.forEach((currencyCode, rateValue) {
      if (rateValue is num) {
        parsedRates[currencyCode] = rateValue;
      } else if (rateValue is String) {
        final parsed = num.tryParse(rateValue);
        if (parsed != null) {
          parsedRates[currencyCode] = parsed;
        }
      }
    });

    return CurrencyRates(rates: parsedRates);
  }

  /// Map of currency codes to their exchange rates.
  final Map<String, num> rates;

  /// Converts this object to a JSON map.
  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from(rates);
  }
}
