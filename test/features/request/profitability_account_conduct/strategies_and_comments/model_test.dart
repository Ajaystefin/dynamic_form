import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

import "../../../../test_config.dart";

/* ================= MOCKS / FAKES ================= */

class MockProfitabilityRepository extends Mock
    implements ProfitabilityRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class SpyStrategiesAndCommentsViewModel extends StrategiesAndCommentsViewModel {
  bool loadCommentCategoryDataCalled = false;
  bool initializeCalled = false;
  bool fetchExistingStrategyCommentsCalled = false;
  bool fetchCommentCategoryMasterCalled = false;
  bool registerDraftCallbackCalled = false;
  bool loadDraftIfAvailableCalled = false;

  Map<String, List<Reference>> referenceMaster = <String, List<Reference>>{};
  List<dynamic> existingComments = <dynamic>[];

  bool shouldThrowOnFetchMaster = false;
  bool shouldThrowOnFetchExisting = false;

  @override
  Future<void> loadCommentCategoryData() async {
    loadCommentCategoryDataCalled = true;
    await super.loadCommentCategoryData();
  }

  @override
  Future<void> initialize(BuildContext? context) async {
    initializeCalled = true;
    await super.initialize(context);
  }

  @override
  void registerDraftCallback() {
    registerDraftCallbackCalled = true;
  }

  @override
  Future<void> loadDraftIfAvailable() async {
    loadDraftIfAvailableCalled = true;
  }

  @override
  Future<Map<String, List<Reference>>> fetchCommentCategoryMaster() async {
    fetchCommentCategoryMasterCalled = true;

    if (shouldThrowOnFetchMaster) {
      throw Exception("Boom");
    }

    return referenceMaster;
  }

  @override
  Future<List<dynamic>> fetchExistingStrategyComments() async {
    fetchExistingStrategyCommentsCalled = true;

    if (shouldThrowOnFetchExisting) {
      throw Exception("Existing comments failed");
    }

    return existingComments;
  }
}

class InitNoSuperSpyStrategiesAndCommentsViewModel
    extends SpyStrategiesAndCommentsViewModel {
  @override
  Future<void> initialize(BuildContext? context) async {
    initializeCalled = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}

class _ByIdEntry {
  _ByIdEntry({
    this.strategyComment,
    this.appStrategyCommentsId,
    this.categoryType,
  });

  final dynamic strategyComment;
  final dynamic appStrategyCommentsId;
  final dynamic categoryType;
}

/* ================= CONNECTIVITY ================= */

const MethodChannel kConnectivityChannel = MethodChannel(
  "dev.fluttercommunity.plus/connectivity",
);

void registerConnectivityStub() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    kConnectivityChannel,
    (MethodCall call) async {
      if (call.method == "check") {
        return <String>["wifi"];
      }
      return <String>["wifi"];
    },
  );
}

void unregisterConnectivityStub() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(kConnectivityChannel, null);
}

/* ================= HELPERS ================= */

List<Reference> allAllowedCategoryReferences() {
  return <Reference>[
    Reference(
      id: ServerConstants.relationshipStrategyCommentCategoryId,
      name: "Relationship Strategy",
    ),
    Reference(
      id: ServerConstants.depositsStrategyCommentCategoryId,
      name: "Deposit Strategy",
    ),
    Reference(
      id: ServerConstants.transactionalBankingCommentCategoryId,
      name: "Transactional Banking",
    ),
    Reference(
      id: ServerConstants.tradeFinanceCommentCategoryId,
      name: "Trade Finance",
    ),
    Reference(
      id: ServerConstants.treasuryCommentCategoryId,
      name: "Treasury",
    ),
    Reference(
      id: ServerConstants.ermCommentsCategoryId,
      name: "ERM",
    ),
    Reference(
      id: ServerConstants.esgCommentsCategoryId,
      name: "ESG",
    ),
  ];
}

