import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:toastification/toastification.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/model.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/esg_certification.dart";
import "package:wcas_frontend/repositories/certification_repository.dart";

// ===========================================================================
// Silent AlertManager — prevents Toastification init crash in unit tests
// ===========================================================================
class _SilentAlertManager implements AlertManager {
  String? lastFailure;
  String? lastSuccess;

  @override
  void showFailureToast(String message) => lastFailure = message;
  @override
  void showSuccessToast(String message) => lastSuccess = message;
  @override
  void showInfoToast(String message) {}
  @override
  void showWarningToast(String message) {}
}

// ===========================================================================
// Mocks
// ===========================================================================
class MockCertRepo extends Mock implements CertificationRepository {}

class MockRefService extends Mock implements ReferenceDataService {}

// ===========================================================================
// Fakes / test doubles
// ===========================================================================
class FakeBuildContext extends Fake implements BuildContext {}

class FakeEsgCertification extends Fake implements EsgCertification {}

class TestEsgCertificationViewModel extends EsgCertificationViewModel {
  TestEsgCertificationViewModel({
    this.failRefData = false,
    this.failCertDetails = false,
    this.readOnly = false,
  });

  final bool failRefData;
  final bool failCertDetails;
  final bool readOnly;

  bool draftRegistered = false;
  bool draftLoaded = false;

  bool deleteDraftCalled = false;

  @override
  bool get isReadOnly => readOnly;

  @override
  Future<void> loadReferenceData() async {
    if (failRefData) {
      throw Exception("ref-fail");
    }
  }

  @override
  Future<void> fetchAndSetStrategyComments({
    dynamic dynamicSections,
    String? appRefNo,
  }) async {}

  @override
  Future<void> loadCertificationDetails() async {
    if (failCertDetails) {
      throw Exception("cert-fail");
    }
  }

  @override
  void registerDraftCallback() {
    draftRegistered = true;
  }

  @override
  Future<void> loadDraftIfAvailable() async {
    draftLoaded = true;
  }

  @override
  Future<void> deleteDraft() async {
    deleteDraftCalled = true;
  }
}

class FakeSffCategory extends SffCategory {
  FakeSffCategory({bool? isSelected, String? briefDesc, String? name})
      : super(
          sffCategoryId: 42,
          isSelected: isSelected ?? false,
          briefDesc: briefDesc ?? "",
          sffCategory: name,
        );
}

class FakeFacilityRiskRating extends FacilityRiskRating {
  FakeFacilityRiskRating()
      : super(
          borrowerRim: "R",
          facilityName: "F",
          sicCode: "S",
          esRating: "E",
          pctTotalLimit: 0.5,
        );
}

// ===========================================================================
// Helpers
// ===========================================================================
EsgCertification makeCert({
  String checklist = "CL",
  String? excludedActivity,
  bool? sffRequired,
  bool? sllRequired,
  bool? adverseMedia,
  String? adverseMediaSummary,
  List<SffCategory>? sffCategories,
  List<FacilityRiskRating>? esRiskRating,
  List<String>? listOfExcludedActivities,
}) {
  return EsgCertification(
    excludedActivity: excludedActivity ?? "YES",
    listOfExcludedActivities: listOfExcludedActivities ?? ["A"],
    sffCategories:
        sffCategories ?? [FakeSffCategory(isSelected: true, briefDesc: "ok")],
    esRiskRating: esRiskRating ?? [FakeFacilityRiskRating()],
    adverseMedia: adverseMedia ?? true,
    adverseMediaSummary: adverseMediaSummary ?? "none",
    additionalChecklist: checklist,
    sffRequired: sffRequired,
    sllRequired: sllRequired,
  );
}

/// Default fake reference data — 7 sections so dynamicSections is non-empty.
Map<String, List<Reference>> _fakeRefData({int sectionCount = 7}) {
  final sections = List.generate(
    sectionCount,
    (i) => Reference(id: i + 1, name: "S${i + 1}"),
  );
  return {
    ReferenceDataKeys.esgSectionTitles: sections,
    ReferenceDataKeys.esgAdittionalGuidance: [
      Reference(id: 10, name: "G1", description: "desc1", reference2: "1"),
      Reference(
        id: 11,
        name: "G2",
        description: "desc2",
        reference2: "1",
        reference3: "SEC1",
      ),
      Reference(
        id: 12,
        name: "G3",
        description: "desc3",
        reference2: "2",
        reference3: "SEC2",
      ),
      Reference(id: 13, name: "G_empty", reference2: ""),
      Reference(id: 14, name: "G_nonint", reference2: "abc"),
    ],
    ReferenceDataKeys.excludedActivityList: [Reference(id: 3, name: "SIC")],
    ReferenceDataKeys.esgSffCategory: [Reference(id: 4, name: "CAT")],
  };
}

