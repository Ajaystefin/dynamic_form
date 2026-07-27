import "package:wcas_frontend/models/request/profitability/profitability_summary/profitability_data.dart";

/// Represents relationship profitability information,
/// including projected and realized profitability metrics.
class RelationshipProfitability {
  /// Creates a [RelationshipProfitability] instance.
  RelationshipProfitability({
    this.customerRim,
    this.customerName,
    this.projectedNext12Months,
    this.realizedLastYear,
    this.comments,
  });

  /// Creates a [RelationshipProfitability] instance from a JSON map.
  RelationshipProfitability.fromJson(Map<String, dynamic> json) {
    customerRim = json["customerRim"];
    customerName = json["customerName"];
    projectedNext12Months = json["projectedNext12Months"] != null
        ? ProfitabilityData.fromProjectedNext12MonthsJson(
            json["projectedNext12Months"],
          )
        : null;
    realizedLastYear = json["realizedLastYear"] != null
        ? ProfitabilityData.fromRealizedLastYearsJson(json["realizedLastYear"])
        : null;
    comments = json["comments"];
  }

  /// customerRim
  String? customerRim;

  /// customerName
  String? customerName;

  /// projectedNext12Months
  ProfitabilityData? projectedNext12Months;

  /// realizedLastYear
  ProfitabilityData? realizedLastYear;

  /// comments
  String? comments;

  /// Converts this [RelationshipProfitability] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["customerRim"] = customerRim;
    data["customerName"] = customerName;
    if (projectedNext12Months != null) {
      data["projectedNext12Months"] =
          projectedNext12Months!.toProjectedNext12MonthsJson();
    }
    if (realizedLastYear != null) {
      data["realizedLastYear"] = realizedLastYear!.toRealizedLastYearsJson();
    }
    data["comments"] = comments;
    return data;
  }
}
