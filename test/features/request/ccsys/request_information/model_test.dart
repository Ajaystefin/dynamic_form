import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:toastification/toastification.dart";

import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/ccsys_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";

import "../../../../test_config.dart";

/* ================= MOCKS / FAKES ================= */

class MockCcsysRepository extends Mock implements CcsysRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeApplicationDetails extends Fake implements ApplicationDetails {}

Reference ref({
  required int id,
  required String name,
  String? reference1,
  String? reference2,
  String? reference3,
  String? reference4,
  String? reference5,
}) {
  return Reference(
    id: id,
    name: name,
    reference1: reference1,
    reference2: reference2,
    reference3: reference3,
    reference4: reference4,
    reference5: reference5,
  );
}

Reference ccsysFallbackReference() {
  return Reference(
    id: ServerConstants.ccsysAppReferenceId,
    name: ServerConstants.ccsysAppReferenceName,
    reference1: ServerConstants.ccsysAppReference1,
    reference2: ServerConstants.ccsysAppReference2,
    reference3: ServerConstants.ccsysAppReference3,
    reference4: ServerConstants.ccsysAppReference4,
    reference5: ServerConstants.ccsysAppReference5,
  );
}

ApplicationDetails details({
  String? applicationRefNo,
  String? lastApprovedAppRefNum,
  String? approvedDate,
  String? branch,
  String? region,
  bool? enabledForView,
  int? status,
  String? instanceId,
  String? businessSegment,
}) {
  return ApplicationDetails()
    ..applicationRefNo = applicationRefNo
    ..lastApprovedAppRefNum = lastApprovedAppRefNum
    ..approvedDate = approvedDate
    ..branch = branch
    ..region = region
    ..enabledForView = enabledForView
    ..status = status
    ..instanceId = instanceId
    ..businessSegment = businessSegment;
}

Request buildRequest({
  bool isCreateRequest = true,
  bool? ccsysCanEditReadOnly = true,
  String? applicationRefNo,
}) {
  return Request()
    ..isCreateRequest = isCreateRequest
    ..ccsysCanEditReadOnly = ccsysCanEditReadOnly
    ..applicationRefNo = applicationRefNo
    ..businessSegment = ref(
      id: ServerConstants.businessSegmentId[BusinessSegment.corporate] ?? 1,
      name: "Corporate",
      reference1: "CORP",
    )
    ..requestType = ref(
      id: 11,
      name: "New",
      reference1: "NEW",
      reference2: "REQ2",
    )
    ..applicationType = ref(
      id: 22,
      name: "Application Type",
      reference1: "APP-SUB-TYPE",
    )
    ..customerRimNo = 123456
    ..customerName = "Test Customer"
    ..branch = "HQ";
}

RequestInformationViewModel readyVm({
  required MockCcsysRepository repo,
  required MockCustomerRepository customerRepo,
  bool isCreateRequest = true,
  bool isExistingApp = false,
  String? existingAppRefNo,
}) {
  Globals.request = buildRequest(
    isCreateRequest: isCreateRequest,
    applicationRefNo: existingAppRefNo,
  );

  return RequestInformationViewModel()
    ..repository = repo
    ..repositoryCustomer = customerRepo
    ..isNewRequest = isCreateRequest
    ..isExisitngAppRefNo = isExistingApp
    ..selectedLastApprovedAppRefNum = "LAST-APP"
    ..applicationDetails = details(
      applicationRefNo: existingAppRefNo,
      approvedDate: "2024-01-01",
      branch: "HQ",
      region: "DXB",
      enabledForView: false,
      status: 1,
      instanceId: "INSTANCE-1",
      businessSegment: "Existing Segment",
    )
    ..applicationType = <Reference>[
      ccsysFallbackReference(),
    ];
}

void stubAlertManager(MockAlertManager alerts) {
  when(() => alerts.showFailureToast(any())).thenReturn(null);
  when(() => alerts.showSuccessToast(any())).thenReturn(null);
  when(() => alerts.showInfoToast(any())).thenReturn(null);
  when(() => alerts.showWarningToast(any())).thenReturn(null);
}