/// Widget tree with ToastificationWrapper so toast paths don't crash.
Widget _tree(Widget child) => ToastificationWrapper(
      child: MaterialApp(home: Scaffold(body: child)),
    );

// ===========================================================================
// MAIN
// ===========================================================================
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(FakeSffCategory());
    registerFallbackValue(FakeFacilityRiskRating());
    registerFallbackValue(FakeEsgCertification());
  });

  late _SilentAlertManager alertSpy;
  late MockCertRepo mockRepo;
  late MockRefService mockRef;
  late EsgCertificationViewModel vm;

  setUp(() {
    alertSpy = _SilentAlertManager();
    AlertManager.overrideInstance(alertSpy);

    mockRepo = MockCertRepo();
    mockRef = MockRefService();
    ReferenceDataService.overrideInstance(mockRef);
    when(() => mockRef.getReferenceData(any()))
        .thenAnswer((_) async => _fakeRefData());

    Globals.user = User(id: "test-user", currentRole: Role(roleId: 1));

    vm = EsgCertificationViewModel();
    vm.repository = mockRepo;
  });

  // =========================================================================
  // EsgCertificationState
  // =========================================================================
  group("EsgCertificationState", () {
    test("constructor sets loaderStatus", () {
      const s = EsgCertificationState(loaderStatus: LoadingStatus.loading);
      expect(s.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith — no args keeps original values", () {
      const original =
          EsgCertificationState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith — overrides loaderStatus", () {
      const original =
          EsgCertificationState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith — overrides fieldVersion", () {
      const original = EsgCertificationState(
        loaderStatus: LoadingStatus.loaded,
        fieldVersion: 0,
      );
      final updated = original.copyWith(fieldVersion: 7);
      expect(updated.fieldVersion, 7);
    });

    test("copyWith — overrides additionalChecklist", () {
      const original = EsgCertificationState(
        loaderStatus: LoadingStatus.loaded,
        additionalChecklist: "old",
      );
      final updated = original.copyWith(additionalChecklist: "new");
      expect(updated.additionalChecklist, "new");
    });
  });

  // =========================================================================
  // init()
  // =========================================================================
  group("init()", () {
    late TestEsgCertificationViewModel vm;

    setUp(() {
      vm = TestEsgCertificationViewModel();

      vm.repository = mockRepo;
    });

    testWidgets("ref data error → shows failedRefData toast", (tester) async {
      final vm = TestEsgCertificationViewModel(failRefData: true);

      await tester.pumpWidget(_tree(Container()));
      final ctx = tester.element(find.byType(Container));

      await vm.init(ctx);
      await tester.pump();

      expect(alertSpy.lastFailure, contains("failedRefData"));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("cert details error → shows failedEsgDetails toast",
        (tester) async {
      final vm = TestEsgCertificationViewModel(failCertDetails: true);

      await tester.pumpWidget(_tree(Container()));
      final ctx = tester.element(find.byType(Container));

      await vm.init(ctx);
      await tester.pump();

      expect(alertSpy.lastFailure, contains("failedEsgDetails"));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("both succeed → loaderStatus ends as loaded", (tester) async {
      final vm = TestEsgCertificationViewModel();

      await tester.pumpWidget(_tree(Container()));
      final ctx = tester.element(find.byType(Container));

      await vm.init(ctx);
      await tester.pump();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("readOnly mode skips draft registration", (tester) async {
      final vm = TestEsgCertificationViewModel(readOnly: true);

      await tester.pumpWidget(_tree(Container()));
      final ctx = tester.element(find.byType(Container));

      await vm.init(ctx);
      await tester.pump();

      expect(vm.draftRegistered, isFalse);
      expect(vm.draftLoaded, isFalse);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  // =========================================================================
  // loadReferenceData()
  // =========================================================================
  group("loadReferenceData()", () {
    test("populates sectionTitles", () async {
      await vm.loadReferenceData();
      expect(vm.sectionTitles, isNotEmpty);
    });

    test("sectionTitles sorted ascending by id", () async {
      await vm.loadReferenceData();
      final ids = vm.sectionTitles!.map((r) => r.id ?? 0).toList();
      expect(ids, equals([...ids]..sort()));
    });

    test("additionalGuidelines sorted ascending by id", () async {
      await vm.loadReferenceData();
      final ids = vm.additionalGuidelines!.map((r) => r.id ?? 0).toList();
      expect(ids, equals([...ids]..sort()));
    });

    test("sicCodeLists populated", () async {
      await vm.loadReferenceData();
      expect(vm.sicCodeLists, isNotEmpty);
    });

    test("esgSffCategories populated", () async {
      await vm.loadReferenceData();
      expect(vm.esgSffCategories, isNotEmpty);
    });

    test("dynamicSections non-empty when > 6 sections", () async {
      await vm.loadReferenceData();
      expect(vm.dynamicSections, isNotEmpty);
    });

    test("dynamicSections empty when <= 6 sections", () async {
      when(() => mockRef.getReferenceData(any()))
          .thenAnswer((_) async => _fakeRefData(sectionCount: 6));
      await vm.loadReferenceData();
      expect(vm.dynamicSections, isEmpty);
    });

    test("guidanceBySectionId: section 1 gets G1 and G2", () async {
      await vm.loadReferenceData();
      expect(vm.guidanceBySectionId[1], hasLength(2));
    });

    test("guidanceBySectionId: section 2 gets G3", () async {
      await vm.loadReferenceData();
      expect(vm.guidanceBySectionId[2], hasLength(1));
    });

    test("guidanceBySectionAndPart: SEC1 indexed under section 1", () async {
      await vm.loadReferenceData();
      expect(vm.guidanceBySectionAndPart[1]?["SEC1"], isNotEmpty);
    });

    test("guidanceBySectionAndPart: SEC2 indexed under section 2", () async {
      await vm.loadReferenceData();
      expect(vm.guidanceBySectionAndPart[2]?["SEC2"], isNotEmpty);
    });

    test("guidance with empty reference2 is skipped", () async {
      await vm.loadReferenceData();
      final all = vm.guidanceBySectionId.values.expand((l) => l).toList();
      expect(all.any((r) => r.id == 13), isFalse);
    });

    test("guidance with non-integer reference2 is skipped", () async {
      await vm.loadReferenceData();
      final all = vm.guidanceBySectionId.values.expand((l) => l).toList();
      expect(all.any((r) => r.id == 14), isFalse);
    });

    test("re-running clears previous guidanceBySectionId cache", () async {
      await vm.loadReferenceData();
      final firstCount = vm.guidanceBySectionId.length;
      await vm.loadReferenceData();
      expect(vm.guidanceBySectionId.length, firstCount);
    });
  });

  // =========================================================================
  // guideline text helpers
  // =========================================================================
  group("guidelinesForSectionId()", () {
    setUp(() async => vm.loadReferenceData());

    test("returns joined descriptions for known section", () {
      final text = vm.guidelinesForSectionId(1);
      expect(text, contains("desc1"));
    });

    test("multiple guidelines joined with newline", () {
      final text = vm.guidelinesForSectionId(1);
      expect(text, contains("desc1"));
      expect(text, contains("desc2"));
    });

    test("returns empty string for unknown section id", () {
      expect(vm.guidelinesForSectionId(9999), isEmpty);
    });
  });

  group("guidelinesForSectionPart()", () {
    setUp(() async => vm.loadReferenceData());

    test("returns text for known section + part", () {
      final text = vm.guidelinesForSectionPart(1, "SEC1");
      expect(text, isNotEmpty);
    });

    test("returns empty for unknown part key", () {
      expect(vm.guidelinesForSectionPart(1, "UNKNOWN"), isEmpty);
    });

    test("returns empty for unknown section id", () {
      expect(vm.guidelinesForSectionPart(9999, "SEC1"), isEmpty);
    });
  });

  // =========================================================================
  // sectionIdAt()
  // =========================================================================
  group("sectionIdAt()", () {
    test("returns correct id at valid index", () async {
      await vm.loadReferenceData();
      final id = vm.sectionIdAt(0);
      expect(id, greaterThan(0));
    });

    test("returns 0 for out-of-bounds index", () async {
      await vm.loadReferenceData();
      expect(vm.sectionIdAt(999), 0);
    });

    test("returns 0 when sectionTitles is null", () {
      vm.sectionTitles = null;
      expect(vm.sectionIdAt(0), 0);
    });

    test("returns 0 when sectionTitles is empty", () {
      vm.sectionTitles = [];
      expect(vm.sectionIdAt(0), 0);
    });
  });

  // =========================================================================
  // loadCertificationDetails()
  // =========================================================================
  group("loadCertificationDetails()", () {
    test("empty cert resets all fields to defaults", () async {
      final empty = EsgCertification(
        excludedActivity: "",
        listOfExcludedActivities: [],
        sffCategories: [],
        esRiskRating: [],
        adverseMedia: false,
        adverseMediaSummary: "",
        additionalChecklist: "",
        sffRequired: false,
        sllRequired: false,
      );
      when(() => mockRepo.getEsgCertificationDetails())
          .thenAnswer((_) async => empty);

      await vm.loadCertificationDetails();

      expect(vm.sffRequired, isFalse);
      expect(vm.sllRequired, isFalse);
      expect(vm.esgSffCategoriess, isEmpty);
      expect(vm.facilitiesRiskRatings, isEmpty);
      expect(vm.adverseMediaSummary, "");
      expect(vm.additionalChecklist, "");
    });

    test("populated cert → all fields mapped correctly", () async {
      final cert = makeCert(
        checklist: "MyChecklist",
        sffRequired: true,
        sllRequired: true,
        excludedActivity: "YES",
        adverseMedia: true,
        adverseMediaSummary: "media-summary",
        listOfExcludedActivities: ["ACT1", "ACT2"],
      );
      when(() => mockRepo.getEsgCertificationDetails())
          .thenAnswer((_) async => cert);

      await vm.loadCertificationDetails();

      expect(vm.certifications.additionalChecklist, "MyChecklist");
      expect(vm.sffRequired, isTrue);
      expect(vm.sllRequired, isTrue);
      expect(vm.esgSffCategoriess.first.briefDesc, "ok");
      expect(vm.facilitiesRiskRatings, hasLength(1));
      expect(vm.adverseMediaSummary, "media-summary");
      expect(vm.isExcluded, "YES");
      expect(vm.excludedFlag, isTrue);
      expect(vm.excludedActivities, ["ACT1", "ACT2"]);
    });

    test("sffRequired=null treated as false", () async {
      final cert = makeCert(sffRequired: null);
      when(() => mockRepo.getEsgCertificationDetails())
          .thenAnswer((_) async => cert);
      await vm.loadCertificationDetails();
      expect(vm.sffRequired, isFalse);
    });

    test("sllRequired=null treated as false", () async {
      final cert = makeCert(sllRequired: null);
      when(() => mockRepo.getEsgCertificationDetails())
          .thenAnswer((_) async => cert);
      await vm.loadCertificationDetails();
      expect(vm.sllRequired, isFalse);
    });

    test("showSff / showSll are aliases for sffRequired / sllRequired",
        () async {
      final cert = makeCert(sffRequired: true, sllRequired: true);
      when(() => mockRepo.getEsgCertificationDetails())
          .thenAnswer((_) async => cert);
      await vm.loadCertificationDetails();
      expect(vm.showSff, isTrue);
      expect(vm.showSll, isTrue);
    });

    test("API error is rethrown", () async {
      when(() => mockRepo.getEsgCertificationDetails())
          .thenThrow(Exception("net-fail"));
      await expectLater(
        vm.loadCertificationDetails(),
        throwsA(isA<Object>()),
      );
    });
  });

  // =========================================================================
  // updateExcludedValue() & ExclusionStatus mapping
  // =========================================================================
  group("updateExcludedValue()", () {
    test("YES → excludedFlag=true", () {
      vm.updateExcludedValue("YES");
      expect(vm.excludedFlag, isTrue);
    });

    test("Yes → excludedFlag=true", () {
      vm.updateExcludedValue("Yes");
      expect(vm.excludedFlag, isTrue);
    });

    test("NO → excludedFlag=false", () {
      vm.updateExcludedValue("NO");
      expect(vm.excludedFlag, isFalse);
    });

    test("No → excludedFlag=false", () {
      vm.updateExcludedValue("No");
      expect(vm.excludedFlag, isFalse);
    });

    test("N/A → excludedFlag=null", () {
      vm.updateExcludedValue("N/A");
      expect(vm.excludedFlag, isNull);
    });

    test("unknown string → excludedFlag=null", () {
      vm.updateExcludedValue("BOGUS");
      expect(vm.excludedFlag, isNull);
    });

    test("non-excluded value clears excludedActivities", () {
      vm.excludedActivities = ["X", "Y"];
      vm.updateExcludedValue("NO");
      expect(vm.excludedActivities, isEmpty);
    });

    test("N/A clears excludedActivities", () {
      vm.excludedActivities = ["X", "Y"];
      vm.updateExcludedValue("N/A");
      expect(vm.excludedActivities, isEmpty);
    });

    test("unknown value clears excludedActivities", () {
      vm.excludedActivities = ["X"];
      vm.updateExcludedValue("BOGUS");
      expect(vm.excludedActivities, isEmpty);
    });

    test("excluded value preserves excludedActivities", () {
      vm.excludedActivities = ["X", "Y"];
      vm.updateExcludedValue("YES");
      expect(vm.excludedActivities, ["X", "Y"]);
    });

    test("emits loaded state", () {
      vm.updateExcludedValue("YES");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  // =========================================================================
  // updateExcludedActivities()
  // =========================================================================
  group("updateExcludedActivities()", () {
    test("replaces list and increments fieldVersion", () {
      final before = vm.fieldVersion;
      vm.updateExcludedActivities(["A", "B"]);
      expect(vm.excludedActivities, ["A", "B"]);
      expect(vm.fieldVersion, before + 1);
      expect(vm.state.fieldVersion, before + 1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("empty list clears activities", () {
      vm.excludedActivities = ["old"];
      vm.updateExcludedActivities([]);
      expect(vm.excludedActivities, isEmpty);
    });
  });

  // =========================================================================
  // updateAdditionalChecklist()
  // =========================================================================
  group("updateAdditionalChecklist()", () {
    test("capitalises first letter", () {
      vm.updateAdditionalChecklist("hello world");
      expect(vm.additionalChecklist, "Hello world");
    });

    test("state.additionalChecklist reflects raw value passed in", () {
      vm.updateAdditionalChecklist("xyz");
      expect(vm.state.additionalChecklist, "xyz");
    });

    test("emits loaded state", () {
      vm.updateAdditionalChecklist("text");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("empty string stays empty", () {
      vm.updateAdditionalChecklist("");
      expect(vm.additionalChecklist, "");
    });
  });

  // =========================================================================
  // updateAdverseMedia()
  // =========================================================================
  group("updateAdverseMedia()", () {
    test("localised yes key sets isAdverseMedia=true", () {
      // easy_localization returns the key itself in test env
      vm.updateAdverseMedia("certification.esgCertification.yes");
      expect(vm.isAdverseMedia, isTrue);
    });

    test("any other value sets isAdverseMedia=false", () {
      vm.updateAdverseMedia("No");
      expect(vm.isAdverseMedia, isFalse);
    });

    test("emits loaded state", () {
      vm.updateAdverseMedia("No");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  // =========================================================================
  // updateAdverseMediaSummary()
  // =========================================================================
  group("updateAdverseMediaSummary()", () {
    test("stores value", () {
      vm.updateAdverseMediaSummary("summary");
      expect(vm.adverseMediaSummary, "summary");
    });

    test("emits loaded state", () {
      vm.updateAdverseMediaSummary("x");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("accepts empty string", () {
      vm.updateAdverseMediaSummary("");
      expect(vm.adverseMediaSummary, "");
    });
  });

  // =========================================================================
  // updateCategorySelectionById()
  // =========================================================================
  group("updateCategorySelectionById()", () {
    test("selects existing category", () {
      final cat = FakeSffCategory(isSelected: false, name: "CAT_A");
      vm.esgSffCategoriess = [cat];
      vm.updateCategorySelectionById("CAT_A", true);
      expect(vm.esgSffCategoriess.first.isSelected, isTrue);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("deselects existing category", () {
      final cat = FakeSffCategory(isSelected: true, name: "CAT_A");
      vm.esgSffCategoriess = [cat];
      vm.updateCategorySelectionById("CAT_A", false);
      expect(vm.esgSffCategoriess.first.isSelected, isFalse);
    });

    test("null treated as false for existing category", () {
      final cat = FakeSffCategory(isSelected: true, name: "CAT_A");
      vm.esgSffCategoriess = [cat];
      vm.updateCategorySelectionById("CAT_A", null);
      expect(vm.esgSffCategoriess.first.isSelected, isFalse);
    });

    test("missing + newValue=true → adds new selected entry", () {
      vm.esgSffCategoriess = [];
      vm.updateCategorySelectionById("NEW_CAT", true);
      expect(vm.esgSffCategoriess.length, 1);
      expect(vm.esgSffCategoriess.first.sffCategory, "NEW_CAT");
      expect(vm.esgSffCategoriess.first.isSelected, isTrue);
    });

    test("missing + newValue=false → does NOT add entry", () {
      vm.esgSffCategoriess = [];
      vm.updateCategorySelectionById("GHOST", false);
      expect(vm.esgSffCategoriess, isEmpty);
    });

    test("missing + newValue=null → does NOT add entry", () {
      vm.esgSffCategoriess = [];
      vm.updateCategorySelectionById("GHOST", null);
      expect(vm.esgSffCategoriess, isEmpty);
    });
  });

  // =========================================================================
  // updateCategoryBriefDescById()
  // =========================================================================
  group("updateCategoryBriefDescById()", () {
    test("updates description for existing entry", () {
      final cat =
          FakeSffCategory(isSelected: true, briefDesc: "old", name: "CAT");
      vm.esgSffCategoriess = [cat];
      vm.updateCategoryBriefDescById("CAT", "new-desc");
      expect(vm.esgSffCategoriess.first.briefDesc, "new-desc");
    });

    test("adds new entry with isSelected=false when name not found", () {
      vm.esgSffCategoriess = [];
      vm.updateCategoryBriefDescById("MISSING", "desc!");
      expect(vm.esgSffCategoriess.length, 1);
      expect(vm.esgSffCategoriess.first.sffCategory, "MISSING");
      expect(vm.esgSffCategoriess.first.briefDesc, "desc!");
      expect(vm.esgSffCategoriess.first.isSelected, isFalse);
    });

    test("accepts empty description", () {
      final cat =
          FakeSffCategory(isSelected: true, briefDesc: "old", name: "CAT");
      vm.esgSffCategoriess = [cat];
      vm.updateCategoryBriefDescById("CAT", "");
      expect(vm.esgSffCategoriess.first.briefDesc, "");
    });
  });

  // =========================================================================
  // comment input helpers
  // =========================================================================
  group("initialTextOnceFor()", () {
    test("seeds from serverCommentsBySectionId when not yet set", () {
      vm.serverCommentsBySectionId[99] =
          Comment(categoryId: 99, strategyComment: "server-text");
      expect(vm.initialTextOnceFor(99), "server-text");
    });

    test("returns existing inputsByRefId if already primed", () {
      vm.inputsByRefId[10] = "user-typed";
      expect(vm.initialTextOnceFor(10), "user-typed");
    });

    test("returns empty string when no server data and no input", () {
      expect(vm.initialTextOnceFor(99999), "");
    });

    test("primes inputsByRefId from server on first call", () {
      vm.serverCommentsBySectionId[5] =
          Comment(categoryId: 5, strategyComment: "primed");
      vm.initialTextOnceFor(5);
      expect(vm.inputsByRefId[5], "primed");
    });
  });

  group("updateComment()", () {
    test("stores text in inputsByRefId", () {
      vm.updateComment(7, "hello");
      expect(vm.inputsByRefId[7], "hello");
    });

    test("emits loaded state", () {
      vm.updateComment(7, "hello");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("overwrites previous value for same refId", () {
      vm.updateComment(7, "first");
      vm.updateComment(7, "second");
      expect(vm.inputsByRefId[7], "second");
    });
  });

  group("clearCommentInputs()", () {
    setUp(() async => vm.loadReferenceData());

    test('leaveOneBlankPerSection=true seeds dynamic sections with ""', () {
      vm.inputsByRefId[1] = "dirty";
      vm.clearCommentInputs(leaveOneBlankPerSection: true);
      for (final ref in vm.dynamicSections) {
        expect(vm.inputsByRefId[ref.id ?? 0], "");
      }
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("leaveOneBlankPerSection=false fully clears map", () {
      vm.inputsByRefId[7] = "data";
      vm.clearCommentInputs(leaveOneBlankPerSection: false);
      expect(vm.inputsByRefId, isEmpty);
    });
  });

  // =========================================================================
  // fetchAndSetStrategyComments()
  // =========================================================================
  group("fetchAndSetStrategyComments()", () {
    test("empty sections list emits loaded immediately", () async {
      await vm.fetchAndSetStrategyComments(
        dynamicSections: [],
        appRefNo: "APP001",
      );
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    // test('on API error → catch block seeds blanks and emits loaded', () async
    // {
    //   final sections = [Reference(id: 88, name: 'SEC88')];
    //   try {
    //     await vm.fetchAndSetStrategyComments(
    //       dynamicSections: sections,
    //       appRefNo: 'X',
    //     );
    //   } catch (_) {}
    //   expect(vm.state.loaderStatus, LoadingStatus.loaded);
    // });

    // test('uses vm.dynamicSections when no argument provided', () async {
    //   await vm.loadReferenceData();
    //   try {
    //     await vm.fetchAndSetStrategyComments(appRefNo: 'APP');
    //   } catch (_) {}
    //   expect(vm.state.loaderStatus, LoadingStatus.loaded);
    // });
  });

  // =========================================================================
  // submitCertification() — guard: isSubmitting
  // =========================================================================
  group("submitCertification() — guard: isSubmitting", () {
    testWidgets("returns early when already submitting", (tester) async {
      await tester.pumpWidget(_tree(Form(key: vm.formKey, child: Container())));
      vm.isSubmitting = true;
      await vm.submitCertification();
      expect(alertSpy.lastFailure, isNull);
      expect(alertSpy.lastSuccess, isNull);
    });
  });

  // =========================================================================
  // submitCertification() — form validation failure
  // =========================================================================
  group("submitCertification() — form validation failure", () {
    testWidgets("no form rendered → fixValidationErrors toast", (tester) async {
      await tester.pump();
      await vm.submitCertification();
      expect(alertSpy.lastFailure, contains("fixValidationErrors"));
      expect(alertSpy.lastSuccess, isNull);
    });
  });

  // =========================================================================
  // submitCertification() — briefDesc validation
  // =========================================================================
  group("submitCertification() — briefDesc validation", () {
    testWidgets(
        "selected category with empty briefDesc → briefDescRequired toast",
        (tester) async {
      await tester.pumpWidget(_tree(Form(key: vm.formKey, child: Container())));
      vm.certifications = makeCert();
      vm.esgSffCategoriess = [
        FakeSffCategory(isSelected: true, briefDesc: ""),
      ];
      await vm.submitCertification();
      expect(alertSpy.lastFailure, contains("briefDescRequired"));
    });

    testWidgets("selected category with whitespace-only briefDesc → toast",
        (tester) async {
      await tester.pumpWidget(_tree(Form(key: vm.formKey, child: Container())));
      vm.certifications = makeCert();
      vm.esgSffCategoriess = [
        FakeSffCategory(isSelected: true, briefDesc: "   "),
      ];
      await vm.submitCertification();
      expect(alertSpy.lastFailure, contains("briefDescRequired"));
    });

    testWidgets("unselected category with empty briefDesc → passes validation",
        (tester) async {
      await tester.pumpWidget(_tree(Form(key: vm.formKey, child: Container())));
      vm.certifications = makeCert();
      vm.esgSffCategoriess = [
        FakeSffCategory(isSelected: false, briefDesc: ""),
      ];
      when(() => mockRepo.postEsgCertificationDetails(any()))
          .thenThrow(Exception("post-fail"));
      await vm.submitCertification();
      expect(alertSpy.lastFailure, isNot(contains("briefDescRequired")));
    });
  });

  // =========================================================================
  // submitCertification() — post failure
  // =========================================================================
  group("submitCertification() — post failure", () {
    testWidgets("API throws → error toast, isSubmitting reset, state=loaded",
        (tester) async {
      await tester.pumpWidget(_tree(Form(key: vm.formKey, child: Container())));
      vm.certifications = makeCert();
      vm.esgSffCategoriess = [
        FakeSffCategory(isSelected: true, briefDesc: "ok"),
      ];
      when(() => mockRepo.postEsgCertificationDetails(any()))
          .thenThrow(Exception("post-fail"));

      await vm.submitCertification();

      expect(alertSpy.lastFailure, contains("post-fail"));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.isSubmitting, isFalse);
    });
  });

  // =========================================================================
  // submitCertification() — post success
  // =========================================================================
  group("submitCertification() — post success", () {
    late TestEsgCertificationViewModel vm;

    setUp(() {
      vm = TestEsgCertificationViewModel();
      vm.repository = mockRepo;
    });

    testWidgets("successful post calls repository and applies response",
        (tester) async {
      await tester.pumpWidget(_tree(Form(key: vm.formKey, child: Container())));

      final responseCert = makeCert(
        checklist: "UPDATED",
        sffRequired: true,
        sllRequired: true,
        adverseMedia: false,
        adverseMediaSummary: "updated-summary",
        excludedActivity: "NO",
        listOfExcludedActivities: ["B"],
      );

      vm.certifications = makeCert();
      vm.esgSffCategoriess = [
        FakeSffCategory(isSelected: true, briefDesc: "ok"),
      ];

      when(() => mockRepo.postEsgCertificationDetails(any()))
          .thenAnswer((_) async => responseCert);

      await vm.submitCertification();
      await tester.pump();

      verify(() => mockRepo.postEsgCertificationDetails(any())).called(1);

      // check the flag, not vm.deleteDraft()
      expect(vm.deleteDraftCalled, isTrue);

      // optional extra checks
      expect(vm.additionalChecklist, "UPDATED");
      expect(vm.adverseMediaSummary, "updated-summary");
      expect(vm.isExcluded, "NO");
      expect(vm.excludedActivities, ["B"]);
    });

    testWidgets("_applyCertificationResponse updates all VM fields",
        (tester) async {
      await tester.pumpWidget(_tree(Form(key: vm.formKey, child: Container())));

      final responseCert = makeCert(
        checklist: "NEW_CL",
        sffRequired: true,
        sllRequired: false,
        adverseMedia: false,
        adverseMediaSummary: "resp-summary",
        excludedActivity: "NO",
        listOfExcludedActivities: [],
        esRiskRating: [],
      );

      vm.certifications = makeCert();
      vm.esgSffCategoriess = [
        FakeSffCategory(isSelected: true, briefDesc: "ok"),
      ];

      when(() => mockRepo.postEsgCertificationDetails(any()))
          .thenAnswer((_) async => responseCert);

      await vm.submitCertification();
      await tester.pump();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.deleteDraftCalled, isTrue);

      // verify response was applied
      expect(vm.additionalChecklist, "NEW_CL");
      expect(vm.sffRequired, isTrue);
      expect(vm.sllRequired, isFalse);
      expect(vm.isAdverseMedia, isFalse);
      expect(vm.adverseMediaSummary, "resp-summary");
      expect(vm.isExcluded, "NO");
      expect(vm.excludedActivities, isEmpty);
      expect(vm.facilitiesRiskRatings, isEmpty);
    });
  });

  // =========================================================================
  // submitComments()
  // =========================================================================
  group("submitComments()", () {
    test("empty dynamicSections → no submissions, emits loaded", () async {
      vm.dynamicSections = [];
      await vm.submitComments();
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("sections with empty inputs → skipped, emits loaded", () async {
      await vm.loadReferenceData();
      for (final ref in vm.dynamicSections) {
        vm.inputsByRefId[ref.id ?? 0] = "";
      }
      await vm.submitComments();
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    // test('sections with non-empty inputs → attempts save, emits loaded', ()
    // async {
    //   await vm.loadReferenceData();
    //   for (final ref in vm.dynamicSections) {
    //     vm.inputsByRefId[ref.id ?? 0] = 'comment text';
    //   }
    //   try {
    //     await vm.submitComments();
    //   } catch (_) {}
    //   expect(vm.state.loaderStatus, LoadingStatus.loaded);
    // });
  });

  // =========================================================================
  // pageMode / isReadOnly
  // =========================================================================
  group("pageMode & isReadOnly", () {
    test("default pagemode=na → isReadOnly=false", () {
      expect(vm.pagemode, PageMode.na);
      expect(vm.isReadOnly, isFalse);
    });

    test("pagemode=view → isReadOnly=true", () {
      vm.pagemode = PageMode.view;
      expect(vm.isReadOnly, isTrue);
    });

    test("pagemode=edit → isReadOnly=false", () {
      vm.pagemode = PageMode.edit;
      expect(vm.isReadOnly, isFalse);
    });
  });

  // =========================================================================
  // isFI flag
  // =========================================================================
  group("isFI flag", () {
    test("defaults to false", () {
      expect(vm.isFI, isFalse);
    });
  });

  // =========================================================================
  // close()
  // =========================================================================
  group("close()", () {
    test("completes without error", () async {
      await expectLater(vm.close(), completes);
    });
  });
}
