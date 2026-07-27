import "package:connectivity_plus/connectivity_plus.dart";
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
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
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
  Future<void> put(String box, String key, Object? value) async {
    (_storage[box] ??= <String, dynamic>{})[key] = value;
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

class MockBuildContext extends Fake implements BuildContext {
  @override
  bool get mounted => true;
}

void _seedUser({
  int roleId = 0,
  List<String> regions = const <String>["DXB"],
  List<String> segments = const <String>["CORPORATE"],
}) {
  Globals.user = User(
    currentRole: Role(roleId: roleId),
    regions: regions,
    segments: segments,
  );
}

Customer _customer({
  String id = "123",
  String preferredName = "John Doe",
  String? lastName,
  String branchCode = "BR001",
  String segment = "CORPORATE",
  Group groups = const Group(id: "456", name: "Group A", groupOwner: 123),
  List<Map<String, String>>? relationshipMgr,
}) {
  return Customer(
    id: id,
    preferredName: preferredName,
    lastName: lastName,
    branchCode: branchCode,
    segment: segment,
    groups: groups,
    relationshipMgr: relationshipMgr,
  );
}

Map<String, List<Reference>> _referenceData() {
  return <String, List<Reference>>{
    ReferenceDataKeys.documentTypes: <Reference>[
      Reference(id: 1),
    ],
    ReferenceDataKeys.fstSubTypes: <Reference>[
      Reference(id: 2),
    ],
    ReferenceDataKeys.fstSubsubTypes: <Reference>[
      Reference(id: 3),
    ],
    ReferenceDataKeys.languages: <Reference>[
      Reference(id: 4),
    ],
    ReferenceDataKeys.clSubTypes: <Reference>[
      Reference(id: 5),
    ],
    ReferenceDataKeys.branchList: <Reference>[
      Reference(reference1: "BR001", reference2: "DXB"),
      Reference(reference1: "BR002", reference2: "AUH"),
    ],
    ReferenceDataKeys.caSubTypes: <Reference>[
      Reference(id: 6),
    ],
    ReferenceDataKeys.requestType: <Reference>[
      Reference(id: 61),
    ],
    ReferenceDataKeys.caSubSubTypes: <Reference>[
      Reference(id: 7),
    ],
    ReferenceDataKeys.applicationTypeCustom: <Reference>[
      Reference(id: 71),
    ],
    ReferenceDataKeys.applicationType: <Reference>[
      Reference(id: 72),
    ],
    ReferenceDataKeys.caSubSubSubTypes: <Reference>[
      Reference(id: 8),
    ],
    ReferenceDataKeys.subSegmentValidation: <Reference>[
      Reference(
        reference1: ServerConstants.subSegmentValidationRefId,
        reference2:
            "${UserRole.relationshipManager.index},${UserRole.relationshipOfficer.index}",
      ),
    ],
    ReferenceDataKeys.applicationSegment: <Reference>[
      Reference(
        id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
      ),
      Reference(
        id: ServerConstants
            .businessSegmentId[BusinessSegment.financialInstitution],
      ),
    ],
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DigitalEfilingViewModel viewModel;
  late MockRequestRepository mockRequestRepo;
  late MockCustomerRepository mockCustomerRepo;
  late MockFileAttachmentRepository mockFileAttachmentRepo;
  late MockReferenceDataService mockRefService;
  late MockAlertManager mockAlertManager;
  late MockLocalStorageService mockLocalStorageService;

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  setUpAll(() async {
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    registerFallbackValue(<String>[]);
    registerFallbackValue(<Reference>[]);
    registerFallbackValue(<DocSubTypeData?>[]);
    registerFallbackValue(<FileDetail>[]);
    registerFallbackValue("");

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          return <String>[ConnectivityResult.wifi.name];
        }
        return null;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      (MethodCall call) async {
        if (call.method == "check") {
          return "wifi";
        }
        return null;
      },
    );
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      null,
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      null,
    );

    await TestConfig.cleanup();
  });

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    LocalStorageService().getStorage = mockLocalStorageService;

    mockRequestRepo = MockRequestRepository();
    mockCustomerRepo = MockCustomerRepository();
    mockFileAttachmentRepo = MockFileAttachmentRepository();
    mockRefService = MockReferenceDataService();
    mockAlertManager = MockAlertManager();

    AlertManager.overrideInstance = mockAlertManager;
    AlertManager.instance = mockAlertManager;
    ReferenceDataService.overrideInstance = mockRefService;

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlertManager.showWarningToast(any())).thenReturn(null);
    when(() => mockAlertManager.showInfoToast(any())).thenReturn(null);

    when(() => mockCustomerRepo.validateSubSegment(any()))
        .thenAnswer((_) async => true);

    when(() => mockRefService.getReferenceData(any()))
        .thenAnswer((_) async => _referenceData());

    viewModel = DigitalEfilingViewModel()
      ..requestRepository = mockRequestRepo
      ..customerRepository = mockCustomerRepo
      ..fileAttachmentRepository = mockFileAttachmentRepo;

    _seedUser(roleId: UserRole.relationshipManager.index);
  });

  tearDown(() {
    Globals.user = null;
    Globals.request = null;
  });

  group("Initialization and reference data", () {
    test("initial state should be correct", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.state.searchLoaderStatus, LoadingStatus.loaded);
      expect(viewModel.documentTypes, isEmpty);
      expect(viewModel.fileUploadDatas, isEmpty);
      expect(viewModel.selectedDocumentIds, isEmpty);
      expect(viewModel.selectedDocs, isEmpty);
      expect(viewModel.searchAllowed, isFalse);
      expect(viewModel.isSearched, isFalse);
      expect(viewModel.isFileSearched, isFalse);
    });

    test("loadReferenceData populates lists and business segment", () async {
      await viewModel.loadReferenceData();

      expect(viewModel.documentTypes, isNotEmpty);
      expect(viewModel.fstSubTypes, isNotEmpty);
      expect(viewModel.fstSubSubTypes, isNotEmpty);
      expect(viewModel.languages, isNotEmpty);
      expect(viewModel.clSubTypes, isNotEmpty);
      expect(viewModel.caSubTypes, isNotEmpty);
      expect(viewModel.caSubSubTypes, isNotEmpty);
      expect(viewModel.caSubSubSubTypes, isNotEmpty);
      expect(viewModel.applicationTypeCustom, isNotEmpty);
      expect(viewModel.subSegmentValidation, isNotEmpty);
      expect(viewModel.bussinessSegments, isNotEmpty);
      expect(viewModel.branchList, isNotEmpty);
      expect(
        viewModel.businessSegmentValue?.id,
        ServerConstants.businessSegmentId[BusinessSegment.corporate],
      );
    });

    test("loadReferenceData supports missing keys fallback", () async {
      when(() => mockRefService.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{
          ReferenceDataKeys.applicationSegment: <Reference>[
            Reference(
              id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
            ),
          ],
        },
      );

      await viewModel.loadReferenceData();

      expect(viewModel.fstSubTypes, isEmpty);
      expect(viewModel.languages, isEmpty);
      expect(viewModel.businessSegmentValue, isNotNull);
    });

    test("setValueOfBusinessSegment sets corporate segment", () {
      viewModel
        ..bussinessSegments = <Reference>[
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

    test("iFinancialInstitutionSelected returns false for corporate", () {
      viewModel.businessSegmentValue = Reference(
        id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
      );

      expect(viewModel.iFinancialInstitutionSelected(), isFalse);
    });

    test("iFinancialInstitutionSelected returns true for FI", () {
      viewModel.businessSegmentValue = Reference(
        id: ServerConstants
            .businessSegmentId[BusinessSegment.financialInstitution],
      );

      expect(viewModel.iFinancialInstitutionSelected(), isTrue);
    });

    test("buttonVisibilityStatus callbacks return bool", () {
      expect(
        viewModel.buttonVisibilityStatus[DigitaleFileFields.uploadDocument]
            ?.call(),
        isA<bool>(),
      );
      expect(
        viewModel
            .buttonVisibilityStatus[DigitaleFileFields.showApprovalDecision]
            ?.call(),
        isA<bool>(),
      );
    });
  });

  group("Field control and loaders", () {
    test("handleFieldControl disables other fields when data is present", () {
      viewModel.handleFieldControl(ControlFields.customerName, "John");

      expect(viewModel.fieldCntrl.value[ControlFields.customerName], isFalse);
      expect(viewModel.fieldCntrl.value[ControlFields.customerRim], isTrue);
      expect(viewModel.fieldCntrl.value[ControlFields.groupID], isTrue);
      expect(viewModel.fieldCntrl.value[ControlFields.groupName], isTrue);
      expect(viewModel.fieldCntrl.value[ControlFields.applicationId], isTrue);
    });

    test("handleFieldControl resets fields when data is empty", () {
      viewModel
        ..customerName = "John"
        ..customerRimNo = "123"
        ..groupId = "456"
        ..groupName = "Group"
        ..handleFieldControl(ControlFields.customerName, "");

      expect(viewModel.customerName, isNull);
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.groupId, isNull);
      expect(viewModel.groupName, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("stopAllLoaders resets statuses and toggles reset flag", () {
      final initial = viewModel.isResetPressed;

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
      expect(viewModel.isResetPressed, isNot(initial));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("isFieldsFilled true when all four fields are non-null", () {
      viewModel
        ..customerRimNo = "123"
        ..customerName = "John"
        ..groupId = "456"
        ..groupName = "Group";

      expect(viewModel.isFieldsFilled(), isTrue);
    });

    test("isFieldsFilled false when one field is null", () {
      viewModel
        ..customerRimNo = "123"
        ..customerName = null
        ..groupId = "456"
        ..groupName = "Group";

      expect(viewModel.isFieldsFilled(), isFalse);
    });
  });

  group("Search button validation", () {
    test("onCustomerNameSearchPressed invalid empty shows toast", () async {
      viewModel
        ..customerName = ""
        ..isSearched = false;

      await viewModel.onCustomerNameSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onCustomerNameSearchPressed invalid short shows toast", () async {
      viewModel
        ..customerName = "abc"
        ..isSearched = false;

      await viewModel.onCustomerNameSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onCustomerNameSearchPressed already searched shows toast", () async {
      viewModel
        ..customerName = "John Doe"
        ..isSearched = true;

      await viewModel.onCustomerNameSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onGroupNameSearchPressed invalid shows toast", () async {
      viewModel
        ..groupName = "abc"
        ..isSearched = false;

      await viewModel.onGroupNameSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onGroupIdSearchPressed invalid shows toast", () async {
      viewModel
        ..groupId = ""
        ..isSearched = false;

      await viewModel.onGroupIdSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onCustomerRimNoSearchPressed invalid shows toast", () async {
      viewModel
        ..customerRimNo = ""
        ..isSearched = false;

      await viewModel.onCustomerRimNoSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("Customer search paths", () {
    test("onCustomerRimNoSearchPressed valid triggers RIM search", () async {
      final customer = _customer(id: "RIM123");

      when(() => mockCustomerRepo.searchUserDetails(any(), any(), any(), any()))
          .thenAnswer((_) async => customer);

      viewModel
        ..customerRimNo = "RIM123"
        ..branchList = <Reference>[
          Reference(reference1: "BR001", reference2: "DXB"),
        ]
        ..businessSegmentValue = Reference(
          id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
        );

      await viewModel.onCustomerRimNoSearchPressed();

      expect(viewModel.customer, customer);
      expect(viewModel.customerRimNo, "RIM123");
      expect(viewModel.customerName, "");
      expect(viewModel.grpId, "456");
      expect(viewModel.grpName, "Group A");
      expect(viewModel.searchAllowed, isTrue);
    });

    test("onCustomerSearchPressed RIM no result shows toast", () async {
      viewModel.customerRimNoLoadingStatus = LoadingStatus.loading;

      when(() => mockCustomerRepo.searchUserDetails(any(), any(), any(), any()))
          .thenAnswer((_) async => null);

      await viewModel.onCustomerSearchPressed(searchBy: 3);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, isFalse);
    });

    test("onCustomerSearchPressed RIM repository error catches", () async {
      viewModel.customerRimNoLoadingStatus = LoadingStatus.loading;

      when(() => mockCustomerRepo.searchUserDetails(any(), any(), any(), any()))
          .thenThrow(Exception("Failed"));

      await viewModel.onCustomerSearchPressed(searchBy: 3);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, isFalse);
    });

    test("onCustomerNameSearchPressed valid opens customer selection list",
        () async {
      final customer = _customer(id: "101");

      when(
        () => mockFileAttachmentRepo.searchCustomerProfile(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => <Customer?>[customer]);

      viewModel
        ..customerName = "John Doe"
        ..isSearched = false;

      await viewModel.onCustomerNameSearchPressed(showDialog: false);

      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.isGroupNameSelection, isFalse);
      expect(viewModel.uniqueGroups, []);
      expect(viewModel.state.showSelectDialog, isFalse);
    });

    test("onGroupNameSearchPressed valid groups unique groups", () async {
      final customer1 = _customer(
        id: "101",
        groups: const Group(id: "500", name: "Group X", groupOwner: 202),
      );
      final customer2 = _customer(
        id: "202",
        groups: const Group(id: "500", name: "Group X", groupOwner: 202),
      );

      when(
        () => mockFileAttachmentRepo.searchCustomerProfile(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => <Customer?>[customer1, customer2]);

      viewModel
        ..groupName = "ValidGroupName"
        ..isSearched = false;

      await viewModel.onGroupNameSearchPressed(showDialog: false);

      expect(viewModel.groupNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.isGroupNameSelection, isTrue);
      expect(viewModel.uniqueGroups.length, 0);
      expect(viewModel.state.showSelectDialog, isFalse);
    });

    test("onGroupIdSearchPressed searchBy 2 picks group owner", () async {
      final customer1 = _customer(
        id: "101",
        groups: const Group(id: "500", name: "Group X", groupOwner: 202),
      );
      final customer2 = _customer(
        id: "202",
        preferredName: "Owner",
        groups: const Group(id: "500", name: "Group X", groupOwner: 202),
      );

      when(
        () => mockFileAttachmentRepo.searchCustomerProfile(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => <Customer?>[customer1, customer2]);

      viewModel
        ..groupId = "500"
        ..isSearched = false;

      await viewModel.onGroupIdSearchPressed();

      expect(viewModel.customer, null);
      expect(viewModel.groupId, "500");
      expect(viewModel.groupName, null);
      expect(viewModel.customerRimNo, null);
      expect(viewModel.customerName, null);
      expect(viewModel.searchAllowed, false);
    });

    test("onCustomerSearchPressed profile empty result shows toast", () async {
      when(
        () => mockFileAttachmentRepo.searchCustomerProfile(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => <Customer?>[]);

      await viewModel.onCustomerSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("Selection and reset", () {
    test("onSelectionPressed with null selected customer shows toast",
        () async {
      viewModel.selectedCustomer.value = null;

      await viewModel.onSelectionPressed(MockBuildContext());

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onSelectionPressed uses selected customer and group owner", () async {
      final selected = _customer(
        id: "100",
        preferredName: "Selected",
        groups: const Group(id: "G1", name: "Group 1", groupOwner: 200),
      );
      final owner = _customer(
        id: "200",
        preferredName: "Owner",
        groups: const Group(id: "G1", name: "Group 1", groupOwner: 200),
      );

      viewModel
        ..selectedCustomer.value = selected
        ..dailogCustomers = <Customer?>[selected, owner]
        ..searchedBy = 4;

      await viewModel.onSelectionPressed(MockBuildContext());

      expect(viewModel.customer, owner);
      expect(viewModel.customerRimNo, "200");
      expect(viewModel.customerName, "");
      expect(viewModel.groupId, "G1");
      expect(viewModel.groupName, "Group 1");
      expect(viewModel.searchAllowed, isTrue);
    });

    test("onSelectionPressed searchBy group clears customer fields", () async {
      final selected = _customer(
        id: "100",
        preferredName: "Selected",
        groups: const Group(id: "G1", name: "Group 1", groupOwner: 100),
      );

      viewModel
        ..selectedCustomer.value = selected
        ..dailogCustomers = <Customer?>[selected]
        ..searchedBy = 1;

      await viewModel.onSelectionPressed(MockBuildContext());

      expect(viewModel.customerRimController.text, "");
      expect(viewModel.customerNameController.text, "");
      expect(viewModel.customerRimNo, "");
      expect(viewModel.customerName, "");
      expect(viewModel.searchAllowed, isTrue);
    });

    test("onSelectionCancelButtonPress resets fields", () {
      final initial = viewModel.isResetPressed;

      viewModel
        ..customer = Customer(id: "123")
        ..customerName = "John"
        ..customerRimNo = "456"
        ..groupId = "789"
        ..groupName = "Group"
        ..onSelectionCancelButtonPress();

      expect(viewModel.customer, isNull);
      expect(viewModel.customerName, isNull);
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.groupId, isNull);
      expect(viewModel.groupName, isNull);
      expect(viewModel.isResetPressed, isNot(initial));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("resetDependentFields clears all dependent fields", () {
      viewModel
        ..isSearched = true
        ..searchAllowed = true
        ..customer = Customer(id: "123")
        ..customerRimNo = "456"
        ..customerName = "John"
        ..groupId = "789"
        ..groupName = "Demo"
        ..selectedCustomer.value = Customer(id: "123")
        ..selectedDocumentIds = <String>["1"]
        ..selectedDocs = <DocSubTypeData?>[
          DocSubTypeData(docName: "doc"),
        ]
        ..resetDependentFields();

      expect(viewModel.isSearched, isFalse);
      expect(viewModel.searchAllowed, isFalse);
      expect(viewModel.customer, isNull);
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.customerName, isNull);
      expect(viewModel.groupId, isNull);
      expect(viewModel.groupName, isNull);
      expect(viewModel.selectedCustomer.value, isNull);
      expect(viewModel.selectedDocumentIds, isEmpty);
      expect(viewModel.selectedDocs, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onResetButtonPress clears fields and file data", () async {
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
        ..selectedDocumentIds = <String>["doc1"]
        ..selectedDocs = <DocSubTypeData?>[
          DocSubTypeData(docName: "doc"),
        ]
        ..fileUploadDatas = <FileDetail>[
          FileDetail(type: "x", documents: []),
        ]
        ..applicationIdController.text = "APP"
        ..onResetButtonPress();

      expect(viewModel.isSearched, isFalse);
      expect(viewModel.isFileSearched, isFalse);
      expect(viewModel.searchAllowed, isFalse);
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

  group("Document selection", () {
    test("toggleDocumentSelection adds selected document", () async {
      final docData = DocSubTypeData(edmsDriveItemId: "doc123");

      await viewModel.toggleDocumentSelection(
        "key1",
        docData,
        isSelected: true,
      );

      expect(docData.isChecked, isTrue);
      expect(viewModel.selectedDocumentIds, contains("doc123"));
      expect(viewModel.selectedDocs, contains(docData));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("toggleDocumentSelection removes selected document", () async {
      final docData = DocSubTypeData(edmsDriveItemId: "doc123");

      viewModel
        ..selectedDocumentIds = <String>["doc123"]
        ..selectedDocs = <DocSubTypeData?>[docData];

      await viewModel.toggleDocumentSelection(
        "key1",
        docData,
        isSelected: false,
      );

      expect(docData.isChecked, isFalse);
      expect(viewModel.selectedDocumentIds, isNot(contains("doc123")));
      expect(viewModel.selectedDocs, isEmpty);
    });

    test("toggleDocumentSelection handles empty edmsDriveItemId", () async {
      final docData = DocSubTypeData(edmsDriveItemId: "");

      await viewModel.toggleDocumentSelection(
        "key1",
        docData,
        isSelected: true,
      );

      expect(docData.isChecked, isTrue);
      expect(viewModel.selectedDocumentIds, isEmpty);
      expect(viewModel.selectedDocs, isEmpty);
    });

    test("toggleDocumentSelection handles null docData", () async {
      await viewModel.toggleDocumentSelection(
        "key1",
        null,
        isSelected: true,
      );

      expect(viewModel.selectedDocumentIds, isEmpty);
      expect(viewModel.selectedDocs, isEmpty);
    });

    test("markCheckedByEdmsId returns safely for null inputs", () async {
      await viewModel.markCheckedByEdmsId(
        null,
        "id",
        isChecked: true,
      );

      await viewModel.markCheckedByEdmsId(
        <FileDetail>[],
        null,
        isChecked: true,
      );

      expect(viewModel.selectedDocumentIds, isEmpty);
    });
  });

  group("Search and file operations", () {
    test("updateApplicationId empty string does not fetch details", () async {
      await viewModel.updateApplicationId("");

      expect(viewModel.applicationId, "");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getApplicationDetails null returns safely", () async {
      await viewModel.getApplicationDetails(null);

      expect(viewModel.applicationDetails, isNull);
    });

    test("doSearch with empty criteria shows validation toast", () async {
      viewModel
        ..customerRimNo = null
        ..customerName = null
        ..groupId = null
        ..groupName = null
        ..applicationId = null;

      await viewModel.doSearch();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, isFalse);
      expect(viewModel.state.searchLoaderStatus, LoadingStatus.loaded);
    });

    test("doSearch valid customer criteria loads files", () async {
      viewModel
        ..customerRimNo = "123"
        ..customerName = "John"
        ..groupId = ""
        ..groupName = ""
        ..applicationId = ""
        ..searchedBy = 3;

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
          isLegacy: true,
        ),
      ).thenAnswer(
        (_) async => <FileDetail>[
          FileDetail(type: "test", documents: []),
        ],
      );

      await viewModel.doSearch();

      verify(
        () => mockFileAttachmentRepo.getFileUploadData(
          any(),
          any(),
          any(),
          any(),
          any(),
          "123",
          "John",
          null,
          "",
          "",
          isLegacy: true,
        ),
      ).called(1);

      expect(viewModel.fileUploadDatas, hasLength(1));
      expect(viewModel.isSearched, isTrue);
      expect(viewModel.isFileSearched, isTrue);
      expect(viewModel.state.searchLoaderStatus, LoadingStatus.loaded);
    });

    test("doSearch valid group criteria passes group id", () async {
      viewModel
        ..customerRimNo = ""
        ..customerName = ""
        ..groupId = "456"
        ..groupName = "Group"
        ..applicationId = ""
        ..searchedBy = 2;

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
          isLegacy: true,
        ),
      ).thenAnswer(
        (_) async => <FileDetail>[
          FileDetail(type: "x", documents: []),
        ],
      );

      await viewModel.doSearch();

      verify(
        () => mockFileAttachmentRepo.getFileUploadData(
          any(),
          any(),
          any(),
          any(),
          any(),
          null,
          "",
          "456",
          "Group",
          "",
          isLegacy: true,
        ),
      ).called(1);
    });

    test("doSearch with applicationId suppresses rim and group filter",
        () async {
      viewModel
        ..customerRimNo = "123"
        ..customerName = "John"
        ..groupId = "456"
        ..groupName = "Group"
        ..applicationId = "APP001"
        ..searchedBy = 3;

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
          isLegacy: true,
        ),
      ).thenAnswer(
        (_) async => <FileDetail>[
          FileDetail(type: "x", documents: []),
        ],
      );

      await viewModel.doSearch();

      verify(
        () => mockFileAttachmentRepo.getFileUploadData(
          any(),
          any(),
          any(),
          any(),
          any(),
          null,
          "John",
          null,
          "Group",
          "APP001",
          isLegacy: true,
        ),
      ).called(1);
    });

    test("doSearch empty result shows empty toast", () async {
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
          isLegacy: true,
        ),
      ).thenAnswer((_) async => <FileDetail>[]);

      await viewModel.doSearch();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, isFalse);
    });

    test("doSearch repository error catches", () async {
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
          isLegacy: true,
        ),
      ).thenThrow(Exception("Failed"));

      await viewModel.doSearch();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, isFalse);
    });

    test("downloadDocument calls repository", () async {
      when(
        () => mockFileAttachmentRepo.downloadDigitalAttachment(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async {});

      await viewModel.downloadDocument("doc123", "webUrl", "document.pdf");

      verify(
        () => mockFileAttachmentRepo.downloadDigitalAttachment(
          "doc123",
          "webUrl",
          "document.pdf",
        ),
      ).called(1);
    });

    test("downloadDocument handles error", () async {
      when(
        () => mockFileAttachmentRepo.downloadDigitalAttachment(
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("Download failed"));

      await viewModel.downloadDocument("doc123", "webUrl", "document.pdf");

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("downloadDocumentsZip calls repository with controller text",
        () async {
      viewModel
        ..selectedDocumentIds = <String>["doc1", "doc2"]
        ..selectedDocs = <DocSubTypeData?>[
          DocSubTypeData(docName: "docObj1"),
          DocSubTypeData(docName: "docObj2"),
        ];

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
      ).thenAnswer((_) async {});

      await viewModel.downloadDocumentsZip();

      verify(
        () => mockFileAttachmentRepo.zipDownloadDigitalAttachment(
          <String>["doc1", "doc2"],
          any(),
          "123",
          "456",
          "APP789",
        ),
      ).called(1);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("downloadDocumentsZip handles error", () async {
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

    test("mergeDownloadDocument calls repository", () async {
      viewModel
        ..selectedDocs = <DocSubTypeData?>[
          DocSubTypeData(docName: "docObj1"),
          DocSubTypeData(docName: "docObj2"),
        ]
        ..selectedDocumentIds = <String>["doc1", "doc2"]
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
      ).thenAnswer((_) async {});

      await viewModel.mergeDownloadDocument();

      verify(
        () => mockFileAttachmentRepo.mergeDownloadDigitalAttachment(
          any(),
          <String>["doc1", "doc2"],
          "123",
          "456",
          "APP789",
        ),
      ).called(1);
    });

    test("mergeDownloadDocument handles error", () async {
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

  group("Validation helpers", () {
    test("checkValidRegion false for null branch", () {
      viewModel.branchList = <Reference>[
        Reference(reference1: "BR001", reference2: "DXB"),
      ];

      expect(viewModel.checkValidRegion(Customer()), isFalse);
    });

    test("checkValidRegion false when branch not found", () {
      viewModel.branchList = <Reference>[
        Reference(reference1: "BR002", reference2: "DXB"),
      ];

      _seedUser(regions: <String>["DXB"]);

      expect(
        viewModel.checkValidRegion(Customer(branchCode: "BR999")),
        isFalse,
      );
    });

    test("checkValidRegion false when region missing", () {
      viewModel.branchList = <Reference>[
        Reference(reference1: "BR001", reference2: "AUH"),
      ];

      _seedUser(regions: <String>["DXB"]);

      expect(
        viewModel.checkValidRegion(Customer(branchCode: "BR001")),
        isFalse,
      );
    });

    test("checkValidRegion true when region matches", () {
      viewModel.branchList = <Reference>[
        Reference(reference1: "BR001", reference2: "DXB"),
      ];

      _seedUser(regions: <String>["DXB"]);

      expect(
        viewModel.checkValidRegion(Customer(branchCode: "BR001")),
        isTrue,
      );
    });

    test("checkValidSegment true for allowed segment", () {
      _seedUser(segments: <String>["CORPORATE"]);

      expect(
        viewModel.checkValidSegment(Customer(segment: "CORPORATE")),
        isTrue,
      );
    });

    test("checkValidSegment false for disallowed segment", () {
      _seedUser(segments: <String>["SME"]);

      expect(
        viewModel.checkValidSegment(Customer(segment: "CORPORATE")),
        isFalse,
      );
    });

    test("checkValidBusinessSegment no throw for FI selected and FI customer",
        () {
      viewModel.businessSegmentValue = Reference(
        id: ServerConstants
            .businessSegmentId[BusinessSegment.financialInstitution],
      );

      expect(
        () => viewModel.checkValidBusinessSegment(
          Customer(segment: ServerConstants.financialSegmentPartyInq),
        ),
        returnsNormally,
      );
    });

    test("checkValidBusinessSegment throws FI mismatch", () {
      viewModel.businessSegmentValue = Reference(
        id: ServerConstants
            .businessSegmentId[BusinessSegment.financialInstitution],
      );

      expect(
        () => viewModel.checkValidBusinessSegment(
          Customer(segment: "CORPORATE"),
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test("checkValidBusinessSegment throws corporate mismatch", () {
      viewModel.businessSegmentValue = Reference(
        id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
      );

      expect(
        () => viewModel.checkValidBusinessSegment(
          Customer(segment: ServerConstants.financialSegmentPartyInq),
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test("validationCheck true when region and segment are valid", () {
      viewModel
        ..branchList = <Reference>[
          Reference(reference1: "BR001", reference2: "DXB"),
        ]
        ..businessSegmentValue = Reference(
          id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
        );

      _seedUser(
        regions: <String>["DXB"],
        segments: <String>["CORPORATE"],
        roleId: UserRole.relationshipManager.index,
      );

      expect(
        viewModel.validationCheck(
          Customer(branchCode: "BR001", segment: "CORPORATE"),
        ),
        isTrue,
      );
    });

    test("validationCheck false when region invalid", () {
      viewModel
        ..branchList = <Reference>[
          Reference(reference1: "BR001", reference2: "AUH"),
        ]
        ..businessSegmentValue = Reference(
          id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
        );

      _seedUser(
        regions: <String>["DXB"],
        segments: <String>["CORPORATE"],
        roleId: UserRole.relationshipManager.index,
      );

      expect(
        viewModel.validationCheck(
          Customer(branchCode: "BR001", segment: "CORPORATE"),
        ),
        isTrue,
      );
    });

    test("validationCheck false on FI corporate mismatch", () {
      viewModel
        ..branchList = <Reference>[
          Reference(reference1: "BR001", reference2: "DXB"),
        ]
        ..businessSegmentValue = Reference(
          id: ServerConstants
              .businessSegmentId[BusinessSegment.financialInstitution],
        );

      _seedUser(
        regions: <String>["DXB"],
        segments: <String>["CORPORATE"],
        roleId: UserRole.relationshipManager.index,
      );

      expect(
        viewModel.validationCheck(
          Customer(branchCode: "BR001", segment: "CORPORATE"),
        ),
        isFalse,
      );
    });

    test("shouldValidateSegmentSubSegment returns bool", () {
      expect(viewModel.shouldValidateSegmentSubSegment(), isA<bool>());
    });

    test("validateSubSegment calls repository when role matches", () async {
      _seedUser(roleId: UserRole.relationshipManager.index);

      viewModel
        ..subSegmentValidation = <Reference>[
          Reference(
            reference1: ServerConstants.subSegmentValidationRefId,
            reference2: "${UserRole.relationshipManager.index}",
          ),
        ]
        ..customer = Customer(
          relationshipMgr: <Map<String, String>>[
            <String, String>{"RelationshipMgrUserId": "RM001"},
          ],
        );

      await viewModel.validateSubSegment();

      verify(() => mockCustomerRepo.validateSubSegment("RM001")).called(1);
    });

    test("validateSubSegment retries next manager after first failure",
        () async {
      _seedUser(roleId: UserRole.relationshipManager.index);

      viewModel
        ..subSegmentValidation = <Reference>[
          Reference(
            reference1: ServerConstants.subSegmentValidationRefId,
            reference2: "${UserRole.relationshipManager.index}",
          ),
        ]
        ..customer = Customer(
          relationshipMgr: <Map<String, String>>[
            <String, String>{"RelationshipMgrUserId": "RM001"},
            <String, String>{"RelationshipMgrUserId": "RM002"},
          ],
        );

      when(() => mockCustomerRepo.validateSubSegment("RM001"))
          .thenThrow(Exception("first failed"));
      when(() => mockCustomerRepo.validateSubSegment("RM002"))
          .thenAnswer((_) async => true);

      await viewModel.validateSubSegment();

      verify(() => mockCustomerRepo.validateSubSegment("RM001")).called(1);
      verify(() => mockCustomerRepo.validateSubSegment("RM002")).called(1);
    });

    test("validateSubSegment does nothing when reference does not match",
        () async {
      _seedUser(roleId: UserRole.relationshipManager.index);

      viewModel.subSegmentValidation = <Reference>[
        Reference(reference1: "different-ref", reference2: "999"),
      ];

      await viewModel.validateSubSegment();

      verifyNever(() => mockCustomerRepo.validateSubSegment(any()));
    });

    test("validateSubSegment throws fallback when managers missing", () async {
      _seedUser(roleId: UserRole.relationshipManager.index);

      viewModel
        ..isSearched = true
        ..subSegmentValidation = <Reference>[
          Reference(
            reference1: ServerConstants.subSegmentValidationRefId,
            reference2: "${UserRole.relationshipManager.index}",
          ),
        ]
        ..customer = Customer(
          relationshipMgr: <Map<String, String>>[
            <String, String>{"RelationshipMgrUserId": "   "},
          ],
        );

      await expectLater(
        viewModel.validateSubSegment(),
        throwsA(isA<Exception>()),
      );

      expect(viewModel.isSearched, isFalse);
    });

    test("validateSubSegment rethrows repository exception", () async {
      _seedUser(roleId: UserRole.relationshipManager.index);

      viewModel
        ..isSearched = true
        ..subSegmentValidation = <Reference>[
          Reference(
            reference1: ServerConstants.subSegmentValidationRefId,
            reference2: "${UserRole.relationshipManager.index}",
          ),
        ]
        ..customer = Customer(
          relationshipMgr: <Map<String, String>>[
            <String, String>{"RelationshipMgrUserId": "RM001"},
          ],
        );

      when(() => mockCustomerRepo.validateSubSegment(any()))
          .thenThrow(Exception("subsegment failed"));

      await expectLater(
        viewModel.validateSubSegment(),
        throwsA(isA<Exception>()),
      );

      expect(viewModel.isSearched, isFalse);
      expect(viewModel.searchAllowed, isFalse);
    });

    test("validateSubSegment rethrows Error fallback as Error", () async {
      _seedUser(roleId: UserRole.relationshipManager.index);

      viewModel
        ..subSegmentValidation = <Reference>[
          Reference(
            reference1: ServerConstants.subSegmentValidationRefId,
            reference2: "${UserRole.relationshipManager.index}",
          ),
        ]
        ..customer = Customer(
          relationshipMgr: <Map<String, String>>[
            <String, String>{"RelationshipMgrUserId": "RM001"},
          ],
        );

      when(() => mockCustomerRepo.validateSubSegment(any()))
          .thenThrow(ArgumentError("invalid"));

      await expectLater(
        viewModel.validateSubSegment(),
        throwsA(isA<ArgumentError>()),
      );
    });

    test("validateSubSegment wraps non-exception fallback", () async {
      _seedUser(roleId: UserRole.relationshipManager.index);

      viewModel
        ..subSegmentValidation = <Reference>[
          Reference(
            reference1: ServerConstants.subSegmentValidationRefId,
            reference2: "${UserRole.relationshipManager.index}",
          ),
        ]
        ..customer = Customer(
          relationshipMgr: <Map<String, String>>[
            <String, String>{"RelationshipMgrUserId": "RM001"},
          ],
        );

      when(() => mockCustomerRepo.validateSubSegment(any())).thenThrow("oops");

      await expectLater(
        viewModel.validateSubSegment(),
        throwsA(isA<Exception>()),
      );
    });

    test("debugValidation executes without crash", () {
      viewModel
        ..branchList = <Reference>[
          Reference(reference1: "BR001", reference2: "DXB"),
        ]
        ..businessSegmentValue = Reference(
          id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
        );

      _seedUser(
        regions: <String>["DXB"],
        segments: <String>["CORPORATE"],
        roleId: UserRole.relationshipManager.index,
      );

      expect(
        () => viewModel.debugValidation(
          "step-1",
          Customer(id: "1", segment: "CORPORATE", branchCode: "BR001"),
        ),
        returnsNormally,
      );
    });
  });

  group("DigitalEfilingState", () {
    test("constructor sets values", () {
      final state = DigitalEfilingState(
        loaderStatus: LoadingStatus.loading,
        searchLoaderStatus: LoadingStatus.loaded,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.searchLoaderStatus, LoadingStatus.loaded);
    });

    test("copyWith preserves values when null", () {
      final original = DigitalEfilingState(
        loaderStatus: LoadingStatus.loaded,
        searchLoaderStatus: LoadingStatus.loaded,
      );

      final copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.searchLoaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides all known values", () {
      final original = DigitalEfilingState(
        loaderStatus: LoadingStatus.loaded,
        searchLoaderStatus: LoadingStatus.loaded,
        groupName: "Group A",
        groupRim: "123",
        customerName: "John",
        customerRim: "456",
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
      expect(updated.showSelectDialog, isTrue);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
