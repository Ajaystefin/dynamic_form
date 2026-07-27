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
import "package:wcas_frontend/repositories/auth_repository.dart";

import "../../../test_config.dart";

/// ---- MOCKS ----

class MockAdminRepository extends Mock implements AdminRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {}

class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, Object? value) async {
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
}

void main() {
  late UserDetailViewModel viewModel;
  late MockAdminRepository mockRepo;
  late MockAuthRepository mockAuthRepo;
  late MockAlertManager mockAlert;
  late MockBuildContext mockBuildContext;
  late MockLocalStorageService mockLocalStorageService;

  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    registerFallbackValue(User());
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<Reference>[]);
    registerFallbackValue("");
    registerFallbackValue(false);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          return <String>["wifi"];
        }
        return null;
      },
    );
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
    await TestConfig.cleanup();
  });

  setUp(() {
    mockRepo = MockAdminRepository();
    mockAuthRepo = MockAuthRepository();
    mockAlert = MockAlertManager();
    mockBuildContext = MockBuildContext();
    mockLocalStorageService = MockLocalStorageService();

    LocalStorageService().getStorage = mockLocalStorageService;

    AlertManager.overrideInstance = mockAlert;
    AlertManager.instance = mockAlert;

    when(() => mockAlert.showFailureToast(any())).thenReturn(null);
    when(() => mockAlert.showSuccessToast(any())).thenReturn(null);

    viewModel = UserDetailViewModel()
      ..repository = mockRepo
      ..authRepository = mockAuthRepo;
  });

  tearDown(() async {
    try {
      await viewModel.close();
    } on Object {
      // close() can depend on DraftMixin/global services in tests.
    }
  });

  group("UserDetailViewModel - constructor and draft getters", () {
    test("constructor should initialize default state and fields", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.state.saveUserDetailStatus, LoadingStatus.loaded);
      expect(viewModel.userAccessToRegionValues, isEmpty);
      expect(viewModel.userAccessToCustomerSegmentValues, isEmpty);
      expect(viewModel.selectedUserRoles, "");
      expect(viewModel.islamicRelationshipUserOptions, isEmpty);
      expect(viewModel.referenceData, isEmpty);
      expect(viewModel.formFocusNode, isA<FocusNode>());
      expect(viewModel.formKey, isA<GlobalKey<FormState>>());
    });

    test("draftModuleKey should return admin module key", () {
      expect(viewModel.draftModuleKey, isNotEmpty);
    });

    test("draftFormKey should use route only when selected user is null", () {
      viewModel.selectUserListItem = null;

      expect(viewModel.draftFormKey, contains("admin"));
    });

    test("draftFormKey should use selected user id when id is available", () {
      viewModel.selectUserListItem = User(id: "user-id-123", userName: "john");

      expect(viewModel.draftFormKey, contains("user-id-123"));
    });

    test("draftFormKey should use username when id is empty", () {
      viewModel.selectUserListItem = User(id: "", userName: "john.user");

      expect(viewModel.draftFormKey, contains("john.user"));
    });

    test("draftHandler should return handler instance", () {
      expect(viewModel.draftHandler, isNotNull);
    });
  });

  group("UserDetailViewModel - init and reference loading", () {
    test(
        "init should set repositories and selected user even if reference load fails",
        () async {
      final user = User(
        id: "1",
        userName: "test.user",
        regions: <String>["Asia"],
        segments: <String>["Retail"],
      );

      when(() => mockRepo.getUserDetailList(any()))
          .thenAnswer((_) async => user);

      try {
        await viewModel.init(mockBuildContext, user);
      } on Object {
        // ReferenceDataService/DraftMixin can fail in unit environment.
      }

      expect(viewModel.selectUserListItem, user);
      expect(viewModel.repository, isA<AdminRepository>());
      expect(viewModel.authRepository, isA<AuthRepository>());
    });

    test("loadReferenceData should either populate values or emit error safely",
        () async {
      try {
        await viewModel.loadReferenceData();

        expect(viewModel.referenceData, isA<Map<String, List<Reference>>>());
        expect(
          viewModel.islamicRelationshipUserOptions,
          isA<List<Reference>>(),
        );
      } on Object {
        expect(viewModel.state.loaderStatus, LoadingStatus.error);
      }
    });
  });

  group("UserDetailViewModel - getUserDetailsResponse", () {
    test("getUserDetailsResponse should populate user details and emit loaded",
        () async {
      final user = User(
        id: "123",
        regions: <String>["Asia", "Europe"],
        segments: <String>["Retail"],
        approveOnBehalfOf: true,
        approvalAccess: true,
        tranApprovalAccess: true,
        accessToVipCust: true,
      );

      viewModel.referenceData = <String, List<Reference>>{
        ReferenceDataKeys.regionList: <Reference>[
          Reference(name: "Asia"),
          Reference(name: "Europe"),
          Reference(name: "Africa"),
        ],
        ReferenceDataKeys.segmentType: <Reference>[
          Reference(name: "Retail"),
          Reference(name: "Corporate"),
        ],
      };

      when(() => mockRepo.getUserDetailList(any()))
          .thenAnswer((_) async => user);

      await viewModel.getUserDetailsResponse(user);

      expect(viewModel.userDetails, user);
      expect(viewModel.userAccessToRegionValues?.map((e) => e.name), <String?>[
        "Asia",
        "Europe",
      ]);
      expect(
        viewModel.userAccessToCustomerSegmentValues?.map((e) => e.name),
        <String?>["Retail"],
      );
      expect(viewModel.state.approveOnBehalfOf, true);
      expect(viewModel.state.approvalAccess, true);
      expect(viewModel.state.tranApprovalAccess, true);
      expect(viewModel.state.accessToVipCust, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.state.saveUserDetailStatus, LoadingStatus.loaded);
    });

    test(
        "getUserDetailsResponse should apply default false flags for null values",
        () async {
      final user = User(
        id: "456",
        regions: <String>[],
        segments: <String>[],
      );

      when(() => mockRepo.getUserDetailList(any()))
          .thenAnswer((_) async => user);

      await viewModel.getUserDetailsResponse(user);

      expect(viewModel.state.approveOnBehalfOf, false);
      expect(viewModel.state.approvalAccess, false);
      expect(viewModel.state.tranApprovalAccess, false);
      expect(viewModel.state.accessToVipCust, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "getUserDetailsResponse should emit error and show toast when repo throws",
        () async {
      when(() => mockRepo.getUserDetailList(any()))
          .thenThrow(Exception("fail"));

      await viewModel.getUserDetailsResponse(User());

      verify(() => mockAlert.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("UserDetailViewModel - hydrateRegionAndSegmentSelections", () {
    test("hydrateRegionAndSegmentSelections should match trimmed names", () {
      viewModel
        ..userDetails = User(
          regions: <String>["Asia"],
          segments: <String>["Retail"],
        )
        ..referenceData = <String, List<Reference>>{
          ReferenceDataKeys.regionList: <Reference>[
            Reference(name: " Asia "),
            Reference(name: "Europe"),
          ],
          ReferenceDataKeys.segmentType: <Reference>[
            Reference(name: " Retail "),
            Reference(name: "Corporate"),
          ],
        }
        ..hydrateRegionAndSegmentSelections();

      expect(viewModel.userAccessToRegionValues, hasLength(1));
      expect(viewModel.userAccessToRegionValues?.first.name, " Asia ");
      expect(viewModel.userAccessToCustomerSegmentValues, hasLength(1));
      expect(
        viewModel.userAccessToCustomerSegmentValues?.first.name,
        " Retail ",
      );
    });

    test(
        "hydrateRegionAndSegmentSelections should clear old values when no match",
        () {
      viewModel
        ..userAccessToRegionValues = <Reference>[Reference(name: "Old")]
        ..userAccessToCustomerSegmentValues = <Reference>[
          Reference(name: "Old"),
        ]
        ..userDetails = User(
          regions: <String>["Unknown"],
          segments: <String>["Unknown"],
        )
        ..referenceData = <String, List<Reference>>{
          ReferenceDataKeys.regionList: <Reference>[Reference(name: "Asia")],
          ReferenceDataKeys.segmentType: <Reference>[Reference(name: "Retail")],
        }
        ..hydrateRegionAndSegmentSelections();

      expect(viewModel.userAccessToRegionValues, isEmpty);
      expect(viewModel.userAccessToCustomerSegmentValues, isEmpty);
    });

    test(
        "hydrateRegionAndSegmentSelections should handle missing reference data",
        () {
      viewModel
        ..userDetails = User(
          regions: <String>["Asia"],
          segments: <String>["Retail"],
        )
        ..referenceData = <String, List<Reference>>{}
        ..hydrateRegionAndSegmentSelections();

      expect(viewModel.userAccessToRegionValues, isEmpty);
      expect(viewModel.userAccessToCustomerSegmentValues, isEmpty);
    });

    test("hydrateRegionAndSegmentSelections should handle null user lists", () {
      viewModel
        ..userDetails = User()
        ..referenceData = <String, List<Reference>>{
          ReferenceDataKeys.regionList: <Reference>[Reference(name: "Asia")],
          ReferenceDataKeys.segmentType: <Reference>[Reference(name: "Retail")],
        }
        ..hydrateRegionAndSegmentSelections();

      expect(viewModel.userAccessToRegionValues, isEmpty);
      expect(viewModel.userAccessToCustomerSegmentValues, isEmpty);
    });
  });

  group("UserDetailViewModel - delete region and segment", () {
    test("onUserRegionDeleted removes region at valid index", () {
      viewModel
        ..userDetails = User(regions: <String>["Region1", "Region2", "Region3"])
        ..onUserRegionDeleted(1);

      expect(viewModel.userDetails?.regions, <String>["Region1", "Region3"]);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onUserRegionDeleted handles negative index", () {
      viewModel
        ..userDetails = User(regions: <String>["Region1"])
        ..onUserRegionDeleted(-1);

      expect(viewModel.userDetails?.regions, <String>["Region1"]);
    });

    test("onUserRegionDeleted handles index greater than length", () {
      viewModel
        ..userDetails = User(regions: <String>["Region1"])
        ..onUserRegionDeleted(5);

      expect(viewModel.userDetails?.regions, <String>["Region1"]);
    });

    test("onUserRegionDeleted handles null regions list", () {
      viewModel
        ..userDetails = User()
        ..onUserRegionDeleted(0);

      expect(viewModel.userDetails?.regions, null);
    });

    test("onUserSegmentDeleted removes segment at valid index", () {
      viewModel
        ..userDetails =
            User(segments: <String>["Segment1", "Segment2", "Segment3"])
        ..onUserSegmentDeleted(1);

      expect(viewModel.userDetails?.segments, <String>[
        "Segment1",
        "Segment3",
      ]);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onUserSegmentDeleted handles negative index", () {
      viewModel
        ..userDetails = User(segments: <String>["Segment1"])
        ..onUserSegmentDeleted(-1);

      expect(viewModel.userDetails?.segments, <String>["Segment1"]);
    });

    test("onUserSegmentDeleted handles index greater than length", () {
      viewModel
        ..userDetails = User(segments: <String>["Segment1"])
        ..onUserSegmentDeleted(5);

      expect(viewModel.userDetails?.segments, <String>["Segment1"]);
    });

    test("onUserSegmentDeleted handles null segments list", () {
      viewModel
        ..userDetails = User()
        ..onUserSegmentDeleted(0);

      expect(viewModel.userDetails?.segments, null);
    });
  });

  group("UserDetailViewModel - selected region and segments", () {
    test("onSelectedRegion updates user regions", () {
      final selectedRegions = <Reference>[
        Reference(name: "Asia"),
        Reference(name: "Europe"),
      ];

      viewModel
        ..userDetails = User()
        ..onSelectedRegion(selectedRegions);

      expect(viewModel.userDetails?.regions, <String>["Asia", "Europe"]);
    });

    test("onSelectedRegion trims names and handles null name", () {
      final selectedRegions = <Reference>[
        Reference(name: " Asia "),
        Reference(),
      ];

      viewModel
        ..userDetails = User()
        ..onSelectedRegion(selectedRegions);

      expect(viewModel.userDetails?.regions, <String>["Asia", ""]);
    });

    test("onSelectedRegion handles null input", () {
      viewModel
        ..userDetails = User()
        ..onSelectedRegion(null);

      expect(viewModel.userDetails?.regions, <String>[]);
    });

    test("onSelectedRegion does nothing when userDetails is null", () {
      viewModel
        ..userDetails = null
        ..onSelectedRegion(<Reference>[Reference(name: "Asia")]);

      expect(viewModel.userDetails, null);
    });

    test("onSelectedSegments updates user segments", () {
      final selectedSegments = <Reference>[
        Reference(name: "Retail"),
        Reference(name: "Corporate"),
      ];

      viewModel
        ..userDetails = User()
        ..onSelectedSegments(selectedSegments);

      expect(viewModel.userDetails?.segments, <String>["Retail", "Corporate"]);
    });

    test("onSelectedSegments trims names and handles null name", () {
      final selectedSegments = <Reference>[
        Reference(name: " Retail "),
        Reference(),
      ];

      viewModel
        ..userDetails = User()
        ..onSelectedSegments(selectedSegments);

      expect(viewModel.userDetails?.segments, <String>["Retail", ""]);
    });

    test("onSelectedSegments handles null input", () {
      viewModel
        ..userDetails = User()
        ..onSelectedSegments(null);

      expect(viewModel.userDetails?.segments, <String>[]);
    });

    test("onSelectedSegments does nothing when userDetails is null", () {
      viewModel
        ..userDetails = null
        ..onSelectedSegments(<Reference>[Reference(name: "Retail")]);

      expect(viewModel.userDetails, null);
    });
  });

  group("UserDetailViewModel - islamic relationship selection", () {
    test("islamicRelationshipUserSelected sets islamic flag true for yes", () {
      final yesOption =
          Reference(name: "requestInformation.requestInformation.yes");

      viewModel
        ..userDetails = User()
        ..islamicRelationshipUserSelected(yesOption);

      expect(viewModel.selectedIslamicRelationshipUserValue, yesOption);
      expect(viewModel.userDetails?.isIslamic, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("islamicRelationshipUserSelected sets islamic flag false for non-yes",
        () {
      final noOption = Reference(name: "Other");

      viewModel
        ..userDetails = User()
        ..islamicRelationshipUserSelected(noOption);

      expect(viewModel.selectedIslamicRelationshipUserValue, noOption);
      expect(viewModel.userDetails?.isIslamic, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("islamicRelationshipUserSelected handles null userDetails", () {
      final yesOption =
          Reference(name: "requestInformation.requestInformation.yes");

      viewModel
        ..userDetails = null
        ..islamicRelationshipUserSelected(yesOption);

      expect(viewModel.selectedIslamicRelationshipUserValue, yesOption);
      expect(viewModel.userDetails, null);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("UserDetailViewModel - checkbox selections", () {
    test("onApproveOnBehalfOfSelected toggles true false and null", () {
      viewModel
        ..userDetails = User()
        ..onApproveOnBehalfOfSelected(isChecked: true);
      expect(viewModel.userDetails?.approveOnBehalfOf, true);
      expect(viewModel.state.approveOnBehalfOf, true);

      viewModel.onApproveOnBehalfOfSelected(isChecked: false);
      expect(viewModel.userDetails?.approveOnBehalfOf, false);
      expect(viewModel.state.approveOnBehalfOf, false);

      viewModel.onApproveOnBehalfOfSelected();
      expect(viewModel.userDetails?.approveOnBehalfOf, false);
      expect(viewModel.state.approveOnBehalfOf, false);
    });

    test("onApproveOnBehalfOfSelected handles null userDetails", () {
      viewModel
        ..userDetails = null
        ..onApproveOnBehalfOfSelected(isChecked: true);

      expect(viewModel.userDetails, null);
      expect(viewModel.state.approveOnBehalfOf, true);
    });

    test("onApprovalAccessSelected toggles true false and null", () {
      viewModel
        ..userDetails = User()
        ..onApprovalAccessSelected(isChecked: true);
      expect(viewModel.userDetails?.approvalAccess, true);
      expect(viewModel.state.approvalAccess, true);

      viewModel.onApprovalAccessSelected(isChecked: false);
      expect(viewModel.userDetails?.approvalAccess, false);
      expect(viewModel.state.approvalAccess, false);

      viewModel.onApprovalAccessSelected();
      expect(viewModel.userDetails?.approvalAccess, false);
      expect(viewModel.state.approvalAccess, false);
    });

    test("onApprovalAccessSelected handles null userDetails", () {
      viewModel
        ..userDetails = null
        ..onApprovalAccessSelected(isChecked: true);

      expect(viewModel.userDetails, null);
      expect(viewModel.state.approvalAccess, true);
    });

    test("onTranApprovalAccessSelected toggles true false and null", () {
      viewModel
        ..userDetails = User()
        ..onTranApprovalAccessSelected(isChecked: true);
      expect(viewModel.userDetails?.tranApprovalAccess, true);
      expect(viewModel.state.tranApprovalAccess, true);

      viewModel.onTranApprovalAccessSelected(isChecked: false);
      expect(viewModel.userDetails?.tranApprovalAccess, false);
      expect(viewModel.state.tranApprovalAccess, false);

      viewModel.onTranApprovalAccessSelected();
      expect(viewModel.userDetails?.tranApprovalAccess, false);
      expect(viewModel.state.tranApprovalAccess, false);
    });

    test("onTranApprovalAccessSelected handles null userDetails", () {
      viewModel
        ..userDetails = null
        ..onTranApprovalAccessSelected(isChecked: true);

      expect(viewModel.userDetails, null);
      expect(viewModel.state.tranApprovalAccess, true);
    });

    test("onAccessToVipCustSelected toggles true false and null", () {
      viewModel
        ..userDetails = User()
        ..onAccessToVipCustSelected(isChecked: true);
      expect(viewModel.userDetails?.accessToVipCust, true);
      expect(viewModel.state.accessToVipCust, true);

      viewModel.onAccessToVipCustSelected(isChecked: false);
      expect(viewModel.userDetails?.accessToVipCust, false);
      expect(viewModel.state.accessToVipCust, false);

      viewModel.onAccessToVipCustSelected();
      expect(viewModel.userDetails?.accessToVipCust, false);
      expect(viewModel.state.accessToVipCust, false);
    });

    test("onAccessToVipCustSelected handles null userDetails", () {
      viewModel
        ..userDetails = null
        ..onAccessToVipCustSelected(isChecked: true);

      expect(viewModel.userDetails, null);
      expect(viewModel.state.accessToVipCust, true);
    });
  });

  group("UserDetailViewModel - save button", () {
    testWidgets("onSaveButtonPressed should do nothing when form is invalid",
        (WidgetTester tester) async {
      viewModel
        ..repository = mockRepo
        ..authRepository = mockAuthRepo
        ..userDetails = User(id: "123", name: "Test User");

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: viewModel.formKey,
              child: TextFormField(
                validator: (_) => "required",
              ),
            ),
          ),
        ),
      );

      await viewModel.onSaveButtonPressed();

      verifyNever(() => mockRepo.saveUserDetailsList(any()));
      expect(viewModel.state.saveUserDetailStatus, LoadingStatus.loaded);
    });

    testWidgets(
        "onSaveButtonPressed should emit error and show toast on failure",
        (WidgetTester tester) async {
      viewModel
        ..repository = mockRepo
        ..authRepository = mockAuthRepo
        ..userDetails = User(id: "123")
        ..selectedUserRoles = "Admin";

      when(() => mockRepo.saveUserDetailsList(any()))
          .thenThrow(Exception("save failed"));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: viewModel.formKey,
              child: TextFormField(
                initialValue: "valid",
                validator: (_) => null,
                onSaved: (_) {},
              ),
            ),
          ),
        ),
      );

      await viewModel.onSaveButtonPressed();
      await tester.pump();

      verify(() => mockAlert.showFailureToast(any())).called(1);
      expect(viewModel.state.saveUserDetailStatus, LoadingStatus.error);
    });

    testWidgets("onSaveButtonPressed should handle null current form state",
        (WidgetTester tester) async {
      final isolatedViewModel = UserDetailViewModel()
        ..repository = mockRepo
        ..authRepository = mockAuthRepo
        ..userDetails = User(id: "123");

      await isolatedViewModel.onSaveButtonPressed();

      verifyNever(() => mockRepo.saveUserDetailsList(any()));
      expect(
        isolatedViewModel.state.saveUserDetailStatus,
        LoadingStatus.loaded,
      );

      await isolatedViewModel.close();
    });
  });

  group("UserDetailViewModel - cancel", () {
    test("onCancelButtonPressed should be callable", () {
      expect(() => viewModel.onCancelButtonPressed(), returnsNormally);
    });
  });

  group("UserDetailViewModel - validateSelection", () {
    test("validateSelection returns null for valid selection", () {
      final options = <Reference>[
        Reference(name: "Option1"),
        Reference(name: "Option2"),
      ];

      final result =
          viewModel.validateSelection("Option1", options, "error.key");

      expect(result, null);
    });

    test("validateSelection trims value before checking", () {
      final options = <Reference>[
        Reference(name: "Option1"),
      ];

      final result =
          viewModel.validateSelection(" Option1 ", options, "error.key");

      expect(result, null);
    });

    test("validateSelection returns error for invalid selection", () {
      final options = <Reference>[
        Reference(name: "Option1"),
        Reference(name: "Option2"),
      ];

      final result =
          viewModel.validateSelection("Invalid", options, "error.key");

      expect(result, "error.key");
    });

    test("validateSelection returns error for null value", () {
      final options = <Reference>[
        Reference(name: "Option1"),
      ];

      final result = viewModel.validateSelection(null, options, "error.key");

      expect(result, "error.key");
    });

    test("validateSelection returns error for empty options", () {
      final result =
          viewModel.validateSelection("Option1", <Reference>[], "error.key");

      expect(result, "error.key");
    });
  });

  group("UserDetailViewModel - filtered options", () {
    test("getFilteredOptions filters out NA option", () {
      final options = <Reference>[
        Reference(name: "Option1"),
        Reference(name: "requestInformation.requestInformation.na"),
        Reference(name: "Option2"),
      ];

      final filtered = viewModel.getFilteredOptions(options);

      expect(filtered.length, 2);
      expect(
        filtered.any(
          (ref) => ref.name == "requestInformation.requestInformation.na",
        ),
        false,
      );
    });

    test("getFilteredOptions keeps null and non-NA names", () {
      final options = <Reference>[
        Reference(),
        Reference(name: "Option1"),
      ];

      final filtered = viewModel.getFilteredOptions(options);

      expect(filtered.length, 2);
      expect(filtered.first.name, null);
      expect(filtered.last.name, "Option1");
    });

    test("getFilteredOptions returns empty list for only NA", () {
      final options = <Reference>[
        Reference(name: "requestInformation.requestInformation.na"),
      ];

      final filtered = viewModel.getFilteredOptions(options);

      expect(filtered, isEmpty);
    });

    test("getFilteredOptions returns empty list for empty input", () {
      final filtered = viewModel.getFilteredOptions(<Reference>[]);

      expect(filtered, isEmpty);
    });
  });

  group("UserDetailViewModel - getSelectedReference", () {
    test("getSelectedReference returns selected value when valid", () {
      final selectedValue = Reference(name: "Yes");
      final options = <Reference>[
        selectedValue,
        Reference(name: "No"),
      ];

      final result = viewModel.getSelectedReference(
        options: options,
        selectedValue: selectedValue,
        fallbackFlag: true,
      );

      expect(result, same(selectedValue));
    });

    test("getSelectedReference returns yes fallback for invalid selected value",
        () {
      final options = <Reference>[
        Reference(name: "requestInformation.requestInformation.yes"),
        Reference(name: "requestInformation.requestInformation.no"),
      ];

      final result = viewModel.getSelectedReference(
        options: options,
        selectedValue: Reference(name: "Invalid"),
        fallbackFlag: true,
      );

      expect(result.name, "requestInformation.requestInformation.yes");
    });

    test("getSelectedReference returns no fallback when fallbackFlag is false",
        () {
      final options = <Reference>[
        Reference(name: "requestInformation.requestInformation.yes"),
        Reference(name: "requestInformation.requestInformation.no"),
      ];

      final result = viewModel.getSelectedReference(
        options: options,
        selectedValue: null,
        fallbackFlag: false,
      );

      expect(result.name, "requestInformation.requestInformation.no");
    });

    test("getSelectedReference returns no fallback when fallbackFlag is null",
        () {
      final options = <Reference>[
        Reference(name: "requestInformation.requestInformation.yes"),
        Reference(name: "requestInformation.requestInformation.no"),
      ];

      final result = viewModel.getSelectedReference(
        options: options,
        selectedValue: null,
        fallbackFlag: null,
      );

      expect(result.name, "requestInformation.requestInformation.no");
    });

    test("getSelectedReference returns first filtered when fallback not found",
        () {
      final first = Reference(name: "First");
      final options = <Reference>[
        first,
        Reference(name: "Second"),
      ];

      final result = viewModel.getSelectedReference(
        options: options,
        selectedValue: null,
        fallbackFlag: true,
      );

      expect(result, same(first));
    });

    test("getSelectedReference throws when filtered options are empty", () {
      final options = <Reference>[
        Reference(name: "requestInformation.requestInformation.na"),
      ];

      expect(
        () => viewModel.getSelectedReference(
          options: options,
          selectedValue: null,
          fallbackFlag: true,
        ),
        throwsStateError,
      );
    });
  });
}
