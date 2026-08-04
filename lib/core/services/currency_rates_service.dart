import "package:flutter/foundation.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";

/// Service responsible for fetching and caching currency exchange rates.
///
/// Rates don't change within a day, so the full rate table is fetched once
/// per session and reused for every subsequent lookup. Cache is cleared on
/// logout (see `AuthRepository.clearCacheAndStopSession`).
class CurrencyRatesService {
  /// Returns the singleton instance.
  factory CurrencyRatesService() => _instance;
  CurrencyRatesService._internal();
  static CurrencyRatesService _instance = CurrencyRatesService._internal();

  /// Overrides the singleton instance for testing purposes.
  @visibleForTesting
  static set overrideInstance(CurrencyRatesService v) => _instance = v;

  FacilitySecurityRepository? _repository;

  /// Sets a custom repository instance.
  set repository(FacilitySecurityRepository? value) => _repository = value;

  /// Returns the configured repository or the default singleton instance.
  FacilitySecurityRepository get _repo =>
      _repository ?? FacilitySecurityRepository.instance;

  Map<String, num>? _rates;
  Future<Map<String, num>>? _inFlight;

  /// Returns the cached exchange rate table, fetching it from the API on
  /// the first call of the session and reusing it afterwards.
  Future<Map<String, num>> getRates() async {
    if (_rates != null) {
      return _rates!;
    }
    return _inFlight ??= _fetch();
  }

  Future<Map<String, num>> _fetch() async {
    try {
      final result = await _repo.getAllCurrencyRates();
      _rates = result.rates;
      return _rates!;
    } finally {
      _inFlight = null;
    }
  }

  /// Returns the AED-per-unit exchange rate for [currencyCode], or `null`
  /// if the code has no rate or is not supplied.
  Future<num?> getRate(String? currencyCode) async {
    if (currencyCode == null) {
      return null;
    }
    final rates = await getRates();
    return rates[currencyCode];
  }

  /// Returns the AED-per-unit exchange rate for [currency], or `null`
  /// if the currency has no rate or is not supplied.
  Future<num?> getRateFor(Reference? currency) => getRate(currency?.name);

  /// Clears the cached rate table, forcing the next lookup to re-fetch.
  void clearCache() {
    _rates = null;
    _inFlight = null;
  }
}
