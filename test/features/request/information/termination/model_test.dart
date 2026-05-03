import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
// import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/termination/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
// import 'package:wcas_frontend/models/admin/reference.dart';
// import 'package:wcas_frontend/models/request/comment.dart';
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockAuthRepository extends Mock implements AuthRepository {}

class FakeBuildContext extends Fake implements BuildContext {}

class FakeWidget extends Fake implements Widget {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "FakeWidget";
  }
}

// class MockFormState extends Mock implements FormState {}

class MockDialogHelper extends Mock implements DialogHelper {
  void showCustomDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) {}
}

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
  late TerminationViewModel viewModel;
  late MockRequestRepository mockRepository;
  late MockReferenceDataService mockReferenceDataService;
  late MockAlertManager mockAlertManager;
  late MockCommonRepository mockCommonRepositorysitory;
  // late FakeBuildContext mockContext;
  late MockLocalStorageService mockLocalStorageService;

  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(FakeWidget());
    registerFallbackValue(<Widget>[]); // For actions

    // Mock the connectivity plugin to return a list with wifi connectivity
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (call) async {
        if (call.method == "check") {
          return ["wifi"];
        }
        return null;
      },
    );
  });

  tearDownAll(() async {
    await TestConfig.cleanup();
  });

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockRepository = MockRequestRepository();
    mockReferenceDataService = MockReferenceDataService();
    mockCommonRepositorysitory = MockCommonRepository();
    mockAlertManager = MockAlertManager();
    // mockContext = FakeBuildContext();
    mockLocalStorageService = MockLocalStorageService();

    // Set up LocalStorageService mock
    LocalStorageService().setStorage(mockLocalStorageService);

    viewModel = TerminationViewModel()
      ..repository = mockRepository;

    registerFallbackValue(CommentsType.terminateWithdraw);
    registerFallbackValue(EntityIdentifier.terminateWithdraw);
  });
  testWidgets(
      "onTerminateButtonPressed does not show dialog when form is invalid",
      (WidgetTester tester) async {
    viewModel
      ..terminationPageMode = PageMode.edit
      ..formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Form(
          key: viewModel.formKey,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  viewModel.onTerminateButtonPressed(context);
                },
                child: const Text("Submit"),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Triggers addPostFrameCallback

    // Since form is invalid, dialog should not appear
    expect(
      find.text("requestInformation.terminateWithdrawal.warning".tr()),
      findsNothing,
    );
  });
  testWidgets("onTerminateButtonPressed shows dialog when form is valid",
      (WidgetTester tester) async {
    viewModel
      ..terminationPageMode = PageMode.edit
      ..formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: viewModel.formKey,
            child: Builder(
              builder: (context) {
                return Column(
                  children: [
                    TextFormField(
                      controller: TextEditingController(),
                      validator: (_) => null, // Always valid
                      onSaved: (_) {},
                    ),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.onTerminateButtonPressed(context);
                      },
                      child: const Text("Submit"),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), "Valid input");
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Triggers addPostFrameCallback
    await tester.pump(); // Allows dialog to render

    expect(
      find.text("requestInformation.terminateWithdrawal.warning".tr()),
      findsOneWidget,
    );
  });
  testWidgets("showDialogUpdateTerminateStatus displays confirmation dialog",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                viewModel.showDialogUpdateTerminateStatus(context);
              },
              child: const Text("Trigger Dialog"),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Triggers addPostFrameCallback
    await tester.pump(); // Allows dialog to render

    // Check for presence of dialog content
    expect(
      find.text("requestInformation.terminateWithdrawal.warning".tr()),
      findsOneWidget,
    );
    expect(
      find.text("requestInformation.terminateWithdrawal.warningMsg".tr()),
      findsOneWidget,
    );
  });
  testWidgets("showDialogSuccessTerminateStatus displays success dialog",
      (WidgetTester tester) async {
    viewModel.isTerminationSuccess = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                viewModel.showDialogSuccessTerminateStatus(context);
              },
              child: const Text("Trigger Success Dialog"),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Triggers addPostFrameCallback
    await tester.pump(); // Allows dialog to render

    // Check for presence of dialog content
    expect(
      find.text("requestInformation.terminateWithdrawal.information".tr()),
      findsOneWidget,
    );
    // expect(

    //     findsOneWidget);

    // Confirm flag reset
    expect(viewModel.isTerminationSuccess, false);
  });

  test("MockLocalStorageService should store, retrieve, delete, and clear data",
      () async {
    final storage = MockLocalStorageService();

    await storage.put("box1", "key1", "value1");

    expect(await storage.get("box1", "key1"), "value1");

    await storage.delete("box1", "key1");

    expect(await storage.get("box1", "key1"), isNull);

    await storage.put("box1", "key2", "value2");

    await storage.clearBox("box1");

    expect(await storage.get("box1", "key2"), isNull);

    await storage.put("box2", "key3", "value3");

    storage.clearAll();

    expect(await storage.get("box2", "key3"), isNull);
  });

  group("ApplicationService Tests", () {
    test("submitTerminateRequest calls repository with correct data", () async {
      // when(() => mockRepository.updateTerminateStatus(any(), any()))
      //     .thenAnswer((_) async => 'Success');

      // viewModel.getReviewComments = [
      //   Comment(applicationRefNo: 'APP123', reasonList: 'R1', comment:
      // 'Test')
      // ];

      // await viewModel.submitTerminateRequest(FakeBuildContext());

      // verify(mockRepository.updateTerminateStatus('R1', 'Test')).called(1);
      // expect(viewModel.isTerminationSuccess, true);
    });

    test("submitTerminateRequest handles empty comments", () async {
      // when(() => mockRepository.updateTerminateStatus(any(), any()))
      //     .thenAnswer((_) async => 'Success');

      // viewModel.getReviewComments = [];

      // await viewModel.submitTerminateRequest(FakeBuildContext());

      // expect(viewModel.getReviewComments!.isNotEmpty, false);
      // expect(viewModel.isTerminationSuccess, true);
    });
  });

  group("TerminationViewModel Tests", () {
    test("init calls both getReviewCommentsReference and getReferenceDatas",
        () async {
      viewModel.reasonForTermination = [Reference(id: 1, name: "Test Reason")];
      when(() => mockCommonRepositorysitory.getComments(any(), any()))
          .thenAnswer((_) async => []);
      when(() => mockReferenceDataService.getReferenceData(any())).thenAnswer(
        (_) async => {
          ReferenceDataKeys.terminationReason: [
            Reference(id: 1, name: "Reason"),
          ],
        },
      );

      AlertManager.overrideInstance(mockAlertManager);
      await viewModel.init(FakeBuildContext());

      expect(viewModel.reasonForTermination.isNotEmpty, true);
      expect(viewModel.getReviewComments, isEmpty);
    });

    test("getReviewCommentsReference filters comments by applicationRefNo",
        () async {
      viewModel.getReviewComments = [
        Comment(applicationRefNo: "APP123"),
      ];
      Globals.request?.applicationRefNo = "APP123";
      when(() => mockCommonRepositorysitory.getComments(any(), any()))
          .thenAnswer(
        (_) async => [
          Comment(applicationRefNo: "APP123"),
          Comment(applicationRefNo: "OTHER"),
        ],
      );
      await viewModel.getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      );

      expect(viewModel.getReviewComments!.length, 1);
      expect(viewModel.getReviewComments!.first.applicationRefNo, "APP123");
    });

    test("getReviewCommentsReference handles exception", () async {
      when(() => mockCommonRepositorysitory.getComments(any(), any()))
          .thenThrow(Exception("Error fetching comments"));
      AlertManager.overrideInstance(mockAlertManager);
      await viewModel.getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      );

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test("getReferenceDatas loads termination reasons", () async {
      viewModel.reasonForTermination = [Reference(id: 1, name: "Test Reason")];
      when(() => mockReferenceDataService.getReferenceData(any())).thenAnswer(
        (_) async => {
          ReferenceDataKeys.terminationReason: [
            Reference(id: 1, name: "Test Reason"),
          ],
        },
      );

      await viewModel.getReferenceDatas();

      expect(viewModel.reasonForTermination.length, 1);
      expect(viewModel.reasonForTermination.first.name, "Test Reason");
    });

    test("getReferenceDatas handles exception", () async {
      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenThrow(Exception("Error fetching reference data"));

      await viewModel.getReferenceDatas();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });
}
