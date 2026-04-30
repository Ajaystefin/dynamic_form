import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix.dart";

// If your Appendix classes are in a specific path, adjust the import
// accordingly.
// The import above assumes you grouped them in appendix.dart per your code
// block.

void main() {
  group("Appendix.toCountryOverviewJson", () {
    test("builds overview JSON with legacy key and correct numeric parsing",
        () {
      final appendix = Appendix(
        countryName: "Utopia",
        rating: "AA",
        populationText: "123456",
        gdpText: "456.78",
        importPartners: ["A", "B"],
        exportPartners: ["X", "Y"],
        strengths: ["Stable", "Innovative"],
        threats: ["Inflation"],
      );

      final json = appendix.toCountryOverviewJson();
      expect(json["countryName"], "Utopia");
      expect(json["popuLation"], 123456); // legacy server key + int parse
      expect(json["gdp"], 456.78); // double parse
      expect(json["rating"], "AA");
      expect(json["importPartners"], ["A", "B"]);
      expect(json["exportPartners"], ["X", "Y"]);
      expect(json["strengths"], ["Stable", "Innovative"]);
      expect(json["threats"], ["Inflation"]);
    });

    test("uses ratingOverride when provided", () {
      final appendix = Appendix(
        countryName: "Utopia",
        rating: "BBB",
        populationText: "0",
        gdpText: "0",
      );
      final json = appendix.toCountryOverviewJson(ratingOverride: "AAA");
      expect(json["rating"], "AAA"); // override wins
    });

    test("defaults to zero for invalid numbers", () {
      final appendix =
          Appendix(populationText: "not-a-number", gdpText: "oops");
      final json = appendix.toCountryOverviewJson();
      expect(json["popuLation"], 0);
      expect(json["gdp"], 0.0);
    });

    test("null optionals -> empty or empty list as per impl", () {
      final appendix = Appendix();
      final json = appendix.toCountryOverviewJson();
      expect(json["countryName"], "");
      expect(json["rating"], "");
      expect(json["importPartners"], isA<List<String>>());
      expect(json["exportPartners"], isA<List<String>>());
      expect(json["strengths"], isA<List<String>>());
      expect(json["threats"], isA<List<String>>());
    });
  });

  group("Appendix.toBusinessSegmentRequestItem", () {
    test(
        "builds payload with required fields and"
        " nested overview under legacy key", () {
      final appendix = Appendix(
        countryName: "Wonderland",
        rating: "A-",
        populationText: "1000",
        gdpText: "123.45",
        strengths: ["Tourism"],
      );

      final created = DateTime.utc(2024, 1, 2, 3, 4, 5);
      final updated = DateTime.utc(2024, 2, 3, 4, 5, 6);

      final json = appendix.toBusinessSegmentRequestItem(
        appRefNo: "APP-1",
        rimNo: 987,
        businessSegement: ServerConstants.corporate,
        customerType: ServerConstants.country,
        appendexRemarks: "ok",
        categoryId: "C1",
        createdBy: "user1",
        createdDate: created,
        updatedBy: "user2",
        updatedDate: updated,
        ratingOverride: "AAA", // ensure override flows to nested overview
      );

      expect(json["appRefNo"], "APP-1");
      expect(json["businessSegment"], ServerConstants.corporate);
      expect(json["customerType"], ServerConstants.country);
      expect(json["rimNo"], 987);
      expect(json["appendexRemarks"], "ok");
      expect(json["categoryId"], "C1");
      expect(json["createdBy"], "user1");
      expect(json["updatedBy"], "user2");

      // ISO8601 UTC formatting
      expect(json["createdDate"], created.toUtc().toIso8601String());
      expect(json["updatedDate"], updated.toUtc().toIso8601String());

      // nested legacy key
      final co = json["countryOverView"] as Map<String, dynamic>;
      expect(co["countryName"], "Wonderland");
      expect(co["rating"], "AAA"); // override applied
      expect(co["popuLation"], 1000);
      expect(co["gdp"], 123.45);
      expect(co["strengths"], ["Tourism"]);
    });

    test("omits optional keys when null", () {
      final appendix = Appendix();
      final json = appendix.toBusinessSegmentRequestItem(
        appRefNo: "APP-2",
        rimNo: 1,
      );
      expect(json.containsKey("appendexRemarks"), false);
      expect(json.containsKey("categoryId"), false);
      expect(json.containsKey("createdBy"), false);
      expect(json.containsKey("createdDate"), false);
      expect(json.containsKey("updatedBy"), false);
      expect(json.containsKey("updatedDate"), false);
    });
  });

  group("Appendix.fromJson / fromCountryOverViewJson / fromFlatJson", () {
    test("fromJson parses clean JSON with lists filtered to strings", () {
      final Map<String, dynamic> json = {
        "countryName": "Atlantis",
        "rating": "BBB",
        "popuLation": 12345,
        "gdp": 78.9,
        "importPartners": ["A", 1, "B"], // non-strings ignored
        "exportPartners": ["X", null, "Y"],
        "strengths": ["Sea"],
        "threats": ["Flood"],
      };

      final model = Appendix.fromJson(json);
      expect(model.countryName, "Atlantis");
      expect(model.rating, "BBB");

      expect(
        model.populationText,
        "",
      ); // current impl keeps it empty when numeric
      expect(model.gdpText, "78.9"); // toString()
      expect(model.importPartners, ["A", "B"]);
      expect(model.exportPartners, ["X", "Y"]);
      expect(model.strengths, ["Sea"]);
      expect(model.threats, ["Flood"]);
    });

    test("fromCountryOverViewJson delegates to fromJson", () {
      final Map<String, dynamic> json = {
        "countryName": "Narnia",
        "popuLation": "999",
      };
      final model = Appendix.fromCountryOverViewJson(json);
      expect(model.countryName, "Narnia");
      expect(model.populationText, ""); // current impl keeps it empty
    });
    test("fromFlatJson prefers nested legacy key when present", () {
      final Map<String, dynamic> flat = {
        "countryName": "Outer", // should be ignored in favor of nested
        "countryOverView": {
          "countryName": "Inner",
          "popuLation": 111,
          "rating": "A",
        },
      };
      final model = Appendix.fromFlatJson(flat);
      expect(model.countryName, "Inner");
      expect(
        model.populationText,
        "",
      );
    });

    test("fromFlatJson falls back to flat when no nested", () {
      final Map<String, dynamic> flat = {
        "countryName": "Flatland",
        "popuLation": 222,
      };
      final model = Appendix.fromFlatJson(flat);
      expect(model.countryName, "Flatland");

      expect(
        model.populationText,
        "",
      ); // current impl keeps it empty when numeric
    });
  });

  group("AppendixFiExtract.fromApiResponse", () {
    test("parses list payloads", () {
      final Map<String, dynamic> body = {
        "responseData": <Map<String, dynamic>>[
          {
            "rimNo": 5,
            "appRefNo": "A1",
            "keyInformation": {"k": "v"},
            "balanceSheet": [
              {"b": 1},
            ],
            "liabilities": [
              {"l": 2},
            ],
            "incomeStatement": {"i": 3},
            "capitaladequacy": [
              {"c": 4},
            ],
            "assetquality": [
              {"a": 5},
            ],
            "liguidityandfunding": [
              {"f": 6},
            ],
            "earnings": [
              {"e": 7},
            ],
          },
        ],
      };

      final extract = AppendixFiExtract.fromApiResponse(body);
      expect(extract.isNotEmpty, true);
      expect(extract.items.length, 1);

      final item = extract.items.first;
      expect(item.rimNo, 5);
      expect(item.appRefNo, "A1");
      expect(item.keyInformation, {"k": "v"});
      expect(item.balanceSheet, [
        {"b": 1},
      ]);
      expect(item.liabilities, [
        {"l": 2},
      ]);
      expect(item.incomeStatement, {"i": 3});
      expect(item.capitalAdequacy, [
        {"c": 4},
      ]);
      expect(item.assetQuality, [
        {"a": 5},
      ]);
      expect(item.liquidityAndFunding, [
        {"f": 6},
      ]);
      expect(item.earnings, [
        {"e": 7},
      ]);
    });

    test("parses single map payload", () {
      final Map<String, dynamic> body = {
        "responseData": <String, dynamic>{
          "rimNo": "10",
          "appRefNo": "A2",
        },
      };

      final extract = AppendixFiExtract.fromApiResponse(body);
      expect(extract.items.length, 1);
      expect(extract.items.first.rimNo, 10); // string -> int
      expect(extract.items.first.appRefNo, "A2");
    });

    test("returns empty for invalid payload", () {
      final Map<String, dynamic> body = {"responseData": null};
      final extract = AppendixFiExtract.fromApiResponse(body);
      expect(extract.isEmpty, true);
    });
  });

  group("AppendixFiItem.fromJson", () {
    test("casts lists of maps and supports mixed types", () {
      final Map<String, dynamic> json = {
        "rimNo": "123",
        "appRefNo": 456, // -> "456"
        "keyInformation": {"ok": true},
        "balanceSheet": [
          {"x": 1},
          42, // ignored
          null, // ignored
        ],
        "liabilities": [
          {"y": 2},
        ],
        "incomeStatement": {"rev": 100},
        "capitaladequacy": [
          {"c1": 1},
        ],
        "assetquality": [
          {"a1": 1},
        ],
        "liguidityandfunding": [
          {"l1": 1},
        ],
        "earnings": [
          {"e1": 1},
        ],
      };

      final item = AppendixFiItem.fromJson(json);
      expect(item.rimNo, 123);
      expect(item.appRefNo, "456");
      expect(item.keyInformation, {"ok": true});
      expect(item.balanceSheet, [
        {"x": 1},
      ]);
      expect(item.liabilities, [
        {"y": 2},
      ]);
      expect(item.incomeStatement, {"rev": 100});
      expect(item.capitalAdequacy, [
        {"c1": 1},
      ]);
      expect(item.assetQuality, [
        {"a1": 1},
      ]);
      expect(item.liquidityAndFunding, [
        {"l1": 1},
      ]);
      expect(item.earnings, [
        {"e1": 1},
      ]);
    });

    test("defaults rimNo to 0 when not parseable", () {
      final Map<String, dynamic> json = {
        "rimNo": "not-a-number",
        "appRefNo": "",
      };
      final item = AppendixFiItem.fromJson(json);
      expect(item.rimNo, 0);
    });

    test("null nested maps/lists become null or empty per impl", () {
      final Map<String, dynamic> json = {
        "rimNo": 1,
        "appRefNo": "A",
        "keyInformation": null,
        "balanceSheet": null,
        "liabilities": null,
        "incomeStatement": null,
        "capitaladequacy": null,
        "assetquality": null,
        "liguidityandfunding": null,
        "earnings": null,
      };
      final item = AppendixFiItem.fromJson(json);
      expect(item.keyInformation, isNull);
      expect(item.balanceSheet, isEmpty);
      expect(item.liabilities, isEmpty);
      expect(item.incomeStatement, isNull);
      expect(item.capitalAdequacy, isEmpty);
      expect(item.assetQuality, isEmpty);
      expect(item.liquidityAndFunding, isEmpty);
      expect(item.earnings, isEmpty);
    });
  });

  group("FiAppendixXlsxRow.fromJson", () {
    test("parses int fields and stringifies appRefNo", () {
      final Map<String, dynamic> json = {
        "rimNo": 77,
        "appRefNo": 123, // -> "123"
        "fileNames": ["a.xlsx"],
        "appendixXlsxID": 9,
      };
      final row = FiAppendixXlsxRow.fromJson(json);
      expect(row.rimNo, 77);
      expect(row.appRefNo, "123");
      expect(row.fileNames, ["a.xlsx"]);
      expect(row.appendixXlsxId, 9);
    });

    test("supports rimNo as string and null appendixXlsxID when non-int", () {
      final Map<String, dynamic> json = {
        "rimNo": "88",
        "appRefNo": "A-REF",
        "appendixXlsxID": "not-int",
      };
      final row = FiAppendixXlsxRow.fromJson(json);
      expect(row.rimNo, 88);
      expect(row.appRefNo, "A-REF");
      expect(row.appendixXlsxId, isNull);
    });
  });

  group("FiAppendixXlsxResponse.fromResponseData", () {
    test("parses list shape", () {
      final raw = <Map<String, dynamic>>[
        {"rimNo": 1, "appRefNo": "A"},
        {"rimNo": 2, "appRefNo": "B"},
      ];

      final resp = FiAppendixXlsxResponse.fromResponseData(raw);
      expect(resp.rows.length, 2);
      expect(resp.rows[0].rimNo, 1);
      expect(resp.rows[1].rimNo, 2);
    });

    test("parses single map shape", () {
      final raw = <String, dynamic>{"rimNo": "3", "appRefNo": "C"};
      final resp = FiAppendixXlsxResponse.fromResponseData(raw);
      expect(resp.rows.length, 1);
      expect(resp.rows.first.rimNo, 3);
      expect(resp.rows.first.appRefNo, "C");
    });

    test("returns empty rows for invalid shape", () {
      final resp = FiAppendixXlsxResponse.fromResponseData(null);
      expect(resp.rows, isEmpty);
    });
  });
}
