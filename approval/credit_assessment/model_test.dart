import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/approval/credit_assessment/model.dart';
import 'package:wcas_frontend/features/request/approval/credit_assessment/state.dart';

class TestAlertManager implements AlertManager {
  String? lastFailure, lastSuccess;
  @override
  void showFailureToast(String msg) => lastFailure = msg;
  @override
  void showSuccessToast(String msg) => lastSuccess = msg;
  @override
  void showInfoToast(String msg) {}
  @override
  void showWarningToast(String msg) {}
}

// abstract class HtmlTextProvider {
//   Future<String> getText();
// }

// class HtmlEditorTextProvider implements HtmlTextProvider {
//   final HtmlEditorController controller;

//   HtmlEditorTextProvider(this.controller);

//   @override
//   Future<String> getText() {
//     return controller.getText();
//   }
// }

// class MockHtmlTextProvider extends Mock implements HtmlTextProvider {}

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

class MockRequestRepository extends Mock implements RequestRepository {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // const MethodChannel(
  //         'dev.fluttercommunity.plus/connectivity', JSONMethodCodec())
  //     .setMockMethodCallHandler((_) async => ['wifi']);

  const channel = MethodChannel(
    'dev.fluttercommunity.plus/connectivity',
    JSONMethodCodec(),
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    return ['wifi'];
  });

  late CreditAssessmentViewModel viewModel;
  late MockRequestRepository mockRepo;
  late MockUnifiedEditorController mockController;
  late TestAlertManager alertSpy;
  // late GlobalKey<FormState> formKey;
  late BuildContext fakeContext;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  setUp(() async {
    await EnvConfig.setEnvironment();

    mockRepo = MockRequestRepository();
    mockController = MockUnifiedEditorController();
    alertSpy = TestAlertManager();
    fakeContext = FakeBuildContext();

    // Override singletons
    // RequestRepository.overrideInstance(mockRepo);
    AlertManager.overrideInstance(alertSpy);

    viewModel = CreditAssessmentViewModel()
      ..repository = mockRepo
      ..controller1 = mockController
      ..controller2 = mockController;

    when(() => mockController.getText())
        .thenAnswer((_) async => '<p>Some&nbsp;Remarks</p>');

    // formKey = viewModel.formKey;
  });

  test('initial state is loading', () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  // test('init() emits loaded', () async {
  //   await viewModel.init(fakeContext);
  //   expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  // });

  group('onSavePress error branch', () {
    test('controller throws → failure toast & error status', () async {
      when(() => mockController.getText()).thenThrow(Exception('JS Error'));

      await viewModel.onSavePress(context: fakeContext);
      expect(alertSpy.lastFailure, 'Exception: JS Error');
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  // group('onSavePress empty remarks branch', () {
  //   test('empty plainText → failure toast & no state change', () async {
  //     when(() => mockController.getText())
  //         .thenAnswer((_) async => '<p>&nbsp;</p>');
  //     viewModel = CreditAssessmentViewModel()
  //       ..repository = mockRepo
  //       ..controller1 = mockController;
  //     AlertManager.overrideInstance(alertSpy);

  //     await viewModel.onSavePress(context: fakeContext);

  //     expect(alertSpy.lastFailure,
  //         'approval.creditAssessment.pleaseEnterRemarks'); // .tr() returns key
  //     expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  //   });
  // });

  // group('onSavePress validate failure branch', () {
  //   testWidgets(
  //     'non-empty but form invalid → no toast & stays loading',
  //     (tester) async {
  //       when(() async => await mockController.getText())
  //           .thenAnswer((_) async => '<p>NotEmpty</p>');

  //       await tester.pumpWidget(
  //         MaterialApp(
  //           home: Scaffold(
  //             body: Form(
  //               key: viewModel.formKey,
  //               child: TextFormField(
  //                 validator: (_) => 'error', // any non-null = invalid
  //               ),
  //             ),
  //           ),
  //         ),
  //       );

  //       // Act
  //       await viewModel.onSavePress(context: tester.element(find.byType(Form)));

  //       expect(alertSpy.lastFailure, isNull);
  //       expect(alertSpy.lastSuccess, isNull);
  //       expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  //     },
  //   );
  // });

  // group('onSavePress success branch', () {
  //   testWidgets('valid remarks + valid form → success toast & loaded',
  //       (tester) async {
  //     await tester.pumpWidget(
  //       MaterialApp(
  //         home: Scaffold(
  //           body: Form(
  //             // key: formKey,
  //             child: TextFormField(
  //               validator: (_) => null, // always valid
  //             ),
  //           ),
  //         ),
  //       ),
  //     );

  //     await viewModel.onSavePress(
  //         isContinue: false, context: tester.element(find.byType(Form)));

  //     expect(alertSpy.lastSuccess,
  //         'approval.creditAssessment.savedSuccessfully'); // .tr()
  //     expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  //   });
  // });

  group('CreditAssessmentState', () {
    test('constructor sets provided loaderStatus', () {
      final state = CreditAssessmentState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test('copyWith with null keeps existing values', () {
      final original =
          CreditAssessmentState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test('copyWith overrides provided fields and does not mutate original', () {
      final original =
          CreditAssessmentState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
