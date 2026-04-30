import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/model.dart";

import "package:wcas_frontend/models/request/profitability/profitability_summary/profitability_data.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/raroc_info.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/realtionship_profitability.dart";

void main() {
  // - REQUIRED for GlobalKey / FormState / Controllers
  TestWidgetsFlutterBinding.ensureInitialized();

  late RelationshipProfitabilitySummaryDraftHandler handler;

  setUp(() {
    handler = RelationshipProfitabilitySummaryDraftHandler();
  });

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------
  RelationshipProfitabilitySummaryViewModel buildVm() {
    final vm = RelationshipProfitabilitySummaryViewModel();

    vm.formKey = GlobalKey<FormState>();

    // Summary comments
    vm.summaryCommentsController.text = "Summary comment";

    // Prepare data via VM-owned model
    vm.relationshipProfitabilitySummaryData?.relationshipProfitability = [
      RelationshipProfitability(
        comments: "Row comment",
        projectedNext12Months: ProfitabilityData(),
        realizedLastYear: ProfitabilityData(),
      ),
    ];

    vm.relationshipProfitabilitySummaryData?.rarocInformation = [
      RarocInformation(),
    ];

    // Profitability controllers
    vm.getTextController("proj_nii_0").text = "10";
    vm.getTextController("proj_nfi_0").text = "20";
    vm.getTextController("proj_exp_0").text = "30";
    vm.getTextController("proj_casa_0").text = "40";
    vm.getTextController("proj_rwa_0").text = "50";

    vm.getTextController("real_nii_0").text = "1";
    vm.getTextController("real_nfi_0").text = "2";
    vm.getTextController("real_exp_0").text = "3";
    vm.getTextController("real_casa_0").text = "4";
    vm.getTextController("real_rwa_0").text = "5";

    // RAROC controllers
    vm.realizedRarocControllers = [TextEditingController(text: "6")];
    vm.proposedRarocControllers = [TextEditingController(text: "7")];
    vm.finalRarocControllers = [TextEditingController(text: "8")];
    vm.commentsControllers = [TextEditingController(text: "RAROC comment")];

    return vm;
  }

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------
  test("buildDraftData builds summary, profitability and raroc correctly", () {
    final vm = buildVm();

    final data = handler.buildDraftData(vm);

    expect(data["summaryComments"], "Summary comment");

    final profitability = data["relationshipProfitability"] as List;
    expect(profitability.length, 1);

    final row = profitability.first as Map<String, dynamic>;
    expect(row["comments"], "Row comment");
    expect(row["projectedNext12Months"]["nii"], "10");
    expect(row["realizedLastYear"]["rwa"], "5");

    final raroc = data["rarocInformation"] as List;
    expect(raroc.length, 1);
    expect(raroc.first["existingRealizedRarocPercent"], "6");
    expect(raroc.first["comments"], "RAROC comment");
  });

  // ---------------------------------------------------------------------------
  // buildDraftData — empty VM
  // ---------------------------------------------------------------------------
  test("buildDraftData handles empty VM safely", () {
    final vm = RelationshipProfitabilitySummaryViewModel()
      ..formKey = GlobalKey<FormState>();

    final data = handler.buildDraftData(vm);

    expect(data["summaryComments"], "");
    expect(data["relationshipProfitability"], isEmpty);
    expect(data["rarocInformation"], isEmpty);
  });

  // ---------------------------------------------------------------------------
  // applyDraft — profitability restore
  // ---------------------------------------------------------------------------
  test("applyDraft restores profitability data and controllers", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "summaryComments": "Restored summary",
      "relationshipProfitability": [
        {
          "comments": "Updated comment",
          "projectedNext12Months": {
            "nii": "11",
            "nfi": "22",
            "expectedNetIncome": "33",
            "avgCasa": "44",
            "rwa": "55",
          },
          "realizedLastYear": {
            "nii": "1a",
            "nfi": "2a",
            "expectedNetIncome": "3a",
            "avgCasa": "4a",
            "rwa": "5a",
          },
        }
      ],
    });

    final row = vm
        .relationshipProfitabilitySummaryData!.relationshipProfitability!.first;

    expect(row.comments, "Updated comment");
    expect(row.projectedNext12Months!.nii, "11");
    expect(vm.getTextController("proj_nii_0").text, "11");
    expect(vm.getTextController("real_rwa_0").text, "5a");
  });

  // ---------------------------------------------------------------------------
  // applyDraft — RAROC restore
  // ---------------------------------------------------------------------------
  test("applyDraft restores raroc data and controllers", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "rarocInformation": [
        {
          "existingRealizedRarocPercent": "9",
          "proposedRarocPercentProposedByCoverage": "10",
          "proposedFinalRarocPercentExAnteRaroc": "11",
          "comments": "Updated raroc",
        }
      ],
    });

    final raroc =
        vm.relationshipProfitabilitySummaryData!.rarocInformation!.first;

    expect(raroc.existingRealizedRarocPercent, "9");
    expect(vm.realizedRarocControllers!.first.text, "9");
    expect(vm.commentsControllers!.first.text, "Updated raroc");
  });

  // ---------------------------------------------------------------------------
  // applyDraft — defensive paths
  // ---------------------------------------------------------------------------
  test("applyDraft skips non-map draft rows safely", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "relationshipProfitability": ["bad-data"],
    });

    expect(
      vm.relationshipProfitabilitySummaryData!.relationshipProfitability!.first
          .comments,
      "Row comment",
    );
  });

  test("applyDraft ignores extra rows beyond model count", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "relationshipProfitability": [{}, {}],
    });

    expect(
      vm.relationshipProfitabilitySummaryData!.relationshipProfitability!
          .length,
      1,
    );
  });
}
