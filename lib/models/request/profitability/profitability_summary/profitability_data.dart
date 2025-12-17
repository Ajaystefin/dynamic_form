class ProfitabilityData {
  int? nii;
  int? nfi;
  int? expectedNetIncome;
  int? avgCasa;
  int? rwa;
  int? realizedNii;
  int? realizedNfi;
  int? realizedExpectedNetIncome;
  int? realizedAvgCasa;
  int? realizedRwa;

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

  ProfitabilityData.fromJson(Map<String, dynamic> json) {
    nii = json['nii'];
    nfi = json['nfi'];
    expectedNetIncome = json['expectedNetIncome'];
    avgCasa = json['avgCasa'];
    rwa = json['rwa'];
    realizedNii = json['realizedNii'];
    realizedNfi = json['realizedNfi'];
    realizedExpectedNetIncome = json['realizedExpectedNetIncome'];
    realizedAvgCasa = json['realizedAvgCasa'];
    realizedRwa = json['realizedRwa'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nii'] = nii;
    data['nfi'] = nfi;
    data['expectedNetIncome'] = expectedNetIncome;
    data['avgCasa'] = avgCasa;
    data['rwa'] = rwa;
    data['realizedNii'] = realizedNii;
    data['realizedNfi'] = realizedNfi;
    data['realizedExpectedNetIncome'] = realizedExpectedNetIncome;
    data['realizedAvgCasa'] = realizedAvgCasa;
    data['realizedRwa'] = realizedRwa;

    return data;
  }
}
