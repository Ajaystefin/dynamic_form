import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/utils/utils.dart";

import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/state.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";

// -----------------------------------------------------------------------------
// Mock ViewModel
// -----------------------------------------------------------------------------
class MockFacilitiesSummaryViewModel extends Mock
    implements FacilitiesSummaryViewModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      FacilitiesSummaryState(loaderStatus: LoadingStatus.loaded),
    );
  });

  TestWidgetsFlutterBinding.ensureInitialized();

  late FacilitySummaryDraftHandler handler;
  late MockFacilitiesSummaryViewModel vm;
  late GlobalKey<FormState> formKey;

  setUp(() {
    handler = FacilitySummaryDraftHandler();
    vm = MockFacilitiesSummaryViewModel();
    formKey = GlobalKey<FormState>();

    when(() => vm.formKey).thenReturn(formKey);
    when(() => vm.draftFormKey).thenReturn("facilitySummaryForm");
    when(() => vm.emit(any())).thenReturn(null);
    when(() => vm.state).thenReturn(
      FacilitiesSummaryState(loaderStatus: LoadingStatus.loaded),
    );
  });

  // ---------------------------------------------------------------------------
  // resolveDraftKey
  // ---------------------------------------------------------------------------

  test("resolveDraftKey returns draftFormKey", () {
    final key = handler.resolveDraftKey(vm);
    expect(key, "facilitySummaryForm");
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------

  // test('buildDraftData stores edited facilities grouped by RIM', () {
  //   final facility = FacilitySummaryNew(
  //     facilityId: 10,
  //     rimNo: 101,
  //     proposedLimit: 500,
  //     currency: 'AED',
  //   )..isEdited = true;

  //   final list = FacilitySummaryList(
  //     rims: [
  //       RimSummary(
  //         rimName: 'RIM (101)',
  //         groups: [
  //           RimGroup(
  //             facilityLimits: [
  //               FacilityDis(facility: facility),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ],
  //   );

  //   when(() => vm.customerFacilities).thenReturn([list]);

  //   final draft = handler.buildDraftData(vm);

  //   expect(draft.containsKey('byRim'), true);
  //   final byRim = draft['byRim'] as Map;

  //   expect(byRim.containsKey('101'), true);
  //   expect((byRim['101'] as List).length, 1);

  //   final saved = (byRim['101'] as List).first as Map<String, dynamic>;
  //   expect(saved['facilityId'], 10);
  //   expect(saved['proposedLimit'], 500);
  //   expect(saved['currency'], 'AED');
  // });

  // ---------------------------------------------------------------------------
  // applyDraft — happy path
  // ---------------------------------------------------------------------------

  test("applyDraft applies draft values to matching facility by RIM", () {
    final facility = FacilitySummaryNew(
      facilityId: 20,
      rimNo: 202,
    );

    final list = FacilitySummaryList(
      rims: [
        RimSummary(
          rimName: "RIM (202)",
          groups: [
            RimGroup(
              facilityLimits: [
                FacilityDis(facility: facility),
              ],
            ),
          ],
        ),
      ],
    );

    when(() => vm.customerFacilities).thenReturn([list]);

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
          }
        ],
      },
    });

    expect(facility.proposedLimit, 900);
    expect(facility.currency, "USD");
    expect(facility.tenorUnit, "Days");
    expect(facility.tenorValue, 30);
    expect(facility.index, "LIBOR");
    expect(facility.marginSign, "+");
    expect(facility.marginValue, 2);
    expect(facility.projectName, "Project A");
    expect(facility.isEdited, true);
  });

  // ---------------------------------------------------------------------------
  // applyDraft — safe path (no matching facilityId)
  // ---------------------------------------------------------------------------

  test("applyDraft does nothing when facilityId does not match", () {
    final facility = FacilitySummaryNew(
      facilityId: 30,
      rimNo: 303,
      proposedLimit: 100,
    );

    final list = FacilitySummaryList(
      rims: [
        RimSummary(
          rimName: "RIM (303)",
          groups: [
            RimGroup(
              facilityLimits: [
                FacilityDis(facility: facility),
              ],
            ),
          ],
        ),
      ],
    );

    when(() => vm.customerFacilities).thenReturn([list]);

    handler.applyDraft(vm, {
      "byRim": {
        "303": [
          {
            "facilityId": 999, // mismatch
            "proposedLimit": 9999,
          }
        ],
      },
    });

    // unchanged
    expect(facility.proposedLimit, 100);
    expect(facility.isEdited, isNot(true));
  });
}
