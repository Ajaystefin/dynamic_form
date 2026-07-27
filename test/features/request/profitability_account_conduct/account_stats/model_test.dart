import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_stats/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_stats/state.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/profitability/account_stat.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

import "../../../../test_config.dart";

class MockProfitabilityRepository extends Mock
    implements ProfitabilityRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeComment extends Fake implements Comment {}

// ✅ FIX: Mock BuildContext to avoid null crash
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late AccountStatsViewModel viewModel;
  late MockProfitabilityRepository mockRepo;
  late MockCommonRepository mockCommon;
  late MockAlertManager mockAlert;

  final mockContext = MockBuildContext();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // ✅ Required for mocktail
    registerFallbackValue(FakeComment());
    registerFallbackValue(CommentsType.accountStats);
    registerFallbackValue(EntityIdentifier.accountStats);
  });

  setUp(() async {
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async => ["wifi"],
    );

    mockRepo = MockProfitabilityRepository();
    mockCommon = MockCommonRepository();
    mockAlert = MockAlertManager();

    viewModel = AccountStatsViewModel()..repository = mockRepo;

    CommonRepository.overrideInstance = mockCommon;
    AlertManager.overrideInstance = mockAlert;

    Globals.request = Request(applicationRefNo: "APP123");

    // ✅ set role to force edit mode branch
    Globals.user = User(
      id: "USER123",
      currentRole: Role(roleId: 123),
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
  });

  // ================= INIT =================

  test("init full success (covers draft + flows)", () async {
    when(() => mockRepo.getAccountStats()).thenAnswer((_) async => {});

    when(() => mockCommon.getApplicationStrategyDetails(any(), any()))
        .thenAnswer((_) async => []);

    await viewModel.init(mockContext);

    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("init handles error", () async {
    when(() => mockRepo.getAccountStats()).thenThrow(Exception());
    when(() => mockCommon.getApplicationStrategyDetails(any(), any()))
        .thenAnswer((_) async => []);

    await viewModel.init(mockContext);

    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  // ================= ACCOUNT =================

  test("getAccountStats success", () async {
    final data = {
      Customer(id: "C1"): [AccountStat(product: "A1")],
    };

    when(() => mockRepo.getAccountStats()).thenAnswer((_) async => data);

    await viewModel.getAccountStats();

    expect(viewModel.customerWiseAccountStat, data);
  });

  test("getAccountStats error", () async {
    when(() => mockRepo.getAccountStats()).thenThrow(Exception());

    await viewModel.getAccountStats();

    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  // ================= COMMENTS FETCH =================

  test("getApplicationStrategyDetails success", () async {
    final list = [
      Comment(
        categoryId: ServerConstants.accountStatsCommentCategoryId,
        strategyComment: "OK",
      ),
    ];

    when(() => mockCommon.getApplicationStrategyDetails(any(), any()))
        .thenAnswer((_) async => list);

    await viewModel.getApplicationStrategyDetails();

    expect(viewModel.comment, "OK");
  });

  test("getApplicationStrategyDetails empty", () async {
    when(() => mockCommon.getApplicationStrategyDetails(any(), any()))
        .thenAnswer((_) async => []);

    await viewModel.getApplicationStrategyDetails();

    expect(viewModel.comment, "");
  });

  test("getApplicationStrategyDetails error", () async {
    when(() => mockCommon.getApplicationStrategyDetails(any(), any()))
        .thenThrow(Exception());

    await viewModel.getApplicationStrategyDetails();

    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  // ================= SAVE =================

  test("saveComments success save", () async {
    viewModel.comment = "Hi";

    when(() => mockCommon.saveApplicationStrategyDetails(any(), any(), any()))
        .thenAnswer((_) async => "Saved");

    when(() => mockAlert.showSuccessToast(any())).thenReturn(null);

    await viewModel.saveComments();

    expect(viewModel.state.saveButtonLoading, LoadingStatus.loaded);
  });

  test("saveComments success continue", () async {
    viewModel.comment = "Hi";

    when(() => mockCommon.saveApplicationStrategyDetails(any(), any(), any()))
        .thenAnswer((_) async => "Saved");

    await viewModel.saveComments(isContinue: true);

    expect(viewModel.state.continueButtonLoading, LoadingStatus.loaded);
  });

  test("saveComments error", () async {
    viewModel.comment = "Hi";

    when(() => mockCommon.saveApplicationStrategyDetails(any(), any(), any()))
        .thenThrow(Exception());

    when(() => mockAlert.showFailureToast(any())).thenReturn(null);

    await viewModel.saveComments();

    verify(() => mockAlert.showFailureToast(any())).called(1);
  });

  // ================= LABELS (✅ FIXED) =================

  test("getPreviousYearLabel", () {
    final result = viewModel.getPreviousYearLabel(mockContext);
    expect(result, isNotNull);
  });

  test("getCurrentYearLabel", () {
    final result = viewModel.getCurrentYearLabel(mockContext);
    expect(result, isNotNull);
  });

  // ================= STATE =================

  test("state copyWith", () {
    final s = AccountStatsState(loaderStatus: LoadingStatus.loaded);
    final n = s.copyWith(loaderStatus: LoadingStatus.error);

    expect(n.loaderStatus, LoadingStatus.error);
  });
}
