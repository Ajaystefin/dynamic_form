import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";

class SecurityCovenantCondition {
  SecurityCovenantCondition({
    this.appRefNo,
    this.number,
    this.covenantConditionMasterId,
    this.description,
    this.deferralDate,
    this.date,
    this.isChecked = false,
    this.isCovenant = false,
  });
  factory SecurityCovenantCondition.fromJson(
    Map<String, dynamic> json, {
    bool isCovenant = false,
  }) {
    return SecurityCovenantCondition(
      appRefNo: json["appRefNo"],
      number: json["covenantConditionNo"],
      covenantConditionMasterId: json["covenantConditionMasterId"],
      description: json["description"],
      deferralDate: DateTimeUtils.intToDateTime(json["deferralDate"]),
      isChecked: json["selected"] ?? false,
      isCovenant: json["isCovenant"] ?? false,
    );
  }
  String? appRefNo;
  String? number;
  String? description;
  DateTime? deferralDate;
  int? covenantConditionMasterId;
  bool isChecked;
  bool isCovenant;
  DateTime? date;
  Map<String, dynamic> toJson({required bool isCovenant}) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["appRefNo"] = appRefNo; //
    data["covenantConditionNo"] = number; //
    data["covenantConditionMasterId"] = covenantConditionMasterId; //
    data["description"] = description;
    try {
      data["deferralDate"] = deferralDate != null
          ? DateFormat("yyyy-MM-dd").format(deferralDate!)
          : null; //
    } catch (_) {
      data["deferralDate"] = null;
    }

    data["selected"] = isChecked; //
    data["isCovenant"] = isCovenant; //
    return data;
  }
}
