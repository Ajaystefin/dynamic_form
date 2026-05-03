import "package:flutter_test/flutter_test.dart";
// import 'package:wcas_frontend/models/request/profitability/profitability_summary/profitability.dart';

void main() {
  group("ProfitabilityData", () {
    //   test('fromJson creates a valid instance', () {
    //     final Map<String, dynamic> json = {
    //       'nii': 100,
    //       'nfi': 50,
    //       'expectedNetIncome': 150,
    //       'avgCasa': 200,
    //       'rwa': 300,
    //       'realizedNii': 90,
    //       'realizedNfi': 45,
    //       'realizedExpectedNetIncome': 135,
    //       'realizedAvgCasa': 180,
    //       'realizedRwa': 270,
    //     };

    //     final profitabilityData = ProfitabilityData.fromJson(json);

    //     expect(profitabilityData.nii, 100);
    //     expect(profitabilityData.nfi, 50);
    //     expect(profitabilityData.expectedNetIncome, 150);
    //     expect(profitabilityData.avgCasa, 200);
    //     expect(profitabilityData.rwa, 300);
    //     expect(profitabilityData.realizedNii, 90);
    //     expect(profitabilityData.realizedNfi, 45);
    //     expect(profitabilityData.realizedExpectedNetIncome, 135);
    //     expect(profitabilityData.realizedAvgCasa, 180);
    //     expect(profitabilityData.realizedRwa, 270);
    //   });

    //   test('toJson converts instance to JSON correctly', () {
    //     final profitabilityData = ProfitabilityData(
    //       nii: 100,
    //       nfi: 50,
    //       expectedNetIncome: 150,
    //       avgCasa: 200,
    //       rwa: 300,
    //       realizedNii: 90,
    //       realizedNfi: 45,
    //       realizedExpectedNetIncome: 135,
    //       realizedAvgCasa: 180,
    //       realizedRwa: 270,
    //     );

    //     final json = profitabilityData.toJson();

    //     expect(json['nii'], 100);
    //     expect(json['nfi'], 50);
    //     expect(json['expectedNetIncome'], 150);
    //     expect(json['avgCasa'], 200);
    //     expect(json['rwa'], 300);
    //     expect(json['realizedNii'], 90);
    //     expect(json['realizedNfi'], 45);
    //     expect(json['realizedExpectedNetIncome'], 135);
    //     expect(json['realizedAvgCasa'], 180);
    //     expect(json['realizedRwa'], 270);
    //   });
  });

  group("RelationshipProfitability", () {
    // test('fromJson creates a valid instance', () {
    //   final Map<String, dynamic> json = {
    //     'customerRim': 'RIM123',
    //     'customerName': 'Test Customer',
    //     'projectedNext12Months': {
    //       'nii': 100,
    //       'nfi': 50,
    //       'expectedNetIncome': 150,
    //       'avgCasa': 200,
    //       'rwa': 300,
    //       'realizedNii': 90,
    //       'realizedNfi': 45,
    //       'realizedExpectedNetIncome': 135,
    //       'realizedAvgCasa': 180,
    //       'realizedRwa': 270,
    //     },
    //     'realizedLastYear': {
    //       'nii': 80,
    //       'nfi': 40,
    //       'expectedNetIncome': 120,
    //       'avgCasa': 160,
    //       'rwa': 240,
    //       'realizedNii': 70,
    //       'realizedNfi': 35,
    //       'realizedExpectedNetIncome': 105,
    //       'realizedAvgCasa': 140,
    //       'realizedRwa': 210,
    //     },
    //     'comments': 'Some comments',
    //   };

    //   final relationshipProfitability =
    //       RelationshipProfitability.fromJson(json);

    //   expect(relationshipProfitability.customerRim, 'RIM123');
    //   expect(relationshipProfitability.customerName, 'Test Customer');
    //   expect(relationshipProfitability.projectedNext12Months, isNotNull);
    //   expect(relationshipProfitability.projectedNext12Months!.nii, 100);
    //   expect(relationshipProfitability.realizedLastYear, isNotNull);
    //   expect(relationshipProfitability.realizedLastYear!.nii, 80);
    //   expect(relationshipProfitability.comments, 'Some comments');
    // });

    // test('toJson converts instance to JSON correctly', () {
    //   final profitabilityData1 = ProfitabilityData(
    //     nii: 100,
    //     nfi: 50,
    //     expectedNetIncome: 150,
    //     avgCasa: 200,
    //     rwa: 300,
    //     realizedNii: 90,
    //     realizedNfi: 45,
    //     realizedExpectedNetIncome: 135,
    //     realizedAvgCasa: 180,
    //     realizedRwa: 270,
    //   );

    //   final profitabilityData2 = ProfitabilityData(
    //     nii: 80,
    //     nfi: 40,
    //     expectedNetIncome: 120,
    //     avgCasa: 160,
    //     rwa: 240,
    //     realizedNii: 70,
    //     realizedNfi: 35,
    //     realizedExpectedNetIncome: 105,
    //     realizedAvgCasa: 140,
    //     realizedRwa: 210,
    //   );

    //   final relationshipProfitability = RelationshipProfitability(
    //     customerRim: 'RIM123',
    //     customerName: 'Test Customer',
    //     projectedNext12Months: profitabilityData1,
    //     realizedLastYear: profitabilityData2,
    //     comments: 'Some comments',
    //   );

    //   final json = relationshipProfitability.toJson();

    //   expect(json['customerRim'], 'RIM123');
    //   expect(json['customerName'], 'Test Customer');
    //   expect(json['projectedNext12Months'], isA<Map<String, dynamic>>());
    //   expect(json['projectedNext12Months']['nii'], 100);
    //   expect(json['realizedLastYear'], isA<Map<String, dynamic>>());
    //   expect(json['realizedLastYear']['nii'], 80);
    //   expect(json['comments'], 'Some comments');
    // });
  });
}
