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
    // Simple fields
    customerRim = json["customerRim"];
    customerName = json["customerName"];
    comments = json["comments"];
    // Nested objects
    final proj = json["projectedNext12Months"];
    final real = json["realizedLastYear"];
    projectedNext12Months = proj != null
        ? ProfitabilityData.fromProjectedNext12MonthsJson(proj)
        : null;
    realizedLastYear =
        real != null ? ProfitabilityData.fromRealizedLastYearsJson(real) : null;
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
    // Simple fields
    data["customerRim"] = customerRim;
    data["customerName"] = customerName;
    data["comments"] = comments;
    // Nested objects
    if (projectedNext12Months != null) {
      data["projectedNext12Months"] = projectedNext12Months!.toJson();
    }
    if (realizedLastYear != null) {
      data["realizedLastYear"] = realizedLastYear!.toJson();
    }
    return data;
  }
}
