import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/model.dart";
import "package:wcas_frontend/models/request/profitability/relationship_utilization.dart";

class MockRelationshipUtilizationViewModel extends Mock
    implements RelationshipUtilizationViewModel {}

class MockRelationshipUtilization extends Mock
    implements RelationshipUtilization {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RelationshipUtilizationDraftHandler handler;
  late MockRelationshipUtilizationViewModel vm;
  late GlobalKey<FormState> formKey;

  setUp(() {
    handler = RelationshipUtilizationDraftHandler();
    vm = MockRelationshipUtilizationViewModel();
    formKey = GlobalKey<FormState>();

    when(() => vm.formKey).thenReturn(formKey);

    when(() => vm.clean(any<dynamic>())).thenAnswer((invocation) {
      final value = invocation.positionalArguments.first;
      return value?.toString().trim() ?? "";
    });
  });

  group("RelationshipUtilizationDraftHandler.buildDraftData", () {
    testWidgets("calls form save before serializing data", (tester) async {
      String? savedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                initialValue: "saved-from-form",
                onSaved: (value) {
                  savedValue = value;
                },
              ),
            ),
          ),
        ),
      );

      final row = MockRelationshipUtilization();

      when(() => row.clientTurnover).thenReturn(" 1000 ");
      when(() => row.turnoverInCbdCua).thenReturn(" 500 ");
      when(() => row.throughputToCbdPercentage).thenReturn(" 50 ");

      when(() => vm.relationshipUtilizationData).thenReturn(
        <RelationshipUtilization>[row],
      );

      final result = handler.buildDraftData(vm);

      expect(savedValue, "saved-from-form");
      expect(result["relationshipUtilizationData"], hasLength(1));

      verify(() => vm.syncControllersToModel()).called(1);
    });

    test("serializes relationship utilization rows and cleans values", () {
      final firstRow = MockRelationshipUtilization();
      final secondRow = MockRelationshipUtilization();

      when(() => firstRow.clientTurnover).thenReturn(" 1000 ");
      when(() => firstRow.turnoverInCbdCua).thenReturn(" 500 ");
      when(() => firstRow.throughputToCbdPercentage).thenReturn(" 50 ");

      when(() => secondRow.clientTurnover).thenReturn(" 2000 ");
      when(() => secondRow.turnoverInCbdCua).thenReturn(" 1000 ");
      when(() => secondRow.throughputToCbdPercentage).thenReturn(" 50 ");

      when(() => vm.relationshipUtilizationData).thenReturn(
        <RelationshipUtilization>[
          firstRow,
          secondRow,
        ],
      );

      final result = handler.buildDraftData(vm);

      expect(result, contains("relationshipUtilizationData"));

      final rows = result["relationshipUtilizationData"] as List<dynamic>;

      expect(rows, hasLength(2));

      expect(rows[0], <String, dynamic>{
        "clientTurnover": "1000",
        "turnoverInCbdCua": "500",
        "throughputToCbdPercentage": "50",
      });

      expect(rows[1], <String, dynamic>{
        "clientTurnover": "2000",
        "turnoverInCbdCua": "1000",
        "throughputToCbdPercentage": "50",
      });

      verify(() => vm.syncControllersToModel()).called(1);
    });

    test("serializes empty relationship utilization list", () {
      when(() => vm.relationshipUtilizationData)
          .thenReturn(<RelationshipUtilization>[]);

      final result = handler.buildDraftData(vm);

      expect(result, contains("relationshipUtilizationData"));
      expect(result["relationshipUtilizationData"], isEmpty);

      verify(() => vm.syncControllersToModel()).called(1);
    });
  });

  group("RelationshipUtilizationDraftHandler.applyDraft", () {
    test("returns without changes when relationshipUtilizationData key is missing", () {
      when(() => vm.relationshipUtilizationData)
          .thenReturn(<RelationshipUtilization>[]);

      handler.applyDraft(vm, <String, dynamic>{});

      verifyNever(() => vm.initalize());
      verifyNever(() => vm.recalcPercentage(any<int>()));
    });

    test("returns without changes when raw rows is not a list", () {
      when(() => vm.relationshipUtilizationData)
          .thenReturn(<RelationshipUtilization>[]);

      handler.applyDraft(vm, <String, dynamic>{
        "relationshipUtilizationData": <String, dynamic>{
          "clientTurnover": "1000",
        },
      });

      verifyNever(() => vm.initalize());
      verifyNever(() => vm.recalcPercentage(any<int>()));
    });

    test("returns without changes when raw rows list is empty", () {
      when(() => vm.relationshipUtilizationData)
          .thenReturn(<RelationshipUtilization>[]);

      handler.applyDraft(vm, <String, dynamic>{
        "relationshipUtilizationData": <dynamic>[],
      });

      verifyNever(() => vm.initalize());
      verifyNever(() => vm.recalcPercentage(any<int>()));
    });

    test("returns without changes when vm data list is empty", () {
      when(() => vm.relationshipUtilizationData)
          .thenReturn(<RelationshipUtilization>[]);

      handler.applyDraft(vm, <String, dynamic>{
        "relationshipUtilizationData": <dynamic>[
          <String, dynamic>{
            "clientTurnover": "1000",
            "turnoverInCbdCua": "500",
            "throughputToCbdPercentage": "50",
          },
        ],
      });

      verifyNever(() => vm.initalize());
      verifyNever(() => vm.recalcPercentage(any<int>()));
    });

    test("applies draft rows by index and recalculates percentage", () {
      final firstRow = MockRelationshipUtilization();
      final secondRow = MockRelationshipUtilization();

      when(() => vm.relationshipUtilizationData).thenReturn(
        <RelationshipUtilization>[
          firstRow,
          secondRow,
        ],
      );

      handler.applyDraft(vm, <String, dynamic>{
        "relationshipUtilizationData": <dynamic>[
          <String, dynamic>{
            "clientTurnover": "1000",
            "turnoverInCbdCua": "500",
            "throughputToCbdPercentage": "50",
          },
          <String, dynamic>{
            "clientTurnover": "2000",
            "turnoverInCbdCua": "1000",
            "throughputToCbdPercentage": "50",
          },
        ],
      });

      verify(() => firstRow.clientTurnover = "1000").called(1);
      verify(() => firstRow.turnoverInCbdCua = "500").called(1);
      verify(() => firstRow.throughputToCbdPercentage = "50").called(1);

      verify(() => secondRow.clientTurnover = "2000").called(1);
      verify(() => secondRow.turnoverInCbdCua = "1000").called(1);
      verify(() => secondRow.throughputToCbdPercentage = "50").called(1);

      verify(() => vm.initalize()).called(1);
      verify(() => vm.recalcPercentage(0)).called(1);
      verify(() => vm.recalcPercentage(1)).called(1);
    });

    test("applies only min count when draft has more rows than vm data", () {
      final firstRow = MockRelationshipUtilization();

      when(() => vm.relationshipUtilizationData).thenReturn(
        <RelationshipUtilization>[
          firstRow,
        ],
      );

      handler.applyDraft(vm, <String, dynamic>{
        "relationshipUtilizationData": <dynamic>[
          <String, dynamic>{
            "clientTurnover": "1000",
            "turnoverInCbdCua": "500",
            "throughputToCbdPercentage": "50",
          },
          <String, dynamic>{
            "clientTurnover": "9999",
            "turnoverInCbdCua": "9999",
            "throughputToCbdPercentage": "99",
          },
        ],
      });

      verify(() => firstRow.clientTurnover = "1000").called(1);
      verify(() => firstRow.turnoverInCbdCua = "500").called(1);
      verify(() => firstRow.throughputToCbdPercentage = "50").called(1);

      verify(() => vm.initalize()).called(1);
      verify(() => vm.recalcPercentage(0)).called(1);
      verifyNever(() => vm.recalcPercentage(1));
    });

    test("applies only min count when vm has more rows than draft", () {
      final firstRow = MockRelationshipUtilization();
      final secondRow = MockRelationshipUtilization();

      when(() => vm.relationshipUtilizationData).thenReturn(
        <RelationshipUtilization>[
          firstRow,
          secondRow,
        ],
      );

      handler.applyDraft(vm, <String, dynamic>{
        "relationshipUtilizationData": <dynamic>[
          <String, dynamic>{
            "clientTurnover": "1111",
            "turnoverInCbdCua": "2222",
            "throughputToCbdPercentage": "33",
          },
        ],
      });

      verify(() => firstRow.clientTurnover = "1111").called(1);
      verify(() => firstRow.turnoverInCbdCua = "2222").called(1);
      verify(() => firstRow.throughputToCbdPercentage = "33").called(1);

      verifyNever(() => secondRow.clientTurnover = any<String>());
      verifyNever(() => secondRow.turnoverInCbdCua = any<String>());
      verifyNever(() => secondRow.throughputToCbdPercentage = any<String>());

      verify(() => vm.initalize()).called(1);
      verify(() => vm.recalcPercentage(0)).called(1);
      verifyNever(() => vm.recalcPercentage(1));
    });

    test("skips draft row when raw row is not a map", () {
      final firstRow = MockRelationshipUtilization();
      final secondRow = MockRelationshipUtilization();

      when(() => vm.relationshipUtilizationData).thenReturn(
        <RelationshipUtilization>[
          firstRow,
          secondRow,
        ],
      );

      handler.applyDraft(vm, <String, dynamic>{
        "relationshipUtilizationData": <dynamic>[
          "invalid-row",
          <String, dynamic>{
            "clientTurnover": "2000",
            "turnoverInCbdCua": "1000",
            "throughputToCbdPercentage": "50",
          },
        ],
      });

      verifyNever(() => firstRow.clientTurnover = any<String>());
      verifyNever(() => firstRow.turnoverInCbdCua = any<String>());
      verifyNever(() => firstRow.throughputToCbdPercentage = any<String>());

      verify(() => secondRow.clientTurnover = "2000").called(1);
      verify(() => secondRow.turnoverInCbdCua = "1000").called(1);
      verify(() => secondRow.throughputToCbdPercentage = "50").called(1);

      verify(() => vm.initalize()).called(1);

      // recalcPercentage is called for count rows, even if one raw row was skipped.
      verify(() => vm.recalcPercentage(0)).called(1);
      verify(() => vm.recalcPercentage(1)).called(1);
    });

    test("keeps existing turnoverInCbdCua when restored turnover is empty", () {
      final firstRow = MockRelationshipUtilization();

      when(() => firstRow.turnoverInCbdCua).thenReturn("existing-turnover");

      when(() => vm.relationshipUtilizationData).thenReturn(
        <RelationshipUtilization>[
          firstRow,
        ],
      );

      handler.applyDraft(vm, <String, dynamic>{
        "relationshipUtilizationData": <dynamic>[
          <String, dynamic>{
            "clientTurnover": "1000",
            "turnoverInCbdCua": "",
            "throughputToCbdPercentage": "50",
          },
        ],
      });

      verify(() => firstRow.clientTurnover = "1000").called(1);
      verify(() => firstRow.turnoverInCbdCua = "existing-turnover").called(1);
      verify(() => firstRow.throughputToCbdPercentage = "50").called(1);

      verify(() => vm.initalize()).called(1);
      verify(() => vm.recalcPercentage(0)).called(1);
    });

    test("keeps existing turnoverInCbdCua when restored turnover is whitespace", () {
      final firstRow = MockRelationshipUtilization();

      when(() => firstRow.turnoverInCbdCua).thenReturn("old-value");

      when(() => vm.relationshipUtilizationData).thenReturn(
        <RelationshipUtilization>[
          firstRow,
        ],
      );

      handler.applyDraft(vm, <String, dynamic>{
        "relationshipUtilizationData": <dynamic>[
          <String, dynamic>{
            "clientTurnover": "1000",
            "turnoverInCbdCua": "   ",
            "throughputToCbdPercentage": "50",
          },
        ],
      });

      verify(() => firstRow.clientTurnover = "1000").called(1);
      verify(() => firstRow.turnoverInCbdCua = "old-value").called(1);
      verify(() => firstRow.throughputToCbdPercentage = "50").called(1);

      verify(() => vm.initalize()).called(1);
      verify(() => vm.recalcPercentage(0)).called(1);
    });

    test("cleans draft values before applying them", () {
      final firstRow = MockRelationshipUtilization();

      when(() => vm.relationshipUtilizationData).thenReturn(
        <RelationshipUtilization>[
          firstRow,
        ],
      );

      handler.applyDraft(vm, <String, dynamic>{
        "relationshipUtilizationData": <dynamic>[
          <String, dynamic>{
            "clientTurnover": " 1000 ",
            "turnoverInCbdCua": " 500 ",
            "throughputToCbdPercentage": " 50 ",
          },
        ],
      });

      verify(() => firstRow.clientTurnover = "1000").called(1);
      verify(() => firstRow.turnoverInCbdCua = "500").called(1);
      verify(() => firstRow.throughputToCbdPercentage = "50").called(1);

      verify(() => vm.initalize()).called(1);
      verify(() => vm.recalcPercentage(0)).called(1);
    });

    test("cleans null draft values to empty strings", () {
      final firstRow = MockRelationshipUtilization();

      when(() => firstRow.turnoverInCbdCua).thenReturn("fallback-turnover");

      when(() => vm.relationshipUtilizationData).thenReturn(
        <RelationshipUtilization>[
          firstRow,
        ],
      );

      handler.applyDraft(vm, <String, dynamic>{
        "relationshipUtilizationData": <dynamic>[
          <String, dynamic>{
            "clientTurnover": null,
            "turnoverInCbdCua": null,
            "throughputToCbdPercentage": null,
          },
        ],
      });

      verify(() => firstRow.clientTurnover = "").called(1);
      verify(() => firstRow.turnoverInCbdCua = "fallback-turnover").called(1);
      verify(() => firstRow.throughputToCbdPercentage = "").called(1);

      verify(() => vm.initalize()).called(1);
      verify(() => vm.recalcPercentage(0)).called(1);
    });
  });
}
