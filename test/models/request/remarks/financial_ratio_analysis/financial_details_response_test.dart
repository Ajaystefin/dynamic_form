import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_details_response.dart";

void main() {
  group("StatementConst", () {
    test("fromJson parses correctly", () {
      final json = {"id": 101, "value": "Revenue"};
      final sc = StatementConst.fromJson(json);
      expect(sc.id, 101);
      expect(sc.value, "Revenue");
    });

    test("toJson outputs correct map", () {
      final sc = StatementConst(id: 5, value: "NetIncome");
      final out = sc.toJson();
      expect(out, {"id": 5, "value": "NetIncome"});
    });

    test("fromJson throws on wrong types", () {
      final bad = {"id": "oops", "value": 5};
      expect(() => StatementConst.fromJson(bad), throwsA(isA<TypeError>()));
    });
  });

  group("Statement", () {
    test("fromJson parses nested list and date", () {
      final json = {
        "id": 7,
        "date": "2024-03-31T00:00:00.000Z",
        "periods": 4,
        "statementConsts": [
          {"id": 1, "value": "Revenue"},
          {"id": 2, "value": "COGS"},
        ],
      };

      final stmt = Statement.fromJson(json);
      expect(stmt.id, 7);
      expect(stmt.date.toUtc().toIso8601String(), "2024-03-31T00:00:00.000Z");
      expect(stmt.periods, 4);
      expect(stmt.statementConsts.length, 2);
      expect(stmt.statementConsts.first.value, "Revenue");
    });

    test("toJson emits ISO 8601 date and nested list", () {
      final dt = DateTime.parse("2023-12-31T10:15:30.000Z");
      final stmt = Statement(
        id: 9,
        date: dt,
        periods: 1,
        statementConsts: [
          StatementConst(id: 10, value: "OpEx"),
        ],
      );

      final out = stmt.toJson();
      expect(out["id"], 9);
      expect(out["date"], dt.toIso8601String());
      expect(out["periods"], 1);
      expect(out["statementConsts"], [
        {"id": 10, "value": "OpEx"},
      ]);
    });

    test("fromJson with empty statementConsts", () {
      final json = {
        "id": 1,
        "date": "2022-01-01T00:00:00.000Z",
        "periods": 0,
        "statementConsts": [],
      };
      final stmt = Statement.fromJson(json);
      expect(stmt.statementConsts, isEmpty);
      expect(stmt.periods, 0);
    });

    test("fromJson throws on invalid date", () {
      final json = {
        "id": 1,
        "date": "31-12-2024", // invalid ISO for DateTime.parse
        "periods": 2,
        "statementConsts": [],
      };
      expect(() => Statement.fromJson(json), throwsA(isA<FormatException>()));
    });

    test("fromJson throws on wrong types", () {
      final json = {
        "id": "bad",
        "date": 123,
        "periods": "two",
        "statementConsts": "nope",
      };
      expect(() => Statement.fromJson(json), throwsA(isA<TypeError>()));
    });
  });

  group("MacroItem", () {
    test("fromJson parses correctly", () {
      final json = {
        "stmtId": 42,
        "stmtDate": "2025-06-30T00:00:00.000Z",
        "value": "3.14",
      };
      final mi = MacroItem.fromJson(json);
      expect(mi.stmtID, 42);
      expect(mi.stmtDate.toUtc().toIso8601String(), "2025-06-30T00:00:00.000Z");
      expect(mi.value, "3.14");
    });

    test("toJson outputs correct map", () {
      final dt = DateTime.parse("2020-01-01T12:00:00.000Z");
      final mi = MacroItem(stmtID: 1, stmtDate: dt, value: "GDP");
      final out = mi.toJson();
      expect(out, {
        "stmtId": 1,
        "stmtDate": dt.toIso8601String(),
        "value": "GDP",
      });
    });

    test("fromJson throws on invalid date", () {
      final json = {
        "stmtId": 1,
        "stmtDate": "01/01/2020", // invalid for DateTime.parse
        "value": "x",
      };
      expect(() => MacroItem.fromJson(json), throwsA(isA<FormatException>()));
    });

    test("fromJson throws on wrong types", () {
      final json = {
        "stmtId": "bad",
        "stmtDate": 123,
        "value": 99,
      };
      expect(() => MacroItem.fromJson(json), throwsA(isA<TypeError>()));
    });
  });

  group("FinancialDetailsResponse", () {
    test("fromJson parses nested lists and macro map", () {
      final json = {
        "EntityId": 1001,
        "LongName": "Mega Corp International",
        "ShortName": "MegaCorp",
        "statements": [
          {
            "id": 11,
            "date": "2024-09-30T00:00:00.000Z",
            "periods": 4,
            "statementConsts": [
              {"id": 1, "value": "Sales"},
              {"id": 2, "value": "Expenses"},
            ],
          },
        ],
        "macros": {
          "GDP": [
            {
              "stmtId": 11,
              "stmtDate": "2024-09-30T00:00:00.000Z",
              "value": "2.5",
            }
          ],
          "INF": [
            {
              "stmtId": 12,
              "stmtDate": "2024-09-30T00:00:00.000Z",
              "value": "4.1",
            },
            {
              "stmtId": 13,
              "stmtDate": "2024-12-31T00:00:00.000Z",
              "value": "3.9",
            }
          ],
        },
      };

      final res = FinancialDetailsResponse.fromJson(json);

      expect(res.entityId, 1001);
      expect(res.longName, "Mega Corp International");
      expect(res.shortName, "MegaCorp");

      // statements parsed
      expect(res.statements.length, 1);
      expect(res.statements.first.id, 11);
      expect(res.statements.first.statementConsts.length, 2);

      // macros parsed
      expect(res.macros.length, 2);
      expect(res.macros["GDP"], isA<List<MacroItem>>());
      expect(res.macros["GDP"]!.single.value, "2.5");
      expect(res.macros["INF"]!.length, 2);
      expect(res.macros["INF"]!.last.stmtID, 13);
    });

    test("toJson mirrors keys and serializes nested structures", () {
      final stmt = Statement(
        id: 22,
        date: DateTime.parse("2023-06-30T00:00:00.000Z"),
        periods: 2,
        statementConsts: [
          StatementConst(id: 3, value: "GrossProfit"),
        ],
      );
      final macros = <String, List<MacroItem>>{
        "CPI": [
          MacroItem(
            stmtID: 22,
            stmtDate: DateTime.parse("2023-06-30T00:00:00.000Z"),
            value: "5.0",
          ),
        ],
      };

      final res = FinancialDetailsResponse(
        entityId: 55,
        longName: "Beta Inc.",
        shortName: "Beta",
        statements: [stmt],
        macros: macros,
      );

      final out = res.toJson();

      // Case-sensitive keys
      expect(out.containsKey("EntityId"), isTrue);
      expect(out.containsKey("LongName"), isTrue);
      expect(out.containsKey("ShortName"), isTrue);
      expect(out.containsKey("statements"), isTrue);
      expect(out.containsKey("macros"), isTrue);

      expect(out["EntityId"], 55);
      expect(out["LongName"], "Beta Inc.");
      expect(out["ShortName"], "Beta");

      // statements list shape
      expect(out["statements"], [
        {
          "id": 22,
          "date": "2023-06-30T00:00:00.000Z",
          "periods": 2,
          "statementConsts": [
            {"id": 3, "value": "GrossProfit"},
          ],
        }
      ]);

      // macros map shape
      final outMacros = out["macros"] as Map<String, dynamic>;
      expect(outMacros.keys, containsAll(["CPI"]));
      expect(outMacros["CPI"], [
        {
          "stmtId": 22,
          "stmtDate": "2023-06-30T00:00:00.000Z",
          "value": "5.0",
        }
      ]);
    });

    test("fromJson with empty collections", () {
      final json = {
        "EntityId": 1,
        "LongName": "X",
        "ShortName": "X",
        "statements": [],
        "macros": <String, dynamic>{},
      };

      final res = FinancialDetailsResponse.fromJson(json);
      expect(res.statements, isEmpty);
      expect(res.macros, isEmpty);
    });

    test("fromJson throws on wrong macro types", () {
      final json = {
        "EntityId": 1,
        "LongName": "X",
        "ShortName": "X",
        "statements": [],
        "macros": {
          // wrong value type: should be List<dynamic>
          "GDP": {"stmtId": 1},
        },
      };

      // Depending on runtime, this may throw TypeError/CastError
      expect(
        () => FinancialDetailsResponse.fromJson(json),
        throwsA(predicate((e) => e is TypeError)),
      );
    });

    test("fromJson throws on missing required fields", () {
      final jsonMissing = {
        // Missing 'EntityId', 'LongName', 'ShortName'
        "statements": [],
        "macros": {},
      };

      expect(
        () => FinancialDetailsResponse.fromJson(jsonMissing),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group("Round-trip (fromJson -> toJson -> fromJson)", () {
    test("Full object round-trips without data loss", () {
      final source = {
        "EntityId": 999,
        "LongName": "Omega Holdings",
        "ShortName": "Omega",
        "statements": [
          {
            "id": 101,
            "date": "2022-12-31T23:59:59.000Z",
            "periods": 4,
            "statementConsts": [
              {"id": 1, "value": "EBITDA"},
              {"id": 2, "value": "NetIncome"},
            ],
          },
        ],
        "macros": {
          "UNRATE": [
            {
              "stmtId": 101,
              "stmtDate": "2022-12-31T23:59:59.000Z",
              "value": "3.7",
            },
          ],
          "GDP": [],
        },
      };

      final obj1 = FinancialDetailsResponse.fromJson(source);
      final map = obj1.toJson();
      final obj2 = FinancialDetailsResponse.fromJson(map);

      // Field-by-field checks
      expect(obj2.entityId, 999);
      expect(obj2.longName, "Omega Holdings");
      expect(obj2.shortName, "Omega");

      expect(obj2.statements.length, 1);
      expect(obj2.statements.first.id, 101);
      expect(obj2.statements.first.periods, 4);
      expect(obj2.statements.first.statementConsts.length, 2);
      expect(obj2.statements.first.statementConsts.last.value, "NetIncome");

      expect(obj2.macros.keys, containsAll(["UNRATE", "GDP"]));
      expect(obj2.macros["UNRATE"]!.single.value, "3.7");
      expect(obj2.macros["GDP"], isEmpty);
    });
  });
}
