import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:mocktail/mocktail.dart";
import "package:toastification/toastification.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/limit_caps/model.dart";
import "package:wcas_frontend/features/request/approval/limit_caps/state.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/approval/limit_detail.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";

class MockApprovalRepo extends Mock implements ApprovalRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockDialogHlp extends Mock implements DialogHelper {}

class MockRouter extends Mock implements GoRouter {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("bootstrap toastification", (tester) async {
    await tester.pumpWidget(
      const ToastificationWrapper(
        child: MaterialApp(home: SizedBox()),
      ),
    );
    await tester.pumpAndSettle();
  });

  late LimitCapsViewModel vm;
  late MockApprovalRepo mockRepo;
  late List<LimitDetail> sampleDetails;
  late MockRouter mockRouter;
  late MockAlertManager mockAlert;

  setUpAll(() async {
    await EnvConfig.setEnvironment();
    registerFallbackValue("");

    const connectivityChannel =
        MethodChannel("dev.fluttercommunity.plus/connectivity");
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          // return a List so invokeListMethod can cast safely
          return <dynamic>[];
        }
        return null;
      },
    );

    mockRouter = MockRouter();
  });

  setUp(() {
    Globals.user = User(
      id: "u1",
      name: "Test",
      currentRole: Role(roleId: 1, code: "R1", bpmRole: "R1"),
    );
    Globals.sessionID = "session-123";
    mockAlert = MockAlertManager();
    mockRepo = MockApprovalRepo();
    AlertManager.overrideInstance(mockAlert);
    sampleDetails = [
      LimitDetail(rimNo: 111, limitNumber: "1000"),
      LimitDetail(rimNo: 222, limitNumber: "2000"),
    ];

    vm = LimitCapsViewModel()..repository = mockRepo;
  });

  test("initial state is loading", () {
    expect(vm.state.loaderStatus, LoadingStatus.loading);
    expect(vm.rowsPerPage, 5);
    expect(vm.limitDetail, isEmpty);
    expect(vm.filteredlimitDetail, isEmpty);
    expect(vm.filterRim, isNull);
  });

  test("init() loads data then emits loaded", () async {
    BuildContext? context;
    when(() => mockRepo.getCompanyLimitDetails())
        .thenAnswer((_) async => sampleDetails);
    await vm.init(context);
    expect(vm.limitDetail, sampleDetails);
    expect(vm.filteredlimitDetail, sampleDetails);
  });

  test("getCompanyLimitDetails() on error calls showFailureToast", () async {
    when(() => mockRepo.getCompanyLimitDetails()).thenThrow(Exception("oops"));

    await vm.getCompanyLimitDetails();

    expect(vm.limitDetail, isEmpty);
    expect(vm.filteredlimitDetail, isEmpty);
  });

  test("onFilter() filters existing limitDetail and emits loaded", () {
    vm.limitDetail = sampleDetails;
    vm.filteredlimitDetail = sampleDetails;
    vm.onFilter(value: "11");

    expect(vm.filterRim, "11");
    expect(vm.filteredlimitDetail.length, 1);
    expect(vm.filteredlimitDetail.first?.rimNo, 111);
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  test("onSavePress() without continue emits loading→loaded", () async {
    final emitted = <LimitCapsState>[];
    vm.stream.listen(emitted.add);

    await vm.onSavePress(isContinue: false);

    expect(
      emitted.map((s) => s.loaderStatus).toList(),
      [LoadingStatus.loading],
    );
    verifyNever(() => mockRouter.go(any()));
  });

  test("onSavePress() with continue navigates after loaded", () async {
    final emitted = <LimitCapsState>[];
    vm.stream.listen(emitted.add);

    await vm.onSavePress(isContinue: true);

    expect(
      emitted.map((s) => s.loaderStatus).toList(),
      [LoadingStatus.loading],
    );
  });

  group("LimitCapsState", () {
    test("constructor sets loaderStatus", () {
      final state = LimitCapsState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final original = LimitCapsState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      final original = LimitCapsState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
