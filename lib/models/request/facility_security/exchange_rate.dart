class CurrencyRates {
  const CurrencyRates({required this.rates});

  factory CurrencyRates.fromJson(Map<String, dynamic> json) {
    final Map<String, num> parsedRates = {};
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
  final Map<String, num> rates;

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(rates);
}
