import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/facility_security/exchange_rate.dart";

void main() {
  group("CurrencyRates Tests", () {
    test("Constructor assigns values correctly", () {
      final rates = {"USD": 1.0, "EUR": 0.85};
      final currencyRates = CurrencyRates(rates: rates);
      expect(currencyRates.rates.length, 2);
      expect(currencyRates.rates["USD"], 1.0);
      expect(currencyRates.rates["EUR"], 0.85);
    });

    test("fromJson parses numeric values correctly", () {
      final json = {"USD": 1.0, "EUR": 0.85};
      final currencyRates = CurrencyRates.fromJson(json);
      expect(currencyRates.rates["USD"], 1.0);
      expect(currencyRates.rates["EUR"], 0.85);
    });

    test("fromJson parses string values that can be converted to num", () {
      final json = {"USD": "1.0", "EUR": "0.85"};
      final currencyRates = CurrencyRates.fromJson(json);
      expect(currencyRates.rates["USD"], 1.0);
      expect(currencyRates.rates["EUR"], 0.85);
    });

    test("fromJson ignores invalid string values", () {
      final json = {"USD": "abc", "EUR": "0.85"};
      final currencyRates = CurrencyRates.fromJson(json);
      expect(currencyRates.rates.containsKey("USD"), false);
      expect(currencyRates.rates["EUR"], 0.85);
    });

    test("fromJson handles empty map", () {
      final json = <String, dynamic>{};
      final currencyRates = CurrencyRates.fromJson(json);
      expect(currencyRates.rates, isEmpty);
    });

    test("toJson returns correct map", () {
      final rates = {"USD": 1.0, "EUR": 0.85};
      final currencyRates = CurrencyRates(rates: rates);
      final json = currencyRates.toJson();
      expect(json["USD"], 1.0);
      expect(json["EUR"], 0.85);
    });
  });
}
