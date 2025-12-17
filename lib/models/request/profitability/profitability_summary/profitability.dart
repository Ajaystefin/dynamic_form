
class RelationshipProfitability {
  String? customerRim;
  String? customerName;
  ProfitabilityData? projectedNext12Months;
  ProfitabilityData? realizedLastYear;
  String? comments;

  RelationshipProfitability({
    this.customerRim,
    this.customerName,
    this.projectedNext12Months,
    this.realizedLastYear,
    this.comments,
  });

  RelationshipProfitability.fromJson(Map<String, dynamic> json) {
    // Simple fields
    customerRim = json['customerRim'];
    customerName = json['customerName'];
    comments = json['comments'];
    // Nested objects
    final proj = json['projectedNext12Months'];
    final real = json['realizedLastYear'];
    projectedNext12Months = proj != null ? ProfitabilityData.fromJson(proj) : null;
    realizedLastYear = real != null ? ProfitabilityData.fromJson(real) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // Simple fields
    data['customerRim'] = customerRim;
    data['customerName'] = customerName;
    data['comments'] = comments;
    // Nested objects
    if (projectedNext12Months != null) {
      data['projectedNext12Months'] = projectedNext12Months!.toJson();
    }
    if (realizedLastYear != null) {
      data['realizedLastYear'] = realizedLastYear!.toJson();
    }
    return data;
  }
}

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

  static const _jsonKeys = <String>[
    'nii',
    'nfi',
    'expectedNetIncome',
    'avgCasa',
    'rwa',
    'realizedNii',
    'realizedNfi',
    'realizedExpectedNetIncome',
    'realizedAvgCasa',
    'realizedRwa',
  ];

  ProfitabilityData.fromJson(Map<String, dynamic> json) {
    // Assign by iterating over known keys
    for (final k in _jsonKeys) {
      final v = json[k];
      switch (k) {
        case 'nii':
          nii = v;
          break;
        case 'nfi':
          nfi = v;
          break;
        case 'expectedNetIncome':
          expectedNetIncome = v;
          break;
        case 'avgCasa':
          avgCasa = v;
          break;
        case 'rwa':
          rwa = v;
          break;
        case 'realizedNii':
          realizedNii = v;
          break;
        case 'realizedNfi':
          realizedNfi = v;
          break;
        case 'realizedExpectedNetIncome':
          realizedExpectedNetIncome = v;
          break;
        case 'realizedAvgCasa':
          realizedAvgCasa = v;
          break;
        case 'realizedRwa':
          realizedRwa = v;
          break;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // Emit by iterating over keys
    for (final k in _jsonKeys) {
      switch (k) {
        case 'nii':
          data[k] = nii;
          break;
        case 'nfi':
          data[k] = nfi;
          break;
        case 'expectedNetIncome':
          data[k] = expectedNetIncome;
          break;
        case 'avgCasa':
          data[k] = avgCasa;
          break;
        case 'rwa':
          data[k] = rwa;
          break;
        case 'realizedNii':
          data[k] = realizedNii;
          break;
        case 'realizedNfi':
          data[k] = realizedNfi;
          break;
        case 'realizedExpectedNetIncome':
          data[k] = realizedExpectedNetIncome;
          break;
        case 'realizedAvgCasa':
          data[k] = realizedAvgCasa;
          break;
        case 'realizedRwa':
          data[k] = realizedRwa;
          break;
      }
    }
    return data;
  }
}
