import 'package:wcas_frontend/models/request/profitability/profitability_summary/profitability_data.dart';

class RelationshipProfitability {
  String? customerRim;
  String? customerName;
  ProfitabilityData? projectedNext12Months;
  ProfitabilityData? realizedLastYear;
  String? comments;

  RelationshipProfitability(
      {this.customerRim,
      this.customerName,
      this.projectedNext12Months,
      this.realizedLastYear,
      this.comments});

  RelationshipProfitability.fromJson(Map<String, dynamic> json) {
    customerRim = json['customerRim'];
    customerName = json['customerName'];
    projectedNext12Months = json['projectedNext12Months'] != null
        ? ProfitabilityData.fromJson(json['projectedNext12Months'])
        : null;
    realizedLastYear = json['realizedLastYear'] != null
        ? ProfitabilityData.fromJson(json['realizedLastYear'])
        : null;
    comments = json['comments'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customerRim'] = customerRim;
    data['customerName'] = customerName;
    if (projectedNext12Months != null) {
      data['projectedNext12Months'] = projectedNext12Months!.toJson();
    }
    if (realizedLastYear != null) {
      data['realizedLastYear'] = realizedLastYear!.toJson();
    }
    data['comments'] = comments;
    return data;
  }
}
