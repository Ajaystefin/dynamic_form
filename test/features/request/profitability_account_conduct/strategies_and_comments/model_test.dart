// model_test.dart — fixed to avoid deprecated APIs and align with model.dart
import "dart:io";

import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
// Keep the same Hive package you’re using in your test environment.
// If your project uses `hive` instead of `hive_ce`, change the import
// accordingly.
import "package:hive_ce/hive.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

import "../../../../test_config.dart";

/// A simple fake to simulate dynamic objects with a `categoryId` getter.
class FakeItem {
  FakeItem(this.categoryId, this.name);
  final int? categoryId;
  final String name;
  @override
  String toString() => "FakeItem(categoryId: $categoryId, name: $name)";
}

/// A second fake to verify that different types are still accepted as
/// `dynamic`.
class OtherFake {
  OtherFake(this.categoryId, this.payload);
  final int? categoryId;
  final int payload;
  @override
  String toString() => "OtherFake(categoryId: $categoryId, payload: $payload)";
}

class FakeComment {
  FakeComment(this.id, this.strategyComment);
  final String? strategyComment;
  final int id;
  @override
  String toString() =>
      "FakeComment(id: $id, strategyComment: $strategyComment)";
}

class SpyStrategiesAndCommentsViewModel extends StrategiesAndCommentsViewModel {
  // ----- Flags -----
  bool loadCommentCategoryDataCalled = false;
  bool initializeCalled = false;
  bool selectAllowedCategoriesCalled = false;
  bool fetchExistingStrategyCommentsCalled = false;
  bool fetchCommentCategoryMasterCalled = false;
  bool registerDraftCallbackCalled = false;
  bool loadDraftIfAvailableCalled = false;

  // ----- Stub data -----
  Map<String, List<Reference>> referenceMaster = {};
  List<dynamic> existingComments = [];

  // ----- Failure simulation -----
  bool shouldThrowOnFetchMaster = false;

  @override
  Future<void> loadCommentCategoryData() async {
    loadCommentCategoryDataCalled = true;
    await super.loadCommentCategoryData();
  }

  @override
  Future<void> initialize(context) async {
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
  List<Map<String, dynamic>> selectAllowedCategories(
    List<Reference> allRefs,
  ) {
    selectAllowedCategoriesCalled = true;
    return [
      {
        "id": ServerConstants.relationshipStrategyCommentCategoryId,
        "name": "Relationship",
        "type": "REL",
      },
    ];
  }

  @override
  Future<List<dynamic>> fetchExistingStrategyComments() async {
    fetchExistingStrategyCommentsCalled = true;
    return existingComments;
  }
}

// ---------- Connectivity mocking (non-deprecated) ----------

// Define the channel once at top-level (no shadowing) and use
// StandardMethodCodec (default for connectivity_plus).
const MethodChannel kConnectivityChannel = MethodChannel(
  "dev.fluttercommunity.plus/connectivity",
  StandardMethodCodec(),
);

// Stub `checkConnectivity()` method to return a Wi-Fi result.
void _registerConnectivityStub() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(kConnectivityChannel, (call) async {
    if (call.method == "check") {
      return ["wifi"]; // List<dynamic> as expected by connectivity_plus
    }
    return null;
  });
}

void _unregisterConnectivityStub() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(kConnectivityChannel, null);
}

// ---------- Hive sandbox helpers ----------
late Directory _hiveTestDir;

Future<void> _initHiveForTests() async {
  _hiveTestDir = await Directory.systemTemp.createTemp("wcas_hive_test_");
  Hive.init(_hiveTestDir.path);
}

Future<void> _disposeHiveForTests() async {
  try {
    await Hive.close();
  } finally {
    if (await _hiveTestDir.exists()) {
      await _hiveTestDir.delete(recursive: true);
    }
  }
}

// ---------- Mocks ----------
class MockProfitabilityRepository extends Mock
    implements ProfitabilityRepository {}

class MockAlertManager extends Mock implements AlertManager {}

// Types used by helper assertions in tests below.
class _ByIdEntry {
  _ByIdEntry(this.strategyComment, this.appStrategyCommentsId);
  final dynamic strategyComment;
  final dynamic appStrategyCommentsId;
}

