// ---- Format helpers ---
import "package:decimal/decimal.dart";
import "package:decimal/intl.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";

// You can put these in a utils file, e.g., date_validation_util.dart
// typedef WarnFn = void Function(String messageKeyTranslated);

class ProjectContractNumericHelper {
  // Test hook: by default uses AlertManager, but can be overridden in tests.
  // @visibleForTesting
  // static WarnFn warn = (msg) => AlertManager().showWarningToast(msg);

  static String showStr(String? s) => s ?? "";

  static InputDecoration dec(String label) => InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      );

  /// Returns '' if value is null or literal string 'null' (case-insensitive).
  static String sanitizeString(dynamic value) {
    if (value == null) return "";
    final s = value.toString().trim();
    return s.toLowerCase() == "null" ? "" : s;
  }

  /// Safely converts dynamic (num or string) to double?
  static double? toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final v = value.trim();
      if (v.isEmpty || v.toLowerCase() == "null") return null;
      final cleaned = v.replaceAll(",", ""); // remove grouping commas
      return double.tryParse(cleaned);
    }
    return null;
  }

  /// Format numbers with up to 6 decimals (per spec: Numeric / 21, 6 decimals)

  /// Format numbers with up to 6 decimals. Return '0' when value is null.
  static String fmt6(double? value) {
    if (value == null) return "0"; // <-- changed
    final f = NumberFormat("#,##0.######");
    return f.format(value);
  }

  /// Format numbers with up to 6 decimals. Return '0' when value is null.
  static String fmt4(double? value) {
    if (value == null) return "0"; // <-- changed
    final f = NumberFormat("#,##0.####");
    return f.format(value);
  }

  /// Format percentage with up to 2 decimals. Return '0' when value is null.
  static String fmtPercent(double? value) {
    if (value == null) return "0"; // <-- changed
    final f = NumberFormat("##0.##");
    return f.format(value);
  }

  /// Parse and format dates as DD/MM/YYYY
  static String sanitizeDate(dynamic value) {
    final raw = sanitizeString(value);
    if (raw.isEmpty) return "";
    try {
      // Try ISO or common formats first
      final dt = DateTime.parse(raw);
      return DateFormat("dd/MM/yyyy").format(dt);
    } catch (_) {
      // If already in DD/MM/YYYY, keep as-is
      final regex = RegExp(r"^\d{2}/\d{2}/\d{4}$");
      if (regex.hasMatch(raw)) return raw;
      // Fallback: return empty to avoid bad display
      return "";
    }
  }

  static String safeText(dynamic value) {
    final s = value?.toString().trim();
    return (s?.isNotEmpty ?? false)
        ? s!
        : ""; // <— replace with no `!` version below
  }

  static String safeTextLower(dynamic value) {
    if (value == null) return "";
    final s = value.toString().trim();
    return s.isEmpty || s.toLowerCase() == "null" ? "" : s;
  }

  /// Returns '' if value is null or the literal string 'null'
  /// (case-insensitive).
  static String sanitizeStringa(dynamic value) {
    if (value == null) return "";
    final s = value.toString().trim();
    return s.toLowerCase() == "null" ? "" : s;
  }

  /// Safely converts dynamic (num or string) to double?
  static double? toDoubleOrNulla(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final v = value.trim();
      if (v.isEmpty || v.toLowerCase() == "null") return 0;
      return double.tryParse(v);
    }
    return 0;
  }

  static double? ppcRowSyncParseValue(String? input) {
    if (input == null) return null;

    final cleaned = input.trim();

    if (cleaned.isEmpty) return null;

    // Remove commas or any grouping characters if needed
    final noCommas = cleaned.replaceAll(",", "");

    // Try parse safely
    return double.tryParse(noCommas);
  }

// Strict DD/MM/YYYY checker
  static bool isValidDdMmYyyy(String input) {
    try {
      DateFormat("dd/MM/yyyy").parseStrict(input);
      return true;
    } catch (_) {
      return false;
    }
  }

