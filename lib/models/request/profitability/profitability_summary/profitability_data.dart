class ProfitabilityData {
  ProfitabilityData({
    this.nii,
    this.nfi,
    this.expectedNetIncome,
    this.avgCasa,
    this.rwa,
    this.realizedNii,
    this.realizedNfi,
    this.realizedExpectedNetIncome,
    this.realizedAvgCasa,
    this.realizedRwa,
  });

  ProfitabilityData.fromJhson(Map<String, dynamic> json) {
    nii = json["nii"]?.toString();
    nfi = json["nfi"]?.toString();
    expectedNetIncome = json["expectedNetIncome"]?.toString();
    avgCasa = json["avgCasa"]?.toString();
    rwa = json["rwa"]?.toString();

    realizedNii = json["realizedNii"]?.toString();
    realizedNfi = json["realizedNfi"]?.toString();
    realizedExpectedNetIncome = json["realizedExpectedNetIncome"]?.toString();
    realizedAvgCasa = json["realizedAvgCasa"]?.toString();
    realizedRwa = json["realizedRwa"]?.toString();
  }

  ProfitabilityData.fromProjectedNext12MonthsJson(Map<String, dynamic> json) {
    nii = json["nii"]?.toString();
    nfi = json["nfi"]?.toString();
    expectedNetIncome = json["expectedNetIncome"]?.toString();
    avgCasa = json["avgCasa"]?.toString();
    rwa = json["rwa"]?.toString();
  }

  ProfitabilityData.fromRealizedLastYearsJson(Map<String, dynamic> json) {
    nii = json["nii"]?.toString();
    nfi = json["nfi"]?.toString();
    expectedNetIncome = json["expectedNetIncome"]?.toString();
    avgCasa = json["avgCasa"]?.toString();
    rwa = json["rwa"]?.toString();
  }
  String? nii;
  String? nfi;
  String? expectedNetIncome;
  String? avgCasa;
  String? rwa;
  String? realizedNii;
  String? realizedNfi;
  String? realizedExpectedNetIncome;
  String? realizedAvgCasa;
  String? realizedRwa;

  Map<String, dynamic> toProjectedNext12MonthsJson() {
    return {
      "nii": nii,
      "nfi": nfi,
      "expectedNetIncome": expectedNetIncome,
      "avgCasa": avgCasa,
      "rwa": rwa,
    };
  }

  Map<String, dynamic> toRealizedLastYearsJson() {
    return {
      "nii": nii,
      "nfi": nfi,
      "expectedNetIncome": expectedNetIncome,
      "avgCasa": avgCasa,
      "rwa": rwa,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "nii": nii,
      "nfi": nfi,
      "expectedNetIncome": expectedNetIncome,
      "avgCasa": avgCasa,
      "rwa": rwa,
      "realizedNii": realizedNii,
      "realizedNfi": realizedNfi,
      "realizedExpectedNetIncome": realizedExpectedNetIncome,
      "realizedAvgCasa": realizedAvgCasa,
      "realizedRwa": realizedRwa,
    };
  }
}
