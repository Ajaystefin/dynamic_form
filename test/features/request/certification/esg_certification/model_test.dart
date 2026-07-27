import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
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
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/certification_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";

class MockCertificationRepository extends Mock
    implements CertificationRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeBuildContext extends Fake implements BuildContext {}

class FakeEsgCertification extends Fake implements EsgCertification {}

class FakeComment extends Fake implements Comment {}

class TestEsgCertificationViewModel extends EsgCertificationViewModel {
  TestEsgCertificationViewModel({
    this.failReferenceData = false,
    this.failCertificationDetails = false,
    this.forceReadOnly = false,
  });

  final bool failReferenceData;
  final bool failCertificationDetails;
  final bool forceReadOnly;

  bool draftRegistered = false;
  bool draftLoaded = false;
  bool deleteDraftCalled = false;
  bool submitCommentsCalled = false;

  @override
  bool get isReadOnly => forceReadOnly;

  @override
  Future<void> loadReferenceData() async {
    if (failReferenceData) {
      throw Exception("ref-fail");
    }

    sectionTitles = <Reference>[
      Reference(id: 1, name: "Section 1 General"),
      Reference(id: 2, name: "Section 2 ESG"),
      Reference(id: 5, name: "Section 5 Dynamic"),
    ];
    dynamicSections = <Reference>[
      Reference(id: 5, name: "Section 5 Dynamic"),
    ];
  }

  @override
  Future<void> fetchAndSetStrategyComments({
    List<Reference>? dynamicSections,
    String? appRefNo,
    bool manageLoader = true,
  }) async {}

