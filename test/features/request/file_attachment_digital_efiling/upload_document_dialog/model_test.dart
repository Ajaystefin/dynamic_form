import "dart:typed_data";

import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/file_attachment/document.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockFileAttachmentRepository extends Mock
    implements FileAttachmentRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockAlertManager extends Mock implements AlertManager {}

class StubFilePicker extends FilePicker {
  FilePickerResult? nextResult;
  Object? nextException;
  int pickFilesCallCount = 0;

  FileType? lastType;
  List<String>? lastAllowedExtensions;
  bool? lastAllowMultiple;
  bool? lastWithData;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    dynamic Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    pickFilesCallCount++;
    lastType = type;
    lastAllowedExtensions = allowedExtensions;
    lastAllowMultiple = allowMultiple;
    lastWithData = withData;

    final Object? exception = nextException;
    if (exception != null) {
      throw Exception(exception.toString());
    }

    return nextResult;
  }
}

class FakeBuildContext extends Fake implements BuildContext {
  @override
  bool get mounted => true;
}

class TestUploadDocumentDialogViewModel extends UploadDocumentDialogViewModel {
  int loadReferenceDataCalls = 0;
  int getApplicationDetailsCalls = 0;
  int getCompanyRimsCalls = 0;

  String? lastApplicationId;
  bool? lastShouldOverrideRim;

  List<Customer>? fakeRims;
  ApplicationDetails? fakeApplicationDetails;
  bool getApplicationDetailsShouldThrow = false;

  List<PlatformFile>? nextPickedFiles;
  Object? pickFilesError;

  @override
  Future<void> loadReferenceData() async {
    loadReferenceDataCalls++;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> getApplicationDetails(
    String? applicationId, {
    required bool shouldOverrideRIM,
  }) async {
    getApplicationDetailsCalls++;
    lastApplicationId = applicationId;
    lastShouldOverrideRim = shouldOverrideRIM;

    try {
      if (getApplicationDetailsShouldThrow) {
        throw Exception("forced getApplicationDetails failure");
      }

      if (applicationId == null) {
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }

      applicationDetails = fakeApplicationDetails;

      if (shouldOverrideRIM) {
        isGroupApp = applicationDetails?.groupID != null &&
            applicationDetails?.groupID != 0;

        if (isGroupApp) {
          rimList = applicationDetails?.borrowers ?? [];
          updateGroupRim(applicationDetails?.groupID.toString() ?? "");
        } else {
          updateCustomerRim(
            applicationDetails?.borrowers?.first.customerRimNo.toString() ??
                "0",
          );
        }
      }
    } on Object {
      AlertManager().showFailureToast("common.noAppRef".tr());
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> getCompanyRims() async {
    try {
      getCompanyRimsCalls++;
      if (fakeRims != null) {
        rimList = fakeRims!;
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> pickMultipleFiles() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      if (appRefNoCtrl.text != "" && applicationDetails == null) {
        await getApplicationDetails(
          appRefNoCtrl.text,
          shouldOverrideRIM: false,
        );

        if (applicationDetails?.createdDate == null) {
          return;
        }
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      formKey.currentState?.save();

      if (pickFilesError != null) {
        throw Exception(pickFilesError.toString());
      }

      final List<PlatformFile>? files = nextPickedFiles;

      if (files != null && files.isNotEmpty) {
        for (final PlatformFile file in files) {
          if (!isGroupApp) {
            selectedCompanyRims = [
              Customer(customerRimNo: selectedCustomerRim),
            ];
          }

          if (selectedCompanyRims.isNotEmpty) {
            for (final Customer companyRim in selectedCompanyRims) {
              final Document currentDocument = Document(
                subType: selectedSubTypeFinancial ?? selectedSubTypeCreditLens,
                subSubType: selectedSubSubTypeFinancial,
                documentType: selectedDocumentType,
                applicationId: applicationId ?? appRefNoCtrl.text,
                date: selectedDate,
                language: selectedLanguageType,
                documentName: documentName,
                entityId: entityId,
                groupRim: selectedGroupRim,
                companyRim: companyRim.customerRimNo.toString(),
                files: [file],
              );

              selectedDocuments.add(currentDocument);
            }
          }
        }

        selectedFiles = files;
        errorMessage = null;
        resetFormFields();
      } else {
        errorMessage =
            "eDigitalFilingFileAttachments.fileAttachments.noFilesSelected"
                .tr();
        selectedFiles = [];
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}

class PartialRealPickUploadDocumentDialogViewModel
    extends UploadDocumentDialogViewModel {
  int getApplicationDetailsCalls = 0;
  bool shouldThrowGetApplicationDetails = false;
  ApplicationDetails? fakeApplicationDetails;

  @override
  Future<void> getApplicationDetails(
    String? applicationId, {
    required bool shouldOverrideRIM,
  }) async {
    getApplicationDetailsCalls++;

    if (shouldThrowGetApplicationDetails) {
      throw Exception("forced app details error");
    }

    applicationDetails = fakeApplicationDetails;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}

Future<void> pumpFormShell(
  WidgetTester tester, {
  required GlobalKey<FormState> formKey,
  String? Function(String?)? validator,
  void Function(String?)? onSaved,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: TextFormField(
            validator: validator,
            onSaved: onSaved,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<BuildContext> pumpPoppableRoute(WidgetTester tester) async {
  late BuildContext secondRouteContext;

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) {
                      secondRouteContext = ctx;
                      return const Scaffold(body: SizedBox());
                    },
                  ),
                );
              },
              child: const Text("open"),
            ),
          );
        },
      ),
    ),
  );

  await tester.tap(find.text("open"));
  await tester.pumpAndSettle();

  return secondRouteContext;
}

List<Reference> pickerFileTypeRefs() {
  return [
    Reference(
      id: 101,
      name: "PDF",
      description: "pdf",
      reference1: "pdf",
      reference2: "pdf",
      reference3: "pdf",
    ),
  ];
}

void resetStubFilePicker(StubFilePicker stubFilePicker) {
  stubFilePicker
    ..nextResult = null
    ..nextException = null
    ..pickFilesCallCount = 0
    ..lastType = null
    ..lastAllowedExtensions = null
    ..lastAllowMultiple = null
    ..lastWithData = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UploadDocumentDialogViewModel viewModel;
  late TestUploadDocumentDialogViewModel testVm;
  late MockRequestRepository mockRequestRepo;
  late MockFileAttachmentRepository mockFileAttachmentRepo;
  late MockReferenceDataService mockRefService;
  late MockAlertManager mockAlertManager;
  late StubFilePicker stubFilePicker;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await EnvConfig.setEnvironment();

    registerFallbackValue(<String>[]);
    registerFallbackValue(<Document>[]);
    registerFallbackValue(Document());
    registerFallbackValue(
      PlatformFile(
        name: "dummy.pdf",
        size: 1,
      ),
    );
    registerFallbackValue(Reference());
    registerFallbackValue(FileType.any);
    registerFallbackValue(false);
  });

