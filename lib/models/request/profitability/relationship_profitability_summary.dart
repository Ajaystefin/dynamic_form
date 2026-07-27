import "package:wcas_frontend/models/request/profitability/profitability_summary/raroc_info.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/realtionship_profitability.dart";

/// Represents relationship profitability summary data,
/// including RAROC and profitability information.
class RelationshipProfitabilitySummary {
  /// Creates a [RelationshipProfitabilitySummary] instance.
  RelationshipProfitabilitySummary({
    this.rarocInformation,
    this.relationshipProfitability,
  });

  /// Creates a [RelationshipProfitabilitySummary] instance from a JSON map.
  RelationshipProfitabilitySummary.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json["rarocInformation"] != null) {
      rarocInformation = <RarocInformation>[];
      json["rarocInformation"].forEach((v) {
        rarocInformation!.add(RarocInformation.fromJson(v));
      });
    }
    if (json["relationshipProfitability"] != null) {
      relationshipProfitability = <RelationshipProfitability>[];
      json["relationshipProfitability"].forEach((v) {
        relationshipProfitability!.add(RelationshipProfitability.fromJson(v));
      });
    }
  }

  /// RAROC information records.
  List<RarocInformation>? rarocInformation;

  /// Relationship profitability records.
  List<RelationshipProfitability>? relationshipProfitability;

  /// Converts this [RelationshipProfitabilitySummary]
  /// instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (rarocInformation != null) {
      data["rarocInformation"] =
          rarocInformation!.map((v) => v.toJson()).toList();
    }
    if (relationshipProfitability != null) {
      data["relationshipProfitability"] =
          relationshipProfitability!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
