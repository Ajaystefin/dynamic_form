import "package:flutter/services.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";

class MaxValueTextInputFormatter extends TextInputFormatter {
  MaxValueTextInputFormatter(this.max);
  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = newValue.text.replaceAll(",", "");
    final int entered = int.tryParse(cleaned) ?? 0;
    if (entered == 0) return newValue;
    if (entered > max) {
      AlertManager().showWarningToast("Proposed limit exceeds parent limit");
      return oldValue;
    }
    return newValue;
  }
}

enum LimitTypeEnum { mainLimit, subLimit }

extension LimitTypeEnumX on LimitTypeEnum {
  String get label {
    switch (this) {
      case LimitTypeEnum.mainLimit:
        return "Main Limit";
      case LimitTypeEnum.subLimit:
        return "Sub Limit";
    }
  }

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
