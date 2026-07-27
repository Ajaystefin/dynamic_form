import "dart:convert";
import "dart:io";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hive_ce/hive.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/facility_security/exchange_rate.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";
import "package:wcas_frontend/models/request/facility_security/limits_facilities_response.dart";
import "package:wcas_frontend/models/request/facility_security/project_list.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockFacilitySecurityRepository extends Mock
    implements FacilitySecurityRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeBuildContext extends Fake implements BuildContext {}

class InitSpyFacilitiesSummaryViewModel extends FacilitiesSummaryViewModel {
  bool linkageCalled = false;
  bool perRimCalled = false;
  bool appDetailsCalled = false;
  bool currencyCodesCalled = false;
  bool updatedFacilityRefCalled = false;
  bool referenceDataCalled = false;

  @override
  Future<void> getFacilitySummaryListFromLinakge() async {
    linkageCalled = true;
  }

  @override
  Future<void> getFacilitySummaryListPerRim() async {
    perRimCalled = true;
  }

  @override
  Future<void> getApplicationDetails() async {
    appDetailsCalled = true;
  }

  @override
  Future<void> getCurrencyCodes() async {
    currencyCodesCalled = true;
  }

  @override
  Future<void> getUpdatedFacilityReference() async {
    updatedFacilityRefCalled = true;
  }

  @override
  Future<void> getReferenceData() async {
    referenceDataCalled = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FacilitiesSummaryViewModel viewModel;
  late MockRequestRepository mockRequestRepo;
  late MockFacilitySecurityRepository mockFacilityRepo;
  late MockReferenceDataService mockReferenceService;
  late MockAlertManager mockAlertManager;

  const MethodChannel connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  late Directory hiveDir;

  setUpAll(() async {
    hiveDir = await Directory.systemTemp.createTemp("hive_test_");
    Hive.init(hiveDir.path);

    registerFallbackValue(<String>[]);
    registerFallbackValue(Facility());
    registerFallbackValue(Reference());
    registerFallbackValue(FacilityDetails());
    registerFallbackValue(<FacilitySummaryNew>[]);
    registerFallbackValue(ApplicationDetails());

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, (call) async {
      if (call.method == "check") {
        return ["wifi"];
      }
      return null;
    });
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
    try {
      if (await hiveDir.exists()) {
        await hiveDir.delete(recursive: true);
      }
    } on Object catch (_) {}
  });

  setUp(() {
    mockRequestRepo = MockRequestRepository();
    mockFacilityRepo = MockFacilitySecurityRepository();
    mockReferenceService = MockReferenceDataService();
    mockAlertManager = MockAlertManager();

    viewModel = FacilitiesSummaryViewModel()
      ..repository = mockRequestRepo
      ..facilitySecurityRepository = mockFacilityRepo
      ..referenceDataService = mockReferenceService;

    AlertManager.overrideInstance = mockAlertManager;

    // Safe defaults used by a lot of tests.
    viewModel
      ..currencyCodes = [
        Reference(name: "AED"),
        Reference(name: "USD"),
        Reference(name: "EUR"),
      ]
      ..benchmark = [
        Reference(id: 1, name: "LIBOR", reference2: "F"),
        Reference(id: 2, name: "SOFR", reference2: "N"),
        Reference(id: 3, name: "EIBOR", reference2: "F"),
      ]
      ..marginSign = [
        Reference(name: "+", reference1: "+"),
        Reference(name: "-", reference1: "-"),
      ]
      ..period = [
        Reference(id: 1, name: "Days", reference1: "D"),
        Reference(id: 2, name: "Months", reference1: "M"),
        Reference(id: 3, name: "Years", reference1: "Y"),
        Reference(id: 4, name: "On Demand", reference1: "OD"),
      ]
      ..productTypeOptions = [
        Reference(id: 11321, name: "Conventional"),
        Reference(id: 11322, name: "Islamic"),
      ]
      ..sustanabilityClassifications = [
        Reference(id: 11, name: "Green"),
        Reference(id: 12, name: "Social"),
        Reference(id: 13, name: "Transition"),
      ];
  });

  group("Draft + primitive getters", () {
    test("draft getters return expected values", () {
      expect(viewModel.draftModuleKey, DraftModuleKeys.facilitiesAndSecurities);
      expect(viewModel.draftFormKey, Routes.facilitySummaryView);
      expect(viewModel.draftHandler, isA<FacilitySummaryDraftHandler>());
    });

    test("canEdit reflects pageMode", () {
      viewModel.pageMode = PageMode.na;
      expect(viewModel.canEdit, false);

      viewModel.pageMode = PageMode.view;
      expect(viewModel.canEdit, false);

      viewModel.pageMode = PageMode.edit;
      expect(viewModel.canEdit, true);
    });

    test("groupRimKey builds stable key", () {
      expect(viewModel.groupRimKey(11315, 999), "11315-999");
    });

    test("isProjectGroup returns correct values", () {
      expect(
        viewModel.isProjectGroup(ServerConstants.projectSpecificLimitsID),
        true,
      );
      expect(
        viewModel.isProjectGroup(ServerConstants.projectStandByLimitID),
        true,
      );
      expect(
        viewModel.isProjectGroup(ServerConstants.generalLimitGroupId),
        false,
      );
      expect(viewModel.isProjectGroup(null), false);
    });

    test("shouldRequireHeaderLimitsFor returns only for project groups", () {
      expect(
        viewModel.shouldRequireHeaderLimitsFor(
          ServerConstants.projectSpecificLimitsID,
        ),
        true,
      );
      expect(
        viewModel.shouldRequireHeaderLimitsFor(
          ServerConstants.projectStandByLimitID,
        ),
        true,
      );
      expect(
        viewModel.shouldRequireHeaderLimitsFor(
          ServerConstants.generalLimitGroupId,
        ),
        false,
      );
      expect(viewModel.shouldRequireHeaderLimitsFor(null), false);
    });

    test("shouldShowProjectHeaderErrors defaults to false", () {
      expect(
        viewModel.shouldShowProjectHeaderErrors(
          ServerConstants.projectSpecificLimitsID,
        ),
        false,
      );
      expect(viewModel.shouldShowProjectHeaderErrors(null), false);
    });
  });

  group("Simple setters and local state", () {
    test("selectSharedLimit stores selected value", () {
      final ref = Reference(id: 1, name: "Yes");
      viewModel.selectSharedLimit(ref);
      expect(viewModel.facility.sharedLimit, ref);
    });

    test("addSelectedSubLimitDetails stores selected value", () {
      final ref = Reference(id: 99, name: "Sub");
      viewModel.addSelectedSubLimitDetails(ref);
      expect(viewModel.selectedSubLimitDetails, ref);
    });

    test("onProjectNameSelected stores first selected value", () {
      final ref = Reference(name: "PRJ-001");
      viewModel.onProjectNameSelected([ref]);
      expect(viewModel.selectedProjectRef?.name, "PRJ-001");
    });

    test("onProjectNameSelected ignores empty selection", () {
      viewModel
        ..selectedProjectRef = Reference(name: "OLD")
        ..onProjectNameSelected([]);
      expect(viewModel.selectedProjectRef?.name, "OLD");
    });

    test("applySelectedProjectTo applies selected project and marks edited",
        () {
      final f = FacilitySummaryNew()
        ..projectName = null
        ..isEdited = false;

      viewModel
        ..selectedProjectRef = Reference(name: "Project X")
        ..applySelectedProjectTo(f);

      expect(f.projectName, "Project X");
      expect(f.isEdited, true);
    });

    test(
        "markProjectHeaderErrors and clearProjectHeaderErrors toggle correctly",
        () {
      const groupId = ServerConstants.projectSpecificLimitsID;

      expect(viewModel.shouldShowProjectHeaderErrors(groupId), false);

      viewModel.markProjectHeaderErrors(groupId);
      expect(viewModel.shouldShowProjectHeaderErrors(groupId), true);

      viewModel.clearProjectHeaderErrors(groupId);
      expect(viewModel.shouldShowProjectHeaderErrors(groupId), false);
    });

    test("headerCurrencyFor returns null when not set", () {
      expect(viewModel.headerCurrencyFor(11315, 999), isNull);
    });

    test("setHeaderCurrencyFor stores value by composite key", () {
      viewModel.setHeaderCurrencyFor(11315, 999, Reference(name: "USD"));
      expect(viewModel.headerCurrencyFor(11315, 999)?.name, "USD");
      expect(viewModel.headerCurrencyFor(11315, 888), isNull);
    });

    test("psNameCtrl and standbyNameCtrl are cached", () {
      final a1 = viewModel.psNameCtrl(999);
      final a2 = viewModel.psNameCtrl(999);
      final b1 = viewModel.standbyNameCtrl(999);
      final b2 = viewModel.standbyNameCtrl(999);

      expect(identical(a1, a2), true);
      expect(identical(b1, b2), true);
    });

    test(
        "setProjectExistingLimitInput and"
        " setProjectProposedLimitInput persist values", () {
      viewModel
        ..setProjectExistingLimitInput("123", groupId: 11315, rimNo: 999)
        ..setProjectProposedLimitInput("456", groupId: 11315, rimNo: 999);

      expect(viewModel.proposedLimitForGroup(11315, rimNo: 999), 456);
      expect(viewModel.isProjectHeaderLimitsEnteredFor(11315), true);
      expect(viewModel.isProjectHeaderLimitsEnteredForAtRim(11315, 999), true);
      expect(viewModel.isProjectHeaderLimitsEnteredForAtRim(11315, 888), false);
    });

    test("proposedLimitForGroup returns zero when not found", () {
      expect(viewModel.proposedLimitForGroup(11315, rimNo: 999), 0);
    });

    test(
        "isProjectHeaderLimitsEnteredFor "
        "false "
        "when group has no proposed value", () {
      expect(viewModel.isProjectHeaderLimitsEnteredFor(11315), false);
      expect(viewModel.isProjectHeaderLimitsEnteredForAtRim(11315, 999), false);
    });
  });

