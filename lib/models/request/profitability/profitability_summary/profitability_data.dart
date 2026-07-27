/// Represents profitability data including projected and
/// realized financial performance metrics.
class ProfitabilityData {
  /// Creates a [ProfitabilityData] instance.
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

  /// Creates a [ProfitabilityData] instance from a JSON map.
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

  /// Creates a [ProfitabilityData] instance from projected next 12 months data.
  ProfitabilityData.fromProjectedNext12MonthsJson(
    Map<String, dynamic> json,
  ) {
    nii = json["nii"]?.toString();
    nfi = json["nfi"]?.toString();
    expectedNetIncome = json["expectedNetIncome"]?.toString();
    avgCasa = json["avgCasa"]?.toString();
    rwa = json["rwa"]?.toString();
  }

  /// Creates a [ProfitabilityData] instance from realized last years data.
  ProfitabilityData.fromRealizedLastYearsJson(
    Map<String, dynamic> json,
  ) {
    nii = json["nii"]?.toString();
    nfi = json["nfi"]?.toString();
    expectedNetIncome = json["expectedNetIncome"]?.toString();
    avgCasa = json["avgCasa"]?.toString();
    rwa = json["rwa"]?.toString();
  }

  /// nii
  String? nii;

  /// nfi
  String? nfi;

  /// expectedNetIncome
  String? expectedNetIncome;

  /// avgCasa
  String? avgCasa;

  /// rwa
  String? rwa;

  /// realizedNii
  String? realizedNii;

  /// realizedNfi
  String? realizedNfi;

  /// realizedExpectedNetIncome
  String? realizedExpectedNetIncome;

  /// realizedAvgCasa
  String? realizedAvgCasa;

  /// realizedRwa
  String? realizedRwa;

  /// Converts projected next 12 months data to a JSON map.
  Map<String, dynamic> toProjectedNext12MonthsJson() {
    return {
      "nii": nii,
      "nfi": nfi,
      "expectedNetIncome": expectedNetIncome,
      "avgCasa": avgCasa,
      "rwa": rwa,
    };
  }

  /// Converts realized last years data to a JSON map.
  Map<String, dynamic> toRealizedLastYearsJson() {
    return {
      "nii": nii,
      "nfi": nfi,
      "expectedNetIncome": expectedNetIncome,
      "avgCasa": avgCasa,
      "rwa": rwa,
    };
  }

  /// Converts this [ProfitabilityData] instance to a JSON map.
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
