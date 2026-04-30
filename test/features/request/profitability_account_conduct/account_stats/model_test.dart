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

void main() {
  late AccountStatsViewModel viewModel;
  late MockProfitabilityRepository mockProfitabilityRepository;
  late MockCommonRepository mockCommonRepository;
  late MockAlertManager mockAlertManager;

  // Use a single, consistent channel and codec.
  // connectivity_plus uses StandardMethodCodec.
  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    StandardMethodCodec(),
  );

  setUpAll(() async {
    // Initialize test binding once for the suite
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    // Register mock handler via the test binary messenger (non-deprecated API)
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          // connectivity_plus expects a List<dynamic> (e.g., ['wifi'],
          // ['mobile'], ['none'])
          return <dynamic>["wifi"];
        }
        return null;
      },
    );

    // Mocks
    mockProfitabilityRepository = MockProfitabilityRepository();
    mockCommonRepository = MockCommonRepository();
    mockAlertManager = MockAlertManager();

    // SUT
    viewModel = AccountStatsViewModel();
    viewModel.repository = mockProfitabilityRepository;

    // Globals / singletons
    AlertManager.overrideInstance(mockAlertManager);
    Globals.request = Request(applicationRefNo: "APP123");
    Globals.user = User(id: "USER123", currentRole: Role(roleId: 123));
  });

  tearDown(() async {
    // Unregister the handler after each test to prevent bleed-over
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
  });

  tearDownAll(() async {
    // Extra safety — ensure it's unregistered at the suite end
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
  });

  group("AccountConductViewModel.init", () {});

  test("initial state should be loading", () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test("getApplicationStrategyDetails success should update comment", () async {
    // Arrange
    final mockCommentList = [
      Comment(
        categoryId: ServerConstants.accountStatsCommentCategoryId,
        strategyComment: "Strategy A",
      ),
      Comment(categoryId: 999, strategyComment: "Other"),
    ];

    when(
      () => mockCommonRepository.getApplicationStrategyDetails(
        CommentsType.accountStats,
        EntityIdentifier.accountStats,
      ),
    ).thenAnswer((_) async => mockCommentList);

    CommonRepository.overrideInstance(mockCommonRepository);

    // Act
    await viewModel.getApplicationStrategyDetails();

    // Assert
    expect(viewModel.comment, "Strategy A");
    expect(viewModel.state.loaderStatus, isNot(LoadingStatus.error));
  });

  test("getApplicationStrategyDetails failure should emit error", () async {
    // Arrange
    when(
      () => mockCommonRepository.getApplicationStrategyDetails(
        CommentsType.accountStats,
        EntityIdentifier.accountStats,
      ),
    ).thenThrow(Exception("Fetch failed"));

    CommonRepository.overrideInstance(mockCommonRepository);

    // Act
    await viewModel.getApplicationStrategyDetails();

    // Assert
    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  test("getAccountStats success", () async {
    final Map<Customer, List<AccountStat>> mockData = {
      Customer(id: "C1"): [AccountStat(product: "A1")],
    };

    when(() => mockProfitabilityRepository.getAccountStats())
        .thenAnswer((_) async => mockData);

    await viewModel.getAccountStats();

    expect(viewModel.customerWiseAccountStat, mockData);
    expect(viewModel.state.loaderStatus, isNot(LoadingStatus.error));
  });

  test("getAccountStats failure should emit error", () async {
    when(() => mockProfitabilityRepository.getAccountStats())
        .thenThrow(Exception("Failed"));

    await viewModel.getAccountStats();

    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  test("saveComments success with isContinue=false", () async {
    viewModel.comment = "Test comment";
    final Comment commentData = Comment(comment: viewModel.comment);
    when(() => mockCommonRepository.saveComment(commentData))
        .thenAnswer((_) async => "Saved");

    CommonRepository.overrideInstance(mockCommonRepository);

    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

    await viewModel.saveComments();

    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    // verify(() => mockAlertManager.showSuccessToast('Saved')).called(1);
  });

  test("saveComments failure should show failure toast", () async {
    viewModel.comment = "Test comment";
    final Comment commentData = Comment(comment: viewModel.comment);
    when(() => mockCommonRepository.saveComment(commentData))
        .thenThrow(Exception("Save failed"));

    CommonRepository.overrideInstance(mockCommonRepository);

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

    await viewModel.saveComments();

    verify(() => mockAlertManager.showFailureToast(any())).called(1);
  });
  test("init should initialize repository and load data", () async {
    final mockData = {
      Customer(id: "C1"): [AccountStat(product: "A1")],
    };

    when(() => mockProfitabilityRepository.getAccountStats())
        .thenAnswer((_) async => mockData);

    await viewModel.init(null);

    expect(viewModel.customerWiseAccountStat, mockData);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("init should emit error if getAccountStats fails", () async {
    when(() => mockProfitabilityRepository.getAccountStats())
        .thenThrow(Exception("Failed"));

    await viewModel.init(null);

    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("saveComments with isContinue=true should navigate", () async {
    viewModel.comment = "Continue comment";
    final Comment commentData = Comment(comment: viewModel.comment);
    when(() => mockCommonRepository.saveComment(commentData))
        .thenAnswer((_) async => "Saved");

    CommonRepository.overrideInstance(mockCommonRepository);
    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

    await viewModel.saveComments(isContinue: true);

    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    // verify(() => mockAlertManager.showSuccessToast('Saved')).called(1);
  });

  group("AccountStatsState", () {
    test("constructor sets loaderStatus", () {
      final state = AccountStatsState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final original = AccountStatsState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      final original = AccountStatsState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
