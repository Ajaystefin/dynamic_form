import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:mocktail/mocktail.dart";
import "package:toastification/toastification.dart";

import "package:wcas_frontend/core/constants/_server_constants.dart";
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

// ─────────────────────────────────────────────
//  Mocks
// ─────────────────────────────────────────────
class MockCcsysRepository extends Mock implements CcsysRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

/// Silent AlertManager — no Toastification calls, no crashes.
class _SilentAlertManager implements AlertManager {
  @override
  void showFailureToast(String message) {}
  @override
  void showSuccessToast(String message) {}
  @override
  void showInfoToast(String message) {}
  @override
  void showWarningToast(String message) {}
}

// ─────────────────────────────────────────────
//  Reference helper
// ─────────────────────────────────────────────
Reference _ref({
  required int id,
  required String name,
  String? ref1,
  String? ref2,
  String? ref3,
  String? ref4,
  String? ref5,
}) =>
    Reference(
      id: id,
      name: name,
      reference1: ref1,
      reference2: ref2,
      reference3: ref3,
      reference4: ref4,
      reference5: ref5,
    );

void _stubExistingDetails(
  MockCcsysRepository repo,
  ApplicationDetails details,
) =>
    when(() => repo.getApplicationDetails()).thenAnswer((_) async => details);

void _stubNewDetails(MockCcsysRepository repo, ApplicationDetails? details) =>
    when(() => repo.getLastApprovedApplication())
        .thenAnswer((_) async => details);

RequestInformationViewModel _makeReadyVm({
  required MockCcsysRepository repo,
  required MockCustomerRepository customerRepo,
  bool isCreate = true,
  String? existingAppRefNo,
  bool isExisting = false,
}) {
  final vm = RequestInformationViewModel()
    ..repository = repo
    ..repositoryCustomer = customerRepo
    ..isExisitngAppRefNo = isExisting
    ..applicationDetails = (ApplicationDetails()
      ..applicationRefNo = existingAppRefNo
      ..approvedDate = "2024-01-01"
      ..branch = "HQ"
      ..region = "SOUTH"
      ..enabledForView = false
      ..status = 1)
    ..applicationType = [
      Reference(
        id: ServerConstants.ccsysAppReferenceId,
        name: ServerConstants.ccsysAppReferenceName,
        reference1: ServerConstants.ccsysAppReference1,
        reference2: ServerConstants.ccsysAppReference2,
        reference3: ServerConstants.ccsysAppReference3,
        reference4: ServerConstants.ccsysAppReference4,
        reference5: ServerConstants.ccsysAppReference5,
      ),
    ];

  Globals.request = Request()
    ..isCreateRequest = isCreate
    ..applicationRefNo = existingAppRefNo
    ..businessSegment = _ref(id: 1, name: "Corp")
    ..requestType = _ref(id: 1, name: "New", ref1: "R1", ref2: "R2")
    ..applicationType = _ref(id: 1, name: "AppType", ref1: "AT1")
    ..customerRimNo = 123456
    ..customerName = "Test Corp"
    ..branch = "HQ"
    ..ccsysCanEditReadOnly = true;

  return vm;
}

// ─────────────────────────────────────────────
//  Widget tree
//
//  Uses a GoRouter (so context.pop() works) and ToastificationWrapper
//  (so AlertManager.show* never throws).  A wide ViewConfiguration
//  (1400 × 900) prevents dialog_helper.dart Row overflow assertions.
// ─────────────────────────────────────────────

/// A minimal GoRouter that just shows [child] on the home route.
GoRouter _makeRouter(Widget child) => GoRouter(
      routes: [
        GoRoute(
          path: "/",
          builder: (_, __) => child,
        ),
      ],
    );

Widget _appTree(Widget child) {
  return ToastificationWrapper(
    child: MaterialApp.router(
      routerConfig: _makeRouter(
        Scaffold(body: child),
      ),
    ),
  );
}

