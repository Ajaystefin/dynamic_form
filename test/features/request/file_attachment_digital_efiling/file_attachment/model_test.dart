import "dart:async";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
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

class FakeFilePicker extends FilePicker {
  FakeFilePicker({
    required this.result,
  });

  final FilePickerResult? result;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late FileAttachmentViewModel viewModel;
  late MockFileAttachmentRepository mockRepository;
  late MockReferenceDataService mockReferenceDataService;
  late MockAlertManager mockAlertManager;

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestConfig.setupTestEnvironment();

    // Important: initialize FilePicker.platform once.
    // Do not read FilePicker.platform before assigning a fake implementation.
    FilePicker.platform = FakeFilePicker(result: null);

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

    registerFallbackValue(FakeDocument());
    registerFallbackValue(<Reference>[]);
    registerFallbackValue(<FileAccess>[]);
    registerFallbackValue(<Document>[]);
    registerFallbackValue(<String>[]);
    registerFallbackValue(<DocSubTypeData?>[]);
  });

  tearDownAll(() {
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

    ReferenceDataService.overrideInstance = mockReferenceDataService;
    AlertManager.overrideInstance = mockAlertManager;
    AlertManager.instance = mockAlertManager;

    FilePicker.platform = FakeFilePicker(result: null);

    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

    viewModel = FileAttachmentViewModel()
      ..fileAttachmentRepository = mockRepository;
  });

  tearDown(() {
    Globals.request = null;
    FilePicker.platform = FakeFilePicker(result: null);
  });

  Map<String, List<Reference>> buildReferenceData({
    bool includeApprovalDecision = false,
    bool includeNullApprovalId = false,
  }) {
    return <String, List<Reference>>{
      ReferenceDataKeys.fileType: <Reference>[
        Reference(id: 1, name: "PDF"),
      ],
      ReferenceDataKeys.documentTypes: <Reference>[
        Reference(id: 2, name: "Document Type"),
      ],
      ReferenceDataKeys.fstSubTypes: <Reference>[
        Reference(id: 3, name: "FST Sub"),
      ],
      ReferenceDataKeys.fstSubsubTypes: <Reference>[
        Reference(id: 4, name: "FST SubSub"),
      ],
      ReferenceDataKeys.languages: <Reference>[
        Reference(id: 5, name: "English"),
      ],
      ReferenceDataKeys.clSubTypes: <Reference>[
        Reference(id: 6, name: "CL Sub"),
      ],
      ReferenceDataKeys.applicationTypeCustom: <Reference>[
        Reference(id: 7, name: "Custom"),
      ],
      ReferenceDataKeys.requestType: <Reference>[
        Reference(id: 8, name: "Request Type"),
      ],
      ReferenceDataKeys.applicationType: <Reference>[
        Reference(id: 9, name: "Application Type"),
      ],
      ReferenceDataKeys.caSubSubSubTypes: <Reference>[
        if (includeNullApprovalId) Reference(name: "Null Id Type"),
        if (includeApprovalDecision)
          Reference(
            id: ServerConstants.subSubSubTypeCreditApplicationApprovalDecision,
            name: "Approval Decision",
          ),
        Reference(id: 10, name: "SubSubSub"),
      ],
    };
  }

  void stubGetDocumentsSuccess({
    List<Document> documents = const <Document>[],
  }) {
    when(
      () => mockRepository.getDocuments(
        showApprovalSubType: any(named: "showApprovalSubType"),
        documentTypes: any(named: "documentTypes"),
        subTypes: any(named: "subTypes"),
        subSubTypes: any(named: "subSubTypes"),
        subSubSubTypes: any(named: "subSubSubTypes"),
        languages: any(named: "languages"),
      ),
    ).thenAnswer((_) async => documents);
  }

  void stubGetFileAccessTreeSuccess({
    List<FileAccess> fileAccesses = const <FileAccess>[],
    List<Document> documents = const <Document>[],
  }) {
    when(() => mockRepository.getFileAccessRight())
        .thenAnswer((_) async => fileAccesses);

    stubGetDocumentsSuccess(documents: documents);

    when(() => mockRepository.calculateFileCountsAggregated(any(), any()))
        .thenReturn(fileAccesses);
  }

  void stubDigitalFilingSuccess({
    List<FileDetail> fileDetails = const <FileDetail>[],
  }) {
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
        isLegacy: any(named: "isLegacy"),
      ),
    ).thenAnswer((_) async => fileDetails);
  }

  group("FileAttachmentViewModel - initial values", () {
    test("initial state and fields should be correct", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.state.documentsLoaderStatus, LoadingStatus.loaded);
      expect(viewModel.state.digitalFilesStatus, LoadingStatus.loaded);
      expect(viewModel.formKey, isA<GlobalKey<FormState>>());
      expect(viewModel.request.applicationRefNo, "TEST123");
      expect(viewModel.selectedFiles, isEmpty);
      expect(viewModel.selectedDocuments, isEmpty);
      expect(viewModel.selectedDocumentIds, isEmpty);
      expect(viewModel.selectedDocs, isEmpty);
      expect(viewModel.uploadedDocuments, isEmpty);
      expect(viewModel.allDocuments, isEmpty);
      expect(viewModel.fileAccesses, isEmpty);
      expect(viewModel.fileUploadDatas, isEmpty);
      expect(viewModel.rimList, isEmpty);
      expect(viewModel.selectedCompanyRims, isEmpty);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.selectedFolder, isNull);
      expect(viewModel.selectedDate, isNotNull);
      expect(viewModel.selectedDocumentType, isNull);
      expect(viewModel.selectedSubType, isNull);
      expect(viewModel.selectedSubTypeCreditLens, isNull);
      expect(viewModel.selectedSubSubType, isNull);
      expect(viewModel.selectedSubSubSubType, isNull);
      expect(viewModel.documentTypes, isEmpty);
      expect(viewModel.fileType, isEmpty);
      expect(viewModel.languages, isEmpty);
      expect(viewModel.caSubTypes, isEmpty);
      expect(viewModel.caSubSubTypes, isEmpty);
      expect(viewModel.caSubSubSubTypes, isEmpty);
      expect(viewModel.clSubTypes, isEmpty);
      expect(viewModel.cdSubTypes, isEmpty);
      expect(viewModel.fstSubTypes, isEmpty);
      expect(viewModel.fstSubSubTypes, isEmpty);
      expect(viewModel.selectedCheckbocDocuments, isEmpty);
      expect(viewModel.selectedRows, isEmpty);
      expect(viewModel.selectedGroupRim, isNull);
      expect(viewModel.isSelectAllCompanyRims, isFalse);
      expect(viewModel.canEdit, isFalse);
      expect(viewModel.pageMode, PageMode.na);
    });

    test("canEdit should return true when pageMode is edit", () {
      viewModel.pageMode = PageMode.edit;

      expect(viewModel.canEdit, isTrue);
    });

    test("canEdit should return false when pageMode is not edit", () {
      viewModel.pageMode = PageMode.na;

      expect(viewModel.canEdit, isFalse);
    });
  });

  group("buttonVisibilityStatus", () {
    test("visibility closures should return bool values", () {
      final downloadDocuments = viewModel
          .buttonVisibilityStatus[FileAttachmentFields.downloadDocuments]!();
      final showApprovalDecision = viewModel
          .buttonVisibilityStatus[FileAttachmentFields.showApprovalDecision]!();

      expect(downloadDocuments, isA<bool>());
      expect(showApprovalDecision, isA<bool>());
    });
  });

  group("loadReferenceData", () {
    test("should populate reference data lists", () async {
      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenAnswer((_) async => buildReferenceData());

      await viewModel.loadReferenceData();

      expect(viewModel.fileType, hasLength(1));
      expect(viewModel.documentTypes, hasLength(1));
      expect(viewModel.fstSubTypes, hasLength(1));
      expect(viewModel.fstSubSubTypes, hasLength(1));
      expect(viewModel.languages, hasLength(1));
      expect(viewModel.clSubTypes, hasLength(1));
      expect(viewModel.applicationTypeCustom, hasLength(1));
      expect(viewModel.caSubTypes, hasLength(1));
      expect(viewModel.caSubSubTypes, hasLength(1));
      expect(viewModel.caSubSubSubTypes, hasLength(1));
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

    test("should execute approval subtype filtering branch safely", () async {
      when(() => mockReferenceDataService.getReferenceData(any())).thenAnswer(
        (_) async => buildReferenceData(
          includeApprovalDecision: true,
          includeNullApprovalId: true,
        ),
      );

      await viewModel.loadReferenceData();

      expect(viewModel.caSubSubSubTypes, isA<List<Reference>>());
    });
  });

  group("simple update methods", () {
    test("updateDocumentName should update documentName", () {
      viewModel.updateDocumentName("Test Document");

      expect(viewModel.documentName, "Test Document");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateDocumentName should support null", () {
      viewModel.updateDocumentName(null);

      expect(viewModel.documentName, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateEntityId should update entityId", () {
      viewModel.updateEntityId("ENTITY-001");

      expect(viewModel.entityId, "ENTITY-001");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateEntityId should support null", () {
      viewModel.updateEntityId(null);

      expect(viewModel.entityId, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateLanguageType should update selectedLanguageType", () {
      final ref = Reference(id: 1, name: "English");

      viewModel.updateLanguageType(ref);

      expect(viewModel.selectedLanguageType, ref);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateSubTypeCredit should update selectedSubSubType", () {
      final ref = Reference(id: 1, name: "Credit Type");

      viewModel.updateSubTypeCredit(ref);

      expect(viewModel.selectedSubSubType, ref);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateSubTypeCreditLens should update selectedSubTypeCreditLens", () {
      final ref = Reference(id: 1, name: "Credit Lens");

      viewModel.updateSubTypeCreditLens(ref);

      expect(viewModel.selectedSubTypeCreditLens, ref);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateSubType should update selectedSubType", () {
      final ref = Reference(id: 1, name: "Sub Type");

      viewModel.updateSubType(ref);

      expect(viewModel.selectedSubType, ref);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateSubSubType should update selectedSubSubType", () {
      final ref = Reference(id: 1, name: "SubSub Type");

      viewModel.updateSubSubType(ref);

      expect(viewModel.selectedSubSubType, ref);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updatesubsubsubType should update selectedSubSubSubType", () {
      final ref = Reference(id: 1, name: "SubSubSub Type");

      viewModel.updatesubsubsubType(ref);

      expect(viewModel.selectedSubSubSubType, ref);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateCompanyRim should update selectedCompanyRims", () {
      final rims = <Customer>[
        Customer(customerRimNo: 1),
        Customer(customerRimNo: 2),
      ];

      viewModel.updateCompanyRim(rims);

      expect(viewModel.selectedCompanyRims, rims);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onDocumentTypeChanged should reset and update selectedDocumentType",
        () {
      viewModel
        ..selectedLanguageType = Reference(id: 1, name: "English")
        ..selectedSubType = Reference(id: 2, name: "Sub")
        ..selectedCompanyRims = <Customer>[Customer(customerRimNo: 10)]
        ..documentName = "Old"
        ..entityId = "Old Entity"
        ..selectedDate = DateTime(2024)
        ..selectedSubSubType = Reference(id: 3, name: "SubSub")
        ..selectedSubSubSubType = Reference(id: 4, name: "SubSubSub")
        ..selectedSubTypeCreditLens = Reference(id: 5, name: "CL");

      final ref = Reference(id: 99, name: "New Document Type");

      viewModel.onDocumentTypeChanged(ref);

      expect(viewModel.selectedDocumentType, ref);
      expect(viewModel.selectedLanguageType, isNull);
      expect(viewModel.selectedSubType, isNull);
      expect(viewModel.selectedCompanyRims, isEmpty);
      expect(viewModel.documentName, isNull);
      expect(viewModel.entityId, isNull);
      expect(viewModel.selectedDate, isNull);
      expect(viewModel.selectedSubSubType, isNull);
      expect(viewModel.selectedSubSubSubType, isNull);
      expect(viewModel.selectedSubTypeCreditLens, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("resetFormFields", () {
    test("should clear all form fields", () {
      viewModel
        ..selectedLanguageType = Reference(name: "English")
        ..selectedSubType = Reference(name: "SubType")
        ..selectedSubTypeCreditLens = Reference(name: "Credit Lens")
        ..selectedSubSubType = Reference(name: "SubFinancial")
        ..selectedSubSubSubType = Reference(name: "Third")
        ..selectedCompanyRims = <Customer>[Customer(customerRimNo: 1)]
        ..documentName = "Test"
        ..entityId = "ENT-1"
        ..selectedDate = DateTime.now()
        ..selectedDocumentType = Reference(name: "DocType")
        ..isSelectAllCompanyRims = true
        ..resetFormFields();

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

  group("selection helpers", () {
    test("toggleSelection should update selectedRows", () {
      viewModel.toggleSelection("doc1", isSelected: true);

      expect(viewModel.selectedRows["doc1"], true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      viewModel.toggleSelection("doc1", isSelected: false);

      expect(viewModel.selectedRows["doc1"], false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("toggleDocumentSelection should add document and id when selected",
        () async {
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

    test(
        "toggleDocumentSelection should remove document and id when unselected",
        () async {
      final docData = DocSubTypeData(edmsDriveItemId: "doc123");

      await viewModel.toggleDocumentSelection(
        "key1",
        docData,
        isSelected: true,
      );

      await viewModel.toggleDocumentSelection(
        "key1",
        docData,
        isSelected: false,
      );

      expect(docData.isChecked, isFalse);
      expect(viewModel.selectedDocumentIds, isNot(contains("doc123")));
      expect(viewModel.selectedDocs, isNot(contains(docData)));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("toggleDocumentSelection should not add when edmsDriveItemId is empty",
        () async {
      final docData = DocSubTypeData(edmsDriveItemId: "");

      await viewModel.toggleDocumentSelection(
        "key1",
        docData,
        isSelected: true,
      );

      expect(docData.isChecked, isTrue);
      expect(viewModel.selectedDocumentIds, isEmpty);
      expect(viewModel.selectedDocs, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("toggleDocumentSelection should handle null docData", () async {
      await viewModel.toggleDocumentSelection(
        "key1",
        null,
        isSelected: true,
      );

      expect(viewModel.selectedDocumentIds, isEmpty);
      expect(viewModel.selectedDocs, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("markCheckedByEdmsId", () {
    test("should return safely when list is null", () async {
      await viewModel.markCheckedByEdmsId(
        null,
        "id",
        isChecked: true,
      );

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("should return safely when target id is null", () async {
      await viewModel.markCheckedByEdmsId(
        <FileDetail>[],
        null,
        isChecked: true,
      );

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("should iterate safely when list is empty", () async {
      await viewModel.markCheckedByEdmsId(
        <FileDetail>[],
        "id",
        isChecked: true,
      );

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });
  });

  group("removeFileAt", () {
    test("should remove document at valid index", () {
      viewModel
        ..selectedDocuments = <Document>[
          Document(documentName: "Doc1"),
          Document(documentName: "Doc2"),
          Document(documentName: "Doc3"),
        ]
        ..removeFileAt(1);

      expect(viewModel.selectedDocuments, hasLength(2));
      expect(viewModel.selectedDocuments[0].documentName, "Doc1");
      expect(viewModel.selectedDocuments[1].documentName, "Doc3");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("should ignore index out of bounds", () {
      viewModel
        ..selectedDocuments = <Document>[Document(documentName: "Doc1")]
        ..removeFileAt(5);

      expect(viewModel.selectedDocuments, hasLength(1));
    });

    test("should ignore negative index", () {
      viewModel
        ..selectedDocuments = <Document>[Document(documentName: "Doc1")]
        ..removeFileAt(-1);

      expect(viewModel.selectedDocuments, hasLength(1));
    });
  });

  group("document type helpers", () {
    test("document type helper methods should return correct values", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.constitutionalDocument],
      );
      expect(viewModel.isConstitutionalDocumentsSelected(), isTrue);

      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.creditApplication],
      );
      expect(viewModel.isCreditApplicationSelected(), isTrue);

      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.creditLensDocument],
      );
      expect(viewModel.isCreditLensSelected(), isTrue);

      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.financialStatements],
      );
      expect(viewModel.isFinancialStatementsSelected(), isTrue);

      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.externalOpinions],
      );
      expect(viewModel.isExternalOpinionsSelected(), isTrue);

      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.other],
      );
      expect(viewModel.isOthersSelected(), isTrue);

      viewModel.selectedDocumentType = Reference(id: 999);
      expect(viewModel.isConstitutionalDocumentsSelected(), isFalse);
      expect(viewModel.isCreditApplicationSelected(), isFalse);
      expect(viewModel.isCreditLensSelected(), isFalse);
      expect(viewModel.isFinancialStatementsSelected(), isFalse);
      expect(viewModel.isExternalOpinionsSelected(), isFalse);
      expect(viewModel.isOthersSelected(), isFalse);

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
      final folder = FileAccess(
        id: 1,
        name: "Folder",
        access: AccessType.edit,
        children: <FileAccess>[],
      );

      viewModel
        ..allDocuments = <Document>[
          Document(documentName: "Doc1", folderID: 1),
          Document(documentName: "Doc2", folderID: 2),
          Document(documentName: "Doc3", folderID: 1),
        ]
        ..onSelectFolder(folder);

      expect(viewModel.selectedFolder, folder);
      expect(viewModel.uploadedDocuments, hasLength(2));
      expect(viewModel.state.showUploadButton, isTrue);
      expect(viewModel.state.showUploadForm, isFalse);
      expect(viewModel.state.documentsLoaderStatus, LoadingStatus.loaded);
    });

    test("onSelectFolder should set empty status when no documents found", () {
      final folder = FileAccess(
        id: 1,
        name: "Folder",
        access: AccessType.edit,
        children: <FileAccess>[],
      );

      viewModel
        ..allDocuments = <Document>[]
        ..onSelectFolder(folder);

      expect(viewModel.uploadedDocuments, isEmpty);
      expect(viewModel.state.documentsLoaderStatus, LoadingStatus.empty);
    });

    test("onSelectFolder should set error status for AccessType.none", () {
      final folder = FileAccess(
        id: 1,
        name: "Folder",
        access: AccessType.none,
        children: <FileAccess>[],
      );

      viewModel.onSelectFolder(folder);

      expect(viewModel.selectedFolder, folder);
      expect(viewModel.state.documentsLoaderStatus, LoadingStatus.error);
      expect(viewModel.state.documentListErrorMessage, isNotNull);
    });

    test("showUploadForm should update state for edit access", () {
      viewModel
        ..selectedFolder = FileAccess(
          id: 1,
          name: "Folder",
          access: AccessType.edit,
          children: <FileAccess>[],
        )
        ..showUploadForm();

      expect(viewModel.state.showUploadForm, isTrue);
      expect(viewModel.state.showUploadButton, isFalse);
    });

    test("showUploadForm should show toast and return for non-edit access", () {
      viewModel
        ..selectedFolder = FileAccess(
          id: 1,
          name: "Folder",
          access: AccessType.none,
          children: <FileAccess>[],
        )
        ..showUploadForm();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.showUploadForm, isNot(true));
    });

    test("showUploadForm should throw if selectedFolder is null", () {
      viewModel.selectedFolder = null;

      expect(
        () => viewModel.showUploadForm(),
        throwsA(isA<TypeError>()),
      );
    });

    test("onSelectFolder should reset form fields before selecting folder", () {
      final folder = FileAccess(
        id: 100,
        name: "Folder 100",
        access: AccessType.edit,
        children: <FileAccess>[],
      );

      viewModel
        ..selectedLanguageType = Reference(name: "English")
        ..selectedSubType = Reference(name: "Sub Type")
        ..selectedSubTypeCreditLens = Reference(name: "Credit Lens")
        ..selectedSubSubType = Reference(name: "SubSub")
        ..selectedSubSubSubType = Reference(name: "SubSubSub")
        ..selectedCompanyRims = <Customer>[Customer(customerRimNo: 1)]
        ..documentName = "Before"
        ..entityId = "Entity"
        ..selectedDate = DateTime(2025)
        ..selectedDocumentType = Reference(name: "Doc Type")
        ..allDocuments = <Document>[
          Document(documentName: "Folder Doc", folderID: 100),
        ]
        ..onSelectFolder(folder);

      expect(viewModel.selectedFolder, folder);
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
      expect(viewModel.uploadedDocuments, hasLength(1));
      expect(viewModel.state.documentsLoaderStatus, LoadingStatus.loaded);
    });
  });

  group("getFileAccessTree", () {
    test("should load data successfully", () async {
      final fileAccesses = <FileAccess>[
        FileAccess(
          id: 1,
          name: "Folder",
          access: AccessType.edit,
          children: <FileAccess>[],
        ),
      ];

      stubGetFileAccessTreeSuccess(fileAccesses: fileAccesses);

      await viewModel.getFileAccessTree();

      expect(viewModel.fileAccesses, fileAccesses);
      expect(viewModel.allDocuments, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("should handle repository exception", () async {
      when(() => mockRepository.getFileAccessRight())
          .thenThrow(Exception("file access error"));

      await viewModel.getFileAccessTree();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("should pass populated reference lists to repository", () async {
      viewModel
        ..documentTypes = <Reference>[Reference(id: 1, name: "Doc Type")]
        ..fstSubTypes = <Reference>[Reference(id: 2, name: "FST")]
        ..clSubTypes = <Reference>[Reference(id: 3, name: "CL")]
        ..cdSubTypes = <Reference>[Reference(id: 4, name: "CD")]
        ..caSubTypes = <Reference>[Reference(id: 5, name: "CA")]
        ..fstSubSubTypes = <Reference>[Reference(id: 6, name: "FST SubSub")]
        ..caSubSubTypes = <Reference>[Reference(id: 7, name: "CA SubSub")]
        ..applicationTypeCustom = <Reference>[Reference(id: 8, name: "Custom")]
        ..caSubSubSubTypes = <Reference>[Reference(id: 9, name: "SubSubSub")]
        ..languages = <Reference>[Reference(id: 10, name: "English")];

      final fileAccesses = <FileAccess>[
        FileAccess(
          id: 1,
          name: "Folder",
          access: AccessType.edit,
          children: <FileAccess>[],
        ),
      ];

      final documents = <Document>[
        Document(documentName: "Doc", folderID: 1),
      ];

      when(() => mockRepository.getFileAccessRight())
          .thenAnswer((_) async => fileAccesses);

      when(
        () => mockRepository.getDocuments(
          showApprovalSubType: any(named: "showApprovalSubType"),
          documentTypes: any(named: "documentTypes"),
          subTypes: any(named: "subTypes"),
          subSubTypes: any(named: "subSubTypes"),
          subSubSubTypes: any(named: "subSubSubTypes"),
          languages: any(named: "languages"),
        ),
      ).thenAnswer((_) async => documents);

      when(() => mockRepository.calculateFileCountsAggregated(any(), any()))
          .thenReturn(fileAccesses);

      await viewModel.getFileAccessTree();

      expect(viewModel.fileAccesses, fileAccesses);
      expect(viewModel.allDocuments, documents);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getDigitalFilingViewData", () {
    test("should load file upload data successfully", () async {
      stubDigitalFilingSuccess();

      await viewModel.getDigitalFilingViewData();

      expect(viewModel.fileUploadDatas, isEmpty);
      expect(viewModel.selectedDocs, isEmpty);
      expect(viewModel.selectedDocumentIds, isEmpty);
      expect(viewModel.state.digitalFilesStatus, LoadingStatus.loaded);
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
          isLegacy: any(named: "isLegacy"),
        ),
      ).thenThrow(Exception("digital filing error"));

      await viewModel.getDigitalFilingViewData();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.digitalFilesStatus, LoadingStatus.loaded);
    });

    test("should pass customer rim when request is non-group", () async {
      Globals.request = Request(
        applicationRefNo: "APP-NON-GROUP",
        customerRimNo: 11111,
      );

      viewModel = FileAttachmentViewModel()
        ..fileAttachmentRepository = mockRepository;

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
          isLegacy: false,
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
          isLegacy: false,
        ),
      ).called(1);
    });

    test("should pass group id when request is group application", () async {
      Globals.request = Request(
        applicationRefNo: "APP-GROUP",
        customerRimNo: 22222,
        groupId: 99999,
      );

      viewModel = FileAttachmentViewModel()
        ..fileAttachmentRepository = mockRepository;

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
          isLegacy: false,
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
          isLegacy: false,
        ),
      ).called(1);
    });

    test("should clear existing selections before load", () async {
      viewModel
        ..selectedDocs = <DocSubTypeData?>[
          DocSubTypeData(edmsDriveItemId: "old-doc"),
        ]
        ..selectedDocumentIds = <String>["old-doc"];

      stubDigitalFilingSuccess();

      await viewModel.getDigitalFilingViewData();

      expect(viewModel.selectedDocs, isEmpty);
      expect(viewModel.selectedDocumentIds, isEmpty);
      expect(viewModel.state.digitalFilesStatus, LoadingStatus.loaded);
    });
  });

  group("upload documents", () {
    test("onUploadDocumentsPressed should upload and clear documents",
        () async {
      viewModel
        ..selectedDocuments = <Document>[
          Document(documentName: "Test"),
        ]
        ..selectedFolder = FileAccess(
          id: 1,
          name: "Folder",
          access: AccessType.edit,
          children: <FileAccess>[],
        );

      when(() => mockRepository.uploadDocumentsMultipart(any()))
          .thenAnswer((_) async => "Uploaded successfully");
      stubGetFileAccessTreeSuccess();

      await viewModel.onUploadDocumentsPressed();

      expect(viewModel.selectedDocuments, isEmpty);
      expect(viewModel.state.uploadStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showSuccessToast("Uploaded successfully"))
          .called(1);
    });

    test("onUploadDocumentsPressed should handle exception", () async {
      viewModel.selectedDocuments = <Document>[
        Document(documentName: "Test"),
      ];

      when(() => mockRepository.uploadDocumentsMultipart(any()))
          .thenThrow(Exception("upload failed"));

      await viewModel.onUploadDocumentsPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.uploadStatus, LoadingStatus.error);
    });

    test("onUploadDocumentsPressed should refresh selected folder after upload",
        () async {
      final folder = FileAccess(
        id: 7,
        name: "Folder 7",
        access: AccessType.edit,
        children: <FileAccess>[],
      );

      viewModel
        ..selectedFolder = folder
        ..selectedDocuments = <Document>[
          Document(documentName: "Upload Doc"),
        ]
        ..allDocuments = <Document>[
          Document(documentName: "Uploaded Doc", folderID: 7),
        ];

      when(() => mockRepository.uploadDocumentsMultipart(any()))
          .thenAnswer((_) async => "Uploaded");

      stubGetFileAccessTreeSuccess(
        documents: <Document>[
          Document(documentName: "Uploaded Doc", folderID: 7),
        ],
      );

      await viewModel.onUploadDocumentsPressed();

      expect(viewModel.selectedDocuments, isEmpty);
      expect(viewModel.selectedFolder, folder);
      expect(viewModel.state.uploadStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showSuccessToast("Uploaded")).called(1);
    });

    test(
        "onUploadDocumentsPressed should not select folder when selectedFolder is null",
        () async {
      viewModel
        ..selectedFolder = null
        ..selectedDocuments = <Document>[
          Document(documentName: "Upload Doc"),
        ];

      when(() => mockRepository.uploadDocumentsMultipart(any()))
          .thenAnswer((_) async => "Uploaded");

      stubGetFileAccessTreeSuccess();

      await viewModel.onUploadDocumentsPressed();

      expect(viewModel.selectedDocuments, isEmpty);
      expect(viewModel.selectedFolder, isNull);
      expect(viewModel.state.uploadStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showSuccessToast("Uploaded")).called(1);
    });
  });

  group("onBrowsePressed validation and success", () {
    testWidgets("should return when form validation fails", (tester) async {
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

      await viewModel.onBrowsePressed();

      expect(viewModel.selectedDocuments, isEmpty);
      expect(viewModel.selectedFiles, isEmpty);
    });

    testWidgets(
      "should create documents when files are selected for non-group request",
      (tester) async {
        Globals.request = Request(
          applicationRefNo: "APP-123",
          customerRimNo: 55555,
        );

        viewModel = FileAttachmentViewModel()
          ..fileAttachmentRepository = mockRepository
          ..selectedFolder = FileAccess(
            id: 99,
            name: "Upload Folder",
            access: AccessType.edit,
            children: <FileAccess>[],
          )
          ..selectedDocumentType = Reference(
            id: ServerConstants
                .documentTypeId[DocumentType.financialStatements],
            name: "Financial Statements",
          )
          ..selectedSubType = Reference(id: 10, name: "Sub Type")
          ..selectedSubSubType = Reference(id: 20, name: "Sub Sub Type")
          ..selectedSubSubSubType = Reference(id: 30, name: "Sub Sub Sub Type")
          ..selectedLanguageType = Reference(id: 40, name: "English")
          ..documentName = "Uploaded Document"
          ..entityId = "ENTITY-1"
          ..selectedDate = DateTime(2025);

        final file = PlatformFile(
          name: "test.pdf",
          size: 3,
          bytes: Uint8List.fromList(<int>[1, 2, 3]),
        );

        FilePicker.platform = FakeFilePicker(
          result: FilePickerResult(<PlatformFile>[file]),
        );

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

        await viewModel.onBrowsePressed();

        expect(viewModel.selectedFiles, hasLength(1));
        expect(viewModel.selectedFiles.first.name, "test.pdf");
        expect(viewModel.selectedDocuments, hasLength(1));

        final document = viewModel.selectedDocuments.first;

        expect(document.folderID, 99);
        expect(document.documentType?.name, "Financial Statements");
        expect(document.subType?.name, "Sub Type");
        expect(document.subSubType?.name, "Sub Sub Type");
        expect(document.subSubSubType?.name, "Sub Sub Sub Type");
        expect(document.language?.name, "English");
        expect(document.documentName, "Uploaded Document");
        expect(document.entityId, "ENTITY-1");
        expect(document.applicationId, "APP-123");
        expect(document.companyRim, "55555");
        expect(document.files, hasLength(1));
        expect(document.files?.first.name, "test.pdf");
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

        expect(viewModel.selectedLanguageType, isNull);
        expect(viewModel.selectedSubType, isNull);
        expect(viewModel.selectedSubSubType, isNull);
        expect(viewModel.selectedSubSubSubType, isNull);
        expect(viewModel.selectedDocumentType, isNull);
        expect(viewModel.documentName, isNull);
        expect(viewModel.entityId, isNull);
        expect(viewModel.selectedDate, isNull);
      },
    );

    testWidgets(
      "should use request type and application type for credit application",
      (tester) async {
        final requestType = Reference(id: 11, name: "Request Type");
        final applicationType = Reference(id: 22, name: "Application Type");

        Globals.request = Request(
          applicationRefNo: "APP-CA",
          customerRimNo: 77777,
          requestType: requestType,
          applicationType: applicationType,
        );

        viewModel = FileAttachmentViewModel()
          ..fileAttachmentRepository = mockRepository
          ..selectedFolder = FileAccess(
            id: 10,
            name: "Credit Folder",
            access: AccessType.edit,
            children: <FileAccess>[],
          )
          ..selectedDocumentType = Reference(
            id: ServerConstants.documentTypeId[DocumentType.creditApplication],
            name: "Credit Application",
          )
          ..documentName = "Credit App Doc";

        final file = PlatformFile(
          name: "credit.pdf",
          size: 3,
          bytes: Uint8List.fromList(<int>[1, 2, 3]),
        );

        FilePicker.platform = FakeFilePicker(
          result: FilePickerResult(<PlatformFile>[file]),
        );

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

        await viewModel.onBrowsePressed();

        expect(viewModel.selectedDocuments, hasLength(1));

        final document = viewModel.selectedDocuments.first;

        expect(document.documentType?.name, "Credit Application");
        expect(document.subType, requestType);
        expect(document.subSubType, applicationType);
        expect(document.companyRim, "77777");
        expect(document.files?.first.name, "credit.pdf");
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );

    testWidgets(
      "should create documents for selected company rims in group request",
      (tester) async {
        Globals.request = Request(
          applicationRefNo: "APP-GROUP-BROWSE",
          customerRimNo: 12345,
          groupId: 99999,
        );

        viewModel = FileAttachmentViewModel()
          ..fileAttachmentRepository = mockRepository
          ..selectedFolder = FileAccess(
            id: 15,
            name: "Group Folder",
            access: AccessType.edit,
            children: <FileAccess>[],
          )
          ..selectedDocumentType = Reference(
            id: ServerConstants
                .documentTypeId[DocumentType.financialStatements],
            name: "Financial Statements",
          )
          ..selectedCompanyRims = <Customer>[
            Customer(customerRimNo: 101),
            Customer(customerRimNo: 202),
          ]
          ..documentName = "Group Upload";

        final file = PlatformFile(
          name: "group.pdf",
          size: 3,
          bytes: Uint8List.fromList(<int>[1, 2, 3]),
        );

        FilePicker.platform = FakeFilePicker(
          result: FilePickerResult(<PlatformFile>[file]),
        );

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

        await viewModel.onBrowsePressed();

        expect(viewModel.selectedDocuments, hasLength(2));
        expect(viewModel.selectedDocuments[0].companyRim, "101");
        expect(viewModel.selectedDocuments[1].companyRim, "202");
        expect(viewModel.selectedDocuments[0].groupRim, 99999);
        expect(viewModel.selectedDocuments[1].groupRim, 99999);
        expect(viewModel.selectedFiles, hasLength(1));
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );

    testWidgets(
      "should set errorMessage when picker returns empty files",
      (tester) async {
        FilePicker.platform = FakeFilePicker(
          result: const FilePickerResult(<PlatformFile>[]),
        );

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

        await viewModel.onBrowsePressed();

        expect(viewModel.selectedFiles, isEmpty);
        expect(viewModel.selectedDocuments, isEmpty);
        expect(
          viewModel.errorMessage,
          "eDigitalFilingFileAttachments.fileAttachments.noFilesSelected",
        );
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );

    testWidgets(
      "should set errorMessage when picker returns null",
      (tester) async {
        FilePicker.platform = FakeFilePicker(result: null);

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

        await viewModel.onBrowsePressed();

        expect(viewModel.selectedFiles, isEmpty);
        expect(viewModel.selectedDocuments, isEmpty);
        expect(
          viewModel.errorMessage,
          "eDigitalFilingFileAttachments.fileAttachments.noFilesSelected",
        );
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );
  });

  group("download and delete actions", () {
    test("downloadViewDocument should call repository and reset loader",
        () async {
      final document = Document(documentName: "Test");

      when(() => mockRepository.downloadFileAttachment(any()))
          .thenAnswer((_) async {});

      await viewModel.downloadViewDocument(document);

      verify(() => mockRepository.downloadFileAttachment(document)).called(1);
      expect(document.downloadLoader, LoadingStatus.loaded);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("downloadViewDocument should handle exception and reset loader",
        () async {
      final document = Document(documentName: "Test");

      when(() => mockRepository.downloadFileAttachment(any()))
          .thenThrow(Exception("download failed"));

      await viewModel.downloadViewDocument(document);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(document.downloadLoader, LoadingStatus.loaded);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("downloadViewDocument should emit loading before repository completes",
        () async {
      final document = Document(documentName: "Slow Download");

      final completer = Completer<void>();

      when(() => mockRepository.downloadFileAttachment(any()))
          .thenAnswer((_) => completer.future);

      final future = viewModel.downloadViewDocument(document);

      expect(document.downloadLoader, LoadingStatus.loading);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      completer.complete();
      await future;

      expect(document.downloadLoader, LoadingStatus.loaded);
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

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("downloadDocumentsZip should call repository successfully", () async {
      viewModel
        ..selectedDocumentIds = <String>["1", "2"]
        ..selectedDocs = <DocSubTypeData?>[
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

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("downloadDocumentsZip should pass empty selections safely", () async {
      viewModel
        ..selectedDocumentIds = <String>[]
        ..selectedDocs = <DocSubTypeData?>[];

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
          <String>[],
          <DocSubTypeData?>[],
          viewModel.request.customerRimNo.toString(),
          viewModel.request.groupId.toString(),
          Globals.request?.applicationRefNo,
        ),
      ).called(1);
    });

    test("mergeDownloadDocument should call repository successfully", () async {
      viewModel
        ..selectedDocumentIds = <String>["1", "2"]
        ..selectedDocs = <DocSubTypeData?>[
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

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("mergeDownloadDocument should pass empty selections safely", () async {
      viewModel
        ..selectedDocumentIds = <String>[]
        ..selectedDocs = <DocSubTypeData?>[];

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
          <DocSubTypeData?>[],
          <String>[],
          Globals.request!.customerRimNo?.toString(),
          Globals.request!.groupId?.toString(),
          "",
        ),
      ).called(1);
    });

    test("onDeleteDocumentPressed should delete and reset loader", () async {
      final document = Document(documentName: "Test");

      viewModel.selectedFolder = FileAccess(
        id: 1,
        name: "Folder",
        access: AccessType.edit,
        children: <FileAccess>[],
      );

      when(() => mockRepository.deleteDocument(any()))
          .thenAnswer((_) async => null);
      stubGetFileAccessTreeSuccess();

      await viewModel.onDeleteDocumentPressed(document);

      verify(() => mockRepository.deleteDocument(document)).called(1);
      expect(document.deleteLoader, LoadingStatus.loaded);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onDeleteDocumentPressed should handle exception and reset loader",
        () async {
      final document = Document(documentName: "Test");

      when(() => mockRepository.deleteDocument(any()))
          .thenThrow(Exception("delete failed"));

      await viewModel.onDeleteDocumentPressed(document);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(document.deleteLoader, LoadingStatus.loaded);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onDeleteDocumentPressed should refresh selected folder after delete",
        () async {
      final folder = FileAccess(
        id: 9,
        name: "Folder 9",
        access: AccessType.edit,
        children: <FileAccess>[],
      );

      final document = Document(documentName: "Delete Doc", folderID: 9);

      viewModel
        ..selectedFolder = folder
        ..allDocuments = <Document>[
          Document(documentName: "Remaining Doc", folderID: 9),
        ];

      when(() => mockRepository.deleteDocument(any()))
          .thenAnswer((_) async => null);

      stubGetFileAccessTreeSuccess(
        documents: <Document>[
          Document(documentName: "Remaining Doc", folderID: 9),
        ],
      );

      await viewModel.onDeleteDocumentPressed(document);

      expect(document.deleteLoader, LoadingStatus.loaded);
      expect(viewModel.selectedFolder, folder);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "onDeleteDocumentPressed should skip folder refresh when selectedFolder is null",
        () async {
      final document = Document(documentName: "Delete Doc");

      viewModel.selectedFolder = null;

      when(() => mockRepository.deleteDocument(any()))
          .thenAnswer((_) async => null);

      stubGetFileAccessTreeSuccess();

      await viewModel.onDeleteDocumentPressed(document);

      expect(document.deleteLoader, LoadingStatus.loaded);
      expect(viewModel.selectedFolder, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      verify(() => mockRepository.deleteDocument(document)).called(1);
    });

    test(
        "onDeleteDocumentPressed should mark document loading before repository completes",
        () async {
      final document = Document(documentName: "Slow Delete");

      final completer = Completer<String?>();

      when(() => mockRepository.deleteDocument(any()))
          .thenAnswer((_) => completer.future);

      final future = viewModel.onDeleteDocumentPressed(document);

      expect(document.deleteLoader, LoadingStatus.loading);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      completer.complete(null);
      await future;

      expect(document.deleteLoader, LoadingStatus.loaded);
    });
  });

  group("company rim selection", () {
    test("toggleSelectAllCompanyRims should select all rims when true", () {
      viewModel
        ..rimList = <Customer>[
          Customer(customerRimNo: 1),
          Customer(customerRimNo: 2),
        ]
        ..toggleSelectAllCompanyRims(value: true);

      expect(viewModel.isSelectAllCompanyRims, isTrue);
      expect(viewModel.selectedCompanyRims, hasLength(2));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("toggleSelectAllCompanyRims should clear rims when false", () {
      viewModel
        ..rimList = <Customer>[
          Customer(customerRimNo: 1),
          Customer(customerRimNo: 2),
        ]
        ..selectedCompanyRims = <Customer>[
          Customer(customerRimNo: 1),
          Customer(customerRimNo: 2),
        ]
        ..toggleSelectAllCompanyRims(value: false);

      expect(viewModel.isSelectAllCompanyRims, isFalse);
      expect(viewModel.selectedCompanyRims, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("linkToApplication", () {
    test("should call repository when selected docs are valid", () async {
      viewModel
        ..selectedDocs = <DocSubTypeData?>[
          DocSubTypeData(edmsDriveItemId: "1"),
        ]
        ..selectedDocumentIds = <String>["1", "2"];

      when(() => mockRepository.linkToApplication(any(), any()))
          .thenAnswer((_) async => null);

      await viewModel.linkToApplication();

      verify(
        () => mockRepository.linkToApplication(
          Globals.request?.applicationRefNo,
          viewModel.selectedDocumentIds,
        ),
      ).called(1);
      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("should block credit application docs", () async {
      viewModel
        ..selectedDocs = <DocSubTypeData?>[
          DocSubTypeData(
            edmsDriveItemId: "1",
            docTypeId: DocumentType.creditApplication,
          ),
        ]
        ..selectedDocumentIds = <String>["1"];

      await viewModel.linkToApplication();

      verifyNever(() => mockRepository.linkToApplication(any(), any()));
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("should handle exception from repository", () async {
      viewModel
        ..selectedDocs = <DocSubTypeData?>[
          DocSubTypeData(edmsDriveItemId: "1"),
        ]
        ..selectedDocumentIds = <String>["1"];

      when(() => mockRepository.linkToApplication(any(), any()))
          .thenThrow(Exception("link failed"));

      await viewModel.linkToApplication();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("should still call repository when no docs selected", () async {
      viewModel
        ..selectedDocs = <DocSubTypeData?>[]
        ..selectedDocumentIds = <String>[];

      when(() => mockRepository.linkToApplication(any(), any()))
          .thenAnswer((_) async => null);

      await viewModel.linkToApplication();

      verify(() => mockRepository.linkToApplication(any(), any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("should handle null selected doc safely", () async {
      viewModel
        ..selectedDocs = <DocSubTypeData?>[null]
        ..selectedDocumentIds = <String>["1"];

      when(() => mockRepository.linkToApplication(any(), any()))
          .thenAnswer((_) async => null);

      await viewModel.linkToApplication();

      verify(
        () => mockRepository.linkToApplication(
          Globals.request?.applicationRefNo,
          viewModel.selectedDocumentIds,
        ),
      ).called(1);
      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
    });
  });

  group("FileAttachmentState", () {
    test("constructor should set initial values", () {
      final state = FileAttachmentState(
        loaderStatus: LoadingStatus.loading,
        documentsLoaderStatus: LoadingStatus.loaded,
        digitalFilesStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.documentsLoaderStatus, LoadingStatus.loaded);
      expect(state.digitalFilesStatus, LoadingStatus.loading);
    });

    test("copyWith should create new state with updated values", () {
      final initialState = FileAttachmentState(
        loaderStatus: LoadingStatus.loading,
        documentsLoaderStatus: LoadingStatus.loading,
      );

      final newState = initialState.copyWith(
        loaderStatus: LoadingStatus.loaded,
        showUploadButton: true,
      );

      expect(newState.loaderStatus, LoadingStatus.loaded);
      expect(newState.showUploadButton, isTrue);
      expect(newState.documentsLoaderStatus, LoadingStatus.loading);
    });

    test("copyWith should preserve unchanged values", () {
      final initialState = FileAttachmentState(
        loaderStatus: LoadingStatus.loading,
        documentsLoaderStatus: LoadingStatus.loaded,
        showUploadButton: false,
      );

      final newState = initialState.copyWith();

      expect(newState.loaderStatus, LoadingStatus.loading);
      expect(newState.documentsLoaderStatus, LoadingStatus.loaded);
      expect(newState.showUploadButton, isFalse);
    });

    test("copyWith should update all known values", () {
      final initialState = FileAttachmentState(
        loaderStatus: LoadingStatus.loading,
        documentsLoaderStatus: LoadingStatus.loading,
        digitalFilesStatus: LoadingStatus.loading,
        showUploadButton: false,
        showUploadForm: false,
      );

      final newState = initialState.copyWith(
        loaderStatus: LoadingStatus.loaded,
        documentsLoaderStatus: LoadingStatus.empty,
        digitalFilesStatus: LoadingStatus.loaded,
        uploadStatus: LoadingStatus.error,
        showUploadButton: true,
        showUploadForm: true,
        documentListErrorMessage: "Error message",
      );

      expect(newState.loaderStatus, LoadingStatus.loaded);
      expect(newState.documentsLoaderStatus, LoadingStatus.empty);
      expect(newState.digitalFilesStatus, LoadingStatus.loaded);
      expect(newState.uploadStatus, LoadingStatus.error);
      expect(newState.showUploadButton, isTrue);
      expect(newState.showUploadForm, isTrue);
      expect(newState.documentListErrorMessage, "Error message");
    });
  });

  group("hard singleton methods", () {
    test(
      "getCompanyRims is skipped because CustomerRepository.instance is not injectable",
      () {
        expect(viewModel.state.digitalFilesStatus, LoadingStatus.loading);
      },
      skip:
          "CustomerRepository.instance cannot be mocked with test code only. Add repository injection for full coverage.",
    );
  });
}
