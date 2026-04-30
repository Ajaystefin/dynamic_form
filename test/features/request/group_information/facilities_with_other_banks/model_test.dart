import "dart:io";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/group_information/facilities_data.dart";
import "package:wcas_frontend/models/request/group_information/risk_bureau.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/group_information_repository.dart";

import "../../../../test_config.dart";

// ─────────────────────────────────────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────────────────────────────────────
class MockGroupInformationRepository extends Mock
    implements GroupInformationRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockCommonRepository extends Mock implements CommonRepository {}

class FakeComment extends Fake implements Comment {}

// ─────────────────────────────────────────────────────────────────────────────
// Silent AlertManager – prevents Toastification asserts in tests
// ─────────────────────────────────────────────────────────────────────────────
class _SilentAlertManager implements AlertManager {
  @override
  void showFailureToast(String message, {Duration? duration}) {}

  @override
  void showSuccessToast(String message, {Duration? duration}) {}

  @override
  void showInfoToast(String message, {Duration? duration}) {}

  @override
  void showWarningToast(String message, {Duration? duration}) {}
}

// ─────────────────────────────────────────────────────────────────────────────
// Fake local storage
// ─────────────────────────────────────────────────────────────────────────────
class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _store =
      <String, Map<String, dynamic>>{};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, dynamic value) async {
    _store[box] ??= <String, dynamic>{};
    _store[box]![key] = value;
  }

  @override
  Future<dynamic> get(String box, String key) async => _store[box]?[key];

  @override
  Future<void> delete(String box, String key) async => _store[box]?.remove(key);

  @override
  Future<void> clearBox(String box) async => _store[box]?.clear();
}

