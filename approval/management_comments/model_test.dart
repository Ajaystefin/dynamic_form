import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/approval/management_comments/model.dart';
import 'package:wcas_frontend/features/request/approval/management_comments/state.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';

class MockAlertManager extends Mock implements AlertManager {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockFormState extends Mock implements FormState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MockFormState';
  }
}

class MockGlobalKey extends Mock implements GlobalKey<FormState> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await EnvConfig.setEnvironment();
    registerFallbackValue('');
  });

  late ManagementCommentsViewModel viewModel;
  late MockAlertManager mockAlert;
  late MockRequestRepository mockRepo;
  late MockFormState mockFormState;
  late MockGlobalKey mockGlobalKey;

  setUp(() {
    mockAlert = MockAlertManager();
    mockRepo = MockRequestRepository();
    mockFormState = MockFormState();
    mockGlobalKey = MockGlobalKey();

    AlertManager.overrideInstance(mockAlert);

    viewModel = ManagementCommentsViewModel()..repository = mockRepo;

    when(() => mockAlert.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlert.showFailureToast(any())).thenReturn(null);
    when(() => mockGlobalKey.currentState).thenReturn(mockFormState);
    when(() => mockFormState.validate()).thenReturn(true);
    when(() => mockFormState.save()).thenReturn(null);
  });

  tearDown(() {
    viewModel.close();
  });

  group('ManagementCommentsViewModel - Initialization Tests', () {
    test('constructor initializes with loading state', () {
      final newViewModel = ManagementCommentsViewModel();
      expect(newViewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test('formKey is properly initialized', () {
      expect(viewModel.formKey, isA<GlobalKey<FormState>>());
    });

    test('management comment fields have default values', () {
      expect(viewModel.creditCommitteeRecommendations, '');
      expect(viewModel.ccoComments, '');
      expect(viewModel.ceoComments, '');
      expect(viewModel.bcicComments, '');
    });

    test('repository can be set manually', () {
      viewModel.repository = mockRepo;
      expect(viewModel.repository, mockRepo);
    });
  });

  // group('ManagementCommentsViewModel - init() Method Tests', () {
  // test('init() initializes repository and sets state to loaded', () async {
  //   viewModel.init('test_context');
  //   await Future.delayed(Duration.zero);

  //   expect(viewModel.repository, isA<RequestRepository>());
  //   expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  // });

  // test('init() handles different context types', () async {
  //   viewModel.init(null);
  //   await Future.delayed(Duration.zero);
  //   expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

  //   viewModel.init(123);
  //   await Future.delayed(Duration.zero);
  //   expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  // });
  // });

  group('ManagementCommentsViewModel - onSave Method Tests', () {
    test('onSave without attached form emits loaded and no toast', () async {
      await viewModel.onSave();
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      verifyNever(() => mockAlert.showSuccessToast(any()));
    });

    test('onSave with valid form shows success toast', () async {
      viewModel.formKey = mockGlobalKey;

      await viewModel.onSave();

      verify(() => mockFormState.validate()).called(1);
      verify(() => mockFormState.save()).called(1);
      verify(() => mockAlert.showSuccessToast(
          'approval.managementComments.savedSuccessfully')).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('onSave with invalid form does not save or show toast', () async {
      viewModel.formKey = mockGlobalKey;
      when(() => mockFormState.validate()).thenReturn(false);

      await viewModel.onSave();

      verify(() => mockFormState.validate()).called(1);
      verifyNever(() => mockFormState.save());
      verifyNever(() => mockAlert.showSuccessToast(any()));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('onSave with null form state does not save', () async {
      viewModel.formKey = mockGlobalKey;
      when(() => mockGlobalKey.currentState).thenReturn(null);

      await viewModel.onSave();

      verifyNever(() => mockFormState.validate());
      verifyNever(() => mockFormState.save());
      verifyNever(() => mockAlert.showSuccessToast(any()));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('onSave handles form validation exception', () async {
      viewModel.formKey = mockGlobalKey;
      when(() => mockFormState.validate())
          .thenThrow(Exception('Validation error'));

      await viewModel.onSave();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test('onSave handles form save exception', () async {
      viewModel.formKey = mockGlobalKey;
      when(() => mockFormState.save()).thenThrow(Exception('Save error'));

      await viewModel.onSave();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test('onSave handles toast exception and sets error state', () async {
      viewModel.formKey = mockGlobalKey;
      when(() => mockAlert.showSuccessToast(any()))
          .thenThrow(Exception('Toast error'));

      await viewModel.onSave();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test('onSave processes form data correctly when valid', () async {
      viewModel.formKey = mockGlobalKey;
      viewModel.creditCommitteeRecommendations = 'Updated recommendation';
      viewModel.ccoComments = 'Updated CCO comment';

      await viewModel.onSave();

      expect(
          viewModel.creditCommitteeRecommendations, 'Updated recommendation');
      expect(viewModel.ccoComments, 'Updated CCO comment');
      verify(() => mockFormState.save()).called(1);
    });
  });

  group('ManagementCommentsViewModel - State Management Tests', () {
    test('state changes correctly during successful save operation', () async {
      viewModel.formKey = mockGlobalKey;

      final List<LoadingStatus> statusChanges = [];
      viewModel.stream.listen((state) {
        statusChanges.add(state.loaderStatus);
      });

      await viewModel.onSave();
      await Future.delayed(Duration.zero);

      expect(statusChanges, contains(LoadingStatus.loaded));
    });

    test('state changes correctly during error scenario', () async {
      viewModel.formKey = mockGlobalKey;
      when(() => mockFormState.validate()).thenThrow(Exception('Test error'));

      final List<LoadingStatus> statusChanges = [];
      viewModel.stream.listen((state) {
        statusChanges.add(state.loaderStatus);
      });

      await viewModel.onSave();
      await Future.delayed(Duration.zero);

      expect(statusChanges, contains(LoadingStatus.error));
    });

    test('state object copyWith method works correctly', () {
      final initialState =
          ManagementCommentsState(loaderStatus: LoadingStatus.loading);
      final newState =
          initialState.copyWith(loaderStatus: LoadingStatus.loaded);

      expect(newState.loaderStatus, LoadingStatus.loaded);
      expect(initialState.loaderStatus, LoadingStatus.loading);
    });

    test('state object copyWith preserves existing values when null passed',
        () {
      final initialState =
          ManagementCommentsState(loaderStatus: LoadingStatus.loading);
      final newState = initialState.copyWith();

      expect(newState.loaderStatus, LoadingStatus.loading);
    });
  });

  group('ManagementCommentsViewModel - Field Management Tests', () {
    test('credit committee recommendations can be updated', () {
      viewModel.creditCommitteeRecommendations = 'New recommendation';
      expect(viewModel.creditCommitteeRecommendations, 'New recommendation');
    });

    test('CCO comments can be updated', () {
      viewModel.ccoComments = 'New CCO comment';
      expect(viewModel.ccoComments, 'New CCO comment');
    });

    test('CEO comments can be updated', () {
      viewModel.ceoComments = 'New CEO comment';
      expect(viewModel.ceoComments, 'New CEO comment');
    });

    test('BCIC comments can be updated', () {
      viewModel.bcicComments = 'New BCIC comment';
      expect(viewModel.bcicComments, 'New BCIC comment');
    });

    test('all comment fields can be cleared', () {
      viewModel.creditCommitteeRecommendations = '';
      viewModel.ccoComments = '';
      viewModel.ceoComments = '';
      viewModel.bcicComments = '';

      expect(viewModel.creditCommitteeRecommendations, '');
      expect(viewModel.ccoComments, '');
      expect(viewModel.ceoComments, '');
      expect(viewModel.bcicComments, '');
    });
  });

  group('ManagementCommentsViewModel - Integration Tests', () {
    testWidgets('complete workflow with form widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: viewModel.formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) =>
                        value?.isEmpty == true ? 'Required' : null,
                    initialValue: viewModel.creditCommitteeRecommendations,
                    onSaved: (value) =>
                        viewModel.creditCommitteeRecommendations = value ?? '',
                  ),
                  TextFormField(
                    validator: (value) =>
                        value?.isEmpty == true ? 'Required' : null,
                    initialValue: viewModel.ccoComments,
                    onSaved: (value) => viewModel.ccoComments = value ?? '',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await viewModel.onSave();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      verifyNever(() => mockAlert.showSuccessToast(
          'approval.managementComments.savedSuccessfully')).called(0);
    });

    testWidgets('workflow with form validation failure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: viewModel.formKey,
              child: TextFormField(
                validator: (value) => 'Always fails',
                initialValue: '',
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await viewModel.onSave();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      verifyNever(() => mockAlert.showSuccessToast(any()));
    });

    test('viewModel can be initialized multiple times', () async {
      final vm1 = ManagementCommentsViewModel();
      final vm2 = ManagementCommentsViewModel();
      final vm3 = ManagementCommentsViewModel();

      expect(vm1.state.loaderStatus, LoadingStatus.loading);
      expect(vm2.state.loaderStatus, LoadingStatus.loading);
      expect(vm3.state.loaderStatus, LoadingStatus.loading);

      vm1.close();
      vm2.close();
      vm3.close();
    });

    test('viewModel can handle rapid state changes', () async {
      viewModel.formKey = mockGlobalKey;

      await Future.wait([
        viewModel.onSave(),
        viewModel.onSave(),
        viewModel.onSave(),
      ]);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group('ManagementCommentsState', () {
    test('constructor sets loaderStatus', () {
      final state =
          ManagementCommentsState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test('copyWith keeps existing when null', () {
      final original =
          ManagementCommentsState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test('copyWith overrides field', () {
      final original =
          ManagementCommentsState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });

  group('onTextChange', () {
    test('should validate the field', () async {
      viewModel.onTextChange("", 1);
      expect(viewModel.canSubmit, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      viewModel.onTextChange("", 1);
      viewModel.onTextChange("New Comment", 2);
      viewModel.onTextChange("", 3);
      viewModel.onTextChange("", 4);
      expect(viewModel.canSubmit, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      viewModel.onTextChange("New Comment 1", 1);
      viewModel.onTextChange("New Comment 2", 2);
      viewModel.onTextChange("New Comment 3", 3);
      viewModel.onTextChange("New Comment 4", 4);
      expect(viewModel.canSubmit, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });
}