// Number formatter: 6 decimals, thousands separator, no currency symbol.
// final NumberFormat _fixed6 = NumberFormat("#,##0.${'0' * 6}");
// Returns "+1,234.000000", "-123.450000" or "NA" if ~0
  static String formatSignedOrNA(
    double? value, {
    int decimals = 6,
    double epsilon = 1e-6,
    bool trimTrailingZeros = false, // NEW
  }) {
    if (value == null) return "NA";
    if (value.abs() < epsilon) return "NA";

    final sign = value >= 0 ? "" : "-";
    final abs = value.abs();

    // If trimming is requested, use an optional-decimal pattern:
    // - integers: "#,##0"
    // - non-integers: "#,##0.######" (up to `decimals`, no trailing zeros)
    if (trimTrailingZeros) {
      final isInt = (abs - abs.floor()).abs() < epsilon;
      final pattern = isInt ? "#,##0" : "#,##0.${'#' * decimals}";
      final fmt = NumberFormat(pattern);
      return "$sign${fmt.format(abs)}";
    }

    // Default behavior (fixed decimals)
    final fmt = NumberFormat("#,##0.${'0' * decimals}");
    return "$sign${fmt.format(abs)}";
  }

// Computes variation (current AED - initial AED)
  static double? computeVariationAed({
    required double? initialAed,
    required double? currentAed,
  }) {
    if (initialAed == null || currentAed == null) return null;
    return currentAed - initialAed;
  }

  /// Normalize to date-only (UTC) to avoid time/dst affecting inDays.

  /// Signed calendar-day difference: expected - original.
  /// Returns null if either date is missing.
  static int? daysDiffSigned(DateTime? original, DateTime? expected) {
    DateTime dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

    if (original == null || expected == null) return null;
    final o = dateOnly(original);
    final e = dateOnly(expected);
    return e.difference(o).inDays;
  }

  /// Format variation string as "+N days", "-N days", or "NA" when zero/unknown.
  static String formatVariationDays(int? days) {
    if (days == null || days == 0) return "NA";
    final sign = days > 0 ? "" : "-";
    final abs = days.abs();
    final unit = abs == 1 ? "day" : "days";
    return "$sign$abs $unit";
  }

// --- NEW: Safe string formatter that adds grouping without using double ---
  static String formatAsThousandsPreservingDecimals(String raw) {
    if (raw.isEmpty) return raw;
    // Normalize: strip any existing grouping commas
    final parts = raw.replaceAll(",", "").split(".");
    var intPart = parts[0];
    final fracPart = parts.length > 1 ? parts[1] : "";

    // Add commas to integer part (thousands grouping)
    // Example: 1234567 -> 1,234,567
    final reg = RegExp(r"(\d)(?=(\d{3})+(?!\d))");
    intPart = intPart.replaceAllMapped(reg, (m) => "${m[1]},");

    // Preserve fractional part as-is (up to 6 digits per your input filter)
    return fracPart.isNotEmpty ? "$intPart.$fracPart" : intPart;
  }

