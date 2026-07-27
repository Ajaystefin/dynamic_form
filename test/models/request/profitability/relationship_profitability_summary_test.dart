import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/models/request/profitability/profitability_summary/raroc_info.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/realtionship_profitability.dart";
import "package:wcas_frontend/models/request/profitability/relationship_profitability_summary.dart";

void main() {
  group("RelationshipProfitabilitySummary", () {
    test("constructor should assign provided lists", () {
      final List<RarocInformation> rarocList = <RarocInformation>[
        RarocInformation(),
      ];

      final List<RelationshipProfitability> relationshipList =
          <RelationshipProfitability>[
        RelationshipProfitability(),
      ];

      final RelationshipProfitabilitySummary summary =
          RelationshipProfitabilitySummary(
        rarocInformation: rarocList,
        relationshipProfitability: relationshipList,
      );

      expect(summary.rarocInformation, same(rarocList));
      expect(summary.relationshipProfitability, same(relationshipList));
      expect(summary.rarocInformation, hasLength(1));
      expect(summary.relationshipProfitability, hasLength(1));
    });

    test("fromJson should keep lists null when keys are missing", () {
      final RelationshipProfitabilitySummary summary =
          RelationshipProfitabilitySummary.fromJson(<String, dynamic>{});

      expect(summary.rarocInformation, isNull);
      expect(summary.relationshipProfitability, isNull);
    });

    test("fromJson should keep lists null when json values are null", () {
      final RelationshipProfitabilitySummary summary =
          RelationshipProfitabilitySummary.fromJson(
        <String, dynamic>{
          "rarocInformation": null,
          "relationshipProfitability": null,
        },
      );

      expect(summary.rarocInformation, isNull);
      expect(summary.relationshipProfitability, isNull);
    });

    test("fromJson should create empty lists when json lists are empty", () {
      final RelationshipProfitabilitySummary summary =
          RelationshipProfitabilitySummary.fromJson(
        <String, dynamic>{
          "rarocInformation": <Map<String, dynamic>>[],
          "relationshipProfitability": <Map<String, dynamic>>[],
        },
      );

      expect(summary.rarocInformation, isNotNull);
      expect(summary.rarocInformation, isEmpty);
      expect(summary.relationshipProfitability, isNotNull);
      expect(summary.relationshipProfitability, isEmpty);
    });

    test("fromJson should parse raroc and relationship profitability lists",
        () {
      final Map<String, dynamic> rarocJson = RarocInformation().toJson();
      final Map<String, dynamic> relationshipJson =
          RelationshipProfitability().toJson();

      final RelationshipProfitabilitySummary summary =
          RelationshipProfitabilitySummary.fromJson(
        <String, dynamic>{
          "rarocInformation": <Map<String, dynamic>>[
            rarocJson,
          ],
          "relationshipProfitability": <Map<String, dynamic>>[
            relationshipJson,
          ],
        },
      );

      expect(summary.rarocInformation, isNotNull);
      expect(summary.rarocInformation, hasLength(1));
      expect(summary.rarocInformation!.first, isA<RarocInformation>());

      expect(summary.relationshipProfitability, isNotNull);
      expect(summary.relationshipProfitability, hasLength(1));
      expect(
        summary.relationshipProfitability!.first,
        isA<RelationshipProfitability>(),
      );
    });

    test("toJson should return empty map when lists are null", () {
      final RelationshipProfitabilitySummary summary =
          RelationshipProfitabilitySummary();

      final Map<String, dynamic> json = summary.toJson();

      expect(json, isEmpty);
      expect(json.containsKey("rarocInformation"), isFalse);
      expect(json.containsKey("relationshipProfitability"), isFalse);
    });

    test("toJson should include empty lists when lists are empty", () {
      final RelationshipProfitabilitySummary summary =
          RelationshipProfitabilitySummary(
        rarocInformation: <RarocInformation>[],
        relationshipProfitability: <RelationshipProfitability>[],
      );

      final Map<String, dynamic> json = summary.toJson();

      expect(json.containsKey("rarocInformation"), isTrue);
      expect(json.containsKey("relationshipProfitability"), isTrue);
      expect(json["rarocInformation"], isEmpty);
      expect(json["relationshipProfitability"], isEmpty);
    });

    test("toJson should serialize raroc and relationship profitability lists",
        () {
      final RelationshipProfitabilitySummary summary =
          RelationshipProfitabilitySummary(
        rarocInformation: <RarocInformation>[
          RarocInformation(),
        ],
        relationshipProfitability: <RelationshipProfitability>[
          RelationshipProfitability(),
        ],
      );

      final Map<String, dynamic> json = summary.toJson();

      expect(json["rarocInformation"], isA<List<dynamic>>());
      expect(json["relationshipProfitability"], isA<List<dynamic>>());

      expect(json["rarocInformation"], hasLength(1));
      expect(json["relationshipProfitability"], hasLength(1));

      expect(
        (json["rarocInformation"] as List<dynamic>).first,
        isA<Map<String, dynamic>>(),
      );

      expect(
        (json["relationshipProfitability"] as List<dynamic>).first,
        isA<Map<String, dynamic>>(),
      );
    });

    test("fromJson and toJson should work together", () {
      final RelationshipProfitabilitySummary original =
          RelationshipProfitabilitySummary(
        rarocInformation: <RarocInformation>[
          RarocInformation(),
        ],
        relationshipProfitability: <RelationshipProfitability>[
          RelationshipProfitability(),
        ],
      );

      final Map<String, dynamic> json = original.toJson();

      final RelationshipProfitabilitySummary parsed =
          RelationshipProfitabilitySummary.fromJson(json);

      expect(parsed.rarocInformation, isNotNull);
      expect(parsed.rarocInformation, hasLength(1));
      expect(parsed.relationshipProfitability, isNotNull);
      expect(parsed.relationshipProfitability, hasLength(1));
    });
  });
}
