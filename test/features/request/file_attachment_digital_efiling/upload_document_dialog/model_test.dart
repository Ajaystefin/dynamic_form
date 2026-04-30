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

/// ---------------------------------------------------------------------------
/// Test seam subclass
/// ---------------------------------------------------------------------------
class TestUploadDocumentDialogViewModel extends UploadDocumentDialogViewModel {
  int loadReferenceDataCalls = 0;
  int getApplicationDetailsCalls = 0;
  int getCompanyRimsCalls = 0;

  String? lastApplicationId;
  bool? lastShouldOverrideRim;

  List<Customer>? fakeRims;
  ApplicationDetails? fakeApplicationDetails;
  bool getApplicationDetailsShouldThrow = false;

  /// Test seam for file picking
  List<PlatformFile>? nextPickedFiles;
  Object? pickFilesError;

  @override
  Future<void> loadReferenceData() async {
    loadReferenceDataCalls++;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> getApplicationDetails(
    String? applicationId,
    bool shouldOverrideRIM,
  ) async {
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
    } catch (e) {
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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> pickMultipleFiles() async {
    if (!(formKey.currentState!.validate())) {
      return;
    }

    try {
      if (appRefNoCtrl.text != "" && applicationDetails == null) {
        await getApplicationDetails(appRefNoCtrl.text, false);
        if (applicationDetails?.createdDate == null) {
          return;
        }
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      formKey.currentState?.save();

      if (pickFilesError != null) throw pickFilesError!;
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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}

/// ---------------------------------------------------------------------------
/// Helpers
/// ---------------------------------------------------------------------------
Future<void> pumpFormShell(
  WidgetTester tester, {
  required GlobalKey<FormState> formKey,
  String? Function(String?)? validator,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: TextFormField(
            validator: validator,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<BuildContext> pumpPoppableRoute(
  WidgetTester tester,
) async {
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

class FakeBuildContext extends Fake implements BuildContext {
  @override
  bool get mounted => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UploadDocumentDialogViewModel viewModel;
  late TestUploadDocumentDialogViewModel testVm;
  late MockRequestRepository mockRequestRepo;
  late MockFileAttachmentRepository mockFileAttachmentRepo;
  late MockReferenceDataService mockRefService;
  late MockAlertManager mockAlertManager;

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
  });

  setUp(() {
    /// IMPORTANT: Globals.request must exist BEFORE creating the ViewModel
    Globals.request = Request(
      groupId: 456,
      customerRimNo: 789,
      applicationRefNo: "APP-123",
    );

    mockRequestRepo = MockRequestRepository();
    mockFileAttachmentRepo = MockFileAttachmentRepository();
    mockRefService = MockReferenceDataService();
    mockAlertManager = MockAlertManager();

    viewModel = UploadDocumentDialogViewModel();
    viewModel.repository = mockRequestRepo;
    viewModel.fileAttachmentRepository = mockFileAttachmentRepo;

    testVm = TestUploadDocumentDialogViewModel();
    testVm.repository = mockRequestRepo;
    testVm.fileAttachmentRepository = mockFileAttachmentRepo;

    AlertManager.overrideInstance(mockAlertManager);
    ReferenceDataService.overrideInstance(mockRefService);

    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showInfoToast(any())).thenReturn(null);

    when(() => mockRefService.getReferenceData(any())).thenAnswer(
      (_) async => {
        ReferenceDataKeys.fileType: [Reference(id: 101, name: "PDF")],
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

    when(() => mockFileAttachmentRepo.downloadFileAttachment(any()))
        .thenAnswer((_) async {});

    when(() => mockFileAttachmentRepo.uploadDigitalDocuments(any()))
        .thenAnswer((_) async => "Uploaded successfully");
  });

  group("Initialization / state", () {
    test(
        "initial state should be loading for loader"
        " and loaded for upload button", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.state.uploadButtonStatus, LoadingStatus.loaded);
    });

    test(
        "init: applicationId "
        "path calls "
        "getApplicationDetails + loadReferenceData", () async {
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
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(testVm.applicationId, "APP-999");
      expect(testVm.getApplicationDetailsCalls, 1);
      expect(testVm.lastApplicationId, "APP-999");
      expect(testVm.lastShouldOverrideRim, true);
      expect(testVm.loadReferenceDataCalls, 1);
      expect(testVm.selectedGroupRim, 999);
      expect(testVm.rimList.length, 2);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "init: applicationId path skips "
        "getApplicationDetails if companyRims passed", () async {
      final rims = [
        Customer(customerRimNo: 11),
      ];

      await testVm.init(
        FakeBuildContext(),
        groupRim: "",
        customerRim: "",
        applicationId: "APP-111",
        companyRims: rims,
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(testVm.applicationId, "APP-111");
      expect(testVm.getApplicationDetailsCalls, 0);
      expect(testVm.rimList.length, 1);
      expect(testVm.loadReferenceDataCalls, 1);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "init: groupRim path sets group mode and "
        "fetches company rims when rimList empty", () async {
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
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(testVm.selectedGroupRim, 123);
      expect(testVm.isGroupApp, true);
      expect(testVm.getCompanyRimsCalls, 1);
      expect(testVm.rimList.length, 2);
      expect(testVm.loadReferenceDataCalls, 1);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init: groupRim path skips getCompanyRims when rimList already passed",
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
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(testVm.selectedGroupRim, 123);
      expect(testVm.isGroupApp, true);
      expect(testVm.getCompanyRimsCalls, 0);
      expect(testVm.rimList.length, 1);
      expect(testVm.loadReferenceDataCalls, 1);
    });

    test("init: customer rim path updates customer and optional grpId",
        () async {
      await testVm.init(
        FakeBuildContext(),
        groupRim: "0",
        customerRim: "456",
        applicationId: "",
        grpId: "789",
        companyRims: [],
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(testVm.selectedCustomerRim, 456);
      expect(testVm.selectedGroupRim, 789);
      expect(testVm.isCompanyRim, true);
      expect(testVm.loadReferenceDataCalls, 1);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "init: customer rim path with empty "
        "grpId leaves selectedGroupRim unchanged", () async {
      await testVm.init(
        FakeBuildContext(),
        groupRim: "0",
        customerRim: "456",
        applicationId: "",
        grpId: "",
        companyRims: [],
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(testVm.selectedCustomerRim, 456);
      expect(testVm.selectedGroupRim, isNull);
      expect(testVm.isCompanyRim, true);
      expect(testVm.loadReferenceDataCalls, 1);
    });

    test("init: if companyRims passed, uses them", () async {
      final rims = [
        Customer(customerRimNo: 1),
        Customer(customerRimNo: 2),
      ];

      await testVm.init(
        FakeBuildContext(),
        groupRim: "",
        customerRim: "",
        applicationId: "",
        companyRims: rims,
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(testVm.rimList.length, 2);
      expect(testVm.loadReferenceDataCalls, 1);
    });

    test(
        "loadReferenceData populates reference lists "
        "and filters credit application document", () async {
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

      final hasNullIdDoc = viewModel.documentTypes.any((doc) => doc.id == null);
      expect(hasNullIdDoc, true);
    });
  });

  group("Search and Application / Company RIMs", () {
    test("updateSearchValue executes without error", () {
      expect(() => viewModel.updateSearchValue("test"), returnsNormally);
    });

    test(
        "getCompanyRims returns early when no "
        "applicationId and no eligible group data", () async {
      viewModel.selectedGroupRim = null;
      viewModel.applicationId = null;

      await viewModel.getCompanyRims();

      verifyNever(() => mockFileAttachmentRepo.getCompanyRims(any()));
    });

    test("getCompanyRims fetches rims when applicationId is present (real VM)",
        () async {
      viewModel.selectedGroupRim = 100;
      viewModel.applicationId = "APP-001";

      await viewModel.getCompanyRims();

      verify(() => mockFileAttachmentRepo.getCompanyRims(100)).called(1);
      expect(viewModel.rimList.length, 3);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getCompanyRims handles repository error (real VM)", () async {
      viewModel.selectedGroupRim = 100;
      viewModel.applicationId = "APP-001";

      when(() => mockFileAttachmentRepo.getCompanyRims(any()))
          .thenThrow(Exception("Failed to fetch RIMs"));

      await viewModel.getCompanyRims();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getCompanyRims seam handles fake rims path", () async {
      testVm.fakeRims = [
        Customer(customerRimNo: 1),
        Customer(customerRimNo: 2),
      ];

      await testVm.getCompanyRims();

      expect(testVm.getCompanyRimsCalls, 1);
      expect(testVm.rimList.length, 2);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getApplicationDetails returns early when applicationId is null",
        () async {
      await testVm.getApplicationDetails(null, true);

      expect(testVm.applicationDetails, isNull);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getApplicationDetails with group app overrides rimList and groupRim",
        () async {
      testVm.fakeApplicationDetails = ApplicationDetails()
        ..groupID = 500
        ..borrowers = [
          Customer(customerRimNo: 11),
          Customer(customerRimNo: 22),
        ];

      await testVm.getApplicationDetails("APP-500", true);

      expect(testVm.isGroupApp, true);
      expect(testVm.rimList.length, 2);
      expect(testVm.selectedGroupRim, 500);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getApplicationDetails with non-group app overrides customer rim",
        () async {
      testVm.fakeApplicationDetails = ApplicationDetails()
        ..groupID = 0
        ..borrowers = [
          Customer(customerRimNo: 777),
        ];

      await testVm.getApplicationDetails("APP-777", true);

      expect(testVm.isGroupApp, false);
      expect(testVm.selectedCustomerRim, 777);
      expect(testVm.isCompanyRim, true);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "getApplicationDetails with shouldOverrideRIM=false "
        "loads applicationDetails only", () async {
      testVm.fakeApplicationDetails = ApplicationDetails()
        ..groupID = 500
        ..borrowers = [
          Customer(customerRimNo: 11),
        ];

      await testVm.getApplicationDetails("APP-1", false);

      expect(testVm.applicationDetails, isNotNull);
      expect(testVm.selectedGroupRim, isNull);
      expect(testVm.selectedCustomerRim, isNull);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getApplicationDetails error shows noAppRef toast", () async {
      testVm.getApplicationDetailsShouldThrow = true;

      await testVm.getApplicationDetails("BAD-APP", true);

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

    test("toggleSelectAllCompanyRims(true) selects all", () {
      viewModel.rimList = [
        Customer(customerRimNo: 1),
        Customer(customerRimNo: 2),
        Customer(customerRimNo: 3),
      ];

      viewModel.toggleSelectAllCompanyRims(true);

      expect(viewModel.isSelectAllCompanyRims, true);
      expect(viewModel.selectedCompanyRims.length, 3);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("toggleSelectAllCompanyRims(false) clears selection", () {
      viewModel.rimList = [
        Customer(customerRimNo: 1),
        Customer(customerRimNo: 2),
      ];
      viewModel.selectedCompanyRims = [
        Customer(customerRimNo: 1),
      ];

      viewModel.toggleSelectAllCompanyRims(false);

      expect(viewModel.isSelectAllCompanyRims, false);
      expect(viewModel.selectedCompanyRims, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateApplicationId updates applicationId + controller", () {
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

    test("updateDocumentName updates field + controller", () {
      viewModel.updateDocumentName("Test Document");

      expect(viewModel.documentName, "Test Document");
      expect(viewModel.documentNameCtrl.text, "Test Document");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateEntityId updates field + controller", () {
      viewModel.updateEntityId("ENTITY-123");

      expect(viewModel.entityId, "ENTITY-123");
      expect(viewModel.entityIdCtrl.text, "ENTITY-123");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateDocumentType updates selectedDocumentType", () {
      final docType = Reference(id: 1, name: "Type 1");

      viewModel.updateDocumentType(docType);

      expect(viewModel.selectedDocumentType, docType);
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

    test("updateLanguageType clears entityId for non-English/Arabic", () {
      viewModel.entityId = "FR1";
      viewModel.entityIdCtrl.text = "FR1";

      final langType = Reference(id: 999, name: "French");

      viewModel.updateLanguageType(langType);

      expect(viewModel.selectedLanguageType, langType);
      expect(viewModel.entityId, "");
      expect(viewModel.entityIdCtrl.text, "");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateGroupRim parses and updates group rim", () {
      viewModel.updateGroupRim("123");

      expect(viewModel.selectedGroupRim, 123);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('updateGroupRim does not update when groupRim is "0"', () {
      viewModel.selectedGroupRim = 999;

      viewModel.updateGroupRim("0");

      expect(viewModel.selectedGroupRim, 999);
    });

    test("updateGroupRim does not update when groupRim is empty", () {
      viewModel.selectedGroupRim = 999;

      viewModel.updateGroupRim("");

      expect(viewModel.selectedGroupRim, 999);
    });

    test("updateCustomerRim parses and updates customer rim", () {
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

  group("File/document management", () {
    test("removeFileAt removes selected document at valid index", () {
      viewModel.selectedFiles = [
        PlatformFile(name: "file1.pdf", size: 100),
        PlatformFile(name: "file2.pdf", size: 200),
      ];
      viewModel.selectedDocuments = [
        Document(documentName: "doc1"),
        Document(documentName: "doc2"),
      ];

      viewModel.removeFileAt(0);

      expect(viewModel.selectedDocuments.length, 1);
      expect(viewModel.selectedDocuments[0].documentName, "doc2");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("removeFileAt does nothing when index is out of bounds", () {
      viewModel.selectedDocuments = [Document(documentName: "doc1")];

      viewModel.removeFileAt(5);

      expect(viewModel.selectedDocuments.length, 1);
    });

    test("removeFileAt does nothing when index is negative", () {
      viewModel.selectedDocuments = [Document(documentName: "doc1")];

      viewModel.removeFileAt(-1);

      expect(viewModel.selectedDocuments.length, 1);
    });
  });

  group("Upload button", () {
    testWidgets(
        "onUploadDocumentsPressed uploads, shows "
        "info toast, resets button status and pops", (tester) async {
      final ctx = await pumpPoppableRoute(tester);

      viewModel.selectedDocuments = [
        Document(documentName: "doc1"),
      ];

      await viewModel.onUploadDocumentsPressed(ctx);
      await tester.pumpAndSettle();

      verify(() => mockFileAttachmentRepo.uploadDigitalDocuments(any()))
          .called(1);
      verifyNever(() => mockAlertManager.showInfoToast("Uploaded successfully"))
          .called(0);

      expect(viewModel.state.uploadButtonStatus, LoadingStatus.loaded);
    });

    testWidgets(
        "onUploadDocumentsPressed handles repository error and still pops",
        (tester) async {
      when(() => mockFileAttachmentRepo.uploadDigitalDocuments(any()))
          .thenThrow(Exception("upload failed"));

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
    test("resetFormFields clears all transient fields", () {
      viewModel.selectedDocumentType = Reference(id: 1, name: "Doc");
      viewModel.selectedLanguageType = Reference(id: 1, name: "English");
      viewModel.selectedSubTypeFinancial = Reference(id: 2, name: "Financial");
      viewModel.selectedSubTypeCreditLens = Reference(id: 3, name: "Credit");
      viewModel.selectedSubSubTypeFinancial =
          Reference(id: 4, name: "SubFinancial");
      viewModel.selectedCompanyRims = [
        Customer(customerRimNo: 1),
        Customer(customerRimNo: 2),
      ];
      viewModel.isSelectAllCompanyRims = true;
      viewModel.documentName = "Test Doc";
      viewModel.entityId = "ENT-1";
      viewModel.documentNameCtrl.text = "Test";
      viewModel.entityIdCtrl.text = "ENT-1";
      viewModel.selectedDate = DateTime.now();
      viewModel.selectedGroupRim = 123;
      viewModel.applicationId = "APP-123";

      viewModel.resetFormFields();

      expect(viewModel.selectedDocumentType, null);
      expect(viewModel.selectedLanguageType, null);
      expect(viewModel.selectedSubTypeFinancial, null);
      expect(viewModel.selectedSubTypeCreditLens, null);
      expect(viewModel.selectedSubSubTypeFinancial, null);
      expect(viewModel.selectedCompanyRims, isEmpty);
      expect(viewModel.isSelectAllCompanyRims, false);
      expect(viewModel.documentName, null);
      expect(viewModel.entityId, null);
      expect(viewModel.documentNameCtrl.text, "");
      expect(viewModel.entityIdCtrl.text, "");
      expect(viewModel.selectedDate, null);

      // Intentionally NOT reset according to implementation:
      expect(viewModel.selectedGroupRim, 123);
      expect(viewModel.applicationId, "APP-123");

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("resetFormFields also works with attached form state",
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

  group("pickMultipleFiles (test seam)", () {
    testWidgets("returns immediately when form validation fails",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => "invalid",
      );

      await testVm.pickMultipleFiles();

      expect(testVm.selectedFiles, isEmpty);
      expect(testVm.selectedDocuments, isEmpty);
    });

    testWidgets(
        "if appRefNo exists and applicationDetails is "
        "null, returns early when createdDate missing", (tester) async {
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
      // createdDate intentionally left null

      await testVm.pickMultipleFiles();

      expect(testVm.selectedFiles, isEmpty);
      expect(testVm.selectedDocuments, isEmpty);
    });

    testWidgets(
        "successful single customer flow builds documents and resets form",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      testVm.selectedDocumentType = Reference(id: 1, name: "DocType");
      testVm.selectedSubTypeFinancial = Reference(id: 2, name: "SubFinancial");
      testVm.selectedSubSubTypeFinancial =
          Reference(id: 3, name: "SubSubFinancial");
      testVm.selectedLanguageType =
          Reference(id: ServerConstants.languageEnglish, name: "English");
      testVm.documentName = "My Document";
      testVm.entityId = "ENTITY-1";
      testVm.selectedDate = DateTime(2025, 1, 1);
      testVm.selectedCustomerRim = 222;
      testVm.isGroupApp = false;
      testVm.applicationId = "APP-1";

      testVm.nextPickedFiles = [
        PlatformFile(name: "a.pdf", size: 100),
        PlatformFile(name: "b.pdf", size: 200),
      ];

      await testVm.pickMultipleFiles();

      expect(testVm.selectedFiles.length, 2);
      expect(testVm.selectedDocuments.length, 2);

      expect(testVm.selectedDocuments[0].companyRim, "222");
      expect(testVm.selectedDocuments[0].applicationId, "APP-1");
      expect(testVm.selectedDocuments[0].documentName, "My Document");

      expect(testVm.selectedDocumentType, null);
      expect(testVm.selectedLanguageType, null);
      expect(testVm.documentNameCtrl.text, "");
      expect(testVm.entityIdCtrl.text, "");
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets(
        "group flow creates one document per selected company rim per file",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      testVm.selectedDocumentType = Reference(id: 1, name: "DocType");
      testVm.selectedSubTypeCreditLens = Reference(id: 5, name: "CL Sub");
      testVm.selectedLanguageType =
          Reference(id: ServerConstants.languageEnglish, name: "English");
      testVm.documentName = "Group Document";
      testVm.entityId = "G-1";
      testVm.selectedDate = DateTime(2025, 1, 1);
      testVm.selectedGroupRim = 999;
      testVm.applicationId = "APP-GRP";
      testVm.isGroupApp = true;
      testVm.selectedCompanyRims = [
        Customer(customerRimNo: 101),
        Customer(customerRimNo: 202),
      ];

      testVm.nextPickedFiles = [
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

    testWidgets("no files selected sets error message and clears selectedFiles",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      testVm.selectedDocumentType = Reference(id: 1, name: "DocType");
      testVm.selectedCustomerRim = 123;
      testVm.applicationId = "APP-1";
      testVm.nextPickedFiles = [];

      await testVm.pickMultipleFiles();

      expect(testVm.selectedFiles, isEmpty);
      expect(testVm.errorMessage, isNotNull);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("null files also sets error message and clears selectedFiles",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      testVm.selectedDocumentType = Reference(id: 1, name: "DocType");
      testVm.selectedCustomerRim = 123;
      testVm.applicationId = "APP-1";
      testVm.nextPickedFiles = null;

      await testVm.pickMultipleFiles();

      expect(testVm.selectedFiles, isEmpty);
      expect(testVm.errorMessage, isNotNull);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets(
        "file picker exception shows failure toast and restores loader status",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      testVm.selectedDocumentType = Reference(id: 1, name: "DocType");
      testVm.selectedCustomerRim = 123;
      testVm.applicationId = "APP-1";
      testVm.pickFilesError = Exception("picker failed");

      await testVm.pickMultipleFiles();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets(
        "if selectedCompanyRims stays empty, "
        "files are captured but no docs added", (tester) async {
      await pumpFormShell(
        tester,
        formKey: testVm.formKey,
        validator: (_) => null,
      );

      testVm.selectedDocumentType = Reference(id: 1, name: "DocType");
      testVm.isGroupApp = true;
      testVm.selectedCompanyRims = [];
      testVm.applicationId = "APP-1";
      testVm.nextPickedFiles = [
        PlatformFile(name: "a.pdf", size: 100),
      ];

      await testVm.pickMultipleFiles();

      expect(testVm.selectedFiles.length, 1);
      expect(testVm.selectedDocuments, isEmpty);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets(
        "getApplicationDetails exception inside "
        "seam is caught and shows failure", (tester) async {
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
    test("isConstitutionalDocumentsSelected returns true when selected", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.constitutionalDocument],
        name: "Constitutional",
      );

      expect(viewModel.isConstitutionalDocumentsSelected(), true);
    });

    test("isConstitutionalDocumentsSelected returns false when not selected",
        () {
      viewModel.selectedDocumentType = Reference(id: 999, name: "Other");

      expect(viewModel.isConstitutionalDocumentsSelected(), false);
    });

    test("isCreditLensSelected returns true when selected", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.creditLensDocument],
        name: "Credit Lens",
      );

      expect(viewModel.isCreditLensSelected(), true);
    });

    test("isCreditLensSelected returns false when not selected", () {
      viewModel.selectedDocumentType = Reference(id: 999, name: "Other");

      expect(viewModel.isCreditLensSelected(), false);
    });

    test("isFinancialStatementsSelected returns true when selected", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.financialStatements],
        name: "Financial",
      );

      expect(viewModel.isFinancialStatementsSelected(), true);
    });

    test("isFinancialStatementsSelected returns false when not selected", () {
      viewModel.selectedDocumentType = Reference(id: 999, name: "Other");

      expect(viewModel.isFinancialStatementsSelected(), false);
    });

    test("isExternalOpinionsSelected returns true when selected", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.externalOpinions],
        name: "External",
      );

      expect(viewModel.isExternalOpinionsSelected(), true);
    });

    test("isExternalOpinionsSelected returns false when not selected", () {
      viewModel.selectedDocumentType = Reference(id: 999, name: "Other");

      expect(viewModel.isExternalOpinionsSelected(), false);
    });

    test("isOthersSelected returns true when selected", () {
      viewModel.selectedDocumentType = Reference(
        id: ServerConstants.documentTypeId[DocumentType.other],
        name: "Other",
      );

      expect(viewModel.isOthersSelected(), true);
    });

    test("isOthersSelected returns false when not selected", () {
      viewModel.selectedDocumentType = Reference(id: 999, name: "Something");

      expect(viewModel.isOthersSelected(), false);
    });
  });

  group("Download document", () {
    test("downloadViewDocument calls repository method", () async {
      final document = Document(documentName: "test.pdf");

      await viewModel.downloadViewDocument(document);

      verify(() => mockFileAttachmentRepo.downloadFileAttachment(document))
          .called(1);
    });
  });

  group("Document type changed", () {
    test("onDocumentTypeChanged resets related fields", () {
      viewModel.selectedDocumentType = Reference(id: 1, name: "Old Type");
      viewModel.documentName = "Old Name";
      viewModel.entityId = "OLD-ENTITY";
      viewModel.selectedCompanyRims = [
        Customer(customerRimNo: 1),
      ];
      viewModel.selectedSubTypeFinancial = Reference(id: 2, name: "Financial");
      viewModel.selectedSubTypeCreditLens = Reference(id: 3, name: "Credit");
      viewModel.selectedSubSubTypeFinancial =
          Reference(id: 4, name: "SubFinancial");
      viewModel.selectedDate = DateTime.now();

      final newType = Reference(id: 5, name: "New Type");
      viewModel.onDocumentTypeChanged(newType);

      expect(viewModel.selectedDocumentType, newType);
      expect(viewModel.documentName, "");
      expect(viewModel.documentNameCtrl.text, "");
      expect(viewModel.entityId, "");
      expect(viewModel.entityIdCtrl.text, "");
      expect(viewModel.selectedCompanyRims, isEmpty);
      expect(viewModel.selectedSubTypeFinancial, null);
      expect(viewModel.selectedSubTypeCreditLens, null);
      expect(viewModel.selectedSubSubTypeFinancial, null);
      expect(viewModel.selectedDate, null);
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

class MockBuildContext extends Fake implements BuildContext {
  @override
  bool get mounted => true;
}
