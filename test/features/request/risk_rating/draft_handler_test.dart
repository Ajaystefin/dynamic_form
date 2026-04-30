import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/features/request/risk_rating/draft_handler.dart";
import "package:wcas_frontend/features/request/risk_rating/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/risk_rating/external_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/internal_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/risk_rating.dart";

void main() {
  late RiskRatingDraftHandler handler;
  late RiskRatingViewModel vm;

  setUp(() {
    handler = RiskRatingDraftHandler();
    vm = RiskRatingViewModel();

    // Reference lists for external rating resolution
    vm.sAndP = [Reference(id: 1)];
    vm.moodys = [Reference(id: 2)];
    vm.fitch = [Reference(id: 3)];
  });

  Future<void> attachForm(
    WidgetTester tester,
    RiskRatingViewModel vm,
  ) async {
    final key = GlobalKey<FormState>();
    vm.formKey = key;

    await tester.pumpWidget(
      MaterialApp(
        home: Form(
          key: key,
          child: const SizedBox(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------

  testWidgets("buildDraftData saves form when mounted", (tester) async {
    await attachForm(tester, vm);

    vm.riskRating = RiskRating(
      internalRatings: [
        InternalRating(
          customerRimNo: 10,
          entityId: 20,
          proposedCRR: 30,
          proposedModel: "IM",
          proposedBasisOfCrr: "Auto",
          internalRatingType: InternalRatingtype.none,
          secondBestRating: "88",
          proposedByCredit: "Yes",
          borrowerGuarantor: "Borrower",
        ),
      ],
      externalRatings: [
        ExternalRating(
          customerRimNo: 10,
          customerName: "ABC",
          sAndP: Reference(id: 1),
          moodys: Reference(id: 2),
          fitch: Reference(id: 3),
        ),
      ],
      comments: "Internal",
      externalComments: "External",
    );

    final draft = handler.buildDraftData(vm);

    expect(draft["comments"], "");
    expect(draft["externalComments"], "");

    final internal = draft["internalRatingList"][0];
    expect(internal["rimNo"], 10);
    expect(internal["entityId"], 20);
    expect(internal["proposedCrr"], 30);
    expect(internal["proposedModel"], "IM");
    expect(internal["internalRatingType"], "none");
    expect(internal["secondBestRating"], "88");

    final external = draft["externalRatingList"][0];
    expect(external["rimNo"], 10);
    expect(external["sAndP"], 1);
    expect(external["moodys"], 2);
    expect(external["fitch"], 3);
  });

  testWidgets("buildDraftData handles null form state safely", (tester) async {
    vm.formKey = GlobalKey<FormState>(); // not mounted

    vm.riskRating = RiskRating(
      internalRatings: [],
      externalRatings: null,
    );

    final draft = handler.buildDraftData(vm);

    expect(draft["internalRatingList"], isEmpty);
    expect(draft["externalRatingList"], isEmpty);
  });

  // ---------------------------------------------------------------------------
  // applyDraft – internal
  // ---------------------------------------------------------------------------

  testWidgets("applyDraft creates internal rating from valid draft",
      (tester) async {
    await attachForm(tester, vm);

    vm.riskRating = RiskRating(internalRatings: []);

    handler.applyDraft(vm, {
      "internalRatingList": [
        {
          "rimNo": "99",
          "entityId": "100",
          "borrowerGuarantor": "G",
          "crr": "1",
          "existingBasisOfCrr": "E",
          "prevRatingSource": "2",
          "prevCrr": "3",
          "proposedModel": "Manual",
          "proposedCrr": "4",
          "proposedBasisOfCrr": "PB",
          "proposedRatingSource": "SRC",
          "detailsOverride": "DO",
          "overrideComment": "OC",
          "cascadeNote": "CN",
          "proposedByCredit": 123,
          "internalRatingType": "override",
          "secondBestRating": "77",
        }
      ],
    });

    final ir = vm.riskRating.internalRatings.single;

    expect(ir.customerRimNo, 99);
    expect(ir.entityId, 100);
    expect(ir.crr, 1);
    expect(ir.previousCRR, 3);
    expect(ir.proposedCRR, 4);
    expect(ir.internalRatingType, InternalRatingtype.override);
    expect(ir.secondBestRating, "77");
  });

  testWidgets("applyDraft ignores invalid internal drafts", (tester) async {
    vm.riskRating = RiskRating(internalRatings: []);

    handler.applyDraft(vm, {
      "internalRatingList": [
        "invalid",
        {"rimNo": null},
      ],
    });

    expect(vm.riskRating.internalRatings, isEmpty);
  });

  testWidgets("applyDraft falls back to InternalRatingtype.none",
      (tester) async {
    vm.riskRating = RiskRating(internalRatings: []);

    handler.applyDraft(vm, {
      "internalRatingList": [
        {"rimNo": 1, "internalRatingType": "invalid"},
      ],
    });

    expect(
      vm.riskRating.internalRatings.first.internalRatingType,
      InternalRatingtype.none,
    );
  });

  // ---------------------------------------------------------------------------
  // applyDraft – external
  // ---------------------------------------------------------------------------

  testWidgets("applyDraft resolves external ratings correctly", (tester) async {
    vm.riskRating = RiskRating(externalRatings: [], internalRatings: []);

    handler.applyDraft(vm, {
      "externalRatingList": [
        {
          "rimNo": "10",
          "customerName": "ABC",
          "sAndP": "1",
          "moodys": "2",
          "fitch": "3",
        }
      ],
    });

    final er = vm.riskRating.externalRatings!.single;

    expect(er.customerRimNo, 10);
    expect(er.customerName, "ABC");
    expect(er.sAndP?.id, 1);
    expect(er.moodys?.id, 2);
    expect(er.fitch?.id, 3);
  });

  testWidgets("applyDraft handles missing reference IDs safely",
      (tester) async {
    vm.riskRating = RiskRating(externalRatings: [], internalRatings: []);

    handler.applyDraft(vm, {
      "externalRatingList": [
        {
          "rimNo": 10,
          "sAndP": 999,
        }
      ],
    });

    final er = vm.riskRating.externalRatings!.single;
    expect(er.sAndP, isNull);
  });

  // ---------------------------------------------------------------------------
  // comments
  // ---------------------------------------------------------------------------

  testWidgets("applyDraft overwrites comments when provided", (tester) async {
    vm.riskRating = RiskRating(comments: "Old", internalRatings: []);

    handler.applyDraft(vm, {"comments": "New"});

    expect(vm.riskRating.comments, "New");
  });

  testWidgets("applyDraft preserves comments when missing", (tester) async {
    vm.riskRating = RiskRating(comments: "Keep", internalRatings: []);

    handler.applyDraft(vm, {});

    expect(vm.riskRating.comments, "Keep");
  });

  // ---------------------------------------------------------------------------
  // helper extensions
  // ---------------------------------------------------------------------------

  test("firstWhereOrNull returns null when not found", () {
    final result = [1, 2, 3].firstWhereOrNull((e) => e == 99);
    expect(result, isNull);
  });

  test("firstOrNull returns null on empty iterable", () {
    expect(<int>[].firstOrNull, isNull);
  });
}