  @override
  Future<void> loadCertificationDetails() async {
    if (failCertificationDetails) {
      throw Exception("cert-fail");
    }

    certifications = EsgCertification(
      excludedActivity: "",
      listOfExcludedActivities: <String>[],
      sffCategories: <SffCategory>[],
      esRiskRating: <FacilityRiskRating>[],
      adverseMedia: false,
      adverseMediaSummary: "",
      additionalChecklist: "",
      sffRequired: false,
      sllRequired: false,
    );
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

  @override
  Future<void> submitComments() async {
    submitCommentsCalled = true;
  }
}

class FakeSffCategory extends SffCategory {
  FakeSffCategory({
    bool? isSelected,
    String? briefDesc,
    String? name,
  }) : super(
          sffCategoryId: 1,
          sffCategory: name ?? "CAT",
          isSelected: isSelected ?? false,
          briefDesc: briefDesc ?? "",
        );
}

class FakeFacilityRiskRating extends FacilityRiskRating {
  FakeFacilityRiskRating()
      : super(
          borrowerRim: "RIM",
          facilityName: "Facility",
          sicCode: "SIC",
          esRating: "LOW",
          pctTotalLimit: 10,
        );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCertificationRepository mockRepository;
  late MockReferenceDataService mockReferenceDataService;
  late MockCommonRepository mockCommonRepository;
  late MockAlertManager mockAlertManager;
  late EsgCertificationViewModel vm;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(FakeEsgCertification());
    registerFallbackValue(FakeComment());
    registerFallbackValue(Comment());
  });

  setUp(() {
    EasyLocalization.logger.enableBuildModes = [];

    mockRepository = MockCertificationRepository();
    mockReferenceDataService = MockReferenceDataService();
    mockCommonRepository = MockCommonRepository();
    mockAlertManager = MockAlertManager();

    ReferenceDataService.overrideInstance = mockReferenceDataService;
    CommonRepository.overrideInstance = mockCommonRepository;
    AlertManager.overrideInstance = mockAlertManager;

    when(() => mockAlertManager.showFailureToast(any())).thenAnswer((_) {});
    when(() => mockAlertManager.showSuccessToast(any())).thenAnswer((_) {});
    when(() => mockAlertManager.showWarningToast(any())).thenAnswer((_) {});
    when(() => mockAlertManager.showInfoToast(any())).thenAnswer((_) {});

    Globals.user = User(
      id: "USER-1",
      currentRole: Role(roleId: 1),
    );

    Globals.request = Request(
      applicationRefNo: "APP-001",
      customerRimNo: 123,
    );

    vm = EsgCertificationViewModel()..repository = mockRepository;
  });

  Map<String, List<Reference>> referenceData({
    bool sectionNames = false,
  }) {
    final List<int> lockedIds =
        ServerConstants.esgSectionLockedReferenceIds.toList();

    final int lockedId1 = lockedIds.isNotEmpty ? lockedIds.first : 900001;
    final int lockedId2 = lockedIds.length > 1 ? lockedIds[1] : 900002;

    return <String, List<Reference>>{
      ReferenceDataKeys.esgSectionTitles: sectionNames
          ? <Reference>[
              Reference(id: 30, name: "Section 3 Media"),
              Reference(id: lockedId1, name: "Locked Standard 1"),
              Reference(id: lockedId2, name: "Locked Standard 2"),
              Reference(id: 60, name: "Section 6 Dynamic"),
              Reference(id: 70, name: "Other Dynamic Title"),
              Reference(id: 80, name: ""),
            ]
          : <Reference>[
              Reference(id: 3, name: "C"),
              Reference(id: 1, name: "A"),
              Reference(id: 2, name: "B"),
              Reference(id: 6, name: "Section 6 Dynamic"),
            ],
      ReferenceDataKeys.esgAdittionalGuidance: <Reference>[
        Reference(
          id: 20,
          name: "Guide 2",
          description: "Description 2",
          reference2: "1",
          reference3: "SEC1",
        ),
        Reference(
          id: 10,
          name: "Guide 1",
          description: "Description 1",
          reference2: "1",
        ),
        Reference(
          id: 30,
          name: "Guide 3",
          description: "",
          reference2: "2",
          reference3: "SEC2",
        ),
        Reference(id: 40, name: "Skip empty", reference2: ""),
        Reference(id: 50, name: "Skip invalid", reference2: "abc"),
      ],
      ReferenceDataKeys.excludedActivityList: <Reference>[
        Reference(id: 100, name: "SIC-1"),
      ],
      ReferenceDataKeys.esgSffCategory: <Reference>[
        Reference(id: 200, name: "SFF-1"),
      ],
    };
  }

  EsgCertification cert({
    String? excludedActivity = "YES",
    List<String>? excludedActivities,
    List<SffCategory>? categories,
    List<FacilityRiskRating>? ratings,
    bool? adverseMedia = true,
    String? adverseSummary = "media",
    String? checklist = "checklist",
    bool? sffRequired,
    bool? sllRequired,
  }) {
    return EsgCertification(
      excludedActivity: excludedActivity,
      listOfExcludedActivities: excludedActivities ?? <String>["A"],
      sffCategories: categories ??
          <SffCategory>[
            FakeSffCategory(
              isSelected: true,
              briefDesc: "ok",
              name: "CAT",
            ),
          ],
      esRiskRating: ratings ?? <FacilityRiskRating>[FakeFacilityRiskRating()],
      adverseMedia: adverseMedia,
      adverseMediaSummary: adverseSummary,
      additionalChecklist: checklist,
      sffRequired: sffRequired,
      sllRequired: sllRequired,
    );
  }

  group("EsgCertificationState", () {
    test("constructor and copyWith", () {
      const EsgCertificationState state = EsgCertificationState(
        loaderStatus: LoadingStatus.loading,
        additionalChecklist: "old",
      );

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.copyWith().loaderStatus, LoadingStatus.loading);

      final EsgCertificationState updated = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        additionalChecklist: "new",
        fieldVersion: 10,
      );

      expect(updated.loaderStatus, LoadingStatus.loaded);
      expect(updated.additionalChecklist, "new");
      expect(updated.fieldVersion, 10);
    });
  });

  group("draft and read only", () {
    test("draft getters", () {
      expect(vm.draftModuleKey, isNotEmpty);
      expect(vm.draftFormKey, isNotEmpty);
      expect(vm.draftHandler, isNotNull);
    });

    test("page modes", () {
      expect(vm.isReadOnly, false);

      vm.pagemode = PageMode.view;
      expect(vm.isReadOnly, true);

      vm.pagemode = PageMode.edit;
      expect(vm.isReadOnly, false);
    });

    test("show flags", () {
      vm
        ..sffRequired = true
        ..sllRequired = true;

      expect(vm.showSff, true);
      expect(vm.showSll, true);
    });

    test("close completes", () async {
      await expectLater(vm.close(), completes);
    });
  });

  group("init", () {
    testWidgets("success registers draft and loads", (tester) async {
      final TestEsgCertificationViewModel testVm =
          TestEsgCertificationViewModel()..repository = mockRepository;

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (context) => Container())),
      );

      final BuildContext context = tester.element(find.byType(Container));

      await testVm.init(context);

      expect(testVm.draftRegistered, true);
      expect(testVm.draftLoaded, true);
      expect(testVm.isInitCompleted, true);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("read only skips draft", (tester) async {
      final TestEsgCertificationViewModel testVm =
          TestEsgCertificationViewModel(forceReadOnly: true)
            ..repository = mockRepository;

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (context) => Container())),
      );

      final BuildContext context = tester.element(find.byType(Container));

      await testVm.init(context);

      expect(testVm.draftRegistered, false);
      expect(testVm.draftLoaded, false);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("reference error handled", (tester) async {
      final TestEsgCertificationViewModel testVm =
          TestEsgCertificationViewModel(failReferenceData: true)
            ..repository = mockRepository;

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (context) => Container())),
      );

      final BuildContext context = tester.element(find.byType(Container));

      await testVm.init(context);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("certification error handled", (tester) async {
      final TestEsgCertificationViewModel testVm =
          TestEsgCertificationViewModel(failCertificationDetails: true)
            ..repository = mockRepository;

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (context) => Container())),
      );

      final BuildContext context = tester.element(find.byType(Container));

      await testVm.init(context);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("loadReferenceData", () {
    test("loads and indexes reference data", () async {
      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenAnswer((_) async => referenceData(sectionNames: true));

      await vm.loadReferenceData();

      expect(vm.sectionTitles, isNotEmpty);
      expect(vm.additionalGuidelines, isNotEmpty);
      expect(vm.sicCodeLists, isNotEmpty);
      expect(vm.esgSffCategories, isNotEmpty);
      expect(vm.dynamicSections, isNotEmpty);
      expect(vm.guidanceBySectionId[1]?.length, 2);
      expect(vm.guidanceBySectionAndPart[1]?["SEC1"], isNotEmpty);
      expect(vm.guidanceBySectionAndPart[2]?["SEC2"], isNotEmpty);

      for (final Reference ref in vm.dynamicSections) {
        expect(
          ServerConstants.esgSectionLockedReferenceIds.contains(ref.id ?? 0),
          isFalse,
        );
      }
    });

    test("sorts by name if ids are zero or null", () async {
      when(() => mockReferenceDataService.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{
          ReferenceDataKeys.esgSectionTitles: <Reference>[
            Reference(name: "Zulu"),
            Reference(name: "Alpha"),
          ],
          ReferenceDataKeys.esgAdittionalGuidance: <Reference>[
            Reference(name: "Zulu", reference2: "1"),
            Reference(name: "Alpha", reference2: "1"),
          ],
          ReferenceDataKeys.excludedActivityList: <Reference>[],
          ReferenceDataKeys.esgSffCategory: <Reference>[],
        },
      );

      await vm.loadReferenceData();

      expect(vm.sectionTitles?.first.name, "Alpha");
      expect(vm.additionalGuidelines?.first.name, "Alpha");
    });

    test("empty map safe", () async {
      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenAnswer((_) async => <String, List<Reference>>{});

      await vm.loadReferenceData();

      expect(vm.sectionTitles, isEmpty);
      expect(vm.additionalGuidelines, isEmpty);
      expect(vm.sicCodeLists, isEmpty);
      expect(vm.esgSffCategories, isEmpty);
      expect(vm.dynamicSections, isEmpty);
    });

    test("throws upward", () async {
      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenThrow(Exception("ref"));

      expect(() => vm.loadReferenceData(), throwsException);
    });
  });

  group("section and guideline helpers", () {
    setUp(() async {
      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenAnswer((_) async => referenceData(sectionNames: true));
      await vm.loadReferenceData();
    });

    test("guidelinesForSectionId", () {
      expect(vm.guidelinesForSectionId(1), contains("Description 1"));
      expect(vm.guidelinesForSectionId(999), "");
    });

    test("guidelinesForSectionPart", () {
      expect(vm.guidelinesForSectionPart(1, "SEC1"), contains("Description 2"));
      expect(vm.guidelinesForSectionPart(1, "BAD"), "");
      expect(vm.guidelinesForSectionPart(999, "SEC1"), "");
    });

    test("sectionRefById, hasSectionId and sectionTitleById", () {
      vm.sectionTitles = <Reference>[
        Reference(id: 101, name: "Section A"),
        Reference(id: 102, name: "   "),
        Reference(id: 103),
      ];

      expect(vm.sectionRefById(101)?.name, "Section A");
      expect(vm.sectionRefById(999), isNull);

      expect(vm.hasSectionId(101), true);
      expect(vm.hasSectionId(999), false);

      expect(vm.sectionTitleById(101), "Section A");
      expect(
        vm.sectionTitleById(102, fallback: "Fallback 102"),
        "Fallback 102",
      );
      expect(
        vm.sectionTitleById(103, fallback: "Fallback 103"),
        "Fallback 103",
      );
      expect(
        vm.sectionTitleById(999, fallback: "Missing Fallback"),
        "Missing Fallback",
      );
    });

    test("sectionRefById handles null sectionTitles", () {
      vm.sectionTitles = null;

      expect(vm.sectionRefById(1), isNull);
      expect(vm.hasSectionId(1), false);
      expect(vm.sectionTitleById(1, fallback: "Fallback"), "Fallback");
    });

    test("guideline text falls back to name and skips blank", () {
      vm.guidanceBySectionId[99] = <Reference>[
        Reference(id: 1, description: " Description "),
        Reference(id: 2, name: "Name fallback"),
        Reference(id: 3, description: "   ", name: "   "),
      ];

      final String result = vm.guidelinesForSectionId(99);

      expect(result, contains("Description"));
      expect(result, contains("Name fallback"));
      expect(result.split("\n").length, 2);
    });
  });

  group("loadCertificationDetails", () {
    test("maps populated certification", () async {
      when(() => mockRepository.getEsgCertificationDetails()).thenAnswer(
        (_) async => cert(
          checklist: "Checklist",
          excludedActivities: <String>["A", "B"],
          sffRequired: true,
          sllRequired: true,
          adverseSummary: "summary",
        ),
      );

      await vm.loadCertificationDetails();

      expect(vm.certifications.additionalChecklist, "Checklist");
      expect(vm.sffRequired, true);
      expect(vm.sllRequired, true);
      expect(vm.showSff, true);
      expect(vm.showSll, true);
      expect(vm.esgSffCategoriess, isNotEmpty);
      expect(vm.facilitiesRiskRatings, isNotEmpty);
      expect(vm.isAdverseMedia, true);
      expect(vm.adverseMediaSummary, "summary");
      expect(vm.isExcluded, "YES");
      expect(vm.excludedFlag, true);
      expect(vm.excludedActivities, <String>["A", "B"]);
      expect(vm.additionalChecklist, "Checklist");
    });

    test("maps default null values", () async {
      when(() => mockRepository.getEsgCertificationDetails()).thenAnswer(
        (_) async => EsgCertification(excludedActivity: ""),
      );

      await vm.loadCertificationDetails();

      expect(vm.sffRequired, false);
      expect(vm.sllRequired, false);
      expect(vm.esgSffCategoriess, isEmpty);
      expect(vm.facilitiesRiskRatings, isEmpty);
      expect(vm.adverseMediaSummary, "");
      expect(vm.excludedActivities, isEmpty);
      expect(vm.additionalChecklist, "");
    });

    test("throws upward", () async {
      when(() => mockRepository.getEsgCertificationDetails())
          .thenThrow(Exception("cert"));

      expect(() => vm.loadCertificationDetails(), throwsException);
    });
  });

  group("excluded activity", () {
    test("updateExcludedValue NA clears", () {
      vm
        ..excludedActivities = <String>["A"]
        ..updateExcludedValue("NA");

      expect(vm.excludedFlag, isNull);
      expect(vm.excludedActivities, isEmpty);
    });

    test("updateExcludedValue N/A clears", () {
      vm
        ..excludedActivities = <String>["A"]
        ..updateExcludedValue("N/A");

      expect(vm.excludedFlag, isNull);
      expect(vm.excludedActivities, isEmpty);
    });

    test("updateExcludedValue unknown clears", () {
      vm
        ..excludedActivities = <String>["A"]
        ..updateExcludedValue("BAD");

      expect(vm.excludedFlag, isNull);
      expect(vm.excludedActivities, isEmpty);
    });

    test("updateExcludedActivities", () {
      final int before = vm.fieldVersion;

      vm.updateExcludedActivities(<String>["A", "B"]);

      expect(vm.excludedActivities, <String>["A", "B"]);
      expect(vm.fieldVersion, before + 1);
      expect(vm.state.fieldVersion, before + 1);
    });

    test("updateExcludedActivities empty", () {
      vm
        ..excludedActivities = <String>["OLD"]
        ..updateExcludedActivities(<String>[]);

      expect(vm.excludedActivities, isEmpty);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("simple update methods", () {
    test("updateAdditionalChecklist", () {
      vm.updateAdditionalChecklist("hello");

      expect(vm.additionalChecklist, "Hello");
      expect(vm.state.additionalChecklist, "hello");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateAdditionalChecklist empty", () {
      vm.updateAdditionalChecklist("");

      expect(vm.additionalChecklist, "");
    });

    test("updateAdverseMedia yes and no", () {
      vm.updateAdverseMedia("certification.esgCertification.yes");
      expect(vm.isAdverseMedia, true);

      vm.updateAdverseMedia("No");
      expect(vm.isAdverseMedia, false);
    });

    test("updateAdverseMediaSummary", () {
      vm.updateAdverseMediaSummary("summary");

      expect(vm.adverseMediaSummary, "summary");

      vm.updateAdverseMediaSummary("");
      expect(vm.adverseMediaSummary, "");
    });
  });

  group("category methods", () {
    test("updateCategorySelectionById existing", () {
      vm
        ..esgSffCategoriess = <SffCategory>[
          FakeSffCategory(name: "CAT", isSelected: false),
        ]
        ..updateCategorySelectionById("CAT", newValue: true);

      expect(vm.esgSffCategoriess.first.isSelected, true);

      vm.updateCategorySelectionById("CAT", newValue: false);
      expect(vm.esgSffCategoriess.first.isSelected, false);

      vm.updateCategorySelectionById("CAT");
      expect(vm.esgSffCategoriess.first.isSelected, false);
    });

    test("updateCategorySelectionById missing", () {
      vm
        ..esgSffCategoriess = <SffCategory>[]
        ..updateCategorySelectionById("NEW", newValue: true);

      expect(vm.esgSffCategoriess.length, 1);
      expect(vm.esgSffCategoriess.first.sffCategory, "NEW");
      expect(vm.esgSffCategoriess.first.isSelected, true);

      vm
        ..esgSffCategoriess = <SffCategory>[]
        ..updateCategorySelectionById("MISS", newValue: false);

      expect(vm.esgSffCategoriess, isEmpty);

      vm.updateCategorySelectionById("MISS");
      expect(vm.esgSffCategoriess, isEmpty);
    });

    test("updateCategoryBriefDescById", () {
      vm
        ..esgSffCategoriess = <SffCategory>[
          FakeSffCategory(name: "CAT", briefDesc: "old"),
        ]
        ..updateCategoryBriefDescById("CAT", "new");

      expect(vm.esgSffCategoriess.first.briefDesc, "new");

      vm.updateCategoryBriefDescById("MISS", "desc");
      expect(vm.esgSffCategoriess.last.sffCategory, "MISS");
      expect(vm.esgSffCategoriess.last.briefDesc, "desc");

      vm.updateCategoryBriefDescById("MISS", "");
      expect(vm.esgSffCategoriess.last.briefDesc, "");
    });
  });

  group("comment input helpers", () {
    test("initialTextOnceFor from input/server/empty", () {
      vm.inputsByRefId[1] = "typed";
      expect(vm.initialTextOnceFor(1), "typed");

      vm.serverCommentsBySectionId[2] =
          Comment(categoryId: 2, strategyComment: "server");

      expect(vm.initialTextOnceFor(2), "server");
      expect(vm.inputsByRefId[2], "server");

      expect(vm.initialTextOnceFor(999), "");
      expect(vm.inputsByRefId[999], "");
    });

    test("updateComment", () {
      vm.updateComment(1, "hello");
      expect(vm.inputsByRefId[1], "hello");

      vm.updateComment(1, "world");
      expect(vm.inputsByRefId[1], "world");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("clearCommentInputs true and false", () {
      vm
        ..dynamicSections = <Reference>[
          Reference(id: 1, name: "D1"),
          Reference(id: 2, name: "D2"),
        ]
        ..inputsByRefId[99] = "old"
        ..clearCommentInputs();

      expect(vm.inputsByRefId[1], "");
      expect(vm.inputsByRefId[2], "");

      vm.clearCommentInputs(leaveOneBlankPerSection: false);
      expect(vm.inputsByRefId, isEmpty);
    });
  });

  group("fetchAndSetStrategyComments", () {
    test("empty sections with loader", () async {
      await vm.fetchAndSetStrategyComments(
        dynamicSections: <Reference>[],
        appRefNo: "APP",
      );

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("empty sections without loader", () async {
      await vm.fetchAndSetStrategyComments(
        dynamicSections: <Reference>[],
        appRefNo: "APP",
        manageLoader: false,
      );

      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("uses vm.dynamicSections when parameter is null", () async {
      vm.dynamicSections = <Reference>[
        Reference(id: 33, name: "D33"),
      ];

      when(
        () => mockCommonRepository.getStategyComment(
          any(),
          any(),
          appRefNo: any(named: "appRefNo"),
        ),
      ).thenAnswer(
        (_) async => <Comment>[
          Comment(categoryId: 33, strategyComment: "vm-dynamic"),
        ],
      );

      await vm.fetchAndSetStrategyComments(appRefNo: "APP");

      expect(vm.inputsByRefId[33], "vm-dynamic");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("fetch comments success", () async {
      final List<Reference> sections = <Reference>[
        Reference(id: 10, name: "D10"),
        Reference(id: 20, name: "D20"),
      ];

      when(
        () => mockCommonRepository.getStategyComment(
          any(),
          any(),
          appRefNo: any(named: "appRefNo"),
        ),
      ).thenAnswer((invocation) async {
        final int refId = invocation.positionalArguments.first as int;
        return <Comment>[
          Comment(
            id: refId + 100,
            categoryId: refId,
            strategyComment: "comment-$refId",
          ),
        ];
      });

      await vm.fetchAndSetStrategyComments(
        dynamicSections: sections,
        appRefNo: "APP",
      );

      expect(vm.serverCommentsBySectionId[10]?.strategyComment, "comment-10");
      expect(vm.serverCommentsBySectionId[20]?.strategyComment, "comment-20");
      expect(vm.inputsByRefId[10], "comment-10");
      expect(vm.inputsByRefId[20], "comment-20");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("fetch comments ignores mismatched category", () async {
      final List<Reference> sections = <Reference>[
        Reference(id: 10, name: "D10"),
      ];

      when(
        () => mockCommonRepository.getStategyComment(
          any(),
          any(),
          appRefNo: any(named: "appRefNo"),
        ),
      ).thenAnswer(
        (_) async => <Comment>[
          Comment(categoryId: 999, strategyComment: "wrong"),
        ],
      );

      await vm.fetchAndSetStrategyComments(
        dynamicSections: sections,
        appRefNo: "APP",
      );

      expect(vm.serverCommentsBySectionId[10], isNull);
      expect(vm.inputsByRefId[10], "");
    });

    test("fetch comments catches error and seeds blanks", () async {
      final List<Reference> sections = <Reference>[
        Reference(id: 88, name: "D88"),
      ];

      when(
        () => mockCommonRepository.getStategyComment(
          any(),
          any(),
          appRefNo: any(named: "appRefNo"),
        ),
      ).thenThrow(Exception("comment error"));

      await vm.fetchAndSetStrategyComments(
        dynamicSections: sections,
        appRefNo: "APP",
      );

      expect(vm.inputsByRefId[88], "");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("submitComments", () {
    test("empty dynamic sections", () async {
      vm.dynamicSections = <Reference>[];

      await vm.submitComments();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("empty inputs skipped", () async {
      vm
        ..dynamicSections = <Reference>[Reference(id: 1, name: "D1")]
        ..inputsByRefId[1] = "";

      await vm.submitComments();

      verifyNever(
        () => mockCommonRepository.saveStategyComment(
          any(),
          appRefNo: any(named: "appRefNo"),
          rimNo: any(named: "rimNo"),
        ),
      );

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("save comments success clears and refreshes", () async {
      vm
        ..dynamicSections = <Reference>[Reference(id: 1, name: "D1")]
        ..inputsByRefId[1] = " hello "
        ..serverCommentsBySectionId[1] =
            Comment(id: 77, categoryId: 1, strategyComment: "old");

      when(
        () => mockCommonRepository.saveStategyComment(
          any(),
          appRefNo: any(named: "appRefNo"),
          rimNo: any(named: "rimNo"),
        ),
      ).thenAnswer((_) async {
        return "";
      });

      when(
        () => mockCommonRepository.getStategyComment(
          any(),
          any(),
          appRefNo: any(named: "appRefNo"),
        ),
      ).thenAnswer((_) async => <Comment>[]);

      await vm.submitComments();

      verify(
        () => mockCommonRepository.saveStategyComment(
          any(),
          appRefNo: any(named: "appRefNo"),
          rimNo: any(named: "rimNo"),
        ),
      ).called(1);

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("save comments partial failure shows toast", () async {
      vm
        ..dynamicSections = <Reference>[Reference(id: 1, name: "D1")]
        ..inputsByRefId[1] = "hello";

      when(
        () => mockCommonRepository.saveStategyComment(
          any(),
          appRefNo: any(named: "appRefNo"),
          rimNo: any(named: "rimNo"),
        ),
      ).thenThrow(Exception("save-comment-fail"));

      await vm.submitComments();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(vm.inputsByRefId[1], "hello");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("outer catch branch safe", () async {
      vm.dynamicSections = <Reference>[Reference(name: "D")];

      await vm.submitComments();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("submitCertification", () {
    testWidgets("already submitting returns", (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Form(key: vm.formKey, child: Container())),
      );

      vm.isSubmitting = true;

      await vm.submitCertification();

      verifyNever(() => mockRepository.postEsgCertificationDetails(any()));
    });

    testWidgets("brief desc validation fails", (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Form(key: vm.formKey, child: Container())),
      );

      vm
        ..certifications = cert()
        ..esgSffCategoriess = <SffCategory>[
          FakeSffCategory(isSelected: true, briefDesc: " "),
        ];

      await vm.submitCertification();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    testWidgets("excluded activity validation fails", (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Form(key: vm.formKey, child: Container())),
      );

      vm
        ..certifications = cert()
        ..isFI = false
        ..excludedStatus = ExclusionStatus.excluded
        ..excludedActivities = <String>[]
        ..esgSffCategoriess = <SffCategory>[
          FakeSffCategory(isSelected: false, briefDesc: ""),
        ];

      await vm.submitCertification();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    testWidgets("repository throws handled", (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Form(key: vm.formKey, child: Container())),
      );

      vm
        ..certifications = cert()
        ..isFI = true
        ..esgSffCategoriess = <SffCategory>[
          FakeSffCategory(isSelected: true, briefDesc: "ok"),
        ];

      when(() => mockRepository.postEsgCertificationDetails(any()))
          .thenThrow(Exception("post-fail"));

      await vm.submitCertification();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.error);
      expect(vm.isSubmitting, false);
    });

    testWidgets("success FI branch safe", (tester) async {
      final TestEsgCertificationViewModel testVm =
          TestEsgCertificationViewModel()..repository = mockRepository;

      await tester.pumpWidget(
        MaterialApp(home: Form(key: testVm.formKey, child: Container())),
      );

      testVm
        ..certifications = cert()
        ..isFI = true
        ..esgSffCategoriess = <SffCategory>[
          FakeSffCategory(isSelected: false, briefDesc: ""),
        ];

      when(() => mockRepository.postEsgCertificationDetails(any()))
          .thenAnswer((_) async => cert(excludedActivity: "NA"));

      await testVm.submitCertification();
      await tester.pump();

      expect(testVm.deleteDraftCalled, true);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });
  });
}
