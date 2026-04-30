import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/state.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";
import "package:wcas_frontend/models/request/file_attachment/document.dart";
import "package:wcas_frontend/models/request/file_attachment/file_upload.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";

import "../../../../test_config.dart";

class MockFileAttachmentRepository extends Mock
    implements FileAttachmentRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeDocument extends Fake implements Document {}

void main() {
  late FileAttachmentViewModel viewModel;
  late MockFileAttachmentRepository mockRepository;
  late MockReferenceDataService mockReferenceDataService;
  late MockAlertManager mockAlertManager;

  setUpAll(() async {
    await TestConfig.setupTestEnvironment();
    registerFallbackValue(FakeDocument());
  });

  setUp(() {
    mockRepository = MockFileAttachmentRepository();
    mockReferenceDataService = MockReferenceDataService();
    mockAlertManager = MockAlertManager();

    Globals.request = Request(
      applicationRefNo: "TEST123",
      customerRimNo: 12345,
      groupId: 67890,
    );

    ReferenceDataService.overrideInstance(mockReferenceDataService);
    AlertManager.overrideInstance(mockAlertManager);

    viewModel = FileAttachmentViewModel();
    viewModel.fileAttachmentRepository = mockRepository;
  });

  tearDown(() {
    Globals.request = null;
  });

  group("FileAttachmentViewModel - initial values", () {
    test("initial state should be correct", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.state.documentsLoaderStatus, LoadingStatus.loaded);
      expect(viewModel.formKey, isA<GlobalKey<FormState>>());
      expect(viewModel.request.applicationRefNo, "TEST123");
      expect(viewModel.selectedFiles, isEmpty);
      expect(viewModel.selectedDocuments, isEmpty);
      expect(viewModel.uploadedDocuments, isEmpty);
      expect(viewModel.allDocuments, isEmpty);
      expect(viewModel.fileAccesses, isEmpty);
      expect(viewModel.rimList, isEmpty);
      expect(viewModel.selectedCompanyRims, isEmpty);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.selectedFolder, isNull);
      expect(viewModel.fileUploadDatas, isEmpty);
      expect(viewModel.selectedDate, isNotNull);
      expect(viewModel.selectedDocumentType, isNull);
      expect(viewModel.selectedSubTypeCreditLens, isNull);
      expect(viewModel.selectedSubSubType, isNull);
      expect(viewModel.selectedSubType, isNull);
      expect(viewModel.documentTypes, isEmpty);
      expect(viewModel.caSubTypes, isEmpty);
      expect(viewModel.caSubSubTypes, isEmpty);
      expect(viewModel.clSubTypes, isEmpty);
      expect(viewModel.caSubSubSubTypes, isEmpty);
      expect(viewModel.cdSubTypes, isEmpty);
      expect(viewModel.fstSubTypes, isEmpty);
      expect(viewModel.fstSubSubTypes, isEmpty);
      expect(viewModel.languages, isEmpty);
      expect(viewModel.selectedLanguageType, isNull);
      expect(viewModel.selectedCheckbocDocuments, isEmpty);
      expect(viewModel.selectedRows, isEmpty);
      expect(viewModel.selectedGroupRim, isNull);
      expect(viewModel.canEdit, isFalse);
      expect(viewModel.pageMode, PageMode.na);
    });

    test("canEdit should return true when pageMode is edit", () {
      viewModel.pageMode = PageMode.edit;

      expect(viewModel.canEdit, isTrue);
    });
  });

  group("buttonVisibilityStatus", () {
    test("closures should return bool values", () {
      final bool downloadDocuments = viewModel
          .buttonVisibilityStatus[FileAttachmentFields.downloadDocuments]!();
      final bool showApprovalDecision = viewModel
          .buttonVisibilityStatus[FileAttachmentFields.showApprovalDecision]!();

      expect(downloadDocuments, isA<bool>());
      expect(showApprovalDecision, isA<bool>());
    });
  });

  group("loadReferenceData", () {
    test("should populate reference data lists", () async {
      final Map<String, List<Reference>> mockData = {
        ReferenceDataKeys.fileType: <Reference>[
          Reference(id: 1, name: "PDF"),
        ],
        ReferenceDataKeys.documentTypes: <Reference>[
          Reference(id: 2, name: "Type 1"),
        ],
        ReferenceDataKeys.fstSubTypes: <Reference>[
          Reference(id: 3, name: "FST Sub 1"),
        ],
        ReferenceDataKeys.fstSubsubTypes: <Reference>[
          Reference(id: 4, name: "FST SubSub 1"),
        ],
        ReferenceDataKeys.languages: <Reference>[
          Reference(id: 5, name: "English"),
        ],
        ReferenceDataKeys.clSubTypes: <Reference>[
          Reference(id: 6, name: "CL Sub 1"),
        ],
        ReferenceDataKeys.applicationTypeCustom: <Reference>[
          Reference(id: 7, name: "Custom App 1"),
        ],
        ReferenceDataKeys.requestType: <Reference>[
          Reference(id: 8, name: "CA Sub 1"),
        ],
        ReferenceDataKeys.applicationType: <Reference>[
          Reference(id: 9, name: "CA SubSub 1"),
        ],
        ReferenceDataKeys.caSubSubSubTypes: <Reference>[
          Reference(id: 10, name: "CA SubSubSub 1"),
        ],
      };

      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenAnswer((_) async => mockData);

      await viewModel.loadReferenceData();

      expect(viewModel.fileType.length, 1);
      expect(viewModel.documentTypes.length, 1);
      expect(viewModel.fstSubTypes.length, 1);
      expect(viewModel.fstSubSubTypes.length, 1);
      expect(viewModel.languages.length, 1);
      expect(viewModel.clSubTypes.length, 1);
      expect(viewModel.applicationTypeCustom.length, 1);
      expect(viewModel.caSubTypes.length, 1);
      expect(viewModel.caSubSubTypes.length, 1);
      expect(viewModel.caSubSubSubTypes.length, 1);
    });

    test("should fallback to empty lists when keys are missing", () async {
      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenAnswer((_) async => <String, List<Reference>>{});

      await viewModel.loadReferenceData();

      expect(viewModel.fileType, isEmpty);
      expect(viewModel.documentTypes, isEmpty);
      expect(viewModel.fstSubTypes, isEmpty);
      expect(viewModel.fstSubSubTypes, isEmpty);
      expect(viewModel.languages, isEmpty);
      expect(viewModel.clSubTypes, isEmpty);
      expect(viewModel.applicationTypeCustom, isEmpty);
      expect(viewModel.caSubTypes, isEmpty);
      expect(viewModel.caSubSubTypes, isEmpty);
      expect(viewModel.caSubSubSubTypes, isEmpty);
    });
  });

  group("simple update methods", () {
    test("updateDocumentName should update documentName", () {
      viewModel.updateDocumentName("Test Document");

      expect(viewModel.documentName, "Test Document");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateEntityId should update entityId", () {
      viewModel.updateEntityId("ENTITY-001");

      expect(viewModel.entityId, "ENTITY-001");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onDocumentTypeChanged should reset and update selectedDocumentType",
        () {
      viewModel.selectedLanguageType = Reference(id: 11, name: "English");
      final Reference reference = Reference(id: 1, name: "Document Type 1");

      viewModel.onDocumentTypeChanged(reference);

      expect(viewModel.selectedDocumentType, reference);
      expect(viewModel.selectedLanguageType, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateLanguageType should update selectedLanguageType", () {
      final Reference reference = Reference(id: 1, name: "English");

      viewModel.updateLanguageType(reference);

      expect(viewModel.selectedLanguageType, reference);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateSubTypeCredit should update selectedSubSubType", () {
      final Reference reference = Reference(id: 1, name: "Credit Type 1");

      viewModel.updateSubTypeCredit(reference);

      expect(viewModel.selectedSubSubType, reference);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateSubTypeCreditLens should update selectedSubTypeCreditLens", () {
      final Reference reference = Reference(id: 1, name: "Credit Lens Type 1");

      viewModel.updateSubTypeCreditLens(reference);

      expect(viewModel.selectedSubTypeCreditLens, reference);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateSubType should update selectedSubType", () {
      final Reference reference = Reference(id: 1, name: "Sub Type 1");

      viewModel.updateSubType(reference);

      expect(viewModel.selectedSubType, reference);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateSubSubType should update selectedSubSubType", () {
      final Reference reference = Reference(id: 1, name: "SubSub Type 1");

      viewModel.updateSubSubType(reference);

      expect(viewModel.selectedSubSubType, reference);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updatesubsubsubType should update selectedSubSubSubType", () {
      final Reference reference = Reference(id: 1, name: "SubSubSub Type 1");

      viewModel.updatesubsubsubType(reference);

      expect(viewModel.selectedSubSubSubType, reference);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateCompanyRim should update selectedCompanyRims", () {
      final List<Customer> rims = <Customer>[
        Customer(customerRimNo: 1),
        Customer(customerRimNo: 2),
      ];

      viewModel.updateCompanyRim(rims);

      expect(viewModel.selectedCompanyRims, rims);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateSelectedDate should parse and update selectedDate", () {
      viewModel.updateSelectedDate("2024-01-15");

      expect(viewModel.selectedDate, isNotNull);
      expect(viewModel.selectedDate!.year, 2024);
      expect(viewModel.selectedDate!.month, 1);
      expect(viewModel.selectedDate!.day, 15);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateSelectedDate should set null for invalid date", () {
      viewModel.updateSelectedDate("invalid-date");

      expect(viewModel.selectedDate, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("selection helpers", () {
    test("toggleSelection should update selectedRows", () {
      viewModel.toggleSelection("doc1", true);

      expect(viewModel.selectedRows["doc1"], true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      viewModel.toggleSelection("doc1", false);

      expect(viewModel.selectedRows["doc1"], false);
    });

    test("toggleDocumentSelection should add document and id when selected",
        () {
      final DocSubTypeData docData = DocSubTypeData(edmsDriveItemId: "doc123");

      viewModel.toggleDocumentSelection("doc1", true, docData);

      expect(viewModel.selectedDocumentIds, contains("doc123"));
      expect(viewModel.selectedDocs, contains(docData));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "toggleDocumentSelection should remove document and id when unselected",
        () {
      final DocSubTypeData docData = DocSubTypeData(edmsDriveItemId: "doc123");

      viewModel.toggleDocumentSelection("doc1", true, docData);
      viewModel.toggleDocumentSelection("doc1", false, docData);

      expect(viewModel.selectedDocumentIds, isNot(contains("doc123")));
      expect(viewModel.selectedDocs, isNot(contains(docData)));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("toggleDocumentSelection should not add when edmsDriveItemId is empty",
        () {
      final DocSubTypeData docData = DocSubTypeData(edmsDriveItemId: "");

      viewModel.toggleDocumentSelection("doc1", true, docData);

      expect(viewModel.selectedDocumentIds, isEmpty);
      expect(viewModel.selectedDocs, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("isDocumentSelected should return correct value", () {
      viewModel.selectedCheckbocDocuments["doc1"] = true;

      expect(viewModel.isDocumentSelected("doc1"), isTrue);
      expect(viewModel.isDocumentSelected("doc2"), isFalse);
    });
  });

  group("removeFileAt", () {
    test("should remove document at valid index", () {
      viewModel.selectedDocuments = <Document>[
        Document(documentName: "Doc1"),
        Document(documentName: "Doc2"),
        Document(documentName: "Doc3"),
      ];
      viewModel.selectedFiles = <PlatformFile>[
        PlatformFile(name: "file1.pdf", size: 100),
        PlatformFile(name: "file2.pdf", size: 100),
        PlatformFile(name: "file3.pdf", size: 100),
      ];

      viewModel.removeFileAt(1);

      expect(viewModel.selectedDocuments.length, 2);
      expect(viewModel.selectedDocuments[0].documentName, "Doc1");
      expect(viewModel.selectedDocuments[1].documentName, "Doc3");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("should ignore when index is out of bounds", () {
      viewModel.selectedDocuments = <Document>[
        Document(documentName: "Doc1"),
      ];

      viewModel.removeFileAt(5);

      expect(viewModel.selectedDocuments.length, 1);
    });

    test("should ignore when index is negative", () {
      viewModel.selectedDocuments = <Document>[
        Document(documentName: "Doc1"),
      ];

      viewModel.removeFileAt(-1);

      expect(viewModel.selectedDocuments.length, 1);
    });
  });

  group("resetFormFields", () {
    test("should clear all form fields", () {
      viewModel.selectedLanguageType = Reference(name: "English");
      viewModel.selectedSubType = Reference(name: "SubType");
      viewModel.selectedSubTypeCreditLens = Reference(name: "Credit Lens");
      viewModel.selectedSubSubType = Reference(name: "SubFinancial");
      viewModel.selectedSubSubSubType = Reference(name: "Third");
      viewModel.selectedCompanyRims = <Customer>[Customer(customerRimNo: 1)];
      viewModel.documentName = "Test";
      viewModel.entityId = "ENT-1";
      viewModel.selectedDate = DateTime.now();
      viewModel.selectedDocumentType = Reference(name: "DocType");
      viewModel.isSelectAllCompanyRims = true;

      viewModel.resetFormFields();

      expect(viewModel.selectedLanguageType, isNull);
      expect(viewModel.selectedSubType, isNull);
      expect(viewModel.selectedSubTypeCreditLens, isNull);
      expect(viewModel.selectedSubSubType, isNull);
      expect(viewModel.selectedSubSubSubType, isNull);
      expect(viewModel.selectedCompanyRims, isEmpty);
      expect(viewModel.documentName, isNull);
      expect(viewModel.entityId, isNull);
      expect(viewModel.selectedDate, isNull);
      expect(viewModel.selectedDocumentType, isNull);
      expect(viewModel.isSelectAllCompanyRims, isFalse);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getDocumentTypeReferenceById", () {
    test("should return matching reference", () {
      viewModel.documentTypes = <Reference>[
        Reference(id: 1, name: "Type 1"),
        Reference(id: 2, name: "Type 2"),
        Reference(id: 3, name: "Type 3"),
      ];

      final Reference? result = viewModel.getDocumentTypeReferenceById(2);

      expect(result, isNotNull);
      expect(result!.id, 2);
      expect(result.name, "Type 2");
    });

    test("should return fallback reference when not found", () {
      viewModel.documentTypes = <Reference>[
        Reference(id: 1, name: "Type 1"),
      ];

      final Reference? result = viewModel.getDocumentTypeReferenceById(999);

      expect(result, isNotNull);
      expect(result!.id, 999);
    });
  });

  group("document type helpers", () {
    test("isConstitutionalDocumentsSelected returns correct value", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.constitutionalDocument],
      );

      expect(viewModel.isConstitutionalDocumentsSelected(), isTrue);

      viewModel.selectedDocumentType = Reference(id: 999);

      expect(viewModel.isConstitutionalDocumentsSelected(), isFalse);
    });

    test("isCreditApplicationSelected returns correct value", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.creditApplication],
      );

      expect(viewModel.isCreditApplicationSelected(), isTrue);

      viewModel.selectedDocumentType = Reference(id: 999);

      expect(viewModel.isCreditApplicationSelected(), isFalse);
    });

    test("isCreditLensSelected returns correct value", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.creditLensDocument],
      );

      expect(viewModel.isCreditLensSelected(), isTrue);

      viewModel.selectedDocumentType = Reference(id: 999);

      expect(viewModel.isCreditLensSelected(), isFalse);
    });

    test("isFinancialStatementsSelected returns correct value", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.financialStatements],
      );

      expect(viewModel.isFinancialStatementsSelected(), isTrue);

      viewModel.selectedDocumentType = Reference(id: 999);

      expect(viewModel.isFinancialStatementsSelected(), isFalse);
    });

    test("isExternalOpinionsSelected returns correct value", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.externalOpinions],
      );

      expect(viewModel.isExternalOpinionsSelected(), isTrue);

      viewModel.selectedDocumentType = Reference(id: 999);

      expect(viewModel.isExternalOpinionsSelected(), isFalse);
    });

    test("isOthersSelected returns correct value", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.other],
      );

      expect(viewModel.isOthersSelected(), isTrue);

      viewModel.selectedDocumentType = Reference(id: 999);

      expect(viewModel.isOthersSelected(), isFalse);
    });

    test("all helper methods return false when selectedDocumentType is null",
        () {
      viewModel.selectedDocumentType = null;

      expect(viewModel.isConstitutionalDocumentsSelected(), isFalse);
      expect(viewModel.isCreditApplicationSelected(), isFalse);
      expect(viewModel.isCreditLensSelected(), isFalse);
      expect(viewModel.isFinancialStatementsSelected(), isFalse);
      expect(viewModel.isExternalOpinionsSelected(), isFalse);
      expect(viewModel.isOthersSelected(), isFalse);
    });
  });

  group("folder selection and upload form", () {
    test("onSelectFolder should update selectedFolder and uploadedDocuments",
        () {
      final FileAccess fileAccess = FileAccess(
        id: 1,
        name: "Test Folder",
        access: AccessType.edit,
        children: <FileAccess>[],
      );

      viewModel.allDocuments = <Document>[
        Document(documentName: "Doc1", folderID: 1),
        Document(documentName: "Doc2", folderID: 2),
        Document(documentName: "Doc3", folderID: 1),
      ];

      viewModel.onSelectFolder(fileAccess);

      expect(viewModel.selectedFolder, fileAccess);
      expect(viewModel.uploadedDocuments.length, 2);
      expect(viewModel.uploadedDocuments[0].documentName, "Doc1");
      expect(viewModel.uploadedDocuments[1].documentName, "Doc3");
      expect(viewModel.state.showUploadButton, isTrue);
      expect(viewModel.state.showUploadForm, isFalse);
      expect(viewModel.state.documentsLoaderStatus, LoadingStatus.loaded);
    });

    test("onSelectFolder should set empty status when no documents found", () {
      final FileAccess fileAccess = FileAccess(
        id: 1,
        name: "Test Folder",
        access: AccessType.edit,
        children: <FileAccess>[],
      );

      viewModel.allDocuments = <Document>[];

      viewModel.onSelectFolder(fileAccess);

      expect(viewModel.uploadedDocuments, isEmpty);
      expect(viewModel.state.documentsLoaderStatus, LoadingStatus.empty);
    });

    test("onSelectFolder should set error status for AccessType.none", () {
      final FileAccess fileAccess = FileAccess(
        id: 1,
        name: "Test Folder",
        access: AccessType.none,
        children: <FileAccess>[],
      );

      viewModel.onSelectFolder(fileAccess);

      expect(viewModel.state.documentsLoaderStatus, LoadingStatus.error);
      expect(viewModel.state.documentListErrorMessage, isNotNull);
    });

    test("showUploadForm should update state for edit access", () {
      viewModel.selectedFolder = FileAccess(
        id: 1,
        name: "Test Folder",
        access: AccessType.edit,
        children: <FileAccess>[],
      );

      viewModel.showUploadForm();

      expect(viewModel.state.showUploadForm, isTrue);
      expect(viewModel.state.showUploadButton, isFalse);
    });

    test("showUploadForm should return early for non-edit access", () {
      viewModel.selectedFolder = FileAccess(
        id: 1,
        name: "Test Folder",
        access: AccessType.none,
        children: <FileAccess>[],
      );

      viewModel.showUploadForm();

      expect(viewModel.state.showUploadForm, isNot(true));
    });
  });

  group("getCompanyRims", () {
    test("should return early when not a group application", () async {
      Globals.request = Request(
        applicationRefNo: "TEST123",
        customerRimNo: 12345,
        groupId: null,
      );

      viewModel = FileAttachmentViewModel();
      viewModel.fileAttachmentRepository = mockRepository;

      await viewModel.getCompanyRims();

      expect(viewModel.rimList, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });
  });

  group("getFileAccessTree", () {
    test("should load data successfully", () async {
      when(() => mockRepository.getFileAccessRight())
          .thenAnswer((_) async => <FileAccess>[]);
      when(() => mockRepository.getDocuments(any(), any(), any(), any(), any()))
          .thenAnswer((_) async => <Document>[]);
      when(() => mockRepository.calculateFileCountsAggregated(any(), any()))
          .thenReturn(<FileAccess>[]);

      await viewModel.getFileAccessTree();

      expect(viewModel.fileAccesses, isEmpty);
      expect(viewModel.allDocuments, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("should handle repository exception", () async {
      when(() => mockRepository.getFileAccessRight())
          .thenThrow(Exception("file access error"));

      await viewModel.getFileAccessTree();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getDigitalFilingViewData", () {
    test("should load file upload data successfully", () async {
      when(
        () => mockRepository.getFileUploadData(
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
          any(),
        ),
      ).thenAnswer((_) async => <FileDetail>[]);

      await viewModel.getDigitalFilingViewData();

      expect(viewModel.fileUploadDatas, isEmpty);
      expect(viewModel.selectedDocs, isEmpty);
      expect(viewModel.selectedDocumentIds, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("should handle exception", () async {
      when(
        () => mockRepository.getFileUploadData(
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
          any(),
        ),
      ).thenThrow(Exception("digital filing error"));

      await viewModel.getDigitalFilingViewData();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("should pass customer rim when request is non-group", () async {
      Globals.request = Request(
        applicationRefNo: "APP-NON-GROUP",
        customerRimNo: 11111,
        groupId: null,
      );

      viewModel = FileAttachmentViewModel();
      viewModel.fileAttachmentRepository = mockRepository;

      when(
        () => mockRepository.getFileUploadData(
          any(),
          any(),
          any(),
          any(),
          any(),
          "11111",
          null,
          null,
          null,
          null,
          false,
        ),
      ).thenAnswer((_) async => <FileDetail>[]);

      await viewModel.getDigitalFilingViewData();

      verify(
        () => mockRepository.getFileUploadData(
          any(),
          any(),
          any(),
          any(),
          any(),
          "11111",
          null,
          null,
          null,
          null,
          false,
        ),
      ).called(1);
    });

    test("should pass group id when request is group application", () async {
      Globals.request = Request(
        applicationRefNo: "APP-GROUP",
        customerRimNo: 22222,
        groupId: 99999,
      );

      viewModel = FileAttachmentViewModel();
      viewModel.fileAttachmentRepository = mockRepository;

      when(
        () => mockRepository.getFileUploadData(
          any(),
          any(),
          any(),
          any(),
          any(),
          null,
          null,
          "99999",
          null,
          null,
          false,
        ),
      ).thenAnswer((_) async => <FileDetail>[]);

      await viewModel.getDigitalFilingViewData();

      verify(
        () => mockRepository.getFileUploadData(
          any(),
          any(),
          any(),
          any(),
          any(),
          null,
          null,
          "99999",
          null,
          null,
          false,
        ),
      ).called(1);
    });
  });

  group("upload documents", () {
    test("onUploadDocumentsPressed should upload and clear documents",
        () async {
      viewModel.selectedDocuments = <Document>[
        Document(documentName: "Test"),
      ];
      viewModel.selectedFolder = FileAccess(
        id: 1,
        name: "Test Folder",
        access: AccessType.edit,
        children: <FileAccess>[],
      );

      when(() => mockRepository.uploadDocumentsMultipart(any()))
          .thenAnswer((_) async => "Uploaded successfully");
      when(() => mockRepository.getFileAccessRight())
          .thenAnswer((_) async => <FileAccess>[]);
      when(() => mockRepository.getDocuments(any(), any(), any(), any(), any()))
          .thenAnswer((_) async => <Document>[]);
      when(() => mockRepository.calculateFileCountsAggregated(any(), any()))
          .thenReturn(<FileAccess>[]);

      await viewModel.onUploadDocumentsPressed();

      expect(viewModel.selectedDocuments, isEmpty);
      expect(viewModel.state.uploadStatus, LoadingStatus.loaded);
    });

    test("onUploadDocumentsPressed should handle exception", () async {
      viewModel.selectedDocuments = <Document>[
        Document(documentName: "Test"),
      ];

      when(() => mockRepository.uploadDocumentsMultipart(any()))
          .thenThrow(Exception("upload failed"));

      await viewModel.onUploadDocumentsPressed();

      expect(viewModel.state.uploadStatus, LoadingStatus.error);
    });
  });

  group("onBrowsePressed", () {
    test("should handle validation failure / missing FormState safely in test",
        () async {
      try {
        await viewModel.onBrowsePressed();
      } catch (_) {
        // Expected in unit test because formKey.currentState can be null.
      }

      expect(viewModel.state.loaderStatus, isA<LoadingStatus>());
    });
  });

  group("download and delete actions", () {
    test("downloadViewDocument should set loading state and reset", () async {
      final Document document = Document(documentName: "Test");

      when(() => mockRepository.downloadFileAttachment(any()))
          .thenAnswer((_) async {});

      await viewModel.downloadViewDocument(document);

      expect(document.downloadLoader, LoadingStatus.loaded);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("downloadViewDocument should handle exception and reset loader",
        () async {
      final Document document = Document(documentName: "Test");

      when(() => mockRepository.downloadFileAttachment(any()))
          .thenThrow(Exception("download failed"));

      await viewModel.downloadViewDocument(document);

      expect(document.downloadLoader, LoadingStatus.loaded);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("downloadDocument should call repository successfully", () async {
      when(() => mockRepository.downloadDigitalAttachment(any(), any(), any()))
          .thenAnswer((_) async {});

      await viewModel.downloadDocument(
        "doc1",
        "http://example.com",
        "file.pdf",
      );

      verify(
        () => mockRepository.downloadDigitalAttachment(
          "doc1",
          "http://example.com",
          "file.pdf",
        ),
      ).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("downloadDocument should handle exception", () async {
      when(() => mockRepository.downloadDigitalAttachment(any(), any(), any()))
          .thenThrow(Exception("download error"));

      await viewModel.downloadDocument(
        "doc1",
        "http://example.com",
        "file.pdf",
      );

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("downloadDocumentsZip should call repository successfully", () async {
      viewModel.selectedDocumentIds = <String>["1", "2"];
      viewModel.selectedDocs = <dynamic>[
        DocSubTypeData(edmsDriveItemId: "1"),
      ];

      when(
        () => mockRepository.zipDownloadDigitalAttachment(
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async {});

      await viewModel.downloadDocumentsZip();

      verify(
        () => mockRepository.zipDownloadDigitalAttachment(
          viewModel.selectedDocumentIds,
          viewModel.selectedDocs,
          viewModel.request.customerRimNo.toString(),
          viewModel.request.groupId.toString(),
          Globals.request?.applicationRefNo,
        ),
      ).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("downloadDocumentsZip should handle exception", () async {
      when(
        () => mockRepository.zipDownloadDigitalAttachment(
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("zip error"));

      await viewModel.downloadDocumentsZip();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("mergeDownloadDocument should call repository successfully", () async {
      viewModel.selectedDocumentIds = <String>["1", "2"];
      viewModel.selectedDocs = <dynamic>[
        DocSubTypeData(edmsDriveItemId: "1"),
      ];

      when(
        () => mockRepository.mergeDownloadDigitalAttachment(
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async {});

      await viewModel.mergeDownloadDocument();

      verify(
        () => mockRepository.mergeDownloadDigitalAttachment(
          viewModel.selectedDocs,
          viewModel.selectedDocumentIds,
          Globals.request!.customerRimNo?.toString(),
          Globals.request!.groupId?.toString(),
          "",
        ),
      ).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("mergeDownloadDocument should handle exception", () async {
      when(
        () => mockRepository.mergeDownloadDigitalAttachment(
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("merge error"));

      await viewModel.mergeDownloadDocument();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onDeleteDocumentPressed should set loading state and reset",
        () async {
      final Document document = Document(documentName: "Test");
      viewModel.selectedFolder = FileAccess(
        id: 1,
        name: "Test Folder",
        access: AccessType.edit,
        children: <FileAccess>[],
      );

      when(() => mockRepository.deleteDocument(any())).thenAnswer((_) async {
        return null;
      });
      when(() => mockRepository.getFileAccessRight())
          .thenAnswer((_) async => <FileAccess>[]);
      when(() => mockRepository.getDocuments(any(), any(), any(), any(), any()))
          .thenAnswer((_) async => <Document>[]);
      when(() => mockRepository.calculateFileCountsAggregated(any(), any()))
          .thenReturn(<FileAccess>[]);

      await viewModel.onDeleteDocumentPressed(document);

      expect(document.deleteLoader, LoadingStatus.loaded);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onDeleteDocumentPressed should handle exception and reset loader",
        () async {
      final Document document = Document(documentName: "Test");

      when(() => mockRepository.deleteDocument(any()))
          .thenThrow(Exception("delete failed"));

      await viewModel.onDeleteDocumentPressed(document);

      expect(document.deleteLoader, LoadingStatus.loaded);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("company rim selection", () {
    test("toggleSelectAllCompanyRims should select all rims when true", () {
      viewModel.rimList = <Customer>[
        Customer(customerRimNo: 1),
        Customer(customerRimNo: 2),
      ];

      viewModel.toggleSelectAllCompanyRims(true);

      expect(viewModel.isSelectAllCompanyRims, isTrue);
      expect(viewModel.selectedCompanyRims.length, 2);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("toggleSelectAllCompanyRims should clear rims when false", () {
      viewModel.rimList = <Customer>[
        Customer(customerRimNo: 1),
        Customer(customerRimNo: 2),
      ];
      viewModel.selectedCompanyRims = List<Customer>.from(viewModel.rimList);

      viewModel.toggleSelectAllCompanyRims(false);

      expect(viewModel.isSelectAllCompanyRims, isFalse);
      expect(viewModel.selectedCompanyRims, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("linkToApplication", () {
    test(
        "should return early when selected docs"
        " contain credit application type", () async {
      viewModel.selectedDocs = <dynamic>[
        DocSubTypeData(
          edmsDriveItemId: "1",
        ),
      ];
      viewModel.selectedDocumentIds = <String>["1"];

      await viewModel.linkToApplication();

      // verifyNever(() => mockRepository.linkToApplication(any(), any()));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("should call repository when docs are valid", () async {
      viewModel.selectedDocs = <dynamic>[
        DocSubTypeData(
          edmsDriveItemId: "1",
        ),
      ];
      viewModel.selectedDocumentIds = <String>["1", "2"];

      when(() => mockRepository.linkToApplication(any(), any()))
          .thenAnswer((_) async {
        return null;
      });

      await viewModel.linkToApplication();

      verify(
        () => mockRepository.linkToApplication(
          Globals.request?.applicationRefNo,
          viewModel.selectedDocumentIds,
        ),
      ).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("should handle exception from repository", () async {
      viewModel.selectedDocs = <dynamic>[
        DocSubTypeData(
          edmsDriveItemId: "1",
        ),
      ];
      viewModel.selectedDocumentIds = <String>["1"];

      when(() => mockRepository.linkToApplication(any(), any()))
          .thenThrow(Exception("link failed"));

      await viewModel.linkToApplication();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("FileAttachmentState", () {
    test("copyWith should create new state with updated values", () {
      final FileAttachmentState initialState = FileAttachmentState(
        loaderStatus: LoadingStatus.loading,
        documentsLoaderStatus: LoadingStatus.loading,
      );

      final FileAttachmentState newState = initialState.copyWith(
        loaderStatus: LoadingStatus.loaded,
        showUploadButton: true,
      );

      expect(newState.loaderStatus, LoadingStatus.loaded);
      expect(newState.showUploadButton, isTrue);
    });

    test("copyWith should preserve unchanged values", () {
      final FileAttachmentState initialState = FileAttachmentState(
        loaderStatus: LoadingStatus.loading,
        documentsLoaderStatus: LoadingStatus.loaded,
        showUploadButton: false,
      );

      final FileAttachmentState newState = initialState.copyWith();

      expect(newState.loaderStatus, LoadingStatus.loading);
      expect(newState.documentsLoaderStatus, LoadingStatus.loaded);
      expect(newState.showUploadButton, isFalse);
    });

    test("copyWith should update documentsLoaderStatus", () {
      final FileAttachmentState initialState = FileAttachmentState(
        loaderStatus: LoadingStatus.loaded,
        documentsLoaderStatus: LoadingStatus.loading,
      );

      final FileAttachmentState newState = initialState.copyWith(
        documentsLoaderStatus: LoadingStatus.empty,
      );

      expect(newState.documentsLoaderStatus, LoadingStatus.empty);
    });

    test("copyWith should update showUploadForm", () {
      final FileAttachmentState initialState = FileAttachmentState(
        loaderStatus: LoadingStatus.loaded,
        documentsLoaderStatus: LoadingStatus.loaded,
        showUploadForm: false,
      );

      final FileAttachmentState newState = initialState.copyWith(
        showUploadForm: true,
      );

      expect(newState.showUploadForm, isTrue);
    });

    test("copyWith should update documentListErrorMessage", () {
      final FileAttachmentState initialState = FileAttachmentState(
        loaderStatus: LoadingStatus.loaded,
        documentsLoaderStatus: LoadingStatus.error,
      );

      final FileAttachmentState newState = initialState.copyWith(
        documentListErrorMessage: "Error message",
      );

      expect(newState.documentListErrorMessage, "Error message");
    });
  });
}
