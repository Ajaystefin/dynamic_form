import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/file_upload_service.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/state.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/file_attachment/document.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/file_attachment_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';

class MockRequestRepository extends Mock implements RequestRepository {}

class MockFileAttachmentRepository extends Mock
    implements FileAttachmentRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockAlertManager extends Mock implements AlertManager {}

class MockFileUploadService extends Mock implements FileUploadService {}

class MockNavigatorState extends Fake implements NavigatorState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MockNavigatorState';
  }
}

class MockBuildContext extends Fake implements BuildContext {
  final MockNavigatorState _navigator = MockNavigatorState();

  @override
  bool get mounted => true;

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() {
    if (T == NavigatorState) {
      return _navigator as T?;
    }
    return null;
  }
}

void main() {
  late UploadDocumentDialogViewModel viewModel;
  late MockRequestRepository mockRequestRepo;
  late MockFileAttachmentRepository mockFileAttachmentRepo;
  late MockReferenceDataService mockRefService;
  late MockAlertManager mockAlertManager;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EnvConfig.setEnvironment();
    registerFallbackValue(<String>[]);
    registerFallbackValue(<Document>[]);
    registerFallbackValue(Document());
  });

  setUp(() {
    mockRequestRepo = MockRequestRepository();
    mockFileAttachmentRepo = MockFileAttachmentRepository();
    mockRefService = MockReferenceDataService();
    mockAlertManager = MockAlertManager();

    viewModel = UploadDocumentDialogViewModel();
    viewModel.repository = mockRequestRepo;
    viewModel.fileAttachmentRepository = mockFileAttachmentRepo;

    AlertManager.overrideInstance(mockAlertManager);
    ReferenceDataService.overrideInstance(mockRefService);

    // Initialize Globals.request
    Globals.request = Request(
      groupId: 456,
      customerRimNo: 789,
      applicationRefNo: '123',
    );

    // Setup default mock responses
    when(() => mockRefService.getReferenceData(any())).thenAnswer((_) async => {
          ReferenceDataKeys.documentTypes: [
            Reference(id: 1, name: 'Doc Type 1'),
            Reference(
                id: ServerConstants
                    .documentTypeId[DocumentType.creditApplication],
                name: 'Credit Application'),
            Reference(id: 3, name: 'Doc Type 3'),
          ],
          ReferenceDataKeys.fstSubTypes: [Reference(id: 2, name: 'FST Sub')],
          ReferenceDataKeys.fstSubsubTypes: [
            Reference(id: 3, name: 'FST SubSub')
          ],
          ReferenceDataKeys.languages: [Reference(id: 4, name: 'English')],
          ReferenceDataKeys.clSubTypes: [Reference(id: 5, name: 'CL Sub')],
          ReferenceDataKeys.caSubTypes: [Reference(id: 6, name: 'CA Sub')],
          ReferenceDataKeys.caSubSubTypes: [
            Reference(id: 7, name: 'CA SubSub')
          ],
          ReferenceDataKeys.caSubSubSubTypes: [
            Reference(id: 8, name: 'CA SubSubSub')
          ],
        });

    when(() => mockFileAttachmentRepo.getCompanyRims(any()))
        .thenAnswer((_) async => ['RIM1', 'RIM2', 'RIM3']);

    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
  });

  group('Initialization', () {
    test('initial state should be loading for loader, loaded for upload button',
        () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.state.uploadButtonStatus, LoadingStatus.loaded);
    });

    test('init should load reference data and set state to loaded', () async {
      viewModel.init(
        MockBuildContext(),
        groupRim: '100',
        customerRim: '200',
        applicationId: 'APP123',
        rimsList: ['RIM1', 'RIM2'],
      );

      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.selectedGroupRim, 100);
      expect(viewModel.selectedCustomerRim, 200);
      expect(viewModel.applicationId, 'APP123');
      expect(viewModel.rimList, ['RIM1', 'RIM2']);
    });

    test('init should handle empty customerRim by using first from rimsList',
        () async {
      viewModel.init(
        MockBuildContext(),
        groupRim: '100',
        customerRim: '',
        applicationId: 'APP123',
        rimsList: ['RIM1', 'RIM2'],
      );

      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.selectedCustomerRim, int.tryParse('RIM1'));
    });

    test('init should handle customerRim as "0" by using first from rimsList',
        () async {
      viewModel.init(
        MockBuildContext(),
        groupRim: '100',
        customerRim: '0',
        applicationId: 'APP123',
        rimsList: ['300', '400'],
      );

      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.selectedCustomerRim, 300);
    });

    test('loadReferenceData should populate all reference lists', () async {
      await viewModel.loadReferenceData();

      // Should filter out credit application document type
      expect(viewModel.documentTypes.length, 2);
      expect(viewModel.fstSubTypes.length, 1);
      expect(viewModel.fstSubSubTypes.length, 1);
      expect(viewModel.languages.length, 1);
      expect(viewModel.clSubTypes.length, 1);
      expect(viewModel.subTypes.length, 1);
      expect(viewModel.subsubTypes.length, 1);
      expect(viewModel.caSubSubSubTypes.length, 1);
    });

    test('loadReferenceData should filter out credit application document',
        () async {
      await viewModel.loadReferenceData();

      final hasCreditApp = viewModel.documentTypes.any((doc) =>
          doc.id ==
          ServerConstants.documentTypeId[DocumentType.creditApplication]);
      expect(hasCreditApp, false);
    });
  });

  group('Search and Company RIMs', () {
    test('updateSearchValue should execute without error', () {
      expect(() => viewModel.updateSearchValue('test'), returnsNormally);
    });

    test('getCompanyRims should fetch rims when group application', () async {
      viewModel.selectedGroupRim = 100;

      await viewModel.getCompanyRims();

      verify(() => mockFileAttachmentRepo.getCompanyRims(100)).called(1);
      expect(viewModel.rimList, ['RIM1', 'RIM2', 'RIM3']);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('getCompanyRims should return early if not group application',
        () async {
      viewModel.selectedGroupRim = null;

      await viewModel.getCompanyRims();

      verifyNever(() => mockFileAttachmentRepo.getCompanyRims(any()));
    });

    test('getCompanyRims should handle errors', () async {
      viewModel.selectedGroupRim = 100;
      when(() => mockFileAttachmentRepo.getCompanyRims(any()))
          .thenThrow(Exception('Failed to fetch RIMs'));

      await viewModel.getCompanyRims();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group('Field Updates', () {
    test('updateCompanyRim should update selected company rims', () {
      viewModel.updateCompanyRim(['RIM1', 'RIM2']);

      expect(viewModel.selectedCompanyRims, ['RIM1', 'RIM2']);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('toggleSelectAllCompanyRims should select all when true', () {
      viewModel.rimList = ['RIM1', 'RIM2', 'RIM3'];

      viewModel.toggleSelectAllCompanyRims(true);

      expect(viewModel.isSelectAllCompanyRims, true);
      expect(viewModel.selectedCompanyRims, ['RIM1', 'RIM2', 'RIM3']);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('toggleSelectAllCompanyRims should clear all when false', () {
      viewModel.rimList = ['RIM1', 'RIM2', 'RIM3'];
      viewModel.selectedCompanyRims = ['RIM1', 'RIM2'];

      viewModel.toggleSelectAllCompanyRims(false);

      expect(viewModel.isSelectAllCompanyRims, false);
      expect(viewModel.selectedCompanyRims, []);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('updateApplicationId should update application ID', () {
      viewModel.updateApplicationId('APP456');

      expect(viewModel.applicationId, 'APP456');
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('updateDocumentName should update document name and text controller',
        () {
      viewModel.updateDocumentName('Test Document');

      expect(viewModel.documentName, 'Test Document');
      expect(viewModel.textController.text, 'Test Document');
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('updateDocumentType should update selected document type', () {
      final docType = Reference(id: 1, name: 'Type 1');

      viewModel.updateDocumentType(docType);

      expect(viewModel.selectedDocumentType, docType);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('updateLanguageType should update selected language type', () {
      final langType = Reference(id: 1, name: 'English');

      viewModel.updateLanguageType(langType);

      expect(viewModel.selectedLanguageType, langType);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('updateGroupRim should parse and update group rim', () {
      viewModel.updateGroupRim('123');

      expect(viewModel.selectedGroupRim, 123);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('updateGroupRim should not update when groupRim is "0"', () {
      viewModel.selectedGroupRim = 999;

      viewModel.updateGroupRim('0');

      expect(viewModel.selectedGroupRim, 999);
    });

    test('updateGroupRim should not update when groupRim is empty', () {
      viewModel.selectedGroupRim = 999;

      viewModel.updateGroupRim('');

      expect(viewModel.selectedGroupRim, 999);
    });

    test('updateCustomerRim should parse and update customer rim', () {
      viewModel.updateCustomerRim('456');

      expect(viewModel.selectedCustomerRim, 456);
      expect(viewModel.isCompanyRim, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('updateSubTypeCredit should update selected sub type credit', () {
      final subType = Reference(id: 1, name: 'Credit Sub');

      viewModel.updateSubTypeCredit(subType);

      expect(viewModel.selectedSubTypeCredit, subType);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('updateSubTypeCreditLens should update selected sub type credit lens',
        () {
      final subType = Reference(id: 2, name: 'Credit Lens Sub');

      viewModel.updateSubTypeCreditLens(subType);

      expect(viewModel.selectedSubTypeCreditLens, subType);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('updateSubTypeFinancial should update selected sub type financial',
        () {
      final subType = Reference(id: 3, name: 'Financial Sub');

      viewModel.updateSubTypeFinancial(subType);

      expect(viewModel.selectedSubTypeFinancial, subType);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        'updateSubSubTypeFinancial should update selected sub sub type financial',
        () {
      final subSubType = Reference(id: 4, name: 'Financial SubSub');

      viewModel.updateSubSubTypeFinancial(subSubType);

      expect(viewModel.selectedSubSubTypeFinancial, subSubType);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group('File Management', () {
    test('removeFileAt should remove file and document at valid index', () {
      viewModel.selectedFiles = [
        PlatformFile(name: 'file1.pdf', size: 100),
        PlatformFile(name: 'file2.pdf', size: 200),
      ];
      viewModel.selectedDocuments = [
        Document(documentName: 'doc1'),
        Document(documentName: 'doc2'),
      ];

      viewModel.removeFileAt(0);

      expect(viewModel.selectedDocuments.length, 1);
      expect(viewModel.selectedDocuments[0].documentName, 'doc2');
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('removeFileAt should not remove when index is out of bounds', () {
      viewModel.selectedDocuments = [
        Document(documentName: 'doc1'),
      ];

      viewModel.removeFileAt(5);

      expect(viewModel.selectedDocuments.length, 1);
    });

    test('removeFileAt should not remove when index is negative', () {
      viewModel.selectedDocuments = [
        Document(documentName: 'doc1'),
      ];

      viewModel.removeFileAt(-1);

      expect(viewModel.selectedDocuments.length, 1);
    });
  });

  group('Form Reset', () {
    test('resetFormFields should clear all form fields', () {
      viewModel.selectedLanguageType = Reference(id: 1, name: 'English');
      viewModel.selectedSubTypeFinancial = Reference(id: 2, name: 'Financial');
      viewModel.selectedSubTypeCreditLens = Reference(id: 3, name: 'Credit');
      viewModel.selectedSubSubTypeFinancial =
          Reference(id: 4, name: 'SubFinancial');
      viewModel.selectedCompanyRims = ['RIM1', 'RIM2'];
      viewModel.isSelectAllCompanyRims = true;
      viewModel.documentName = 'Test Doc';
      viewModel.textController.text = 'Test';
      viewModel.selectedDate = DateTime.now();

      viewModel.resetFormFields();

      expect(viewModel.selectedLanguageType, null);
      expect(viewModel.selectedSubTypeFinancial, null);
      expect(viewModel.selectedSubTypeCreditLens, null);
      expect(viewModel.selectedSubSubTypeFinancial, null);
      expect(viewModel.selectedCompanyRims, []);
      expect(viewModel.isSelectAllCompanyRims, false);
      expect(viewModel.documentName, null);
      expect(viewModel.textController.text, '');
      expect(viewModel.selectedDate, null);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group('Document Type Helpers', () {
    test('isConstitutionalDocumentsSelected should return true when selected',
        () {
      viewModel.selectedDocumentType = Reference(
          id: ServerConstants
              .documentTypeId[DocumentType.constitutionalDocument],
          name: 'Constitutional');

      expect(viewModel.isConstitutionalDocumentsSelected(), true);
    });

    test(
        'isConstitutionalDocumentsSelected should return false when not selected',
        () {
      viewModel.selectedDocumentType = Reference(id: 999, name: 'Other');

      expect(viewModel.isConstitutionalDocumentsSelected(), false);
    });

    test('isCreditLensSelected should return true when selected', () {
      viewModel.selectedDocumentType = Reference(
          id: ServerConstants.documentTypeId[DocumentType.creditLensDocument],
          name: 'Credit Lens');

      expect(viewModel.isCreditLensSelected(), true);
    });

    test('isCreditLensSelected should return false when not selected', () {
      viewModel.selectedDocumentType = Reference(id: 999, name: 'Other');

      expect(viewModel.isCreditLensSelected(), false);
    });

    test('isFinancialStatementsSelected should return true when selected', () {
      viewModel.selectedDocumentType = Reference(
          id: ServerConstants.documentTypeId[DocumentType.financialStatements],
          name: 'Financial');

      expect(viewModel.isFinancialStatementsSelected(), true);
    });

    test('isFinancialStatementsSelected should return false when not selected',
        () {
      viewModel.selectedDocumentType = Reference(id: 999, name: 'Other');

      expect(viewModel.isFinancialStatementsSelected(), false);
    });

    test('isExternalOpinionsSelected should return true when selected', () {
      viewModel.selectedDocumentType = Reference(
          id: ServerConstants.documentTypeId[DocumentType.externalOpinions],
          name: 'External');

      expect(viewModel.isExternalOpinionsSelected(), true);
    });

    test('isExternalOpinionsSelected should return false when not selected',
        () {
      viewModel.selectedDocumentType = Reference(id: 999, name: 'Other');

      expect(viewModel.isExternalOpinionsSelected(), false);
    });

    test('isOthersSelected should return true when selected', () {
      viewModel.selectedDocumentType = Reference(
          id: ServerConstants.documentTypeId[DocumentType.other],
          name: 'Other');

      expect(viewModel.isOthersSelected(), true);
    });

    test('isOthersSelected should return false when not selected', () {
      viewModel.selectedDocumentType = Reference(id: 999, name: 'Something');

      expect(viewModel.isOthersSelected(), false);
    });
  });

  group('Download Document', () {
    test('downloadViewDocument should call repository method', () async {
      final document = Document(documentName: 'test.pdf');

      when(() => mockFileAttachmentRepo.downloadFileAttachment(any()))
          .thenAnswer((_) async => {});

      await viewModel.downloadViewDocument(document);

      verify(() => mockFileAttachmentRepo.downloadFileAttachment(document))
          .called(1);
    });
  });

  group('Document Type Changed', () {
    test('onDocumentTypeChanged should reset all related fields', () {
      viewModel.selectedDocumentType = Reference(id: 1, name: 'Old Type');
      viewModel.documentName = 'Old Name';
      viewModel.selectedSubTypeFinancial = Reference(id: 2, name: 'Financial');
      viewModel.selectedSubTypeCreditLens = Reference(id: 3, name: 'Credit');
      viewModel.selectedSubSubTypeFinancial =
          Reference(id: 4, name: 'SubFinancial');
      viewModel.selectedDate = DateTime.now();

      final newType = Reference(id: 5, name: 'New Type');
      viewModel.onDocumentTypeChanged(newType);

      expect(viewModel.selectedDocumentType, newType);
      expect(viewModel.textController.text, '');
      expect(viewModel.selectedSubTypeFinancial, null);
      expect(viewModel.selectedSubTypeCreditLens, null);
      expect(viewModel.selectedSubSubTypeFinancial, null);
      expect(viewModel.selectedDate, null);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group('UploadDocumentDialogState', () {
    test('constructor sets loader and upload button status', () {
      final state = UploadDocumentDialogState(
        loaderStatus: LoadingStatus.loading,
        uploadButtonStatus: LoadingStatus.loaded,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.uploadButtonStatus, LoadingStatus.loaded);
    });

    test('copyWith keeps existing values when null', () {
      final original = UploadDocumentDialogState(
        loaderStatus: LoadingStatus.loaded,
        uploadButtonStatus: LoadingStatus.loaded,
      );

      final copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.uploadButtonStatus, LoadingStatus.loaded);
    });

    test('copyWith overrides loaderStatus', () {
      final original = UploadDocumentDialogState(
        loaderStatus: LoadingStatus.loaded,
        uploadButtonStatus: LoadingStatus.loaded,
      );

      final updated = original.copyWith(loaderStatus: LoadingStatus.loading);

      expect(updated.loaderStatus, LoadingStatus.loading);
      expect(updated.uploadButtonStatus, LoadingStatus.loaded);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });

    test('copyWith overrides uploadButtonStatus', () {
      final original = UploadDocumentDialogState(
        loaderStatus: LoadingStatus.loaded,
        uploadButtonStatus: LoadingStatus.loaded,
      );

      final updated =
          original.copyWith(uploadButtonStatus: LoadingStatus.loading);

      expect(updated.loaderStatus, LoadingStatus.loaded);
      expect(updated.uploadButtonStatus, LoadingStatus.loading);
      expect(original.uploadButtonStatus, LoadingStatus.loaded);
    });

    test('copyWith overrides both statuses', () {
      final original = UploadDocumentDialogState(
        loaderStatus: LoadingStatus.loaded,
        uploadButtonStatus: LoadingStatus.loaded,
      );

      final updated = original.copyWith(
        loaderStatus: LoadingStatus.loading,
        uploadButtonStatus: LoadingStatus.error,
      );

      expect(updated.loaderStatus, LoadingStatus.loading);
      expect(updated.uploadButtonStatus, LoadingStatus.error);
    });
  });
}
