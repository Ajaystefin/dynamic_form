import "dart:io";
import "dart:ui" as ui;


import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";

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

// -----------------------------------------------------------------------------
// Mocks
// -----------------------------------------------------------------------------
class MockGroupInformationRepository extends Mock
    implements GroupInformationRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockCommonRepository extends Mock implements CommonRepository {}

class FakeComment extends Fake implements Comment {}

// -----------------------------------------------------------------------------
// EasyLocalization test loader
// -----------------------------------------------------------------------------
class TestAssetLoader extends AssetLoader {
  const TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return <String, dynamic>{
      "groupInformation": <String, dynamic>{
        "facilitiesWithOtherBanks": <String, dynamic>{
          "title": "Facilities With Other Banks",
          "title_central": "Central Risk Bureau",
          "delete": "Delete",
          "cancel": "Cancel",
          "warning": "Warning",
          "warningmsg": "Are you sure?",
        },
      },
    };
  }
}

// -----------------------------------------------------------------------------
// Silent AlertManager
// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// Fake local storage
// -----------------------------------------------------------------------------
class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _store =
      <String, Map<String, dynamic>>{};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, Object? value) async {
    _store[box] ??= <String, dynamic>{};
    _store[box]![key] = value;
  }

  @override
  Future<dynamic> get(String box, String key) async {
    return _store[box]?[key];
  }

  @override
  Future<void> delete(String box, String key) async {
    _store[box]?.remove(key);
  }

  @override
  Future<void> clearBox(String box) async {
    _store[box]?.clear();
  }
}

// -----------------------------------------------------------------------------
// Test subclasses
// -----------------------------------------------------------------------------
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
}

class TestFacilitiesWithOtherBanksViewModelClose
    extends FacilitiesWithOtherBanksViewModel {
  bool unregisterDraftCallbackCalled = false;

  @override
  void unregisterDraftCallback() {
    unregisterDraftCallbackCalled = true;
  }
}

// -----------------------------------------------------------------------------
// Fake data
// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------
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

  when(() => repo.getFacilitiesOtherBanks()).thenAnswer(
    (_) async => <Facility>[],
  );

  when(() => repo.getFacilitiesCentralRiskBureau()).thenAnswer(
    (_) async => _fakeRisk,
  );

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

Future<void> runOnSaveCommentWithoutPendingTimers(
  WidgetTester tester,
  Future<void> Function() body,
) async {
  await tester.runAsync(() async {
    await HttpOverrides.runZoned(
      () async {
        try {
          await body();
        } on Object {
          // Production code uses CommonRepository.instance directly.
          // Block real HTTP and swallow for test safety.
        }
      },
      createHttpClient: (SecurityContext? context) {
        throw const SocketException("Blocked by test");
      },
    );
  });
}

