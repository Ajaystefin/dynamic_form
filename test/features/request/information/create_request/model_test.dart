import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/create_request/model.dart";
import "package:wcas_frontend/features/request/information/create_request/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/group.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Fake implements BuildContext {
  @override
  bool get mounted => true;
}

void main() {
  late CreateRequestViewModel viewModel;
  late MockCustomerRepository mockCustomerRepo;
  late MockReferenceDataService mockRefService;
  late MockAlertManager mockAlertManager;

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, (call) async {
      if (call.method == "check") {
        return ["wifi"];
      }
      return null;
    });

    await EnvConfig.setEnvironment();

    mockCustomerRepo = MockCustomerRepository();
    mockRefService = MockReferenceDataService();
    mockAlertManager = MockAlertManager();

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

    viewModel = CreateRequestViewModel()..repository = mockCustomerRepo;

    AlertManager.overrideInstance = mockAlertManager;
    ReferenceDataService.overrideInstance = mockRefService;

    Globals.cleanGlobalCache();

    viewModel
      ..applicationTypes = [
        Reference(
          id: 1,
          reference3: "REQ1",
          reference2: ServerConstants.corperateCode,
        ),
        Reference(
          id: 2,
          reference3: "REQ1",
          reference2: ServerConstants.financialCode,
        ),
        Reference(
          id: 3,
          reference3: "REQ1",
          reference2: ServerConstants.corperateCode,
        ),
        Reference(
          id: 4,
          reference3: "REQ1",
          reference2: "${ServerConstants.corperateCode}, "
              "${ServerConstants.financialCode}",
        ),
      ]
      ..requestTypes = [
        Reference(id: 10, name: "Full CA"),
        Reference(
          id: ServerConstants.requestFinancialId,
          name: "Financial Request",
        ),
        Reference(
          id: 12,
          reference1: ServerConstants.isolatedMemo,
          name: "Isolated Memo",
        ),
      ];
  });

  tearDown(Globals.cleanGlobalCache);

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, (call) async {
      return null;
    });
  });

  void seedMandatorySelections({bool fi = false}) {
    viewModel
      ..selectedRequestType =
          Reference(id: 100, reference1: "REQ1", name: "Request 1")
      ..selectedApplicationType =
          Reference(id: 200, reference1: "APP1", name: "Application 1")
      ..businessSegmentValue = Reference(
        id: fi
            ? ServerConstants.financialInstitutionId
            : ServerConstants.businessSegmentId[BusinessSegment.corporate],
        name: fi ? "FI" : "Corporate",
      );

    if (fi) {
      viewModel.selectedCustomerType = Reference(
        id: 9999,
        name: "Bank",
      );
    }
  }

  group("CreateRequestState", () {
    test("constructor sets fields correctly", () {
      final state = CreateRequestState(
        loaderStatus: LoadingStatus.loading,
        showSelectDialog: true,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.showSelectDialog, isTrue);
    });

    test("copyWith keeps existing values when nothing passed", () {
      final original = CreateRequestState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.showSelectDialog, isFalse);
    });

    test("copyWith overrides fields", () {
      final original = CreateRequestState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(
        loaderStatus: LoadingStatus.error,
        showSelectDialog: true,
      );

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(updated.showSelectDialog, isTrue);
      expect(original.showSelectDialog, isFalse);
    });
  });

  group("initialization", () {
    test("initial state should be loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("init loads reference data and sets state to loaded", () async {
      final referenceData = {
        ReferenceDataKeys.requestType: [Reference(id: 1)],
        ReferenceDataKeys.customerType: [Reference(id: 2)],
        ReferenceDataKeys.applicationTypeCustom: [Reference(id: 3)],
        ReferenceDataKeys.applicationSegment: [
          Reference(
            id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
            name: "Corporate",
          ),
        ],
        ReferenceDataKeys.branchList: [Reference(id: 4)],
        ReferenceDataKeys.subSegmentValidation: [Reference(id: 5)],
      };

      when(() => mockRefService.getReferenceData(any()))
          .thenAnswer((_) async => referenceData);

      await viewModel.init();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.requestTypes.length, 1);
      expect(viewModel.customerTypes.length, 1);
      expect(viewModel.applicationTypes.length, 1);
      expect(viewModel.bussinessSegments.length, 1);
      expect(viewModel.branchList.length, 1);
      expect(viewModel.subSegmentValidation.length, 1);
      expect(
        viewModel.businessSegmentValue?.id,
        ServerConstants.businessSegmentId[BusinessSegment.corporate],
      );
    });

    test("loadReferenceData handles exception", () async {
      when(() => mockRefService.getReferenceData(any()))
          .thenThrow(Exception("reference load failed"));

      await viewModel.loadReferenceData();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("setValueOfBusinessSegment sets corporate by default", () {
      viewModel
        ..bussinessSegments = [
          Reference(id: 999, name: "Retail"),
          Reference(
            id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
            name: "Corporate",
          ),
        ]
        ..setValueOfBusinessSegment();

      expect(viewModel.businessSegmentValue?.name, "Corporate");
    });
  });

  group("simple methods and helpers", () {
    test("iFinancialInstitutionSelected returns true when FI selected", () {
      viewModel.businessSegmentValue = Reference(
        id: ServerConstants.financialInstitutionId,
      );
      expect(viewModel.iFinancialInstitutionSelected(), isTrue);
    });

    test("iFinancialInstitutionSelected returns false when not FI", () {
      viewModel.businessSegmentValue = Reference(id: 999);
      expect(viewModel.iFinancialInstitutionSelected(), isFalse);
    });

    test("isFieldsFilled returns true when all fields are filled", () {
      viewModel
        ..customerRimNo = "123"
        ..customerName = "John"
        ..groupId = "456"
        ..groupName = "Group";

      expect(viewModel.isFieldsFilled(), isTrue);
    });

    test("isFieldsFilled returns false when any field is missing", () {
      viewModel
        ..customerRimNo = "123"
        ..customerName = null
        ..groupId = "456"
        ..groupName = "Group";

      expect(viewModel.isFieldsFilled(), isFalse);
    });

    test("valueTruncateToMax returns empty when value is null", () {
      expect(viewModel.valueTruncateToMax(null, 5), "");
    });

    test("valueTruncateToMax truncates correctly", () {
      expect(viewModel.valueTruncateToMax("ABCDEFGHIJ", 4), "ABCD");
    });

    test("isApplicableForSegment returns true when segment exists", () {
      final ref = Reference(reference2: "C,F");
      expect(
        viewModel.isApplicableForSegment(ref, "C"),
        isTrue,
      );
    });

    test("isApplicableForSegment returns false when segment does not exist",
        () {
      final ref = Reference(reference2: "F");
      expect(
        viewModel.isApplicableForSegment(ref, "C"),
        isFalse,
      );
    });

    test("isApplicableForRoles returns true when any role exists", () {
      final ref = Reference(reference4: "CA,CCOOD");
      expect(
        viewModel.isApplicableForRoles(ref, ["CCOOD"]),
        isTrue,
      );
    });

    test("isApplicableForRoles returns false when roles do not match", () {
      final ref = Reference(reference4: "CA,CCOOD");
      expect(
        viewModel.isApplicableForRoles(ref, ["RM"]),
        isFalse,
      );
    });

    test("shouldValidateSegmentSubSegment returns a bool", () {
      final result = viewModel.shouldValidateSegmentSubSegment();
      expect(result, isA<bool>());
    });
  });

  group("business segment / request / application selections", () {
    test("onBussinessSegmentSelected updates selected business segment",
        () async {
      final segment = Reference(id: 99, name: "Segment X");

      await viewModel.onBussinessSegmentSelected(segment);

      expect(viewModel.businessSegmentValue, segment);
      expect(viewModel.requestCreate.businessSegment, segment);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "onRequestTypeChange updates"
        " selectedRequestType and resets application type", () async {
      final requestType = Reference(id: 1, reference1: "REQ1");

      viewModel.selectedApplicationType = Reference(id: 999);

      await viewModel.onRequestTypeChange(requestType);

      expect(viewModel.selectedRequestType, requestType);
      expect(viewModel.selectedApplicationType, isNull);
    });

    test("onApplicationTypeChanged updates selectedApplicationType", () {
      final applicationType = Reference(id: 5, reference1: "APP");

      viewModel.onApplicationTypeChanged(applicationType);

      expect(viewModel.selectedApplicationType, applicationType);
      expect(viewModel.requestCreate.applicationType, applicationType);
    });

    test("onCustomerTypeSelection updates selectedCustomerType", () async {
      final customerType = Reference(id: 8, name: "Corporate");

      await viewModel.onCustomerTypeSelection(customerType);

      expect(viewModel.selectedCustomerType, customerType);
      expect(viewModel.requestCreate.customerType, customerType);
    });

    test("applicationTypeItems returns corporate matching items", () {
      viewModel
        ..selectedRequestType = Reference(reference1: "REQ1")
        ..businessSegmentValue = Reference(
          id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
        );

      final result = viewModel.applicationTypeItems();

      expect(result.isNotEmpty, isTrue);
      expect(result.any((e) => e.id == 1), isTrue);
      expect(result.any((e) => e.id == 4), isTrue);
    });

    test("applicationTypeItems returns FI matching items", () {
      viewModel
        ..selectedRequestType = Reference(reference1: "REQ1")
        ..businessSegmentValue = Reference(
          id: ServerConstants
              .businessSegmentId[BusinessSegment.financialInstitution],
        );

      final result = viewModel.applicationTypeItems();

      expect(result.isNotEmpty, isTrue);
      expect(result.any((e) => e.id == 2), isTrue);
      expect(result.any((e) => e.id == 4), isTrue);
    });

    test("getRequestTypes filters out financial request for default users", () {
      final filtered = viewModel.getRequestTypes();

      expect(
        filtered.any((r) => r.id == ServerConstants.requestFinancialId),
        isFalse,
      );
    });
  });

  group("reset and field control", () {
    test("resetDependentFields clears dependent fields", () {
      viewModel
        ..customer = Customer(id: "1")
        ..customerName = "John"
        ..customerRimNo = "123"
        ..groupId = "456"
        ..groupName = "Group A"
        ..selectedRequestType = Reference(id: 1)
        ..selectedApplicationType = Reference(id: 2)
        ..selectedCustomerType = Reference(id: 3)
        ..selectedCustomer.value = Customer(id: "1")
        ..isSearched = true
        ..resetDependentFields();

      expect(viewModel.customer, isNull);
      expect(viewModel.customerName, isNull);
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.groupId, isNull);
      expect(viewModel.groupName, isNull);
      expect(viewModel.selectedRequestType, isNull);
      expect(viewModel.selectedApplicationType, isNull);
      expect(viewModel.selectedCustomerType, isNull);
      expect(viewModel.selectedCustomer.value, isNull);
      expect(viewModel.isSearched, isFalse);
    });

    test("onResetButtonPress clears fields and sets business segment default",
        () {
      viewModel
        ..bussinessSegments = [
          Reference(
            id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
            name: "Corporate",
          ),
        ]
        ..customer = Customer(id: "1")
        ..customerName = "John"
        ..customerRimNo = "123"
        ..groupId = "456"
        ..groupName = "Group"
        ..groupOwner = 5
        ..selectedCustomer.value = Customer(id: "1")
        ..onResetButtonPress();

      expect(viewModel.customer, isNull);
      expect(viewModel.customerName, isNull);
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.groupId, isNull);
      expect(viewModel.groupName, isNull);
      expect(viewModel.groupOwner, 0);
      expect(viewModel.selectedCustomer.value, isNull);
      expect(
        viewModel.businessSegmentValue?.id,
        ServerConstants.businessSegmentId[BusinessSegment.corporate],
      );
    });

    test("handleFieldControl disables other fields when data present", () {
      viewModel.handleFieldControl(ControlFields.customerName, "John");

      expect(viewModel.fieldCntrl.value[ControlFields.customerName], isFalse);
      expect(viewModel.fieldCntrl.value[ControlFields.customerRim], isTrue);
      expect(viewModel.fieldCntrl.value[ControlFields.groupID], isTrue);
      expect(viewModel.fieldCntrl.value[ControlFields.groupName], isTrue);
    });

    test("handleFieldControl resets fields when data empty", () {
      viewModel
        ..customerName = "John"
        ..customerRimNo = "111"
        ..groupId = "222"
        ..groupName = "Group"
        ..handleFieldControl(ControlFields.customerName, "");

      expect(viewModel.customerName, isNull);
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.groupId, isNull);
      expect(viewModel.groupName, isNull);
      expect(viewModel.fieldCntrl.value[ControlFields.customerName], isFalse);
    });

    test("stopAllLoaders resets all loading flags to loaded", () {
      viewModel
        ..customerRimNoLoadingStatus = LoadingStatus.loading
        ..customerNameLoadingStatus = LoadingStatus.loading
        ..groupIdLoadingStatus = LoadingStatus.loading
        ..groupNameLoadingStatus = LoadingStatus.loading
        ..submitLoadingStatus = LoadingStatus.loading;
      final before = viewModel.isResetPressed;

      viewModel.stopAllLoaders();

      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.groupIdLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.groupNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.submitLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.isResetPressed, isNot(before));
    });

    test("onSelectionCancelButtonPress resets state", () {
      viewModel
        ..customer = Customer(id: "1")
        ..customerName = "John"
        ..customerRimNo = "11"
        ..groupId = "22"
        ..groupName = "Group"
        ..groupOwner = 9
        ..isSearched = true
        ..onSelectionCancelButtonPress();

      expect(viewModel.customer, isNull);
      expect(viewModel.customerName, isNull);
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.groupId, isNull);
      expect(viewModel.groupName, isNull);
      expect(viewModel.groupOwner, 0);
      expect(viewModel.isSearched, isFalse);
      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.groupIdLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.groupNameLoadingStatus, LoadingStatus.loaded);
    });
  });

  group("region and segment validation", () {
    test("checkValidRegion returns true and updates region side effect", () {
      Globals.user = User(regions: ["Abu Dhabi"]);
      Globals.requestCustomerInfo = Customer();

      viewModel.branchList = [
        Reference(reference1: "BR1", reference2: "Abu Dhabi"),
      ];

      final customer = Customer(branchCode: "BR1");
      final result = viewModel.checkValidRegion(customer);

      expect(result, isTrue);
    });

    test(
        "checkValidSegment "
        "returns true when "
        "user segment matches customer segment", () {
      Globals.user = User(segments: ["Corporate"]);

      final result =
          viewModel.checkValidSegment(Customer(segment: "Corporate"));

      expect(result, isTrue);
    });

    test("checkValidSegment returns false when user segment does not match",
        () {
      Globals.user = User(segments: ["Corporate"]);

      final result = viewModel.checkValidSegment(Customer(segment: "Retail"));

      expect(result, isFalse);
    });

    test("checkValidBusinessSegment throws FI mismatch", () {
      viewModel.businessSegmentValue = Reference(
        id: ServerConstants
            .businessSegmentId[BusinessSegment.financialInstitution],
      );

      expect(
        () =>
            viewModel.checkValidBusinessSegment(Customer(segment: "Corporate")),
        throwsA(
          predicate((e) => e.toString().contains("common.segmentFiMismatch")),
        ),
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
        throwsA(
          predicate(
            (e) => e.toString().contains("common.segmentCorporateMismatch"),
          ),
        ),
      );
    });

    test("checkValidBusinessSegment does not throw when valid FI combination",
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

    test("validationCheck returns true when validation passes", () {
      final customer = Customer(segment: "Corporate", branchCode: "001");
      Globals.user = User(segments: ["Corporate"], regions: ["Abu Dhabi"]);
      viewModel.branchList = [
        Reference(reference1: "001", reference2: "Abu Dhabi"),
      ];

      final result = viewModel.validationCheck(customer);

      expect(result, isTrue);
      expect(viewModel.isSearched, isFalse);
    });
  });

  group("FI customer type / class code validation", () {
    test("validateCustomerTypeAgainstClassCode returns true when not FI", () {
      viewModel
        ..businessSegmentValue = Reference(id: 999)
        ..selectedCustomerType = Reference(id: 1, name: "Bank");

      final result = viewModel.validateCustomerTypeAgainstClassCode(
        Customer(classCode: "1234"),
      );

      expect(result, isTrue);
    });

    test(
        "validateCustomerTypeAgainstClassCode returns "
        "true when selectedCustomerType is null", () {
      viewModel
        ..businessSegmentValue = Reference(
          id: ServerConstants.financialInstitutionId,
        )
        ..selectedCustomerType = null;

      final result = viewModel.validateCustomerTypeAgainstClassCode(
        Customer(classCode: "1234"),
      );

      expect(result, isTrue);
    });

    test(
        "country type fails when class code is "
        "not country class code and gated false", () {
      viewModel
        ..businessSegmentValue = Reference(
          id: ServerConstants.financialInstitutionId,
        )
        ..selectedCustomerType = Reference(
          id: ServerConstants.countryIDFI,
          name: ServerConstants.countryNameFI,
        )
        ..isGroupIdNameFICountry = false;

      final result = viewModel.validateCustomerTypeAgainstClassCode(
        Customer(classCode: "9999"),
      );

      expect(result, isFalse);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("country type passes when class code matches country class code", () {
      viewModel
        ..businessSegmentValue = Reference(
          id: ServerConstants.financialInstitutionId,
        )
        ..selectedCustomerType = Reference(
          id: ServerConstants.countryIDFI,
          name: ServerConstants.countryNameFI,
        )
        ..isGroupIdNameFICountry = false;

      final result = viewModel.validateCustomerTypeAgainstClassCode(
        Customer(classCode: ServerConstants.countryClassCode),
      );

      expect(result, isTrue);
    });

    test(
        "bank type fails when class code equals "
        "country class code and gated false", () {
      viewModel
        ..businessSegmentValue = Reference(
          id: ServerConstants.financialInstitutionId,
        )
        ..selectedCustomerType = Reference(
          id: 99999,
          name: "Bank",
        )
        ..isGroupIdNameFICountry = false;

      final result = viewModel.validateCustomerTypeAgainstClassCode(
        Customer(classCode: ServerConstants.countryClassCode),
      );

      expect(result, isFalse);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("bank type passes when class code is not country class code", () {
      viewModel
        ..businessSegmentValue = Reference(
          id: ServerConstants.financialInstitutionId,
        )
        ..selectedCustomerType = Reference(
          id: 99999,
          name: "Bank",
        )
        ..isGroupIdNameFICountry = false;

      final result = viewModel.validateCustomerTypeAgainstClassCode(
        Customer(classCode: "1234"),
      );

      expect(result, isTrue);
    });

    test("validation is skipped when gating flag is true", () {
      viewModel
        ..businessSegmentValue = Reference(
          id: ServerConstants.financialInstitutionId,
        )
        ..selectedCustomerType = Reference(
          id: ServerConstants.countryIDFI,
          name: ServerConstants.countryNameFI,
        )
        ..isGroupIdNameFICountry = true;

      final result = viewModel.validateCustomerTypeAgainstClassCode(
        Customer(classCode: "9999"),
      );

      expect(result, isTrue);
    });

    test("checkCustomerTypeCountry resets statuses when invalid", () {
      viewModel
        ..businessSegmentValue = Reference(
          id: ServerConstants.financialInstitutionId,
        )
        ..selectedCustomerType = Reference(
          id: ServerConstants.countryIDFI,
          name: ServerConstants.countryNameFI,
        )
        ..isGroupIdNameFICountry = false
        ..customerRimNoLoadingStatus = LoadingStatus.loading
        ..customerNameLoadingStatus = LoadingStatus.loading
        ..groupIdLoadingStatus = LoadingStatus.loading
        ..groupNameLoadingStatus = LoadingStatus.loading
        ..submitLoadingStatus = LoadingStatus.loading
        ..checkCustomerTypeCountry(
          Customer(classCode: "9999"),
        );

      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.groupIdLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.groupNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.submitLoadingStatus, LoadingStatus.loaded);
    });
  });

  group("selection dialog and filter", () {
    test("onSelectionPressed shows toast when no customer selected", () {
      viewModel.selectedCustomer.value = null;

      viewModel.onSelectionPressed(MockBuildContext());

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onSelectionPressed populates fields when selection exists", () async {
      final customer = Customer(
        preferredName: "John",
        id: "25",
        branchCode: "3",
        segment: "Corporate",
        customerRimNo: 5,
        groups: const Group(id: "5", name: "Demo", groupOwner: 25),
      );

      Globals.user = User(regions: ["Abu Dhabi"], segments: ["Corporate"]);
      viewModel
        ..selectedCustomer.value = customer
        ..branchList = [
          Reference(reference1: "3", reference2: "Abu Dhabi"),
        ];
      await viewModel.onSelectionPressed(MockBuildContext());

      expect(viewModel.customer?.id, "25");
      expect(viewModel.customerRimNo, "25");
      expect(viewModel.groupId, "5");
      expect(viewModel.groupName, "Demo");
      expect(viewModel.isSearched, isTrue);
    });

    test("filterCustomers shows toast when allCustomers is empty", () {
      viewModel
        ..allCustomers = []
        ..filterCustomers();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("filterCustomers returns all customers when search term is empty", () {
      final c1 = Customer(preferredName: "Alice");
      final c2 = Customer(preferredName: "Bob");

      viewModel
        ..allCustomers = [c1, c2]
        ..customerName = ""
        ..isGroupNameSelection = false
        ..filterCustomers();

      expect(viewModel.dailogCustomers.length, 2);
      expect(viewModel.dailogCustomers, containsAll([c1, c2]));
    });

    test("filterCustomers filters by customer name", () {
      final c1 = Customer(preferredName: "Alice");
      final c2 = Customer(preferredName: "Bob");

      viewModel
        ..allCustomers = [c1, c2]
        ..customerName = "ali"
        ..isGroupNameSelection = false
        ..filterCustomers();

      expect(viewModel.dailogCustomers.length, 1);
      expect(viewModel.dailogCustomers.first, c1);
    });

    test("filterCustomers filters by group name", () {
      final c1 = Customer(groups: const Group(name: "Group A"));
      final c2 = Customer(groups: const Group(name: "Group B"));

      viewModel
        ..allCustomers = [c1, c2]
        ..groupName = "group b"
        ..isGroupNameSelection = true
        ..filterCustomers();

      expect(viewModel.dailogCustomers.length, 1);
      expect(viewModel.dailogCustomers.first, c2);
    });

    test("filterCustomers excludes null customers", () {
      final c1 = Customer(preferredName: "Alice");

      viewModel
        ..allCustomers = [c1, null]
        ..customerName = "ali"
        ..isGroupNameSelection = false
        ..filterCustomers();

      expect(viewModel.dailogCustomers.length, 1);
      expect(viewModel.dailogCustomers.first, c1);
    });
  });

  group("search button guards", () {
    test("onGroupNameSearchPressed shows toast when groupName invalid",
        () async {
      viewModel
        ..groupName = "abc"
        ..isSearched = false;

      await viewModel.onGroupNameSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onGroupIdSearchPressed shows toast when groupId empty", () async {
      viewModel
        ..groupId = ""
        ..isSearched = false;

      await viewModel.onGroupIdSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onGroupIdSearchPressed shows toast when already searched", () async {
      viewModel
        ..groupId = "123"
        ..isSearched = true;

      await viewModel.onGroupIdSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onCustomerRimNoSearchPressed shows toast when rim empty", () async {
      viewModel
        ..customerRimNo = ""
        ..isSearched = false;

      await viewModel.onCustomerRimNoSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onCustomerRimNoSearchPressed shows toast when already searched",
        () async {
      viewModel
        ..customerRimNo = "123"
        ..isSearched = true;

      await viewModel.onCustomerRimNoSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onCustomerNameSearchPressed shows toast when invalid", () async {
      viewModel
        ..customerName = "abc"
        ..isSearched = false;

      await viewModel.onCustomerNameSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("search flows", () {
    test("onCustomerSearchPressed shows toast when required dropdowns missing",
        () async {
      viewModel
        ..selectedRequestType = null
        ..selectedApplicationType = null
        ..businessSegmentValue = null;

      await viewModel.onCustomerSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, isFalse);
      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.groupIdLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.groupNameLoadingStatus, LoadingStatus.loaded);
    });

    test("onCustomerSearchPressed requires customer type for FI", () async {
      viewModel
        ..selectedRequestType = Reference(id: 1)
        ..selectedApplicationType = Reference(id: 2)
        ..businessSegmentValue =
            Reference(id: ServerConstants.financialInstitutionId)
        ..selectedCustomerType = null;

      await viewModel.onCustomerSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

test(
  "search by customer RIM uses searchUserDetails and populates fields",
  () async {
    seedMandatorySelections();

    final customer = Customer(
      id: "123",
      groups: const Group(id: "456", name: "Group A", groupOwner: 123),
    );

    viewModel
      ..repository = mockCustomerRepo
      ..customerRimNoLoadingStatus = LoadingStatus.loading
      ..customerRimNo = "123";

    when(() => mockCustomerRepo.searchUserDetails(
          any(),
          any(),
          any(),
          any(),
    ),).thenAnswer((_) async => customer); 

    await viewModel.onCustomerSearchPressed();

    expect(viewModel.customer?.id, "123");
    expect(viewModel.customerRimNo, "123");
    expect(viewModel.customerName, "");
    expect(viewModel.groupId, "456"); 
    expect(viewModel.groupName, "Group A");
    expect(viewModel.groupOwner, 123);
    expect(viewModel.isSearched, isTrue);
  },
);
 
    test(
    "search by customer name with single result "
        "opens dialog list and populates fields",
  () async {
    seedMandatorySelections();

    final customer = Customer(
      id: "101",
      preferredName: "Alice",
      groups: const Group(
        id: "G1",
        name: "Group One",
        groupOwner: 101,
      ),
    );

    viewModel
      ..customerNameLoadingStatus = LoadingStatus.loading
      ..customerName = "Alice"

    ..repository = mockCustomerRepo;

    when(() => mockCustomerRepo.searchCustomerProfile(any(), any(), any()))
        .thenAnswer((_) async => [customer]);

    await viewModel.onCustomerSearchPressed();

   
    expect(viewModel.customer?.id, "101");
    expect(viewModel.dailogCustomers.length, 1);
    expect(viewModel.allCustomers.length, 1);
    expect(viewModel.state.showSelectDialog, true);
    expect(viewModel.groupId, isNull);
    expect(viewModel.groupName, isNull);
  },
);

    test(
        "search by customer name with multiple "
        "results stores dialog list and returns early", () async {
      seedMandatorySelections();
      final c1 = Customer(id: "1", preferredName: "John");
      final c2 = Customer(id: "2", preferredName: "Johnny");

      viewModel
        ..customerNameLoadingStatus = LoadingStatus.loading
        ..customerName = "John";

      when(() => mockCustomerRepo.searchCustomerProfile("John", null, null))
          .thenAnswer((_) async => [c1, c2]);

      await viewModel.onCustomerSearchPressed();

      expect(viewModel.customer, isNull);
      expect(viewModel.dailogCustomers.length, 2);
      expect(viewModel.allCustomers.length, 2);
      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
    });

    test("search by groupId with multiple results selects group owner",
        () async {
      seedMandatorySelections();
      final c1 = Customer(
        id: "10",
        groups: const Group(id: "500", name: "Main Group", groupOwner: 10),
      );
      final c2 = Customer(
        id: "20",
        groups: const Group(id: "500", name: "Main Group", groupOwner: 10),
      );

      viewModel
        ..groupIdLoadingStatus = LoadingStatus.loading
        ..groupId = "500";

      when(() => mockCustomerRepo.searchCustomerProfile(null, "500", null))
          .thenAnswer((_) async => [c1, c2]);

      await viewModel.onCustomerSearchPressed();

      expect(viewModel.customer?.id, "10");
      expect(viewModel.customerRimNo, "10");
      expect(viewModel.groupId, "500");
      expect(viewModel.groupName, "Main Group");
      expect(viewModel.groupOwner, 10);
    });

    test("search result empty shows toast", () async {
      seedMandatorySelections();
      viewModel
        ..customerNameLoadingStatus = LoadingStatus.loading
        ..customerName = "Unknown";

      when(() => mockCustomerRepo.searchCustomerProfile("Unknown", null, null))
          .thenAnswer((_) async => []);

      await viewModel.onCustomerSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, isFalse);
    });

    test("search throws exception and is caught", () async {
      seedMandatorySelections();
      viewModel
        ..customerNameLoadingStatus = LoadingStatus.loading
        ..customerName = "Error";

      when(() => mockCustomerRepo.searchCustomerProfile("Error", null, null))
          .thenThrow(Exception("Network failure"));

      await viewModel.onCustomerSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, isFalse);
      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
    });

    test("onGroupNameSearchPressed valid path sets flags and calls search",
        () async {
      seedMandatorySelections();
      final customer = Customer(
        id: "101",
        groups: const Group(id: "G1", name: "Group One", groupOwner: 101),
      );

      viewModel
        ..groupName = "Group One"
        ..isSearched = false;

      when(
        () => mockCustomerRepo.searchCustomerProfile(null, null, "Group One"),
      ).thenAnswer((_) async => [customer]);

      await viewModel.onGroupNameSearchPressed(showDialog: false);

      expect(viewModel.groupNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.isGroupNameSelection, isTrue);
      expect(viewModel.isGroupIdNameFICountry, isTrue);
    });

    test("onGroupIdSearchPressed valid path sets flags and calls search",
        () async {
      seedMandatorySelections();
      final ownerCustomer = Customer(
        id: "10",
        groups: const Group(id: "500", name: "Main Group", groupOwner: 10),
      );

      viewModel
        ..groupId = "500"
        ..isSearched = false;

      when(() => mockCustomerRepo.searchCustomerProfile(null, "500", null))
          .thenAnswer((_) async => [ownerCustomer]);

      await viewModel.onGroupIdSearchPressed();

      expect(viewModel.groupIdLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.isGroupIdNameFICountry, isTrue);
    });

    test("onCustomerRimNoSearchPressed valid path sets flags and calls search",
        () async {
      seedMandatorySelections();
      final customer = Customer(
        id: "123",
        groups: const Group(id: "G2", name: "Group Two", groupOwner: 123),
      );

      viewModel
        ..customerRimNo = "123"
        ..isSearched = false;

      when(() => mockCustomerRepo.searchUserDetails("123", null, null, null))
          .thenAnswer((_) async => customer);

      await viewModel.onCustomerRimNoSearchPressed();

      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.isGroupIdNameFICountry, isFalse);
    });

    test("onCustomerNameSearchPressed valid path sets flags and calls search",
        () async {
      seedMandatorySelections();
      final customer = Customer(
        id: "321",
        groups: const Group(id: "G3", name: "Group Three", groupOwner: 321),
      );

      viewModel
        ..customerName = "John Smith"
        ..isSearched = false;

      when(
        () => mockCustomerRepo.searchCustomerProfile("John Smith", null, null),
      ).thenAnswer((_) async => [customer]);

      await viewModel.onCustomerNameSearchPressed(showDialog: false);

      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.isGroupNameSelection, isFalse);
      expect(viewModel.isGroupIdNameFICountry, isFalse);
    });
  });

  group("validateSubSegment", () {
    test("calls repository.validateSubSegment when criteria met", () async {
      Globals.user = User(currentRole: Role(roleId: 100));
      when(() => mockCustomerRepo.validateSubSegment("RM1"))
          .thenAnswer((_) async {});

      await (viewModel
            ..subSegmentValidation = [
              Reference(
                reference1: ServerConstants.subSegmentValidationRefId,
                reference2: "100,101",
              ),
            ]
            ..customer = Customer(
              relationshipMgr: <Map<String, String>>[
                <String, String>{"RelationshipMgrUserId": "RM1"},
              ],
            ))
          .validateSubSegment();

      verify(() => mockCustomerRepo.validateSubSegment("RM1")).called(1);
    });

    test("does not call repository when role does not match", () async {
      Globals.user = User(currentRole: Role(roleId: 200));
      await (viewModel
            ..subSegmentValidation = [
              Reference(
                reference1: ServerConstants.subSegmentValidationRefId,
                reference2: "100,101",
              ),
            ])
          .validateSubSegment();

      verifyNever(() => mockCustomerRepo.validateSubSegment(any()));
    });

    test("rethrows and keeps fields when repository throws", () async {
      Globals.user = User(currentRole: Role(roleId: 100));
      viewModel
        ..subSegmentValidation = [
          Reference(
            reference1: ServerConstants.subSegmentValidationRefId,
            reference2: "100",
          ),
        ]
        ..customerName = "John"
        ..customerRimNo = "123"
        ..groupId = "555"
        ..groupName = "Group"
        ..isSearched = true
        ..customer = Customer(
          relationshipMgr: <Map<String, String>>[
            <String, String>{"RelationshipMgrUserId": "RM1"},
          ],
        );

      when(() => mockCustomerRepo.validateSubSegment("RM1"))
          .thenThrow(Exception("Validation failed"));

      await expectLater(
        () => viewModel.validateSubSegment(),
        throwsA(isA<Exception>()),
      );

      expect(viewModel.customerName, "John");
      expect(viewModel.customerRimNo, "123");
      expect(viewModel.groupId, "555");
      expect(viewModel.groupName, "Group");
      expect(viewModel.isSearched, isFalse);
    });
  });

  group("submit validation and submit flow", () {
    test("submitButtonValidation returns true when customer missing", () {
      expect(viewModel.submitButtonValidation(), isTrue);
    });

    test(
        "submitButtonValidation returns false when "
        "mandatory fields exist for corporate", () {
      viewModel
        ..customer = Customer(id: "123")
        ..selectedRequestType = Reference(id: 1)
        ..selectedApplicationType = Reference(id: 2)
        ..businessSegmentValue = Reference(
          id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
        );

      expect(viewModel.submitButtonValidation(), isFalse);
    });

    test(
        "submitButtonValidation returns true for FI when customer type missing",
        () {
      viewModel
        ..customer = Customer(id: "123")
        ..selectedRequestType = Reference(id: 1)
        ..selectedApplicationType = Reference(id: 2)
        ..businessSegmentValue =
            Reference(id: ServerConstants.financialInstitutionId)
        ..selectedCustomerType = null;

      expect(viewModel.submitButtonValidation(), isTrue);
    });

    test(
        "submitButtonValidation returns false "
        "for FI when customer type selected", () {
      viewModel
        ..customer = Customer(id: "123")
        ..selectedRequestType = Reference(id: 1)
        ..selectedApplicationType = Reference(id: 2)
        ..businessSegmentValue =
            Reference(id: ServerConstants.financialInstitutionId)
        ..selectedCustomerType = Reference(id: 99);

      expect(viewModel.submitButtonValidation(), isFalse);
    });

    test("onSubmitButtonPress shows failure toast when invalid", () async {
      await viewModel.onSubmitButtonPress(isValidated: false);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.submitLoadingStatus, LoadingStatus.loaded);
    });

    test("onSubmitButtonPress ends safely when FI classCode validation fails",
        () async {
      seedMandatorySelections(fi: true);

      viewModel
        ..selectedCustomerType = Reference(
          id: ServerConstants.countryIDFI,
          name: ServerConstants.countryNameFI,
        )
        ..customer = Customer(
          id: "123",
          classCode: "9999",
          groups: const Group(id: "456", name: "Group A", groupOwner: 123),
        )
        ..customerRimNo = "123"
        ..customerName = "Very Long Customer Name Example"
        ..groupId = "456"
        ..groupName = "Very Long Group Name Example"
        ..groupOwner = 123
        ..isGroupIdNameFICountry = false;

      await viewModel.onSubmitButtonPress(isValidated: true);

      expect(viewModel.submitLoadingStatus, LoadingStatus.loaded);
      expect(Globals.request, isNotNull);
      expect(Globals.request?.isCreateRequest, isTrue);
    });
  });

  group("widget/form validation", () {
    testWidgets("form validation works", (tester) async {
      viewModel.formKey = GlobalKey<FormState>();
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: viewModel.formKey,
              child: TextFormField(
                controller: controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Required";
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      expect(viewModel.formKey.currentState!.validate(), isFalse);

      controller.text = "Valid input";
      await tester.pump();

      expect(viewModel.formKey.currentState!.validate(), isTrue);
    });
  });
}
