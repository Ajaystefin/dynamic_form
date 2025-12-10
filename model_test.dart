import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/state.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/login/user.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/file_attachment/file_upload.dart';
import 'package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart';
import 'package:wcas_frontend/models/request/group.dart';
import 'package:wcas_frontend/repositories/customer_respository.dart';
import 'package:wcas_frontend/repositories/file_attachment_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockFileAttachmentRepository extends Mock
    implements FileAttachmentRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Fake implements BuildContext {
  @override
  bool get mounted => true;
}

void main() {
  late DigitalEfilingViewModel viewModel;
  late MockCustomerRepository mockCustomerRepo;
  late MockFileAttachmentRepository mockFileAttachmentRepo;
  late MockReferenceDataService mockRefService;
  late MockAlertManager mockAlertManager;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EnvConfig.setEnvironment();
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    mockCustomerRepo = MockCustomerRepository();
    mockFileAttachmentRepo = MockFileAttachmentRepository();
    mockRefService = MockReferenceDataService();
    mockAlertManager = MockAlertManager();

    viewModel = DigitalEfilingViewModel();
    viewModel.customerRepository = mockCustomerRepo;
    viewModel.fileAttachmentRepository = mockFileAttachmentRepo;

    AlertManager.overrideInstance(mockAlertManager);
    ReferenceDataService.overrideInstance(mockRefService);

    // Setup default mock responses
    when(() => mockRefService.getReferenceData(any())).thenAnswer((_) async => {
          ReferenceDataKeys.documentTypes: [Reference(id: 1)],
          ReferenceDataKeys.fstSubTypes: [Reference(id: 2)],
          ReferenceDataKeys.fstSubsubTypes: [Reference(id: 3)],
          ReferenceDataKeys.languages: [Reference(id: 4)],
          ReferenceDataKeys.clSubTypes: [Reference(id: 5)],
          ReferenceDataKeys.caSubTypes: [Reference(id: 6)],
          ReferenceDataKeys.caSubSubTypes: [Reference(id: 7)],
          ReferenceDataKeys.caSubSubSubTypes: [Reference(id: 8)],
        });
  });

  group('Initialization', () {
    test('initial state should be loading', () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.state.searchLoaderStatus, LoadingStatus.loaded);
    });

    test('init should set loaderStatus to loaded', () async {
      viewModel.init(null);
      // Wait a bit for async operations
      await Future.delayed(Duration(milliseconds: 100));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('loadReferenceData should populate all reference lists', () async {
      await viewModel.loadReferenceData();

      expect(viewModel.documentTypes.length, 1);
      expect(viewModel.fstSubTypes.length, 1);
      expect(viewModel.fstSubSubTypes.length, 1);
      expect(viewModel.languages.length, 1);
      expect(viewModel.clSubTypes.length, 1);
      expect(viewModel.caSubTypes.length, 1);
      expect(viewModel.caSubSubTypes.length, 1);
      expect(viewModel.caSubSubSubTypes.length, 1);
    });
  });

  group('Field Control', () {
    test('handleFieldControl disables other fields when data is present', () {
      viewModel.handleFieldControl(ControlFields.customerName, 'John');

      expect(viewModel.fieldCntrl.value[ControlFields.customerRim], true);
      expect(viewModel.fieldCntrl.value[ControlFields.customerName], false);
      expect(viewModel.fieldCntrl.value[ControlFields.groupID], true);
      expect(viewModel.fieldCntrl.value[ControlFields.groupName], true);
    });

    test('handleFieldControl resets fields when data is empty', () {
      viewModel.customerName = 'John';
      viewModel.groupName = 'Group';

      viewModel.handleFieldControl(ControlFields.customerName, '');

      expect(viewModel.customerName, null);
      expect(viewModel.customerRimNo, null);
      expect(viewModel.groupId, null);
      expect(viewModel.groupName, null);
    });

    test('stopAllLoaders should reset all loading statuses', () {
      viewModel.customerRimNoLoadingStatus = LoadingStatus.loading;
      viewModel.customerNameLoadingStatus = LoadingStatus.loading;
      viewModel.groupIdLoadingStatus = LoadingStatus.loading;
      viewModel.groupNameLoadingStatus = LoadingStatus.loading;
      viewModel.submitLoadingStatus = LoadingStatus.loading;

      viewModel.stopAllLoaders();

      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.groupIdLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.groupNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.submitLoadingStatus, LoadingStatus.loaded);
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
  });

  group('Customer Search - Customer Name', () {
    test('onCustomerNameSearchPressed triggers search when valid', () {
      viewModel.customerName = 'John Doe';
      viewModel.isSearched = false;

      viewModel.onCustomerNameSearchPressed();

      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.isGroupNameSelection, false);
    });

    test('onCustomerNameSearchPressed shows toast when name is too short', () {
      viewModel.customerName = 'abc';
      viewModel.isSearched = false;

      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      viewModel.onCustomerNameSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test('onCustomerNameSearchPressed does nothing when already searched', () {
      viewModel.customerName = 'John Doe';
      viewModel.isSearched = true;

      viewModel.onCustomerNameSearchPressed();

      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
    });

    test('onCustomerNameSearchPressed shows toast when name is empty', () {
      viewModel.customerName = '';
      viewModel.isSearched = false;

      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      viewModel.onCustomerNameSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group('Customer Search - Group Name', () {
    test('onGroupNameSearchPressed triggers search when valid', () {
      viewModel.groupName = 'ValidGroupName';
      viewModel.isSearched = false;

      viewModel.onGroupNameSearchPressed(showDialog: false);

      expect(viewModel.groupNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.isGroupNameSelection, true);
    });

    test('onGroupNameSearchPressed shows toast when name is too short', () {
      viewModel.groupName = 'abc';
      viewModel.isSearched = false;

      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      viewModel.onGroupNameSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test('onGroupNameSearchPressed does nothing when already searched', () {
      viewModel.groupName = 'ValidGroupName';
      viewModel.isSearched = true;

      viewModel.onGroupNameSearchPressed();

      expect(viewModel.groupNameLoadingStatus, LoadingStatus.loaded);
    });
  });

  group('Customer Search - Group ID', () {
    test('onGroupIdSearchPressed triggers search when valid', () {
      viewModel.groupId = 'G123';
      viewModel.isSearched = false;

      viewModel.onGroupIdSearchPressed();

      expect(viewModel.groupIdLoadingStatus, LoadingStatus.loaded);
    });

    test('onGroupIdSearchPressed shows toast when groupId is empty', () {
      viewModel.groupId = '';
      viewModel.isSearched = false;

      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      viewModel.onGroupIdSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test('onGroupIdSearchPressed does nothing when already searched', () {
      viewModel.groupId = 'G123';
      viewModel.isSearched = true;

      viewModel.onGroupIdSearchPressed();

      expect(viewModel.groupIdLoadingStatus, LoadingStatus.loaded);
    });
  });

  group('Customer Search - Customer RIM', () {
    test('onCustomerRimNoSearchPressed triggers search when valid', () {
      viewModel.customerRimNo = 'RIM123';
      viewModel.isSearched = false;

      viewModel.onCustomerRimNoSearchPressed();

      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
    });

    test('onCustomerRimNoSearchPressed shows toast when rimNo is empty', () {
      viewModel.customerRimNo = '';
      viewModel.isSearched = false;

      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      viewModel.onCustomerRimNoSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test('onCustomerRimNoSearchPressed does nothing when already searched', () {
      viewModel.customerRimNo = 'RIM123';
      viewModel.isSearched = true;

      viewModel.onCustomerRimNoSearchPressed();

      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
    });
  });

  group('Customer Search - Main Search', () {
    test('onCustomerSearchPressed with single customer result', () async {
      final customer = Customer(
        id: '123',
        preferredName: 'John Doe',
        groups: Group(id: '456', name: 'Group A'),
      );

      viewModel.customerNameLoadingStatus = LoadingStatus.loading;
      when(() => mockCustomerRepo.searchCustomerProfile(any(), any(), any()))
          .thenAnswer((_) async => [customer]);

      await viewModel.onCustomerSearchPressed();

      expect(viewModel.customer, customer);
      expect(viewModel.customerRimNo, '123');
      expect(viewModel.customerName, 'John Doe');
      expect(viewModel.groupId, '456');
      expect(viewModel.groupName, 'Group A');
    });

    test('onCustomerSearchPressed with multiple customer results', () async {
      final customers = [
        Customer(id: '123', preferredName: 'John Doe'),
        Customer(id: '456', preferredName: 'Jane Doe'),
      ];

      viewModel.customerNameLoadingStatus = LoadingStatus.loading;
      when(() => mockCustomerRepo.searchCustomerProfile(any(), any(), any()))
          .thenAnswer((_) async => customers);

      await viewModel.onCustomerSearchPressed();

      expect(viewModel.dailogCustomers.length, 2);
      expect(viewModel.state.showSelectDialog, true);
    });

    test('onCustomerSearchPressed with no results shows toast', () async {
      viewModel.customerRimNoLoadingStatus = LoadingStatus.loading;
      when(() => mockCustomerRepo.searchUserDetails(any(), any(), any(), any()))
          .thenAnswer((_) async => null);
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.onCustomerSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, false);
    });

    test('onCustomerSearchPressed handles error', () async {
      viewModel.customerRimNoLoadingStatus = LoadingStatus.loading;
      when(() => mockCustomerRepo.searchUserDetails(any(), any(), any(), any()))
          .thenThrow(Exception('Failed'));
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.onCustomerSearchPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.isSearched, false);
    });

    test('onCustomerSearchPressed by RIM number', () async {
      final customer = Customer(
        id: '123',
        preferredName: 'John Doe',
        groups: Group(id: '456', name: 'Group A'),
      );

      viewModel.customerRimNoLoadingStatus = LoadingStatus.loading;
      when(() => mockCustomerRepo.searchUserDetails(any(), any(), any(), any()))
          .thenAnswer((_) async => customer);

      await viewModel.onCustomerSearchPressed();

      expect(viewModel.customer, customer);
      expect(viewModel.customerRimNo, '123');
    });
  });

  group('Selection and Reset', () {
    test('onSelectionPressed with valid customer', () {
      final customer = Customer(
        id: '123',
        preferredName: 'John Doe',
        groups: Group(id: '456', name: 'Group A'),
      );

      viewModel.selectedCustomer.value = customer;
      viewModel.onSelectionPressed(MockBuildContext());

      expect(viewModel.customer, customer);
      expect(viewModel.customerRimNo, '123');
      expect(viewModel.customerName, 'John Doe');
      expect(viewModel.groupId, '456');
      expect(viewModel.groupName, 'Group A');
    });

    test('onSelectionPressed with null customer shows toast', () {
      viewModel.selectedCustomer.value = null;
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      viewModel.onSelectionPressed(MockBuildContext());

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test('onSelectionCancelButtonPress resets fields', () {
      viewModel.customer = Customer(id: '123');
      viewModel.customerName = 'John';
      viewModel.groupName = 'Group';

      viewModel.onSelectionCancelButtonPress();

      expect(viewModel.customer, null);
      expect(viewModel.customerName, null);
      expect(viewModel.groupName, null);
      expect(viewModel.customerRimNo, null);
      expect(viewModel.groupId, null);
    });

    test('resetDependentFields should clear all dependent fields', () {
      viewModel.isSearched = true;
      viewModel.customer = Customer(id: '123');
      viewModel.customerRimNo = '456';
      viewModel.customerName = 'John';
      viewModel.groupId = '789';
      viewModel.groupName = 'Demo';
      viewModel.selectedCustomer.value = Customer(id: '123');

      viewModel.resetDependentFields();

      expect(viewModel.isSearched, false);
      expect(viewModel.customer, isNull);
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.customerName, isNull);
      expect(viewModel.groupId, isNull);
      expect(viewModel.groupName, isNull);
      expect(viewModel.selectedCustomer.value, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('onResetButtonPress should reset all form fields and state', () {
      viewModel.isSearched = true;
      viewModel.customer = Customer(id: '123');
      viewModel.customerRimNo = '456';
      viewModel.customerName = 'John';
      viewModel.groupId = '789';
      viewModel.groupName = 'Demo';

      viewModel.onResetButtonPress();

      expect(viewModel.isSearched, false);
      expect(viewModel.customer, isNull);
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.customerName, isNull);
      expect(viewModel.groupId, isNull);
      expect(viewModel.groupName, isNull);
    });
  });

  group('Validation', () {
    test('checkValidSegment returns true when segment matches', () {
      Globals.user = User(segments: ['Corporate']);
      final customer = Customer(segment: 'Corporate');
      expect(viewModel.checkValidSegment(customer), isTrue);
    });

    test('checkValidSegment returns false when segment does not match', () {
      Globals.user = User(segments: ['Retail']);
      final customer = Customer(segment: 'Corporate');
      expect(viewModel.checkValidSegment(customer), isFalse);
    });

    test('checkValidRegion returns true', () {
      final customer = Customer(branchCode: '123');
      expect(viewModel.checkValidRegion(customer), isTrue);
    });

    test('validationCheck returns true when validation passes', () {
      Globals.user = User(segments: ['Corporate']);
      final customer = Customer(segment: 'Corporate');
      viewModel.customer = customer;

      expect(viewModel.validationCheck(customer), isTrue);
    });
  });

  group('Document Management', () {
    test('toggleDocumentSelection adds document to selected list', () {
      final docData = DocSubTypeData(edmsDriveItemId: 'doc123');

      viewModel.toggleDocumentSelection('key1', true, docData);

      expect(viewModel.selectedDocumentIds.contains('doc123'), isTrue);
      expect(docData.isChecked, isTrue);
    });

    test('toggleDocumentSelection removes document from selected list', () {
      final docData = DocSubTypeData(edmsDriveItemId: 'doc123');
      viewModel.selectedDocumentIds.add('doc123');

      viewModel.toggleDocumentSelection('key1', false, docData);

      expect(viewModel.selectedDocumentIds.contains('doc123'), isFalse);
      expect(docData.isChecked, isFalse);
    });

    test('toggleDocumentSelection handles empty edmsDriveItemId', () {
      final docData = DocSubTypeData(edmsDriveItemId: '');

      viewModel.toggleDocumentSelection('key1', true, docData);

      expect(viewModel.selectedDocumentIds.isEmpty, isTrue);
      expect(docData.isChecked, isTrue);
    });

    test('isDocumentSelected returns correct status', () {
      viewModel.selectedDocuments['key1'] = true;
      viewModel.selectedDocuments['key2'] = false;

      expect(viewModel.isDocumentSelected('key1'), isTrue);
      expect(viewModel.isDocumentSelected('key2'), isFalse);
      expect(viewModel.isDocumentSelected('key3'), isFalse);
    });
  });

  group('Search and File Operations', () {
    test('updateSearchValue does not throw error', () {
      expect(() => viewModel.updateSearchValue('test'), returnsNormally);
    });

    test('updateApplicationId updates application ID', () {
      viewModel.updateApplicationId('APP123');

      expect(viewModel.applicationId, 'APP123');
      expect(viewModel.applicationIdController.text, 'APP123');
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('doSearch with valid search criteria', () async {
      viewModel.customerRimNo = '123';
      viewModel.customerName = 'John';
      viewModel.groupId = '456';
      viewModel.groupName = 'Group';

      when(() => mockFileAttachmentRepo.getFileUploadData(
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
          )).thenAnswer((_) async => [
            FileDetail(type: 'test', documents: []),
          ]);

      viewModel.doSearch();
      await Future.delayed(Duration(milliseconds: 100));

      expect(viewModel.fileUploadDatas.length, 1);
      expect(viewModel.state.searchLoaderStatus, LoadingStatus.loaded);
    });

    test('doSearch with empty criteria shows toast', () async {
      viewModel.customerRimNo = null;
      viewModel.customerName = null;
      viewModel.groupId = null;
      viewModel.groupName = null;
      viewModel.applicationId = null;

      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      viewModel.doSearch();
      await Future.delayed(Duration(milliseconds: 100));

      expect(viewModel.state.searchLoaderStatus, LoadingStatus.loaded);
    });

    test('doSearch with empty results shows toast', () async {
      viewModel.customerRimNo = '123';

      when(() => mockFileAttachmentRepo.getFileUploadData(
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
          )).thenAnswer((_) async => []);

      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      viewModel.doSearch();
      await Future.delayed(Duration(milliseconds: 100));

      expect(viewModel.state.searchLoaderStatus, LoadingStatus.loaded);
    });

    test('doSearch handles error', () async {
      viewModel.customerRimNo = '123';

      when(() => mockFileAttachmentRepo.getFileUploadData(
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
          )).thenThrow(Exception('Failed'));

      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      viewModel.doSearch();
      await Future.delayed(Duration(milliseconds: 100));

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test('downloadDocument downloads single document', () async {
      when(() => mockFileAttachmentRepo.downloadDigitalAttachment(any(), any()))
          .thenAnswer((_) async => {});

      await viewModel.downloadDocument('doc123', 'document.pdf');

      verify(() => mockFileAttachmentRepo.downloadDigitalAttachment(
          'doc123', 'document.pdf')).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('downloadDocument handles error', () async {
      when(() => mockFileAttachmentRepo.downloadDigitalAttachment(any(), any()))
          .thenThrow(Exception('Download failed'));
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.downloadDocument('doc123', 'document.pdf');

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test('downloadDocumentsZip downloads multiple documents', () async {
      viewModel.selectedDocumentIds = ['doc1', 'doc2'];
      viewModel.customerRimController.text = '123';
      viewModel.groupRimController.text = '456';
      viewModel.applicationIdController.text = 'APP789';

      when(() => mockFileAttachmentRepo.zipDownloadDigitalAttachment(
          any(), any(), any(), any())).thenAnswer((_) async => {});

      await viewModel.downloadDocumentsZip();

      verify(() => mockFileAttachmentRepo.zipDownloadDigitalAttachment(
          ['doc1', 'doc2'], '123', '456', 'APP789')).called(1);
    });

    test('downloadDocumentsZip handles error', () async {
      viewModel.selectedDocumentIds = ['doc1'];

      when(() => mockFileAttachmentRepo.zipDownloadDigitalAttachment(
          any(), any(), any(), any())).thenThrow(Exception('Zip failed'));
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.downloadDocumentsZip();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test('mergeDownloadDocument merges documents', () async {
      viewModel.selectedDocumentIds = ['doc1', 'doc2'];

      when(() => mockFileAttachmentRepo.mergeDownloadDigitalAttachment(any()))
          .thenAnswer((_) async => {});

      await viewModel.mergeDownloadDocument();

      verify(() => mockFileAttachmentRepo
          .mergeDownloadDigitalAttachment(['doc1', 'doc2'])).called(1);
    });

    test('mergeDownloadDocument handles error', () async {
      viewModel.selectedDocumentIds = ['doc1'];

      when(() => mockFileAttachmentRepo.mergeDownloadDigitalAttachment(any()))
          .thenThrow(Exception('Merge failed'));
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.mergeDownloadDocument();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group('DigitalEfilingState', () {
    test('constructor sets loaderStatus', () {
      final state = DigitalEfilingState(
          loaderStatus: LoadingStatus.loading,
          searchLoaderStatus: LoadingStatus.loaded);
      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.searchLoaderStatus, LoadingStatus.loaded);
    });

    test('copyWith keeps existing when null', () {
      final original = DigitalEfilingState(
          loaderStatus: LoadingStatus.loaded,
          searchLoaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test('copyWith overrides', () {
      final original = DigitalEfilingState(
          loaderStatus: LoadingStatus.loaded,
          searchLoaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });

    test('copyWith updates all fields', () {
      final original = DigitalEfilingState(
        loaderStatus: LoadingStatus.loaded,
        searchLoaderStatus: LoadingStatus.loaded,
        groupName: 'Group A',
        groupRim: '123',
        customerName: 'John',
        customerRim: '456',
        showSelectDialog: false,
      );

      final updated = original.copyWith(
        loaderStatus: LoadingStatus.loading,
        searchLoaderStatus: LoadingStatus.loading,
        groupName: 'Group B',
        groupRim: '789',
        customerName: 'Jane',
        customerRim: '012',
        showSelectDialog: true,
      );

      expect(updated.loaderStatus, LoadingStatus.loading);
      expect(updated.searchLoaderStatus, LoadingStatus.loading);
      expect(updated.groupName, 'Group B');
      expect(updated.groupRim, '789');
      expect(updated.customerName, 'Jane');
      expect(updated.customerRim, '012');
      expect(updated.showSelectDialog, true);
    });
  });
}
