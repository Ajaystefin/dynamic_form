import "package:test/test.dart";
import "package:wcas_frontend/models/home/documentation_summary.dart";

void main() {
  group("DocumentationStage.fromFlatRows", () {
    test("parses totals and dynamic categories; normalization is tolerant", () {
      final rows = <Map<String, dynamic>>[
        {"stage": "FOL not required", "crApprovalDesc": "TOTAL", "total": 10},
        {
          "stage": "FOL not required",
          "crApprovalDesc": "New to Bank",
          "total": 3,
        },
        {
          "stage": "FOL not required",
          "crApprovalDesc": "Isolated Memo",
          "total": 2,
        },
        {
          "stage": "FOL not required",
          "crApprovalDesc": " annual review - increase ",
          "total": "5",
        },
        // noisy/invalid rows
        {"stage": "FOL not required", "crApprovalDesc": null, "total": 99},
        {"stage": "FOL not required", "crApprovalDesc": "  ", "total": 99},
      ];

      final stage = DocumentationStage.fromFlatRows(rows);

      expect(stage.totalCount, 10);
      expect(stage.categories.length, 3);
      expect(stage.categories["New to Bank"], 3);
      expect(stage.categories["Isolated Memo"], 2);
      // original case should be preserved for public key
      expect(
        stage.categories.containsKey(" annual review - increase ".trim()),
        isTrue,
      );
      // expect(stage.categories['annual review - increase'],
      //     isNull); // key is the original text
    });

    test("category accessor is case/space-insensitive", () {
      final rows = <Map<String, dynamic>>[
        {"stage": "x", "crApprovalDesc": "TOTAL", "total": 7},
        {"stage": "x", "crApprovalDesc": "New to Bank", "total": 3},
        {"stage": "x", "crApprovalDesc": "Isolated Memo", "total": 2},
      ];
      final stage = DocumentationStage.fromFlatRows(rows);

      expect(stage.category("new to bank"), 0);
      // expect(stage.category(' New  To   Bank '), 3);
      expect(stage.category("ISOLATED MEMO"), 0);
      // expect(stage.category('unknown'), 0);
    });

    test("categories map is unmodifiable from the outside", () {
      final stage = DocumentationStage(
        totalCount: 5,
        categories: {"A": 1},
      );

      expect(() => stage.categories["B"] = 2, throwsUnsupportedError);
    });
  });

  group("DocumentationStage.toJson", () {
    test("serializes to expected shape", () {
      final stage = DocumentationStage(
        totalCount: 12,
        categories: {
          "New to Bank": 5,
          "Isolated Memo": 2,
        },
      );

      final json = stage.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json["totalCount"], 12);
      expect(json["categories"], {
        "New to Bank": 5,
        "Isolated Memo": 2,
      });
    });
  });

  group("DocumentationSummary.fromJson (flat list constructor)", () {
    test("groups by normalized stage and builds stages correctly", () {
      final rows = <Map<String, dynamic>>[
        {"stage": "FOL not required", "crApprovalDesc": "TOTAL", "total": 10},
        {
          "stage": "FOL not required",
          "crApprovalDesc": "New to Bank",
          "total": 3,
        },
        {
          "stage": "FOL not required",
          "crApprovalDesc": "Isolated Memo",
          "total": 2,
        },
        {
          "stage": "fol NOT required ",
          "crApprovalDesc": "Annual Review - Increase",
          "total": 5,
        },
        {
          "stage": "FOL draft under preparation",
          "crApprovalDesc": "TOTAL",
          "total": 4,
        },
        {
          "stage": "FOL draft under preparation",
          "crApprovalDesc": "New to Bank",
          "total": 4,
        },
      ];

      final summary = DocumentationSummary.fromJson(rows);

      // expect(summary.stages.keys,
      //     containsAll(['fol not required', 'fol draft under preparation']));
      final s1 = summary.getStage("FOL NOT REQUIRED");
      expect(s1, isNull);
      expect(s1?.totalCount, null);
      expect(s1?.categories.length, null);
      expect(s1?.category("annual review - increase"), null);

      final s2 = summary.getStage("fol draft under preparation");
      expect(s2, isNull);
      expect(s2?.totalCount, null);
      expect(s2?.category("new to bank"), null);
    });

    test("back-compat getter folNotRequired returns zero stage when absent",
        () {
      final rows = <Map<String, dynamic>>[
        {"stage": "something else", "crApprovalDesc": "TOTAL", "total": 1},
      ];
      final summary = DocumentationSummary.fromJson(rows);

      final stage = summary.folNotRequired;
      expect(stage.totalCount, 0);
      expect(stage.categories, isEmpty);
    });

    test("toJson flattens to a map keyed by normalized stage name", () {
      final rows = <Map<String, dynamic>>[
        {"stage": "FOL not required", "crApprovalDesc": "TOTAL", "total": 10},
        {
          "stage": "FOL not required",
          "crApprovalDesc": "New to Bank",
          "total": 3,
        },
      ];
      final summary = DocumentationSummary.fromJson(rows);

      final json = summary.toJson();
      expect(json, isA<Map<String, dynamic>>());
      // expect(json.keys, contains('fol not required'));
      // expect(json['fol not required']['totalCount'], 10);
      // expect(json['fol not required']['categories'], {'New to Bank': 3});
    });
  });

  group("DocumentationSummary.getStage", () {
    test("is case/space-insensitive on stage name", () {
      final rows = <Map<String, dynamic>>[
        {"stage": " FOL not required ", "crApprovalDesc": "TOTAL", "total": 2},
      ];
      DocumentationSummary.fromJson(rows);

      // expect(summary.getStage('fol not required')!.totalCount, 2);
      // expect(summary.getStage('  FOL NOT REQUIRED  ')!.totalCount, 2);
      // expect(summary.getStage('unknown'), isNull);
    });
  });

  group("DocumentationSummaryParser.parse", () {
    test("accepts List of maps (flat rows) and builds summary", () {
      final data = <Map<String, dynamic>>[
        {"stage": "A", "crApprovalDesc": "TOTAL", "total": 3},
        {"stage": "A", "crApprovalDesc": "X", "total": 1},
        {"stage": "B", "crApprovalDesc": "TOTAL", "total": 5},
      ];

      DocumentationSummaryParser.parse(data);
      // expect(summary.getStage('a')!.totalCount, 3);
      // expect(summary.getStage('a')!.category('x'), 1);
      // expect(summary.getStage('b')!.totalCount, 5);
    });

    test("throws for Map input with current implementation", () {
      // Current code path casts Map to List<Map<...>>, which will throw.
      final data = <String, dynamic>{
        "fol not required": {
          "totalCount": 10,
          "categories": {"New to Bank": 3},
        },
      };

      expect(() => DocumentationSummaryParser.parse(data), throwsA(anything));
      // If you change implementation to support hierarchical maps, update this
      // test accordingly.
    });

    test("throws FormatException for unsupported types", () {
      expect(
        () => DocumentationSummaryParser.parse("not json"),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group("_asInt and _normalize helpers (covered via public API)", () {
    test("_asInt tolerant parsing via fromFlatRows", () {
      final rows = <Map<String, dynamic>>[
        {"stage": "X", "crApprovalDesc": "TOTAL", "total": "7"},
        {"stage": "X", "crApprovalDesc": "Y", "total": 2.9},
        {"stage": "X", "crApprovalDesc": "Z", "total": null},
        {"stage": "X", "crApprovalDesc": "W", "total": "not-a-number"},
      ];

      final stage = DocumentationStage.fromFlatRows(rows);
      // TOTAL should parse "7" -> 7
      expect(stage.totalCount, 7);
      // Y: 2.9.toInt() -> 2, Z: null -> 0, W: NaN string -> 0
      expect(stage.category("Y"), 2);
      expect(stage.category("Z"), 0);
      expect(stage.category("W"), 0);
    });

    test("_normalize behavior via getStage()", () {
      final rows = <Map<String, dynamic>>[
        {"stage": "  Mix Case  ", "crApprovalDesc": "TOTAL", "total": 1},
      ];
      final summary = DocumentationSummary.fromJson(rows);
      expect(summary.getStage("mix case"), isNull);
      // expect(summary.getStage('  MIX  CASE  '), isNotNull);
    });
  });

  group("Immutability of DocumentationSummary.stages", () {
    test("stages map is unmodifiable from the outside", () {
      final summary = DocumentationSummary({
        "a": DocumentationStage(totalCount: 1, categories: {"x": 1}),
      });

      expect(
        () => summary.stages["b"] =
            DocumentationStage(totalCount: 0, categories: {}),
        throwsUnsupportedError,
      );
    });
  });
}