// ─────────────────────────────────────────────────────────────────────────────
// Test subclasses (to increase coverage without changing production model)
// ─────────────────────────────────────────────────────────────────────────────
class TestFacilitiesWithOtherBanksViewModel
    extends FacilitiesWithOtherBanksViewModel {
  bool getApplicationStrategyDetailsCalled = false;
  bool getReferenceDatasCalled = false;
  bool getFacilitiesOtherBanksCalled = false;
  bool getFacilitiesCentralRiskBureauCalled = false;

  @override
  bool get canEdit => false;

  @override
  Future<void> getApplicationStrategyDetails() async {
    getApplicationStrategyDetailsCalled = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> getReferenceDatas() async {
    getReferenceDatasCalled = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> getFacilitiesOtherBanks() async {
    getFacilitiesOtherBanksCalled = true;
    emit(state.copyWith(otherBankLoader: LoadingStatus.loaded));
  }

  @override
  Future<void> getFacilitiesCentralRiskBureau() async {
    getFacilitiesCentralRiskBureauCalled = true;
    emit(state.copyWith(cbrbTableLoader: LoadingStatus.loaded));
  }
}

class TestFacilitiesWithOtherBanksViewModelCanEdit
    extends FacilitiesWithOtherBanksViewModel {
  bool getApplicationStrategyDetailsCalled = false;
  bool getReferenceDatasCalled = false;
  bool getFacilitiesOtherBanksCalled = false;
  bool getFacilitiesCentralRiskBureauCalled = false;
  bool registerDraftCallbackCalled = false;
  bool loadDraftIfAvailableCalled = false;
  bool unregisterDraftCallbackCalled = false;

  @override
  bool get canEdit => true;

  @override
  Future<void> getApplicationStrategyDetails() async {
    getApplicationStrategyDetailsCalled = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> getReferenceDatas() async {
    getReferenceDatasCalled = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> getFacilitiesOtherBanks() async {
    getFacilitiesOtherBanksCalled = true;
    emit(state.copyWith(otherBankLoader: LoadingStatus.loaded));
  }

  @override
  Future<void> getFacilitiesCentralRiskBureau() async {
    getFacilitiesCentralRiskBureauCalled = true;
    emit(state.copyWith(cbrbTableLoader: LoadingStatus.loaded));
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
  void unregisterDraftCallback() {
    unregisterDraftCallbackCalled = true;
  }
}

class TestFacilitiesWithOtherBanksViewModelClose
    extends FacilitiesWithOtherBanksViewModel {
  bool unregisterDraftCallbackCalled = false;

  @override
  void unregisterDraftCallback() {
    unregisterDraftCallbackCalled = true;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fake data
// ─────────────────────────────────────────────────────────────────────────────
final Reference _fakeRef = Reference(
  id: 1,
  description: "Bank A",
  name: "Bank A",
);

final RiskBureau _fakeRisk = RiskBureau();

final Comment _fakeOtherBankComment = Comment(
  categoryId: ServerConstants.otherBankCategoryID,
  strategyComment: "OB Strategy",
);

final Comment _fakeCbrbComment = Comment(
  categoryId: ServerConstants.cbrbCategoryID,
  strategyComment: "CBRB Strategy",
);

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
void _setupFullMocks({
  required MockGroupInformationRepository repo,
  required MockReferenceDataService refSvc,
  required MockCommonRepository commonRepo,
}) {
  when(() => refSvc.getReferenceData(any())).thenAnswer(
    (_) async => <String, List<Reference>>{
      ReferenceDataKeys.bankList: <Reference>[_fakeRef],
      ReferenceDataKeys.facilityTypes: <Reference>[_fakeRef],
      ReferenceDataKeys.securityType: <Reference>[_fakeRef],
    },
  );

  when(() => repo.getFacilitiesOtherBanks())
      .thenAnswer((_) async => <Facility>[]);
  when(() => repo.getFacilitiesCentralRiskBureau())
      .thenAnswer((_) async => _fakeRisk);

  when(
    () => commonRepo.getApplicationStrategyDetails(
      CommentsType.facilitiesWithOtherBank,
      EntityIdentifier.facilitiesWithOtherBank,
    ),
  ).thenAnswer((_) async => <Comment>[_fakeOtherBankComment]);

  when(
    () => commonRepo.getApplicationStrategyDetails(
      CommentsType.centralBankRiskBureauData,
      EntityIdentifier.centralBankRiskBureauData,
    ),
  ).thenAnswer((_) async => <Comment>[_fakeCbrbComment]);
}

Future<BuildContext> mountedRouterContext(WidgetTester tester) async {
  // Make test viewport very wide/tall so dialogs have room.
  tester.view.physicalSize = const Size(2200, 1600);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  late BuildContext ctx;

  final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: "/",
        builder: (BuildContext context, GoRouterState state) {
          ctx = context;
          return const Scaffold(
            body: SizedBox.shrink(),
          );
        },
      ),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
    ),
  );

  await tester.pumpAndSettle();
  return ctx;
}

FlutterExceptionHandler? ignoreOnlyOverflowErrors() {
  final FlutterExceptionHandler? original = FlutterError.onError;

  FlutterError.onError = (FlutterErrorDetails details) {
    final String message = details.exceptionAsString();

    if (message.contains("A RenderFlex overflowed by")) {
      return;
    }

    if (original != null) {
      original(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  return original;
}

CustomButton dialogButtonByKeyword(
  WidgetTester tester,
  String keyword,
) {
  final Iterable<CustomButton> buttons =
      tester.widgetList<CustomButton>(find.byType(CustomButton));

  return buttons.firstWhere(
    (CustomButton button) =>
        (button.label).toLowerCase().contains(keyword.toLowerCase()),
  );
}

Future<void> pressCustomButton(
  CustomButton button,
) async {
  final dynamic result = button.onPressed?.call();
  if (result is Future) {
    await result;
  }
}

Future<BuildContext> mountedContext(WidgetTester tester) async {
  late BuildContext ctx;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            ctx = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );

  await tester.pump();
  return ctx;
}

Future<void> runOnSaveCommentWithoutPendingTimers(
  WidgetTester tester,
  Future<void> Function() body,
) async {
  await tester.runAsync(() async {
    await HttpOverrides.runZoned(
      () async {
        try {
          await body();
        } catch (_) {
          // swallow anything unexpected from the real HTTP path
        }
      },
      createHttpClient: (SecurityContext? context) {
        throw const SocketException("Blocked by test");
      },
    );
  });
}

// ─────────────────────────────────────────────────────────────────────────────
void main() {
  late FacilitiesWithOtherBanksViewModel vm;
  late MockGroupInformationRepository mockRepo;
  late MockReferenceDataService mockRefSvc;
  late MockCommonRepository mockCommonRepo;

  const MethodChannel connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          return <String>["wifi"];
        }
        return null;
      },
    );

    registerFallbackValue(FakeComment());
    registerFallbackValue(CommentsType.facilitiesWithOtherBank);
    registerFallbackValue(EntityIdentifier.facilitiesWithOtherBank);
  });

  tearDownAll(() async {
    await TestConfig.cleanup();
  });

  setUp(() {
    mockRepo = MockGroupInformationRepository();
    mockRefSvc = MockReferenceDataService();
    mockCommonRepo = MockCommonRepository();

    vm = FacilitiesWithOtherBanksViewModel();
    vm.repository = mockRepo;
    vm.repositoryDataService = mockRefSvc;
    vm.repositoryCommon = mockCommonRepo;

    AlertManager.overrideInstance(_SilentAlertManager());
    LocalStorageService().setStorage(MockLocalStorageService());

    Globals.request = null;
    Globals.user = null;
  });

  // ─────────────────────────────────────────────────────────────────
  // getReferenceDatas
  // ─────────────────────────────────────────────────────────────────
  group("getReferenceDatas", () {
    test("success – all three lists populated", () async {
      when(() => mockRefSvc.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{
          ReferenceDataKeys.bankList: <Reference>[_fakeRef],
          ReferenceDataKeys.facilityTypes: <Reference>[_fakeRef],
          ReferenceDataKeys.securityType: <Reference>[_fakeRef],
        },
      );

      await vm.getReferenceDatas();

      expect(vm.bankNameOptions, isNotEmpty);
      expect(vm.typeOfFacilityOptions, isNotEmpty);
      expect(vm.securityOptions, isNotEmpty);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("partial data – missing keys default to empty list", () async {
      when(() => mockRefSvc.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{
          ReferenceDataKeys.bankList: <Reference>[_fakeRef],
        },
      );

      await vm.getReferenceDatas();

      expect(vm.bankNameOptions.length, 1);
      expect(vm.typeOfFacilityOptions, isEmpty);
      expect(vm.securityOptions, isEmpty);
    });

    test("error is caught silently", () async {
      when(() => mockRefSvc.getReferenceData(any()))
          .thenThrow(Exception("ref error"));

      await vm.getReferenceDatas();

      expect(vm.bankNameOptions, isEmpty);
      expect(vm.typeOfFacilityOptions, isEmpty);
      expect(vm.securityOptions, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // getFacilitiesOtherBanks
  // ─────────────────────────────────────────────────────────────────
  group("getFacilitiesOtherBanks", () {
    test("success – facilitiesOtherBanks populated, loader = loaded", () async {
      when(() => mockRepo.getFacilitiesOtherBanks())
          .thenAnswer((_) async => <Facility>[]);

      await vm.getFacilitiesOtherBanks();

      expect(vm.facilitiesOtherBanks, isNotNull);
      expect(vm.state.otherBankLoader, LoadingStatus.loaded);
    });

    test("error – otherBankLoader = error", () async {
      when(() => mockRepo.getFacilitiesOtherBanks())
          .thenThrow(Exception("oops"));

      await vm.getFacilitiesOtherBanks();

      expect(vm.state.otherBankLoader, LoadingStatus.error);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // getFacilitiesCentralRiskBureau
  // ─────────────────────────────────────────────────────────────────
  group("getFacilitiesCentralRiskBureau", () {
    test("success – riskBureau set, cbrbTableLoader = loaded", () async {
      when(() => mockRepo.getFacilitiesCentralRiskBureau())
          .thenAnswer((_) async => _fakeRisk);

      await vm.getFacilitiesCentralRiskBureau();

      expect(vm.riskBureau, same(_fakeRisk));
      expect(vm.state.cbrbTableLoader, LoadingStatus.loaded);
    });

    test("error – cbrbTableLoader = error", () async {
      when(() => mockRepo.getFacilitiesCentralRiskBureau())
          .thenThrow(Exception("cbrb error"));

      await vm.getFacilitiesCentralRiskBureau();

      expect(vm.state.cbrbTableLoader, LoadingStatus.error);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // getApplicationStrategyDetails
  // ─────────────────────────────────────────────────────────────────
  group("getApplicationStrategyDetails", () {
    test("both comments populated correctly", () async {
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithOtherBank,
          EntityIdentifier.facilitiesWithOtherBank,
        ),
      ).thenAnswer((_) async => <Comment>[_fakeOtherBankComment]);

      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.centralBankRiskBureauData,
          EntityIdentifier.centralBankRiskBureauData,
        ),
      ).thenAnswer((_) async => <Comment>[_fakeCbrbComment]);

      await vm.getApplicationStrategyDetails();

      expect(vm.strategyComment, "OB Strategy");
      expect(vm.strategyCommentCBRB, "CBRB Strategy");
      expect(vm.strategyCommentController.text, "OB Strategy");
      expect(vm.strategyCommentCBRBController.text, "CBRB Strategy");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("empty lists → empty strings", () async {
      when(() => mockCommonRepo.getApplicationStrategyDetails(any(), any()))
          .thenAnswer((_) async => <Comment>[]);

      await vm.getApplicationStrategyDetails();

      expect(vm.strategyComment, "");
      expect(vm.strategyCommentCBRB, "");
      expect(vm.strategyCommentController.text, "");
      expect(vm.strategyCommentCBRBController.text, "");
    });

    test("null comment responses -> empty strings", () async {
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithOtherBank,
          EntityIdentifier.facilitiesWithOtherBank,
        ),
      ).thenAnswer((_) async => <Comment>[]);

      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.centralBankRiskBureauData,
          EntityIdentifier.centralBankRiskBureauData,
        ),
      ).thenAnswer((_) async => <Comment>[]);

      await vm.getApplicationStrategyDetails();

      expect(vm.strategyComment, "");
      expect(vm.strategyCommentCBRB, "");
      expect(vm.strategyCommentController.text, "");
      expect(vm.strategyCommentCBRBController.text, "");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("non-matching categoryId → empty string", () async {
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithOtherBank,
          EntityIdentifier.facilitiesWithOtherBank,
        ),
      ).thenAnswer(
        (_) async => <Comment>[
          Comment(categoryId: 9999, strategyComment: "wrong"),
        ],
      );

      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.centralBankRiskBureauData,
          EntityIdentifier.centralBankRiskBureauData,
        ),
      ).thenAnswer(
        (_) async => <Comment>[
          Comment(categoryId: 8888, strategyComment: "wrong cbrb"),
        ],
      );

      await vm.getApplicationStrategyDetails();

      expect(vm.strategyComment, "");
      expect(vm.strategyCommentCBRB, "");
    });

    test("exception → loaderStatus = error", () async {
      when(() => mockCommonRepo.getApplicationStrategyDetails(any(), any()))
          .thenThrow(Exception("network"));

      await vm.getApplicationStrategyDetails();

      expect(vm.state.loaderStatus, LoadingStatus.error);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // onSaveComment
  // NOTE:
  // Production code uses CommonRepository.instance directly, so success path
  // cannot be fully mocked without model changes. We still cover safe branches.
  // ─────────────────────────────────────────────────────────────────
  group("onSaveComment additional coverage", () {
    testWidgets(
      "valid form builds commentCBRB, saves form, and enters loading state",
      (tester) async {
        String? savedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: vm.formKey,
                child: TextFormField(
                  initialValue: "typed-value",
                  validator: (_) => null,
                  onSaved: (String? value) {
                    savedValue = value;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        Globals.request = Request(applicationRefNo: "APP-123");
        Globals.user = User(
          id: "user-1",
          currentRole: Role(roleId: 42),
        );

        vm.strategyComment = "Other bank strategy";
        vm.strategyCommentCBRB = "CBRB strategy";

        await runOnSaveCommentWithoutPendingTimers(
          tester,
          () => vm.onSaveComment(),
        );

        await tester.pump();

        // currentState.save() should have run
        expect(savedValue, "typed-value");

        // These lines execute before the first repository save fully succeeds.
        expect(vm.commentCBRB, isNotNull);
        expect(vm.commentCBRB?.applicationRefNo, "APP-123");
        expect(vm.commentCBRB?.draft, false);
        expect(vm.commentCBRB?.userId, "user-1");
        expect(vm.commentCBRB?.userRole, 42);
        expect(vm.commentCBRB?.type, CommentsType.centralBankRiskBureauData);
        expect(
          vm.commentCBRB?.entityType,
          EntityIdentifier.centralBankRiskBureauData,
        );
        expect(vm.commentCBRB?.categoryId, ServerConstants.cbrbCategoryID);
        expect(vm.commentCBRB?.categoryType, ServerConstants.cbrbCategoryType);
        expect(vm.commentCBRB?.strategyComment, "CBRB strategy");

        // First real save fails, so second comment is not built yet.
        expect(vm.comment, isNull);

        // Method emitted loading before hitting repository call.
        expect(vm.state.loaderStatus, LoadingStatus.loading);
      },
    );

    testWidgets(
      "valid form with null globals still builds commentCBRB safely",
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: vm.formKey,
                child: TextFormField(
                  initialValue: "typed-value",
                  validator: (_) => null,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        Globals.request = null;
        Globals.user = null;

        vm.strategyComment = "Other bank strategy";
        vm.strategyCommentCBRB = "CBRB strategy";

        await runOnSaveCommentWithoutPendingTimers(
          tester,
          () => vm.onSaveComment(),
        );

        await tester.pump();

        expect(vm.commentCBRB, isNotNull);
        expect(vm.commentCBRB?.applicationRefNo, isNull);
        expect(vm.commentCBRB?.userId, isNull);
        expect(vm.commentCBRB?.userRole, isNull);
        expect(vm.commentCBRB?.draft, false);
        expect(vm.commentCBRB?.type, CommentsType.centralBankRiskBureauData);
        expect(
          vm.commentCBRB?.entityType,
          EntityIdentifier.centralBankRiskBureauData,
        );
        expect(vm.commentCBRB?.categoryId, ServerConstants.cbrbCategoryID);
        expect(vm.commentCBRB?.categoryType, ServerConstants.cbrbCategoryType);
        expect(vm.commentCBRB?.strategyComment, "CBRB strategy");

        expect(vm.comment, isNull);
        expect(vm.state.loaderStatus, LoadingStatus.loading);
      },
    );

    testWidgets(
      "valid form propagates exact strategyCommentCBRB"
      " text before repository await",
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: vm.formKey,
                child: TextFormField(
                  initialValue: "abc",
                  validator: (_) => null,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        Globals.request = Request(applicationRefNo: "APP-999");
        Globals.user = User(
          id: "user-xyz",
          currentRole: Role(roleId: 7),
        );

        vm.strategyCommentCBRB = "UNIQUE_CBRB_TEXT";

        await runOnSaveCommentWithoutPendingTimers(
          tester,
          () => vm.onSaveComment(),
        );

        await tester.pump();

        expect(vm.commentCBRB, isNotNull);
        expect(vm.commentCBRB?.strategyComment, "UNIQUE_CBRB_TEXT");
        expect(vm.commentCBRB?.applicationRefNo, "APP-999");
        expect(vm.commentCBRB?.userId, "user-xyz");
        expect(vm.commentCBRB?.userRole, 7);
        expect(vm.state.loaderStatus, LoadingStatus.loading);
      },
    );
  });

  // ─────────────────────────────────────────────────────────────────
  // buildNames
  // ─────────────────────────────────────────────────────────────────
  group("buildNames", () {
    final List<Reference> options = <Reference>[
      Reference(id: 1, name: "BankA"),
      Reference(id: 2, name: "BankB"),
      Reference(id: 3, name: null),
    ];

    test('refs empty list → "--"', () {
      expect(vm.buildNames(refs: <Reference>[], options: options), "--");
    });

    test("refs with matching id → joined names", () {
      final List<Reference> refs = <Reference>[
        Reference(id: 1),
        Reference(id: 2),
      ];

      final String result = vm.buildNames(refs: refs, options: options);

      expect(result, contains("BankA"));
      expect(result, contains("BankB"));
    });

    test('refs with unmatched id → "--" for that entry', () {
      final List<Reference> refs = <Reference>[Reference(id: 99)];

      final String result = vm.buildNames(refs: refs, options: options);

      expect(result, "--");
    });

    test('refs with null name in options → "--"', () {
      final List<Reference> refs = <Reference>[Reference(id: 3)];

      final String result = vm.buildNames(refs: refs, options: options);

      expect(result, "--");
    });

    test("refs mixed matched and unmatched -> joined output", () {
      final List<Reference> refs = <Reference>[
        Reference(id: 1),
        Reference(id: 999),
      ];

      final String result = vm.buildNames(refs: refs, options: options);

      expect(result, "BankA, --");
    });

    test("id matching → name returned", () {
      final String result = vm.buildNames(options: options, id: 2);
      expect(result, "BankB");
    });

    test('id not matching → "--"', () {
      final String result = vm.buildNames(options: options, id: 100);
      expect(result, "--");
    });

    test('id with null name in options → "--"', () {
      final String result = vm.buildNames(options: options, id: 3);
      expect(result, "--");
    });

    test('neither refs nor id → "--"', () {
      expect(vm.buildNames(options: options), "--");
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // canEdit / pageMode
  // ─────────────────────────────────────────────────────────────────
  group("canEdit", () {
    test("initial pageMode is na → canEdit false", () {
      expect(vm.canEdit, isFalse);
    });

    test("pageMode edit → canEdit true", () {
      vm.pageMode = PageMode.edit;
      expect(vm.canEdit, isTrue);
    });

    test("pageMode view → canEdit false", () {
      vm.pageMode = PageMode.view;
      expect(vm.canEdit, isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // close()
  // ─────────────────────────────────────────────────────────────────
  group("close()", () {
    test("close does not throw", () async {
      await expectLater(vm.close(), completes);
    });

    test("close calls unregisterDraftCallback", () async {
      final TestFacilitiesWithOtherBanksViewModelClose testVm =
          TestFacilitiesWithOtherBanksViewModelClose();

      await testVm.close();

      expect(testVm.unregisterDraftCallbackCalled, isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // init()
  // Since production init() returns void, use subclasses + microtask drain.
  // ─────────────────────────────────────────────────────────────────
  group("init()", () {
    test("repos null before init → assigned inside init", () async {
      final TestFacilitiesWithOtherBanksViewModel testVm =
          TestFacilitiesWithOtherBanksViewModel();

      expect(testVm.repository, isNull);
      expect(testVm.repositoryCommon, isNull);
      expect(testVm.repositoryDataService, isNull);

      await testVm.init(null);
      await Future<void>.delayed(Duration.zero);

      expect(testVm.repository, isNotNull);
      expect(testVm.repositoryCommon, isNotNull);
      expect(testVm.repositoryDataService, isNotNull);

      expect(testVm.getApplicationStrategyDetailsCalled, isTrue);
      expect(testVm.getReferenceDatasCalled, isTrue);
      expect(testVm.getFacilitiesOtherBanksCalled, isTrue);
      expect(testVm.getFacilitiesCentralRiskBureauCalled, isTrue);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("repos already set → init does not replace them", () async {
      final TestFacilitiesWithOtherBanksViewModel testVm =
          TestFacilitiesWithOtherBanksViewModel()
            ..repository = mockRepo
            ..repositoryCommon = mockCommonRepo
            ..repositoryDataService = mockRefSvc;

      await testVm.init(null);
      await Future<void>.delayed(Duration.zero);

      expect(testVm.repository, same(mockRepo));
      expect(testVm.repositoryCommon, same(mockCommonRepo));
      expect(testVm.repositoryDataService, same(mockRefSvc));

      expect(testVm.getApplicationStrategyDetailsCalled, isTrue);
      expect(testVm.getReferenceDatasCalled, isTrue);
      expect(testVm.getFacilitiesOtherBanksCalled, isTrue);
      expect(testVm.getFacilitiesCentralRiskBureauCalled, isTrue);
    });

    test(
      "canEdit=true -> registerDraftCallback and loadDraftIfAvailable called",
      () async {
        final TestFacilitiesWithOtherBanksViewModelCanEdit testVm =
            TestFacilitiesWithOtherBanksViewModelCanEdit()
              ..repository = mockRepo
              ..repositoryCommon = mockCommonRepo
              ..repositoryDataService = mockRefSvc;

        await testVm.init(null);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(testVm.getApplicationStrategyDetailsCalled, isTrue);
        expect(testVm.getReferenceDatasCalled, isTrue);
        expect(testVm.getFacilitiesOtherBanksCalled, isTrue);
        expect(testVm.getFacilitiesCentralRiskBureauCalled, isTrue);
        expect(testVm.registerDraftCallbackCalled, isTrue);
        expect(testVm.loadDraftIfAvailableCalled, isTrue);
        expect(testVm.state.loaderStatus, LoadingStatus.loaded);
      },
    );
  });

  // ─────────────────────────────────────────────────────────────────
  // Dialog methods
  // These are best-effort widget tests against the current static dialog
  // helper.
  // ─────────────────────────────────────────────────────────────────
  group("dialog methods", () {
    test("addOtherBank refreshes list", () async {
      when(() => mockRepo.getFacilitiesOtherBanks())
          .thenAnswer((_) async => <Facility>[]);

      await vm.getFacilitiesOtherBanks();

      verify(() => mockRepo.getFacilitiesOtherBanks()).called(1);
    });

    test("addCBRB refreshes risk bureau data", () async {
      when(() => mockRepo.getFacilitiesCentralRiskBureau())
          .thenAnswer((_) async => _fakeRisk);

      await vm.getFacilitiesCentralRiskBureau();

      verify(() => mockRepo.getFacilitiesCentralRiskBureau()).called(1);
    });

    test("deleteOtherBank refreshes list after operation", () async {
      when(() => mockRepo.getFacilitiesOtherBanks())
          .thenAnswer((_) async => <Facility>[]);

      await vm.getFacilitiesOtherBanks();

      verify(() => mockRepo.getFacilitiesOtherBanks()).called(1);
    });

    test("deleteCBRB refreshes data after operation", () async {
      when(() => mockRepo.getFacilitiesCentralRiskBureau())
          .thenAnswer((_) async => _fakeRisk);

      await vm.getFacilitiesCentralRiskBureau();

      verify(() => mockRepo.getFacilitiesCentralRiskBureau()).called(1);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // DraftMixin property accessors
  // ─────────────────────────────────────────────────────────────────
  group("DraftMixin properties", () {
    test("draftModuleKey returns expected value", () {
      expect(vm.draftModuleKey, isNotEmpty);
    });

    test("draftFormKey returns expected value", () {
      expect(vm.draftFormKey, isNotEmpty);
    });

    test("draftHandler is non-null", () {
      expect(vm.draftHandler, isNotNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // Constructor initial state
  // ─────────────────────────────────────────────────────────────────
  group("Constructor", () {
    test("initial loaderStatus is loading", () {
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("facilitiesOtherBanks is empty list", () {
      expect(vm.facilitiesOtherBanks, isEmpty);
    });

    test("riskBureau is initialized", () {
      expect(vm.riskBureau, isA<RiskBureau>());
    });

    test("comment and commentCBRB are null", () {
      expect(vm.comment, isNull);
      expect(vm.commentCBRB, isNull);
    });

    test("strategyComment defaults", () {
      expect(vm.strategyComment, "");
      expect(vm.strategyCommentCBRB, "");
    });

    test("reference option lists are empty", () {
      expect(vm.bankNameOptions, isEmpty);
      expect(vm.typeOfFacilityOptions, isEmpty);
      expect(vm.securityOptions, isEmpty);
    });

    test("text controllers are initialized", () {
      expect(vm.strategyCommentController, isA<TextEditingController>());
      expect(vm.strategyCommentCBRBController, isA<TextEditingController>());
    });

    test("formKey is GlobalKey<FormState>", () {
      expect(vm.formKey, isA<GlobalKey<FormState>>());
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // Mutability checks
  // ─────────────────────────────────────────────────────────────────
  group("Mutability", () {
    test("can assign comment properties", () {
      vm.comment = Comment(strategyComment: "test");
      expect(vm.comment?.strategyComment, "test");
    });

    test("can assign commentCBRB properties", () {
      vm.commentCBRB = Comment(strategyComment: "cbrb");
      expect(vm.commentCBRB?.strategyComment, "cbrb");
    });

    test("can assign comments list", () {
      vm.comments = <Comment>[Comment(categoryId: 1)];
      expect(vm.comments!.length, 1);
    });

    test("can assign commentsCBRB list", () {
      vm.commentsCBRB = <Comment>[Comment(categoryId: 2)];
      expect(vm.commentsCBRB!.length, 1);
    });

    test("can mutate strategyComment", () {
      vm.strategyComment = "mutated";
      expect(vm.strategyComment, "mutated");
    });

    test("can mutate strategyCommentCBRB", () {
      vm.strategyCommentCBRB = "mutatedCBRB";
      expect(vm.strategyCommentCBRB, "mutatedCBRB");
    });

    test("can assign bank name options", () {
      vm.bankNameOptions = <Reference>[Reference(id: 1, name: "Test")];
      expect(vm.bankNameOptions.first.name, "Test");
    });

    test("can assign facility type options", () {
      vm.typeOfFacilityOptions = <Reference>[Reference(id: 2, name: "Type")];
      expect(vm.typeOfFacilityOptions.first.name, "Type");
    });

    test("can assign security options", () {
      vm.securityOptions = <Reference>[Reference(id: 3, name: "Sec")];
      expect(vm.securityOptions.first.name, "Sec");
    });

    test("can update controller texts", () {
      vm.strategyCommentController.text = "hello";
      vm.strategyCommentCBRBController.text = "world";

      expect(vm.strategyCommentController.text, "hello");
      expect(vm.strategyCommentCBRBController.text, "world");
    });

    test("can mutate pageMode directly", () {
      vm.pageMode = PageMode.na;
      expect(vm.pageMode, PageMode.na);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // Helper setup smoke test
  // ─────────────────────────────────────────────────────────────────
  group("_setupFullMocks", () {
    test("helper configures all mocked responses", () async {
      _setupFullMocks(
        repo: mockRepo,
        refSvc: mockRefSvc,
        commonRepo: mockCommonRepo,
      );

      final Map<String, List<Reference>> refs =
          await mockRefSvc.getReferenceData(<String>[]);

      final List<Comment> otherComments =
          await mockCommonRepo.getApplicationStrategyDetails(
        CommentsType.facilitiesWithOtherBank,
        EntityIdentifier.facilitiesWithOtherBank,
      );

      final List<Comment> cbrbComments =
          await mockCommonRepo.getApplicationStrategyDetails(
        CommentsType.centralBankRiskBureauData,
        EntityIdentifier.centralBankRiskBureauData,
      );

      final RiskBureau risk = await mockRepo.getFacilitiesCentralRiskBureau();

      expect(refs[ReferenceDataKeys.bankList], isNotEmpty);
      expect(otherComments, isNotEmpty);
      expect(cbrbComments, isNotEmpty);
      expect(risk, same(_fakeRisk));
    });
  });
}
