import "package:flutter/foundation.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";

/// Service responsible for fetching and caching the currency list and
/// exchange rates.
///
/// Rates don't change within a day, so the full list is fetched once per
/// session and reused for every subsequent lookup. Cache is cleared on
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

  List<Reference>? _currencies;
  Map<String, num>? _rates;
  Future<CurrencyListResult>? _inFlight;

  Future<CurrencyListResult> _fetchOrCached() async {
    if (_currencies != null && _rates != null) {
      return (currencies: _currencies!, rates: _rates!);
    }
    return _inFlight ??= _fetch();
  }

  Future<CurrencyListResult> _fetch() async {
    try {
      final result = await _repo.getCurrencyList();
      _currencies = _aedFirst(result.currencies);
      _rates = result.rates;
      return (currencies: _currencies!, rates: _rates!);
    } finally {
      _inFlight = null;
    }
  }

  /// Orders the currency list so AED comes first, preserving the API order
  /// for everything else.
  List<Reference> _aedFirst(List<Reference> currencies) {
    return List<Reference>.of(currencies)
      ..sort((a, b) {
        final bool aIsAed =
            (a.name ?? "").toUpperCase() == ServerConstants.aedCurrency;
        final bool bIsAed =
            (b.name ?? "").toUpperCase() == ServerConstants.aedCurrency;
        return (bIsAed ? 1 : 0) - (aIsAed ? 1 : 0);
      });
  }

  /// Returns the cached currency list with AED first, fetching it from the
  /// API on the first call of the session and reusing it afterwards.
  ///
  /// Returns a copy so callers can sort or filter it without corrupting the
  /// cached list every other caller shares.
  Future<List<Reference>> getCurrencies() async =>
      List<Reference>.of((await _fetchOrCached()).currencies);

  /// Returns the cached exchange rate table, fetching it from the API on
  /// the first call of the session and reusing it afterwards.
  Future<Map<String, num>> getRates() async => (await _fetchOrCached()).rates;

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

  /// Clears the cached currency list and rate table, forcing the next
  /// lookup to re-fetch.
  void clearCache() {
    _currencies = null;
    _rates = null;
    _inFlight = null;
  }
}