Future<BuildContext> pumpWidgetWithoutNavigator(WidgetTester tester) async {
  late BuildContext capturedContext;

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const <Locale>[Locale("en")],
      fallbackLocale: const Locale("en"),
      startLocale: const Locale("en"),
      path: "unused",
      assetLoader: const TestAssetLoader(),
      saveLocale: false,
      child: Builder(
        builder: (BuildContext context) {
          return Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Builder(
              builder: (BuildContext innerContext) {
                capturedContext = innerContext;
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    ),
  );

  await tester.pump();
  return capturedContext;
}

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  late FacilitiesWithOtherBanksViewModel vm;
  late MockGroupInformationRepository mockRepo;
  late MockReferenceDataService mockRefSvc;
  late MockCommonRepository mockCommonRepo;

  const MethodChannel connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();

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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);

    await TestConfig.cleanup();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    mockRepo = MockGroupInformationRepository();
    mockRefSvc = MockReferenceDataService();
    mockCommonRepo = MockCommonRepository();

    vm = FacilitiesWithOtherBanksViewModel()
      ..repository = mockRepo
      ..repositoryDataService = mockRefSvc
      ..repositoryCommon = mockCommonRepo;

    AlertManager.overrideInstance = _SilentAlertManager();
    LocalStorageService().getStorage = MockLocalStorageService();

    Globals.request = null;
    Globals.user = null;
  });

  group("Constructor", () {
    test("initial values are set correctly", () {
      expect(vm.state.loaderStatus, LoadingStatus.loading);
      expect(vm.repository, same(mockRepo));
      expect(vm.repositoryDataService, same(mockRefSvc));
      expect(vm.repositoryCommon, same(mockCommonRepo));
      expect(vm.formKey, isA<GlobalKey<FormState>>());
      expect(vm.riskBureau, isA<RiskBureau>());
      expect(vm.facilitiesOtherBanks, isEmpty);
      expect(vm.comments, isNull);
      expect(vm.comment, isNull);
      expect(vm.strategyComment, "");
      expect(vm.commentsCBRB, isNull);
      expect(vm.commentCBRB, isNull);
      expect(vm.strategyCommentCBRB, "");
      expect(vm.bankNameOptions, isEmpty);
      expect(vm.typeOfFacilityOptions, isEmpty);
      expect(vm.securityOptions, isEmpty);
      expect(vm.strategyCommentController, isA<TextEditingController>());
      expect(vm.strategyCommentCBRBController, isA<TextEditingController>());
      expect(vm.pageMode, PageMode.na);
    });
  });

  group("DraftMixin properties", () {
    test("draftModuleKey returns expected value", () {
      expect(vm.draftModuleKey, isNotEmpty);
    });

    test("draftFormKey returns expected value", () {
      expect(vm.draftFormKey, isNotEmpty);
    });

    test("draftHandler returns handler", () {
      expect(vm.draftHandler, isNotNull);
    });
  });

  group("getReferenceDatas", () {
    test("success populates all reference lists", () async {
      when(() => mockRefSvc.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{
          ReferenceDataKeys.bankList: <Reference>[_fakeRef],
          ReferenceDataKeys.facilityTypes: <Reference>[_fakeRef],
          ReferenceDataKeys.securityType: <Reference>[_fakeRef],
        },
      );

      await vm.getReferenceDatas();

      expect(vm.bankNameOptions, hasLength(1));
      expect(vm.typeOfFacilityOptions, hasLength(1));
      expect(vm.securityOptions, hasLength(1));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("missing reference keys default to empty lists", () async {
      when(() => mockRefSvc.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{
          ReferenceDataKeys.bankList: <Reference>[_fakeRef],
        },
      );

      await vm.getReferenceDatas();

      expect(vm.bankNameOptions, hasLength(1));
      expect(vm.typeOfFacilityOptions, isEmpty);
      expect(vm.securityOptions, isEmpty);
    });

    test("empty reference data defaults all lists to empty", () async {
      when(() => mockRefSvc.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{},
      );

      await vm.getReferenceDatas();

      expect(vm.bankNameOptions, isEmpty);
      expect(vm.typeOfFacilityOptions, isEmpty);
      expect(vm.securityOptions, isEmpty);
    });

    test("error is caught silently", () async {
      when(() => mockRefSvc.getReferenceData(any())).thenThrow(
        Exception("ref error"),
      );

      await vm.getReferenceDatas();

      expect(vm.bankNameOptions, isEmpty);
      expect(vm.typeOfFacilityOptions, isEmpty);
      expect(vm.securityOptions, isEmpty);
    });
  });

  group("getFacilitiesOtherBanks", () {
    test("success sets list and loaded status", () async {
      when(() => mockRepo.getFacilitiesOtherBanks()).thenAnswer(
        (_) async => <Facility>[],
      );

      await vm.getFacilitiesOtherBanks();

      expect(vm.facilitiesOtherBanks, isNotNull);
      expect(vm.facilitiesOtherBanks, isEmpty);
      expect(vm.state.otherBankLoader, LoadingStatus.loaded);
    });

    test("error sets loader to error", () async {
      when(() => mockRepo.getFacilitiesOtherBanks()).thenThrow(
        Exception("oops"),
      );

      await vm.getFacilitiesOtherBanks();

      expect(vm.state.otherBankLoader, LoadingStatus.error);
    });
  });

  group("getFacilitiesCentralRiskBureau", () {
    test("success sets risk bureau and loaded status", () async {
      when(() => mockRepo.getFacilitiesCentralRiskBureau()).thenAnswer(
        (_) async => _fakeRisk,
      );

      await vm.getFacilitiesCentralRiskBureau();

      expect(vm.riskBureau, same(_fakeRisk));
      expect(vm.state.cbrbTableLoader, LoadingStatus.loaded);
    });

    test("error sets cbrb loader to error", () async {
      when(() => mockRepo.getFacilitiesCentralRiskBureau()).thenThrow(
        Exception("cbrb error"),
      );

      await vm.getFacilitiesCentralRiskBureau();

      expect(vm.state.cbrbTableLoader, LoadingStatus.error);
    });
  });

  group("getApplicationStrategyDetails", () {
    test("matching comments populate strategy values and controllers", () async {
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

      expect(vm.comments, hasLength(1));
      expect(vm.commentsCBRB, hasLength(1));
      expect(vm.strategyComment, "OB Strategy");
      expect(vm.strategyCommentCBRB, "CBRB Strategy");
      expect(vm.strategyCommentController.text, "OB Strategy");
      expect(vm.strategyCommentCBRBController.text, "CBRB Strategy");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("empty comment lists produce empty strategy values", () async {
      when(() => mockCommonRepo.getApplicationStrategyDetails(any(), any()))
          .thenAnswer((_) async => <Comment>[]);

      await vm.getApplicationStrategyDetails();

      expect(vm.strategyComment, "");
      expect(vm.strategyCommentCBRB, "");
      expect(vm.strategyCommentController.text, "");
      expect(vm.strategyCommentCBRBController.text, "");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("non matching category ids produce empty strategy values", () async {
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
      expect(vm.strategyCommentController.text, "");
      expect(vm.strategyCommentCBRBController.text, "");
    });

    test("matching comments with null strategy text update controllers safely",
        () async {
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithOtherBank,
          EntityIdentifier.facilitiesWithOtherBank,
        ),
      ).thenAnswer(
        (_) async => <Comment>[
          Comment(categoryId: ServerConstants.otherBankCategoryID),
        ],
      );

      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.centralBankRiskBureauData,
          EntityIdentifier.centralBankRiskBureauData,
        ),
      ).thenAnswer(
        (_) async => <Comment>[
          Comment(categoryId: ServerConstants.cbrbCategoryID),
        ],
      );

      await vm.getApplicationStrategyDetails();

      expect(vm.strategyComment, isNull);
      expect(vm.strategyCommentCBRB, isNull);
      expect(vm.strategyCommentController.text, "");
      expect(vm.strategyCommentCBRBController.text, "");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("exception sets loader status error", () async {
      when(() => mockCommonRepo.getApplicationStrategyDetails(any(), any()))
          .thenThrow(Exception("network"));

      await vm.getApplicationStrategyDetails();

      expect(vm.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("onSaveComment", () {
    testWidgets("invalid form does not build comments",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: vm.formKey,
              child: TextFormField(
                validator: (_) => "required",
              ),
            ),
          ),
        ),
      );

      await vm.onSaveComment();

      expect(vm.commentCBRB, isNull);
      expect(vm.comment, isNull);
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    testWidgets(
      "valid form builds CBRB comment before real singleton repository call",
      (WidgetTester tester) async {
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

        Globals.request = Request(applicationRefNo: "APP-123");
        Globals.user = User(
          id: "user-1",
          currentRole: Role(roleId: 42),
        );

        vm
          ..strategyComment = "Other bank strategy"
          ..strategyCommentCBRB = "CBRB strategy";

        await runOnSaveCommentWithoutPendingTimers(
          tester,
          () => vm.onSaveComment(),
        );

        await tester.pump();

        expect(savedValue, "typed-value");
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
        expect(vm.comment, isNull);
        expect(vm.state.loaderStatus, LoadingStatus.loading);
      },
    );

    testWidgets(
      "valid form with null globals still builds CBRB comment safely",
      (WidgetTester tester) async {
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

        Globals.request = null;
        Globals.user = null;

        vm
          ..strategyComment = "Other bank strategy"
          ..strategyCommentCBRB = "CBRB strategy";

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
  });

  group("dialog methods stable coverage", () {
    testWidgets(
      "addOtherBank executes finally refresh when dialog fails to open",
      (WidgetTester tester) async {
        when(() => mockRepo.getFacilitiesOtherBanks()).thenAnswer(
          (_) async => <Facility>[],
        );

        final BuildContext context = await pumpWidgetWithoutNavigator(tester);

        await expectLater(
          vm.addOtherBank(context, null),
          throwsA(isA<Object>()),
        );

        verify(() => mockRepo.getFacilitiesOtherBanks()).called(1);
      },
    );

    testWidgets(
      "addCBRB executes finally refresh when dialog fails to open",
      (WidgetTester tester) async {
        when(() => mockRepo.getFacilitiesCentralRiskBureau()).thenAnswer(
          (_) async => _fakeRisk,
        );

        final BuildContext context = await pumpWidgetWithoutNavigator(tester);

        await expectLater(
          vm.addCBRB(context, null),
          throwsA(isA<Object>()),
        );

        verify(() => mockRepo.getFacilitiesCentralRiskBureau()).called(1);
      },
    );

    testWidgets(
      "deleteOtherBankFacility executes finally refresh when dialog fails to open",
      (WidgetTester tester) async {
        when(() => mockRepo.getFacilitiesOtherBanks()).thenAnswer(
          (_) async => <Facility>[],
        );

        final BuildContext context = await pumpWidgetWithoutNavigator(tester);

        await expectLater(
          vm.deleteOtherBankFacility(context, null),
          throwsA(isA<Object>()),
        );

        verify(() => mockRepo.getFacilitiesOtherBanks()).called(1);
      },
    );

    testWidgets(
      "deleteCBRBData executes finally refresh when dialog fails to open",
      (WidgetTester tester) async {
        when(() => mockRepo.getFacilitiesCentralRiskBureau()).thenAnswer(
          (_) async => _fakeRisk,
        );

        final BuildContext context = await pumpWidgetWithoutNavigator(tester);

        await expectLater(
          vm.deleteCBRBData(context, null),
          throwsA(isA<Object>()),
        );

        verify(() => mockRepo.getFacilitiesCentralRiskBureau()).called(1);
      },
    );
  });

  group("buildNames", () {
    final List<Reference> options = <Reference>[
      Reference(id: 1, name: "BankA"),
      Reference(id: 2, name: "BankB"),
      Reference(id: 3),
    ];

    test('refs empty list returns "--"', () {
      expect(vm.buildNames(refs: <Reference>[], options: options), "--");
    });

    test("refs with matching ids return joined names", () {
      final String result = vm.buildNames(
        refs: <Reference>[
          Reference(id: 1),
          Reference(id: 2),
        ],
        options: options,
      );

      expect(result, "BankA, BankB");
    });

    test('refs with unmatched id returns "--"', () {
      final String result = vm.buildNames(
        refs: <Reference>[Reference(id: 99)],
        options: options,
      );

      expect(result, "--");
    });

    test('refs with null name in options returns "--"', () {
      final String result = vm.buildNames(
        refs: <Reference>[Reference(id: 3)],
        options: options,
      );

      expect(result, "--");
    });

    test("refs mixed matched and unmatched returns joined output", () {
      final String result = vm.buildNames(
        refs: <Reference>[
          Reference(id: 1),
          Reference(id: 999),
        ],
        options: options,
      );

      expect(result, "BankA, --");
    });

    test("id matching returns name", () {
      expect(vm.buildNames(options: options, id: 2), "BankB");
    });

    test('id not matching returns "--"', () {
      expect(vm.buildNames(options: options, id: 100), "--");
    });

    test('id with null name in options returns "--"', () {
      expect(vm.buildNames(options: options, id: 3), "--");
    });

    test('neither refs nor id returns "--"', () {
      expect(vm.buildNames(options: options), "--");
    });
  });

  group("canEdit", () {
    test("initial pageMode na returns false", () {
      expect(vm.canEdit, isFalse);
    });

    test("pageMode edit returns true when not cancellation app", () {
      vm.pageMode = PageMode.edit;
      expect(vm.canEdit, isTrue);
    });

    test("pageMode view returns false", () {
      vm.pageMode = PageMode.view;
      expect(vm.canEdit, isFalse);
    });
  });

  group("close", () {
    test("close completes", () async {
      await expectLater(vm.close(), completes);
    });

    test("close calls unregisterDraftCallback", () async {
      final TestFacilitiesWithOtherBanksViewModelClose testVm =
          TestFacilitiesWithOtherBanksViewModelClose();

      await testVm.close();

      expect(testVm.unregisterDraftCallbackCalled, isTrue);
    });
  });

  group("init", () {
    test("null repositories are assigned and load methods are called", () async {
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

    test("existing repositories are not replaced", () async {
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

    test("canEdit true registers and loads draft", () async {
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
    });
  });

  group("mutability", () {
    test("can assign comment", () {
      vm.comment = Comment(strategyComment: "test");
      expect(vm.comment?.strategyComment, "test");
    });

    test("can assign commentCBRB", () {
      vm.commentCBRB = Comment(strategyComment: "cbrb");
      expect(vm.commentCBRB?.strategyComment, "cbrb");
    });

    test("can assign comments list", () {
      vm.comments = <Comment>[Comment(categoryId: 1)];
      expect(vm.comments, hasLength(1));
    });

    test("can assign commentsCBRB list", () {
      vm.commentsCBRB = <Comment>[Comment(categoryId: 2)];
      expect(vm.commentsCBRB, hasLength(1));
    });

    test("can mutate strategy comments", () {
      vm
        ..strategyComment = "mutated"
        ..strategyCommentCBRB = "mutatedCBRB";

      expect(vm.strategyComment, "mutated");
      expect(vm.strategyCommentCBRB, "mutatedCBRB");
    });

    test("can assign reference options", () {
      vm
        ..bankNameOptions = <Reference>[Reference(id: 1, name: "Bank")]
        ..typeOfFacilityOptions = <Reference>[Reference(id: 2, name: "Type")]
        ..securityOptions = <Reference>[Reference(id: 3, name: "Security")];

      expect(vm.bankNameOptions.first.name, "Bank");
      expect(vm.typeOfFacilityOptions.first.name, "Type");
      expect(vm.securityOptions.first.name, "Security");
    });

    test("can update controller texts", () {
      vm
        ..strategyCommentController.text = "hello"
        ..strategyCommentCBRBController.text = "world";

      expect(vm.strategyCommentController.text, "hello");
      expect(vm.strategyCommentCBRBController.text, "world");
    });

    test("can mutate pageMode", () {
      vm.pageMode = PageMode.na;
      expect(vm.pageMode, PageMode.na);
    });
  });

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

      final List<Facility> facilities =
          await mockRepo.getFacilitiesOtherBanks();

      final RiskBureau risk = await mockRepo.getFacilitiesCentralRiskBureau();

      expect(refs[ReferenceDataKeys.bankList], isNotEmpty);
      expect(otherComments, isNotEmpty);
      expect(cbrbComments, isNotEmpty);
      expect(facilities, isEmpty);
      expect(risk, same(_fakeRisk));
    });
  });
}
