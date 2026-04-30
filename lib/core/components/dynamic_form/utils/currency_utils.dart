import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";

/// Utility class for currency-related operations
///
/// Provides formatting, parsing, and helper methods for currency fields
class CurrencyUtils {
  // Private constructor to prevent instantiation
  CurrencyUtils._();

  /// Number formatter for currency display (e.g., 1,234)
  static final NumberFormat _currencyFormatter = NumberFormat("#,###");

  /// Format a numeric value as currency string with thousand separators
  ///
  /// Example: 1234.56 -> "1,234"
  static String formatCurrency(double value) {
    return _currencyFormatter.format(value.toInt());
  }

  /// Parse a currency string to double, removing thousand separators
  ///
  /// Example: "1,234" -> 1234.0
  static double? parseCurrency(String value) {
    final cleaned = value.replaceAll(",", "");
    return double.tryParse(cleaned);
  }

  /// Check if the given currency code is AED
  static bool isAedCurrency(String? currency) {
    return currency == ServerConstants.aedCurrency;
  }

  /// Create a currency data map in the standard format
  ///
  /// Returns: {fromCurrency: String, fromVal: double, aedEquivalent: double}
  static Map<String, dynamic> createCurrencyMap({
    required String currency,
    required double amount,
    required double aedEquivalent,
  }) {
    return {
      "fromCurrency": currency,
      "fromVal": amount,
      "aedEquivalent": aedEquivalent,
    };
  }

  /// Calculate AED equivalent based on currency and exchange rate
  ///
  /// If currency is AED, returns the amount as-is
  /// Otherwise, multiplies amount by exchange rate
  static double calculateAedEquivalent({
    required String currency,
    required double amount,
    required double exchangeRate,
  }) {
    return isAedCurrency(currency) ? amount : amount * exchangeRate;
  }

  /// Extract currency data from a document map
  ///
  /// Supports two formats:
  /// 1. New format: {fromCurrency: "USD", fromVal: 100, aedEquivalent: 367}
  /// 2. Old format: {"USD": 100}
  ///
  /// Returns null if no valid data found
  static CurrencyFieldData? extractFromDocument(
    Map<String, dynamic>? document,
    String fieldKey,
  ) {
    if (document == null) return null;

    final storedValue = document[fieldKey];
    if (storedValue is! Map<String, dynamic> || storedValue.isEmpty) {
      return null;
    }

    // New API format: {fromCurrency, fromVal, aedEquivalent}
    if (storedValue.containsKey("fromCurrency")) {
      return CurrencyFieldData(
        currency: storedValue["fromCurrency"]?.toString(),
        amount: _parseNumericValue(storedValue["fromVal"]),
        aedEquivalent: _parseNumericValue(storedValue["aedEquivalent"]),
      );
    }

    // Old format: {currency: amount}
    final entry = storedValue.entries.first;
    return CurrencyFieldData(
      currency: entry.key,
      amount: _parseNumericValue(entry.value),
      aedEquivalent: null,
    );
  }

  /// Parse a value that could be num or String to double
  static double? _parseNumericValue(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

/// Data class to hold currency field values
class CurrencyFieldData {
  const CurrencyFieldData({
    this.currency,
    this.amount,
    this.aedEquivalent,
  });
  final String? currency;
  final double? amount;
  final double? aedEquivalent;

  /// Get formatted amount string
  String get formattedAmount {
    if (amount == null) return "";
    return CurrencyUtils.formatCurrency(amount!);
  }

  /// Get formatted AED equivalent string
  String get formattedAedEquivalent {
    if (aedEquivalent == null) return "";
    return CurrencyUtils.formatCurrency(aedEquivalent!);
  }
}