void stubAlertManager(MockAlertManager alert) {
  when(() => alert.showFailureToast(any())).thenReturn(null);
  when(() => alert.showSuccessToast(any())).thenReturn(null);
  when(() => alert.showInfoToast(any())).thenReturn(null);
  when(() => alert.showWarningToast(any())).thenReturn(null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StrategiesAndCommentsViewModel vm;
  late MockProfitabilityRepository mockRepo;
  late MockAlertManager mockAlert;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
    await EasyLocalization.ensureInitialized();

    registerConnectivityStub();

    registerFallbackValue(CommentsType.strategyComments);
    registerFallbackValue(<Map<String, dynamic>>[]);
  });

  tearDownAll(() async {
    unregisterConnectivityStub();
    await TestConfig.cleanup();
  });

  setUp(() {
    mockRepo = MockProfitabilityRepository();
    mockAlert = MockAlertManager();

    AlertManager.overrideInstance = mockAlert;
    stubAlertManager(mockAlert);

    vm = StrategiesAndCommentsViewModel()..profitabilityRepository = mockRepo;
  });

  tearDown(() async {
    try {
      await vm.close();
    } on Object {
      // Ignore double-close / locally disposed instances in isolated tests.
    }
  });

  /* ================= INITIAL / CONFIG ================= */

  group("Initial state and config", () {
    test("initial state is loading", () {
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("state copyWith keeps and overrides loaderStatus", () {
      const StrategiesAndCommentsState initial = StrategiesAndCommentsState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(initial.copyWith().loaderStatus, LoadingStatus.loading);
      expect(
        initial.copyWith(loaderStatus: LoadingStatus.loaded).loaderStatus,
        LoadingStatus.loaded,
      );
    });

    test("draft config is correct", () {
      expect(
        vm.draftModuleKey,
        DraftModuleKeys.profitabilityAndAccountConduct,
      );
      expect(vm.draftFormKey, Routes.strategiesAndComments);
      expect(vm.draftHandler, isA<StrategiesAndCommentsDraftHandler>());
    });

    test("canEdit follows pageMode", () {
      vm.pageMode = PageMode.na;
      expect(vm.canEdit, false);

      vm.pageMode = PageMode.view;
      expect(vm.canEdit, false);

      vm.pageMode = PageMode.edit;
      expect(vm.canEdit, true);
    });

    test("scrollController exists", () {
      expect(vm.scrollController, isA<ScrollController>());
    });
  });

  /* ================= CATEGORY FILTERING ================= */

  group("selectAllowedCategories / filterAndProjectReferences", () {
    test("filters allowed ids and projects name", () {
      final List<Reference> refs = <Reference>[
        ...allAllowedCategoryReferences(),
        Reference(id: 999999, name: "Ignored"),
        Reference(name: "Null Id"),
      ];

      final List<Map<String, dynamic>> result =
          vm.selectAllowedCategories(refs);

      expect(result, hasLength(7));
      expect(
        result.map((Map<String, dynamic> e) => e["id"]),
        containsAll(<int>[
          ServerConstants.relationshipStrategyCommentCategoryId,
          ServerConstants.depositsStrategyCommentCategoryId,
          ServerConstants.transactionalBankingCommentCategoryId,
          ServerConstants.tradeFinanceCommentCategoryId,
          ServerConstants.treasuryCommentCategoryId,
          ServerConstants.ermCommentsCategoryId,
          ServerConstants.esgCommentsCategoryId,
        ]),
      );
      expect(result.any((Map<String, dynamic> e) => e["id"] == 999999), false);
    });

    test("missing name becomes empty string", () {
      final List<Map<String, dynamic>> result = vm.selectAllowedCategories(
        <Reference>[
          Reference(id: ServerConstants.relationshipStrategyCommentCategoryId),
        ],
      );

      expect(result, hasLength(1));
      expect(result.first["name"], "");
    });

    test("empty input returns empty output", () {
      expect(vm.selectAllowedCategories(<Reference>[]), isEmpty);
    });

    test("duplicates are preserved", () {
      const int id = ServerConstants.transactionalBankingCommentCategoryId;

      final List<Map<String, dynamic>> result = vm.selectAllowedCategories(
        <Reference>[
          Reference(id: id, name: "A"),
          Reference(id: id, name: "B"),
        ],
      );

      expect(result, hasLength(2));
      expect(result[0]["name"], "A");
      expect(result[1]["name"], "B");
    });

    test("compat wrapper filterAndProjectReferences delegates", () {
      const int id = ServerConstants.relationshipStrategyCommentCategoryId;

      final List<Map<String, dynamic>> result = vm.filterAndProjectReferences(
        <Reference>[Reference(id: id, name: "Relationship")],
      );

      expect(result, hasLength(1));
      expect(result.first["id"], id);
    });
  });

  /* ================= CATEGORY ID / NORMALIZATION ================= */

  group("category id helpers", () {
    test("getCategoryId returns null for null comment", () {
      expect(vm.getCategoryId(null), isNull);
      expect(vm.extractCategoryId(null), isNull);
    });

    test("getCategoryId returns categoryId", () {
      final Comment comment = Comment(categoryId: 42);

      expect(vm.getCategoryId(comment), 42);
      expect(vm.extractCategoryId(comment), 42);
    });

    test("getCategoryId returns null when categoryId is null", () {
      final Comment comment = Comment();

      expect(vm.getCategoryId(comment), isNull);
    });

    test("indexExistingCommentsByCategoryId skips null ids", () {
      final Comment a = Comment(strategyComment: "A");
      final Comment b = Comment(categoryId: 1, strategyComment: "B");

      final Map<int, dynamic> result = vm.indexExistingCommentsByCategoryId(
        <Comment>[a, b],
      );

      expect(result, hasLength(1));
      expect(result[1], same(b));
    });

    test("indexExistingCommentsByCategoryId last duplicate wins", () {
      final Comment first = Comment(categoryId: 7, strategyComment: "First");
      final Comment second = Comment(categoryId: 7, strategyComment: "Second");

      final Map<int, dynamic> result = vm.indexExistingCommentsByCategoryId(
        <Comment>[first, second],
      );

      expect(result, hasLength(1));
      expect(result[7], same(second));
    });

    test("normalizeByCategoryId wrapper delegates", () {
      final Comment a = Comment(categoryId: 1, strategyComment: "A");

      final Map<int, dynamic> result = vm.normalizeByCategoryId(<Comment>[a]);

      expect(result[1], same(a));
    });

    test("empty normalization returns empty", () {
      expect(vm.normalizeByCategoryId(<Comment>[]), isEmpty);
    });
  });

  /* ================= BUILD MAPS ================= */

  group("build maps", () {
    test(
        "buildCommentTextByCategoryId maps comments and defaults missing to empty",
        () {
      const int id1 = ServerConstants.relationshipStrategyCommentCategoryId;
      const int id2 = ServerConstants.depositsStrategyCommentCategoryId;

      final List<Map<String, dynamic>> categories = <Map<String, dynamic>>[
        <String, dynamic>{"id": id1, "name": "A"},
        <String, dynamic>{"id": id2, "name": "B"},
      ];

      final Map<int, dynamic> byId = <int, dynamic>{
        id1: _ByIdEntry(strategyComment: "Server Text"),
      };

      final Map<int, String> result = vm.buildCommentTextByCategoryId(
        categories,
        byId,
      );

      expect(result[id1], "Server Text");
      expect(result[id2], "");
    });

    test("buildCommentTextMap wrapper delegates", () {
      const int id = ServerConstants.relationshipStrategyCommentCategoryId;

      final Map<int, String> result = vm.buildCommentTextMap(
        <Map<String, dynamic>>[
          <String, dynamic>{"id": id, "name": "A"},
        ],
        <int, dynamic>{
          id: _ByIdEntry(strategyComment: "A"),
        },
      );

      expect(result[id], "A");
    });

    test("buildExistingRecordIdsByCategoryId includes non-null ids", () {
      const int id1 = ServerConstants.relationshipStrategyCommentCategoryId;
      const int id2 = ServerConstants.depositsStrategyCommentCategoryId;

      final Map<int, int> result = vm.buildExistingRecordIdsByCategoryId(
        <Map<String, dynamic>>[
          <String, dynamic>{"id": id1, "name": "A"},
          <String, dynamic>{"id": id2, "name": "B"},
        ],
        <int, dynamic>{
          id1: _ByIdEntry(appStrategyCommentsId: 123),
          id2: _ByIdEntry(),
        },
      );

      expect(result[id1], 123);
      expect(result.containsKey(id2), false);
    });

    test("buildExistingIdsMap wrapper delegates", () {
      const int id = ServerConstants.relationshipStrategyCommentCategoryId;

      final Map<int, int> result = vm.buildExistingIdsMap(
        <Map<String, dynamic>>[
          <String, dynamic>{"id": id, "name": "A"},
        ],
        <int, dynamic>{
          id: _ByIdEntry(appStrategyCommentsId: 77),
        },
      );

      expect(result[id], 77);
    });

    test("buildExistingRecordIdsByCategoryId empty refs returns empty", () {
      expect(
        vm.buildExistingRecordIdsByCategoryId(
          <Map<String, dynamic>>[],
          <int, dynamic>{},
        ),
        isEmpty,
      );
    });
  });

  /* ================= ATTACH / ENRICH TYPE ================= */

  group("attachCategoryTypeFromApi", () {
    test("assigns type from api", () {
      const int id1 = ServerConstants.relationshipStrategyCommentCategoryId;
      const int id2 = ServerConstants.depositsStrategyCommentCategoryId;

      final List<Map<String, dynamic>> result = vm.attachCategoryTypeFromApi(
        <Map<String, dynamic>>[
          <String, dynamic>{"id": id1, "name": "Relationship"},
          <String, dynamic>{"id": id2, "name": "Deposit"},
        ],
        <int, dynamic>{
          id1: _ByIdEntry(categoryType: "REL"),
          id2: _ByIdEntry(categoryType: "DEP"),
        },
      );

      expect(result[0]["type"], "REL");
      expect(result[1]["type"], "DEP");
    });

    test("type is null when missing", () {
      const int id = ServerConstants.relationshipStrategyCommentCategoryId;

      final List<Map<String, dynamic>> result = vm.attachCategoryTypeFromApi(
        <Map<String, dynamic>>[
          <String, dynamic>{"id": id, "name": "Relationship"},
        ],
        <int, dynamic>{},
      );

      expect(result.first["type"], isNull);
    });

    test("preserves original fields and creates new maps", () {
      const int id = ServerConstants.relationshipStrategyCommentCategoryId;
      final Map<String, dynamic> original = <String, dynamic>{
        "id": id,
        "name": "Relationship",
        "extra": 10,
      };

      final List<Map<String, dynamic>> result = vm.attachCategoryTypeFromApi(
        <Map<String, dynamic>>[original],
        <int, dynamic>{
          id: _ByIdEntry(categoryType: "REL"),
        },
      );

      expect(result.first["extra"], 10);
      expect(result.first["type"], "REL");
      expect(identical(result.first, original), false);
      expect(original.containsKey("type"), false);
    });

    test("empty categories returns empty", () {
      expect(
        vm.attachCategoryTypeFromApi(
          <Map<String, dynamic>>[],
          <int, dynamic>{},
        ),
        isEmpty,
      );
    });

    test("enrichReferencesWithType wrapper delegates", () {
      const int id = ServerConstants.relationshipStrategyCommentCategoryId;

      final List<Map<String, dynamic>> result = vm.enrichReferencesWithType(
        <Map<String, dynamic>>[
          <String, dynamic>{"id": id, "name": "A"},
        ],
        <int, dynamic>{
          id: _ByIdEntry(categoryType: "TYPE"),
        },
      );

      expect(result.first["type"], "TYPE");
    });
  });

  /* ================= LOAD DATA ORCHESTRATION ================= */

  group("loadCommentCategoryData / wrappers", () {
    test("loadCommentCategoryData builds maps and emits loaded", () async {
      const int id = ServerConstants.relationshipStrategyCommentCategoryId;

      final SpyStrategiesAndCommentsViewModel spy =
          SpyStrategiesAndCommentsViewModel()
            ..profitabilityRepository = mockRepo
            ..referenceMaster = <String, List<Reference>>{
              ReferenceDataKeys.strategyCommentsCategory: <Reference>[
                Reference(id: id, name: "Relationship"),
                Reference(id: 999999, name: "Ignored"),
              ],
            }
            ..existingComments = <dynamic>[
              Comment(
                categoryId: id,
                strategyComment: "Server Text",
                categoryType: "REL",
              ),
            ];

      await spy.loadCommentCategoryData();

      expect(spy.state.loaderStatus, LoadingStatus.loaded);
      expect(spy.fetchCommentCategoryMasterCalled, true);
      expect(spy.fetchExistingStrategyCommentsCalled, true);
      expect(spy.commentCategories, hasLength(1));
      expect(spy.commentCategories.first["id"], id);
      expect(spy.commentCategories.first["name"], "Relationship");
      expect(spy.commentCategories.first["type"], "REL");
      expect(spy.commentTextByCategoryId[id], "Server Text");
    });

    test("loadCommentCategoryData handles missing reference key", () async {
      final SpyStrategiesAndCommentsViewModel spy =
          SpyStrategiesAndCommentsViewModel()
            ..profitabilityRepository = mockRepo
            ..referenceMaster = <String, List<Reference>>{}
            ..existingComments = <dynamic>[];

      await spy.loadCommentCategoryData();

      expect(spy.state.loaderStatus, LoadingStatus.loaded);
      expect(spy.commentCategories, isEmpty);
      expect(spy.commentTextByCategoryId, isEmpty);
    });

    test("loadCommentCategoryData emits error on master exception", () async {
      final SpyStrategiesAndCommentsViewModel spy =
          SpyStrategiesAndCommentsViewModel()
            ..profitabilityRepository = mockRepo
            ..shouldThrowOnFetchMaster = true;

      await spy.loadCommentCategoryData();

      expect(spy.state.loaderStatus, LoadingStatus.error);
      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    test("loadCommentCategoryData emits error on existing comments exception",
        () async {
      final SpyStrategiesAndCommentsViewModel spy =
          SpyStrategiesAndCommentsViewModel()
            ..profitabilityRepository = mockRepo
            ..referenceMaster = <String, List<Reference>>{
              ReferenceDataKeys.strategyCommentsCategory: <Reference>[
                Reference(
                  id: ServerConstants.relationshipStrategyCommentCategoryId,
                  name: "Relationship",
                ),
              ],
            }
            ..shouldThrowOnFetchExisting = true;

      await spy.loadCommentCategoryData();

      expect(spy.state.loaderStatus, LoadingStatus.error);
      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    test("getReferenceData delegates", () async {
      final SpyStrategiesAndCommentsViewModel spy =
          SpyStrategiesAndCommentsViewModel()
            ..profitabilityRepository = mockRepo
            ..referenceMaster = <String, List<Reference>>{}
            ..existingComments = <dynamic>[];

      await spy.getReferenceData();

      expect(spy.loadCommentCategoryDataCalled, true);
    });

    test("fetchExistingComments delegates", () async {
      final SpyStrategiesAndCommentsViewModel spy =
          SpyStrategiesAndCommentsViewModel()
            ..existingComments = <dynamic>["comment"];

      final List<dynamic> result = await spy.fetchExistingComments();

      expect(spy.fetchExistingStrategyCommentsCalled, true);
      expect(result, <dynamic>["comment"]);
    });

    test("fetchReferenceMaster delegates", () async {
      final SpyStrategiesAndCommentsViewModel spy =
          SpyStrategiesAndCommentsViewModel()
            ..referenceMaster = <String, List<Reference>>{
              ReferenceDataKeys.strategyCommentsCategory: <Reference>[
                Reference(id: 1, name: "A"),
              ],
            };

      final Map<String, List<Reference>> result =
          await spy.fetchReferenceMaster();

      expect(spy.fetchCommentCategoryMasterCalled, true);
      expect(
        result[ReferenceDataKeys.strategyCommentsCategory]!.first.name,
        "A",
      );
    });
  });

  /* ================= INIT / INITIALIZE ================= */

  group("initialize / init", () {
    test("initialize calls loadCommentCategoryData", () async {
      final SpyStrategiesAndCommentsViewModel spy =
          SpyStrategiesAndCommentsViewModel()
            ..profitabilityRepository = mockRepo
            ..referenceMaster = <String, List<Reference>>{}
            ..existingComments = <dynamic>[];

      await spy.initialize(null);

      expect(spy.initializeCalled, true);
      expect(spy.loadCommentCategoryDataCalled, true);
    });

    test("init delegates to initialize", () async {
      final InitNoSuperSpyStrategiesAndCommentsViewModel spy =
          InitNoSuperSpyStrategiesAndCommentsViewModel();

      await spy.init(null);

      expect(spy.initializeCalled, true);
    });

    test("init triggers draft logic when canEdit true", () async {
      final InitNoSuperSpyStrategiesAndCommentsViewModel spy =
          InitNoSuperSpyStrategiesAndCommentsViewModel()
            ..pageMode = PageMode.edit;

      await spy.init(null);

      expect(spy.initializeCalled, true);
      expect(spy.registerDraftCallbackCalled, true);
      expect(spy.loadDraftIfAvailableCalled, true);
    });

    test("init does not trigger draft logic when canEdit false", () async {
      final InitNoSuperSpyStrategiesAndCommentsViewModel spy =
          InitNoSuperSpyStrategiesAndCommentsViewModel()
            ..pageMode = PageMode.view;

      await spy.init(null);

      expect(spy.initializeCalled, true);
      expect(spy.registerDraftCallbackCalled, false);
      expect(spy.loadDraftIfAvailableCalled, false);
    });
  });

  /* ================= UPDATE COMMENT ================= */

  group("updateComment", () {
    test("updateCommentTextForCategory updates map and emits", () {
      final StrategiesAndCommentsState before = vm.state;

      vm.updateCommentTextForCategory(10, "Updated");

      expect(vm.commentTextByCategoryId[10], "Updated");
      expect(vm.state, isNot(equals(before)));
    });

    test("updateComment wrapper delegates", () {
      vm.updateComment(20, "Value");

      expect(vm.commentTextByCategoryId[20], "Value");
    });

    test("multiple updates are stored", () {
      vm
        ..updateComment(1, "A")
        ..updateComment(2, "B");

      expect(vm.commentTextByCategoryId[1], "A");
      expect(vm.commentTextByCategoryId[2], "B");
    });
  });

  /* ================= CATEGORY TYPE RESOLUTION ================= */

  group("resolveCategoryTypeLabel", () {
    test("existing non-empty wins and trims", () {
      expect(
        vm.resolveCategoryTypeLabel(999, existing: " CUSTOM "),
        "CUSTOM",
      );
    });

    test("known ids return mapped types", () {
      expect(
        vm.resolveCategoryTypeLabel(
          ServerConstants.relationshipStrategyCommentCategoryId,
        ),
        ServerConstants.relationshipStrategyCommentCategoryType,
      );
      expect(
        vm.resolveCategoryTypeLabel(
          ServerConstants.depositsStrategyCommentCategoryId,
        ),
        ServerConstants.depositsStrategyCommentCategoryType,
      );
      expect(
        vm.resolveCategoryTypeLabel(
          ServerConstants.transactionalBankingCommentCategoryId,
        ),
        ServerConstants.transactionalBankingCommentCategoryType,
      );
      expect(
        vm.resolveCategoryTypeLabel(
          ServerConstants.tradeFinanceCommentCategoryId,
        ),
        ServerConstants.tradeFinanceCommentCategoryType,
      );
      expect(
        vm.resolveCategoryTypeLabel(
          ServerConstants.treasuryCommentCategoryId,
        ),
        ServerConstants.treasuryFinanceCommentCategoryType,
      );
      expect(
        vm.resolveCategoryTypeLabel(
          ServerConstants.esgCommentsCategoryId,
        ),
        ServerConstants.esgCommentCategoryType,
      );
      expect(
        vm.resolveCategoryTypeLabel(
          ServerConstants.ermCommentsCategoryId,
        ),
        ServerConstants.ermCommentCategoryType,
      );
    });

    test("unknown id returns fallback", () {
      expect(vm.resolveCategoryTypeLabel(999999), "Strategy Comments");
    });
  });

  /* ================= HTML / EDITOR HELPERS ================= */

  group("editor helpers", () {
    test("cleanHtml removes tags and nbsp", () {
      expect(
        vm.cleanHtml("<p>Hello&nbsp;World&amp;nbsp;Again</p>"),
        "Hello World Again",
      );
    });

    test("cleanHtml handles non-breaking unicode and trims", () {
      expect(vm.cleanHtml("  <b>A\u00A0B</b>  "), "A B");
    });

    test("initialTextOnceFor returns lastSaved once", () {
      vm.lastSavedPlainByCategoryId[1] = "Saved";

      expect(vm.initialTextOnceFor(1), "Saved");
      expect(vm.initialTextOnceFor(1), "");
    });

    test("initialTextOnceFor falls back to commentTextByCategoryId", () {
      vm.commentTextByCategoryId[2] = "Draft";

      expect(vm.initialTextOnceFor(2), "Draft");
    });

    test("initialTextOnceFor returns empty when no data", () {
      expect(vm.initialTextOnceFor(99), "");
    });

    test("resetSeedForDraftCategories allows reseeding", () {
      vm.lastSavedPlainByCategoryId[3] = "Text";

      expect(vm.initialTextOnceFor(3), "Text");
      expect(vm.initialTextOnceFor(3), "");

      vm.resetSeedForDraftCategories(<int>[3]);

      expect(vm.initialTextOnceFor(3), "Text");
    });

    test("getControllerFor returns same controller for same category", () {
      final controller1 = vm.getControllerFor(10);
      final controller2 = vm.getControllerFor(10);

      expect(identical(controller1, controller2), true);
    });

    test("getControllerFor creates controller with empty seed", () {
      final controller = vm.getControllerFor(20);

      expect(controller, isNotNull);
    });

    test("readEditorPlain returns empty when controller is absent", () async {
      final String result = await vm.readEditorPlain(99);

      expect(result, "");
    });

    test("readAllEditorsPlain returns map for absent controllers", () async {
      final Map<int, String> result =
          await vm.readAllEditorsPlain(<int>[1, 2, 3]);

      expect(result, <int, String>{
        1: "",
        2: "",
        3: "",
      });
    });

    test("applyDraftTextToMountedEditors does not crash without controllers",
        () {
      expect(
        () => vm.applyDraftTextToMountedEditors(
          <int, String>{
            1: "Draft",
            2: "Other",
          },
        ),
        returnsNormally,
      );
    });
  });

  /* ================= SEED SERVER DATA ================= */

  group("seedInitialFromServer", () {
    test("populates category, saved and record maps with empty seeds", () {
      vm.seedInitialFromServer(
        categories: <Map<String, dynamic>>[
          <String, dynamic>{"id": 1, "name": "A"},
          <String, dynamic>{"id": 2, "name": "B"},
        ],
        serverPlainTextById: <int, String>{
          1: "",
          2: "",
        },
        serverRecordIdsByCategoryId: <int, int>{
          1: 100,
          2: 200,
        },
      );

      expect(vm.commentCategories, hasLength(2));
      expect(vm.lastSavedPlainByCategoryId[1], "");
      expect(vm.lastSavedPlainByCategoryId[2], "");
      expect(vm.existingCommentRecordIdsByCategoryId[1], 100);
      expect(vm.existingCommentRecordIdsByCategoryId[2], 200);
    });

    test("seedInitialFromServer creates controllers safely with empty content",
        () {
      vm.seedInitialFromServer(
        categories: <Map<String, dynamic>>[
          <String, dynamic>{"id": 5, "name": "A"},
        ],
        serverPlainTextById: <int, String>{
          5: "",
        },
        serverRecordIdsByCategoryId: <int, int>{
          5: 500,
        },
      );

      expect(vm.initialTextOnceFor(5), "");
      expect(vm.existingCommentRecordIdsByCategoryId[5], 500);
    });

    test(
        "seedInitialFromServer trims lastSaved values without creating JS calls",
        () {
      vm.seedInitialFromServer(
        categories: <Map<String, dynamic>>[
          <String, dynamic>{"id": 6, "name": "A"},
        ],
        serverPlainTextById: <int, String>{
          6: "   ",
        },
        serverRecordIdsByCategoryId: <int, int>{
          6: 600,
        },
      );

      expect(vm.lastSavedPlainByCategoryId[6], "");
      expect(vm.existingCommentRecordIdsByCategoryId[6], 600);
    });
  });

  /* ================= SAVE COMMENTS ================= */

  group("saveComments", () {
    setUp(() {
      vm.profitabilityRepository = mockRepo;
    });

    test("no controllers skips API", () async {
      vm.commentCategories = <Map<String, dynamic>>[
        <String, dynamic>{"id": 1, "name": "A"},
      ];

      await vm.saveComments();

      verifyNever(
        () => mockRepo.saveApplicationStrategyDetailsDynamic(
          type: CommentsType.strategyComments,
          commentList: any(named: "commentList"),
        ),
      );
    });

    test("no payload with isContinue does not throw", () async {
      vm.commentCategories = <Map<String, dynamic>>[
        <String, dynamic>{"id": 1, "name": "A"},
      ];

      await vm.saveComments(isContinue: true);

      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("wrong category id type is caught and shows failure toast", () async {
      vm.commentCategories = <Map<String, dynamic>>[
        <String, dynamic>{"id": "bad"},
      ];

      await vm.saveComments();

      verify(() => mockAlert.showFailureToast(any())).called(1);
      verifyNever(
        () => mockRepo.saveApplicationStrategyDetailsDynamic(
          type: CommentsType.strategyComments,
          commentList: any(named: "commentList"),
        ),
      );
    });

    test("repository not called when category has no controller", () async {
      vm
        ..commentCategories = <Map<String, dynamic>>[
          <String, dynamic>{
            "id": ServerConstants.relationshipStrategyCommentCategoryId,
            "name": "Relationship",
          },
        ]
        ..commentTextByCategoryId = <int, String>{
          ServerConstants.relationshipStrategyCommentCategoryId: "Text",
        };

      await vm.saveComments();

      verifyNever(
        () => mockRepo.saveApplicationStrategyDetailsDynamic(
          type: CommentsType.strategyComments,
          commentList: any(named: "commentList"),
        ),
      );
    });
  });

  /* ================= LOCAL EQUIVALENT HELPERS ================= */

  group("local helper equivalents", () {
    int? asInt(value) {
      if (value == null) {
        return null;
      }
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value.trim());
      }
      return null;
    }

    String? asString(value) => value?.toString();

    test("asInt handles supported values", () {
      expect(asInt(7), 7);
      expect(asInt(12.9), 12);
      expect(asInt(" 300 "), 300);
      expect(asInt("abc"), isNull);
      expect(asInt(null), isNull);
      expect(asInt(Object()), isNull);
    });

    test("asString stringifies values", () {
      expect(asString(42), "42");
      expect(asString(8.5), "8.5");
      expect(asString("x"), "x");
      expect(asString(null), isNull);
    });

    test("normalize maps duplicate last wins", () {
      final List<Map<String, dynamic>> items = <Map<String, dynamic>>[
        <String, dynamic>{"categoryId": 10, "strategyComment": "A"},
        <String, dynamic>{"categoryId": 10, "strategyComment": "B"},
        <String, dynamic>{"categoryId": null, "strategyComment": "C"},
      ];

      final Map<int, Map<String, dynamic>> byId = <int, Map<String, dynamic>>{
        for (final Map<String, dynamic> item in items)
          if (asInt(item["categoryId"]) != null)
            asInt(item["categoryId"])!: item,
      };

      expect(byId, hasLength(1));
      expect(byId[10]!["strategyComment"], "B");
    });
  });

  /* ================= CLOSE ================= */

  group("close", () {
    test("local close completes safely", () async {
      final StrategiesAndCommentsViewModel local =
          StrategiesAndCommentsViewModel();

      await expectLater(local.close(), completes);
    });

    test("close with controllers completes safely", () async {
      final StrategiesAndCommentsViewModel local =
          StrategiesAndCommentsViewModel()
            ..getControllerFor(1)
            ..getControllerFor(2);

      await expectLater(local.close(), completes);
    });
  });
}
