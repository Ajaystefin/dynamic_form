import 'package:wcas_frontend/core/utils/date_time_utils.dart';

class SecurityCovenantCondition {
  String? number;
  String? description;
  String? deferralDate;
  bool isChecked;
  DateTime? date;

  SecurityCovenantCondition(
      {this.number,
      this.description,
      this.deferralDate,
      this.date,
      this.isChecked = false});

  factory SecurityCovenantCondition.fromJson(Map<String, dynamic> json) {
    return SecurityCovenantCondition(
        number: json['number'],
        description: json['description'],
        deferralDate: json['deferralDate'],
        isChecked: json['isChecked'] ?? false,
        date: DateTimeUtils.intToDateTime(json['conditionDate']));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number'] = number;
    data['description'] = description;
    data['deferralDate'] = deferralDate;
    data['isChecked'] = isChecked;
    data['conditionDate'] = date;
    return data;
  }
}
