import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";

/// Represents a covenant or condition deferral record,
/// including description, selection status, and deferral date.
class SecurityCovenantCondition {
  /// Creates a [SecurityCovenantCondition] instance.
  SecurityCovenantCondition({
    this.appRefNo,
    this.number,
    this.covenantConditionMasterId,
    this.description,
    this.deferralDate,
    this.date,
    this.selected = false,
    this.isChecked = false,
    this.isCovenant = false,
  });

  /// Creates a [SecurityCovenantCondition] instance from a JSON map.
  factory SecurityCovenantCondition.fromJson(
    Map<String, dynamic> json,
  ) {
    final bool selectedValue = safeBool(json["selected"]);
    return SecurityCovenantCondition(
      appRefNo: json["appRefNo"],
      number: json["covenantConditionNo"],
      covenantConditionMasterId: json["covenantConditionMasterId"],
      description: json["description"],
      deferralDate: DateTimeUtils.intToDateTime(json["deferralDate"]),
      selected: selectedValue,
      isChecked: selectedValue, //FIX HERE
      isCovenant: json["isCovenant"] ?? false,
    );
  }

  /// Application reference number.
  String? appRefNo;

  /// Covenant or condition reference number.
  String? number;

  /// Description of the covenant or condition.
  String? description;

  /// Deferral date associated with the covenant or condition.
  DateTime? deferralDate;

  /// Unique identifier of the covenant or condition.
  int? covenantConditionMasterId;

  /// Indicates whether the record is selected.
  bool selected;

  /// UI flag indicating whether the record is checked.
  bool isChecked;

  /// Indicates whether the record represents a covenant.
  bool isCovenant;

  /// Date associated with the covenant or condition.
  DateTime? date;

  /// Converts this [SecurityCovenantCondition] instance to a JSON map.
  Map<String, dynamic> toJson({required bool isCovenant}) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["appRefNo"] = appRefNo; //
    data["covenantConditionNo"] = number; //
    data["covenantConditionMasterId"] = covenantConditionMasterId; //
    data["description"] = description;
    data["isCovenant"] = isCovenant; //
    try {
      final bool hasDate = deferralDate != null;
      data["selected"] = hasDate;
      data["deferralDate"] =
          hasDate ? DateFormat("yyyy-MM-dd").format(deferralDate!) : null;
    } on Object catch (_) {
      data["selected"] = false;
      data["deferralDate"] = null;
    }

    return data;
  }
}

/// Returns a boolean value from the supplied object.
bool safeBool(Object? value) {
  if (value == null) {
    return false;
  }
  if (value is bool) {
    return value;
  }
  return value.toString().toLowerCase() == "true";
}
