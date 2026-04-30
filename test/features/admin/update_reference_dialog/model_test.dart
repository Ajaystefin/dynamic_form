import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:path/path.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

class MockAdminRepository extends Mock implements AdminRepository {}

class MockContext extends Mock implements Context {}

class MockBuildContext extends Mock implements BuildContext {}

class MockAlertManager extends Mock implements AlertManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late UpdateReferenceDialogViewModel viewModel;
  late MockAdminRepository mockRepository;
  late GlobalKey<FormState> formKey;
  // late BuildContext fakeContext;
  final referenceType = ReferenceType(id: 1, name: "Type A");
  final referenceTypes = [referenceType];

  // late MockAlertManager mockAlertManager;

  setUp(() {
    mockRepository = MockAdminRepository();
    viewModel = UpdateReferenceDialogViewModel();
    // Set the repository directly instead of using the singleton
    viewModel.repository = mockRepository;
    formKey = GlobalKey<FormState>();
    viewModel.formKey = formKey;
    formKey = GlobalKey<FormState>();
    registerFallbackValue(Reference());

    // mockAlertManager = MockAlertManager();

    registerFallbackValue(MockAlertManager());
  });

  test("initial state should be loading and saveButtonStatus loaded", () {
    // Don't call init() to avoid singleton initialization issues
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    expect(viewModel.state.saveButtonStatus, LoadingStatus.loaded);
  });

  test("getReferenceTypes success", () async {
    when(() => mockRepository.getReferenceTypes())
        .thenAnswer((_) async => referenceTypes);

    await viewModel.getReferenceTypes();

    expect(viewModel.allReferences, referenceTypes);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("getReferenceTypes failure", () async {
    when(() => mockRepository.getReferenceTypes())
        .thenThrow(Exception("Failed"));

    await viewModel.getReferenceTypes();
    expect(viewModel.allReferences, []);
    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  test("onUpdateReferenceData updates fields and emits loaded", () {
    final testReference = Reference(id: 1, name: "Test Name");
    viewModel.onUpdateReferenceData(testReference);
    expect(viewModel.reference.id, 1);
    expect(viewModel.reference.name, "Test Name");
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  // testWidgets('onSaveButtonClick should show failure toast on error',
  //     (WidgetTester tester) async {
  //   final formKey = GlobalKey<FormState>();
  //   // late BuildContext testContext;

  //   tester.pumpWidget(
  //     MaterialApp(
  //       home: Builder(
  //         builder: (context) {
  //           // testContext = context;
  //           return Form(
  //             key: formKey,
  //             child: Container(),
  //           );
  //         },
  //       ),
  //     ),
  //   );

  //   when(() => mockRepository.saveReferenceDataInformation(any(), any()))
  //       .thenThrow(Exception('Save failed'));

  //   // Inject mock alert manager
  //   AlertManager.overrideInstance(mockAlertManager);
  //   when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

  //   viewModel.referenceDataTypeID = 1;
  //   viewModel.reference = Reference(name: 'Test');
  //   viewModel.statusListValue = [Status.active.name];
  //   viewModel.formKey = formKey;

  //   viewModel.onSaveButtonClick(MockBuildContext());

  //   verify(() => mockAlertManager.showFailureToast(any())).called(1);
  // });

  // testWidgets('onSaveButtonClick saves data and pops context', (tester) async
  // {
  //   when(() => mockRepository.saveReferenceDataInformation(any(), any()))
  //       .thenAnswer((_) async => 'success');

  //   final navKey = GlobalKey<NavigatorState>();

  //   await tester.pumpWidget(MaterialApp(
  //     navigatorKey: navKey,
  //     home: Scaffold(
  //       body: Form(
  //         key: viewModel.formKey,
  //         child: TextFormField(
  //           validator: (_) => null,
  //           onSaved: (_) {},
  //         ),
  //       ),
  //     ),
  //   ));

  //   final context = navKey.currentContext!;
  //   viewModel.referenceDataTypeID = 1;
  //   viewModel.reference = Reference(name: 'Test');
  //   viewModel.statusListValue = [Status.active.name];

  //   await viewModel.onSaveButtonClick(context);

  //   verifyNever(() =>
  //           mockRepository.saveReferenceDataInformation(1,
  // viewModel.reference))
  //       .called(1);
  //   expect(viewModel.state.saveButtonStatus, LoadingStatus.loaded);
  // });

  testWidgets("onSaveButtonClick handles validation failure", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: viewModel.formKey,
            child: TextFormField(
              validator: (_) => "error",
            ),
          ),
        ),
      ),
    );

    final context = tester.element(find.byType(Form));
    await viewModel.onSaveButtonClick(context);

    expect(viewModel.state.saveButtonStatus, LoadingStatus.loaded);
    verifyNever(
      () => mockRepository.saveReferenceDataInformation(any(), any()),
    );
  });

  // testWidgets('onSaveButtonClick handles exception and shows toast',
  //     (tester) async {
  //   when(() => mockRepository.saveReferenceDataInformation(any(), any()))
  //       .thenThrow(Exception('save failed'));
  //   when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
  //   AlertManager.overrideInstance(mockAlertManager);

  //   await tester.pumpWidget(MaterialApp(
  //     home: Scaffold(
  //       body: Form(
  //         key: viewModel.formKey,
  //         child: TextFormField(
  //           validator: (_) => null,
  //           onSaved: (_) {},
  //         ),
  //       ),
  //     ),
  //   ));

  //   final context = tester.element(find.byType(Form));
  //   viewModel.referenceDataTypeID = 1;
  //   viewModel.reference = Reference(name: 'Test');
  //   viewModel.statusListValue = [Status.active.name];

  //   await viewModel.onSaveButtonClick(context);

  //   verify(() => mockAlertManager.showFailureToast('Exception: save failed'))
  //       .called(1);
  //   expect(viewModel.state.saveButtonStatus, LoadingStatus.loaded);
  // });
}
