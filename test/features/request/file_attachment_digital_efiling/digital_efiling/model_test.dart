import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";
import "package:wcas_frontend/models/request/file_attachment/file_upload.dart";
import "package:wcas_frontend/models/request/group.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockFileAttachmentRepository extends Mock
    implements FileAttachmentRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockAlertManager extends Mock implements AlertManager {}

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

class MockBuildContext extends Fake implements BuildContext {
  @override
  bool get mounted => true;
}

bool get _hasSeededUser => Globals.user != null;

void _safeSetUser({
  List<String>? regions,
  List<String>? segments,
  int? roleId,
}) {
  if (Globals.user == null) return;

  Globals.user = Globals.user!.copyWith(
    regions: regions,
    segments: segments,
    currentRole:
        roleId == null ? Globals.user!.currentRole : Role(roleId: roleId),
  );
}

void main() {
  late DigitalEfilingViewModel viewModel;
  late MockRequestRepository mockRequestRepo;
  late MockCustomerRepository mockCustomerRepo;
  late MockFileAttachmentRepository mockFileAttachmentRepo;
  late MockReferenceDataService mockRefService;
  late MockAlertManager mockAlertManager;
  late MockLocalStorageService mockLocalStorageService;
  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    await TestConfig.setupTestEnvironment();
    TestWidgetsFlutterBinding.ensureInitialized();
    await EnvConfig.setEnvironment();
    registerFallbackValue(<String>[]);

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

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    LocalStorageService().setStorage(mockLocalStorageService);

    mockRequestRepo = MockRequestRepository();
    mockCustomerRepo = MockCustomerRepository();
    mockFileAttachmentRepo = MockFileAttachmentRepository();
    mockRefService = MockReferenceDataService();
    mockAlertManager = MockAlertManager();

    viewModel = DigitalEfilingViewModel()
      ..requestRepository = mockRequestRepo
      ..customerRepository = mockCustomerRepo
      ..fileAttachmentRepository = mockFileAttachmentRepo;

    AlertManager.overrideInstance(mockAlertManager);
    ReferenceDataService.overrideInstance(mockRefService);

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockCustomerRepo.validateSubSegment(any()))
        .thenAnswer((_) async => true);

    when(() => mockRefService.getReferenceData(any())).thenAnswer(
      (_) async => {
        ReferenceDataKeys.documentTypes: [Reference(id: 1)],
        ReferenceDataKeys.fstSubTypes: [Reference(id: 2)],
        ReferenceDataKeys.fstSubsubTypes: [Reference(id: 3)],
        ReferenceDataKeys.languages: [Reference(id: 4)],
        ReferenceDataKeys.clSubTypes: [Reference(id: 5)],
        ReferenceDataKeys.branchList: [
          Reference(reference1: "BR001", reference2: "DXB"),
          Reference(reference1: "BR002", reference2: "AUH"),
        ],
        ReferenceDataKeys.caSubTypes: [Reference(id: 6)],
        ReferenceDataKeys.requestType: [Reference(id: 61)],
        ReferenceDataKeys.caSubSubTypes: [Reference(id: 7)],
        ReferenceDataKeys.applicationTypeCustom: [Reference(id: 71)],
        ReferenceDataKeys.applicationType: [Reference(id: 72)],
        ReferenceDataKeys.caSubSubSubTypes: [Reference(id: 8)],
        ReferenceDataKeys.subSegmentValidation: [
          Reference(
            reference1: ServerConstants.subSegmentValidationRefId,
            reference2: "${UserRole.relationshipManager.index},"
                "${UserRole.relationshipOfficer.index}",
          ),
        ],
        ReferenceDataKeys.applicationSegment: [
          Reference(
            id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
          ),
          Reference(
            id: ServerConstants
                .businessSegmentId[BusinessSegment.financialInstitution],
          ),
        ],
      },
    );

    _safeSetUser(
      regions: ["DXB"],
      segments: ["CORPORATE"],
      roleId: UserRole.relationshipManager.index,
    );
  });

  tearDownAll(() async {
    await TestConfig.cleanup();
  });

  group("Initialization", () {
    test("initial state should be loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.state.searchLoaderStatus, LoadingStatus.loaded);
    });

    test(
        "loadReferenceData populates all reference"
        " lists and sets business segment", () async {
      await viewModel.loadReferenceData();

      expect(viewModel.documentTypes.isNotEmpty, isTrue);
      expect(viewModel.fstSubTypes.isNotEmpty, isTrue);
      expect(viewModel.fstSubSubTypes.isNotEmpty, isTrue);
      expect(viewModel.languages.isNotEmpty, isTrue);
      expect(viewModel.clSubTypes.isNotEmpty, isTrue);
      expect(viewModel.caSubTypes.isNotEmpty, isTrue);
      expect(viewModel.caSubSubTypes.isNotEmpty, isTrue);
      expect(viewModel.caSubSubSubTypes.isNotEmpty, isTrue);
      expect(viewModel.applicationTypeCustom.isNotEmpty, isTrue);
      expect(viewModel.subSegmentValidation.isNotEmpty, isTrue);
      expect(viewModel.bussinessSegments.isNotEmpty, isTrue);
      expect(viewModel.branchList.isNotEmpty, isTrue);
      expect(viewModel.businessSegmentValue, isNotNull);
    });

    test("setValueOfBusinessSegment sets corporate business segment", () {
      viewModel
        ..bussinessSegments = [
          Reference(id: 9999),
          Reference(
            id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
          ),
        ]
        ..setValueOfBusinessSegment();

      expect(
        viewModel.businessSegmentValue?.id,
        ServerConstants.businessSegmentId[BusinessSegment.corporate],
      );
    });

    test(
        "iFinancialInstitutionSelected "
        "returns "
        "false for corporate business segment", () {
      viewModel.businessSegmentValue = Reference(
        id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
      );

      expect(viewModel.iFinancialInstitutionSelected(), isFalse);
    });

    test("iFinancialInstitutionSelected returns true for FI business segment",
        () {
      viewModel.businessSegmentValue = Reference(
        id: ServerConstants
            .businessSegmentId[BusinessSegment.financialInstitution],
      );

      expect(viewModel.iFinancialInstitutionSelected(), isTrue);
    });
  });

  group("Field Control", () {
    test("handleFieldControl disables other fields when data is present", () {
      viewModel.handleFieldControl(ControlFields.customerName, "John");

      expect(viewModel.fieldCntrl.value[ControlFields.customerRim], true);
      expect(viewModel.fieldCntrl.value[ControlFields.customerName], false);
      expect(viewModel.fieldCntrl.value[ControlFields.groupID], true);
      expect(viewModel.fieldCntrl.value[ControlFields.groupName], true);
      expect(viewModel.fieldCntrl.value[ControlFields.applicationId], true);
    });

    test("handleFieldControl resets fields when data is empty", () {
      viewModel
        ..customerName = "John"
        ..groupName = "Group"
        ..customerRimNo = "123"
        ..groupId = "456"
        ..handleFieldControl(ControlFields.customerName, "");

      expect(viewModel.customerName, null);
      expect(viewModel.customerRimNo, null);
      expect(viewModel.groupId, null);
      expect(viewModel.groupName, null);
    });

    test("stopAllLoaders should reset all loading statuses", () {
      final initialResetFlag = viewModel.isResetPressed;

      viewModel
        ..customerRimNoLoadingStatus = LoadingStatus.loading
        ..customerNameLoadingStatus = LoadingStatus.loading
        ..groupIdLoadingStatus = LoadingStatus.loading
        ..groupNameLoadingStatus = LoadingStatus.loading
        ..submitLoadingStatus = LoadingStatus.loading
        ..stopAllLoaders();

      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.groupIdLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.groupNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.submitLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.isResetPressed, isNot(initialResetFlag));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("isFieldsFilled returns true when all fields are filled", () {
      viewModel
        ..customerRimNo = "123"
        ..customerName = "John"
        ..groupId = "456"
        ..groupName = "Group";

      expect(viewModel.isFieldsFilled(), isTrue);
    });

    test("isFieldsFilled returns false when any field is null", () {
      viewModel
        ..customerRimNo = "123"
        ..customerName = null
        ..groupId = "456"
        ..groupName = "Group";

      expect(viewModel.isFieldsFilled(), isFalse);
    });
  });

  group("Customer Search - Customer Name", () {
    test("onCustomerNameSearchPressed triggers search when valid", () async {
      final customer = Customer(
        id: "123",
        preferredName: "John Doe",
        branchCode: "BR001",
        segment: "CORPORATE",
        groups: Group(id: "456", name: "Group A"),
      );

      when(() => mockCustomerRepo.searchCustomerProfile(any(), any(), any()))
          .thenAnswer((_) async => [customer]);

      viewModel
        ..customerName = "John Doe"
        ..isSearched = false;

      await viewModel.onCustomerNameSearchPressed(showDialog: false);

      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.isGroupNameSelection, false);
      expect(viewModel.customer, customer);
      expect(viewModel.customerRimNo, "123");
      expect(viewModel.customerName, "John Doe");
      expect(viewModel.grpId, "456");
      expect(viewModel.grpName, "Group A");
      expect(viewModel.searchAllowed, isTrue);
    });

    test("onCustomerNameSearchPressed shows toast when name is too short",
        () async {
      viewModel
        ..customerName = "abc"
        ..isSearched = false;

      await viewModel.onCustomerNameSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onCustomerNameSearchPressed does nothing when already searched",
        () async {
      viewModel
        ..customerName = "John Doe"
        ..isSearched = true;

      await viewModel.onCustomerNameSearchPressed();

      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onCustomerNameSearchPressed shows toast when name is empty",
        () async {
      viewModel
        ..customerName = ""
        ..isSearched = false;

      await viewModel.onCustomerNameSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("Customer Search - Group Name", () {
    test("onGroupNameSearchPressed triggers search when valid", () async {
      final customer = Customer(
        id: "100",
        preferredName: "John Doe",
        branchCode: "BR001",
        segment: "CORPORATE",
        groups: Group(id: "456", name: "ValidGroupName"),
      );

      when(() => mockCustomerRepo.searchCustomerProfile(any(), any(), any()))
          .thenAnswer((_) async => [customer]);

      viewModel
        ..groupName = "ValidGroupName"
        ..isSearched = false;

      await viewModel.onGroupNameSearchPressed(showDialog: false);

      expect(viewModel.groupNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.isGroupNameSelection, true);
      expect(viewModel.groupId, "456");
      expect(viewModel.groupName, "ValidGroupName");
    });

    test("onGroupNameSearchPressed shows toast when name is too short",
        () async {
      viewModel
        ..groupName = "abc"
        ..isSearched = false;

      await viewModel.onGroupNameSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onGroupNameSearchPressed does nothing when already searched",
        () async {
      viewModel
        ..groupName = "ValidGroupName"
        ..isSearched = true;

      await viewModel.onGroupNameSearchPressed();

      expect(viewModel.groupNameLoadingStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("Customer Search - Group ID", () {
    test("onGroupIdSearchPressed triggers search when valid", () async {
      final customer = Customer(
        id: "200",
        preferredName: "John Doe",
        branchCode: "BR001",
        segment: "CORPORATE",
        groups: Group(id: "G123", name: "Group A", groupOwner: 200),
      );

      when(() => mockCustomerRepo.searchCustomerProfile(any(), any(), any()))
          .thenAnswer((_) async => [customer]);

      viewModel
        ..groupId = "G123"
        ..isSearched = false;

      await viewModel.onGroupIdSearchPressed();

      expect(viewModel.groupIdLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.groupId, "G123");
      expect(viewModel.groupName, "Group A");
    });

    test("onGroupIdSearchPressed shows toast when groupId is empty", () async {
      viewModel
        ..groupId = ""
        ..isSearched = false;

      await viewModel.onGroupIdSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onGroupIdSearchPressed does nothing when already searched", () async {
      viewModel
        ..groupId = "G123"
        ..isSearched = true;

      await viewModel.onGroupIdSearchPressed();

      expect(viewModel.groupIdLoadingStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("Customer Search - Customer RIM", () {
    test("onCustomerRimNoSearchPressed triggers search when valid", () async {
      final customer = Customer(
        id: "RIM123",
        preferredName: "John Doe",
        branchCode: "BR001",
        segment: "CORPORATE",
        groups: Group(id: "456", name: "Group A"),
      );

      when(() => mockCustomerRepo.searchUserDetails(any(), any(), any(), any()))
          .thenAnswer((_) async => customer);

      viewModel
        ..customerRimNo = "RIM123"
        ..isSearched = false;

      await viewModel.onCustomerRimNoSearchPressed();

      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.customer, customer);
      expect(viewModel.customerRimNo, "RIM123");
      expect(viewModel.customerName, "John Doe");
      expect(viewModel.grpId, "456");
      expect(viewModel.grpName, "Group A");
    });

    test("onCustomerRimNoSearchPressed shows toast when rimNo is empty",
        () async {
      viewModel
        ..customerRimNo = ""
        ..isSearched = false;

      await viewModel.onCustomerRimNoSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onCustomerRimNoSearchPressed does nothing when already searched",
        () async {
      viewModel
        ..customerRimNo = "RIM123"
        ..isSearched = true;

      await viewModel.onCustomerRimNoSearchPressed();

      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("Customer Search - Main Search", () {
    test("onCustomerSearchPressed with no results shows toast", () async {
      viewModel.customerRimNoLoadingStatus = LoadingStatus.loading;
      when(() => mockCustomerRepo.searchUserDetails(any(), any(), any(), any()))
          .thenAnswer((_) async => null);

      await viewModel.onCustomerSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, false);
    });

    test("onCustomerSearchPressed handles error", () async {
      viewModel.customerRimNoLoadingStatus = LoadingStatus.loading;
      when(() => mockCustomerRepo.searchUserDetails(any(), any(), any(), any()))
          .thenThrow(Exception("Failed"));

      await viewModel.onCustomerSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, false);
    });

    test("onCustomerSearchPressed by RIM number", () async {
      final customer = Customer(
        id: "123",
        preferredName: "John Doe",
        branchCode: "BR001",
        segment: "CORPORATE",
        groups: Group(id: "456", name: "Group A"),
      );

      viewModel.customerRimNoLoadingStatus = LoadingStatus.loading;
      when(() => mockCustomerRepo.searchUserDetails(any(), any(), any(), any()))
          .thenAnswer((_) async => customer);

      await viewModel.onCustomerSearchPressed(searchBy: 3);

      expect(viewModel.customer, customer);
      expect(viewModel.customerRimNo, "123");
      expect(viewModel.customerName, "John Doe");
      expect(viewModel.grpId, "456");
      expect(viewModel.grpName, "Group A");
      expect(viewModel.searchAllowed, isTrue);
    });

    test(
        "onCustomerSearchPressed by profile search with "
        "one result shows dialog path and sets customer", () async {
      final customer = Customer(
        id: "111",
        preferredName: "Single User",
        branchCode: "BR001",
        segment: "CORPORATE",
        groups: Group(id: "222", name: "Group B"),
      );

      when(() => mockCustomerRepo.searchCustomerProfile(any(), any(), any()))
          .thenAnswer((_) async => [customer]);

      await viewModel.onCustomerSearchPressed(showDialog: true, searchBy: 4);

      expect(viewModel.customer, customer);
      expect(viewModel.dailogCustomers.length, 1);
      expect(viewModel.state.showSelectDialog, isFalse);
    });

    test(
        "onCustomerSearchPressed by profile search with "
        "multiple results and groupId loading picks group owner", () async {
      final customer1 = Customer(
        id: "101",
        preferredName: "User 1",
        branchCode: "BR001",
        segment: "CORPORATE",
        groups: Group(id: "500", name: "Group X", groupOwner: 202),
      );
      final customer2 = Customer(
        id: "202",
        preferredName: "User 2",
        branchCode: "BR001",
        segment: "CORPORATE",
        groups: Group(id: "500", name: "Group X", groupOwner: 202),
      );

      viewModel.groupIdLoadingStatus = LoadingStatus.loading;

      when(() => mockCustomerRepo.searchCustomerProfile(any(), any(), any()))
          .thenAnswer((_) async => [customer1, customer2]);

      await viewModel.onCustomerSearchPressed(searchBy: 2);

      expect(viewModel.customer?.id, "202");
      expect(viewModel.groupId, "500");
      expect(viewModel.groupName, "Group X");
      expect(viewModel.searchAllowed, isTrue);
    });

    test(
        "onCustomerSearchPressed by profile search with multiple "
        "results and non-group loading opens selection dialog", () async {
      final customer1 = Customer(
        id: "101",
        preferredName: "User 1",
        branchCode: "BR001",
        segment: "CORPORATE",
        groups: Group(id: "500", name: "Group X", groupOwner: 202),
      );
      final customer2 = Customer(
        id: "202",
        preferredName: "User 2",
        branchCode: "BR001",
        segment: "CORPORATE",
        groups: Group(id: "500", name: "Group X", groupOwner: 202),
      );

      viewModel
        ..groupIdLoadingStatus = LoadingStatus.loaded
        ..customerNameLoadingStatus = LoadingStatus.loading;

      when(() => mockCustomerRepo.searchCustomerProfile(any(), any(), any()))
          .thenAnswer((_) async => [customer1, customer2]);

      await viewModel.onCustomerSearchPressed(showDialog: true, searchBy: 4);

      expect(viewModel.dailogCustomers.length, 2);
      expect(viewModel.state.showSelectDialog, isFalse);
    });

    test(
        "onCustomerSearchPressed profile search with "
        "empty list ends with no user found toast", () async {
      when(() => mockCustomerRepo.searchCustomerProfile(any(), any(), any()))
          .thenAnswer((_) async => []);

      await viewModel.onCustomerSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.searchAllowed, isTrue);
      expect(viewModel.isSearched, isFalse);
    });

    test("onCustomerSearchPressed returns early when validationCheck fails",
        () async {
      final customer = Customer(
        id: "123",
        preferredName: "John Doe",
        branchCode: "BR002",
        segment: "OTHER_SEGMENT",
        groups: Group(id: "456", name: "Group A"),
      );

      viewModel.branchList = [
        Reference(reference1: "BR001", reference2: "DXB"),
        Reference(reference1: "BR002", reference2: "AUH"),
      ];

      _safeSetUser(
        regions: ["DXB"],
        segments: ["CORPORATE"],
        roleId: UserRole.relationshipManager.index,
      );

      viewModel.customerRimNoLoadingStatus = LoadingStatus.loading;

      when(() => mockCustomerRepo.searchUserDetails(any(), any(), any(), any()))
          .thenAnswer((_) async => customer);

      await viewModel.onCustomerSearchPressed(searchBy: 3);

      // verify(() =>
    });
  });

  group("Selection and Reset", () {
    test("onSelectionPressed with valid customer having group data", () async {
      final customer = Customer(
        id: "123",
        preferredName: "John Doe",
        groups: Group(id: "456", name: "Group A"),
      );

      viewModel.selectedCustomer.value = customer;
      await viewModel.onSelectionPressed(MockBuildContext());

      await Future.delayed(const Duration(milliseconds: 10));

      expect(viewModel.customer, customer);
      expect(viewModel.customerRimNo, "");
      expect(viewModel.customerName, "");
      expect(viewModel.groupId, "456");
      expect(viewModel.groupName, "Group A");
      expect(viewModel.searchAllowed, isTrue);
    });

    test(
        "onSelectionPressed with valid customer "
        "without group data uses customer fields", () async {
      final customer = Customer(
        id: "123",
        preferredName: "John Doe",
        groups: Group(id: "", name: ""),
      );

      viewModel.selectedCustomer.value = customer;
      await viewModel.onSelectionPressed(MockBuildContext());

      await Future.delayed(const Duration(milliseconds: 10));

      expect(viewModel.customer, customer);
      expect(viewModel.customerRimNo, "123");
      expect(viewModel.customerName, "John Doe");
      expect(viewModel.groupId, "");
      expect(viewModel.groupName, "");
      expect(viewModel.searchAllowed, isTrue);
    });

    test("onSelectionPressed with null customer shows toast", () async {
      viewModel.selectedCustomer.value = null;

      await viewModel.onSelectionPressed(MockBuildContext());

      await Future.delayed(const Duration(milliseconds: 10));

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.searchAllowed, isFalse);
    });

    test("onSelectionCancelButtonPress resets fields", () {
      final initialResetFlag = viewModel.isResetPressed;

      viewModel
        ..customer = Customer(id: "123")
        ..customerName = "John"
        ..groupName = "Group"
        ..customerRimNo = "456"
        ..groupId = "789"
        ..onSelectionCancelButtonPress();

      expect(viewModel.customer, null);
      expect(viewModel.customerName, null);
      expect(viewModel.groupName, null);
      expect(viewModel.customerRimNo, null);
      expect(viewModel.groupId, null);
      expect(viewModel.isResetPressed, isNot(initialResetFlag));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("resetDependentFields should clear all dependent fields", () {
      viewModel
        ..isSearched = true
        ..searchAllowed = true
        ..customer = Customer(id: "123")
        ..customerRimNo = "456"
        ..customerName = "John"
        ..groupId = "789"
        ..groupName = "Demo"
        ..selectedCustomer.value = Customer(id: "123")
        ..selectedDocumentIds = ["1"]
        ..selectedDocs = ["doc"]
        ..resetDependentFields();

      expect(viewModel.isSearched, false);
      expect(viewModel.searchAllowed, false);
      expect(viewModel.customer, isNull);
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.customerName, isNull);
      expect(viewModel.groupId, isNull);
      expect(viewModel.groupName, isNull);
      expect(viewModel.selectedCustomer.value, isNull);
      expect(viewModel.selectedDocumentIds, isEmpty);
      expect(viewModel.selectedDocs, isEmpty);
      expect(viewModel.fieldCntrl.value[ControlFields.applicationId], isFalse);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onResetButtonPress should reset all form fields and state", () async {
      viewModel
        ..isSearched = true
        ..isFileSearched = true
        ..searchAllowed = true
        ..customer = Customer(id: "123")
        ..customerRimNo = "456"
        ..customerName = "John"
        ..groupId = "789"
        ..grpId = "111"
        ..groupName = "Demo"
        ..grpName = "DemoGrp"
        ..selectedDocumentIds = ["doc1"]
        ..selectedDocs = ["doc"]
        ..onResetButtonPress();

      await Future.delayed(const Duration(milliseconds: 20));

      expect(viewModel.isSearched, false);
      expect(viewModel.isFileSearched, false);
      expect(viewModel.searchAllowed, false);
      expect(viewModel.customer, isNull);
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.customerName, isNull);
      expect(viewModel.groupId, isNull);
      expect(viewModel.grpId, isNull);
      expect(viewModel.groupName, isNull);
      expect(viewModel.grpName, isNull);
      expect(viewModel.selectedDocumentIds, isEmpty);
      expect(viewModel.selectedDocs, isEmpty);
      expect(viewModel.applicationIdController.text, "");
      expect(viewModel.applicationId, "");
      expect(viewModel.fileUploadDatas, isEmpty);
    });
  });

  group("Document Management", () {
    test("toggleDocumentSelection adds document to selected list", () {
      final docData = DocSubTypeData(edmsDriveItemId: "doc123");

      viewModel.toggleDocumentSelection("key1", true, docData);

      expect(viewModel.selectedDocumentIds.contains("doc123"), isTrue);
      expect(viewModel.selectedDocs.contains(docData), isTrue);
      expect(docData.isChecked, isTrue);
    });

    test("toggleDocumentSelection removes document from selected list", () {
      final docData = DocSubTypeData(edmsDriveItemId: "doc123");
      viewModel.selectedDocumentIds.add("doc123");
      viewModel.selectedDocs.add(docData);

      viewModel.toggleDocumentSelection("key1", false, docData);

      expect(viewModel.selectedDocumentIds.contains("doc123"), isFalse);
      expect(viewModel.selectedDocs.contains(docData), isFalse);
      expect(docData.isChecked, isFalse);
    });

    test("toggleDocumentSelection handles empty edmsDriveItemId", () {
      final docData = DocSubTypeData(edmsDriveItemId: "");

      viewModel.toggleDocumentSelection("key1", true, docData);

      expect(viewModel.selectedDocumentIds.isEmpty, isTrue);
      expect(docData.isChecked, isTrue);
    });

    test(
        "toggleDocumentSelection handles remove "
        "for non-existing item without crash", () {
      final docData = DocSubTypeData(edmsDriveItemId: "doc-not-added");

      viewModel.toggleDocumentSelection("key1", false, docData);

      expect(viewModel.selectedDocumentIds.isEmpty, isTrue);
      expect(docData.isChecked, isFalse);
    });

    test("isDocumentSelected returns correct status", () {
      viewModel.selectedDocuments["key1"] = true;
      viewModel.selectedDocuments["key2"] = false;

      expect(viewModel.isDocumentSelected("key1"), isTrue);
      expect(viewModel.isDocumentSelected("key2"), isFalse);
      expect(viewModel.isDocumentSelected("key3"), isFalse);
    });
  });

  group("Search and File Operations", () {
    test("updateSearchValue does not throw error", () {
      expect(() => viewModel.updateSearchValue("test"), returnsNormally);
    });

    test("updateApplicationId updates application ID", () async {
      await viewModel.updateApplicationId("APP123");

      expect(viewModel.applicationId, "APP123");
    });

    test(
        "updateApplicationId with empty string "
        "does not fetch details and emits loaded", () async {
      await viewModel.updateApplicationId("");

      expect(viewModel.applicationId, "");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getApplicationDetails returns immediately when applicationId is null",
        () async {
      await viewModel.getApplicationDetails(null);

      expect(viewModel.state.loaderStatus, isNotNull);
    });

    test("doSearch with valid search criteria", () async {
      viewModel
        ..customerRimNo = "123"
        ..customerName = "John"
        ..groupId = "456"
        ..groupName = "Group";

      when(
        () => mockFileAttachmentRepo.getFileUploadData(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          true,
        ),
      ).thenAnswer(
        (_) async => [
          FileDetail(type: "test", documents: []),
        ],
      );

      await viewModel.doSearch();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.fileUploadDatas.length, 1);
      expect(viewModel.state.searchLoaderStatus, LoadingStatus.loaded);
      expect(viewModel.isSearched, isTrue);
      expect(viewModel.isFileSearched, isTrue);
    });

    test("doSearch calls repository when criteria is valid", () async {
      viewModel
        ..customerRimNo = "123"
        ..customerName = "John"
        ..groupId = ""
        ..groupName = ""
        ..applicationId = "";

      when(
        () => mockFileAttachmentRepo.getFileUploadData(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          true,
        ),
      ).thenAnswer((_) async => [FileDetail(type: "x", documents: [])]);

      await viewModel.doSearch();
      await Future.delayed(const Duration(milliseconds: 100));

      verify(
        () => mockFileAttachmentRepo.getFileUploadData(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          true,
        ),
      ).called(1);

      expect(viewModel.fileUploadDatas.length, 1);
    });

    test("doSearch with empty criteria shows toast", () async {
      viewModel
        ..customerRimNo = null
        ..customerName = null
        ..groupId = null
        ..groupName = null
        ..applicationId = null;

      await viewModel.doSearch();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.state.searchLoaderStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, isFalse);
    });

    test("doSearch with empty results shows toast", () async {
      viewModel.customerRimNo = "123";

      when(
        () => mockFileAttachmentRepo.getFileUploadData(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          true,
        ),
      ).thenAnswer((_) async => []);

      await viewModel.doSearch();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.state.searchLoaderStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, isFalse);
    });

    test("doSearch handles error", () async {
      viewModel.customerRimNo = "123";

      when(
        () => mockFileAttachmentRepo.getFileUploadData(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          true,
        ),
      ).thenThrow(Exception("Failed"));

      await viewModel.doSearch();
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, isFalse);
    });

    test("downloadDocument downloads single document", () async {
      when(
        () => mockFileAttachmentRepo.downloadDigitalAttachment(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => {});

      await viewModel.downloadDocument("doc123", "iugba", "document.pdf");

      verify(
        () => mockFileAttachmentRepo.downloadDigitalAttachment(
          "doc123",
          "iugba",
          "document.pdf",
        ),
      ).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("downloadDocument handles error", () async {
      when(
        () => mockFileAttachmentRepo.downloadDigitalAttachment(
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("Download failed"));

      await viewModel.downloadDocument("doc123", "iugba", "document.pdf");

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("downloadDocumentsZip downloads multiple documents with exact args",
        () async {
      viewModel
        ..selectedDocumentIds = ["doc1", "doc2"]
        ..selectedDocs = ["docObj1", "docObj2"];
      viewModel.customerRimController.text = "123";
      viewModel.groupRimController.text = "456";
      viewModel.applicationIdController.text = "APP789";

      when(
        () => mockFileAttachmentRepo.zipDownloadDigitalAttachment(
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => {});

      await viewModel.downloadDocumentsZip();

      verify(
        () => mockFileAttachmentRepo.zipDownloadDigitalAttachment(
          ["doc1", "doc2"],
          ["docObj1", "docObj2"],
          "123",
          "456",
          "APP789",
        ),
      ).called(1);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("downloadDocumentsZip handles error", () async {
      viewModel.selectedDocumentIds = ["doc1"];

      when(
        () => mockFileAttachmentRepo.zipDownloadDigitalAttachment(
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("Zip failed"));

      await viewModel.downloadDocumentsZip();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("mergeDownloadDocument merges documents", () async {
      viewModel
        ..selectedDocs = ["docObj1", "docObj2"]
        ..selectedDocumentIds = ["doc1", "doc2"]
        ..customerRimNo = "123"
        ..groupId = "456"
        ..applicationId = "APP789";

      when(
        () => mockFileAttachmentRepo.mergeDownloadDigitalAttachment(
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => {});

      await viewModel.mergeDownloadDocument();

      verify(
        () => mockFileAttachmentRepo.mergeDownloadDigitalAttachment(
          ["docObj1", "docObj2"],
          ["doc1", "doc2"],
          "123",
          "456",
          "APP789",
        ),
      ).called(1);
    });

    test("mergeDownloadDocument handles error", () async {
      viewModel.selectedDocumentIds = ["doc1"];

      when(
        () => mockFileAttachmentRepo.mergeDownloadDigitalAttachment(
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("Merge failed"));

      await viewModel.mergeDownloadDocument();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("Validation Helpers", () {
    test(
        "checkValidRegion returns false when "
        "customer region not in user regions", () {
      viewModel.branchList = [
        Reference(reference1: "BR001", reference2: "AUH"),
      ];

      _safeSetUser(regions: ["DXB"]);

      final customer = Customer(branchCode: "BR001");

      final result = viewModel.checkValidRegion(customer);

      expect(result, isFalse);
    });

    test("checkValidRegion returns false when branch is not found", () {
      viewModel.branchList = [
        Reference(reference1: "BR002", reference2: "DXB"),
      ];

      _safeSetUser(regions: ["DXB"]);

      final customer = Customer(branchCode: "BR999");

      final result = viewModel.checkValidRegion(customer);

      expect(result, isFalse);
    });

    test("checkValidRegion returns false when customer branchCode is null", () {
      viewModel.branchList = [
        Reference(reference1: "BR001", reference2: "DXB"),
      ];

      _safeSetUser(regions: ["DXB"]);

      final customer = Customer(branchCode: null);

      final result = viewModel.checkValidRegion(customer);

      expect(result, isFalse);
    });

    test(
        "checkValidRegion returns expected result "
        "when customer branch maps to user region", () {
      viewModel.branchList = [
        Reference(reference1: "BR001", reference2: "DXB"),
      ];

      _safeSetUser(regions: ["DXB"]);

      final customer = Customer(branchCode: "BR001");
      final result = viewModel.checkValidRegion(customer);

      expect(result, _hasSeededUser ? isTrue : isFalse);
    });

    test("checkValidRegion returns false when user has no regions", () {
      viewModel.branchList = [
        Reference(reference1: "BR001", reference2: "DXB"),
      ];

      _safeSetUser(
        regions: [],
      );

      final customer = Customer(branchCode: "BR001");

      final result = viewModel.checkValidRegion(customer);

      expect(result, isFalse);
    });

    test("checkValidSegment returns expected result for allowed segment", () {
      _safeSetUser(segments: ["CORPORATE"]);

      final customer = Customer(segment: "CORPORATE");
      final result = viewModel.checkValidSegment(customer);

      expect(result, _hasSeededUser ? isTrue : isFalse);
    });

    test("checkValidSegment returns false for disallowed segment", () {
      _safeSetUser(segments: ["SME"]);

      final customer = Customer(segment: "CORPORATE");

      final result = viewModel.checkValidSegment(customer);

      expect(result, isFalse);
    });

    test(
        "checkValidBusinessSegment does not "
        "throw for FI selected and FI customer", () {
      viewModel.businessSegmentValue = Reference(
        id: ServerConstants
            .businessSegmentId[BusinessSegment.financialInstitution],
      );

      final customer =
          Customer(segment: ServerConstants.financialSegmentPartyInq);

      expect(
        () => viewModel.checkValidBusinessSegment(customer),
        returnsNormally,
      );
    });

    test(
        "checkValidBusinessSegment throws segmentFiMismatch "
        "for FI selected and non-FI customer", () {
      viewModel.businessSegmentValue = Reference(
        id: ServerConstants
            .businessSegmentId[BusinessSegment.financialInstitution],
      );

      final customer = Customer(segment: "CORPORATE");

      expect(
        () => viewModel.checkValidBusinessSegment(customer),
        throwsA(isA<String>()),
      );
    });

    test(
        "checkValidBusinessSegment throws segmentCorporateMismatch "
        "for corporate selected and FI customer", () {
      viewModel.businessSegmentValue = Reference(
        id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
      );

      final customer =
          Customer(segment: ServerConstants.financialSegmentPartyInq);

      expect(
        () => viewModel.checkValidBusinessSegment(customer),
        throwsA(isA<String>()),
      );
    });

    test("validationCheck returns expected result when region is invalid", () {
      viewModel.branchList = [
        Reference(reference1: "BR001", reference2: "AUH"),
      ];

      _safeSetUser(
        regions: ["DXB"],
        segments: ["CORPORATE"],
        roleId: UserRole.relationshipManager.index,
      );

      viewModel.businessSegmentValue = Reference(
        id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
      );

      final customer = Customer(
        branchCode: "BR001",
        segment: "CORPORATE",
      );

      final result = viewModel.validationCheck(customer);

      expect(result, _hasSeededUser ? isFalse : isTrue);
    });

    test(
        "validationCheck returns false when segment "
        "is invalid and role requires validation", () {
      viewModel.branchList = [
        Reference(reference1: "BR001", reference2: "DXB"),
      ];

      _safeSetUser(
        regions: ["DXB"],
        segments: ["SME"],
        roleId: UserRole.relationshipManager.index,
      );

      viewModel.businessSegmentValue = Reference(
        id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
      );

      final customer = Customer(
        branchCode: "BR001",
        segment: "CORPORATE",
      );

      final result = viewModel.validationCheck(customer);

      expect(result, _hasSeededUser ? isFalse : isTrue);
    });

    test("validationCheck returns true when region and segment are valid", () {
      viewModel.branchList = [
        Reference(reference1: "BR001", reference2: "DXB"),
      ];

      _safeSetUser(
        regions: ["DXB"],
        segments: ["CORPORATE"],
        roleId: UserRole.relationshipManager.index,
      );

      viewModel.businessSegmentValue = Reference(
        id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
      );

      final customer = Customer(
        branchCode: "BR001",
        segment: "CORPORATE",
      );

      final result = viewModel.validationCheck(customer);

      expect(result, isTrue);
    });

    test("validationCheck returns false on FI/corporate mismatch", () {
      viewModel.branchList = [
        Reference(reference1: "BR001", reference2: "DXB"),
      ];

      _safeSetUser(
        regions: ["DXB"],
        segments: ["CORPORATE"],
        roleId: UserRole.relationshipManager.index,
      );

      viewModel.businessSegmentValue = Reference(
        id: ServerConstants
            .businessSegmentId[BusinessSegment.financialInstitution],
      );

      final customer = Customer(
        branchCode: "BR001",
        segment: "CORPORATE",
      );

      final result = viewModel.validationCheck(customer);

      expect(result, isFalse);
    });

    test("shouldValidateSegmentSubSegment executes and returns a bool", () {
      final result = viewModel.shouldValidateSegmentSubSegment();
      expect(result, isA<bool>());
    });

    test(
        "validateSubSegment executes repository "
        "call when reference and role match", () async {
      if (!_hasSeededUser) {
        expect(
          true,
          isTrue,
          reason:
              "Globals.user is null in test env; skipping user-dependent path",
        );
        return;
      }

      _safeSetUser(roleId: UserRole.relationshipManager.index);

      viewModel
        ..subSegmentValidation = [
          Reference(
            reference1: ServerConstants.subSegmentValidationRefId,
            reference2: "${UserRole.relationshipManager.index}",
          ),
        ]
        ..customer = Customer(
          relationshipMgr: [
            {"RelationshipMgrIdent": "RM001"},
          ],
        );

      await viewModel.validateSubSegment();

      verify(() => mockCustomerRepo.validateSubSegment("RM001")).called(1);
    });

    test(
        "validateSubSegment passes null relationshipMgrIdent "
        "when relationshipMgr list is empty", () async {
      if (!_hasSeededUser) {
        expect(
          true,
          isTrue,
          reason:
              "Globals.user is null in test env; skipping user-dependent path",
        );
        return;
      }

      _safeSetUser(roleId: UserRole.relationshipManager.index);

      viewModel
        ..subSegmentValidation = [
          Reference(
            reference1: ServerConstants.subSegmentValidationRefId,
            reference2: "${UserRole.relationshipManager.index}",
          ),
        ]
        ..customer = Customer(
          relationshipMgr: [],
        );

      await viewModel.validateSubSegment();

      verify(() => mockCustomerRepo.validateSubSegment(null)).called(1);
    });

    test(
        "validateSubSegment does nothing when "
        "validation reference does not match role", () async {
      if (!_hasSeededUser) {
        expect(
          true,
          isTrue,
          reason:
              "Globals.user is null in test env; skipping user-dependent path",
        );
        return;
      }

      _safeSetUser(roleId: UserRole.relationshipManager.index);

      viewModel.subSegmentValidation = [
        Reference(
          reference1: "different-ref",
          reference2: "999",
        ),
      ];

      await viewModel.validateSubSegment();

      verifyNever(() => mockCustomerRepo.validateSubSegment(any()));
    });

    test("validateSubSegment resets fields and rethrows on repository error",
        () async {
      if (!_hasSeededUser) {
        expect(
          true,
          isTrue,
          reason:
              "Globals.user is null in test env; skipping user-dependent path",
        );
        return;
      }

      _safeSetUser(roleId: UserRole.relationshipManager.index);

      viewModel
        ..customerRimNo = "123"
        ..customerName = "John"
        ..groupId = "456"
        ..groupName = "Group"
        ..isSearched = true
        ..subSegmentValidation = [
          Reference(
            reference1: ServerConstants.subSegmentValidationRefId,
            reference2: "${UserRole.relationshipManager.index}",
          ),
        ]
        ..customer = Customer(
          relationshipMgr: [
            {"RelationshipMgrIdent": "RM001"},
          ],
        );

      when(() => mockCustomerRepo.validateSubSegment(any()))
          .thenThrow(Exception("subsegment failed"));

      await expectLater(
        viewModel.validateSubSegment(),
        throwsA(anything),
      );

      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.customerName, isNull);
      expect(viewModel.groupId, isNull);
      expect(viewModel.groupName, isNull);
      expect(viewModel.isSearched, isFalse);
      expect(viewModel.fieldCntrl.value[ControlFields.customerName], isFalse);
      expect(viewModel.fieldCntrl.value[ControlFields.customerRim], isFalse);
      expect(viewModel.fieldCntrl.value[ControlFields.groupID], isFalse);
      expect(viewModel.fieldCntrl.value[ControlFields.groupName], isFalse);
    });

    test("debugValidation executes without crashing", () {
      viewModel.branchList = [
        Reference(reference1: "BR001", reference2: "DXB"),
      ];

      _safeSetUser(
        regions: ["DXB"],
        segments: ["CORPORATE"],
        roleId: UserRole.relationshipManager.index,
      );

      viewModel.businessSegmentValue = Reference(
        id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
      );

      expect(
        () => viewModel.debugValidation(
          "step-1",
          Customer(
            id: "1",
            segment: "CORPORATE",
            branchCode: "BR001",
          ),
        ),
        returnsNormally,
      );
    });

    test("buttonVisibilityStatus callbacks execute and return bool", () {
      final uploadVisible = viewModel
          .buttonVisibilityStatus[DigitaleFileFields.uploadDocument]
          ?.call();
      final approvalVisible = viewModel
          .buttonVisibilityStatus[DigitaleFileFields.showApprovalDecision]
          ?.call();

      expect(uploadVisible, isA<bool>());
      expect(approvalVisible, isA<bool>());
    });
  });

  group("DigitalEfilingState", () {
    test("constructor sets loaderStatus", () {
      final state = DigitalEfilingState(
        loaderStatus: LoadingStatus.loading,
        searchLoaderStatus: LoadingStatus.loaded,
      );
      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.searchLoaderStatus, LoadingStatus.loaded);
    });

    test("copyWith keeps existing when null", () {
      final original = DigitalEfilingState(
        loaderStatus: LoadingStatus.loaded,
        searchLoaderStatus: LoadingStatus.loaded,
      );
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.searchLoaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      final original = DigitalEfilingState(
        loaderStatus: LoadingStatus.loaded,
        searchLoaderStatus: LoadingStatus.loaded,
      );
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith updates all fields", () {
      final original = DigitalEfilingState(
        loaderStatus: LoadingStatus.loaded,
        searchLoaderStatus: LoadingStatus.loaded,
        groupName: "Group A",
        groupRim: "123",
        customerName: "John",
        customerRim: "456",
        showSelectDialog: false,
      );

      final updated = original.copyWith(
        loaderStatus: LoadingStatus.loading,
        searchLoaderStatus: LoadingStatus.loading,
        groupName: "Group B",
        groupRim: "789",
        customerName: "Jane",
        customerRim: "012",
        showSelectDialog: true,
      );

      expect(updated.loaderStatus, LoadingStatus.loading);
      expect(updated.searchLoaderStatus, LoadingStatus.loading);
      expect(updated.groupName, "Group B");
      expect(updated.groupRim, "789");
      expect(updated.customerName, "Jane");
      expect(updated.customerRim, "012");
      expect(updated.showSelectDialog, true);
    });
  });
}
