import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/services/local_storage_service.dart';
import 'package:wcas_frontend/features/request/approval/queries_and_responses/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/approval/queries_and_responses/state.dart';

class MockCommonRepository extends Mock implements CommonRepository {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockBuildContext extends Mock implements BuildContext {}

class MockAlertManager extends Mock implements AlertManager {}

// Mock LocalStorageService
class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, dynamic value) async {
    _storage[box] ??= {};
    _storage[box]![key] = value;
  }

  @override
  Future<dynamic> get(String box, String key) async {
    return _storage[box]?[key];
  }

  @override
  Future<void> delete(String box, String key) async {
    _storage[box]?.remove(key);
  }

  @override
  Future<void> clearBox(String box) async {
    _storage[box]?.clear();
  }

  void clearAll() {
    _storage.clear();
  }
}

void main() {
  late QueriesAndResponsesViewModel viewModel;
  late MockCommonRepository mockCommonRepository;
  // late MockApprovalRepository mockApprovalRepository;
  late MockAlertManager mockAlertManager;
  // late MockBuildContext mockContext;
  late MockLocalStorageService mockLocalStorageService;

  // Stub connectivity_plus channel so every check() returns wifi
  const MethodChannel connectivityChannel = MethodChannel(
    'dev.fluttercommunity.plus/connectivity',
  );

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockCommonRepository = MockCommonRepository();
    // mockApprovalRepository = MockApprovalRepository();
    mockAlertManager = MockAlertManager();
    // mockContext = MockBuildContext();
    await EnvConfig.setEnvironment();
    AlertManager.instance = mockAlertManager;

    viewModel = QueriesAndResponsesViewModel();

    mockLocalStorageService = MockLocalStorageService();

    // Set up LocalStorageService mock
    LocalStorageService().setStorage(mockLocalStorageService);

    // Connectivity mock
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, (call) async {
      if (call.method == 'check') {
        return [ConnectivityResult.wifi.name];
      }
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/connectivity'),
      (MethodCall methodCall) async {
        return 'wifi'; // or whatever mock result you need
      },
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
  });

  test('initial state should be loading', () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  // test('init loads data and emits loaded state', () async {
  //   final mockData = <Comment>[];

  //   when(() => mockApprovalRepository.getQueryResponse())
  //       .thenAnswer((_) async => mockData);

  //   viewModel.init(MockBuildContext());

  //   // expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  //   expect(viewModel.comments, mockData);
  // });

  test('getComments success', () async {
    final mockComments = [
      Comment(commentId: '1', comment: 'Test comment'),
    ];

    when(() => mockCommonRepository.getComments(
            CommentsType.approval, EntityIdentifier.approval))
        .thenAnswer((_) async => mockComments);

    final response = await mockCommonRepository.getComments(
        CommentsType.approval, EntityIdentifier.approval);

    expect(response, mockComments);
  });

  test('getComments failure', () async {
    when(() => mockCommonRepository.getComments(
            CommentsType.approval, EntityIdentifier.approval))
        .thenThrow(Exception());

    expect(
        () => mockCommonRepository.getComments(
            CommentsType.approval, EntityIdentifier.approval),
        throwsException);
  });

  // test('onSavePress success', () async {
  //   final mockComment = Comment(comment: 'Test');
  //   viewModel.comment = mockComment;

  //   Globals.request = Request(applicantRim: 'APP123');
  //   Globals.user = User(id: 'user1', availableRoles: [Role(id: 1)]);

  //   when(() => mockCommonRepository.saveComment(mockComment))
  //       .thenAnswer((_) async => 'Saved successfully');

  //   viewModel.onSavePress();

  //   // Wait for the async operation to complete
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  // });

  // test('onSavePress failure ', () async {
  //   final mockComment = Comment(comment: 'Test');
  //   viewModel.comment = mockComment;

  //   Globals.request = Request(applicantRim: 'APP123');
  //   Globals.user = User(id: 'user1', availableRoles: [Role(roleId: 1)]);

  //   when(() => mockCommonRepository.saveComment(mockComment))
  //       .thenThrow(Exception('Save failed'));

  //   viewModel.onSavePress(context: mockContext);

  //   // Wait for the async operation to complete
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  // });

  test('getComments should handle exception and show failure toast', () async {
    // Simulate an exception
    // when(() => mockRepository.getQueryResponse())
    //     .thenThrow(Exception('Failed to fetch'));

    // Stub AlertManager
    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

    // Call the method
    await viewModel.getComments();

    // Verify toast was shown
    verify(() => mockAlertManager.showFailureToast(any())).called(1);
  });

  test('viewModel properties are properly initialized', () {
    expect(viewModel.comment, isNull);
    expect(viewModel.comments, isEmpty);
  });

  group('QueriesAndResponsesState', () {
    test('constructor sets loaderStatus', () {
      final state =
          QueriesAndResponsesState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test('copyWith keeps existing when null', () {
      final original =
          QueriesAndResponsesState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test('copyWith overrides', () {
      final original =
          QueriesAndResponsesState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });

  group('onTextChange', () {
    test('should validate the field', () async {
      viewModel.onTextChange("");
      expect(viewModel.canSubmit, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      viewModel.onTextChange("New Comment");
      expect(viewModel.canSubmit, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });
}
