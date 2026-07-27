/// Represents RAROC information for a customer,
/// including existing and proposed RAROC metrics.
class RarocInformation {
  /// Creates a [RarocInformation] instance.
  RarocInformation({
    this.customerRim,
    this.customerName,
    this.existingRealizedRarocPercent,
    this.existingLastApprovedRarocPercent,
    this.proposedRarocPercentProposedByCoverage,
    this.proposedFinalRarocPercentExAnteRaroc,
    this.comments,
  });

  /// Creates a [RarocInformation] instance from a JSON map.
  RarocInformation.fromJson(Map<String, dynamic> json) {
    customerRim = json["customerRim"];
    customerName = json["customerName"];
    existingRealizedRarocPercent = json["existingRealizedRarocPercent"] ?? "";
    existingLastApprovedRarocPercent =
        json["existingLastApprovedRarocPercent"] ?? "";
    proposedRarocPercentProposedByCoverage =
        json["proposedRarocPercentProposedByCoverage"] ?? "";
    proposedFinalRarocPercentExAnteRaroc =
        json["proposedFinalRarocPercentExAnteRaroc"] ?? "";
    comments = json["comments"];
  }

  /// customerRim
  String? customerRim;

  /// customerName
  String? customerName;

  /// existingRealizedRarocPercent
  String? existingRealizedRarocPercent;

  /// existingLastApprovedRarocPercent
  String? existingLastApprovedRarocPercent;

  /// proposedRarocPercentProposedByCoverage
  String? proposedRarocPercentProposedByCoverage;

  /// proposedFinalRarocPercentExAnteRaroc
  String? proposedFinalRarocPercentExAnteRaroc;

  /// comments
  String? comments;

  /// Converts this [RarocInformation] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["customerRim"] = customerRim;
    data["customerName"] = customerName;
    data["existingRealizedRarocPercent"] = existingRealizedRarocPercent ?? "";
    data["existingLastApprovedRarocPercent"] = existingLastApprovedRarocPercent;
    data["proposedRarocPercentProposedByCoverage"] =
        proposedRarocPercentProposedByCoverage ?? "";
    data["proposedFinalRarocPercentExAnteRaroc"] =
        proposedFinalRarocPercentExAnteRaroc;
    data["comments"] = comments;
    return data;
  }
}