// ---- Helper: format date as dd/MM/yyyy from int/String/DateTime/null ----
  static String fmtDateFromAny(dynamic raw) {
    if (raw == null) return "";
    try {
      DateTime? dt;

      // If already DateTime
      if (raw is DateTime) {
        dt = raw;
      }
      // If API returns int (e.g., yyyymmdd or epoch) -> rely on your utility
      else if (raw is int) {
        dt = DateTimeUtils.intToDateTime(raw);
      }
      // If API returns String
      else if (raw is String) {
        final s = raw.trim();
        if (s.isEmpty) return "";
        // If it's already formatted like dd/MM/yyyy, trust it
        final slashLike = RegExp(r"^\d{2}/\d{2}/\d{4}$");
        if (slashLike.hasMatch(s)) return s;

        // Try parse int-like strings (e.g., "20250107", "1736208000")
        final asInt = int.tryParse(s);
        if (asInt != null) {
          dt = DateTimeUtils.intToDateTime(asInt);
        } else {
          // Fallbacks: try common formats
          final candidates = [
            DateFormat("yyyy-MM-dd"),
            DateFormat("MM/dd/yyyy"),
            DateFormat("dd-MM-yyyy"),
          ];
          for (final f in candidates) {
            try {
              dt = f.parse(s);
              break;
            } catch (_) {}
          }
        }
      }

      if (dt == null) return "";
      return DateFormat("dd/MM/yyyy").format(dt);
    } catch (_) {
      return "";
    }
  }

  // ---- Helper: stringify number safely (keeps integers clean, decimals
  // intact) ----
  static String numToText(num? value) {
    if (value == null) return "";
    // Avoid trailing .0 for whole numbers
    if (value is int || (value is double && value == value.roundToDouble())) {
      return value.toString();
    }
    return value.toString();
  }

  // ... keep your existing code (sanitizeString, toDoubleOrNull, fmt6, fmt4,
  // etc.)

  /// Safely converts dynamic (num or string) to Decimal?
  /// - Accepts comma-grouped strings, returns null on invalid.
  static Decimal? toDecimalOrNull(dynamic value) {
    if (value == null) return null;
    if (value is Decimal) return value;
    if (value is num) return Decimal.parse(value.toString());
    if (value is String) {
      final v = value.trim();
      if (v.isEmpty || v.toLowerCase() == "null") return null;
      final cleaned = v.replaceAll(",", ""); // remove grouping commas
      // Decimal.parse throws if invalid; guard with try/catch
      try {
        return Decimal.parse(cleaned);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Format Decimal with up to 6 fraction digits (no trailing zeros removal
  /// here).
  /// Falls back to '0' when value is null. Uses your string grouping helper
  /// to avoid converting Decimal -> double.
  static String fmtDec6(Decimal? value) {
    if (value == null) return "0";
    // Keep full decimal string, but trim to max 6 fractional digits for UI spec
    // 21,6
    final raw = value.toString();
    final parts = raw.split(".");
    final intPart = parts[0];
    final frac = (parts.length > 1) ? parts[1] : "";
    final cappedFrac =
        frac.isEmpty ? "" : (frac.length <= 6 ? frac : frac.substring(0, 6));
    final composed = cappedFrac.isNotEmpty ? "$intPart.$cappedFrac" : intPart;
    return formatAsThousandsPreservingDecimals(composed);
  }

  /// Format percentage Decimal with up to 2 fraction digits (no trailing zeros
  /// removal).
  static String fmtPercentDec(Decimal? value) {
    if (value == null) return "0";
    final raw = value.toString();
    final parts = raw.split(".");
    final intPart = parts[0];
    final frac = (parts.length > 1) ? parts[1] : "";
    final cappedFrac =
        frac.isEmpty ? "" : (frac.length <= 2 ? frac : frac.substring(0, 2));
    return cappedFrac.isNotEmpty ? "$intPart.$cappedFrac" : intPart;
  }

  /// Variation using Decimal (current AED - initial AED)
  static Decimal? computeVariationAedDec({
    required Decimal? initialAed,
    required Decimal? currentAed,
  }) {
    if (initialAed == null || currentAed == null) return null;
    return currentAed - initialAed;
  }

  /// Convenience: clamp Decimal within [min, max].
  static Decimal clampDec(Decimal v, Decimal min, Decimal max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

  /// Convenience: to Decimal percent (value/contract * 100).
  // static Decimal? toPercentDec(Decimal? value, Decimal? contract) {
  //   if (value == null || contract == null) return null;
  //   if (contract == Decimal.zero) return Decimal.zero;
  //   return (value / contract) * Decimal.fromInt(100);
  // }

  ///
  /// NOTE: This does NOT change your existing data flow; you just call this
  /// before writing strings to model fields and in toJson.
  static String normalizeToDecimalString(
    String? raw, {
    int maxFrac = 6,
    bool clampNegativeToZero = false,
  }) {
    if (raw == null) return "";
    String s = raw.trim();
    if (s.isEmpty || s.toLowerCase() == "null") return "";

    // Remove grouping commas (UI input)
    s = s.replaceAll(",", "");

    // If it looks like a fraction "a/b", convert to Decimal
    if (s.contains("/")) {
      final parts = s.split("/");
      if (parts.length == 2) {
        try {
          final nume = Decimal.parse(parts[0].trim());
          final deno = Decimal.parse(parts[1].trim());
          if (deno == Decimal.zero) return ""; // invalid division
          final dec = nume / deno;
          // Now format as proper decimal string
          return formatDecimal(
            dec as Decimal,
            maxFrac: maxFrac,
            clampNegativeToZero: clampNegativeToZero,
          );
        } catch (_) {
          return "";
        }
      } else {
        return "";
      }
    }

    // Otherwise treat as decimal input.
    Decimal? dec;
    try {
      dec = Decimal.parse(s);
    } catch (_) {
      return "";
    }

    return formatDecimal(
      dec,
      maxFrac: maxFrac,
      clampNegativeToZero: clampNegativeToZero,
    );
  }

  /// Internal: format Decimal to string with up to [maxFrac] digits, enforcing
  /// 21,6.
  /// Never returns fraction format; always decimal string.
  /// Also clamps negatives to "0" if requested.
  static String formatDecimal(
    Decimal dec, {
    required int maxFrac,
    required bool clampNegativeToZero,
  }) {
    if (clampNegativeToZero && dec <= Decimal.zero) {
      return "0";
    }

    // Intl formatter for Decimal: always decimal output, never "a/b".
    final nf = NumberFormat.decimalPattern()
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = maxFrac;

    final formatted = DecimalFormatter(nf).format(dec);

    // Enforce "21 digits max before '.'" and "up to maxFrac after '.'"
    // We'll trim if needed (safeguard).
    final parts = formatted.replaceAll(",", "").split(".");
    final intPart = parts[0];
    final fracPart = parts.length > 1 ? parts[1] : "";

    final cappedInt =
        intPart.length > 21 ? intPart.substring(intPart.length - 21) : intPart;
    final cappedFrac =
        fracPart.length > maxFrac ? fracPart.substring(0, maxFrac) : fracPart;

    // Reapply grouping to the integer part (optional)
    final withGrouping = groupThousands(cappedInt);

    return cappedFrac.isNotEmpty ? "$withGrouping.$cappedFrac" : withGrouping;
  }

  /// Add thousands grouping to integer part without touching decimals.
  static String groupThousands(String intPart) {
    if (intPart.isEmpty) return intPart;

    // Simple US-locale grouping; if you need locale-aware, use NumberFormat on
    // integers.
    final buf = StringBuffer();
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      buf.write(intPart[i]);
      count++;
      if (count == 3 && i > 0) {
        buf.write(",");
        count = 0;
      }
    }
    return buf.toString().split("").reversed.join();
  }

  static int completedMonthsBetween(DateTime start, DateTime end) {
    if (end.isBefore(start)) return 0;

    int months = (end.year - start.year) * 12 + (end.month - start.month);

    // Count only fully completed months
    if (end.day < start.day) {
      months--;
    }

    return months < 0 ? 0 : months;
  }

  static DateFormat fmt = DateFormat("dd/MM/yyyy");

  static DateTime? dateOnly(DateTime? dt) =>
      dt == null ? null : DateTime(dt.year, dt.month, dt.day);

  static bool validateDates({
    required DateTime? start,
    required DateTime? end,
    required YearRules rules,
    bool showToast = true,
  }) {
    final DateTime? startDate = dateOnly(start);
    final DateTime? endDate = dateOnly(end);

    // Chronology: completion must be >= start
    if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
      if (showToast) {
        AlertManager().showWarningToast(
          "project.viewEditContractDetails.completionDateStartDate".tr(),
        );
        // e.g., "Expected Start Date cannot be greater than Completion Date."
      }
      return false;
    }

    // Year-based rules (only if both dates exist)
    if (startDate != null && endDate != null) {
      final int startYear = startDate.year;
      final int endYear = endDate.year;

      if (rules.sameYearOnly && startYear != endYear) {
        if (showToast) {
          AlertManager().showWarningToast(
            "project.viewEditContractDetails.startDateCompletionSameYear".tr(),

            //"Start and completion must be in the same year.",
          );
        }
        return false;
      }

      if (!rules.sameYearOnly && rules.maxYearSpan != null) {
        final int span = (endYear - startYear).abs();
        if (span > rules.maxYearSpan!) {
          if (showToast) {
            AlertManager().showWarningToast(
              "project.viewEditContractDetails.completionSpan".tr(),
              // "Completion year exceeds allowed span.",
            );
          }
          return false;
        }
      }
    }

    return true;
  }
}

/// Configuration: choose how strict your year checks should be.
class YearRules {
  const YearRules({this.sameYearOnly = false, this.maxYearSpan});

  /// If true, completion must be in the same calendar year as start.
  final bool sameYearOnly;

  /// If not sameYearOnly, you can still enforce a maximum year span
  /// (inclusive).
  /// Example: maxYearSpan = 1 means end.year can be start.year or start.year+1.
  final int? maxYearSpan;
}