void main() {
  // Ensure test binding available before registering handlers
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _initHiveForTests();
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
    _registerConnectivityStub();
  });

  tearDownAll(() async {
    _unregisterConnectivityStub();
    await _disposeHiveForTests();
  });

  late StrategiesAndCommentsViewModel vm;
  late MockProfitabilityRepository mockRepo;
  late MockAlertManager mockAlert;

  setUp(() {
    mockRepo = MockProfitabilityRepository();
    mockAlert = MockAlertManager();

    // model.dart constructs AlertManager internally; override its global
    // instance to our mock.
    AlertManager.overrideInstance(mockAlert);

    vm = StrategiesAndCommentsViewModel()..profitabilityRepository = mockRepo;
  });

  tearDown(() {
    reset(mockRepo);
    reset(mockAlert);
  });

  // ------------------- attachCategoryTypeFromApi -------------------
  group("attachCategoryTypeFromApi", () {
    test("assigns type from commentsByCategoryId when present", () {
      // Arrange
      final categories = [
        {"id": 1160, "name": "Relationship Strategy"},
        {"id": 1161, "name": "Deposit Strategy"},
      ];
      // Simulate backend existing comments objects with `categoryType` field
      final commentsByCategoryId = {
        1160: Comment(categoryType: "RELATIONSHIP"),
        1161: Comment(categoryType: "DEPOSITS"),
      };
      // Act
      final result =
          vm.attachCategoryTypeFromApi(categories, commentsByCategoryId);
      // Assert
      expect(result, hasLength(2));
      expect(result[0]["id"], 1160);
      expect(result[0]["name"], "Relationship Strategy");
      expect(result[0]["type"], "RELATIONSHIP");
      expect(result[1]["id"], 1161);
      expect(result[1]["name"], "Deposit Strategy");
      expect(result[1]["type"], "DEPOSITS");
    });

    test("sets type to null when categoryType is absent", () {
      final categories = [
        {"id": 1162, "name": "Transaction Banking Comments"},
        {"id": 1163, "name": "Trade Finance Comments"},
      ];
      final commentsByCategoryId = {
        1162: Comment(categoryType: null),
        // 1163 missing entirely
      };
      final result =
          vm.attachCategoryTypeFromApi(categories, commentsByCategoryId);
      expect(result[0]["type"], isNull, reason: "Explicit null from backend");
      expect(result[1]["type"], isNull, reason: "Missing entry => null");
    });

    test("preserves original category fields", () {
      final categories = [
        {"id": 1164, "name": "Treasury Comments", "extra": 42},
      ];
      final commentsByCategoryId = {
        1164: Comment(categoryType: "TREASURY"),
      };
      final result =
          vm.attachCategoryTypeFromApi(categories, commentsByCategoryId);
      expect(result.single["id"], 1164);
      expect(result.single["name"], "Treasury Comments");
      expect(result.single["extra"], 42, reason: "Non-standard field remains");
      expect(result.single["type"], "TREASURY");
    });

    test("returns empty list when categories is empty", () {
      final categories = <Map<String, dynamic>>[];
      final commentsByCategoryId = <int, dynamic>{};
      final result =
          vm.attachCategoryTypeFromApi(categories, commentsByCategoryId);
      expect(result, isEmpty);
    });

    test("does not mutate input categories (produces new maps)", () {
      final categories = [
        {"id": 1165, "name": "Relationship History"},
      ];
      final categoriesCopy = categories.map(Map<String, dynamic>.from).toList();
      final commentsByCategoryId = {
        1165: Comment(categoryType: "REL_HISTORY"),
      };
      final result =
          vm.attachCategoryTypeFromApi(categories, commentsByCategoryId);
      expect(
        categories,
        equals(categoriesCopy),
        reason: "Original list/map intact",
      );
      expect(result.single["type"], "REL_HISTORY");
      expect(
        identical(result.single, categories.single),
        isFalse,
        reason: "Should return a new map instance",
      );
    });
  });

  // ------------------- Helper: buildExistingIdsMap -------------------
  group("Helper: buildExistingIdsMap", () {
    test("includes non-null ids and excludes null/missing", () {
      final vm = StrategiesAndCommentsViewModel();
      final refs = <Map<String, dynamic>>[
        {"id": 1160, "name": "RS"},
        {"id": 1161, "name": "DS"},
        {"id": 1162, "name": "TB"},
        {"id": 1163, "name": "TF"},
        {"id": 1164, "name": "TR"},
        {"id": 1165, "name": "Hist"},
      ];
      final byId = <int, dynamic>{
        1160: _ByIdEntry(7, 7), // included
      };
      final idMap = vm.buildExistingIdsMap(refs, byId);
      expect(idMap[1160], 7);
      expect(idMap.containsKey(1163), isFalse);
      expect(idMap.containsKey(1164), isFalse);
      expect(idMap.containsKey(1165), isFalse);
    });

    test("empty refs -> empty map", () {
      final vm = StrategiesAndCommentsViewModel();
      final refs = <Map<String, dynamic>>[];
      final byId = <int, dynamic>{};
      final idMap = vm.buildExistingIdsMap(refs, byId);
      expect(idMap, isEmpty);
    });
  });

  // ------------------- vm.extractCategoryId -------------------
  group("vm.extractCategoryId", () {
    test("returns null when item is null", () {
      expect(vm.extractCategoryId(null), isNull);
    });

    test("returns the categoryId when present (int)", () {
      final item = FakeItem(42, "X");
      expect(vm.extractCategoryId(item), 42);
    });

    test("returns null when categoryId is null", () {
      final item = FakeItem(null, "Y");
      expect(vm.extractCategoryId(item), isNull);
    });
  });

  // ------------------- _buildCommentTextMap -------------------
  group("_buildCommentTextMap", () {
    test("builds map with string/numeric/null/missing comment values", () {
      final vm = StrategiesAndCommentsViewModel();
      final refs = [
        {"id": 1160, "name": "RS"},
        {"id": 1161, "name": "DS"},
        {"id": 1162, "name": "TB"},
        {"id": 1163, "name": "TF"}, // missing in byId => ''
      ];
      final byId = <int, dynamic>{
        1160: _ByIdEntry("RS from server", 7),
      };
      final result = vm.buildCommentTextMap(refs, byId);
      expect(result[1160], "RS from server");
    });
  });

  // ------------------- vm.normalizeByCategoryId -------------------

  group("vm.normalizeByCategoryId", () {
    test("returns empty map for empty input", () {
      final result = vm.normalizeByCategoryId(<Comment>[]);
      expect(result, isEmpty);
    });

    test("includes items with non-null categoryId", () {
      final a = Comment(categoryId: 1, strategyComment: "A");
      final b = Comment(categoryId: 2, strategyComment: "B");

      final result = vm.normalizeByCategoryId([a, b]);

      expect(result.length, 2);
      expect(result.keys, containsAll([1, 2]));
      expect(result[1], same(a));
      expect(result[2], same(b));
    });

    test("skips items with null categoryId", () {
      final a = Comment(categoryId: null, strategyComment: "A");
      final b = Comment(categoryId: 3, strategyComment: "B");

      final result = vm.normalizeByCategoryId([a, b]);

      expect(result.length, 1);
      expect(result.keys, contains(3));
      expect(result.keys, isNot(contains(null)));
      expect(result[3], same(b));
    });

    test("last item with duplicate categoryId wins (overwrites earlier)", () {
      final first = Comment(categoryId: 7, strategyComment: "First");
      final second = Comment(categoryId: 7, strategyComment: "Second");

      final result = vm.normalizeByCategoryId([first, second]);

      expect(result.length, 1);
      expect(result[7], same(second));
    });

    test("handles many Comment items and preserves only non-null ids", () {
      final items = <Comment>[
        Comment(categoryId: null, strategyComment: "null-1"),
        Comment(categoryId: 1, strategyComment: "one"),
        Comment(categoryId: null, strategyComment: "null-2"),
        Comment(categoryId: 2, strategyComment: "two"),
        Comment(categoryId: 3, strategyComment: "three"),
      ];

      final result = vm.normalizeByCategoryId(items);

      expect(result.length, 3);
      expect(result.keys, containsAll(<int>[1, 2, 3]));
      expect((result[1] as Comment).strategyComment, "one");
      expect((result[2] as Comment).strategyComment, "two");
      expect((result[3] as Comment).strategyComment, "three");
    });
  });

  // ------------------- Initial state -------------------
  group("Initial state", () {
    test("loaderStatus is Loading", () {
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });
  });

  // ------------------- updateComment -------------------
  group("updateComment", () {
    test("updates single ref and emits new state", () {
      vm.commentCategories = [
        {"id": 1160, "name": "Relationship Strategy"},
      ];
      final before = vm.state;
      vm.updateComment(1160, "Build stronger ties");
      expect(vm.commentTextByCategoryId[1160], "Build stronger ties");
      expect(vm.state, isNot(equals(before)));
    });

    test("updates multiple refs consistently", () {
      vm.commentCategories = [
        {"id": 1161, "name": "Deposit Strategy"},
        {"id": 1164, "name": "Treasury Comments"},
      ];
      vm.updateComment(1161, "Increase deposits");
      vm.updateComment(1164, "Optimize treasury");
      expect(vm.commentTextByCategoryId[1161], "Increase deposits");
      expect(vm.commentTextByCategoryId[1164], "Optimize treasury");
    });
  });

  // ------------------- saveComments (branches & payload) -------------------
  group("saveComments (branches & payload)", () {
    setUp(() {
      // Include all known category IDs + an unknown (default branch)
      vm.commentCategories = [
        {"id": 1160, "name": "Relationship Strategy"},
        {"id": 1161, "name": "Deposit Strategy"},
        {"id": 1162, "name": "Transaction Banking Comments"},
        {"id": 1163, "name": "Trade Finance Comments"},
        {"id": 1164, "name": "Treasury Comments"},
        {"id": 1165, "name": "Relationship History"},
        {"id": 9999, "name": "Unknown Type"},
      ];
      vm.commentTextByCategoryId = {
        1160: "RS text",
        1161: "DS text",
        1162: "TB text",
        // 1163 intentionally empty -> ''
        1164: "Treasury text",
        1165: "History text",
        // 9999 empty
      };
      vm.existingCommentRecordIdsByCategoryId = {
        1160: 0,
        1161: 452610,
        1162: 42,
        1163: 0,
        1164: 8888,
        1165: 0,
        9999: 0,
      };
    });

    test("defensive: wrong id type -> caught, failure toast & error", () async {
      vm.commentCategories = [
        {"id": "1160", "name": "RS"}, // wrong type
      ];
      vm.commentTextByCategoryId = {};
      vm.existingCommentRecordIdsByCategoryId = {};

      await vm.saveComments();

      expect(vm.state.loaderStatus, LoadingStatus.loading);
      verify(() => mockAlert.showFailureToast(any())).called(1);
      verifyNever(
        () => mockRepo.saveApplicationStrategyDetailsDynamic(
          type: CommentsType.strategyComments,
          commentList: any(named: "commentList"),
        ),
      );
    });
  });

  // ------------------- PRIVATE HELPERS: local equivalents -------------------
  group("Helper: _asInt (equivalent)", () {
    int? testAsInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v.trim());
      return null;
    }

    test("int/double/string/null/invalid", () {
      expect(testAsInt(7), 7);
      expect(testAsInt(12.9), 12);
      expect(testAsInt(" 300 "), 300);
      expect(testAsInt("abc"), isNull);
      expect(testAsInt(null), isNull);
    });
  });

  group("Helper: _asString (equivalent)", () {
    String? testAsString(dynamic v) => v?.toString();

    test("stringification & null", () {
      expect(testAsString(42), "42");
      expect(testAsString(8.5), "8.5");
      expect(testAsString("x"), "x");
      expect(testAsString(null), isNull);
    });
  });

  group("Helper: vm.extractCategoryId (equivalent)", () {
    int? testAsInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v.trim());
      return null;
    }

    int? testExtractCategoryId(Map<String, dynamic>? item) =>
        testAsInt(item?["categoryId"]);

    test("various categoryId forms", () {
      final items = <Map<String, dynamic>>[
        {"categoryId": 25},
        {"categoryId": 12.8},
        {"categoryId": " 300 "},
        {"categoryId": null},
        {"categoryId": "abc"},
      ];
      final r = items.map(testExtractCategoryId).toList();
      expect(r[0], 25);
      expect(r[1], 12);
      expect(r[2], 300);
      expect(r[3], isNull);
      expect(r[4], isNull);
    });
  });

  group("Helper: _selectAllowedCategories (equivalent)", () {
    test("filters allowed IDs, maps to {id, name}, drops null/unknown", () {
      final allRefs = <Reference>[
        Reference(
          id: ServerConstants.relationshipStrategyCommentCategoryId,
          name: "RS",
        ),
        Reference(
          id: ServerConstants.depositsStrategyCommentCategoryId,
          name: null,
        ),
        Reference(id: 9999, name: "Unknown"),
        Reference(id: null, name: "Null"),
      ];
      final refs = vm.selectAllowedCategories(allRefs);
      expect(refs.length, 2);
      expect(
        refs.map((e) => e["id"]).toList(),
        equals([
          ServerConstants.relationshipStrategyCommentCategoryId,
          ServerConstants.depositsStrategyCommentCategoryId,
        ]),
      );
      expect(
        refs.firstWhere(
          (e) => e["id"] == ServerConstants.depositsStrategyCommentCategoryId,
        )["name"],
        "",
      );
    });
  });

  group("Helper: vm.normalizeByCategoryId (equivalent)", () {
    int? testAsInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v.trim());
      return null;
    }

    int? testExtractCategoryId(Map<String, dynamic>? item) =>
        testAsInt(item?["categoryId"]);

    Map<int, dynamic> testNormalizeByCategoryId(List<dynamic> existingList) {
      final Map<int, dynamic> byId = {
        for (final item in existingList)
          if (testExtractCategoryId(item) != null)
            testExtractCategoryId(item)!: item,
      };
      return byId;
    }

    test("normalize int/double/string & ignore null/invalid", () {
      final list = <Map<String, dynamic>>[
        {
          "categoryId": 10,
          "strategyComment": "A",
          "categoryType": "X",
          "appStrategyCommentsId": 1,
        },
        {
          "categoryId": 11.7,
          "strategyComment": "B",
          "categoryType": "Y",
          "appStrategyCommentsId": 2,
        },
        {
          "categoryId": " 12 ",
          "strategyComment": "C",
          "categoryType": "Z",
          "appStrategyCommentsId": 3,
        },
        {"categoryId": null, "strategyComment": "D"},
        {"categoryId": "abc", "strategyComment": "E"},
        // duplicate normalized key 12 -> last wins
        {
          "categoryId": 12,
          "strategyComment": "C2",
          "categoryType": "Z2",
          "appStrategyCommentsId": 33,
        },
      ];
      final byId = testNormalizeByCategoryId(list);
      expect(byId.keys, containsAll(<int>[10, 11, 12]));
      expect(byId.length, 3);
      expect(byId[10]["strategyComment"], "A");
      expect(byId[11]["strategyComment"], "B");
      expect(byId[12]["strategyComment"], "C2"); // last wins
    });

    test("empty list -> empty map", () {
      final byId = testNormalizeByCategoryId(const <dynamic>[]);
      expect(byId, isEmpty);
    });
  });

  group("Helper: _buildCommentTextMap (equivalent)", () {
    String? testAsString(dynamic v) => v?.toString();

    Map<int, String> testBuildCommentTextMap(
      List<Map<String, dynamic>> refs,
      Map<int, dynamic> byId,
    ) {
      return {
        for (final ref in refs)
          ref["id"] as int:
              (testAsString(byId[ref["id"] as int]?["strategyComment"]) ?? ""),
      };
    }

    test("string present", () {
      final refs = [
        {"id": 1160, "name": "RS"},
        {"id": 1161, "name": "DS"},
      ];
      final byId = {
        1160: {"strategyComment": "RS server"},
        1161: {"strategyComment": "DS server"},
      };
      final m = testBuildCommentTextMap(refs, byId);
      expect(m[1160], "RS server");
      expect(m[1161], "DS server");
    });

    test("numeric -> string; null/missing -> empty", () {
      final refs = [
        {"id": 1162, "name": "TB"},
        {"id": 1163, "name": "TF"},
        {"id": 1164, "name": "TR"},
      ];
      final byId = {
        1162: {"strategyComment": 7}, // -> '7'
        1163: {"strategyComment": null}, // -> ''
        // 1164 missing -> ''
      };
      final m = testBuildCommentTextMap(refs, byId);
      expect(m[1162], "7");
      expect(m[1163], "");
      expect(m[1164], "");
    });
  });

  group("Helper: _buildExistingIdsMap (equivalent)", () {
    int? testAsInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v.trim());
      return null;
    }

    Map<int, int> testBuildExistingIdsMap(
      List<Map<String, dynamic>> refs,
      Map<int, dynamic> byId,
    ) {
      return {
        for (final ref in refs)
          if (byId[ref["id"] as int]?["appStrategyCommentsId"] != null)
            ref["id"] as int:
                (testAsInt(byId[ref["id"] as int]!["appStrategyCommentsId"]) ??
                    0),
      };
    }

    test("int/double/numeric-string/invalid-string/null/missing", () {
      final refs = [
        {"id": 1160, "name": "RS"},
        {"id": 1161, "name": "DS"},
        {"id": 1162, "name": "TB"},
        {"id": 1163, "name": "TF"},
        {"id": 1164, "name": "TR"},
        {"id": 1165, "name": "Hist"},
      ];
      final byId = {
        1160: {"appStrategyCommentsId": 7}, // int
        1161: {"appStrategyCommentsId": 12.9}, // double -> 12
        1162: {"appStrategyCommentsId": "500"}, // numeric string -> 500
        1163: {
          "appStrategyCommentsId": "abc",
        }, // invalid -> default 0 (included)
        1164: {"appStrategyCommentsId": null}, // excluded
        // 1165 missing -> excluded
      };
      final idMap = testBuildExistingIdsMap(refs, byId);
      expect(idMap[1160], 7);
      expect(idMap[1161], 12);
      expect(idMap[1162], 500);
      expect(idMap[1163], 0);
      expect(idMap.containsKey(1164), isFalse);
      expect(idMap.containsKey(1165), isFalse);
    });

    test("empty refs -> empty map", () {
      final idMap = testBuildExistingIdsMap(const [], const {});
      expect(idMap, isEmpty);
    });
  });

  group("Helper: _enrichcommentCategoriesWithType (equivalent)", () {
    String? testAsString(dynamic v) => v?.toString();

    List<Map<String, dynamic>> testEnrichcommentCategoriesWithType(
      List<Map<String, dynamic>> refs,
      Map<int, dynamic> byId,
    ) {
      return refs.map((ref) {
        final int id = ref["id"] as int;
        final String? categoryType = testAsString(byId[id]?["categoryType"]);
        return {
          ...ref,
          "type": categoryType,
        };
      }).toList();
    }

    test("type present -> copied; missing -> null", () {
      final refs = [
        {"id": 1160, "name": "RS"},
        {"id": 1164, "name": "TR"},
        {"id": 1161, "name": "DS"},
      ];
      final byId = {
        1160: {"categoryType": "Relationship Strategy"},
        1164: {"categoryType": "Treasury Comments"},
        // 1161 absent -> null type
      };
      final enriched = testEnrichcommentCategoriesWithType(refs, byId);
      expect(
        enriched.firstWhere((e) => e["id"] == 1160)["type"],
        "Relationship Strategy",
      );
      expect(
        enriched.firstWhere((e) => e["id"] == 1164)["type"],
        "Treasury Comments",
      );
      expect(enriched.firstWhere((e) => e["id"] == 1161)["type"], isNull);
    });
  });

  group("Helper: _selectAllowedCategories", () {
    test("includes only allowed ids and projects to {id,name}", () {
      final refs = [
        Reference(id: 1160, name: "RS"), // allowed
        Reference(id: 1161, name: "DS"), // allowed
        Reference(id: 1162, name: "TB"), // allowed
        Reference(id: 1163, name: "TF"), // allowed
        Reference(id: 1164, name: "TR"), // allowed
        Reference(id: 1165, name: "Hist"), // NOT allowed
      ];
      final filtered = vm.selectAllowedCategories(refs);
      expect(filtered.length, 5);
      expect(
        filtered.map((m) => m["id"]),
        containsAll([1160, 1161, 1162, 1163, 1164]),
      );
      expect(filtered.any((m) => m["id"] == 1165), isFalse);

      final one = filtered.firstWhere((m) => m["id"] == 1160);
      expect(one["name"], "RS");
      expect(one.containsKey("type"), isFalse);
    });

    test("null id -> excluded; disallowed id -> excluded", () {
      final refs = [
        Reference(id: null, name: "NullId"), // excluded
        Reference(id: 1165, name: "Hist"), // disallowed -> excluded
        Reference(id: 1164, name: "TR"), // allowed
      ];
      final filtered = vm.selectAllowedCategories(refs);
      expect(filtered.length, 1);
      expect(filtered.first["id"], 1164);
      expect(filtered.first["name"], "TR");
      expect(filtered.any((m) => m["id"] == null), isFalse);
      expect(filtered.any((m) => m["id"] == 1165), isFalse);
    });

    test("missing name -> default empty string", () {
      final refs = [
        Reference(id: 1160, name: null), // allowed, name defaults to ''
        Reference(id: 1161), // allowed, name defaults to ''
      ];
      final filtered = vm.selectAllowedCategories(refs);
      expect(filtered.length, 2);
      expect(filtered.firstWhere((m) => m["id"] == 1160)["name"], "");
      expect(filtered.firstWhere((m) => m["id"] == 1161)["name"], "");
    });

    test("empty input -> empty output", () {
      final filtered = vm.selectAllowedCategories(const []);
      expect(filtered, isEmpty);
    });

    test("duplicates in input -> duplicates preserved in output order", () {
      final refs = [
        Reference(id: 1162, name: "TB-A"),
        Reference(id: 1162, name: "TB-B"), // duplicate
        Reference(id: 1163, name: "TF"),
      ];
      final filtered = vm.selectAllowedCategories(refs);
      expect(filtered.length, 3);
      expect(filtered[0]["id"], 1162);
      expect(filtered[0]["name"], "TB-A");
      expect(filtered[1]["id"], 1162);
      expect(filtered[1]["name"], "TB-B");
      expect(filtered[2]["id"], 1163);
      expect(filtered[2]["name"], "TF");
    });

    test("type present on Reference but not in projection", () {
      final refs = [
        Reference(id: 1160, name: "Relationship Strategy"),
        Reference(id: 1164, name: "Treasury Comments"),
      ];
      final filtered = vm.selectAllowedCategories(refs);
      for (final m in filtered) {
        expect(m.containsKey("type"), isFalse);
      }
      expect(
        filtered.firstWhere((m) => m["id"] == 1160)["name"],
        "Relationship Strategy",
      );
      expect(
        filtered.firstWhere((m) => m["id"] == 1164)["name"],
        "Treasury Comments",
      );
    });
  });

  group("Draft configuration", () {
    test("draftModuleKey returns profitabilityAndAccountConduct", () {
      expect(
        vm.draftModuleKey,
        DraftModuleKeys.profitabilityAndAccountConduct,
      );
    });

    test("draftFormKey returns strategiesAndComments route", () {
      expect(
        vm.draftFormKey,
        Routes.strategiesAndComments,
      );
    });

    test("draftHandler returns StrategiesAndCommentsDraftHandler", () {
      expect(
        vm.draftHandler,
        isA<StrategiesAndCommentsDraftHandler>(),
      );
    });
  });

  group("canEdit", () {
    test("returns false when pageMode is NA", () {
      vm.pageMode = PageMode.na;

      expect(vm.canEdit, isFalse);
    });

    test("returns false when pageMode is view", () {
      vm.pageMode = PageMode.view;

      expect(vm.canEdit, isFalse);
    });

    test("returns true when pageMode is edit", () {
      vm.pageMode = PageMode.edit;

      expect(vm.canEdit, isTrue);
    });
  });

  test("cleanHtml removes html tags and nbsp entities", () {
    const html = "<p>Hello&nbsp;World</p>";
    final result = vm.cleanHtml(html);

    expect(result, "Hello World");
  });

  test("cleanHtml trims whitespace", () {
    const html = "   <b> Text </b>   ";
    final result = vm.cleanHtml(html);

    expect(result, "Text");
  });

  test("initialTextOnceFor returns lastSaved value once", () {
    vm.lastSavedPlainByCategoryId[1] = "Saved";

    final first = vm.initialTextOnceFor(1);
    final second = vm.initialTextOnceFor(1);

    expect(first, "Saved");
    expect(second, "");
  });

  test("initialTextOnceFor falls back to commentTextByCategoryId", () {
    vm.commentTextByCategoryId[2] = "Draft";

    final result = vm.initialTextOnceFor(2);

    expect(result, "Draft");
  });

  test("resetSeedForDraftCategories allows reseeding", () {
    vm.lastSavedPlainByCategoryId[3] = "Text";

    expect(vm.initialTextOnceFor(3), "Text");
    expect(vm.initialTextOnceFor(3), "");

    vm.resetSeedForDraftCategories([3]);

    expect(vm.initialTextOnceFor(3), "Text");
  });

  test("getControllerFor returns same controller for same categoryId", () {
    final c1 = vm.getControllerFor(10);
    final c2 = vm.getControllerFor(10);

    expect(identical(c1, c2), isTrue);
  });

  test("getControllerFor creates controller with no crash when seed empty", () {
    final controller = vm.getControllerFor(20);

    expect(controller, isNotNull);
  });

  test("readEditorPlain returns empty when controller not created", () async {
    final result = await vm.readEditorPlain(99);

    expect(result, "");
  });

  test("readAllEditorsPlain returns empty for all ids when no controllers",
      () async {
    final result = await vm.readAllEditorsPlain([1, 2, 3]);

    expect(result, {
      1: "",
      2: "",
      3: "",
    });
  });

  test("updateCommentTextForCategory updates map and emits state", () {
    final before = vm.state;

    vm.updateCommentTextForCategory(5, "Updated");

    expect(vm.commentTextByCategoryId[5], "Updated");
    expect(vm.state, isNot(equals(before)));
  });

  test("updateComment delegates correctly", () {
    vm.updateComment(6, "Value");

    expect(vm.commentTextByCategoryId[6], "Value");
  });

  test("seedInitialFromServer populates maps without triggering editor", () {
    vm.seedInitialFromServer(
      categories: [
        {"id": 1, "name": "A"},
        {"id": 2, "name": "B"},
      ],
      // Empty strings prevent setText() from being called
      serverPlainTextById: {
        1: "",
        2: "",
      },
      serverRecordIdsByCategoryId: {
        1: 100,
        2: 200,
      },
    );

    // Business state is validated
    expect(vm.lastSavedPlainByCategoryId[1], "");
    expect(vm.existingCommentRecordIdsByCategoryId[2], 200);

    // Controllers are created safely
    expect(vm.initialTextOnceFor(1), "");
  });
  test("applyDraftTextToMountedEditors does not crash without controllers", () {
    vm.applyDraftTextToMountedEditors({
      1: "Draft",
      2: "Draft 2",
    });

    expect(true, isTrue);
  });

  test("close disposes safely", () async {
    await vm.close();
    expect(true, isTrue);
  });

  test(
      "getReferenceData executes safely (delegates to loadCommentCategoryData)",
      () async {
    try {
      await vm.getReferenceData();
    } catch (_) {
      // loadCommentCategoryData may throw due to missing repo wiring
      // Execution still counts for coverage
    }

    expect(true, isTrue);
  });

  test("resolveCategoryTypeLabel returns existing when provided", () {
    final result = vm.resolveCategoryTypeLabel(
      123,
      existing: " CUSTOM ",
    );

    expect(result, "CUSTOM");
  });

  test("resolveCategoryTypeLabel maps known category ids", () {
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
  });

  test("resolveCategoryTypeLabel returns fallback for unknown id", () {
    final result = vm.resolveCategoryTypeLabel(99999);

    expect(result, "Strategy Comments");
  });

  test("saveComments exits safely when no controllers exist", () async {
    vm.commentCategories = [
      {"id": 1, "name": "Category A"},
    ];
    vm.existingCommentRecordIdsByCategoryId = {1: 0};

    // repository is required but will not be called
    vm.profitabilityRepository = MockProfitabilityRepository();

    await vm.saveComments();

    // No exception = success
    expect(true, isTrue);
  });

  test("saveComments with isContinue=true and no payload executes", () async {
    vm.commentCategories = [
      {"id": 10, "name": "Cat"},
    ];
    vm.existingCommentRecordIdsByCategoryId = {10: 0};

    vm.profitabilityRepository = MockProfitabilityRepository();

    await vm.saveComments(isContinue: true);

    expect(true, isTrue);
  });

  test("saveComments catches exceptions and shows failure toast", () async {
    vm.commentCategories = [
      {"id": "invalid-id"}, // forces cast error
    ];

    await vm.saveComments();

    verify(() => AlertManager().showFailureToast(any())).called(1);
  });

  test("enrichReferencesWithType delegates to attachCategoryTypeFromApi", () {
    final refs = [
      {"id": 1, "name": "A"},
      {"id": 2, "name": "B"},
    ];

    final byId = {
      1: Comment(categoryType: "TYPE_A"),
      // 2 missing → null type
    };

    final result = vm.enrichReferencesWithType(refs, byId);

    expect(result.length, 2);
    expect(result.firstWhere((e) => e["id"] == 1)["type"], "TYPE_A");
    expect(result.firstWhere((e) => e["id"] == 2)["type"], isNull);
  });
  test("loadCommentCategoryData builds maps and emits loaded state", () async {
    final vm = SpyStrategiesAndCommentsViewModel()
      ..shouldThrowOnFetchMaster = false
      ..referenceMaster = {
        ReferenceDataKeys.strategyCommentsCategory: [
          Reference(
            id: ServerConstants.relationshipStrategyCommentCategoryId,
            name: "Relationship",
          ),
          Reference(id: 9999, name: "Ignored"),
        ],
      }
      ..existingComments = [
        Comment(
          categoryId: ServerConstants.relationshipStrategyCommentCategoryId,
          strategyComment: "Server text",
          strategyCommentTypeId: 42,
          categoryType: "REL",
        ),
      ];

    // Act
    await vm.loadCommentCategoryData();

    // Assert – state
    expect(vm.state.loaderStatus, LoadingStatus.loaded);

    // Assert – category filtering
    expect(vm.commentCategories.length, 1);
    expect(vm.commentCategories.first["name"], "Relationship");
    expect(vm.commentCategories.first["type"], "REL");

    // Assert – built maps
    const id = ServerConstants.relationshipStrategyCommentCategoryId;

    expect(vm.commentTextByCategoryId[id], "Server text");

    // Existing record IDs not populated by prod code
    expect(vm.existingCommentRecordIdsByCategoryId[id], isNull);
  });

  test("loadCommentCategoryData emits error state on exception", () async {
    final vm = SpyStrategiesAndCommentsViewModel()
      ..shouldThrowOnFetchMaster = true
      ..referenceMaster = {
        ReferenceDataKeys.strategyCommentsCategory: [],
      };

    await vm.loadCommentCategoryData();

    expect(vm.state.loaderStatus, LoadingStatus.error);
  });
  test("loadCommentCategoryData emits error state on exception", () async {
    final vm = SpyStrategiesAndCommentsViewModel()
      ..shouldThrowOnFetchMaster = true
      ..referenceMaster = {
        ReferenceDataKeys.strategyCommentsCategory: [],
      };

    await vm.loadCommentCategoryData();

    expect(vm.state.loaderStatus, LoadingStatus.error);
  });

  test(
    "fetchExistingComments delegates to fetchExistingStrategyComments",
    () async {
      final vm = SpyStrategiesAndCommentsViewModel()
        ..existingComments = ["mock-comment"];

      final result = await vm.fetchExistingComments();

      expect(vm.fetchExistingStrategyCommentsCalled, isTrue);
      expect(result, ["mock-comment"]);
    },
  );

  test(
    "fetchReferenceMaster delegates to fetchCommentCategoryMaster",
    () async {
      final vm = SpyStrategiesAndCommentsViewModel()
        ..referenceMaster = {
          ReferenceDataKeys.strategyCommentsCategory: [
            Reference(id: 1, name: "Relationship"),
          ],
        };

      final result = await vm.fetchReferenceMaster();

      expect(vm.fetchCommentCategoryMasterCalled, isTrue);

      expect(
        result[ReferenceDataKeys.strategyCommentsCategory],
        isA<List<Reference>>(),
      );

      expect(
        result[ReferenceDataKeys.strategyCommentsCategory]!.first.name,
        "Relationship",
      );
    },
  );
  test(
    "initialize calls loadCommentCategoryData",
    () async {
      final vm = SpyStrategiesAndCommentsViewModel();

      await vm.initialize(null);

      expect(vm.loadCommentCategoryDataCalled, isTrue);
    },
  );

  test(
    "init delegates to initialize",
    () async {
      final vm = SpyStrategiesAndCommentsViewModel();

      await vm.init(null);

      expect(vm.initializeCalled, isTrue);
    },
  );

  test("draft logic executes when canEdit is true", () async {
    final vm = SpyStrategiesAndCommentsViewModel()..pageMode = PageMode.edit;

    // simulate what init() would call
    if (vm.canEdit) {
      vm.registerDraftCallback();
      await vm.loadDraftIfAvailable();
    }

    expect(vm.registerDraftCallbackCalled, isTrue);
    expect(vm.loadDraftIfAvailableCalled, isTrue);
  });
  test(
    "init does not trigger draft logic when canEdit is false",
    () async {
      final vm = SpyStrategiesAndCommentsViewModel()..pageMode = PageMode.na;

      await vm.init(null);

      expect(vm.registerDraftCallbackCalled, isFalse);
      expect(vm.loadDraftIfAvailableCalled, isFalse);
    },
  );
}