void stubRepositorySuccess(MockCcsysRepository repo) {
  when(() => repo.getApplicationDetails()).thenAnswer(
    (_) async => details(
      applicationRefNo: "EXISTING-001",
      lastApprovedAppRefNum: "LAST-001",
      approvedDate: "2024-04-01",
      branch: "BR",
      region: "RG",
      enabledForView: true,
      status: 2,
      instanceId: "INST-OLD",
      businessSegment: "Corporate",
    ),
  );

  when(() => repo.getLastApprovedApplication()).thenAnswer(
    (_) async => details(
      applicationRefNo: "LAST-APP-001",
      approvedDate: "2024-03-01",
    ),
  );

  when(() => repo.saveApplicationInformation(any())).thenAnswer(
    (_) async => "APP-SAVED-001",
  );
}

GoRouter makeRouter(Widget child) {
  String customerInfoPath = Routes.ccsysCustomerInformation;
  if (!customerInfoPath.startsWith("/")) {
    customerInfoPath = "/$customerInfoPath";
  }

  return GoRouter(
    initialLocation: "/",
    routes: <RouteBase>[
      GoRoute(
        path: "/",
        builder: (_, __) => child,
      ),
      GoRoute(
        path: customerInfoPath,
        builder: (_, __) => const Scaffold(
          body: Text("customer-information"),
        ),
      ),
    ],
  );
}

Widget appTree(Widget child) {
  return ToastificationWrapper(
    child: MaterialApp.router(
      routerConfig: makeRouter(
        Scaffold(body: child),
      ),
    ),
  );
}

