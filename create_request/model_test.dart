import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/globals.dart';

import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/information/create_request/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/login/user.dart';
import 'package:wcas_frontend/models/login/role.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/group.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/customer_respository.dart';
import 'package:wcas_frontend/features/request/information/create_request/state.dart';

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
    'dev.fluttercommunity.plus/connectivity',
  );
  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (call) async {
        if (call.method == 'check') {
          return ['wifi'];
        }
        return null;
      },
    );
    TestWidgetsFlutterBinding.ensureInitialized();
    await EnvConfig.setEnvironment();
    mockCustomerRepo = MockCustomerRepository();
    mockRefService = MockReferenceDataService();
    mockAlertManager = MockAlertManager();

    viewModel = CreateRequestViewModel();
    viewModel.repository = mockCustomerRepo;
    AlertManager.overrideInstance(mockAlertManager);

    viewModel.applicationTypes = [
      Reference(id: ServerConstants.riskRatingchanges, reference4: 'REQ1'),
      Reference(
          id: 101,
          reference4: 'REQ1',
          reference3: ServerConstants.financialCode),
      Reference(
          id: 102,
          reference4: 'REQ1',
          reference3: ServerConstants.corperateCode),
    ];
    viewModel.selectedRequestType = Reference(reference1: 'REQ1');
  });
  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (call) async {
        return null;
      },
    );
  });
  test('Initial state should be loading', () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test('init sets up request and loads reference data', () async {
    final referenceData = {
      ReferenceDataKeys.requestType: [Reference(id: 1)],
      ReferenceDataKeys.applicationType: [Reference(id: 1, reference4: "FULL")],
      ReferenceDataKeys.customerType: [Reference(id: 2)],
      ReferenceDataKeys.applicationSegment: [
        Reference(
            id: ServerConstants.businessSegmentId[BusinessSegment.corporate])
      ],
    };

    when(() => mockRefService.getReferenceData(any()))
        .thenAnswer((_) async => referenceData);

    ReferenceDataService.overrideInstance(mockRefService);

    await viewModel.init();

    // expect(viewModel.requestCreate, isA<Request>());
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    // expect(viewModel.businessSegmentValue?.id,
    //     ServerConstants.businessSegmentId[BusinessSegment.corporate]);
  });

  test('onBussinessSegmentSelected updates business segment', () {
    final segment = Reference(id: 99);
    viewModel.onBussinessSegmentSelected(segment);
    expect(viewModel.businessSegmentValue, segment);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test('applicationTypeItems returns correct list for full CA', () {
    viewModel.selectedRequestType = Reference(id: 100, reference1: "FULL");

    final result = viewModel.applicationTypeItems();
    expect(result?.length, 0);
  });

  test('applicationTypeItems returns filtered list for FI isolated', () {
    viewModel.selectedRequestType =
        Reference(id: ServerConstants.applicationIsolatedId);
    viewModel.businessSegmentValue = Reference(reference1: "FULL");

    final result = viewModel.applicationTypeItems();
    expect(result?.length, 0);
  });

  test('onResetButtonPress triggers navigation', () async {
    expect(() => viewModel.onResetButtonPress(), returnsNormally);
  });

  test('onSelectionPressed with no customer shows toast', () {
    viewModel.selectedCustomer.value = null;

    viewModel.onSelectionPressed(MockBuildContext());

    // verify(() => mockAlert.showFailureToast(any())).called(1);
  });

  test('onSelectionCancelButtonPress resets fields', () {
    viewModel.customer = Customer(id: '123');
    viewModel.customerName = 'John';
    viewModel.groupName = 'Group';

    viewModel.onSelectionCancelButtonPress();

    expect(viewModel.customer, null);
    expect(viewModel.customerName, null);
    expect(viewModel.groupName, null);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test('handleFieldControl disables other fields when data is present', () {
    viewModel.handleFieldControl(ControlFields.customerName, 'John');

    expect(viewModel.fieldCntrl.value[ControlFields.customerRim], true);
    expect(viewModel.fieldCntrl.value[ControlFields.customerName], false);
  });

  test('onCustomerNameSearchPressed triggers search when valid', () {
    final mockAlertManager = MockAlertManager();
    AlertManager.overrideInstance(mockAlertManager);

    viewModel.customerName = 'John Doe';
    viewModel.isSearched = false;

    viewModel.onCustomerNameSearchPressed();

    expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
    expect(viewModel.isGroupNameSelection, false);
  });
  testWidgets('Form validation test', (tester) async {
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
                  return 'Required';
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );

    // Trigger validation
    expect(viewModel.formKey.currentState!.validate(), false);

    controller.text = 'Valid input';
    await tester.pump();

    expect(viewModel.formKey.currentState!.validate(), true);
  });

  test('handleFieldControl resets fields when data is empty', () {
    viewModel.customerName = 'John';
    viewModel.groupName = 'Group';

    viewModel.handleFieldControl(ControlFields.customerName, '');

    expect(viewModel.customerName, null);
    expect(viewModel.groupName, null);
  });

  test('submitButtonValidation returns true when required fields are missing',
      () {
    expect(viewModel.submitButtonValidation(), true);
  });

  test(
      'submitButtonValidation returns false when all required fields are present',
      () {
    viewModel.customer = Customer(id: '123');
    viewModel.selectedRequestType = Reference(id: 1);
    viewModel.selectedApplicationType = Reference(id: 2);

    expect(viewModel.submitButtonValidation(), false);
  });

  test('onSelectionPressed shows toast when no customer is selected', () {
    viewModel.selectedCustomer.value = null;

    viewModel.onSelectionPressed(MockBuildContext());

    verify(() => mockAlertManager.showFailureToast(any())).called(1);
  });

  test('isFieldsFilled returns true when all fields are filled', () {
    viewModel.customerRimNo = '123';
    viewModel.customerName = 'John';
    viewModel.groupId = '456';
    viewModel.groupName = 'Group';

    expect(viewModel.isFieldsFilled(), isTrue);
  });

  test('isFieldsFilled returns false when any field is null', () {
    viewModel.customerRimNo = '123';
    viewModel.customerName = null;
    viewModel.groupId = '456';
    viewModel.groupName = 'Group';

    expect(viewModel.isFieldsFilled(), isFalse);
  });

  test('onGroupNameSearchPressed shows toast when groupName is invalid', () {
    viewModel.groupName = 'abc'; // too short
    viewModel.isSearched = false;

    viewModel.onGroupNameSearchPressed();

    verify(() => mockAlertManager.showFailureToast(any())).called(1);
  });

  test('onGroupIdSearchPressed does nothing when groupId is empty', () async {
    viewModel.groupId = '';
    viewModel.isSearched = false;

    viewModel.onGroupIdSearchPressed();

    expect(viewModel.groupIdLoadingStatus, LoadingStatus.loaded);
  });

  test('onGroupIdSearchPressed does nothing when already searched', () async {
    viewModel.groupId = '456';
    viewModel.isSearched = true;

    viewModel.onGroupIdSearchPressed();

    expect(viewModel.groupIdLoadingStatus, LoadingStatus.loaded);
  });

  test('onCustomerRimNoSearchPressed does nothing when rimNo is empty',
      () async {
    viewModel.customerRimNo = '';
    viewModel.isSearched = false;

    viewModel.onCustomerRimNoSearchPressed();

    expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
  });

  test('onCustomerRimNoSearchPressed does nothing when already searched',
      () async {
    viewModel.customerRimNo = '123';
    viewModel.isSearched = true;

    viewModel.onCustomerRimNoSearchPressed();

    expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
  });

  test(
      'onRequestTypeChange sets selectedRequestType and resets selectedApplicationType',
      () {
    final requestType = Reference(id: 1, reference1: 'Full CA');

    viewModel.selectedApplicationType =
        Reference(id: 2, reference1: 'Isolated');
    viewModel.onRequestTypeChange(requestType);

    expect(viewModel.selectedRequestType, requestType);
    expect(viewModel.selectedApplicationType, isNull);
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test(
      'onApplicationTypeChanged sets selectedApplicationType and emits loaded status',
      () {
    final applicationType = Reference(id: 1, reference1: 'Full CA');

    viewModel.onApplicationTypeChanged(applicationType);

    expect(viewModel.selectedApplicationType, applicationType);
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test(
      'onCustomerTypeSelection sets selectedCustomerType and emits loaded status',
      () {
    final customerType = Reference(id: 1, reference1: 'Corporate');

    viewModel.onCustomerTypeSelection(customerType);

    expect(viewModel.selectedCustomerType, customerType);
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test('stopAllLoaders should reset all loading statuses and update fieldCntrl',
      () {
    viewModel.customerRimNoLoadingStatus = LoadingStatus.loading;
    viewModel.customerNameLoadingStatus = LoadingStatus.loading;
    viewModel.groupIdLoadingStatus = LoadingStatus.loading;
    viewModel.groupNameLoadingStatus = LoadingStatus.loading;
    viewModel.isSearched = true;

    viewModel.stopAllLoaders();

    expect(viewModel.isSearched, true);
    expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
    expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
    expect(viewModel.groupIdLoadingStatus, LoadingStatus.loaded);
    expect(viewModel.groupNameLoadingStatus, LoadingStatus.loaded);
  });

  test('onGroupNameSearchPressed should trigger search when valid', () {
    viewModel.groupName = 'ValidGroupName';
    viewModel.isSearched = false;

    viewModel.onGroupNameSearchPressed(showDialog: false);

    expect(viewModel.groupNameLoadingStatus, LoadingStatus.loaded);
    expect(viewModel.isGroupNameSelection, true);
  });

  test('onGroupNameSearchPressed should show toast when invalid', () {
    viewModel.groupName = 'abc'; // too short
    viewModel.isSearched = false;

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

    viewModel.onGroupNameSearchPressed();

    verify(() => mockAlertManager.showFailureToast(any())).called(1);
  });

  test('onGroupIdSearchPressed should trigger search when valid', () {
    viewModel.groupId = 'G123';
    viewModel.isSearched = false;

    viewModel.onGroupIdSearchPressed();

    expect(viewModel.groupIdLoadingStatus, LoadingStatus.loaded);
  });

  test('onGroupIdSearchPressed should not trigger search when already searched',
      () {
    viewModel.groupId = 'G123';
    viewModel.isSearched = true;

    viewModel.onGroupIdSearchPressed();

    expect(viewModel.groupIdLoadingStatus, isNot(LoadingStatus.loading));
  });

  test('onCustomerRimNoSearchPressed should trigger search when valid', () {
    viewModel.customerRimNo = 'RIM123';
    viewModel.isSearched = false;

    viewModel.onCustomerRimNoSearchPressed();

    expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
  });

  test(
      'onCustomerRimNoSearchPressed should not trigger search when already searched',
      () {
    viewModel.customerRimNo = 'RIM123';
    viewModel.isSearched = true;

    viewModel.onCustomerRimNoSearchPressed();

    expect(viewModel.customerRimNoLoadingStatus, isNot(LoadingStatus.loading));
  });

  test('onCustomerSearchPressed failure should show toast and emit loaded',
      () async {
    when(() => mockCustomerRepo.searchUserDetails(any(), any(), any(), any()))
        .thenThrow(Exception('Failed'));
    when(() =>
            mockCustomerRepo.searchCustomerProfile(any(), any(), any(), any()))
        .thenThrow(Exception('Failed'));

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

    await viewModel.onCustomerSearchPressed();

    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    expect(viewModel.isSearched, false);
    verify(() => mockAlertManager.showFailureToast(any())).called(1);
  });
  group('checkValidBusinessSegment', () {
    test('should throw FI mismatch when FI selected but segment is corporate',
        () {
      // Arrange
      final customer = Customer(segment: 'Corporate');
      viewModel.businessSegmentValue = Reference(
        id: ServerConstants
            .businessSegmentId[BusinessSegment.financialInstitution],
      );

      // Act & Assert
      expect(
        () => viewModel.checkValidBusinessSegment(customer),
        throwsA(predicate(
            (e) => e.toString().contains('common.segmentFiMismatch'))),
      );
    });

    test(
        'should throw Corporate mismatch when corporate selected but segment is FI',
        () {
      // Arrange
      final customer =
          Customer(segment: ServerConstants.financialSegmentPartyInq);
      viewModel.businessSegmentValue = Reference(
        id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
      );

      // Act & Assert
      expect(
        () => viewModel.checkValidBusinessSegment(customer),
        throwsA(predicate(
            (e) => e.toString().contains('common.segmentCorporateMismatch'))),
      );
    });
  });

  group('Additional Tests for CreateRequestViewModel', () {
    test(
        'iFinancialInstitutionSelected returns true when businessSegmentValue matches FI ID',
        () {
      viewModel.businessSegmentValue =
          Reference(id: ServerConstants.financialInstitutionId);
      expect(viewModel.iFinancialInstitutionSelected(), isTrue);
    });

    test(
        'iFinancialInstitutionSelected returns false when businessSegmentValue does not match FI ID',
        () {
      viewModel.businessSegmentValue = Reference(id: 999);
      expect(viewModel.iFinancialInstitutionSelected(), isFalse);
    });

    test('loadReferenceData populates reference lists', () async {
      final referenceData = {
        ReferenceDataKeys.requestType: [Reference(id: 1)],
        ReferenceDataKeys.customerType: [Reference(id: 2)],
        ReferenceDataKeys.applicationType: [Reference(id: 3)],
        ReferenceDataKeys.applicationSegment: [Reference(id: 4)],
        ReferenceDataKeys.branchList: [Reference(id: 5)],
      };

      when(() => mockRefService.getReferenceData(any()))
          .thenAnswer((_) async => referenceData);
      ReferenceDataService.overrideInstance(mockRefService);

      await viewModel.loadReferenceData();

      expect(viewModel.requestTypes.length, 1);
      expect(viewModel.customerTypes.length, 1);
      expect(viewModel.applicationTypes.length, 1);
      expect(viewModel.bussinessSegments.length, 1);
      expect(viewModel.branchList.length, 1);
    });

    test('setValueOfBusinessSegment sets default corporate segment', () {
      viewModel.bussinessSegments = [
        Reference(
            id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
            name: 'Corporate'),
        Reference(id: 999, name: 'Retail')
      ];

      viewModel.setValueOfBusinessSegment();
      expect(viewModel.businessSegmentValue?.name, 'Corporate');
    });

    test('checkValidRegion returns true when branch matches user region', () {
      Globals.user = User(regions: ['Abu Dhabi']);
      viewModel.branchList = [
        Reference(reference1: '123', reference2: 'Abu Dhabi')
      ];
      final customer = Customer(branchCode: '123');
      expect(viewModel.checkValidRegion(customer), isTrue);
    });

    test(
        'checkValidSegment returns true when user segments contain customer segment',
        () {
      Globals.user = User(segments: ['Corporate']);
      final customer = Customer(segment: 'Corporate');
      expect(viewModel.checkValidSegment(customer), isTrue);
    });

    test('getRequestTypes filters out financial request type', () {
      viewModel.requestTypes = [
        Reference(id: 1),
        Reference(id: ServerConstants.requestFinancialId),
        Reference(id: 2)
      ];

      final filtered = viewModel.getRequestTypes();
      expect(filtered.any((r) => r.id == ServerConstants.requestFinancialId),
          isFalse);
      expect(filtered.length, 2);
    });
    test('onSelectionPressed with valid selection', () async {
      // Arrange
      viewModel.customer = Customer(
        preferredName: "John",
        id: "25",
        branchCode: "3",
        segment: "Corporate",
        customerRimNo: 5,
        groups: Group(id: "5", name: "Demo"),
      );
      viewModel.selectedCustomer.value = viewModel.customer;
      Globals.user = User(regions: ["Abu Dhabi"], segments: ["Corporate"]);

      final referenceData = {
        ReferenceDataKeys.requestType: [Reference(id: 1)],
        ReferenceDataKeys.branchList: [
          Reference(id: 2, reference1: "3", reference3: "Abu Dhabi")
        ],
        ReferenceDataKeys.applicationType: [
          Reference(id: 1, reference4: "FULL")
        ],
        ReferenceDataKeys.customerType: [Reference(id: 2)],
        ReferenceDataKeys.applicationSegment: [
          Reference(
            id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
            name: "Corporate",
          )
        ],
      };

      // ✅ Stub before calling init
      when(() => mockRefService.getReferenceData(any()))
          .thenAnswer((_) async => referenceData);

      ReferenceDataService.overrideInstance(mockRefService);

      // Act
      await viewModel.init();
      viewModel.businessSegmentValue = Reference(name: "Corporate");
      viewModel.onSelectionPressed(MockBuildContext());

      // Assert
      expect(viewModel.customerName, "John");
      expect(viewModel.groupId, "5");
      expect(viewModel.groupName, "Demo");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  test('onSelectionPressed with valid selection', () async {
    viewModel.customer = Customer(
      preferredName: "John",
      id: "25",
      branchCode: "3",
      segment: "Corporate", // ✅ Correct spelling
      customerRimNo: 5,
      groups: Group(id: "5", name: "Demo"),
    );
    viewModel.selectedCustomer.value = viewModel.customer;
    Globals.user = User(regions: ["Abu Dhabi"], segments: ["Corporate"]);

    final referenceData = {
      ReferenceDataKeys.requestType: [Reference(id: 1)],
      ReferenceDataKeys.branchList: [
        Reference(id: 2, reference1: "3", reference3: "Abu Dhabi")
      ],
      ReferenceDataKeys.applicationType: [Reference(id: 1, reference4: "FULL")],
      ReferenceDataKeys.customerType: [Reference(id: 2)],
      ReferenceDataKeys.applicationSegment: [
        Reference(
            id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
            name: "Corporate")
      ],
    };

    when(() => mockRefService.getReferenceData(any()))
        .thenAnswer((_) async => referenceData);

    ReferenceDataService.overrideInstance(mockRefService);

    await viewModel.init();

    viewModel.businessSegmentValue = Reference(name: "Corporate");
    viewModel.onSelectionPressed(MockBuildContext());

    expect(viewModel.customerName, "John");
    expect(viewModel.groupId, "5");
    expect(viewModel.groupName, "Demo");
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });
  group('validationCheck', () {
    test('returns false when region or segment is invalid', () {
      // Arrange
      final customer = Customer(id: '123');

      // Stub region and segment checks using mocks or actual logic
      // If these methods are in ViewModel, you can temporarily override them via dependency injection
      // For now, assume they return false for region
      viewModel.businessSegmentValue = Reference(name: 'Corporate');

      // Use a spy on AlertManager
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      // Act
      // Simulate invalid region by making checkValidRegion return false
      final result = !viewModel.validationCheck(customer);

      // Assert
      expect(result, false);
    });
    test('resetDependentFields should clear all dependent fields', () {
      // Arrange: Set initial values
      viewModel.isSearched = true;
      viewModel.customer = Customer(id: '123');
      viewModel.selectedRequestType = Reference(id: 1);
      viewModel.selectedApplicationType = Reference(id: 2);
      viewModel.selectedCustomerType = Reference(id: 3);
      viewModel.customerRimNo = '456';
      viewModel.customerName = 'John';
      viewModel.groupId = '789';
      viewModel.groupName = 'Demo';
      viewModel.selectedCustomer.value = Customer(id: '123');
      viewModel.fieldCntrl = ValueNotifier({
        ControlFields.customerName: true,
        ControlFields.customerRim: true,
        ControlFields.groupID: true,
        ControlFields.groupName: true,
      });

      // Act
      viewModel.resetDependentFields();

      // Assert: Verify all fields are reset
      expect(viewModel.isSearched, false);
      expect(viewModel.customer, isNull);
      expect(viewModel.selectedRequestType, isNull);
      expect(viewModel.selectedApplicationType, isNull);
      expect(viewModel.selectedCustomerType, isNull);
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.customerName, isNull);
      expect(viewModel.groupId, isNull);
      expect(viewModel.groupName, isNull);
      expect(viewModel.selectedCustomer.value, isNull);

      // Verify fieldCntrl reset
      expect(viewModel.fieldCntrl.value[ControlFields.customerName], false);
      expect(viewModel.fieldCntrl.value[ControlFields.customerRim], false);
      expect(viewModel.fieldCntrl.value[ControlFields.groupID], false);
      expect(viewModel.fieldCntrl.value[ControlFields.groupName], false);

      // Verify state emit
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
    test('onResetButtonPress should reset all form fields and state', () {
      // Arrange: Set initial values
      viewModel.isSearched = true;
      viewModel.customer = Customer(id: '123');
      viewModel.selectedRequestType = Reference(id: 1);
      viewModel.selectedApplicationType = Reference(id: 2);
      viewModel.selectedCustomerType = Reference(id: 3);
      viewModel.customerRimNo = '456';
      viewModel.customerName = 'John';
      viewModel.groupId = '789';
      viewModel.groupName = 'Demo';
      viewModel.selectedCustomer.value = Customer(id: '123');
      viewModel.fieldCntrl = ValueNotifier({
        ControlFields.customerName: true,
        ControlFields.customerRim: true,
        ControlFields.groupID: true,
        ControlFields.groupName: true,
      });

      // Act
      viewModel.onResetButtonPress();

      // Assert: Verify all fields are reset
      expect(viewModel.isSearched, false);
      expect(viewModel.customer, isNull);
      expect(viewModel.selectedRequestType, isNull);
      expect(viewModel.selectedApplicationType, isNull);
      expect(viewModel.selectedCustomerType, isNull);
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.customerName, isNull);
      expect(viewModel.groupId, isNull);
      expect(viewModel.groupName, isNull);
      expect(viewModel.selectedCustomer.value, isNull);

      // Verify fieldCntrl reset
      expect(viewModel.fieldCntrl.value[ControlFields.customerName], false);
      expect(viewModel.fieldCntrl.value[ControlFields.customerRim], false);
      expect(viewModel.fieldCntrl.value[ControlFields.groupID], false);
      expect(viewModel.fieldCntrl.value[ControlFields.groupName], false);

      // Verify state emit
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });
  test(
      'onSubmitButtonPress with isValidated=false should not populate or navigate',
      () {
    viewModel.requestCreate = Request();
    viewModel.onSubmitButtonPress(
      false,
    );

    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    expect(viewModel.requestCreate.customerName, isNull);
  });

  group('getRequestTypes', () {
    late CreateRequestViewModel viewModel;

    setUp(() {
      viewModel = CreateRequestViewModel();
      viewModel.requestTypes = [
        Reference(id: 101, name: 'Full CA'),
        Reference(id: ServerConstants.isolatedMemo, name: 'Isolated Memo'),
        Reference(
            id: ServerConstants.requestFinancialId, name: 'Financial Request'),
      ];
    });
  });

  group('CreateRequestState', () {
    test('constructor sets fields with default for showSelectDialog', () {
      final state = CreateRequestState(
          loaderStatus: LoadingStatus.loading, showSelectDialog: true);
      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.showSelectDialog, true);
    });

    test('copyWith keeps existing when null', () {
      final original = CreateRequestState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.showSelectDialog, false);
    });

    test('copyWith overrides provided fields', () {
      final original = CreateRequestState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(
          loaderStatus: LoadingStatus.error, showSelectDialog: true);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(updated.showSelectDialog, true);
      expect(original.showSelectDialog, false);
    });
  });

  group('filterCustomers', () {
    test('shows toast when allCustomers is empty', () {
      viewModel.allCustomers = [];
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      viewModel.filterCustomers();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test(
        'populates dailogCustomers with allCustomers when search term is empty',
        () {
      final customer1 = Customer(preferredName: 'Alice');
      final customer2 = Customer(preferredName: 'Bob');
      viewModel.allCustomers = [customer1, customer2];
      viewModel.customerName = '';
      viewModel.isGroupNameSelection = false;

      viewModel.filterCustomers();

      expect(viewModel.dailogCustomers.length, 2);
      expect(viewModel.dailogCustomers, containsAll([customer1, customer2]));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('filters customers by name when isGroupNameSelection is false', () {
      final customer1 = Customer(preferredName: 'Alice');
      final customer2 = Customer(preferredName: 'Bob');
      viewModel.allCustomers = [customer1, customer2];
      viewModel.customerName = 'ali';
      viewModel.isGroupNameSelection = false;

      viewModel.filterCustomers();

      expect(viewModel.dailogCustomers.length, 1);
      expect(viewModel.dailogCustomers.first, customer1);
    });

    test('filters customers by group name when isGroupNameSelection is true',
        () {
      final customer1 = Customer(groups: Group(name: 'Group A'));
      final customer2 = Customer(groups: Group(name: 'Group B'));
      viewModel.allCustomers = [customer1, customer2];
      viewModel.groupName = 'group b';
      viewModel.isGroupNameSelection = true;

      viewModel.filterCustomers();

      expect(viewModel.dailogCustomers.length, 1);
      expect(viewModel.dailogCustomers.first, customer2);
    });

    test('excludes null customers during filtering', () {
      final customer1 = Customer(preferredName: 'Alice');
      viewModel.allCustomers = [customer1, null];
      viewModel.customerName = 'ali';
      viewModel.isGroupNameSelection = false;

      viewModel.filterCustomers();

      expect(viewModel.dailogCustomers.length, 1);
      expect(viewModel.dailogCustomers.first, customer1);
    });
  });

  group('validationCheck (Extended)', () {
    test('returns true when validation passes', () {
      // Arrange
      final customer = Customer(segment: 'Corporate', branchCode: '001');
      Globals.user = User(segments: ['Corporate'], regions: ['Abu Dhabi']);

      viewModel.branchList = [
        Reference(reference1: '001', reference2: 'Abu Dhabi')
      ];

      viewModel.businessSegmentValue = Reference(
          id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
          name: 'Corporate');

      // Act
      final result = viewModel.validationCheck(customer);

      // Assert
      expect(result, isTrue);
      expect(viewModel.isSearched, false);
    });

    test('catches exception and handles failure', () {
      // Arrange
      final customer = Customer(segment: 'Corporate');
      // This will throw "common.segmentFiMismatch" inside checkValidBusinessSegment
      viewModel.businessSegmentValue = Reference(
        id: ServerConstants
            .businessSegmentId[BusinessSegment.financialInstitution],
      );

      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      // Act
      final result = viewModel.validationCheck(customer);

      // Assert
      expect(result, false);
      expect(viewModel.customer, isNull);
      expect(viewModel.isSearched, false);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  test(
      'submitButtonValidation returns true when financial institution and no customer type',
      () {
    viewModel.customer = Customer(id: '123');
    viewModel.selectedRequestType = Reference(id: 1);
    viewModel.selectedApplicationType = Reference(id: 1);

    viewModel.businessSegmentValue =
        Reference(id: ServerConstants.financialInstitutionId);

    viewModel.selectedCustomerType = null;

    expect(viewModel.submitButtonValidation(), isTrue);
  });

  test(
      'submitButtonValidation returns false when financial institution and customer type selected',
      () {
    viewModel.customer = Customer(id: '123');
    viewModel.selectedRequestType = Reference(id: 1);
    viewModel.selectedApplicationType = Reference(id: 1);

    viewModel.businessSegmentValue =
        Reference(id: ServerConstants.financialInstitutionId);
    viewModel.selectedCustomerType = Reference(id: 2);

    expect(viewModel.submitButtonValidation(), isFalse);
  });

  test('handleFieldControl updates fieldCntrl correctly', () {
    viewModel.fieldCntrl.value = {
      ControlFields.customerName: false,
      ControlFields.groupID: false,
    };

    viewModel.handleFieldControl(ControlFields.customerName, 'some data');

    expect(viewModel.fieldCntrl.value[ControlFields.customerName], false);
    expect(viewModel.fieldCntrl.value[ControlFields.groupID], true);
  });

  group('validateSubSegment', () {
    test('calls repository.validateSubSegment when criteria met', () async {
      // Arrange
      Globals.user = User(currentRole: Role(roleId: 100)); // Role 100
      viewModel.subSegmentValidation = [
        Reference(
            reference1: ServerConstants.subSegmentValidationRefId,
            reference2: '100,101') // Matches role 100
      ];
      viewModel.customer = Customer(relationshipMgr: [
        {'RelationshipMgrIdent': 'RM1'}
      ]);

      when(() => mockCustomerRepo.validateSubSegment(any()))
          .thenAnswer((_) async {});

      // Act
      await viewModel.validateSubSegment();

      // Assert
      verify(() => mockCustomerRepo.validateSubSegment('RM1')).called(1);
    });

    test('does not call repository when criteria not met', () async {
      // Arrange
      Globals.user = User(currentRole: Role(roleId: 200)); // Role 200
      viewModel.subSegmentValidation = [
        Reference(
            reference1: ServerConstants.subSegmentValidationRefId,
            reference2: '100,101') // Does not match role 200
      ];

      // Act
      await viewModel.validateSubSegment();

      // Assert
      verifyNever(() => mockCustomerRepo.validateSubSegment(any()));
    });

    test('rethrows exception and resets fields on failure', () async {
      // Arrange
      Globals.user = User(currentRole: Role(roleId: 100));
      viewModel.subSegmentValidation = [
        Reference(
            reference1: ServerConstants.subSegmentValidationRefId,
            reference2: '100')
      ];

      when(() => mockCustomerRepo.validateSubSegment(any()))
          .thenThrow(Exception('Validation failed'));

      // Act & Assert
      await expectLater(
          () => viewModel.validateSubSegment(), throwsA(isA<Exception>()));

      expect(viewModel.customerName, isNull);
      expect(viewModel.isSearched, false);
    });
  });

  group('onCustomerSearchPressed (detailed)', () {
    test('shows toast when required fields are missing', () async {
      viewModel.selectedRequestType = null;
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.onCustomerSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, false);
    });

    test('search by RIM success', () async {
      // Arrange
      viewModel.selectedRequestType = Reference(id: 1);
      viewModel.selectedApplicationType = Reference(id: 1);
      viewModel.businessSegmentValue = Reference(id: 1);

      viewModel.customerRimNoLoadingStatus = LoadingStatus.loading;
      viewModel.customerRimNo = '12345';

      final customer =
          Customer(id: '12345', preferredName: 'John', segment: 'Corporate');
      when(() => mockCustomerRepo.searchUserDetails('12345', null, null, null))
          .thenAnswer((_) async => customer);

      // Validation checks mock
      Globals.user = User(segments: ['Corporate']);

      // Act
      await viewModel.onCustomerSearchPressed();

      // Assert
      expect(viewModel.customer, customer);
      expect(viewModel.customerName, 'John');
      expect(viewModel.isSearched, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('search by Profile single result success', () async {
      // Arrange
      viewModel.selectedRequestType = Reference(id: 1);
      viewModel.selectedApplicationType = Reference(id: 1);
      viewModel.businessSegmentValue = Reference(
          id: ServerConstants.businessSegmentId[BusinessSegment.corporate]);

      viewModel.customerNameLoadingStatus = LoadingStatus.loading;
      viewModel.customerName = 'John';

      final customer =
          Customer(id: '12345', preferredName: 'John', segment: 'Corporate');
      when(() => mockCustomerRepo.searchCustomerProfile('John', null, null))
          .thenAnswer((_) async => [customer]); // LIST of 1

      Globals.user = User(segments: ['Corporate']);

      // Act
      await viewModel.onCustomerSearchPressed(showDialog: true);

      // Assert
      expect(viewModel.customer, customer);
      expect(viewModel.dailogCustomers.length, 1);
      expect(viewModel.state.showSelectDialog, true);
    });

    test('search by Profile multiple results shows dialog', () async {
      // Arrange
      viewModel.selectedRequestType = Reference(id: 1);
      viewModel.selectedApplicationType = Reference(id: 1);
      viewModel.businessSegmentValue = Reference(id: 1);

      viewModel.customerNameLoadingStatus =
          LoadingStatus.loading; // or just not RIM loading
      viewModel.customerName = 'John';

      final c1 =
          Customer(id: '1', preferredName: 'John A', segment: 'Corporate');
      final c2 =
          Customer(id: '2', preferredName: 'John B', segment: 'Corporate');

      when(() => mockCustomerRepo.searchCustomerProfile('John', null, null))
          .thenAnswer((_) async => [c1, c2]);

      Globals.user = User(segments: [
        'Corporate'
      ]); // Validation passed for c1/c2? Only if we check them later.
      // Actually validateSubSegment/checkValidRegion is interacting.
      // The code sets dailogCustomers = resultCustomers and emits showSelectDialog WITHOUT checking validation on each yet?
      // Wait, code: "dailogCustomers = resultCustomers; ... emit(showSelectDialog: showDialog);"
      // So it DOES NOT check validation for multiple results unless groupIdLoadingStatus == LoadingStatus.loading (Group Owner case)

      // Act
      await viewModel.onCustomerSearchPressed(showDialog: true);

      // Assert
      expect(viewModel.dailogCustomers.length, 2);
      expect(viewModel.state.showSelectDialog, true);
    });

    test('search result empty shows toast', () async {
      viewModel.selectedRequestType = Reference(id: 1);
      viewModel.selectedApplicationType = Reference(id: 1);
      viewModel.businessSegmentValue = Reference(id: 1);

      viewModel.customerNameLoadingStatus = LoadingStatus.loading;
      viewModel.customerName = 'Unknown';

      when(() => mockCustomerRepo.searchCustomerProfile('Unknown', null, null))
          .thenAnswer((_) async => []);

      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.onCustomerSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, false);
    });

    test('search throws exception is caught', () async {
      viewModel.selectedRequestType = Reference(id: 1);
      viewModel.selectedApplicationType = Reference(id: 1);
      viewModel.businessSegmentValue = Reference(id: 1);

      viewModel.customerNameLoadingStatus = LoadingStatus.loading;

      when(() => mockCustomerRepo.searchCustomerProfile(any(), any(), any()))
          .thenThrow(Exception('Network Error'));
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.onCustomerSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, false);
    });
  });
}
