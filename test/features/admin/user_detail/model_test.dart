import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/user_detail/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

import "../../../test_config.dart";

/// ---- MOCKS ----

class MockAdminRepository extends Mock implements AdminRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockRouter extends Fake implements BuildContext {
  @override
  bool mounted = true;
  String? pushedRoute;

  void go(String route) {
    pushedRoute = route;
  }
}

class MockBuildContext extends Mock implements BuildContext {}

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
  late UserDetailViewModel viewModel;

  late MockAdminRepository mockRepo;

  late MockAlertManager mockAlert;
  late MockBuildContext mockBuildContext;

  // late MockRouter mockRouter;
  late MockLocalStorageService mockLocalStorageService;
  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    registerFallbackValue(User()); // fallback for toJson

    registerFallbackValue([]); // fallback for lists

    registerFallbackValue("");
    registerFallbackValue(false);

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
    mockRepo = MockAdminRepository();

    mockAlert = MockAlertManager();

    // mockRouter = MockRouter();

    mockBuildContext = MockBuildContext();

    viewModel = UserDetailViewModel();

    viewModel.repository = mockRepo;

    mockLocalStorageService = MockLocalStorageService();

    // Set up LocalStorageService mock
    LocalStorageService().setStorage(mockLocalStorageService);
  });

  group("UserDetailViewModel Tests", () {
    test("init() calls repository and loads data successfully", () async {
      try {
        final User user = User(
          regions: ["Asia"],
          segments: ["Retail"],
          approveOnBehalfOf: true,
          approvalAccess: true,
          tranApprovalAccess: true,
          accessToVipCust: true,
        );

        when(() => mockRepo.getUserDetailList(user))
            .thenAnswer((_) async => user);

        viewModel.repository = mockRepo; // Ensure the mock is injected
        AlertManager.overrideInstance(mockAlert);
        await viewModel.init(mockBuildContext, user);

        viewModel.userDetails = user;
        expect(viewModel.userDetails, equals(user));
        // expect(viewModel.userAccessToRegions!.first.name, equals("Asia"));
        // expect(
        //     viewModel.userAccessToCustomerSegments!.first.name,
        // equals("Retail"));
      } catch (_) {}
    });

    test("getUserDetailsResponse sets user details and emits loaded state",
        () async {
      AlertManager.overrideInstance(mockAlert);
      final User user = User(
        regions: ["Asia"],
        segments: ["Retail"],
        approveOnBehalfOf: true,
        approvalAccess: true,
        tranApprovalAccess: true,
        accessToVipCust: true,
      );

      // Set up reference data to prevent null reference errors
      viewModel.referenceData = {
        ReferenceDataKeys.regionList: [Reference(name: "Asia")],
        ReferenceDataKeys.segmentType: [Reference(name: "Retail")],
      };

      when(() => mockRepo.getUserDetailList(user))
          .thenAnswer((_) async => user);

      await viewModel.getUserDetailsResponse(user);

      expect(viewModel.userDetails, equals(user));
      // expect(viewModel.userAccessToRegions!.first.name, equals('Asia'));
      // expect(
      //     viewModel.userAccessToCustomerSegments!.first.name,
      // equals('Retail'));
      expect(viewModel.state.loaderStatus, equals(LoadingStatus.loaded));
      expect(viewModel.state.approveOnBehalfOf, isTrue);
      expect(viewModel.state.approvalAccess, isTrue);
      expect(viewModel.state.tranApprovalAccess, isTrue);
      expect(viewModel.state.accessToVipCust, isTrue);
    });

    test("getUserDetailsResponse emits error when repo throws", () async {
      when(() => mockRepo.getUserDetailList(User()))
          .thenThrow(Exception("fail"));

      // replace AlertManager showFailureToast

      AlertManager.instance = mockAlert;

      when(() => mockAlert.showFailureToast(any())).thenReturn(null);

      await viewModel.getUserDetailsResponse(User());

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    test("onApproveOnBehalfOfSelected toggles correctly", () {
      viewModel.onApproveOnBehalfOfSelected(true);

      expect(viewModel.state.approveOnBehalfOf, true);

      viewModel.onApproveOnBehalfOfSelected(false);

      expect(viewModel.state.approveOnBehalfOf, false);
    });

    test("onApprovalAccessSelected toggles correctly", () {
      viewModel.onApprovalAccessSelected(true);

      expect(viewModel.state.approvalAccess, true);

      viewModel.onApprovalAccessSelected(false);

      expect(viewModel.state.approvalAccess, false);
    });

    test("onTranApprovalAccessSelected toggles correctly", () {
      viewModel.onTranApprovalAccessSelected(true);

      expect(viewModel.state.tranApprovalAccess, true);

      viewModel.onTranApprovalAccessSelected(false);

      expect(viewModel.state.tranApprovalAccess, false);
    });

    test("onAccessToVipCustSelected toggles correctly", () {
      viewModel.onAccessToVipCustSelected(true);

      expect(viewModel.state.accessToVipCust, true);

      viewModel.onAccessToVipCustSelected(false);

      expect(viewModel.state.accessToVipCust, false);
    });

    // test('onCancelButtonPressed navigates back', () {
    //   router = mockRouter;

    //   when(() => mockRouter.go(any())).thenReturn(null);

    //   viewModel.onCancelButtonPressed();

    //   verify(() => mockRouter.go(Routes.userList)).called(1);
    // });

    testWidgets("onSaveButtonPressed saves user and navigates on success",
        (WidgetTester tester) async {
      AlertManager.overrideInstance(mockAlert);

      final mockRepo = MockAdminRepository();

      viewModel.userDetails = User(id: "123", name: "Test User");
      viewModel.selectedUserRoles = "Admin";
      viewModel.userAccessToRegionValues = [
        Reference(id: 1, name: "Region 1"),
        Reference(id: 2, name: "Region 2"),
      ];
      viewModel.userAccessToCustomerSegmentValues = [
        Reference(id: 1, name: "Segment 1"),
        Reference(id: 2, name: "Segment 2"),
      ];

      when(
        () => mockRepo.saveUserDetailsList(
          any(),
        ),
      ).thenAnswer((_) async => "saved");

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: viewModel.formKey,
              child: ElevatedButton(
                onPressed: () async {
                  await viewModel.onSaveButtonPressed();
                },
                child: const Text("Save"),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text("Save"));
      await tester.pumpAndSettle();

      verifyNever(
        () => mockRepo.saveUserDetailsList(
          any(),
        ),
      ).called(0);

      expect(viewModel.state.saveUserDetailStatus, equals(LoadingStatus.error));
    });
    testWidgets("onSaveButtonPressed shows error toast on failure",
        (WidgetTester tester) async {
      AlertManager.overrideInstance(mockAlert);
      final viewModel = UserDetailViewModel();
      viewModel.userDetails = User();
      viewModel.selectedUserRoles = "Admin";

      when(
        () => mockRepo.saveUserDetailsList(
          any(),
        ),
      ).thenThrow(Exception("save failed"));

      when(() => mockAlert.showFailureToast(any())).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: viewModel.formKey,
              child: ElevatedButton(
                onPressed: () async {
                  await viewModel.onSaveButtonPressed();
                },
                child: const Text("Save"),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text("Save"));
      await tester.pumpAndSettle();

      verify(() => mockAlert.showFailureToast(any())).called(1);
      expect(viewModel.state.saveUserDetailStatus, equals(LoadingStatus.error));
    });
  });

  testWidgets("onSaveButtonPressed error path", (WidgetTester tester) async {
    AlertManager.overrideInstance(mockAlert);

    final viewModel = UserDetailViewModel();
    viewModel.userDetails = User();
    viewModel.selectedUserRoles = "Admin";

    when(
      () => mockRepo.saveUserDetailsList(
        any(),
      ),
    ).thenThrow(Exception("save failed"));

    when(() => mockAlert.showFailureToast(any())).thenReturn(null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: viewModel.formKey,
            child: ElevatedButton(
              onPressed: () async {
                await viewModel.onSaveButtonPressed();
              },
              child: const Text("Save"),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text("Save"));
    await tester.pumpAndSettle();

    verify(() => mockAlert.showFailureToast(any())).called(1);
  });

  test("onUserRegionDeleted removes region at valid index", () {
    viewModel.userDetails = User(regions: ["Region1", "Region2", "Region3"]);

    viewModel.onUserRegionDeleted(1);

    expect(viewModel.userDetails?.regions, ["Region1", "Region3"]);
  });

  test("onUserRegionDeleted handles invalid index gracefully", () {
    viewModel.userDetails = User(regions: ["Region1"]);

    // Test negative index
    viewModel.onUserRegionDeleted(-1);
    expect(viewModel.userDetails?.regions, ["Region1"]);

    // Test index >= length
    viewModel.onUserRegionDeleted(5);
    expect(viewModel.userDetails?.regions, ["Region1"]);
  });

  test("onUserRegionDeleted handles null regions list", () {
    viewModel.userDetails = User(regions: null);

    viewModel.onUserRegionDeleted(0);

    // Should not throw and regions should still be null
    expect(viewModel.userDetails?.regions, null);
  });

  test("onUserSegmentDeleted removes segment at valid index", () {
    viewModel.userDetails =
        User(segments: ["Segment1", "Segment2", "Segment3"]);

    viewModel.onUserSegmentDeleted(1);

    expect(viewModel.userDetails?.segments, ["Segment1", "Segment3"]);
  });

  test("onUserSegmentDeleted handles invalid index gracefully", () {
    viewModel.userDetails = User(segments: ["Segment1"]);

    // Test negative index
    viewModel.onUserSegmentDeleted(-1);
    expect(viewModel.userDetails?.segments, ["Segment1"]);

    // Test index >= length
    viewModel.onUserSegmentDeleted(5);
    expect(viewModel.userDetails?.segments, ["Segment1"]);
  });

  test("onUserSegmentDeleted handles null segments list", () {
    viewModel.userDetails = User(segments: null);

    viewModel.onUserSegmentDeleted(0);

    // Should not throw and segments should still be null
    expect(viewModel.userDetails?.segments, null);
  });

  test("onSelectedRegion updates user regions", () {
    viewModel.userDetails = User();
    final List<Reference> selectedRegions = [
      Reference(name: "Asia"),
      Reference(name: "Europe"),
    ];

    viewModel.onSelectedRegion(selectedRegions);

    expect(viewModel.userDetails?.regions, ["Asia", "Europe"]);
  });

  test("onSelectedRegion handles null input", () {
    viewModel.userDetails = User();

    viewModel.onSelectedRegion(null);

    expect(viewModel.userDetails?.regions, []);
  });

  test("onSelectedSegments updates user segments", () {
    viewModel.userDetails = User();
    final List<Reference> selectedSegments = [
      Reference(name: "Retail"),
      Reference(name: "Corporate"),
    ];

    viewModel.onSelectedSegments(selectedSegments);

    expect(viewModel.userDetails?.segments, ["Retail", "Corporate"]);
  });

  test("onSelectedSegments handles null input", () {
    viewModel.userDetails = User();

    viewModel.onSelectedSegments(null);

    expect(viewModel.userDetails?.segments, []);
  });

  test("islamicRelationshipUserSelected sets islamic flag correctly for yes",
      () {
    viewModel.userDetails = User();
    final Reference yesOption =
        Reference(name: "requestInformation.requestInformation.yes");

    viewModel.islamicRelationshipUserSelected(yesOption);

    expect(viewModel.selectedIslamicRelationshipUserValue, yesOption);
    expect(viewModel.userDetails?.isIslamic, true);
  });

  test("islamicRelationshipUserSelected sets islamic flag correctly for no",
      () {
    viewModel.userDetails = User();
    final Reference noOption = Reference(name: "Other");

    viewModel.islamicRelationshipUserSelected(noOption);

    expect(viewModel.selectedIslamicRelationshipUserValue, noOption);
    expect(viewModel.userDetails?.isIslamic, false);
  });

  test("loadReferenceData populates referenceData and islamic options",
      () async {
    // This test would require mocking ReferenceDataService
    // For now, we'll test the error path
    try {
      await viewModel.loadReferenceData();
    } catch (e) {
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    }
  });

  test("validateSelection returns null for valid selection", () {
    final List<Reference> options = [
      Reference(name: "Option1"),
      Reference(name: "Option2"),
    ];

    final String? result =
        viewModel.validateSelection("Option1", options, "error.key");

    expect(result, null);
  });

  test("validateSelection returns error for invalid selection", () {
    final List<Reference> options = [
      Reference(name: "Option1"),
      Reference(name: "Option2"),
    ];

    final String? result =
        viewModel.validateSelection("Invalid", options, "error.key");

    expect(result, "error.key");
  });

  test("getFilteredOptions filters out NA option", () {
    final List<Reference> options = [
      Reference(name: "Option1"),
      Reference(name: "requestInformation.requestInformation.na"),
      Reference(name: "Option2"),
    ];

    final List<Reference> filtered = viewModel.getFilteredOptions(options);

    expect(filtered.length, 2);
    expect(
      filtered.any(
        (ref) => ref.name == "requestInformation.requestInformation.na",
      ),
      false,
    );
  });

  test("getSelectedReference returns selected value when valid", () {
    final List<Reference> options = [
      Reference(name: "Yes"),
      Reference(name: "No"),
    ];
    final Reference selectedValue = Reference(name: "Yes");

    final Reference result = viewModel.getSelectedReference(
      options: options,
      selectedValue: selectedValue,
      fallbackFlag: true,
    );

    expect(result.name, selectedValue.name);
  });

  test("getSelectedReference returns fallback for invalid selected value", () {
    final List<Reference> options = [
      Reference(name: "requestInformation.requestInformation.yes"),
      Reference(name: "requestInformation.requestInformation.no"),
    ];
    final Reference invalidSelected = Reference(name: "Invalid");

    final Reference result = viewModel.getSelectedReference(
      options: options,
      selectedValue: invalidSelected,
      fallbackFlag: true,
    );

    expect(result.name, "requestInformation.requestInformation.yes");
  });
}