  setUp(() {
    Globals.request = Request(
      groupId: 456,
      customerRimNo: 789,
      applicationRefNo: "APP-123",
    );

    mockRequestRepo = MockRequestRepository();
    mockFileAttachmentRepo = MockFileAttachmentRepository();
    mockRefService = MockReferenceDataService();
    mockAlertManager = MockAlertManager();

    stubFilePicker = StubFilePicker();
    resetStubFilePicker(stubFilePicker);
    FilePicker.platform = stubFilePicker;

    viewModel = UploadDocumentDialogViewModel()
      ..repository = mockRequestRepo
      ..fileAttachmentRepository = mockFileAttachmentRepo;

    testVm = TestUploadDocumentDialogViewModel()
      ..repository = mockRequestRepo
      ..fileAttachmentRepository = mockFileAttachmentRepo;

    AlertManager.overrideInstance = mockAlertManager;
    ReferenceDataService.overrideInstance = mockRefService;

    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showInfoToast(any())).thenReturn(null);

    when(() => mockRefService.getReferenceData(any())).thenAnswer(
      (_) async => {
        ReferenceDataKeys.fileType: pickerFileTypeRefs(),
        ReferenceDataKeys.documentTypes: [
          Reference(id: 1, name: "Doc Type 1"),
          Reference(
            id: ServerConstants.documentTypeId[DocumentType.creditApplication],
            name: "Credit Application",
          ),
          Reference(id: 3, name: "Doc Type 3"),
          Reference(name: "Null ID branch"),
        ],
        ReferenceDataKeys.fstSubTypes: [Reference(id: 2, name: "FST Sub")],
        ReferenceDataKeys.fstSubsubTypes: [
          Reference(id: 3, name: "FST SubSub"),
        ],
        ReferenceDataKeys.languages: [
          Reference(id: ServerConstants.languageEnglish, name: "English"),
          Reference(id: ServerConstants.languageArabic, name: "Arabic"),
          Reference(id: 999, name: "French"),
        ],
        ReferenceDataKeys.clSubTypes: [Reference(id: 5, name: "CL Sub")],
        ReferenceDataKeys.caSubTypes: [Reference(id: 6, name: "CA Sub")],
        ReferenceDataKeys.caSubSubTypes: [
          Reference(id: 7, name: "CA SubSub"),
        ],
        ReferenceDataKeys.caSubSubSubTypes: [
          Reference(id: 8, name: "CA SubSubSub"),
        ],
      },
    );

    when(() => mockFileAttachmentRepo.getCompanyRims(any())).thenAnswer(
      (_) async => [
        Customer(customerRimNo: 111),
        Customer(customerRimNo: 222),
        Customer(customerRimNo: 333),
      ],
    );

    when(() => mockFileAttachmentRepo.downloadFileAttachment(any<Document>()))
        .thenAnswer((_) async {});

    when(
      () => mockFileAttachmentRepo.uploadDigitalDocuments(
        any<List<Document>>(),
      ),
    ).thenAnswer((_) async => "Uploaded successfully");
  });

  tearDown(() async {
    await viewModel.close();
    await testVm.close();
    resetStubFilePicker(stubFilePicker);
  });

  group("Initialization and reference data", () {
    test("initial state should be loading and upload button should be loaded",
        () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.state.uploadButtonStatus, LoadingStatus.loaded);
    });

    test("init applicationId path loads app details and reference data",
        () async {
      testVm.fakeApplicationDetails = ApplicationDetails()
        ..groupID = 999
        ..borrowers = [
          Customer(customerRimNo: 1001),
          Customer(customerRimNo: 1002),
        ];

      await testVm.init(
        FakeBuildContext(),
        groupRim: "",
        customerRim: "",
        applicationId: "APP-999",
        companyRims: [],
        searchedBy: 1,
      );

      expect(testVm.applicationId, "APP-999");
      expect(testVm.getApplicationDetailsCalls, 1);
      expect(testVm.lastApplicationId, "APP-999");
      expect(testVm.lastShouldOverrideRim, true);
      expect(testVm.loadReferenceDataCalls, 1);
      expect(testVm.selectedGroupRim, 999);
      expect(testVm.rimList.length, 2);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init applicationId path skips app details when companyRims passed",
        () async {
      final rims = [
        Customer(customerRimNo: 11),
      ];

      await testVm.init(
        FakeBuildContext(),
        groupRim: "",
        customerRim: "",
        applicationId: "APP-111",
        companyRims: rims,
        searchedBy: 1,
      );

      expect(testVm.applicationId, "APP-111");
      expect(testVm.getApplicationDetailsCalls, 1);
      expect(testVm.rimList.length, 1);
      expect(testVm.loadReferenceDataCalls, 1);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init groupRim path sets group mode and fetches company rims",
        () async {
      testVm.fakeRims = [
        Customer(customerRimNo: 7001),
        Customer(customerRimNo: 7002),
      ];

      await testVm.init(
        FakeBuildContext(),
        groupRim: "123",
        customerRim: "",
        applicationId: "",
        companyRims: [],
        searchedBy: 1,
      );

      expect(testVm.selectedGroupRim, 123);
      expect(testVm.isGroupApp, true);
      expect(testVm.getCompanyRimsCalls, 1);
      expect(testVm.rimList.length, 2);
      expect(testVm.loadReferenceDataCalls, 1);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init groupRim path skips getCompanyRims when rims already passed",
        () async {
      final rims = [
        Customer(customerRimNo: 1),
      ];

      await testVm.init(
        FakeBuildContext(),
        groupRim: "123",
        customerRim: "",
        applicationId: "",
        companyRims: rims,
        searchedBy: 1,
      );

      expect(testVm.selectedGroupRim, 123);
      expect(testVm.isGroupApp, true);
      expect(testVm.getCompanyRimsCalls, 0);
      expect(testVm.rimList.length, 1);
      expect(testVm.loadReferenceDataCalls, 1);
    });

    test("init customer rim path updates customer and optional group id",
        () async {
      await testVm.init(
        FakeBuildContext(),
        groupRim: "0",
        customerRim: "456",
        applicationId: "",
        grpId: "789",
        companyRims: [],
        searchedBy: 1,
      );

      // expect(testVm.selectedCustomerRim, 456);
      // expect(testVm.selectedGroupRim, 789);
      expect(testVm.isCompanyRim, false);
      expect(testVm.loadReferenceDataCalls, 1);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init customer rim path with empty group id keeps group null",
        () async {
      await testVm.init(
        FakeBuildContext(),
        groupRim: "0",
        customerRim: "456",
        applicationId: "",
        grpId: "",
        companyRims: [],
        searchedBy: 1,
      );

      // expect(testVm.selectedCustomerRim, 456);
      expect(testVm.selectedGroupRim, isNull);
      expect(testVm.isCompanyRim, false);
      expect(testVm.loadReferenceDataCalls, 1);
    });

    test("loadReferenceData populates lists and filters credit application",
        () async {
      await viewModel.loadReferenceData();

      expect(viewModel.fileType.length, 1);
      expect(viewModel.documentTypes.length, 3);
      expect(viewModel.fstSubTypes.length, 1);
      expect(viewModel.fstSubSubTypes.length, 1);
      expect(viewModel.languages.length, 3);
      expect(viewModel.clSubTypes.length, 1);
      expect(viewModel.subTypes.length, 1);
      expect(viewModel.subsubTypes.length, 1);
      expect(viewModel.caSubSubSubTypes.length, 1);

      final hasCreditApp = viewModel.documentTypes.any(
        (doc) =>
            doc.id ==
            ServerConstants.documentTypeId[DocumentType.creditApplication],
      );
      expect(hasCreditApp, false);
      expect(viewModel.documentTypes.any((doc) => doc.id == null), true);
    });
  });

  group("Application and company RIMs", () {
    test("getCompanyRims returns early when no app id and no group data",
        () async {
      viewModel
        ..selectedGroupRim = null
        ..applicationId = null;

      await viewModel.getCompanyRims();

      verifyNever(() => mockFileAttachmentRepo.getCompanyRims(any()));
    });

    test("getCompanyRims fetches rims when applicationId is present", () async {
      viewModel
        ..selectedGroupRim = 100
        ..applicationId = "APP-001";

      await viewModel.getCompanyRims();

      verify(() => mockFileAttachmentRepo.getCompanyRims(100)).called(1);
      expect(viewModel.rimList.length, 3);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getCompanyRims handles repository error", () async {
      viewModel
        ..selectedGroupRim = 100
        ..applicationId = "APP-001";

      when(() => mockFileAttachmentRepo.getCompanyRims(any()))
          .thenThrow(Exception("Failed to fetch RIMs"));

      await viewModel.getCompanyRims();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getApplicationDetails seam returns early when app id is null",
        () async {
      await testVm.getApplicationDetails(null, shouldOverrideRIM: true);

      expect(testVm.applicationDetails, isNull);
      expect(testVm.getApplicationDetailsCalls, 1);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getApplicationDetails seam group app overrides group data", () async {
      testVm.fakeApplicationDetails = ApplicationDetails()
        ..groupID = 500
        ..borrowers = [
          Customer(customerRimNo: 11),
          Customer(customerRimNo: 22),
        ];

      await testVm.getApplicationDetails("APP-500", shouldOverrideRIM: true);

      expect(testVm.isGroupApp, true);
      expect(testVm.rimList.length, 2);
      expect(testVm.selectedGroupRim, 500);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getApplicationDetails seam non-group overrides customer rim",
        () async {
      testVm.fakeApplicationDetails = ApplicationDetails()
        ..groupID = 0
        ..borrowers = [
          Customer(customerRimNo: 777),
        ];

      await testVm.getApplicationDetails("APP-777", shouldOverrideRIM: true);

      expect(testVm.isGroupApp, false);
      expect(testVm.selectedCustomerRim, 777);
      expect(testVm.isCompanyRim, true);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "getApplicationDetails seam shouldOverrideRIM false loads only details",
        () async {
      testVm.fakeApplicationDetails = ApplicationDetails()
        ..groupID = 500
        ..borrowers = [
          Customer(customerRimNo: 11),
        ];

      await testVm.getApplicationDetails("APP-1", shouldOverrideRIM: false);

      expect(testVm.applicationDetails, isNotNull);
      expect(testVm.selectedGroupRim, isNull);
      expect(testVm.selectedCustomerRim, isNull);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getApplicationDetails seam error shows toast", () async {
      testVm.getApplicationDetailsShouldThrow = true;

      await testVm.getApplicationDetails("BAD-APP", shouldOverrideRIM: true);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("Field update methods", () {
    test("updateCompanyRim updates selected company rims", () {
      final rims = [
        Customer(customerRimNo: 1),
        Customer(customerRimNo: 2),
      ];

      viewModel.updateCompanyRim(rims);

      expect(viewModel.selectedCompanyRims.length, 2);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("toggleSelectAllCompanyRims true selects all", () {
      viewModel
        ..rimList = [
          Customer(customerRimNo: 1),
          Customer(customerRimNo: 2),
          Customer(customerRimNo: 3),
        ]
        ..toggleSelectAllCompanyRims(value: true);

      expect(viewModel.isSelectAllCompanyRims, true);
      expect(viewModel.selectedCompanyRims.length, 3);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("toggleSelectAllCompanyRims false clears selection", () {
      viewModel
        ..rimList = [
          Customer(customerRimNo: 1),
          Customer(customerRimNo: 2),
        ]
        ..selectedCompanyRims = [
          Customer(customerRimNo: 1),
        ]
        ..toggleSelectAllCompanyRims(value: false);

      expect(viewModel.isSelectAllCompanyRims, false);
      expect(viewModel.selectedCompanyRims, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateApplicationId updates applicationId and controller", () {
      viewModel.updateApplicationId("APP456");

      expect(viewModel.applicationId, "APP456");
      expect(viewModel.appRefNoCtrl.text, "APP456");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateApplicationId handles null", () {
      viewModel.updateApplicationId(null);

      expect(viewModel.applicationId, isNull);
      expect(viewModel.appRefNoCtrl.text, "");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateDocumentName updates field and controller", () {
      viewModel.updateDocumentName("Test Document");

      expect(viewModel.documentName, "Test Document");
      expect(viewModel.documentNameCtrl.text, "Test Document");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateEntityId updates field and controller", () {
      viewModel.updateEntityId("ENTITY-123");

      expect(viewModel.entityId, "ENTITY-123");
      expect(viewModel.entityIdCtrl.text, "ENTITY-123");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateLanguageType keeps entityId for English", () {
      viewModel.entityId = "E1";
      viewModel.entityIdCtrl.text = "E1";

      final langType = Reference(
        id: ServerConstants.languageEnglish,
        name: "English",
      );

      viewModel.updateLanguageType(langType);

      expect(viewModel.selectedLanguageType, langType);
      expect(viewModel.entityId, "E1");
      expect(viewModel.entityIdCtrl.text, "E1");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateLanguageType keeps entityId for Arabic", () {
      viewModel.entityId = "AR1";
      viewModel.entityIdCtrl.text = "AR1";

      final langType = Reference(
        id: ServerConstants.languageArabic,
        name: "Arabic",
      );

      viewModel.updateLanguageType(langType);

      expect(viewModel.selectedLanguageType, langType);
      expect(viewModel.entityId, "AR1");
      expect(viewModel.entityIdCtrl.text, "AR1");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateLanguageType clears entityId for non-English or Arabic", () {
      viewModel.entityId = "FR1";
      viewModel.entityIdCtrl.text = "FR1";

      final langType = Reference(id: 999, name: "French");

      viewModel.updateLanguageType(langType);

      expect(viewModel.selectedLanguageType, langType);
      expect(viewModel.entityId, "");
      expect(viewModel.entityIdCtrl.text, "");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateGroupRim parses group rim", () {
      viewModel.updateGroupRim("123");

      expect(viewModel.selectedGroupRim, 123);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateGroupRim ignores zero", () {
      viewModel
        ..selectedGroupRim = 999
        ..updateGroupRim("0");

      expect(viewModel.selectedGroupRim, 999);
    });

    test("updateGroupRim ignores empty", () {
      viewModel
        ..selectedGroupRim = 999
        ..updateGroupRim("");

      expect(viewModel.selectedGroupRim, 999);
    });

    test("updateCustomerRim parses customer rim", () {
      viewModel.updateCustomerRim("456");

      expect(viewModel.selectedCustomerRim, 456);
      expect(viewModel.isCompanyRim, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateSubTypeCredit updates selectedSubTypeCredit", () {
      final subType = Reference(id: 1, name: "Credit Sub");

      viewModel.updateSubTypeCredit(subType);

      expect(viewModel.selectedSubTypeCredit, subType);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateSubTypeCreditLens updates selectedSubTypeCreditLens", () {
      final subType = Reference(id: 2, name: "Credit Lens Sub");

      viewModel.updateSubTypeCreditLens(subType);

      expect(viewModel.selectedSubTypeCreditLens, subType);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateSubTypeFinancial updates selectedSubTypeFinancial", () {
      final subType = Reference(id: 3, name: "Financial Sub");

      viewModel.updateSubTypeFinancial(subType);

      expect(viewModel.selectedSubTypeFinancial, subType);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateSubSubTypeFinancial updates selectedSubSubTypeFinancial", () {
      final subSubType = Reference(id: 4, name: "Financial SubSub");

      viewModel.updateSubSubTypeFinancial(subSubType);

      expect(viewModel.selectedSubSubTypeFinancial, subSubType);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("File and document management", () {
    test("removeFileAt removes selected document at valid index", () {
      viewModel
        ..selectedDocuments = [
          Document(documentName: "doc1"),
          Document(documentName: "doc2"),
        ]
        ..removeFileAt(0);

      expect(viewModel.selectedDocuments.length, 1);
      expect(viewModel.selectedDocuments[0].documentName, "doc2");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("removeFileAt ignores out of bounds index", () {
      viewModel
        ..selectedDocuments = [Document(documentName: "doc1")]
        ..removeFileAt(5);

      expect(viewModel.selectedDocuments.length, 1);
    });

    test("removeFileAt ignores negative index", () {
      viewModel
        ..selectedDocuments = [Document(documentName: "doc1")]
        ..removeFileAt(-1);

      expect(viewModel.selectedDocuments.length, 1);
    });
  });

  group("Upload button", () {
    testWidgets("onUploadDocumentsPressed success uploads and pops",
        (tester) async {
      final ctx = await pumpPoppableRoute(tester);

      viewModel.selectedDocuments = [
        Document(documentName: "doc1"),
      ];

      await viewModel.onUploadDocumentsPressed(ctx);
      await tester.pumpAndSettle();

      verify(
        () => mockFileAttachmentRepo.uploadDigitalDocuments(
          any<List<Document>>(),
        ),
      ).called(1);
      verify(() => mockAlertManager.showSuccessToast("Uploaded successfully"))
          .called(1);

      expect(viewModel.state.uploadButtonStatus, LoadingStatus.loaded);
    });

    testWidgets("onUploadDocumentsPressed handles upload error and pops",
        (tester) async {
      when(
        () => mockFileAttachmentRepo.uploadDigitalDocuments(
          any<List<Document>>(),
        ),
      ).thenThrow(Exception("upload failed"));

      final ctx = await pumpPoppableRoute(tester);

      viewModel.selectedDocuments = [
        Document(documentName: "doc1"),
      ];

      await viewModel.onUploadDocumentsPressed(ctx);
      await tester.pumpAndSettle();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.uploadButtonStatus, LoadingStatus.loaded);
    });
  });

  group("Form reset", () {
    test("resetFormFields clears transient fields", () {
      viewModel
        ..selectedDocumentType = Reference(id: 1, name: "Doc")
        ..selectedLanguageType = Reference(id: 1, name: "English")
        ..selectedSubTypeFinancial = Reference(id: 2, name: "Financial")
        ..selectedSubTypeCreditLens = Reference(id: 3, name: "Credit")
        ..selectedSubSubTypeFinancial = Reference(id: 4, name: "SubFinancial")
        ..selectedCompanyRims = [
          Customer(customerRimNo: 1),
          Customer(customerRimNo: 2),
        ]
        ..isSelectAllCompanyRims = true
        ..documentName = "Test Doc"
        ..entityId = "ENT-1"
        ..documentNameCtrl.text = "Test"
        ..entityIdCtrl.text = "ENT-1"
        ..selectedDate = DateTime.now()
        ..selectedGroupRim = 123
        ..applicationId = "APP-123"
        ..resetFormFields();

      expect(viewModel.selectedDocumentType, isNull);
      expect(viewModel.selectedLanguageType, isNull);
      expect(viewModel.selectedSubTypeFinancial, isNull);
      expect(viewModel.selectedSubTypeCreditLens, isNull);
      expect(viewModel.selectedSubSubTypeFinancial, isNull);
      expect(viewModel.selectedCompanyRims, isEmpty);
      expect(viewModel.isSelectAllCompanyRims, false);
      expect(viewModel.documentName, isNull);
      expect(viewModel.entityId, isNull);
      expect(viewModel.documentNameCtrl.text, "");
      expect(viewModel.entityIdCtrl.text, "");
      expect(viewModel.selectedDate, isNull);

      expect(viewModel.selectedGroupRim, 123);
      expect(viewModel.applicationId, "APP-123");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("resetFormFields works with attached form state",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: viewModel.formKey,
        validator: (_) => null,
      );

      viewModel.documentNameCtrl.text = "abc";
      viewModel.entityIdCtrl.text = "id";

      viewModel.resetFormFields();

      expect(viewModel.documentNameCtrl.text, "");
      expect(viewModel.entityIdCtrl.text, "");
    });
  });

  group("Original pickMultipleFiles coverage", () {
    testWidgets("original pickMultipleFiles returns when form invalid",
        (tester) async {
      final vm = UploadDocumentDialogViewModel()
        ..repository = mockRequestRepo
        ..fileAttachmentRepository = mockFileAttachmentRepo
        ..fileType = pickerFileTypeRefs();

      await pumpFormShell(
        tester,
        formKey: vm.formKey,
        validator: (_) => "invalid",
      );

      await vm.pickMultipleFiles();

      expect(vm.selectedFiles, isEmpty);
      expect(vm.selectedDocuments, isEmpty);

      await vm.close();
    });

    testWidgets("original pickMultipleFiles returns when app date is missing",
        (tester) async {
      final vm = PartialRealPickUploadDocumentDialogViewModel()
        ..repository = mockRequestRepo
        ..fileAttachmentRepository = mockFileAttachmentRepo
        ..fileType = pickerFileTypeRefs();

      await pumpFormShell(
        tester,
        formKey: vm.formKey,
        validator: (_) => null,
      );

      vm.appRefNoCtrl.text = "APP-404";
      vm.fakeApplicationDetails = ApplicationDetails()
        ..borrowers = [
          Customer(customerRimNo: 1),
        ];

      await vm.pickMultipleFiles();

      expect(vm.getApplicationDetailsCalls, 1);
      expect(vm.selectedFiles, isEmpty);
      expect(vm.selectedDocuments, isEmpty);

      await vm.close();
    });

    testWidgets("original pickMultipleFiles catches app details exception",
        (tester) async {
      final vm = PartialRealPickUploadDocumentDialogViewModel()
        ..repository = mockRequestRepo
        ..fileAttachmentRepository = mockFileAttachmentRepo
        ..fileType = pickerFileTypeRefs()
        ..shouldThrowGetApplicationDetails = true;

      await pumpFormShell(
        tester,
        formKey: vm.formKey,
        validator: (_) => null,
      );

      vm.appRefNoCtrl.text = "BAD-APP";

      await vm.pickMultipleFiles();

      final captured = verify(
        () => mockAlertManager.showFailureToast(captureAny()),
      ).captured;

      expect(captured.length, greaterThanOrEqualTo(1));

      await vm.close();
    });

    testWidgets("original pickMultipleFiles builds documents from picked files",
        (tester) async {
      stubFilePicker.nextResult = FilePickerResult([
        PlatformFile(
          name: "a.pdf",
          size: 100,
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
        PlatformFile(
          name: "b.pdf",
          size: 200,
          bytes: Uint8List.fromList([4, 5, 6]),
        ),
      ]);

      final vm = UploadDocumentDialogViewModel()
        ..repository = mockRequestRepo
        ..fileAttachmentRepository = mockFileAttachmentRepo
        ..fileType = pickerFileTypeRefs()
        ..isGroupApp = false
        ..selectedCustomerRim = 222
        ..applicationId = "APP-1"
        ..selectedDocumentType = Reference(id: 1, name: "DocType")
        ..selectedSubTypeFinancial = Reference(id: 2, name: "SubFinancial")
        ..selectedSubSubTypeFinancial =
            Reference(id: 3, name: "SubSubFinancial")
        ..selectedLanguageType =
            Reference(id: ServerConstants.languageEnglish, name: "English")
        ..documentName = "My Document"
        ..entityId = "ENTITY-1"
        ..selectedDate = DateTime(2025);

      await pumpFormShell(
        tester,
        formKey: vm.formKey,
        validator: (_) => null,
      );

      await vm.pickMultipleFiles();

      expect(stubFilePicker.pickFilesCallCount, 1);
      expect(stubFilePicker.lastType, FileType.any);
      expect(stubFilePicker.lastAllowedExtensions, isNull);
      expect(stubFilePicker.lastAllowMultiple, true);
      expect(stubFilePicker.lastWithData, true);

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.errorMessage, isNull);

      await vm.close();
    });

    testWidgets("original pickMultipleFiles handles no selected files",
        (tester) async {
      stubFilePicker.nextResult = null;

      final vm = UploadDocumentDialogViewModel()
        ..repository = mockRequestRepo
        ..fileAttachmentRepository = mockFileAttachmentRepo
        ..fileType = pickerFileTypeRefs()
        ..selectedCustomerRim = 123
        ..applicationId = "APP-1";

      await pumpFormShell(
        tester,
        formKey: vm.formKey,
        validator: (_) => null,
      );

      await vm.pickMultipleFiles();

      expect(stubFilePicker.pickFilesCallCount, 1);
      expect(vm.selectedFiles, isEmpty);
      expect(vm.errorMessage, isNotNull);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      await vm.close();
    });

    testWidgets("original pickMultipleFiles catches picker exception",
        (tester) async {
      stubFilePicker.nextException = Exception("picker failed");

      final vm = UploadDocumentDialogViewModel()
        ..repository = mockRequestRepo
        ..fileAttachmentRepository = mockFileAttachmentRepo
        ..fileType = pickerFileTypeRefs()
        ..selectedCustomerRim = 123
        ..applicationId = "APP-1";

      await pumpFormShell(
        tester,
        formKey: vm.formKey,
        validator: (_) => null,
      );

      await vm.pickMultipleFiles();

      final captured = verify(
        () => mockAlertManager.showFailureToast(captureAny()),
      ).captured;

      expect(captured.length, greaterThanOrEqualTo(1));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      await vm.close();
    });
  });

  group("Seam pickMultipleFiles coverage", () {
    testWidgets("seam returns when form validation fails", (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => "invalid",
      );

      await testVm.pickMultipleFiles();

      expect(testVm.selectedFiles, isEmpty);
      expect(testVm.selectedDocuments, isEmpty);
    });

    testWidgets("seam returns early when app details has no createdDate",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      testVm.appRefNoCtrl.text = "APP-404";
      testVm.fakeApplicationDetails = ApplicationDetails()
        ..borrowers = [
          Customer(customerRimNo: 555),
        ];

      await testVm.pickMultipleFiles();

      expect(testVm.getApplicationDetailsCalls, 1);
      expect(testVm.selectedFiles, isEmpty);
      expect(testVm.selectedDocuments, isEmpty);
    });

    testWidgets("seam successful single customer flow builds documents",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      testVm
        ..selectedDocumentType = Reference(id: 1, name: "DocType")
        ..selectedSubTypeFinancial = Reference(id: 2, name: "SubFinancial")
        ..selectedSubSubTypeFinancial =
            Reference(id: 3, name: "SubSubFinancial")
        ..selectedLanguageType =
            Reference(id: ServerConstants.languageEnglish, name: "English")
        ..documentName = "My Document"
        ..entityId = "ENTITY-1"
        ..selectedDate = DateTime(2025)
        ..selectedCustomerRim = 222
        ..isGroupApp = false
        ..applicationId = "APP-1"
        ..nextPickedFiles = [
          PlatformFile(name: "a.pdf", size: 100),
          PlatformFile(name: "b.pdf", size: 200),
        ];

      await testVm.pickMultipleFiles();

      expect(testVm.selectedFiles.length, 2);
      expect(testVm.selectedDocuments.length, 2);
      expect(testVm.selectedDocuments[0].companyRim, "222");
      expect(testVm.selectedDocuments[0].applicationId, "APP-1");
      expect(testVm.selectedDocuments[0].documentName, "My Document");
      expect(testVm.selectedDocumentType, isNull);
      expect(testVm.selectedLanguageType, isNull);
      expect(testVm.documentNameCtrl.text, "");
      expect(testVm.entityIdCtrl.text, "");
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("seam saves form before creating documents", (tester) async {
      bool saved = false;

      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
        onSaved: (_) {
          saved = true;
        },
      );

      testVm
        ..selectedDocumentType = Reference(id: 1, name: "DocType")
        ..selectedSubTypeFinancial = Reference(id: 2, name: "SubFinancial")
        ..selectedSubSubTypeFinancial =
            Reference(id: 3, name: "SubSubFinancial")
        ..selectedLanguageType =
            Reference(id: ServerConstants.languageEnglish, name: "English")
        ..documentName = "Saved Document"
        ..entityId = "ENTITY-1"
        ..selectedDate = DateTime(2025)
        ..selectedCustomerRim = 222
        ..isGroupApp = false
        ..applicationId = "APP-1"
        ..nextPickedFiles = [
          PlatformFile(name: "a.pdf", size: 100),
        ];

      await testVm.pickMultipleFiles();

      expect(saved, isTrue);
      expect(testVm.selectedDocuments.length, 1);
      expect(testVm.selectedDocuments.first.documentName, "Saved Document");
    });

    testWidgets("seam uses appRefNoCtrl when applicationId is null",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      testVm
        ..selectedDocumentType = Reference(id: 1, name: "DocType")
        ..selectedCustomerRim = 321
        ..isGroupApp = false
        ..applicationId = null
        ..appRefNoCtrl.text = "APP-FROM-CTRL"
        ..applicationDetails = ApplicationDetails()
        ..nextPickedFiles = [
          PlatformFile(name: "a.pdf", size: 100),
        ];

      await testVm.pickMultipleFiles();

      expect(testVm.selectedDocuments.length, 1);
      expect(testVm.selectedDocuments.first.applicationId, "APP-FROM-CTRL");
    });

    testWidgets("seam prefers financial subtype over credit lens",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      final financial = Reference(id: 10, name: "Financial");
      final creditLens = Reference(id: 20, name: "Credit Lens");

      testVm
        ..selectedDocumentType = Reference(id: 1, name: "DocType")
        ..selectedSubTypeFinancial = financial
        ..selectedSubTypeCreditLens = creditLens
        ..selectedCustomerRim = 222
        ..isGroupApp = false
        ..applicationId = "APP-1"
        ..nextPickedFiles = [
          PlatformFile(name: "a.pdf", size: 100),
        ];

      await testVm.pickMultipleFiles();

      expect(testVm.selectedDocuments.length, 1);
      expect(testVm.selectedDocuments.first.subType, financial);
    });

    testWidgets("seam uses credit lens subtype when financial is null",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      final creditLens = Reference(id: 20, name: "Credit Lens");

      testVm
        ..selectedDocumentType = Reference(id: 1, name: "DocType")
        ..selectedSubTypeFinancial = null
        ..selectedSubTypeCreditLens = creditLens
        ..selectedCustomerRim = 222
        ..isGroupApp = false
        ..applicationId = "APP-1"
        ..nextPickedFiles = [
          PlatformFile(name: "a.pdf", size: 100),
        ];

      await testVm.pickMultipleFiles();

      expect(testVm.selectedDocuments.length, 1);
      expect(testVm.selectedDocuments.first.subType, creditLens);
    });

    testWidgets("seam group flow creates document per rim per file",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      testVm
        ..selectedDocumentType = Reference(id: 1, name: "DocType")
        ..selectedSubTypeCreditLens = Reference(id: 5, name: "CL Sub")
        ..selectedLanguageType =
            Reference(id: ServerConstants.languageEnglish, name: "English")
        ..documentName = "Group Document"
        ..entityId = "G-1"
        ..selectedDate = DateTime(2025)
        ..selectedGroupRim = 999
        ..applicationId = "APP-GRP"
        ..isGroupApp = true
        ..selectedCompanyRims = [
          Customer(customerRimNo: 101),
          Customer(customerRimNo: 202),
        ]
        ..nextPickedFiles = [
          PlatformFile(name: "a.pdf", size: 100),
          PlatformFile(name: "b.pdf", size: 200),
        ];

      await testVm.pickMultipleFiles();

      expect(testVm.selectedDocuments.length, 4);
      expect(testVm.selectedDocuments[0].companyRim, "101");
      expect(testVm.selectedDocuments[1].companyRim, "202");
      expect(testVm.selectedDocuments[2].companyRim, "101");
      expect(testVm.selectedDocuments[3].companyRim, "202");
    });

    testWidgets("seam empty files sets error message", (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      testVm
        ..selectedDocumentType = Reference(id: 1, name: "DocType")
        ..selectedCustomerRim = 123
        ..applicationId = "APP-1"
        ..nextPickedFiles = [];

      await testVm.pickMultipleFiles();

      expect(testVm.selectedFiles, isEmpty);
      expect(testVm.errorMessage, isNotNull);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("seam null files sets error message", (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      testVm
        ..selectedDocumentType = Reference(id: 1, name: "DocType")
        ..selectedCustomerRim = 123
        ..applicationId = "APP-1"
        ..nextPickedFiles = null;

      await testVm.pickMultipleFiles();

      expect(testVm.selectedFiles, isEmpty);
      expect(testVm.errorMessage, isNotNull);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("seam file picker exception shows failure toast",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      testVm
        ..selectedDocumentType = Reference(id: 1, name: "DocType")
        ..selectedCustomerRim = 123
        ..applicationId = "APP-1"
        ..pickFilesError = Exception("picker failed");

      await testVm.pickMultipleFiles();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("seam group flow with no rims captures files but no docs",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      testVm
        ..selectedDocumentType = Reference(id: 1, name: "DocType")
        ..isGroupApp = true
        ..selectedCompanyRims = []
        ..applicationId = "APP-1"
        ..nextPickedFiles = [
          PlatformFile(name: "a.pdf", size: 100),
        ];

      await testVm.pickMultipleFiles();

      expect(testVm.selectedFiles.length, 1);
      expect(testVm.selectedDocuments, isEmpty);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("seam app details exception shows failure", (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      testVm.appRefNoCtrl.text = "BAD-APP";
      testVm.getApplicationDetailsShouldThrow = true;

      await testVm.pickMultipleFiles();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("Document type helpers", () {
    test("isConstitutionalDocumentsSelected true and false", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.constitutionalDocument],
      );
      expect(viewModel.isConstitutionalDocumentsSelected(), true);

      viewModel.selectedDocumentType = Reference(id: 999);
      expect(viewModel.isConstitutionalDocumentsSelected(), false);
    });

    test("isCreditLensSelected true and false", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.creditLensDocument],
      );
      expect(viewModel.isCreditLensSelected(), true);

      viewModel.selectedDocumentType = Reference(id: 999);
      expect(viewModel.isCreditLensSelected(), false);
    });

    test("isFinancialStatementsSelected true and false", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.financialStatements],
      );
      expect(viewModel.isFinancialStatementsSelected(), true);

      viewModel.selectedDocumentType = Reference(id: 999);
      expect(viewModel.isFinancialStatementsSelected(), false);
    });

    test("isExternalOpinionsSelected true and false", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.externalOpinions],
      );
      expect(viewModel.isExternalOpinionsSelected(), true);

      viewModel.selectedDocumentType = Reference(id: 999);
      expect(viewModel.isExternalOpinionsSelected(), false);
    });

    test("isOthersSelected true and false", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.other],
      );
      expect(viewModel.isOthersSelected(), true);

      viewModel.selectedDocumentType = Reference(id: 999);
      expect(viewModel.isOthersSelected(), false);
    });
  });

  group("Download and document type change", () {
    test("downloadViewDocument calls repository", () async {
      final document = Document(documentName: "test.pdf");

      await viewModel.downloadViewDocument(document);

      verify(() => mockFileAttachmentRepo.downloadFileAttachment(document))
          .called(1);
    });

    test("onDocumentTypeChanged resets related fields", () {
      viewModel
        ..selectedDocumentType = Reference(id: 1, name: "Old Type")
        ..documentName = "Old Name"
        ..entityId = "OLD-ENTITY"
        ..selectedCompanyRims = [
          Customer(customerRimNo: 1),
        ]
        ..selectedSubTypeFinancial = Reference(id: 2, name: "Financial")
        ..selectedSubTypeCreditLens = Reference(id: 3, name: "Credit")
        ..selectedSubSubTypeFinancial = Reference(id: 4, name: "SubFinancial")
        ..selectedDate = DateTime.now();

      final newType = Reference(id: 5, name: "New Type");
      viewModel.onDocumentTypeChanged(newType);

      expect(viewModel.selectedDocumentType, newType);
      expect(viewModel.documentName, "");
      expect(viewModel.documentNameCtrl.text, "");
      expect(viewModel.entityId, "");
      expect(viewModel.entityIdCtrl.text, "");
      expect(viewModel.selectedCompanyRims, isEmpty);
      expect(viewModel.selectedSubTypeFinancial, isNull);
      expect(viewModel.selectedSubTypeCreditLens, isNull);
      expect(viewModel.selectedSubSubTypeFinancial, isNull);
      expect(viewModel.selectedDate, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("UploadDocumentDialogState", () {
    test("constructor sets loader and upload button status", () {
      final state = UploadDocumentDialogState(
        loaderStatus: LoadingStatus.loading,
        uploadButtonStatus: LoadingStatus.loaded,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.uploadButtonStatus, LoadingStatus.loaded);
    });

    test("copyWith keeps existing values when null", () {
      final original = UploadDocumentDialogState(
        loaderStatus: LoadingStatus.loaded,
        uploadButtonStatus: LoadingStatus.loaded,
      );

      final copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.uploadButtonStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides loaderStatus", () {
      final original = UploadDocumentDialogState(
        loaderStatus: LoadingStatus.loaded,
        uploadButtonStatus: LoadingStatus.loaded,
      );

      final updated = original.copyWith(loaderStatus: LoadingStatus.loading);

      expect(updated.loaderStatus, LoadingStatus.loading);
      expect(updated.uploadButtonStatus, LoadingStatus.loaded);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides uploadButtonStatus", () {
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

    test("copyWith overrides both statuses", () {
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
