import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/state.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";

class MockFacilitiesSummaryViewModel extends Mock
    implements FacilitiesSummaryViewModel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      FacilitiesSummaryState(loaderStatus: LoadingStatus.loaded),
    );
  });

  late FacilitySummaryDraftHandler handler;
  late MockFacilitiesSummaryViewModel vm;
  late GlobalKey<FormState> formKey;

  late Facility facility;
  late Map<String, TextEditingController> psNameCtrls;
  late Map<String, TextEditingController> psProposedCtrls;
  late Map<String, TextEditingController> psStandbyNameCtrls;
  late Map<String, TextEditingController> psStandbyProposedCtrls;

  FacilitySummaryList facilityListWith(
    List<FacilitySummaryNew> facilities, {
    required int rimNo,
  }) {
    return FacilitySummaryList(
      rims: [
        RimSummary(
          rimName: "RIM ($rimNo)",
          groups: [
            RimGroup(
              facilityLimits: facilities
                  .map(
                    (item) => FacilityDis(facility: item),
                  )
                  .toList(),
            ),
          ],
        ),
      ],
    );
  }

  void stubCommonDefaults() {
    facility = Facility();

    psNameCtrls = <String, TextEditingController>{};
    psProposedCtrls = <String, TextEditingController>{};
    psStandbyNameCtrls = <String, TextEditingController>{};
    psStandbyProposedCtrls = <String, TextEditingController>{};

    when(() => vm.formKey).thenReturn(formKey);
    when(() => vm.draftFormKey).thenReturn("facilitySummaryForm");

    when(() => vm.state).thenReturn(
      FacilitiesSummaryState(loaderStatus: LoadingStatus.loaded),
    );

    when(() => vm.emit(any())).thenReturn(null);

    when(() => vm.customerFacilities).thenReturn(const []);
    when(() => vm.facility).thenReturn(facility);

    when(() => vm.selectedProductTypeOption).thenReturn(null);

    when(() => vm.psNameCtrls).thenReturn(psNameCtrls);
    when(() => vm.psProposedCtrls).thenReturn(psProposedCtrls);
    when(() => vm.psStandbyNameCtrls).thenReturn(psStandbyNameCtrls);
    when(() => vm.psStandbyProposedCtrls).thenReturn(psStandbyProposedCtrls);

    when(() => vm.headerCurrencyByKey).thenReturn({});
  }

  setUp(() {
    handler = FacilitySummaryDraftHandler();
    vm = MockFacilitiesSummaryViewModel();
    formKey = GlobalKey<FormState>();

    stubCommonDefaults();
  });

  tearDown(() {
    for (final ctrl in psNameCtrls.values) {
      ctrl.dispose();
    }
    for (final ctrl in psProposedCtrls.values) {
      ctrl.dispose();
    }
    for (final ctrl in psStandbyNameCtrls.values) {
      ctrl.dispose();
    }
    for (final ctrl in psStandbyProposedCtrls.values) {
      ctrl.dispose();
    }
  });

  group("FacilitySummaryDraftHandler.resolveDraftKey", () {
    test("returns draftFormKey", () {
      expect(handler.resolveDraftKey(vm), "facilitySummaryForm");
    });
  });

  group("FacilitySummaryDraftHandler.buildDraftData", () {
    testWidgets(
      "saves mounted form and stores edited facilities grouped by RIM",
      (tester) async {
        var saved = false;

        final editedFacility = FacilitySummaryNew(
          facilityId: 10,
          rimNo: 101,
          proposedLimit: 500,
          currency: "AED",
        )..isEdited = true;

        final notEditedFacility = FacilitySummaryNew(
          facilityId: 11,
          rimNo: 101,
          proposedLimit: 700,
          currency: "USD",
        )..isEdited = false;

        final editedWithoutRim = FacilitySummaryNew(
          facilityId: 12,
          proposedLimit: 900,
          currency: "EUR",
        )..isEdited = true;

        when(() => vm.customerFacilities).thenReturn([
          facilityListWith(
            [
              editedFacility,
              notEditedFacility,
              editedWithoutRim,
            ],
            rimNo: 101,
          ),
        ]);

        psNameCtrls["ps_1"] = TextEditingController(text: "Project One");
        psProposedCtrls["ps_1"] = TextEditingController(text: "1000");
        psStandbyNameCtrls["sb_1"] = TextEditingController(text: "Standby One");
        psStandbyProposedCtrls["sb_1"] =
            TextEditingController(text: "2000");

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: TextFormField(
                  initialValue: "dummy",
                  onSaved: (_) {
                    saved = true;
                  },
                ),
              ),
            ),
          ),
        );

        final draft = handler.buildDraftData(vm);

        expect(saved, true);

        final byRim = draft["byRim"] as Map<String, List<Map<String, dynamic>>>;

        expect(byRim.length, 1);
        expect(byRim.containsKey("101"), true);
        expect(byRim["101"]!.length, 1);
        expect(byRim["101"]!.first["facilityId"], 10);
        expect(byRim["101"]!.first["proposedLimit"], 500);
        expect(byRim["101"]!.first["currency"], "AED");

        expect(draft["selectedProductTypeOption"], isNull);
        expect(draft["selectedFacilityType"], isNull);
        expect(draft["selectedFacilityDescription"], isNull);

        expect(draft["psNameCtrls"], {
          "ps_1": "Project One",
        });
        expect(draft["psProposedCtrls"], {
          "ps_1": "1000",
        });
        expect(draft["standbyNameCtrls"], {
          "sb_1": "Standby One",
        });
        expect(draft["standbyProposedCtrls"], {
          "sb_1": "2000",
        });
        expect(draft["headerCurrencyCtrls"], isEmpty);
      },
    );

    test("works when form currentState is null and customerFacilities is null",
        () {
      when(() => vm.customerFacilities).thenReturn(null);

      final draft = handler.buildDraftData(vm);

      expect(draft["byRim"], isEmpty);
      expect(draft["selectedProductTypeOption"], isNull);
      expect(draft["selectedFacilityType"], isNull);
      expect(draft["selectedFacilityDescription"], isNull);
      expect(draft["psNameCtrls"], isEmpty);
      expect(draft["psProposedCtrls"], isEmpty);
      expect(draft["standbyNameCtrls"], isEmpty);
      expect(draft["standbyProposedCtrls"], isEmpty);
      expect(draft["headerCurrencyCtrls"], isEmpty);
    });

    test("skips non-edited facilities", () {
      final item = FacilitySummaryNew(
        facilityId: 20,
        rimNo: 202,
        proposedLimit: 100,
        currency: "AED",
      )..isEdited = false;

      when(() => vm.customerFacilities).thenReturn([
        facilityListWith([item], rimNo: 202),
      ]);

      final draft = handler.buildDraftData(vm);

      expect(draft["byRim"], isEmpty);
    });

    test("skips edited facilities when rimNo is null", () {
      final item = FacilitySummaryNew(
        facilityId: 21,
        proposedLimit: 100,
        currency: "AED",
      )..isEdited = true;

      when(() => vm.customerFacilities).thenReturn([
        facilityListWith([item], rimNo: 101),
      ]);

      final draft = handler.buildDraftData(vm);

      expect(draft["byRim"], isEmpty);
    });
  });

  group("FacilitySummaryDraftHandler.applyDraft", () {
    test("applies draft values to matching facility by RIM", () {
      final item = FacilitySummaryNew(
        facilityId: 20,
        rimNo: 202,
        proposedLimit: 100,
        currency: "AED",
      );

      when(() => vm.customerFacilities).thenReturn([
        facilityListWith([item], rimNo: 202),
      ]);

      handler.applyDraft(vm, {
        "byRim": {
          "202": [
            {
              "facilityId": 20,
              "proposedLimit": 900,
              "currency": "USD",
              "tenorUnit": "Days",
              "tenorValue": 30,
              "index": "LIBOR",
              "marginSign": "+",
              "marginValue": 2,
              "sustainabilityClassification": "11318",
              "projectName": "Project A",
            },
          ],
        },
      });

      expect(item.proposedLimit, 900);
      expect(item.currency, "USD");
      expect(item.tenorUnit, "Days");
      expect(item.tenorValue, 30);
      expect(item.index, "LIBOR");
      expect(item.marginSign, "+");
      expect(item.marginValue, 2);
      expect(item.sustainabilityClassification, "11318");
      expect(item.projectName, "Project A");
      expect(item.isEdited, true);

      verify(() => vm.emit(any())).called(1);
    });

    test("does nothing when byRim is null", () {
      final item = FacilitySummaryNew(
        facilityId: 30,
        rimNo: 303,
        proposedLimit: 100,
        currency: "AED",
      );

      when(() => vm.customerFacilities).thenReturn([
        facilityListWith([item], rimNo: 303),
      ]);

      handler.applyDraft(vm, {});

      expect(item.proposedLimit, 100);
      expect(item.currency, "AED");
      expect(item.isEdited, isNot(true));

      verify(() => vm.emit(any())).called(1);
    });

    test("does nothing when customerFacilities is null", () {
      when(() => vm.customerFacilities).thenReturn(null);

      handler.applyDraft(vm, {
        "byRim": {
          "404": [
            {
              "facilityId": 40,
              "proposedLimit": 1000,
            },
          ],
        },
      });

      verify(() => vm.emit(any())).called(1);
    });

    test("does nothing when facilityId does not match", () {
      final item = FacilitySummaryNew(
        facilityId: 30,
        rimNo: 303,
        proposedLimit: 100,
        currency: "AED",
      );

      when(() => vm.customerFacilities).thenReturn([
        facilityListWith([item], rimNo: 303),
      ]);

      handler.applyDraft(vm, {
        "byRim": {
          "303": [
            {
              "facilityId": 999,
              "proposedLimit": 9999,
              "currency": "USD",
            },
          ],
        },
      });

      expect(item.proposedLimit, 100);
      expect(item.currency, "AED");
      expect(item.isEdited, isNot(true));

      verify(() => vm.emit(any())).called(1);
    });

    test("does nothing when RIM draft is missing", () {
      final item = FacilitySummaryNew(
        facilityId: 40,
        rimNo: 404,
        proposedLimit: 200,
        currency: "AED",
      );

      when(() => vm.customerFacilities).thenReturn([
        facilityListWith([item], rimNo: 404),
      ]);

      handler.applyDraft(vm, {
        "byRim": {
          "999": [
            {
              "facilityId": 40,
              "proposedLimit": 9999,
            },
          ],
        },
      });

      expect(item.proposedLimit, 200);
      expect(item.currency, "AED");
      expect(item.isEdited, isNot(true));

      verify(() => vm.emit(any())).called(1);
    });

    test("does nothing when facility rimNo is null", () {
      final item = FacilitySummaryNew(
        facilityId: 50,
        proposedLimit: 300,
        currency: "AED",
      );

      when(() => vm.customerFacilities).thenReturn([
        facilityListWith([item], rimNo: 101),
      ]);

      handler.applyDraft(vm, {
        "byRim": {
          "101": [
            {
              "facilityId": 50,
              "proposedLimit": 9999,
            },
          ],
        },
      });

      expect(item.proposedLimit, 300);
      expect(item.currency, "AED");
      expect(item.isEdited, isNot(true));

      verify(() => vm.emit(any())).called(1);
    });

    test("restores project specific and standby controllers", () {
      handler.applyDraft(vm, {
        "psNameCtrls": {
          "ps_1": "Project Specific Name",
        },
        "psProposedCtrls": {
          "ps_1": "1500",
        },
        "standbyNameCtrls": {
          "sb_1": "Standby Name",
        },
        "standbyProposedCtrls": {
          "sb_1": "2500",
        },
      });

      expect(psNameCtrls["ps_1"]!.text, "Project Specific Name");
      expect(psProposedCtrls["ps_1"]!.text, "1500");
      expect(psStandbyNameCtrls["sb_1"]!.text, "Standby Name");
      expect(psStandbyProposedCtrls["sb_1"]!.text, "2500");

      verify(() => vm.emit(any())).called(1);
    });

    test("overwrites existing controller values", () {
      psNameCtrls["ps_1"] = TextEditingController(text: "Old PS Name");
      psProposedCtrls["ps_1"] = TextEditingController(text: "Old PS Amount");
      psStandbyNameCtrls["sb_1"] = TextEditingController(text: "Old SB Name");
      psStandbyProposedCtrls["sb_1"] =
          TextEditingController(text: "Old SB Amount");

      handler.applyDraft(vm, {
        "psNameCtrls": {
          "ps_1": "New PS Name",
        },
        "psProposedCtrls": {
          "ps_1": "3000",
        },
        "standbyNameCtrls": {
          "sb_1": "New SB Name",
        },
        "standbyProposedCtrls": {
          "sb_1": "4000",
        },
      });

      expect(psNameCtrls["ps_1"]!.text, "New PS Name");
      expect(psProposedCtrls["ps_1"]!.text, "3000");
      expect(psStandbyNameCtrls["sb_1"]!.text, "New SB Name");
      expect(psStandbyProposedCtrls["sb_1"]!.text, "4000");

      verify(() => vm.emit(any())).called(1);
    });

    test("skips controller restore when controller draft maps are null", () {
      handler.applyDraft(vm, {
        "psNameCtrls": null,
        "psProposedCtrls": null,
        "standbyNameCtrls": null,
        "standbyProposedCtrls": null,
      });

      expect(psNameCtrls, isEmpty);
      expect(psProposedCtrls, isEmpty);
      expect(psStandbyNameCtrls, isEmpty);
      expect(psStandbyProposedCtrls, isEmpty);

      verify(() => vm.emit(any())).called(1);
    });
  });
}
