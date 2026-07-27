import "package:flutter/services.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";

/// Input formatter that prevents values greater than the configured maximum.
class MaxValueTextInputFormatter extends TextInputFormatter {
  /// Creates a formatter that restricts input to the specified maximum value.
  MaxValueTextInputFormatter(this.max);

  /// Maximum allowed value.
  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = newValue.text.replaceAll(",", "");
    final int entered = int.tryParse(cleaned) ?? 0;
    if (entered == 0) {
      return newValue;
    }
    if (entered > max) {
      AlertManager().showWarningToast("Proposed limit exceeds parent limit");
      return oldValue;
    }
    return newValue;
  }
}

/// Defines the available facility limit types.
enum LimitTypeEnum {
  /// Represents a main limit.
  mainLimit,

  /// Represents a sub limit.
  subLimit,
}

/// Extension methods for [LimitTypeEnum].
extension LimitTypeEnumX on LimitTypeEnum {
  /// Returns the display label for the limit type.
  String get label {
    switch (this) {
      case LimitTypeEnum.mainLimit:
        return "Main Limit";
      case LimitTypeEnum.subLimit:
        return "Sub Limit";
    }
  }

  /// Returns the corresponding [LimitTypeEnum] for the provided label.
  ///
  /// Defaults to [LimitTypeEnum.subLimit] when the label is null,
  /// empty, or unrecognized.
  static LimitTypeEnum fromLabel(String? label) {
    switch (label?.trim()) {
      case "Main Limit":
        return LimitTypeEnum.mainLimit;
      case "Sub Limit":
        return LimitTypeEnum.subLimit;
      default:
        return LimitTypeEnum.subLimit;
    }
  }
}