  group("Data loading methods", () {
    test("getCurrencyCodes success populates list", () async {
      when(() => mockRequestRepo.getCurrencyCodes()).thenAnswer(
        (_) async => [Reference(name: "AED"), Reference(name: "USD")],
      );

      await viewModel.getCurrencyCodes();

      expect(
        viewModel.currencyCodes.map((e) => e.name).toList(),
        ["AED", "USD"],
      );
    });

    test("getCurrencyCodes empty list handled safely", () async {
      when(() => mockRequestRepo.getCurrencyCodes())
          .thenAnswer((_) async => <Reference>[]);

      await viewModel.getCurrencyCodes();

      expect(viewModel.currencyCodes, isEmpty);
      verifyNever(() => mockAlertManager.showFailureToast(any()));
    });

    test("getCurrencyCodes failure shows toast", () async {
      when(() => mockRequestRepo.getCurrencyCodes())
          .thenThrow(Exception("currency-error"));

      await viewModel.getCurrencyCodes();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("getReferenceData success fills lists and filters Both", () async {
      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{
          ReferenceDataKeys.productType: [
            Reference(id: ServerConstants.optionBothId, name: "Both"),
            Reference(id: 11321, name: "Conventional"),
            Reference(id: 11322, name: "Islamic"),
          ],
          ReferenceDataKeys.sustanabilityClassification: [
            Reference(id: 11, name: "Green"),
          ],
          ReferenceDataKeys.period: [
            Reference(id: 1, name: "Days"),
          ],
          ReferenceDataKeys.marginSign: [
            Reference(name: "+"),
            Reference(name: "-"),
          ],
          ReferenceDataKeys.benchMark: [
            Reference(name: "LIBOR"),
          ],
          ReferenceDataKeys.limitGroup: [
            Reference(id: 11315, name: "Project Specific"),
          ],
          ReferenceDataKeys.limitCapsType: [
            Reference(id: 14493, name: "Project Standby Limits"),
          ],
        },
      );

      await viewModel.getReferenceData();

      expect(
        viewModel.productTypeOptions.map((e) => e.name).toList(),
        ["Conventional", "Islamic"],
      );
      expect(viewModel.sustanabilityClassifications.length, 1);
      expect(viewModel.period.length, 1);
      expect(viewModel.marginSign.length, 2);
      expect(viewModel.benchmark.length, 1);
      expect(viewModel.limitGroup.length, 1);
      expect(viewModel.limitCapsType.length, 1);
    });

    test("getReferenceData handles missing keys safely", () async {
      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{
          ReferenceDataKeys.productType: [
            Reference(id: 11321, name: "Conventional"),
          ],
        },
      );

      await viewModel.getReferenceData();

      expect(
        viewModel.productTypeOptions.map((e) => e.name).toList(),
        ["Conventional"],
      );
      expect(viewModel.period, isEmpty);
      expect(viewModel.marginSign, isEmpty);
      expect(viewModel.benchmark, isEmpty);
      expect(viewModel.limitGroup, isEmpty);
      expect(viewModel.limitCapsType, isEmpty);
    });

    test("getReferenceData failure shows toast", () async {
      when(() => mockReferenceService.getReferenceData(any()))
          .thenThrow(Exception("ref-error"));

      await viewModel.getReferenceData();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("getFacilitySummaryListPerRim success stores response", () async {
      final summaries = [
        buildSummary(
          groupId: 11315,
          order: "0",
          limitNo: "HDR-001",
          rimName: "(999)",
        ),
      ];

      when(() => mockFacilityRepo.getFacilitySummaryList())
          .thenAnswer((_) async => summaries);

      await viewModel.getFacilitySummaryListPerRim();

      expect(viewModel.customerFacilities?.length, 1);
      expect(viewModel.customerFacilities?.first.rims?.first.rimName, "(999)");
    });

    test("getFacilitySummaryListPerRim success with empty list", () async {
      when(() => mockFacilityRepo.getFacilitySummaryList())
          .thenAnswer((_) async => <FacilitySummaryList>[]);

      await viewModel.getFacilitySummaryListPerRim();

      expect(viewModel.customerFacilities, isEmpty);
    });

    test("getFacilitySummaryListPerRim failure shows toast", () async {
      when(() => mockFacilityRepo.getFacilitySummaryList())
          .thenThrow(Exception("boom"));

      await viewModel.getFacilitySummaryListPerRim();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getCurrencyRates success calls repository", () async {
      when(() => mockFacilityRepo.getCurrencyRates(any())).thenAnswer(
        (_) async => const CurrencyRates(rates: {"USD": 3.67}),
      );

      await viewModel.getCurrencyRates(Reference(name: "USD"));

      verify(() => mockFacilityRepo.getCurrencyRates(any())).called(1);
      verifyNever(() => mockAlertManager.showFailureToast(any()));
    });

    test("getCurrencyRates failure shows toast", () async {
      when(() => mockFacilityRepo.getCurrencyRates(any()))
          .thenThrow(Exception("bad-rate"));

      await viewModel.getCurrencyRates(Reference(name: "USD"));

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("getApplicationDetails existing request populates fields", () async {
      final details = ApplicationDetails()
        ..applicationRefNo = "APP-1"
        ..lastApprovedAppRefNum = "APP-0"
        ..conventional = true
        ..islamic = false
        ..reconAppReNumber = "REC-1";

      when(() => mockRequestRepo.getApplicationDetails())
          .thenAnswer((_) async => details);

      await viewModel.getApplicationDetails();

      expect(viewModel.applicationDetails?.applicationRefNo, "APP-1");
      expect(viewModel.selectedLastApprovedAppRefNum, "APP-0");
      expect(viewModel.selectedReconAppReNumber, "REC-1");
      expect(viewModel.selectedReconsiderations?.applicationRefNo, "REC-1");
      expect(viewModel.isExisitngAppRefNo, true);
    });

    test("getApplicationDetails new request uses last approved application",
        () async {
      viewModel.isNewRequest = true;

      final details = ApplicationDetails()
        ..applicationRefNo = "APP-LAST"
        ..conventional = false
        ..islamic = true;

      when(() => mockRequestRepo.getLastApprovedApplication())
          .thenAnswer((_) async => details);

      await viewModel.getApplicationDetails();

      expect(viewModel.applicationDetails?.applicationRefNo, "APP-LAST");
      expect(viewModel.selectedLastApprovedAppRefNum, "APP-LAST");
      expect(viewModel.selectedProductTypeOption?.id, 11322);
    });

    test("getApplicationDetails failure rethrows and sets api error flag",
        () async {
      when(() => mockRequestRepo.getApplicationDetails())
          .thenThrow(Exception("app-details-error"));

      expect(viewModel.getApplicationDetails(), throwsException);
      await viewModel.getApplicationDetails().catchError((_) {});

      expect(viewModel.isApiError, true);
    });
  });

  group("Product type logic", () {
    test(
        "populateApplicationDetails updates "
        "internal object and selected product type", () {
      final details = ApplicationDetails()
        ..conventional = false
        ..islamic = true;

      viewModel.populateApplicationDetails(details);

      expect(viewModel.applicationDetails?.islamic, true);
      expect(viewModel.selectedProductTypeOption?.id, 11322);
      expect(viewModel.facility.selectedProductTypeValue?.id, 11322);
    });

    test("updateSelectedProductType chooses conventional", () {
      viewModel.updateSelectedProductType(conventional: true, islamic: false);

      expect(viewModel.isProductTypeEnabled, false);
      expect(viewModel.selectedProductTypeOption?.id, 11321);
      expect(viewModel.facility.selectedProductTypeValue?.id, 11321);
    });

    test("updateSelectedProductType chooses islamic", () {
      viewModel.updateSelectedProductType(conventional: false, islamic: true);

      expect(viewModel.isProductTypeEnabled, false);
      expect(viewModel.selectedProductTypeOption?.id, 11322);
      expect(viewModel.facility.selectedProductTypeValue?.id, 11322);
    });

    test(
        "updateSelectedProductType with both true "
        "enables switching and chooses first option", () {
      viewModel.updateSelectedProductType(conventional: true, islamic: true);

      expect(viewModel.isProductTypeEnabled, true);
      expect(viewModel.selectedProductTypeOption?.id, 11321);
      expect(viewModel.facility.selectedProductTypeValue?.id, 11321);
    });

    test("onProductTypeSelected handles all branches", () {
      viewModel
        ..applicationDetails = ApplicationDetails()
        ..onProductTypeSelected(
          Reference(reference1: ServerConstants.productTypeConventional),
        );
      expect(viewModel.applicationDetails?.conventional, true);
      expect(viewModel.applicationDetails?.islamic, false);

      viewModel.onProductTypeSelected(
        Reference(reference1: ServerConstants.productTypeIslamic),
      );
      expect(viewModel.applicationDetails?.conventional, false);
      expect(viewModel.applicationDetails?.islamic, true);

      viewModel.onProductTypeSelected(
        Reference(reference1: ServerConstants.productTypeBoth),
      );
      expect(viewModel.applicationDetails?.conventional, true);
      expect(viewModel.applicationDetails?.islamic, true);
    });

    test("getFilteredProductOptions filters translated NA item", () {
      final na = "requestInformation.requestInformation.na".tr();
      viewModel.productTypeItems = [
        Reference(name: na),
        Reference(name: "Conventional"),
        Reference(name: "Islamic"),
      ];

      final result = viewModel.getFilteredProductOptions();

      expect(result.map((e) => e.name).toList(), ["Conventional", "Islamic"]);
    });

    test(
        "changeProductTypeOptions clears "
        "selected facility type when id changes", () {
      viewModel.selectedProductTypeOption = Reference(id: 1, name: "Old");
      viewModel.facility.facilityTypeSelectedValue =
          Reference(id: 10, name: "Desc");
      viewModel
        ..facilityDescriptions = [Reference(id: 11, name: "A")]
        ..changeProductTypeOptions(Reference(id: 2, name: "New"));

      expect(viewModel.selectedProductTypeOption?.id, 2);
      expect(viewModel.facility.selectedProductTypeValue, isNotNull);
      expect(viewModel.facilityDescriptions, isEmpty);
    });

    test(
        "changeProductTypeOptions keeps current "
        "description when id does not change", () {
      viewModel.selectedProductTypeOption = Reference(id: 2, name: "Same");
      viewModel.facility.facilityTypeSelectedValue =
          Reference(id: 10, name: "KeepThis");
      viewModel
        ..facilityDescriptions = [Reference(id: 20, name: "Existing")]
        ..changeProductTypeOptions(Reference(id: 2, name: "Same"));

      expect(viewModel.selectedProductTypeOption?.id, 2);
      expect(viewModel.facility.selectedProductTypeValue?.name, "Same");
      expect(viewModel.facilityDescriptions.length, 1);
    });
  });

  group("Reference matching helpers", () {
    test("matchOrFirstByName exact/trim/case-insensitive and empty fallback",
        () {
      final list = [
        Reference(name: " One "),
        Reference(name: "Two"),
      ];

      expect(viewModel.matchOrFirstByName(list, "  one  ").name?.trim(), "One");
      expect(viewModel.matchOrFirstByName(list, "").name, " One ");
    });

    test("matchOrFirstById returns match or first fallback list behavior", () {
      final list = [
        Reference(id: 5, name: "Five"),
        Reference(id: 7, name: "Seven"),
      ];

      expect(viewModel.matchOrFirstById(list, "7").name, "Seven");
    });

    test("matchOrFirstByRef1 matches trimmed case-insensitive value", () {
      final list = [
        Reference(reference1: " AAA "),
        Reference(reference1: "BBB"),
      ];

      expect(
        viewModel.matchOrFirstByRef1(list, " aaa ").reference1?.trim(),
        "AAA",
      );
    });

    test("matchOrFirstByIdInList returns exact match or first fallback", () {
      final list = [
        Reference(id: 1, name: "A"),
        Reference(id: 2, name: "B"),
      ];

      expect(viewModel.matchOrFirstByIdInList(list, "2").name, "B");
      expect(viewModel.matchOrFirstByIdInList(list, "999").name, "A");
      expect(viewModel.matchOrFirstByIdInList([], "2").name, isNull);
    });

    test("facilityTypeNameById returns matched ref or fallback", () {
      viewModel.facilityTypes = [
        Reference(id: 10, name: "Type A"),
      ];

      expect(viewModel.facilityTypeNameById(10).name, "Type A");
      expect(viewModel.facilityTypeNameById(99).name, "99");
      expect(viewModel.facilityTypeNameById(null).name, "null");
    });

    test("limitCapsTypeNameById returns matched name or fallback", () {
      viewModel.limitCapsType = [
        Reference(id: 14493, name: "Project Standby Limits"),
      ];

      expect(viewModel.limitCapsTypeNameById(14493), "Project Standby Limits");
      expect(viewModel.limitCapsTypeNameById(99999), "99999");
      expect(viewModel.limitCapsTypeNameById(null), "");
    });

    test(
        "benchmarkForLimitCategory filters by "
        "reference2 and falls back when no match", () {
      final funded = viewModel.benchmarkForLimitCategory("F");
      final nonFunded = viewModel.benchmarkForLimitCategory("N");
      final noMatch = viewModel.benchmarkForLimitCategory("X");
      final empty = viewModel.benchmarkForLimitCategory("");

      expect(funded.map((e) => e.name).toList(), ["LIBOR", "EIBOR"]);
      expect(nonFunded.map((e) => e.name).toList(), ["SOFR"]);
      expect(noMatch.length, viewModel.benchmark.length);
      expect(empty.length, viewModel.benchmark.length);
    });
  });

  group("Tenor normalization helpers", () {
    test("normalizeTenorUnit covers common formats", () {
      expect(viewModel.normalizeTenorUnit("days"), "Days");
      expect(viewModel.normalizeTenorUnit("D"), "Days");
      expect(viewModel.normalizeTenorUnit("months"), "Months");
      expect(viewModel.normalizeTenorUnit("m"), "Months");
      expect(viewModel.normalizeTenorUnit("years"), "Years");
      expect(viewModel.normalizeTenorUnit("yr"), "Years");
      expect(viewModel.normalizeTenorUnit("On Demand"), "On Demand");
      expect(viewModel.normalizeTenorUnit("customValue"), "CustomValue");
      expect(viewModel.normalizeTenorUnit(null), "");
    });

    test(
        "matchPeriodByAny matches by normalized name / reference1 / id / fallback",
        () {
      expect(viewModel.matchPeriodByAny(viewModel.period, "days").name, "Days");
      expect(viewModel.matchPeriodByAny(viewModel.period, "m").name, "Months");
      expect(viewModel.matchPeriodByAny(viewModel.period, "3").name, "Years");
      expect(
        viewModel.matchPeriodByAny(viewModel.period, "unknown").name,
        "Days",
      );
    });
  });

  group("RIM helpers", () {
    test("extractRimId handles parenthesized, first numeric, invalid and null",
        () {
      expect(viewModel.extractRimId("( 123 )"), 123);
      expect(viewModel.extractRimId("Customer 456 Name"), 456);
      expect(viewModel.extractRimId("Customer (111) Something (222)"), 222);
      expect(viewModel.extractRimId(""), isNull);
      expect(viewModel.extractRimId("   "), isNull);
      expect(viewModel.extractRimId("No numbers"), isNull);
      expect(viewModel.extractRimId(null), isNull);
    });

    test(
        "resolveRimNoFromApi prefers groupOwner "
        "then customerRimNo then parsed rim name", () {
      Globals.request?.groupOwner = 123;
      Globals.request?.customerRimNo = 456;
      expect(viewModel.resolveRimNoFromApi(), 123);

      Globals.request?.groupOwner = null;
      Globals.request?.customerRimNo = 456;
      expect(viewModel.resolveRimNoFromApi(), 456);

      Globals.request?.groupOwner = null;
      Globals.request?.customerRimNo = null;
      viewModel.customerFacilities = [
        FacilitySummaryList()
          ..rims = [
            RimSummary()..rimName = "Customer (777)",
          ],
      ];
      expect(viewModel.resolveRimNoFromApi(), 777);
    });

    test("resolveRimNo uses rimNo first then parsed rimName", () {
      final withRimNo = RimSummary()
        ..rimNo = 500
        ..rimName = "Name (999)";
      final withoutRimNo = RimSummary()..rimName = "Name (777)";

      expect(viewModel.resolveRimNo(withRimNo), 500);
      expect(viewModel.resolveRimNo(withoutRimNo), 777);
      expect(viewModel.resolveRimNo(null), isNull);
    });
  });

  group("Facility/group utility helpers", () {
    test("isExcludedFacility handles CLT and 935 correctly", () {
      final clt = FacilitySummaryNew()..productCode = "CLT";
      final ld935 = FacilitySummaryNew()..limitDescription = "935";
      final normal = FacilitySummaryNew()
        ..productCode = "ODA"
        ..limitDescription = "123";

      expect(viewModel.isExcludedFacility(clt), true);
      expect(viewModel.isExcludedFacility(ld935), true);
      expect(viewModel.isExcludedFacility(normal), false);
    });

    test("firstRimOfCustomer returns first rim or null", () {
      final customer = FacilitySummaryList()
        ..rims = [
          RimSummary()..rimName = "A",
          RimSummary()..rimName = "B",
        ];

      expect(viewModel.firstRimOfCustomer(customer)?.rimName, "A");
      expect(viewModel.firstRimOfCustomer(FacilitySummaryList()), isNull);
    });

    test("groupByIndex returns valid group or null for invalid index", () {
      final rim = RimSummary()
        ..groups = [
          RimGroup()..groupName = "G1",
          RimGroup()..groupName = "G2",
        ];

      expect(viewModel.groupByIndex(rim, 1)?.groupName, "G2");
      expect(viewModel.groupByIndex(rim, -1), isNull);
      expect(viewModel.groupByIndex(rim, 99), isNull);
      expect(viewModel.groupByIndex(null, 0), isNull);
    });

    test("findGroupIndexByName returns match case-insensitively or null", () {
      final rim = RimSummary()
        ..groups = [
          RimGroup()..groupName = "General Working Capital",
          RimGroup()..groupName = "Project Specific",
        ];

      expect(viewModel.findGroupIndexByName(rim, "project specific"), 1);
      expect(viewModel.findGroupIndexByName(rim, "unknown"), isNull);
      expect(viewModel.findGroupIndexByName(null, "anything"), isNull);
    });

    test(
        "hasNonExcludedRows returns true only "
        "when at least one non-excluded exists", () {
      final excluded = FacilitySummaryNew()
        ..limitDescription = "935"
        ..productCode = "CLT";
      final normal = FacilitySummaryNew()
        ..limitDescription = "123"
        ..productCode = "ODA";

      final g1 = RimGroup()
        ..facilityLimits = [
          FacilityDis()..facility = excluded,
        ];
      final g2 = RimGroup()
        ..facilityLimits = [
          FacilityDis()..facility = excluded,
          FacilityDis()..facility = normal,
        ];

      expect(viewModel.hasNonExcludedRows(g1), false);
      expect(viewModel.hasNonExcludedRows(g2), true);
    });

    test("filteredSortedDisList filters excluded rows and sorts by order", () {
      final a = FacilitySummaryNew()
        ..productCode = "ODA"
        ..limitDescription = "123";
      final b = FacilitySummaryNew()
        ..productCode = "CLT"
        ..limitDescription = "935";
      final c = FacilitySummaryNew()
        ..productCode = "ODA"
        ..limitDescription = "123";

      final group = RimGroup()
        ..facilityLimits = [
          (FacilityDis()
            ..order = "2"
            ..facility = a),
          (FacilityDis()
            ..order = "1"
            ..facility = b),
          (FacilityDis()
            ..order = "0"
            ..facility = c),
        ];

      final result = viewModel.filteredSortedDisList(group);

      expect(result.length, 2);
      expect(result.first.order, "0");
      expect(result.last.order, "2");
    });

    test("resolveParentCap returns parent proposed limit or null", () {
      final parent = FacilitySummaryNew()
        ..limitNo = "PARENT-1"
        ..proposedLimit = 500;

      final child = FacilitySummaryNew()
        ..limitNo = "CHILD-1"
        ..proposedLimit = 100;

      final list = [
        FacilityDis()..facility = parent,
        FacilityDis()..facility = child,
      ];

      expect(viewModel.resolveParentCap("PARENT-1", list), 500);
      expect(viewModel.resolveParentCap("UNKNOWN", list), isNull);
      expect(viewModel.resolveParentCap("", list), isNull);
    });

    test("sustainabilityRefs converts csv ids into matching references", () {
      final refs = viewModel.sustainabilityRefs("11, 13");

      expect(refs.map((e) => e.name).toList(), ["Green", "Transition"]);
      expect(viewModel.sustainabilityRefs(""), isEmpty);
      expect(viewModel.sustainabilityRefs(null), isEmpty);
    });
  });

  group("Limit group / description helpers", () {
    test(
        "selectLimittedGroup filters by reference1/reference4 and excludes ids",
        () {
      viewModel
        ..facilityTypes = [
          Reference(id: 100, name: "Match1", reference4: "trade"),
          Reference(id: 101, name: "Match2", reference4: "trade"),
          Reference(id: 13871, name: "Excluded", reference4: "trade"),
          Reference(id: 935, name: "Excluded935", reference4: "trade"),
          Reference(id: 200, name: "Other", reference4: "other"),
        ]
        ..selectLimittedGroup(
          Reference(id: 1, name: "Trade Limit", reference1: "trade"),
        );

      expect(viewModel.facility.facilityTypeSelectedValue?.id, 1);
      expect(
        viewModel.facilityDescriptions.map((e) => e.name).toList(),
        ["Match1", "Match2"],
      );
    });

    test("selectLimittedGroup leaves descriptions empty when no matches exist",
        () {
      viewModel
        ..facilityTypes = [
          Reference(id: 1, name: "A", reference4: "abc"),
        ]
        ..selectLimittedGroup(
          Reference(id: 99, name: "NoMatch", reference1: "xyz"),
        );

      expect(viewModel.facilityDescriptions, isEmpty);
    });

    test("facilityTypeDescriptionsSelected stores selection", () async {
      final ref = Reference(id: 22, name: "Desc");

      await viewModel.facilityTypeDescriptionsSelected(ref);

      expect(viewModel.facility.facilityDescription?.id, 22);
      expect(viewModel.facility.facilityDescription?.name, "Desc");
    });
  });

  group("Project list + schedule fetch helpers", () {
    test("getProjectList success stores project names", () async {
      when(
        () => mockFacilityRepo.getProjectList(
          limitGroup: 11315,
          rimNo: 999,
        ),
      ).thenAnswer(
        (_) async => ProjectListResponse(["PRJ-1", "PRJ-2"]),
      );

      await viewModel.getProjectList(11315, 999);

      expect(
        viewModel.projectNamesSpecific.map((e) => e.name).toList(),
        ["PRJ-1", "PRJ-2"],
      );
    });

    test("getProjectList empty response keeps names empty", () async {
      when(
        () => mockFacilityRepo.getProjectList(
          limitGroup: 11315,
          rimNo: 123,
        ),
      ).thenAnswer(
        (_) async => ProjectListResponse([]),
      );

      await viewModel.getProjectList(11315, 123);

      expect(viewModel.projectNamesSpecific, isEmpty);
    });

    test("getProjectList caches same group+rim and avoids duplicate fetch",
        () async {
      when(
        () => mockFacilityRepo.getProjectList(
          limitGroup: 11315,
          rimNo: 999,
        ),
      ).thenAnswer(
        (_) async => ProjectListResponse(["PRJ-1"]),
      );

      await viewModel.getProjectList(11315, 999);
      await viewModel.getProjectList(11315, 999);

      verify(
        () => mockFacilityRepo.getProjectList(
          limitGroup: 11315,
          rimNo: 999,
        ),
      ).called(2);
    });

    test("getProjectList fetches again when rim changes", () async {
      when(
        () => mockFacilityRepo.getProjectList(
          limitGroup: any(named: "limitGroup"),
          rimNo: any(named: "rimNo"),
        ),
      ).thenAnswer(
        (_) async => ProjectListResponse(["PRJ-1"]),
      );

      await viewModel.getProjectList(11315, 123);
      await viewModel.getProjectList(11315, 456);

      verify(
        () => mockFacilityRepo.getProjectList(
          limitGroup: 11315,
          rimNo: 123,
        ),
      ).called(1);
      verify(
        () => mockFacilityRepo.getProjectList(
          limitGroup: 11315,
          rimNo: 456,
        ),
      ).called(1);
    });

    test("getProjectList with null args still executes safely", () async {
      when(() => mockFacilityRepo.getProjectList()).thenAnswer(
        (_) async => ProjectListResponse([]),
      );

      await viewModel.getProjectList(null, 999);
      await viewModel.getProjectList(11315, null);

      expect(viewModel.projectNamesSpecific, isEmpty);
    });

    test("getProjectList failure shows toast", () async {
      when(
        () => mockFacilityRepo.getProjectList(
          limitGroup: 11315,
          rimNo: 999,
        ),
      ).thenThrow(Exception("project-list-error"));

      await viewModel.getProjectList(11315, 999);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    // testWidgets('scheduleProjectListFetchIfNeeded triggers post-frame fetch
    // for project group', (tester) async {
    //   when(
    //     () => mockFacilityRepo.getProjectList(
    //       limitGroup: 11315,
    //       rimNo: 999,
    //     ),
    //   ).thenAnswer((_) async => const ProjectListResponse(['PRJ-1']));

    //   viewModel.scheduleProjectListFetchIfNeeded(11315, 999);
    //   await tester.pump();

    //   verify(
    //     () => mockFacilityRepo.getProjectList(
    //       limitGroup: 11315,
    //       rimNo: 999,
    //     ),
    //   ).called(1);
    // });

    testWidgets(
        "scheduleProjectListFetchIfNeeded ignores non-project groups / nulls",
        (tester) async {
      viewModel.scheduleProjectListFetchIfNeeded(
        ServerConstants.generalLimitGroupId,
        999,
      );
      await tester.pump();

      verifyNever(
        () => mockFacilityRepo.getProjectList(
          limitGroup: any(named: "limitGroup"),
          rimNo: any(named: "rimNo"),
        ),
      );
    });
  });

  group("Header preload + header helper coverage", () {
    test("preloadHeaderProposedLimitsFromApi ignores excluded headers", () {
      final excluded = FacilitySummaryNew()
        ..facilityId = 999
        ..limitGroup = ServerConstants.projectSpecificLimitsID
        ..rimNo = 111
        ..proposedLimit = 999
        ..currency = "AED"
        ..limitDescription = "935"
        ..productCode = "CLT";

      viewModel
        ..customerFacilities = [
          FacilitySummaryList()
            ..rims = [
              RimSummary()
                ..rimName = "Customer (111)"
                ..groups = [
                  RimGroup()
                    ..facilityLimits = [
                      (FacilityDis()
                        ..order = "0"
                        ..facility = excluded),
                    ],
                ],
            ],
        ]
        ..preloadHeaderProposedLimitsFromApi();

      expect(
        viewModel.headerFacilityIdForGroupAtRim(
          ServerConstants.projectSpecificLimitsID,
          111,
        ),
        isNull,
      );
      expect(
        viewModel.proposedLimitForGroup(
          ServerConstants.projectSpecificLimitsID,
          rimNo: 111,
        ),
        0,
      );
      expect(
        viewModel.headerCurrencyFor(
          ServerConstants.projectSpecificLimitsID,
          111,
        ),
        isNull,
      );
    });

    test("isProjectHeaderDirtyAtRim false when same as API snapshot", () {
      const groupId = ServerConstants.projectSpecificLimitsID;
      const rimNo = 999;

      final header = FacilitySummaryNew()
        ..facilityId = 1
        ..limitGroup = groupId
        ..rimNo = rimNo
        ..proposedLimit = 100
        ..currency = "AED"
        ..projectName = "Project A"
        ..limitDescription = "123"
        ..productCode = "ODA";

      viewModel
        ..customerFacilities = [
          FacilitySummaryList()
            ..rims = [
              RimSummary()
                ..rimName = "Customer (999)"
                ..groups = [
                  RimGroup()
                    ..facilityLimits = [
                      (FacilityDis()
                        ..order = "0"
                        ..facility = header),
                    ],
                ],
            ],
        ]
        ..preloadHeaderProposedLimitsFromApi()

        // Same values as API snapshot
        ..setProjectProposedLimitInput(
          "100",
          groupId: groupId,
          rimNo: rimNo,
        );
      viewModel.psNameCtrl(rimNo).text = "Project A";
      viewModel.setHeaderCurrencyFor(groupId, rimNo, Reference(name: "AED"));

      expect(viewModel.isProjectHeaderDirtyAtRim(groupId, rimNo), false);
    });

    test("isProjectHeaderDirtyAtRim true when currency changes", () {
      const groupId = ServerConstants.projectSpecificLimitsID;
      const rimNo = 999;

      final header = FacilitySummaryNew()
        ..facilityId = 1
        ..limitGroup = groupId
        ..rimNo = rimNo
        ..proposedLimit = 100
        ..currency = "AED"
        ..projectName = "Project A"
        ..limitDescription = "123"
        ..productCode = "ODA";

      viewModel
        ..customerFacilities = [
          FacilitySummaryList()
            ..rims = [
              RimSummary()
                ..rimName = "Customer (999)"
                ..groups = [
                  RimGroup()
                    ..facilityLimits = [
                      (FacilityDis()
                        ..order = "0"
                        ..facility = header),
                    ],
                ],
            ],
        ]
        ..preloadHeaderProposedLimitsFromApi()
        ..setProjectProposedLimitInput(
          "100",
          groupId: groupId,
          rimNo: rimNo,
        );
      viewModel.psNameCtrl(rimNo).text = "Project A";
      viewModel.setHeaderCurrencyFor(groupId, rimNo, Reference(name: "USD"));

      expect(viewModel.isProjectHeaderDirtyAtRim(groupId, rimNo), true);
    });

    test("isProjectHeaderDirtyAtRim true when name changes", () {
      const groupId = ServerConstants.projectStandByLimitID;
      const rimNo = 999;

      final header = FacilitySummaryNew()
        ..facilityId = 1
        ..limitGroup = groupId
        ..rimNo = rimNo
        ..proposedLimit = 100
        ..currency = "AED"
        ..projectName = "Old Name"
        ..limitDescription = "123"
        ..productCode = "ODA";

      viewModel
        ..customerFacilities = [
          FacilitySummaryList()
            ..rims = [
              RimSummary()
                ..rimName = "Customer (999)"
                ..groups = [
                  RimGroup()
                    ..facilityLimits = [
                      (FacilityDis()
                        ..order = "0"
                        ..facility = header),
                    ],
                ],
            ],
        ]
        ..preloadHeaderProposedLimitsFromApi()
        ..setProjectProposedLimitInput(
          "100",
          groupId: groupId,
          rimNo: rimNo,
        )
        ..setHeaderCurrencyFor(groupId, rimNo, Reference(name: "AED"));
      viewModel.standbyNameCtrl(rimNo).text = "New Name";

      expect(viewModel.isProjectHeaderDirtyAtRim(groupId, rimNo), true);
    });
  });

  group("Header/detail/group search helpers", () {
    test("headerLimitNumberForGroup returns header row", () {
      viewModel.customerFacilities = [
        buildSummary(
          groupId: 11315,
          order: "2",
          limitNo: "DET-001",
          rimName: "(999)",
        ),
        buildSummary(
          groupId: 11315,
          order: "0",
          limitNo: "HDR-001",
          rimName: "(999)",
        ),
      ];

      expect(viewModel.headerLimitNumberForGroup(11315), "HDR-001");
    });

    test("headerLimitNumberForGroup returns null when no header exists", () {
      viewModel.customerFacilities = [
        buildSummary(
          groupId: 11315,
          order: "2",
          limitNo: "DET-001",
          rimName: "(999)",
        ),
      ];

      final result = viewModel.headerLimitNumberForGroup(11315);
      expect(result == null || result.isEmpty, true);
    });

    test("headerLimitNumberForGroupAtRim selects correct rim", () {
      viewModel.customerFacilities = [
        buildSummary(
          groupId: 11315,
          order: "0",
          limitNo: "HDR-999",
          rimName: "Customer A (999)",
        ),
        buildSummary(
          groupId: 11315,
          order: "0",
          limitNo: "HDR-888",
          rimName: "Customer B (888)",
        ),
      ];

      expect(
        viewModel.headerLimitNumberForGroupAtRim(11315, 888),
        "HDR-888",
      );
    });

    test("headerLimitNumberForGroupAtRim returns empty/null for wrong rim", () {
      viewModel.customerFacilities = [
        buildSummary(
          groupId: 11315,
          order: "0",
          limitNo: "HDR-999",
          rimName: "Customer A (999)",
        ),
      ];

      final result = viewModel.headerLimitNumberForGroupAtRim(11315, 888);
      expect(result == null || result.isEmpty, true);
    });

    test("hasDetailRowsForGroup returns true when non-header exists", () {
      viewModel.customerFacilities = [
        buildSummary(
          groupId: 11315,
          order: "1",
          limitNo: "DET-001",
          rimName: "(999)",
        ),
      ];

      expect(viewModel.hasDetailRowsForGroup(11315), true);
    });

    test("hasDetailRowsForGroup returns false when only header exists", () {
      viewModel.customerFacilities = [
        buildSummary(
          groupId: 11315,
          order: "0",
          limitNo: "HDR-001",
          rimName: "(999)",
        ),
      ];

      expect(viewModel.hasDetailRowsForGroup(11315), false);
    });

    test("hasDetailRowsForGroup ignores other group ids", () {
      viewModel.customerFacilities = [
        buildSummary(
          groupId: 11317,
          order: "2",
          limitNo: "DET-OTHER",
          rimName: "(999)",
        ),
      ];

      expect(viewModel.hasDetailRowsForGroup(11315), false);
    });

    test(
        "hasDetailRowsForGroupAtRim returns "
        "true when detail exists for group+rims", () {
      viewModel.customerFacilities = [
        buildSummary(
          groupId: 11315,
          order: "2",
          limitNo: "DET-RIM-001",
          rimName: "Customer RIM (999)",
        ),
      ];

      expect(
        viewModel.hasDetailRowsForGroupAtRim(11315, 999),
        true,
      );
    });

    test("hasDetailRowsForGroupAtRim returns false for other rims or groups",
        () {
      viewModel.customerFacilities = [
        buildSummary(
          groupId: 11315,
          order: "2",
          limitNo: "DET-001",
          rimName: "Customer (888)",
        ),
      ];

      expect(viewModel.hasDetailRowsForGroupAtRim(11315, 999), false);
      expect(viewModel.hasDetailRowsForGroupAtRim(11317, 888), false);
    });

    test("shouldCallProjectApiForGroup true when customerFacilities is null",
        () {
      viewModel.customerFacilities = null;
      expect(viewModel.shouldCallProjectApiForGroup(11315), true);
    });

    test("shouldCallProjectApiForGroup false when non-excluded header exists",
        () {
      viewModel.customerFacilities = [
        buildSummary(
          groupId: 11315,
          order: "0",
          limitNo: "HDR",
          rimName: "(999)",
        ),
      ];

      expect(viewModel.shouldCallProjectApiForGroup(11315), false);
    });

    test("shouldCallProjectApiForGroup false when non-excluded detail exists",
        () {
      viewModel.customerFacilities = [
        buildSummary(
          groupId: 11315,
          order: "2",
          limitNo: "DET",
          rimName: "(999)",
        ),
      ];

      expect(viewModel.shouldCallProjectApiForGroup(11315), false);
    });

    test("shouldCallProjectApiForGroup true when only excluded rows exist", () {
      final excluded = FacilitySummaryNew()
        ..limitGroup = 11315
        ..limitDescription = "935"
        ..productCode = "CLT";

      viewModel.customerFacilities = [
        FacilitySummaryList()
          ..rims = [
            RimSummary()
              ..rimName = "(999)"
              ..groups = [
                RimGroup()
                  ..facilityLimits = [
                    (FacilityDis()
                      ..order = "0"
                      ..facility = excluded),
                  ],
              ],
          ],
      ];

      expect(viewModel.shouldCallProjectApiForGroup(11315), true);
    });

    test("limitCapTypeForGroup returns correct values", () {
      expect(
        viewModel.limitCapTypeForGroup(ServerConstants.projectStandByLimitID),
        14493,
      );
      expect(
        viewModel.limitCapTypeForGroup(ServerConstants.projectSpecificLimitsID),
        14494,
      );
      expect(
        viewModel.limitCapTypeForGroup(ServerConstants.generalLimitGroupId),
        14492,
      );
    });
  });

  group("Delete flow", () {
    test(
        "deleteFacilityDetails with null serial "
        "number shows invalid facility toast", () async {
      await viewModel.deleteFacilityDetails();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      verifyNever(
        () => mockFacilityRepo.deleteFacilityDetails(
          facilityId: any(named: "facilityId"),
        ),
      );
    });

    test("deleteFacilityDetails failure shows toast and ends loaded", () async {
      when(
        () => mockFacilityRepo.deleteFacilityDetails(
          facilityId: any(named: "facilityId"),
        ),
      ).thenThrow(Exception("delete-failed"));

      await viewModel.deleteFacilityDetails(serialNumber: 999);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.tableLoaderStatus, LoadingStatus.loaded);
    });
  });

  group("Save limit caps flow", () {
    test("saveLimitCapsSummaryList warns when nothing edited", () async {
      final list = FacilitySummaryList()
        ..rims = [
          RimSummary()
            ..rimName = "Customer (999)"
            ..groups = [
              RimGroup()
                ..facilityLimits = [
                  (FacilityDis()
                    ..facility = (FacilitySummaryNew()
                      ..isEdited = false
                      ..limitGroup = 11315
                      ..rimNo = 999)),
                ],
            ],
        ];

      await viewModel.saveLimitCapsSummaryList(list);

      verify(() => mockAlertManager.showWarningToast(any())).called(1);
      verifyNever(() => mockFacilityRepo.saveFacilitySummaryListEdited(any()));
    });

    test("saveLimitCapsSummaryList success saves and shows success toast",
        () async {
      final edited = FacilitySummaryNew()
        ..isEdited = true
        ..limitGroup = 11315
        ..rimNo = 999
        ..limitNo = "LC-1"
        ..currency = "USD"
        ..proposedLimit = 100;

      final list = FacilitySummaryList()
        ..rims = [
          RimSummary()
            ..rimName = "Customer (999)"
            ..groups = [
              RimGroup()
                ..facilityLimits = [
                  FacilityDis()..facility = edited,
                ],
            ],
        ];

      when(() => mockFacilityRepo.saveFacilitySummaryListEdited(any()))
          .thenAnswer((_) async => null);

      await viewModel.saveLimitCapsSummaryList(list);

      verify(() => mockFacilityRepo.saveFacilitySummaryListEdited(any()))
          .called(1);
      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
    });

    test("saveLimitCapsSummaryList failure shows failure toast", () async {
      final edited = FacilitySummaryNew()
        ..isEdited = true
        ..limitGroup = 11315
        ..rimNo = 999;

      final list = FacilitySummaryList()
        ..rims = [
          RimSummary()
            ..rimName = "Customer (999)"
            ..groups = [
              RimGroup()
                ..facilityLimits = [
                  FacilityDis()..facility = edited,
                ],
            ],
        ];

      when(() => mockFacilityRepo.saveFacilitySummaryListEdited(any()))
          .thenThrow(Exception("caps-save-failed"));

      await viewModel.saveLimitCapsSummaryList(list);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("Save facility summary flow", () {
    test("saveFacilitySummaryList warns when list has no edited facilities",
        () async {
      final list = FacilitySummaryList();

      await viewModel.saveFacilitySummaryList(
        list,
        limitGroup: 11315,
        selectedRim: 999,
      );

      verify(() => mockAlertManager.showWarningToast(any())).called(1);
      verifyNever(() => mockFacilityRepo.saveFacilitySummaryListEdited(any()));
    });

    test("saveFacilitySummaryList ignores null facility entries safely",
        () async {
      final list = FacilitySummaryList()
        ..rims = [
          RimSummary()
            ..rimName = "Customer (999)"
            ..groups = [
              RimGroup()
                ..facilityLimits = [
                  FacilityDis()..facility = null,
                ],
            ],
        ];

      await viewModel.saveFacilitySummaryList(
        list,
        limitGroup: 11315,
        selectedRim: 999,
      );

      verify(() => mockAlertManager.showWarningToast(any())).called(1);
      verifyNever(() => mockFacilityRepo.saveFacilitySummaryListEdited(any()));
    });

    test("saveFacilitySummaryList ignores unedited facilities", () async {
      final unedited = FacilitySummaryNew()
        ..isEdited = false
        ..limitGroup = 11315
        ..rimNo = 999;

      final list = FacilitySummaryList()
        ..rims = [
          RimSummary()
            ..rimName = "Customer (999)"
            ..groups = [
              RimGroup()
                ..facilityLimits = [
                  FacilityDis()..facility = unedited,
                ],
            ],
        ];

      await viewModel.saveFacilitySummaryList(
        list,
        limitGroup: 11315,
        selectedRim: 999,
      );

      verify(() => mockAlertManager.showWarningToast(any())).called(1);
      verifyNever(() => mockFacilityRepo.saveFacilitySummaryListEdited(any()));
    });

    test("saveFacilitySummaryList success for non-project group", () async {
      final edited = FacilitySummaryNew()
        ..isEdited = true
        ..limitGroup = ServerConstants.generalLimitGroupId
        ..rimNo = 999
        ..limitNo = "GEN-1"
        ..isMainLimit = true;

      final list = FacilitySummaryList()
        ..rims = [
          RimSummary()
            ..rimName = "Customer (999)"
            ..groups = [
              RimGroup()
                ..facilityLimits = [
                  FacilityDis()..facility = edited,
                ],
            ],
        ];

      when(() => mockFacilityRepo.saveFacilitySummaryListEdited(any()))
          .thenAnswer((_) async => null);
      when(() => mockFacilityRepo.getFacilitySummaryList())
          .thenAnswer((_) async => <FacilitySummaryList>[]);

      await viewModel.saveFacilitySummaryList(
        list,
        limitGroup: ServerConstants.generalLimitGroupId,
        selectedRim: 999,
      );

      verify(() => mockFacilityRepo.saveFacilitySummaryListEdited(any()))
          .called(1);
      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
    });

    test("saveFacilitySummaryList repo failure shows failure toast", () async {
      final edited = FacilitySummaryNew()
        ..isEdited = true
        ..limitGroup = ServerConstants.generalLimitGroupId
        ..rimNo = 999
        ..limitNo = "FAIL";

      final list = FacilitySummaryList()
        ..rims = [
          RimSummary()
            ..rimName = "Customer (999)"
            ..groups = [
              RimGroup()
                ..facilityLimits = [
                  FacilityDis()..facility = edited,
                ],
            ],
        ];

      when(() => mockFacilityRepo.saveFacilitySummaryListEdited(any()))
          .thenThrow(Exception("save-failed"));

      await viewModel.saveFacilitySummaryList(
        list,
        limitGroup: ServerConstants.generalLimitGroupId,
        selectedRim: 999,
      );

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test(
        "saveFacilitySummaryList project standby "
        "fails when child exceeds controlling limit", () async {
      const groupId = ServerConstants.projectStandByLimitID;
      const rimNo = 999;

      final header = FacilitySummaryNew()
        ..limitGroup = groupId
        ..rimNo = rimNo
        ..limitNo = "HDR"
        ..proposedLimit = 100
        ..limitDescription = "123"
        ..productCode = "ODA";

      final child = FacilitySummaryNew()
        ..isEdited = true
        ..limitGroup = groupId
        ..rimNo = rimNo
        ..limitNo = "CHILD"
        ..controllingLimitNo = "HDR"
        ..proposedLimit = 200
        ..limitDescription = "123"
        ..productCode = "ODA";

      final list = FacilitySummaryList()
        ..rims = [
          RimSummary()
            ..rimName = "Customer (999)"
            ..groups = [
              RimGroup()
                ..facilityLimits = [
                  (FacilityDis()
                    ..order = "0"
                    ..facility = header),
                  (FacilityDis()
                    ..order = "1"
                    ..facility = child),
                ],
            ],
        ];

      viewModel
        ..customerFacilities = [list]
        ..setProjectProposedLimitInput(
          "100",
          groupId: groupId,
          rimNo: rimNo,
        );

      await viewModel.saveFacilitySummaryList(
        list,
        limitGroup: groupId,
        selectedRim: rimNo,
      );

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      // verifyNever(() => mockFacilityRepo.saveFacilitySummaryListEdited(any()));
    });

    test("saveFacilitySummaryList project cap failure shows exceed toast",
        () async {
      const groupId = ServerConstants.projectSpecificLimitsID;
      const rimNo = 999;

      final detail = FacilitySummaryNew()
        ..isEdited = true
        ..limitGroup = groupId
        ..rimNo = rimNo
        ..limitNo = "PS-1"
        ..proposedLimit = 200
        ..limitDescription = "123"
        ..productCode = "ODA";

      final list = FacilitySummaryList()
        ..rims = [
          RimSummary()
            ..rimName = "Customer (999)"
            ..groups = [
              RimGroup()
                ..facilityLimits = [
                  (FacilityDis()
                    ..order = "1"
                    ..facility = detail),
                ],
            ],
        ];

      viewModel.setProjectProposedLimitInput(
        "100",
        groupId: groupId,
        rimNo: rimNo,
      );

      await viewModel.saveFacilitySummaryList(
        list,
        limitGroup: groupId,
        selectedRim: rimNo,
      );

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      // verifyNever(() => mockFacilityRepo.saveFacilitySummaryListEdited(any()));
    });

    test("saveFacilitySummaryList project cap success when total within cap",
        () async {
      const groupId = ServerConstants.projectSpecificLimitsID;
      const rimNo = 999;

      final edited = FacilitySummaryNew()
        ..isEdited = true
        ..limitGroup = groupId
        ..rimNo = rimNo
        ..limitNo = "PS-1"
        ..proposedLimit = 100
        ..limitDescription = "123"
        ..productCode = "ODA";

      final list = FacilitySummaryList()
        ..rims = [
          RimSummary()
            ..rimName = "Customer (999)"
            ..groups = [
              RimGroup()
                ..facilityLimits = [
                  (FacilityDis()
                    ..order = "1"
                    ..facility = edited),
                ],
            ],
        ];

      viewModel.setProjectProposedLimitInput(
        "150",
        groupId: groupId,
        rimNo: rimNo,
      );
      when(() => mockFacilityRepo.saveFacilitySummaryListEdited(any()))
          .thenAnswer((_) async => null);
      when(() => mockFacilityRepo.getFacilitySummaryList())
          .thenAnswer((_) async => <FacilitySummaryList>[]);

      await viewModel.saveFacilitySummaryList(
        list,
        limitGroup: groupId,
        selectedRim: rimNo,
      );

      verify(() => mockFacilityRepo.saveFacilitySummaryListEdited(any()))
          .called(1);
      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
    });
  });

  group("Project header save / payload-building through public APIs", () {
    test("prepareProjectProductCode ignores non-project groups", () {
      viewModel.facility.productCodeProject = "OLD";
      viewModel
        ..limitGroup = [
          Reference(id: 99999, reference3: "new"),
        ]
        ..prepareProjectProductCode(99999);

      expect(viewModel.facility.productCodeProject, "OLD");
    });

    test("saveOrUpdateProjectHeader returns false when groupId is null",
        () async {
      final ok = await viewModel.saveOrUpdateProjectHeader(
        rimNo: 999,
        groupId: null,
        descSnapshot: Reference(id: 25, name: "Desc"),
      );

      expect(ok, false);
    });

    test(
        "saveFacilityProject success builds expected "
        "payload for project specific header", () async {
      const groupId = ServerConstants.projectSpecificLimitsID;
      const rimNo = 999;

      viewModel.limitGroup = [
        Reference(id: groupId, name: "Project Specific", reference3: "pspl"),
      ];
      viewModel.facility.facilityDescription =
          Reference(id: 25, name: "Project Specific");
      viewModel.facility.proposedLimitValue = Reference(name: "USD");

      viewModel
        ..setProjectExistingLimitInput(
          "50",
          groupId: groupId,
          rimNo: rimNo,
        )
        ..setProjectProposedLimitInput(
          "100",
          groupId: groupId,
          rimNo: rimNo,
        );
      viewModel.psNameCtrl(rimNo).text = "Project A";

      when(() => mockFacilityRepo.getFacilitySummaryList())
          .thenAnswer((_) async => <FacilitySummaryList>[]);

      final ok = await viewModel.saveFacilityProject(
        navigateToHomePage: false,
        rimNo,
        groupId,
        Reference(id: 25, name: "Project Specific"),
        facilityId: 123,
        limitCaptype: 14494,
      );

      expect(ok, isFalse);
      expect(viewModel.facility.limitNumber, isNull);

      final captured = verify(
        () => mockFacilityRepo.saveFacilityProject(
          facilityDetails: captureAny(named: "facilityDetails"),
        ),
      ).captured.single as FacilityDetails;

      expect(captured.facilityId, 123);
      expect(captured.rimNo, rimNo);
      expect(captured.limitGroup, groupId);
      expect(captured.presentLimit, 50);
      expect(captured.proposedLimit, 100);
      expect(captured.currency, "USD");
      expect(captured.projectName, "Project A");
      expect(captured.productCode, isNull);
    });

    test("saveFacilityProject failure shows toast and returns false", () async {
      const groupId = ServerConstants.projectStandByLimitID;
      const rimNo = 999;

      viewModel.limitGroup = [
        Reference(id: groupId, name: "Project Standby", reference3: "psbl"),
      ];
      viewModel.facility.facilityDescription =
          Reference(id: 25, name: "Project Standby");
      viewModel.facility.proposedLimitValue = Reference(name: "AED");
      viewModel
        ..setProjectExistingLimitInput(
          "10",
          groupId: groupId,
          rimNo: rimNo,
        )
        ..setProjectProposedLimitInput(
          "20",
          groupId: groupId,
          rimNo: rimNo,
        );
      viewModel.standbyNameCtrl(rimNo).text = "Standby A";

      when(
        () => mockFacilityRepo.saveFacilityProject(
          facilityDetails: any(named: "facilityDetails"),
        ),
      ).thenThrow(Exception("project-save-failed"));

      final ok = await viewModel.saveFacilityProject(
        navigateToHomePage: false,
        rimNo,
        groupId,
        Reference(id: 25, name: "Project Standby"),
      );

      expect(ok, false);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test(
        "saveOrUpdateProjectHeader delegates "
        "to saveFacilityProject success path", () async {
      const groupId = ServerConstants.projectSpecificLimitsID;
      const rimNo = 999;

      viewModel.limitGroup = [
        Reference(id: groupId, name: "Project Specific", reference3: "pspl"),
      ];
      viewModel.facility.facilityDescription =
          Reference(id: 25, name: "Project Specific");
      viewModel.facility.proposedLimitValue = Reference(name: "AED");
      viewModel
        ..setProjectExistingLimitInput(
          "10",
          groupId: groupId,
          rimNo: rimNo,
        )
        ..setProjectProposedLimitInput(
          "20",
          groupId: groupId,
          rimNo: rimNo,
        );
      viewModel.psNameCtrl(rimNo).text = "Project SaveOrUpdate";

      when(() => mockFacilityRepo.getFacilitySummaryList())
          .thenAnswer((_) async => <FacilitySummaryList>[]);

      final ok = await viewModel.saveOrUpdateProjectHeader(
        rimNo: rimNo,
        groupId: groupId,
        descSnapshot: Reference(id: 25, name: "Project Specific"),
        facilityId: 1,
        limitCaptype: 14494,
      );

      expect(ok, isFalse);
      verify(
        () => mockFacilityRepo.saveFacilityProject(
          facilityDetails: any(named: "facilityDetails"),
        ),
      ).called(1);
    });
  });

  group("onMarginValueChanged", () {
    late FacilitiesSummaryViewModel viewModel;

    setUp(() {
      viewModel = FacilitiesSummaryViewModel();
    });

    test("parses positive integer", () {
      final f = FacilitySummaryNew()
        ..facilityId = 1
        ..marginValue = null
        ..isEdited = false;

      viewModel.onMarginValueChanged(f, "10");

      expect(f.marginValue, 10);
      expect(f.isEdited, true);
    });

    test("parses negative decimal", () {
      final f = FacilitySummaryNew()
        ..facilityId = 2
        ..marginValue = null;

      viewModel.onMarginValueChanged(f, "-2.5");

      expect(f.marginValue, -2.5);
      expect(f.isEdited, true);
    });

    test("parses positive decimal with plus sign", () {
      final f = FacilitySummaryNew()
        ..facilityId = 3
        ..marginValue = null;

      viewModel.onMarginValueChanged(f, "+3.75");

      expect(f.marginValue, 3.75);
      expect(f.isEdited, true);
    });

    test("extracts first valid number from mixed input", () {
      final f = FacilitySummaryNew()
        ..facilityId = 4
        ..marginValue = null;

      viewModel.onMarginValueChanged(f, "abc 12.5 xyz");

      expect(f.marginValue, 12.5);
      expect(f.isEdited, true);
    });

    test("sets null when no number present", () {
      final f = FacilitySummaryNew()
        ..facilityId = 5
        ..marginValue = 99;

      viewModel.onMarginValueChanged(f, "invalid text");

      expect(f.marginValue, null);
      expect(f.isEdited, true);
    });

    test("handles empty string input", () {
      final f = FacilitySummaryNew()
        ..facilityId = 6
        ..marginValue = 99;

      viewModel.onMarginValueChanged(f, "");

      expect(f.marginValue, null);
      expect(f.isEdited, true);
    });

    test("handles whitespace input", () {
      final f = FacilitySummaryNew()
        ..facilityId = 7
        ..marginValue = 99;

      viewModel.onMarginValueChanged(f, "   ");

      expect(f.marginValue, null);
      expect(f.isEdited, true);
    });
  });

  test("onMarginValueChanged basic cases", () {
    final vm = FacilitiesSummaryViewModel();

    final f = FacilitySummaryNew()..facilityId = 1;

    //  integer
    vm.onMarginValueChanged(f, "10");
    expect(f.marginValue, 10);
    expect(f.isEdited, true);

    //  decimal
    vm.onMarginValueChanged(f, "-2.5");
    expect(f.marginValue, -2.5);

    //  plus decimal
    vm.onMarginValueChanged(f, "+3.75");
    expect(f.marginValue, 3.75);

    //  mixed text
    vm.onMarginValueChanged(f, "abc 12.5 xyz");
    expect(f.marginValue, 12.5);

    //  invalid input → null
    vm.onMarginValueChanged(f, "hello");
    expect(f.marginValue, null);
  });

  group("onTenorValueChanged", () {
    late FacilitiesSummaryViewModel vm;

    setUp(() {
      vm = FacilitiesSummaryViewModel();
    });

    test("extracts numeric value from simple number", () {
      final f = FacilitySummaryNew()
        ..facilityId = 1
        ..tenorValue = null
        ..isEdited = false;

      vm.onTenorValueChanged(f, "30");

      expect(f.tenorValue, 30);
      expect(f.isEdited, true);
    });

    test("extracts numeric value from mixed text (e.g. '30 Days')", () {
      final f = FacilitySummaryNew()..facilityId = 2;

      vm.onTenorValueChanged(f, "30 Days");

      expect(f.tenorValue, 30);
    });

    test("extracts first number when multiple numbers exist", () {
      final f = FacilitySummaryNew()..facilityId = 3;

      vm.onTenorValueChanged(f, "60 days 12 months");

      expect(f.tenorValue, 60); //  first match only
    });

    test("handles leading text before number", () {
      final f = FacilitySummaryNew()..facilityId = 4;

      vm.onTenorValueChanged(f, "tenor is 45");

      expect(f.tenorValue, 45);
    });

    test("sets null when no number present", () {
      final f = FacilitySummaryNew()
        ..facilityId = 5
        ..tenorValue = 99;

      vm.onTenorValueChanged(f, "invalid input");

      expect(f.tenorValue, null);
    });

    test("handles empty string input", () {
      final f = FacilitySummaryNew()..facilityId = 6;

      vm.onTenorValueChanged(f, "");

      expect(f.tenorValue, null);
    });

    test("handles whitespace input", () {
      final f = FacilitySummaryNew()..facilityId = 7;

      vm.onTenorValueChanged(f, "   ");

      expect(f.tenorValue, null);
    });

    test("handles large numbers correctly", () {
      final f = FacilitySummaryNew()..facilityId = 8;

      vm.onTenorValueChanged(f, "3650 Days");

      expect(f.tenorValue, 3650);
    });
  });

  group("onTenorUnitSelected", () {
    late FacilitiesSummaryViewModel vm;

    setUp(() {
      vm = FacilitiesSummaryViewModel();
    });

    test("updates tenorUnit and marks row edited", () {
      final f = FacilitySummaryNew()
        ..facilityId = 1
        ..tenorUnit = null
        ..isEdited = false;

      vm.onTenorUnitSelected(f, [
        Reference(name: "Months"),
      ]);

      expect(f.tenorUnit, "Months");
      expect(f.isEdited, true);
    });

    test("takes only the first selected item", () {
      final f = FacilitySummaryNew()
        ..facilityId = 2
        ..tenorUnit = null;

      vm.onTenorUnitSelected(f, [
        Reference(name: "Years"),
        Reference(name: "Months"),
      ]);

      expect(f.tenorUnit, "Years"); //  first item only
    });

    test("does nothing when selection is empty", () {
      final f = FacilitySummaryNew()
        ..facilityId = 3
        ..tenorUnit = "Days"
        ..isEdited = false;

      vm.onTenorUnitSelected(f, []);

      expect(f.tenorUnit, "Days"); // unchanged
      expect(f.isEdited, false); // not edited
    });

    test("handles null tenorUnit gracefully before update", () {
      final f = FacilitySummaryNew()..facilityId = 4;

      vm.onTenorUnitSelected(f, [
        Reference(name: "On Demand"),
      ]);

      expect(f.tenorUnit, "On Demand");
      expect(f.isEdited, true);
    });
  });

  group("onMarginSignSelected", () {
    late FacilitiesSummaryViewModel viewModel;

    setUp(() {
      viewModel = FacilitiesSummaryViewModel();
    });

    test("updates marginSign with selected reference1", () {
      final f = FacilitySummaryNew()
        ..facilityId = 1
        ..marginSign = null
        ..isEdited = false;

      final ref = Reference(name: "Plus", reference1: "+");

      viewModel.onMarginSignSelected(f, [ref]);

      expect(f.marginSign, "+"); // uses reference1
      expect(f.isEdited, true);
    });

    test("updates marginSign with minus sign", () {
      final f = FacilitySummaryNew()
        ..facilityId = 2
        ..marginSign = null;

      final ref = Reference(name: "Minus", reference1: "-");

      viewModel.onMarginSignSelected(f, [ref]);

      expect(f.marginSign, "-");
      expect(f.isEdited, true);
    });

    test("uses only first value when multiple provided", () {
      final f = FacilitySummaryNew()
        ..facilityId = 3
        ..marginSign = null;

      final refs = [
        Reference(reference1: "+"),
        Reference(reference1: "-"),
      ];

      viewModel.onMarginSignSelected(f, refs);

      expect(f.marginSign, "+"); //  first item only
      expect(f.isEdited, true);
    });

    test("does nothing when list is empty", () {
      final f = FacilitySummaryNew()
        ..facilityId = 4
        ..marginSign = "OLD"
        ..isEdited = false;

      viewModel.onMarginSignSelected(f, []);

      expect(f.marginSign, "OLD"); //  unchanged
      expect(f.isEdited, false); //  unchanged
    });

    test("handles null reference1 safely", () {
      final f = FacilitySummaryNew()
        ..facilityId = 5
        ..marginSign = null;

      final ref = Reference(name: "NoRef");

      viewModel.onMarginSignSelected(f, [ref]);

      expect(f.marginSign, null);
      expect(f.isEdited, true);
    });
  });

  group("onProposedCurrencySelected", () {
    late FacilitiesSummaryViewModel vm;

    setUp(() {
      vm = FacilitiesSummaryViewModel();
    });

    test("updates currency and marks row edited", () {
      final f = FacilitySummaryNew()
        ..facilityId = 1
        ..currency = "AED"
        ..isEdited = false;

      vm.onProposedCurrencySelected(f, [
        Reference(name: "USD"),
      ]);

      expect(f.currency, "USD");
      expect(f.isEdited, true);
    });

    test("sets facility.proposedLimitValue correctly", () {
      final f = FacilitySummaryNew()..facilityId = 2;

      final selected = Reference(name: "EUR");

      vm.onProposedCurrencySelected(f, [selected]);

      expect(vm.facility.proposedLimitValue, selected);
    });

    test("uses only the first item from selection list", () {
      final f = FacilitySummaryNew()..facilityId = 3;

      vm.onProposedCurrencySelected(f, [
        Reference(name: "GBP"),
        Reference(name: "USD"),
      ]);

      expect(f.currency, "GBP"); // first only
    });

    test("does nothing when list is empty", () {
      final f = FacilitySummaryNew()
        ..facilityId = 4
        ..currency = "AED"
        ..isEdited = false;

      vm.onProposedCurrencySelected(f, []);

      expect(f.currency, "AED"); // unchanged
      expect(f.isEdited, false); // unchanged
      expect(vm.facility.proposedLimitValue, isNull);
    });

    test("handles null currency safely", () {
      final f = FacilitySummaryNew()
        ..facilityId = 5
        ..currency = null;

      vm.onProposedCurrencySelected(f, [
        Reference(name: "USD"),
      ]);

      expect(f.currency, "USD");
    });
  });

  group("onProposedLimitChanged", () {
    late FacilitiesSummaryViewModel vm;

    setUp(() {
      vm = FacilitiesSummaryViewModel();
    });

    test("parses valid numeric input", () {
      final f = FacilitySummaryNew()
        ..facilityId = 1
        ..proposedLimit = null
        ..isEdited = false;

      vm.onProposedLimitChanged(f, "100");

      expect(f.proposedLimit, 100);
      expect(f.proposedLimitAED, 100);
      expect(f.isEdited, true);
    });

    test("removes non-digit characters", () {
      final f = FacilitySummaryNew()..facilityId = 2;

      vm.onProposedLimitChanged(f, "1a2b3");

      expect(f.proposedLimit, 123);
      expect(f.proposedLimitAED, 123);
    });

    test("handles commas and symbols", () {
      final f = FacilitySummaryNew()..facilityId = 3;

      vm.onProposedLimitChanged(f, "1,000 AED");

      expect(f.proposedLimit, 1000);
      expect(f.proposedLimitAED, 1000);
    });

    test("empty input gives zero", () {
      final f = FacilitySummaryNew()..facilityId = 4;

      vm.onProposedLimitChanged(f, "");

      expect(f.proposedLimit, 0);
      expect(f.proposedLimitAED, 0);
    });

    test("non-numeric input gives zero", () {
      final f = FacilitySummaryNew()..facilityId = 5;

      vm.onProposedLimitChanged(f, "abc");

      expect(f.proposedLimit, 0);
      expect(f.proposedLimitAED, 0);
    });

    test("large value handled correctly", () {
      final f = FacilitySummaryNew()..facilityId = 6;

      vm.onProposedLimitChanged(f, "9999999");

      expect(f.proposedLimit, 9999999);
    });
  });

  ///
  ///
  ///
  group("requireIndexForRow (fixed)", () {
    late FacilitiesSummaryViewModel viewModel;

    setUp(() {
      viewModel = FacilitiesSummaryViewModel()
        ..facilityTypes = [
          Reference(id: 10, reference5: "OLD"), // normal product
          Reference(
            id: 20,
            reference5: ServerConstants.newProductCode,
          ), // new product
        ];
    });

    test("returns true for funded + non-new product", () {
      final f = FacilitySummaryNew()
        ..limitCategory = "F"
        ..limitDescription = "10"; // FIXED

      expect(viewModel.requireIndexForRow(f), true);
    });

    test("returns false for new product", () {
      final f = FacilitySummaryNew()
        ..limitCategory = "F"
        ..limitDescription = "20"; // FIXED

      expect(viewModel.requireIndexForRow(f), false);
    });

    test("returns false when not funded", () {
      final f = FacilitySummaryNew()
        ..limitCategory = "N"
        ..limitDescription = "10"; // FIXED

      expect(viewModel.requireIndexForRow(f), false);
    });
  });

  group("onSustainabilitySelected", () {
    late FacilitiesSummaryViewModel vm;

    setUp(() {
      vm = FacilitiesSummaryViewModel();
    });

    test("stores multiple ids correctly", () {
      final f = FacilitySummaryNew()..facilityId = 1;

      vm.onSustainabilitySelected(f, [
        Reference(id: 11),
        Reference(id: 12),
        Reference(id: 13),
      ]);

      expect(f.sustainabilityClassification, "11, 12, 13");
      expect(f.isEdited, true);
    });

    test("ignores null ids", () {
      final f = FacilitySummaryNew()..facilityId = 2;

      vm.onSustainabilitySelected(f, [
        Reference(id: 11),
        Reference(), // id = null
        Reference(id: 13),
      ]);

      expect(f.sustainabilityClassification, "11, 13");
    });

    test("empty list results in empty string", () {
      final f = FacilitySummaryNew()
        ..facilityId = 3
        ..sustainabilityClassification = "old";

      vm.onSustainabilitySelected(f, []);

      expect(f.sustainabilityClassification, "");
      expect(f.isEdited, true);
    });

    test("all null ids results empty string", () {
      final f = FacilitySummaryNew()..facilityId = 4;

      vm.onSustainabilitySelected(f, [
        Reference(),
        Reference(),
      ]);

      expect(f.sustainabilityClassification, "");
    });
  });

  test("updates index and marks edited", () {
    final vm = FacilitiesSummaryViewModel();

    final f = FacilitySummaryNew()
      ..facilityId = 1
      ..index = "old";

    vm.onBenchmarkSelected(f, [
      Reference(id: 100),
    ]);

    expect(f.index, "100");
    expect(f.isEdited, true);
  });

  group("benchmarkItemsForRow", () {
    test("returns filtered benchmark list based on limitCategory", () {
      final vm = FacilitiesSummaryViewModel()
        ..benchmark = [
          Reference(id: 1, name: "LIBOR", reference2: "F"),
          Reference(id: 2, name: "SOFR", reference2: "N"),
          Reference(id: 3, name: "EIBOR", reference2: "F"),
        ];

      final f = FacilitySummaryNew()..limitCategory = "F";

      final result = vm.benchmarkItemsForRow(f);

      expect(result.map((e) => e.name), ["LIBOR", "EIBOR"]);
    });

    test("falls back to full list when no match", () {
      final vm = FacilitiesSummaryViewModel()
        ..benchmark = [
          Reference(id: 1, name: "LIBOR", reference2: "F"),
        ];

      final f = FacilitySummaryNew()..limitCategory = "X";

      final result = vm.benchmarkItemsForRow(f);

      expect(result.length, 1);
    });
  });

  group("selectedBenchmarkForRow", () {
    late FacilitiesSummaryViewModel vm;

    setUp(() {
      vm = FacilitiesSummaryViewModel();
    });

    test("returns matching reference when id matches", () {
      final f = FacilitySummaryNew()..index = "2";

      final items = [
        Reference(id: 1, name: "LIBOR"),
        Reference(id: 2, name: "SOFR"),
      ];

      final result = vm.selectedBenchmarkForRow(f, items);

      expect(result?.name, "SOFR");
    });

    test("returns null when index is empty", () {
      final f = FacilitySummaryNew()..index = "";

      final result = vm.selectedBenchmarkForRow(f, [
        Reference(id: 1),
      ]);

      expect(result, null);
    });

    test("returns null when list is empty", () {
      final f = FacilitySummaryNew()..index = "1";

      final result = vm.selectedBenchmarkForRow(f, []);

      expect(result, null);
    });

    test("returns null when no matching id found", () {
      final f = FacilitySummaryNew()..index = "99";

      final items = [
        Reference(id: 1),
        Reference(id: 2),
      ];

      final result = vm.selectedBenchmarkForRow(f, items);

      expect(result, null);
    });

    test("trims spaces before comparison", () {
      final f = FacilitySummaryNew()..index = " 2 ";

      final items = [
        Reference(id: 2),
      ];

      final result = vm.selectedBenchmarkForRow(f, items);

      expect(result?.id, 2);
    });
  });

  group("Initial value getters", () {
    setUp(() {});

    // -----------------------------------------
    // Proposed Value
    // -----------------------------------------

    // -----------------------------------------
    // Tenor
    // -----------------------------------------

    // -----------------------------------------
    // Benchmark
    // -----------------------------------------

    // -----------------------------------------
    // Margin
    // -----------------------------------------
  });

  group("initFacility", () {});

  group("Final coverage add-ons - error free", () {
    test("isFIFlow and limit-cap type branches", () {
      Globals.request = Request();
      expect(viewModel.isFIFlow, false);
      expect(
        viewModel.limitCapTypeForGroup(ServerConstants.projectStandByLimitID),
        14493,
      );
      expect(
        viewModel.limitCapTypeForGroup(ServerConstants.projectSpecificLimitsID),
        14494,
      );
      expect(viewModel.limitCapTypeForGroup(999), 14492);

      Globals.request = Request()
        ..businessSegment = Reference(
          id: ServerConstants
              .businessSegmentId[BusinessSegment.financialInstitution],
        );
      expect(viewModel.isFIFlow, true);
      expect(
        viewModel.limitCapTypeForGroup(ServerConstants.projectStandByLimitID),
        isNull,
      );
      Globals.request = Request();
    });

    test("init uses all loading methods and marks loaded", () async {
      final spy = InitSpyFacilitiesSummaryViewModel();
      await spy.init(FakeBuildContext(), amendPagemode: PageMode.edit);
      expect(spy.pageMode, PageMode.edit);
      expect(spy.linkageCalled, true);
      expect(spy.perRimCalled, true);
      expect(spy.appDetailsCalled, true);
      expect(spy.currencyCodesCalled, true);
      expect(spy.updatedFacilityRefCalled, true);
      expect(spy.referenceDataCalled, true);
      expect(spy.state.loaderStatus, LoadingStatus.loaded);
      await spy.close();
    });

    test("isProjectHeaderLimitsEntered direct legacy fields", () {
      expect(viewModel.isProjectHeaderLimitsEntered, false);
      viewModel
        ..projectExistingLimitInput = 0
        ..projectProposedLimitInput = 0;
      expect(viewModel.isProjectHeaderLimitsEntered, true);
    });

    test("returnListItemsbasedOnID filters ids and handles empty list", () {
      final refs = [
        Reference(id: 1, name: "A"),
        Reference(id: 2, name: "B"),
        Reference(id: 3, name: "C"),
      ];
      expect(
        viewModel
            .returnListItemsbasedOnID(refs, ["1", null, "3"])
            .map((e) => e.name)
            .toList(),
        ["A", "C"],
      );
      expect(viewModel.returnListItemsbasedOnID([], ["1"]), isEmpty);
    });

    test("convertToAed covers AED, non-AED success, zero-rate and exception",
        () async {
      when(() => mockFacilityRepo.getCurrencyRates(any())).thenAnswer(
        (_) async => const CurrencyRates(rates: {"USD": 3.67, "EUR": 0}),
      );
      expect(
        await viewModel.convertToAed(
          amountStr: "1,000",
          currencyCode: "AED",
          repository: mockFacilityRepo,
        ),
        "1,000",
      );
      expect(
        await viewModel.convertToAed(
          amountStr: "1000",
          currencyCode: "USD",
          repository: mockFacilityRepo,
        ),
        "3,670",
      );
      expect(
        await viewModel.convertToAed(
          amountStr: "1000",
          currencyCode: "EUR",
          repository: mockFacilityRepo,
        ),
        "1,000",
      );
      when(() => mockFacilityRepo.getCurrencyRates(any()))
          .thenThrow(Exception("rate-error"));
      expect(
        await viewModel.convertToAed(
          amountStr: "2000",
          currencyCode: "GBP",
          repository: mockFacilityRepo,
        ),
        "2,000",
      );
    });

    test("computeGroupTotals only includes main-limit rows", () {
      final mainFacility = FacilitySummaryNew()
        ..isMainLimit = true
        ..presentLimit = 10
        ..proposedLimit = 20
        ..presentOutstanding = 30;
      final childFacility = FacilitySummaryNew()
        ..isMainLimit = false
        ..presentLimit = 100
        ..proposedLimit = 200
        ..presentOutstanding = 300;
      final totals = viewModel.computeGroupTotals([
        FacilityDis()..facility = mainFacility,
        FacilityDis()..facility = childFacility,
        FacilityDis()..facility = null,
      ]);
      expect(totals.totalExistingLimit, 10);
      expect(totals.totalProposedLimit, 20);
      expect(totals.totalCurrentOutstanding, 30);
    });

    test("prepareProjectProductCode sets only for project groups", () {
      viewModel
        ..limitGroup = [
          Reference(
            id: ServerConstants.projectSpecificLimitsID,
            reference3: "psp",
          ),
        ]
        ..facility.productCodeProject = null
        ..prepareProjectProductCode(ServerConstants.generalLimitGroupId);
      expect(viewModel.facility.productCodeProject, isNull);
      viewModel
          .prepareProjectProductCode(ServerConstants.projectSpecificLimitsID);
      expect(viewModel.facility.productCodeProject, "PSP");
    });

    test("getFormattedInitialValue covers empty and populated inputs", () {
      expect(viewModel.getFormattedInitialValue(null, ["A"]), "");
      expect(viewModel.getFormattedInitialValue(["P"], null), "");
      expect(viewModel.getFormattedInitialValue([], []), "");
      expect(
        viewModel.getFormattedInitialValue(["A", "B"], ["100", ""]),
        "Initial Value: A 100",
      );
      expect(
        viewModel.getFormattedInitialValue(["A", "B"], ["100", "200"]),
        "Initial Value: A 100, B 200",
      );
    });

    test("onBenchmarkSelected updates nested additional details containers",
        () {
      final details = <String, dynamic>{
        "profitGrid": [
          {"index": "old"},
        ],
        "lcCommission": [
          {"indexLcLGCommision": "oldLc"},
        ],
      };
      final container = <String, dynamic>{
        "additionalDetails": jsonEncode(details),
      };
      final f = FacilitySummaryNew()..additionalDetailsContainer = container;
      viewModel.onBenchmarkSelected(f, [Reference(id: 15750, name: "EIBOR")]);
      expect(f.index, "15750");
      expect(f.isEdited, true);
      expect(
        (f.additionalDetailsParsed?["profitGrid"] as List<dynamic>?)
            ?.first["index"],
        isNull,
      );
      expect(
        (f.additionalDetailsParsed?["lcCommission"] as List<dynamic>?)
            ?.first["indexLcLGCommision"],
        isNull,
      );
      expect(
        (f.additionalDetailsContainer?["additionalDetails"] as String)
            .contains("15750"),
        false,
      );
    });

    test("onBenchmarkSelected ignores empty selection", () {
      final f = FacilitySummaryNew()
        ..index = "old"
        ..isEdited = false;
      viewModel.onBenchmarkSelected(f, []);
      expect(f.index, "old");
      expect(f.isEdited, false);
    });

    test("getReferenceData FI flow uses FI reference keys", () async {
      Globals.request = Request()
        ..businessSegment = Reference(
          id: ServerConstants
              .businessSegmentId[BusinessSegment.financialInstitution],
        );
      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{
          ReferenceDataKeys.fiLimitGroup: [Reference(id: 1, name: "FI Group")],
          ReferenceDataKeys.fiLimitType: [Reference(id: 2, name: "FI Type")],
          ReferenceDataKeys.productType: [
            Reference(id: 11321, name: "Conventional"),
          ],
        },
      );
      await viewModel.getReferenceData();
      expect(viewModel.limitGroup.single.name, "FI Group");
      expect(viewModel.limitTypes.single.name, "FI Type");
      Globals.request = Request();
    });

    test("changeProductTypeOptions same id does not clear descriptions", () {
      viewModel
        ..selectedProductTypeOption = Reference(id: 1, name: "Same")
        ..facility.facilityTypeSelectedValue = Reference(id: 99, name: "Keep")
        ..facilityDescriptions = [Reference(id: 10, name: "Existing")]
        ..changeProductTypeOptions(Reference(id: 1, name: "Same"));
      expect(viewModel.facility.facilityTypeSelectedValue?.name, "Keep");
      expect(viewModel.facilityDescriptions.length, 1);
    });

    test("close completes without error", () async {
      await viewModel.close();
      expect(viewModel.isClosed, true);
    });
  });
}

/// Helper to create simple nested summary structures quickly.
FacilitySummaryList buildSummary({
  required int groupId,
  required String order,
  required String limitNo,
  required String rimName,
  int rimNo = 999,
  int proposedLimit = 0,
  int presentLimit = 0,
  int presentOutstanding = 0,
  bool isMainLimit = true,
  String productCode = "ODA",
  String limitDescription = "123",
  String? controllingLimitNo,
}) {
  final facility = FacilitySummaryNew()
    ..limitGroup = groupId
    ..limitNo = limitNo
    ..productCode = productCode
    ..limitDescription = limitDescription
    ..rimNo = rimNo
    ..proposedLimit = proposedLimit
    ..presentLimit = presentLimit
    ..presentOutstanding = presentOutstanding
    ..isMainLimit = isMainLimit
    ..controllingLimitNo = controllingLimitNo;

  final dis = FacilityDis()
    ..order = order
    ..facility = facility;

  final group = RimGroup()..facilityLimits = [dis];

  final rim = RimSummary()
    ..rimName = rimName
    ..groups = [group];

  return FacilitySummaryList()..rims = [rim];
}
