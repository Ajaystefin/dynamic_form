class RarocInformation {
  RarocInformation({
    this.customerRim,
    this.customerName,
    this.existingRealizedRarocPercent,
    this.existingLastApprovedRarocPercent,
    this.proposedRarocPercentProposedByCoverage,
    this.proposedFinalRarocPercentExAnteRaroc,
    this.comments,
  });

  RarocInformation.fromJson(Map<String, dynamic> json) {
    customerRim = json["customerRim"];
    customerName = json["customerName"];
    existingRealizedRarocPercent = (json["existingRealizedRarocPercent"] ?? "");
    existingLastApprovedRarocPercent =
        (json["existingLastApprovedRarocPercent"] ?? "");
    proposedRarocPercentProposedByCoverage =
        (json["proposedRarocPercentProposedByCoverage"] ?? "");
    proposedFinalRarocPercentExAnteRaroc =
        (json["proposedFinalRarocPercentExAnteRaroc"] ?? "");
    comments = json["comments"];
  }
  String? customerRim;
  String? customerName;
  String? existingRealizedRarocPercent;
  String? existingLastApprovedRarocPercent;
  String? proposedRarocPercentProposedByCoverage;
  String? proposedFinalRarocPercentExAnteRaroc;
  String? comments;

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