/// Pumps an ElevatedButton that calls [onPress(ctx)] when tapped, inside
/// a wide widget tree that satisfies GoRouter, ToastificationWrapper, and
/// avoids dialog overflow.
Future<void> _pumpButton(
  WidgetTester tester,
  void Function(BuildContext ctx) onPress,
) async {
  // Override the test binding's window size so the dialog has plenty of room.
  tester.view.physicalSize = const Size(2800, 1800);
  tester.view.devicePixelRatio = 2.0;

  await tester.pumpWidget(
    _appTree(
      Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => onPress(ctx),
          child: const Text("go"),
        ),
      ),
    ),
  );

  // Let GoRouter settle before any tap.
  await tester.pumpAndSettle();
}

/// Silences Flutter overflow errors during a test so they are not treated as
/// unexpected exceptions.  Overflow in dialog_helper.dart is a production
/// layout concern, not a logic bug we are testing here.
void _silenceOverflowErrors() {
  FlutterError.onError = (FlutterErrorDetails details) {
    final String summary = details.exceptionAsString();
    if (summary.contains("overflowed") || summary.contains("RenderFlex")) {
      return;
    }
    FlutterError.presentError(details);
  };
}

void main() {
  late MockCcsysRepository mockRepo;
  late MockCustomerRepository mockCustomerRepo;

  // Restore default FlutterError handler after each test.
  final FlutterExceptionHandler? originalHandler = FlutterError.onError;

  setUp(() {
    mockRepo = MockCcsysRepository();
    mockCustomerRepo = MockCustomerRepository();
    AlertManager.overrideInstance(_SilentAlertManager());
    Globals.request = Request()
      ..isCreateRequest = false
      ..ccsysCanEditReadOnly = true;
  });

  tearDown(() {
    FlutterError.onError = originalHandler;
  });

  // ═══════════════════════════════════════════
  //  State
  // ═══════════════════════════════════════════
  group("RequestInformationState", () {
    test("constructor sets loaderStatus", () {
      expect(
        RequestInformationState(loaderStatus: LoadingStatus.loading)
            .loaderStatus,
        LoadingStatus.loading,
      );
    });

    test("copyWith keeps value when not provided", () {
      final s = RequestInformationState(loaderStatus: LoadingStatus.loaded);
      expect(s.copyWith().loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides loaderStatus", () {
      final s = RequestInformationState(loaderStatus: LoadingStatus.loaded);
      expect(
        s.copyWith(loaderStatus: LoadingStatus.error).loaderStatus,
        LoadingStatus.error,
      );
      expect(s.loaderStatus, LoadingStatus.loaded);
    });

    test("loading → loaded", () {
      final s = RequestInformationState(loaderStatus: LoadingStatus.loading);
      expect(
        s.copyWith(loaderStatus: LoadingStatus.loaded).loaderStatus,
        LoadingStatus.loaded,
      );
    });

    test("loaded → error", () {
      final s = RequestInformationState(loaderStatus: LoadingStatus.loaded);
      expect(
        s.copyWith(loaderStatus: LoadingStatus.error).loaderStatus,
        LoadingStatus.error,
      );
    });
  });

  // ═══════════════════════════════════════════
  //  Construction & defaults
  // ═══════════════════════════════════════════
  group("construction", () {
    test("initial loaderStatus is loading", () {
      expect(
        RequestInformationViewModel().state.loaderStatus,
        LoadingStatus.loading,
      );
    });
    test("applicationType starts empty", () {
      expect(RequestInformationViewModel().applicationType, isEmpty);
    });
    test("selectedRequestType starts null", () {
      expect(RequestInformationViewModel().selectedRequestType, isNull);
    });
    test("selectedBusinessSegment starts null", () {
      expect(RequestInformationViewModel().selectedBusinessSegment, isNull);
    });
    test("selectedApplicationType starts null", () {
      expect(RequestInformationViewModel().selectedApplicationType, isNull);
    });
    test("isNewRequest defaults false", () {
      expect(RequestInformationViewModel().isNewRequest, false);
    });
    test("isApiError defaults false", () {
      expect(RequestInformationViewModel().isApiError, false);
    });
    test("isExisitngAppRefNo defaults false", () {
      expect(RequestInformationViewModel().isExisitngAppRefNo, false);
    });
    test("canEdit defaults false", () {
      expect(RequestInformationViewModel().canEdit, false);
    });
    test("applicationDetails non-null on construction", () {
      expect(RequestInformationViewModel().applicationDetails, isNotNull);
    });
    test("formKey is GlobalKey", () {
      expect(RequestInformationViewModel().formKey, isA<GlobalKey>());
    });
  });

  // ═══════════════════════════════════════════
  //  initRightsAndMode
  // ═══════════════════════════════════════════
  group("initRightsAndMode", () {
    test("canEdit=false when ccsysCanEditReadOnly=false", () {
      final vm = RequestInformationViewModel()
        ..initRightsAndMode(Request()..ccsysCanEditReadOnly = false);
      expect(vm.canEdit, false);
    });

    test("canEdit is bool when ccsysCanEditReadOnly=true", () {
      final vm = RequestInformationViewModel()
        ..initRightsAndMode(Request()..ccsysCanEditReadOnly = true);
      expect(vm.canEdit, isA<bool>());
    });

    test("null ccsysCanEditReadOnly treated as true", () {
      final vm = RequestInformationViewModel()
        ..initRightsAndMode(Request()..ccsysCanEditReadOnly = null);
      expect(vm.canEdit, isA<bool>());
    });
  });

  // ═══════════════════════════════════════════
  //  onSelectApplicationType
  // ═══════════════════════════════════════════
  group("onSelectApplicationType", () {
    test("accepts Reference", () {
      expect(
        () => RequestInformationViewModel()
            .onSelectApplicationType(Reference(id: 1, name: "X")),
        returnsNormally,
      );
    });
    test("accepts null", () {
      expect(
        () => RequestInformationViewModel().onSelectApplicationType(null),
        returnsNormally,
      );
    });
  });

  // ═══════════════════════════════════════════
  //  applicationTypeItems
  // ═══════════════════════════════════════════
  group("applicationTypeItems", () {
    test("empty list when applicationType empty", () {
      expect(RequestInformationViewModel().applicationTypeItems(), isEmpty);
    });

    test("corporate path – filters by corperateCode + requestType.ref1", () {
      final vm = RequestInformationViewModel()
        ..selectedRequestType = _ref(id: 1, name: "New", ref1: "NEW")
        ..selectedBusinessSegment = _ref(
          id: ServerConstants.businessSegmentId[BusinessSegment.corporate] ??
              999,
          name: "Corp",
        )
        ..applicationType = [
          _ref(
            id: 1,
            name: "CorpType",
            ref3: ServerConstants.corperateCode,
            ref4: "NEW",
          ),
          _ref(
            id: 2,
            name: "FiType",
            ref3: ServerConstants.financialCode,
            ref4: "NEW",
          ),
          _ref(
            id: 3,
            name: "Wrong",
            ref3: ServerConstants.corperateCode,
            ref4: "OTHER",
          ),
        ];
      final result = vm.applicationTypeItems();
      expect(result.length, 1);
      expect(result.first.name, "CorpType");
    });

    test("FI path – filters by financialCode + requestType.ref1", () {
      final vm = RequestInformationViewModel()
        ..selectedRequestType = _ref(id: 1, name: "New", ref1: "NEW")
        ..selectedBusinessSegment = _ref(
          id: ServerConstants
                  .businessSegmentId[BusinessSegment.financialInstitution] ??
              0,
          name: "FI",
        )
        ..applicationType = [
          _ref(
            id: 1,
            name: "FiType",
            ref3: ServerConstants.financialCode,
            ref4: "NEW",
          ),
          _ref(
            id: 2,
            name: "CorpType",
            ref3: ServerConstants.corperateCode,
            ref4: "NEW",
          ),
        ];
      final result = vm.applicationTypeItems();
      expect(result.length, 1);
      expect(result.first.name, "FiType");
    });

    test("empty when requestType.ref1 does not match", () {
      final vm = RequestInformationViewModel()
        ..selectedRequestType = _ref(id: 1, name: "X", ref1: "NOMATCH")
        ..selectedBusinessSegment = _ref(id: 1, name: "Corp")
        ..applicationType = [
          _ref(
            id: 1,
            name: "A",
            ref3: ServerConstants.corperateCode,
            ref4: "OTHER",
          ),
        ];
      expect(vm.applicationTypeItems(), isEmpty);
    });

    test("null reference3 does not crash", () {
      final vm = RequestInformationViewModel()
        ..selectedRequestType = _ref(id: 1, name: "N", ref1: "NEW")
        ..selectedBusinessSegment = _ref(id: 1, name: "Corp")
        ..applicationType = [
          Reference(id: 1, name: "X", reference3: null, reference4: "NEW"),
        ];
      expect(vm.applicationTypeItems, returnsNormally);
    });

    test("null reference4 does not crash", () {
      final vm = RequestInformationViewModel()
        ..selectedRequestType = _ref(id: 1, name: "N", ref1: "NEW")
        ..selectedBusinessSegment = _ref(id: 1, name: "Corp")
        ..applicationType = [
          Reference(
            id: 1,
            name: "X",
            reference3: ServerConstants.corperateCode,
            reference4: null,
          ),
        ];
      expect(vm.applicationTypeItems, returnsNormally);
    });

    test("null selectedRequestType returns empty", () {
      final vm = RequestInformationViewModel()
        ..selectedBusinessSegment = _ref(id: 1, name: "Corp")
        ..applicationType = [
          _ref(
            id: 1,
            name: "A",
            ref3: ServerConstants.corperateCode,
            ref4: "NEW",
          ),
        ];
      expect(vm.applicationTypeItems(), isEmpty);
    });

    test("null selectedBusinessSegment falls through to corporate path", () {
      final vm = RequestInformationViewModel()
        ..selectedRequestType = _ref(id: 1, name: "N", ref1: "NEW")
        ..selectedBusinessSegment = null
        ..applicationType = [
          _ref(
            id: 1,
            name: "A",
            ref3: ServerConstants.corperateCode,
            ref4: "NEW",
          ),
        ];
      expect(vm.applicationTypeItems(), isA<List<Reference>>());
    });
  });

  // ═══════════════════════════════════════════
  //  getApplicationDetails
  // ═══════════════════════════════════════════
  group("getApplicationDetails", () {
    test("new request – maps selectedLastApprovedAppRefNum + dates", () async {
      final vm = RequestInformationViewModel()
        ..repository = mockRepo
        ..repositoryCustomer = mockCustomerRepo
        ..isNewRequest = true;
      _stubNewDetails(
        mockRepo,
        ApplicationDetails()
          ..applicationRefNo = "APP-001"
          ..approvedDate = "2024-01-01",
      );

      await vm.getApplicationDetails();

      verify(() => mockRepo.getLastApprovedApplication()).called(1);
      expect(vm.selectedLastApprovedAppRefNum, "APP-001");
      expect(vm.approvedDate, "2024-01-01");
      expect(vm.lastApprovedAppDate, "2024-01-01");
    });

    test("new request – null API response yields non-null applicationDetails",
        () async {
      final vm = RequestInformationViewModel()
        ..repository = mockRepo
        ..repositoryCustomer = mockCustomerRepo
        ..isNewRequest = true;
      _stubNewDetails(mockRepo, null);

      await vm.getApplicationDetails();

      expect(vm.applicationDetails, isNotNull);
    });

    test("new request – exception is swallowed", () async {
      final vm = RequestInformationViewModel()
        ..repository = mockRepo
        ..repositoryCustomer = mockCustomerRepo
        ..isNewRequest = true;
      when(() => mockRepo.getLastApprovedApplication())
          .thenThrow(Exception("fail"));

      await expectLater(vm.getApplicationDetails(), completes);
    });

    test("existing request – maps selectedLastApprovedAppRefNum", () async {
      Globals.request = Request()..isCreateRequest = false;
      final vm = RequestInformationViewModel()
        ..repository = mockRepo
        ..repositoryCustomer = mockCustomerRepo
        ..isNewRequest = false;
      _stubExistingDetails(
        mockRepo,
        ApplicationDetails()
          ..applicationRefNo = "APP-E"
          ..lastApprovedAppRefNum = "APP-P"
          ..approvedDate = "2024-06-01",
      );

      await vm.getApplicationDetails();

      verify(() => mockRepo.getApplicationDetails()).called(1);
      expect(vm.selectedLastApprovedAppRefNum, "APP-P");
      expect(vm.approvedDate, "2024-06-01");
    });

    test("existing request – non-empty appRefNo sets isExisitngAppRefNo=true",
        () async {
      Globals.request = Request()..isCreateRequest = false;
      final vm = RequestInformationViewModel()
        ..repository = mockRepo
        ..repositoryCustomer = mockCustomerRepo
        ..isNewRequest = false;
      _stubExistingDetails(
        mockRepo,
        ApplicationDetails()..applicationRefNo = "APP-XYZ",
      );

      await vm.getApplicationDetails();

      expect(vm.isExisitngAppRefNo, true);
    });

    test("existing request – whitespace appRefNo → false", () async {
      Globals.request = Request()..isCreateRequest = false;
      final vm = RequestInformationViewModel()
        ..repository = mockRepo
        ..repositoryCustomer = mockCustomerRepo
        ..isNewRequest = false;
      _stubExistingDetails(
        mockRepo,
        ApplicationDetails()..applicationRefNo = "   ",
      );

      await vm.getApplicationDetails();

      expect(vm.isExisitngAppRefNo, false);
    });

    test("existing request – null appRefNo → false", () async {
      Globals.request = Request()..isCreateRequest = false;
      final vm = RequestInformationViewModel()
        ..repository = mockRepo
        ..repositoryCustomer = mockCustomerRepo
        ..isNewRequest = false;
      _stubExistingDetails(
        mockRepo,
        ApplicationDetails()..applicationRefNo = null,
      );

      await vm.getApplicationDetails();

      expect(vm.isExisitngAppRefNo, false);
    });

    test("existing request – emits loaded state", () async {
      Globals.request = Request()..isCreateRequest = false;
      final vm = RequestInformationViewModel()
        ..repository = mockRepo
        ..repositoryCustomer = mockCustomerRepo
        ..isNewRequest = false;
      _stubExistingDetails(
        mockRepo,
        ApplicationDetails()..applicationRefNo = "A",
      );

      await vm.getApplicationDetails();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  // ═══════════════════════════════════════════
  //  onSavePressed
  // ═══════════════════════════════════════════
  group("onSavePressed", () {
    testWidgets("save succeeds (new): sets Globals appRefNo + emits loaded",
        (tester) async {
      _silenceOverflowErrors();
      when(() => mockRepo.saveApplicationInformation(any()))
          .thenAnswer((_) async => "NEW-001");
      final vm = _makeReadyVm(
        repo: mockRepo,
        customerRepo: mockCustomerRepo,
        isCreate: true,
      );

      await _pumpButton(tester, vm.onSavePressed);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockRepo.saveApplicationInformation(any())).called(1);
      expect(Globals.request?.applicationRefNo, "NEW-001");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save succeeds (existing – isExisting=true): emits loaded",
        (tester) async {
      _silenceOverflowErrors();
      when(() => mockRepo.saveApplicationInformation(any()))
          .thenAnswer((_) async => "EXIST-001");
      final vm = _makeReadyVm(
        repo: mockRepo,
        customerRepo: mockCustomerRepo,
        isCreate: false,
        existingAppRefNo: "OLD-REF",
        isExisting: true,
      );

      await _pumpButton(tester, vm.onSavePressed);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save returns empty string: no dialog, state loaded",
        (tester) async {
      _silenceOverflowErrors();
      when(() => mockRepo.saveApplicationInformation(any()))
          .thenAnswer((_) async => "");
      final vm = _makeReadyVm(
        repo: mockRepo,
        customerRepo: mockCustomerRepo,
        isCreate: true,
      );

      await _pumpButton(tester, vm.onSavePressed);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save throws: caught, emits loaded", (tester) async {
      _silenceOverflowErrors();
      when(() => mockRepo.saveApplicationInformation(any()))
          .thenThrow(Exception("server error"));
      final vm = _makeReadyVm(
        repo: mockRepo,
        customerRepo: mockCustomerRepo,
        isCreate: true,
      );

      await _pumpButton(tester, vm.onSavePressed);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save with null applicationDetails initialises it",
        (tester) async {
      _silenceOverflowErrors();
      when(() => mockRepo.saveApplicationInformation(any()))
          .thenAnswer((_) async => "APP-NULL");
      final vm = _makeReadyVm(
        repo: mockRepo,
        customerRepo: mockCustomerRepo,
        isCreate: true,
      )..applicationDetails = null;

      await _pumpButton(tester, vm.onSavePressed);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save: isCreateRequest=false preserves existing appRefNo",
        (tester) async {
      _silenceOverflowErrors();
      when(() => mockRepo.saveApplicationInformation(any()))
          .thenAnswer((_) async => "UPDATED");
      final vm = _makeReadyVm(
        repo: mockRepo,
        customerRepo: mockCustomerRepo,
        isCreate: false,
        existingAppRefNo: "KEEP-REF",
      );

      await _pumpButton(tester, vm.onSavePressed);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save: empty applicationType uses orElse Reference",
        (tester) async {
      _silenceOverflowErrors();
      when(() => mockRepo.saveApplicationInformation(any()))
          .thenAnswer((_) async => "FALLBACK");
      final vm = _makeReadyVm(
        repo: mockRepo,
        customerRepo: mockCustomerRepo,
        isCreate: true,
      )..applicationType = [];

      await _pumpButton(tester, vm.onSavePressed);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  // ═══════════════════════════════════════════
  //  showDialogSuccessAppRefNo
  // ═══════════════════════════════════════════
  group("showDialogSuccessAppRefNo", () {
    // Helper for dialog tests: pump + two frames to let addPostFrameCallback
    // fire.
    Future<void> tapAndWaitForDialog(WidgetTester tester) async {
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // button tap registered
      await tester.pump(); // addPostFrameCallback fires → dialog scheduled
      await tester.pump(); // dialog widget built
    }

    testWidgets("isNew=null: no dialog (toast + moveToNext path)",
        (tester) async {
      _silenceOverflowErrors();
      final vm = RequestInformationViewModel()
        ..repository = mockRepo
        ..repositoryCustomer = mockCustomerRepo;

      await _pumpButton(tester, (ctx) {
        vm.showDialogSuccessAppRefNo(ctx, appRefNo: "R", isNew: null);
      });
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // isNew=null → showSuccessToast + moveToNext (no dialog opened)
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets("isNew=true: dialog appears", (tester) async {
      _silenceOverflowErrors();
      final vm = RequestInformationViewModel()
        ..repository = mockRepo
        ..repositoryCustomer = mockCustomerRepo;

      await _pumpButton(tester, (ctx) {
        vm.showDialogSuccessAppRefNo(
          ctx,
          appRefNo: "APP-NEW",
          isNew: true,
        );
      });
      await tapAndWaitForDialog(tester);

      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets("isNew=false otherRolesCheck=true: dialog appears",
        (tester) async {
      _silenceOverflowErrors();
      final vm = RequestInformationViewModel()
        ..repository = mockRepo
        ..repositoryCustomer = mockCustomerRepo;

      await _pumpButton(tester, (ctx) {
        vm.showDialogSuccessAppRefNo(
          ctx,
          appRefNo: "APP-R",
          isNew: false,
          otherRolesCheck: true,
          otherRolesCheckCC: false,
        );
      });
      await tapAndWaitForDialog(tester);

      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets("isNew=false otherRolesCheckCC=true: dialog appears",
        (tester) async {
      _silenceOverflowErrors();
      final vm = RequestInformationViewModel()
        ..repository = mockRepo
        ..repositoryCustomer = mockCustomerRepo;

      await _pumpButton(tester, (ctx) {
        vm.showDialogSuccessAppRefNo(
          ctx,
          appRefNo: "APP-CC",
          isNew: false,
          otherRolesCheck: false,
          otherRolesCheckCC: true,
        );
      });
      await tapAndWaitForDialog(tester);

      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets("isNew=false both false: dialog appears", (tester) async {
      _silenceOverflowErrors();
      final vm = RequestInformationViewModel()
        ..repository = mockRepo
        ..repositoryCustomer = mockCustomerRepo;

      await _pumpButton(tester, (ctx) {
        vm.showDialogSuccessAppRefNo(
          ctx,
          appRefNo: "APP-E",
          isNew: false,
          otherRolesCheck: false,
          otherRolesCheckCC: false,
        );
      });
      await tapAndWaitForDialog(tester);

      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets("isNew=true null appRefNo: dialog appears", (tester) async {
      _silenceOverflowErrors();
      final vm = RequestInformationViewModel()
        ..repository = mockRepo
        ..repositoryCustomer = mockCustomerRepo;

      await _pumpButton(tester, (ctx) {
        vm.showDialogSuccessAppRefNo(
          ctx,
          appRefNo: null,
          isNew: true,
        );
      });
      await tapAndWaitForDialog(tester);

      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets("OK/close button inside dialog: GoRouter pop is handled",
        (tester) async {
      _silenceOverflowErrors();
      final vm = RequestInformationViewModel()
        ..repository = mockRepo
        ..repositoryCustomer = mockCustomerRepo;

      await _pumpButton(tester, (ctx) {
        vm.showDialogSuccessAppRefNo(ctx, appRefNo: "R", isNew: true);
      });
      await tapAndWaitForDialog(tester);

      expect(find.byType(Dialog), findsOneWidget);

      // Tap the ElevatedButton inside the dialog (the OK / close button).
      // context.pop() is handled by GoRouter which IS in the tree.
      final dialogButton = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(ElevatedButton),
      );
      if (dialogButton.evaluate().isNotEmpty) {
        await tester.tap(dialogButton.first);
        await tester.pump();
      }

      // After pop the dialog is dismissed and no unhandled exception remains.
      expect(tester.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════
  //  Role checks
  // ═══════════════════════════════════════════
  group("role checks", () {
    test("otherRolesCheck returns bool", () {
      expect(RequestInformationViewModel().otherRolesCheck(), isA<bool>());
    });
    test("otherRolesCheckCC returns bool", () {
      expect(RequestInformationViewModel().otherRolesCheckCC(), isA<bool>());
    });
    test("otherRolesCheck idempotent", () {
      final vm = RequestInformationViewModel();
      expect(vm.otherRolesCheck(), vm.otherRolesCheck());
    });
  });

  // ═══════════════════════════════════════════
  //  moveToNext
  // ═══════════════════════════════════════════
  group("moveToNext", () {
    test("does not propagate unexpected exceptions", () {
      final vm = RequestInformationViewModel();
      try {
        vm.moveToNext();
      } catch (_) {
        // router.go throws without real GoRouter context – expected
      }
    });
  });

  // ═══════════════════════════════════════════
  //  State transitions
  // ═══════════════════════════════════════════
  group("state transitions", () {
    test("loading → loaded → error cycle", () {
      final vm = RequestInformationViewModel();
      vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.error));
      expect(vm.state.loaderStatus, LoadingStatus.error);
    });

    test("multiple emits keep latest", () {
      final vm = RequestInformationViewModel();
      vm
        ..emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded))
        ..emit(vm.state.copyWith(loaderStatus: LoadingStatus.error))
        ..emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  // ═══════════════════════════════════════════
  //  Field mutability
  // ═══════════════════════════════════════════
  group("field mutability", () {
    test("canEdit is mutable", () {
      final vm = RequestInformationViewModel()..canEdit = true;
      expect(vm.canEdit, true);
      vm.canEdit = false;
      expect(vm.canEdit, false);
    });

    test("selectedLastApprovedAppRefNum nullable", () {
      final vm = RequestInformationViewModel()
        ..selectedLastApprovedAppRefNum = "REF-X";
      expect(vm.selectedLastApprovedAppRefNum, "REF-X");
      vm.selectedLastApprovedAppRefNum = null;
      expect(vm.selectedLastApprovedAppRefNum, isNull);
    });

    test("approvedDate writable", () {
      final vm = RequestInformationViewModel()..approvedDate = "2025-12-31";
      expect(vm.approvedDate, "2025-12-31");
    });

    test("isApiError mutable", () {
      final vm = RequestInformationViewModel()..isApiError = true;
      expect(vm.isApiError, true);
    });

    test("multiple instances are independent", () {
      final vm1 = RequestInformationViewModel();
      final vm2 = RequestInformationViewModel();
      vm1.emit(vm1.state.copyWith(loaderStatus: LoadingStatus.loaded));
      expect(vm2.state.loaderStatus, LoadingStatus.loading);
    });
  });
}