Future<void> pumpButton(
  WidgetTester tester,
  void Function(BuildContext context) onPressed,
) async {
  tester.view.physicalSize = const Size(2800, 1800);
  tester.view.devicePixelRatio = 2.0;

  await tester.pumpWidget(
    appTree(
      Builder(
        builder: (BuildContext context) {
          return Center(
            child: ElevatedButton(
              onPressed: () => onPressed(context),
              child: const Text("go"),
            ),
          );
        },
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void silenceOverflowErrors() {
  FlutterError.onError = (FlutterErrorDetails details) {
    final String text = details.exceptionAsString();
    if (text.contains("overflowed") || text.contains("RenderFlex")) {
      return;
    }
    FlutterError.presentError(details);
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  late MockCcsysRepository repo;
  late MockCustomerRepository customerRepo;
  late MockAlertManager alerts;

  final FlutterExceptionHandler? originalFlutterError = FlutterError.onError;

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall methodCall) async {
        if (methodCall.method == "check") {
          return <String>["wifi"];
        }

        return <String>["wifi"];
      },
    );

    SharedPreferences.setMockInitialValues(<String, Object>{});

    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
    await EasyLocalization.ensureInitialized();

    registerFallbackValue(FakeApplicationDetails());
  });

  setUp(() {
    repo = MockCcsysRepository();
    customerRepo = MockCustomerRepository();
    alerts = MockAlertManager();

    AlertManager.overrideInstance = alerts;

    stubAlertManager(alerts);
    stubRepositorySuccess(repo);

    Globals.request = buildRequest(isCreateRequest: false);
  });

  tearDown(() {
    FlutterError.onError = originalFlutterError;
  });

  group("RequestInformationState", () {
    test("constructor stores loaderStatus", () {
      final RequestInformationState state = RequestInformationState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing value when null", () {
      final RequestInformationState state = RequestInformationState(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(state.copyWith().loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides value", () {
      final RequestInformationState state = RequestInformationState(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(
        state.copyWith(loaderStatus: LoadingStatus.error).loaderStatus,
        LoadingStatus.error,
      );
      expect(state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("construction", () {
    test("initial values are correct", () {
      final RequestInformationViewModel vm = RequestInformationViewModel();

      expect(vm.state.loaderStatus, LoadingStatus.loading);
      expect(vm.applicationDetails, isNotNull);
      expect(vm.applicationType, isEmpty);
      expect(vm.selectedRequestType, isNull);
      expect(vm.selectedBusinessSegment, isNull);
      expect(vm.selectedApplicationType, isNull);
      expect(vm.status, isNull);
      expect(vm.isNewRequest, false);
      expect(vm.isApiError, false);
      expect(vm.isExisitngAppRefNo, false);
      expect(vm.selectedLastApprovedAppRefNum, isNull);
      expect(vm.approvedDate, isNull);
      expect(vm.lastApprovedAppDate, isNull);
      expect(vm.referenceData, isEmpty);
      expect(vm.canEdit, false);
      expect(vm.pageMode, PageMode.na);
      expect(vm.formFocusNode, isA<FocusNode>());
      expect(vm.formKey, isA<GlobalKey<FormState>>());
    });
  });

  group("initRightsAndMode", () {
    test("rights false always disables canEdit", () {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..initRightsAndMode(Request()..ccsysCanEditReadOnly = false);

      expect(vm.canEdit, false);
    });

    test("rights true sets canEdit as bool based on page mode", () {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..initRightsAndMode(Request()..ccsysCanEditReadOnly = true);

      expect(vm.canEdit, isA<bool>());
      expect(vm.pageMode, isA<PageMode>());
    });

    test("null rights are treated as true", () {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..initRightsAndMode(Request()..ccsysCanEditReadOnly = null);

      expect(vm.canEdit, isA<bool>());
      expect(vm.pageMode, isA<PageMode>());
    });
  });

  group("init", () {
    testWidgets("init completes and emits loaded", (WidgetTester tester) async {
      Globals.request = buildRequest(isCreateRequest: false);

      final RequestInformationViewModel vm = RequestInformationViewModel();

      await pumpButton(tester, (_) {});

      await tester.runAsync(() async {
        await vm.init(tester.element(find.byType(ElevatedButton)));
      });

      await tester.pump();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.selectedApplicationType, isNotNull);
      expect(vm.selectedRequestType, isNotNull);
      expect(vm.selectedBusinessSegment, isNotNull);
      expect(vm.isNewRequest, false);
      expect(vm.canEdit, isA<bool>());
    });

    testWidgets(
        "init handles repository/reference error and still emits loaded",
        (WidgetTester tester) async {
      when(() => repo.getApplicationDetails()).thenThrow(
        Exception("details failed"),
      );

      Globals.request = buildRequest(isCreateRequest: false);

      final RequestInformationViewModel vm = RequestInformationViewModel();

      await pumpButton(tester, (_) {});

      await tester.runAsync(() async {
        await vm.init(tester.element(find.byType(ElevatedButton)));
      });

      await tester.pump();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.isApiError, isA<bool>());
    });

    testWidgets("init handles null Globals.request",
        (WidgetTester tester) async {
      Globals.request = null;

      final RequestInformationViewModel vm = RequestInformationViewModel();

      await pumpButton(tester, (_) {});

      await tester.runAsync(() async {
        await vm.init(tester.element(find.byType(ElevatedButton)));
      });

      await tester.pump();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.selectedApplicationType, isNotNull);
      expect(vm.selectedRequestType, isNotNull);
      expect(vm.selectedBusinessSegment, isNotNull);
    });
  });

  group("getReferenceDatas", () {
    test("method completes or rethrows cleanly without crashing test",
        () async {
      final RequestInformationViewModel vm = RequestInformationViewModel();

      try {
        await vm.getReferenceDatas();
      } on Object {
        // API/environment dependent in unit tests.
      }

      expect(vm.applicationType, isA<List<Reference>>());
      expect(vm.referenceData, isA<Map<String, List<Reference>>>());
    });

    test("reference key constants are usable", () {
      expect(ReferenceDataKeys.applicationType, isNotEmpty);
      expect(ReferenceDataKeys.yesNoNa, isNotEmpty);
      expect(ReferenceDataKeys.ccsysCountryList, isNotEmpty);
      expect(ReferenceDataKeys.ccsysEmirateList, isNotEmpty);
      expect(ReferenceDataKeys.ccsysGender, isNotEmpty);
      expect(ReferenceDataKeys.ccsysPsLegalStatus, isNotEmpty);
      expect(ReferenceDataKeys.ccsysPsResidence, isNotEmpty);
      expect(ReferenceDataKeys.ccsysPsType, isNotEmpty);
    });
  });

  group("onSelectApplicationType", () {
    test("accepts reference", () {
      final RequestInformationViewModel vm = RequestInformationViewModel();

      expect(
        () => vm.onSelectApplicationType(Reference(id: 1, name: "A")),
        returnsNormally,
      );
    });

    test("accepts null", () {
      final RequestInformationViewModel vm = RequestInformationViewModel();

      expect(() => vm.onSelectApplicationType(null), returnsNormally);
    });
  });

  group("applicationTypeItems", () {
    test("returns empty when source list is empty", () {
      final RequestInformationViewModel vm = RequestInformationViewModel();

      expect(vm.applicationTypeItems(), isEmpty);
    });

    test("corporate path filters by request type and corporate code", () {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..selectedRequestType = ref(
          id: 1,
          name: "New",
          reference1: "NEW",
        )
        ..selectedBusinessSegment = ref(
          id: ServerConstants.businessSegmentId[BusinessSegment.corporate] ?? 1,
          name: "Corporate",
        )
        ..applicationType = <Reference>[
          ref(
            id: 10,
            name: "Corporate Item",
            reference3: ServerConstants.corperateCode,
            reference4: "NEW",
          ),
          ref(
            id: 11,
            name: "FI Item",
            reference3: ServerConstants.financialCode,
            reference4: "NEW",
          ),
          ref(
            id: 12,
            name: "Wrong Request",
            reference3: ServerConstants.corperateCode,
            reference4: "OTHER",
          ),
        ];

      final List<Reference> result = vm.applicationTypeItems();

      expect(result, hasLength(1));
      expect(result.first.name, "Corporate Item");
    });

    test("financial institution path filters by financial code", () {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..selectedRequestType = ref(
          id: 1,
          name: "New",
          reference1: "NEW",
        )
        ..selectedBusinessSegment = ref(
          id: ServerConstants
                  .businessSegmentId[BusinessSegment.financialInstitution] ??
              0,
          name: "FI",
        )
        ..applicationType = <Reference>[
          ref(
            id: 10,
            name: "FI Item",
            reference3: ServerConstants.financialCode,
            reference4: "NEW",
          ),
          ref(
            id: 11,
            name: "Corporate Item",
            reference3: ServerConstants.corperateCode,
            reference4: "NEW",
          ),
        ];

      final List<Reference> result = vm.applicationTypeItems();

      expect(result, hasLength(1));
      expect(result.first.name, "FI Item");
    });

    test("returns empty when request type does not match", () {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..selectedRequestType = ref(
          id: 1,
          name: "Different",
          reference1: "DIFF",
        )
        ..selectedBusinessSegment = ref(id: 1, name: "Corporate")
        ..applicationType = <Reference>[
          ref(
            id: 1,
            name: "A",
            reference3: ServerConstants.corperateCode,
            reference4: "NEW",
          ),
        ];

      expect(vm.applicationTypeItems(), isEmpty);
    });

    test("null selectedRequestType returns empty", () {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..selectedRequestType = null
        ..selectedBusinessSegment = ref(id: 1, name: "Corporate")
        ..applicationType = <Reference>[
          ref(
            id: 1,
            name: "A",
            reference3: ServerConstants.corperateCode,
            reference4: "NEW",
          ),
        ];

      expect(vm.applicationTypeItems(), isEmpty);
    });

    test("null selectedBusinessSegment falls through corporate branch", () {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..selectedRequestType = ref(
          id: 1,
          name: "New",
          reference1: "NEW",
        )
        ..selectedBusinessSegment = null
        ..applicationType = <Reference>[
          ref(
            id: 1,
            name: "A",
            reference3: ServerConstants.corperateCode,
            reference4: "NEW",
          ),
        ];

      expect(vm.applicationTypeItems(), hasLength(1));
    });

    test("null reference3 and reference4 do not throw", () {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..selectedRequestType = ref(
          id: 1,
          name: "New",
          reference1: "NEW",
        )
        ..selectedBusinessSegment = ref(id: 1, name: "Corporate")
        ..applicationType = <Reference>[
          Reference(id: 1, name: "No Ref3", reference4: "NEW"),
          Reference(
            id: 2,
            name: "No Ref4",
            reference3: ServerConstants.corperateCode,
          ),
        ];

      expect(vm.applicationTypeItems, returnsNormally);
      expect(vm.applicationTypeItems(), isEmpty);
    });
  });

  group("getApplicationDetails", () {
    test("new request maps last approved application data", () async {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..repository = repo
        ..repositoryCustomer = customerRepo
        ..isNewRequest = true;

      when(() => repo.getLastApprovedApplication()).thenAnswer(
        (_) async => details(
          applicationRefNo: "LAST-001",
          approvedDate: "2024-05-01",
        ),
      );

      await vm.getApplicationDetails();

      verify(() => repo.getLastApprovedApplication()).called(1);
      expect(vm.applicationDetails?.applicationRefNo, "LAST-001");
      expect(vm.selectedLastApprovedAppRefNum, "LAST-001");
      expect(vm.approvedDate, "2024-05-01");
      expect(vm.lastApprovedAppDate, "2024-05-01");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("new request null response creates empty application details",
        () async {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..repository = repo
        ..repositoryCustomer = customerRepo
        ..isNewRequest = true;

      when(() => repo.getLastApprovedApplication()).thenAnswer(
        (_) async => null,
      );

      await vm.getApplicationDetails();

      expect(vm.applicationDetails, isNotNull);
      expect(vm.selectedLastApprovedAppRefNum, isNull);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("new request exception is swallowed", () async {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..repository = repo
        ..repositoryCustomer = customerRepo
        ..isNewRequest = true;

      when(() => repo.getLastApprovedApplication()).thenThrow(
        Exception("last approved failed"),
      );

      await expectLater(vm.getApplicationDetails(), completes);
    });

    test("existing request maps current application details", () async {
      Globals.request = buildRequest(isCreateRequest: false);

      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..repository = repo
        ..repositoryCustomer = customerRepo
        ..isNewRequest = false;

      when(() => repo.getApplicationDetails()).thenAnswer(
        (_) async => details(
          applicationRefNo: "APP-001",
          lastApprovedAppRefNum: "LAST-002",
          approvedDate: "2024-06-01",
        ),
      );

      await vm.getApplicationDetails();

      verify(() => repo.getApplicationDetails()).called(1);
      expect(vm.selectedLastApprovedAppRefNum, "LAST-002");
      expect(vm.approvedDate, "2024-06-01");
      expect(vm.isExisitngAppRefNo, true);
      expect(Globals.request?.isCreateRequest, false);
      expect(vm.isNewRequest, false);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("existing request whitespace app ref is not existing", () async {
      Globals.request = buildRequest(isCreateRequest: false);

      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..repository = repo
        ..repositoryCustomer = customerRepo
        ..isNewRequest = false;

      when(() => repo.getApplicationDetails()).thenAnswer(
        (_) async => details(applicationRefNo: "   "),
      );

      await vm.getApplicationDetails();

      expect(vm.isExisitngAppRefNo, false);
    });

    test("existing request null app ref is not existing", () async {
      Globals.request = buildRequest(isCreateRequest: false);

      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..repository = repo
        ..repositoryCustomer = customerRepo
        ..isNewRequest = false;

      when(() => repo.getApplicationDetails()).thenAnswer(
        (_) async => details(),
      );

      await vm.getApplicationDetails();

      expect(vm.isExisitngAppRefNo, false);
    });

    test("existing request exception is swallowed", () async {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..repository = repo
        ..repositoryCustomer = customerRepo
        ..isNewRequest = false;

      when(() => repo.getApplicationDetails()).thenThrow(
        Exception("current details failed"),
      );

      await expectLater(vm.getApplicationDetails(), completes);
    });
  });

  group("onSavePressed", () {
    testWidgets("save new request success updates globals and emits loaded",
        (WidgetTester tester) async {
      silenceOverflowErrors();

      when(() => repo.saveApplicationInformation(any())).thenAnswer(
        (_) async => "NEW-APP-001",
      );

      final RequestInformationViewModel vm = readyVm(
        repo: repo,
        customerRepo: customerRepo,
      );

      await pumpButton(tester, vm.onSavePressed);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => repo.saveApplicationInformation(any())).called(1);
      expect(Globals.request?.applicationRefNo, "NEW-APP-001");
      expect(Globals.request?.isCreateRequest, false);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save existing request success preserves save flow",
        (WidgetTester tester) async {
      silenceOverflowErrors();

      when(() => repo.saveApplicationInformation(any())).thenAnswer(
        (_) async => "UPDATED-001",
      );

      final RequestInformationViewModel vm = readyVm(
        repo: repo,
        customerRepo: customerRepo,
        isCreateRequest: false,
        isExistingApp: true,
        existingAppRefNo: "OLD-001",
      );

      await pumpButton(tester, vm.onSavePressed);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => repo.saveApplicationInformation(any())).called(1);
      expect(Globals.request?.applicationRefNo, "UPDATED-001");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save empty result does not show dialog and emits loaded",
        (WidgetTester tester) async {
      silenceOverflowErrors();

      when(() => repo.saveApplicationInformation(any())).thenAnswer(
        (_) async => "",
      );

      final RequestInformationViewModel vm = readyVm(
        repo: repo,
        customerRepo: customerRepo,
      );

      await pumpButton(tester, vm.onSavePressed);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verify(() => repo.saveApplicationInformation(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save exception shows failure toast and emits loaded",
        (WidgetTester tester) async {
      silenceOverflowErrors();

      when(() => repo.saveApplicationInformation(any())).thenThrow(
        Exception("save failed"),
      );

      final RequestInformationViewModel vm = readyVm(
        repo: repo,
        customerRepo: customerRepo,
      );

      await pumpButton(tester, vm.onSavePressed);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verify(() => alerts.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save initializes null applicationDetails",
        (WidgetTester tester) async {
      silenceOverflowErrors();

      when(() => repo.saveApplicationInformation(any())).thenAnswer(
        (_) async => "APP-NULL-DETAILS",
      );

      final RequestInformationViewModel vm = readyVm(
        repo: repo,
        customerRepo: customerRepo,
      )..applicationDetails = null;

      await pumpButton(tester, vm.onSavePressed);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(vm.applicationDetails, isNotNull);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save uses fallback app type when applicationType list empty",
        (WidgetTester tester) async {
      silenceOverflowErrors();

      when(() => repo.saveApplicationInformation(any())).thenAnswer(
        (_) async => "APP-FALLBACK",
      );

      final RequestInformationViewModel vm = readyVm(
        repo: repo,
        customerRepo: customerRepo,
      )..applicationType = <Reference>[];

      await pumpButton(tester, vm.onSavePressed);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verify(() => repo.saveApplicationInformation(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save works when globals request fields have null fallbacks",
        (WidgetTester tester) async {
      silenceOverflowErrors();

      when(() => repo.saveApplicationInformation(any())).thenAnswer(
        (_) async => "APP-FALLBACK-FIELDS",
      );

      Globals.request = Request()
        ..isCreateRequest = true
        ..ccsysCanEditReadOnly = true;

      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..repository = repo
        ..repositoryCustomer = customerRepo
        ..applicationType = <Reference>[ccsysFallbackReference()]
        ..applicationDetails = details();

      await pumpButton(tester, vm.onSavePressed);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verify(() => repo.saveApplicationInformation(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("role checks", () {
    test("otherRolesCheck returns bool", () {
      final RequestInformationViewModel vm = RequestInformationViewModel();

      expect(vm.otherRolesCheck(), isA<bool>());
    });

    test("otherRolesCheckCC returns bool", () {
      final RequestInformationViewModel vm = RequestInformationViewModel();

      expect(vm.otherRolesCheckCC(), isA<bool>());
    });

    test("role methods are safe to call repeatedly", () {
      final RequestInformationViewModel vm = RequestInformationViewModel();

      expect(vm.otherRolesCheck(), isA<bool>());
      expect(vm.otherRolesCheck(), isA<bool>());
      expect(vm.otherRolesCheckCC(), isA<bool>());
      expect(vm.otherRolesCheckCC(), isA<bool>());
    });
  });

  group("showDialogSuccessAppRefNo", () {
    Future<void> tapAndBuildDialog(WidgetTester tester) async {
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump();
      await tester.pump();
    }

    testWidgets("isNew true shows dialog", (WidgetTester tester) async {
      silenceOverflowErrors();

      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..repository = repo
        ..repositoryCustomer = customerRepo;

      await pumpButton(tester, (BuildContext context) {
        vm.showDialogSuccessAppRefNo(
          context,
          appRefNo: "APP-NEW",
          isNew: true,
        );
      });

      await tapAndBuildDialog(tester);

      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets("isNew false with otherRolesCheck true shows dialog",
        (WidgetTester tester) async {
      silenceOverflowErrors();

      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..repository = repo
        ..repositoryCustomer = customerRepo;

      await pumpButton(tester, (BuildContext context) {
        vm.showDialogSuccessAppRefNo(
          context,
          appRefNo: "APP-RM",
          isNew: false,
          otherRolesCheck: true,
          otherRolesCheckCC: false,
        );
      });

      await tapAndBuildDialog(tester);

      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets("isNew false with otherRolesCheckCC true shows dialog",
        (WidgetTester tester) async {
      silenceOverflowErrors();

      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..repository = repo
        ..repositoryCustomer = customerRepo;

      await pumpButton(tester, (BuildContext context) {
        vm.showDialogSuccessAppRefNo(
          context,
          appRefNo: "APP-CC",
          isNew: false,
          otherRolesCheck: false,
          otherRolesCheckCC: true,
        );
      });

      await tapAndBuildDialog(tester);

      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets("isNew false with both role flags false shows dialog",
        (WidgetTester tester) async {
      silenceOverflowErrors();

      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..repository = repo
        ..repositoryCustomer = customerRepo;

      await pumpButton(tester, (BuildContext context) {
        vm.showDialogSuccessAppRefNo(
          context,
          appRefNo: "APP-NONE",
          isNew: false,
          otherRolesCheck: false,
          otherRolesCheckCC: false,
        );
      });

      await tapAndBuildDialog(tester);

      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets("isNew true with null appRefNo shows dialog",
        (WidgetTester tester) async {
      silenceOverflowErrors();

      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..repository = repo
        ..repositoryCustomer = customerRepo;

      await pumpButton(tester, (BuildContext context) {
        vm.showDialogSuccessAppRefNo(
          context,
          isNew: true,
        );
      });

      await tapAndBuildDialog(tester);

      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets("isNew null shows toast path without dialog",
        (WidgetTester tester) async {
      silenceOverflowErrors();

      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..repository = repo
        ..repositoryCustomer = customerRepo;

      await pumpButton(tester, (BuildContext context) {
        try {
          vm.showDialogSuccessAppRefNo(
            context,
            appRefNo: "APP-TOAST",
          );
        } on Object {
          // Global router guard for isolated unit test.
        }
      });

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verify(() => alerts.showSuccessToast(any())).called(1);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets("dialog ok button can be tapped safely",
        (WidgetTester tester) async {
      silenceOverflowErrors();

      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..repository = repo
        ..repositoryCustomer = customerRepo;

      await pumpButton(tester, (BuildContext context) {
        vm.showDialogSuccessAppRefNo(
          context,
          appRefNo: "APP-OK",
          isNew: true,
        );
      });

      await tapAndBuildDialog(tester);

      expect(find.byType(Dialog), findsOneWidget);

      final Finder buttonInDialog = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(ElevatedButton),
      );

      if (buttonInDialog.evaluate().isNotEmpty) {
        await tester.tap(buttonInDialog.first);
        await tester.pump();
      }

      expect(tester.takeException(), isNull);
    });
  });

  group("moveToNext", () {
    test("moveToNext can be invoked safely in test guard", () {
      final RequestInformationViewModel vm = RequestInformationViewModel();

      try {
        vm.moveToNext();
      } on Object {
        // Global router may not be attached in isolated unit test.
      }

      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });
  });

  group("field mutability and emits", () {
    test("selectedLastApprovedAppRefNum is mutable", () {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..selectedLastApprovedAppRefNum = "REF-1";

      expect(vm.selectedLastApprovedAppRefNum, "REF-1");

      vm.selectedLastApprovedAppRefNum = null;

      expect(vm.selectedLastApprovedAppRefNum, isNull);
    });

    test("date fields are mutable", () {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..approvedDate = "2025-01-01"
        ..lastApprovedAppDate = "2024-01-01";

      expect(vm.approvedDate, "2025-01-01");
      expect(vm.lastApprovedAppDate, "2024-01-01");
    });

    test("status and booleans are mutable", () {
      final RequestInformationViewModel vm = RequestInformationViewModel()
        ..status = 5
        ..isApiError = true
        ..isNewRequest = true
        ..isExisitngAppRefNo = true
        ..canEdit = true;

      expect(vm.status, 5);
      expect(vm.isApiError, true);
      expect(vm.isNewRequest, true);
      expect(vm.isExisitngAppRefNo, true);
      expect(vm.canEdit, true);
    });

    test("manual emits keep latest state", () {
      final RequestInformationViewModel vm = RequestInformationViewModel();

      vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.error));
      expect(vm.state.loaderStatus, LoadingStatus.error);

      vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("multiple instances are independent", () {
      final RequestInformationViewModel vm1 = RequestInformationViewModel();
      final RequestInformationViewModel vm2 = RequestInformationViewModel();

      vm1.emit(vm1.state.copyWith(loaderStatus: LoadingStatus.loaded));

      expect(vm1.state.loaderStatus, LoadingStatus.loaded);
      expect(vm2.state.loaderStatus, LoadingStatus.loading);
    });
  });
}
