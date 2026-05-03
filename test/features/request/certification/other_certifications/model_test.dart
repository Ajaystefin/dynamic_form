import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/certifications/other_certifications/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/models/request/certification_data.dart";
import "package:wcas_frontend/models/request/esg_certification.dart";
import "package:wcas_frontend/repositories/certification_repository.dart";

class _FakeAlertManager implements AlertManager {
  int failureCalls = 0;
  int successCalls = 0;
  int warningCalls = 0;
  int infoCalls = 0;

  String? lastFailure;
  String? lastSuccess;

  @override
  void showFailureToast(String message) {
    failureCalls++;
    lastFailure = message;
  }

  @override
  void showSuccessToast(String message) {
    successCalls++;
    lastSuccess = message;
  }

  @override
  void showWarningToast(String message) {
    warningCalls++;
  }

  @override
  void showInfoToast(String message) {
    infoCalls++;
  }
}

class _FakeReferenceDataService implements ReferenceDataService {
  Map<String, List<Reference>> nextData = {};
  bool throwError = false;

  @override
  Map<String, List<Reference>> referenceData = {};

  @override
  Map<String, int> referenceTypeIds = {};

  @override
  Future<void> clearCache(String key) async {
    referenceData.remove(key);
    referenceTypeIds.remove(key);
  }

  @override
  Future<Map<String, List<Reference>>> getReferenceData(
    List<String> keys,
  ) async {
    if (throwError) {
      throw Exception("ref error");
    }
    return nextData;
  }

  @override
  void setDependencies({
    localStorageService,
    homeRepository,
    bool skipStorageForTesting = false,
  }) {}

  @override
  Future<void> getFromAPI(List<String> missingKeys) async {}

  @override
  void getFromRefrenceList(
    List<ReferenceType> referenceDataTypeList,
    String key,
  ) {}

  @override
  Future<List<String>> getFromLocalStorage(List<String> keys) async {
    return [];
  }
}

class _FakeCertificationRepository implements CertificationRepository {
  List<CertificationData> nextList = [];
  bool throwGetError = false;
  bool throwPostError = false;
  int postCalls = 0;
  List<CertificationData> postedPayload = [];

  @override
  Future<List<CertificationData>> getOtherCertificationDetails(
    List<Reference> certificateTypes,
    List<Reference> yesNoNaOptions,
  ) async {
    if (throwGetError) {
      throw Exception("get error");
    }
    return nextList;
  }

  @override
  Future<void> postOtherCertificationDetails(
    List<CertificationData> certifications,
  ) async {
    postCalls++;
    postedPayload = certifications;
    if (throwPostError) {
      throw Exception("post error");
    }
  }

  @override
  Future<EsgCertification> getEsgCertificationDetails() async {
    throw UnimplementedError();
  }

  @override
  Future<EsgCertification> postEsgCertificationDetails(
    EsgCertification certification,
  ) async {
    throw UnimplementedError();
  }
}

class _TestableOtherCertificationsViewModel
    extends OtherCertificationsViewModel {
  bool fetchReferenceDataCalled = false;
  bool fetchCertificationDetailsCalled = false;
  bool initializeMissingCertificatesCalled = false;
  bool registerDraftCallbackCalled = false;
  bool loadDraftIfAvailableCalled = false;
  bool unregisterDraftCallbackCalled = false;
  bool throwFromFetchReferenceData = false;
  bool forceCanEdit = false;
  bool deleteDraftCalled = false;

  @override
  Future<void> fetchReferenceData() async {
    fetchReferenceDataCalled = true;
    if (throwFromFetchReferenceData) {
      throw Exception("init failure");
    }

    final yes = Reference(id: ServerConstants.optionYESid, name: "YES");
    yesNoNaOptions = [yes];

    allCertifications = [
      Reference(id: 1, name: "C1"),
      Reference(id: 2, name: "C2"),
    ];
  }

  @override
  Future<void> fetchCertificationDetails() async {
    fetchCertificationDetailsCalled = true;
    certificationDataMap[1] = CertificationData(
      appCertificationId: 11,
      certificateInformation: Reference(id: 1, name: "C1"),
      selectedOption: yesNoNaOptions.first,
      remarks: "loaded from repo",
    );
  }

  @override
  void initializeMissingCertificates() {
    initializeMissingCertificatesCalled = true;
    super.initializeMissingCertificates();
  }

  @override
  Future<void> checkReadAccess() async {
    effectivePageMode = forceCanEdit ? PageMode.edit : PageMode.view;
  }

  @override
  void registerDraftCallback() {
    registerDraftCallbackCalled = true;
  }

  @override
  Future<void> loadDraftIfAvailable() async {
    loadDraftIfAvailableCalled = true;
  }

  @override
  void unregisterDraftCallback() {
    unregisterDraftCallbackCalled = true;
  }

  @override
  Future<void> deleteDraft() async {
    deleteDraftCalled = true;
  }
}

void main() {
  late _FakeReferenceDataService refService;
  late _FakeCertificationRepository repo;
  late _FakeAlertManager alerts;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    TestWidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
  });

  setUp(() async {
    alerts = _FakeAlertManager();
    AlertManager.overrideInstance(alerts);

    refService = _FakeReferenceDataService();
    ReferenceDataService.overrideInstance(refService);

    repo = _FakeCertificationRepository();
  });

  group("basic getters / constructor / defaults", () {
    test("constructor sets initial loading state and rm type", () {
      final vm = OtherCertificationsViewModel();

      expect(vm.state.loaderStatus, LoadingStatus.loading);
      expect(vm.state.type, CertificationType.rm);
      expect(vm.pageMode, PageMode.na);
      expect(vm.effectivePageMode, PageMode.na);
      expect(vm.canEdit, false);
      expect(vm.isNA, true);
      expect(vm.formKey1, isA<GlobalKey<FormState>>());
      expect(vm.formKey2, isA<GlobalKey<FormState>>());
      expect(vm.formKey3, isA<GlobalKey<FormState>>());
    });

    test("draftModuleKey returns certifications module key", () {
      final vm = OtherCertificationsViewModel();
      expect(vm.draftModuleKey, DraftModuleKeys.certifications);
    });

    test("draftFormKey returns correct route for rm", () {
      final vm = OtherCertificationsViewModel();
      vm.emit(vm.state.copyWith(type: CertificationType.rm));
      expect(vm.draftFormKey, Routes.rmCertification);
    });

    test("draftFormKey returns correct route for documentation", () {
      final vm = OtherCertificationsViewModel();
      vm.emit(vm.state.copyWith(type: CertificationType.documentation));
      expect(vm.draftFormKey, Routes.documentationCertification);
    });

    test("draftFormKey returns correct route for limitInput", () {
      final vm = OtherCertificationsViewModel();
      vm.emit(vm.state.copyWith(type: CertificationType.limitInput));
      expect(vm.draftFormKey, Routes.limitInputCertification);
    });

    test("canEdit getter is true only when effectivePageMode is edit", () {
      final vm = OtherCertificationsViewModel();

      expect((vm..effectivePageMode = PageMode.view).canEdit, false);
      expect((vm..effectivePageMode = PageMode.na).canEdit, false);
      expect((vm..effectivePageMode = PageMode.edit).canEdit, true);
    });

    test("isNA getter is true only when effectivePageMode is na", () {
      final vm = OtherCertificationsViewModel();

      expect((vm..effectivePageMode = PageMode.view).isNA, false);
      expect((vm..effectivePageMode = PageMode.edit).isNA, false);
      expect((vm..effectivePageMode = PageMode.na).isNA, true);
    });
  });

  group("getPageHeading", () {
    test("returns correct key for rm", () {
      final vm = OtherCertificationsViewModel();
      vm.emit(vm.state.copyWith(type: CertificationType.rm));
      expect(vm.getPageHeading(), "certification.otherCertifications.rmTitle");
    });

    test("returns correct key for documentation", () {
      final vm = OtherCertificationsViewModel();
      vm.emit(vm.state.copyWith(type: CertificationType.documentation));
      expect(
        vm.getPageHeading(),
        "certification.otherCertifications.documentationTitle",
      );
    });

    test("returns correct key for limitInput", () {
      final vm = OtherCertificationsViewModel();
      vm.emit(vm.state.copyWith(type: CertificationType.limitInput));
      expect(
        vm.getPageHeading(),
        "certification.otherCertifications.limitInputTitle",
      );
    });
  });

  group("fetchReferenceData", () {
    test("success filters types correctly for RM and populates lists",
        () async {
      final vm = OtherCertificationsViewModel();

      final yes = Reference(id: ServerConstants.optionYESid, name: "YES");

      final documentationType = Reference(
        id: 99,
        name: "DOC",
        reference1: ServerConstants
            .certificationtypeCode[CertificationType.documentation],
      );

      final rmType = Reference(
        id: 1,
        name: "RM1",
        reference1: ServerConstants.certificationtypeCode[CertificationType.rm],
        reference2: null,
      );

      final attachmentType = Reference(
        id: 2,
        name: "RM Attachment",
        reference1: ServerConstants.certificationtypeCode[CertificationType.rm],
        reference2: ServerConstants.attachmentCertificatesID,
      );

      final limitInputType = Reference(
        id: 3,
        name: "LI1",
        reference1:
            ServerConstants.certificationtypeCode[CertificationType.limitInput],
        reference2: null,
      );

      refService.nextData = {
        ReferenceDataKeys.certificateType: [
          documentationType,
          rmType,
          attachmentType,
          limitInputType,
        ],
        ReferenceDataKeys.yesNoNa: [yes],
      };

      await (vm
            ..repository = repo
            ..emit(vm.state.copyWith(type: CertificationType.rm)))
          .fetchReferenceData();

      expect(vm.yesNoNaOptions.length, 1);
      expect(vm.attachmentCertifications.length, 1);
      expect(vm.attachmentCertifications.single.id, attachmentType.id);
      expect(vm.certifications.length, 1);
      expect(vm.certifications.single.id, rmType.id);
      expect(vm.allCertifications.length, 2);
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("with empty data keeps lists empty and loader remains loading",
        () async {
      final vm = OtherCertificationsViewModel()..repository = repo;
      refService.nextData = {};

      await vm.fetchReferenceData();

      expect(vm.yesNoNaOptions, isEmpty);
      expect(vm.attachmentCertifications, isEmpty);
      expect(vm.certifications, isEmpty);
      expect(vm.allCertifications, isEmpty);
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("error emits error and shows failure toast", () async {
      final vm = OtherCertificationsViewModel()..repository = repo;
      refService.throwError = true;

      await expectLater(vm.fetchReferenceData(), throwsException);

      expect(vm.state.loaderStatus, LoadingStatus.error);
      expect(alerts.failureCalls, 1);
      expect(alerts.lastFailure, contains("ref error"));
    });
  });

  group("fetchCertificationDetails", () {
    test("success maps repository items by certificate id", () async {
      final yes = Reference(id: ServerConstants.optionYESid, name: "YES");
      final vm = OtherCertificationsViewModel()
        ..repository = repo
        ..yesNoNaOptions = [yes]
        ..allCertifications = [Reference(id: 1, name: "A")];

      repo.nextList = [
        CertificationData(
          appCertificationId: 1,
          certificateInformation: Reference(id: 1, name: "A"),
          selectedOption: yes,
          remarks: "abc",
        ),
      ];

      await vm.fetchCertificationDetails();

      expect(vm.certificationDataMap.length, 1);
      expect(vm.certificationDataMap[1], isNotNull);
      expect(vm.certificationDataMap[1]!.appCertificationId, 1);
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("success with empty list keeps data map empty", () async {
      final vm = OtherCertificationsViewModel()
        ..repository = repo
        ..yesNoNaOptions = [
          Reference(id: ServerConstants.optionNAid, name: "NA"),
        ]
        ..allCertifications = [Reference(id: 1, name: "A")];
      repo.nextList = [];

      await vm.fetchCertificationDetails();

      expect(vm.certificationDataMap, isEmpty);
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("ignores entries where certificateInformation.id is null", () async {
      final yes = Reference(id: ServerConstants.optionYESid, name: "YES");
      final vm = OtherCertificationsViewModel()
        ..repository = repo
        ..yesNoNaOptions = [yes]
        ..allCertifications = [Reference(id: 10, name: "X")];

      repo.nextList = [
        CertificationData(
          appCertificationId: 1,
          certificateInformation: Reference(id: null, name: "Broken"),
          selectedOption: yes,
          remarks: "ignored",
        ),
      ];

      await vm.fetchCertificationDetails();

      expect(vm.certificationDataMap, isEmpty);
    });

    test("error emits error and shows failure toast", () async {
      final vm = OtherCertificationsViewModel()..repository = repo;
      repo.throwGetError = true;

      await expectLater(
        vm.fetchCertificationDetails(),
        throwsException,
      );

      expect(vm.state.loaderStatus, LoadingStatus.error);
      expect(alerts.failureCalls, 1);
      expect(alerts.lastFailure, contains("get error"));
    });
  });

  group("certificate data helpers", () {
    test("initializeMissingCertificates creates defaults with YES option", () {
      final yes = Reference(id: ServerConstants.optionYESid, name: "YES");
      final a = Reference(id: 1, name: "A");
      final b = Reference(id: 2, name: "B");
      final vm = OtherCertificationsViewModel()
        ..repository = repo
        ..yesNoNaOptions = [yes]
        ..allCertifications = [a, b]
        ..initializeMissingCertificates();

      expect(vm.certificationDataMap.length, 2);
      expect(vm.certificationDataMap[1]!.selectedOption!.id, yes.id);
      expect(vm.certificationDataMap[2]!.selectedOption!.id, yes.id);
      expect(vm.certificationDataMap[1]!.remarks, "");
      expect(vm.certificationDataMap[2]!.appCertificationId, 0);
    });

    test("initializeMissingCertificates does not overwrite existing records",
        () {
      final yes = Reference(id: ServerConstants.optionYESid, name: "YES");
      final vm = OtherCertificationsViewModel()
        ..repository = repo
        ..yesNoNaOptions = [yes]
        ..allCertifications = [
          Reference(id: 1, name: "A"),
          Reference(id: 2, name: "B"),
        ]
        ..certificationDataMap[1] = CertificationData(
          appCertificationId: 999,
          certificateInformation: Reference(id: 1, name: "A"),
          selectedOption: yes,
          remarks: "existing",
        )
        ..initializeMissingCertificates();

      expect(vm.certificationDataMap.length, 2);
      expect(vm.certificationDataMap[1]!.appCertificationId, 999);
      expect(vm.certificationDataMap[1]!.remarks, "existing");
      expect(vm.certificationDataMap[2]!.appCertificationId, 0);
    });

    test("getDefaultOption returns YES option", () {
      final yes = Reference(id: ServerConstants.optionYESid, name: "YES");
      final vm = OtherCertificationsViewModel()
        ..repository = repo
        ..yesNoNaOptions = [yes];

      expect(vm.getDefaultOption().id, yes.id);
    });

    test("getDefaultOption throws if YES option is missing", () {
      final vm = OtherCertificationsViewModel()
        ..repository = repo
        ..yesNoNaOptions = [
          Reference(id: ServerConstants.optionNOid, name: "NO"),
          Reference(id: ServerConstants.optionNAid, name: "NA"),
        ];

      expect(vm.getDefaultOption, throwsStateError);
    });

    test("getCertificationById returns existing record if present", () {
      final yes = Reference(id: ServerConstants.optionYESid, name: "YES");
      final vm = OtherCertificationsViewModel()
        ..repository = repo
        ..yesNoNaOptions = [yes]
        ..certificationDataMap[5] = CertificationData(
          appCertificationId: 3,
          certificateInformation: Reference(id: 5),
          selectedOption: yes,
          remarks: "x",
        );

      final result = vm.getCertificationById(5);

      expect(result.appCertificationId, 3);
      expect(result.certificateInformation.id, 5);
      expect(result.remarks, "x");
    });

    test("getCertificationById returns default record if missing", () {
      final yes = Reference(id: ServerConstants.optionYESid, name: "YES");
      final vm = OtherCertificationsViewModel()
        ..repository = repo
        ..yesNoNaOptions = [yes];

      final result = vm.getCertificationById(9);

      expect(result.appCertificationId, 0);
      expect(result.certificateInformation.id, 9);
      expect(result.selectedOption!.id, yes.id);
      expect(result.remarks, "");
    });

    test("getSelectedDropdownOption returns only selected option", () {
      final na = Reference(id: ServerConstants.optionNAid, name: "NA");
      final yes = Reference(id: ServerConstants.optionYESid, name: "YES");
      final vm = OtherCertificationsViewModel()
        ..repository = repo
        ..yesNoNaOptions = [na, yes]
        ..certificationDataMap[1] = CertificationData(
          appCertificationId: 1,
          certificateInformation: Reference(id: 1),
          selectedOption: yes,
        );

      final list = vm.getSelectedDropdownOption(1);

      expect(list.length, 1);
      expect(list.first.id, yes.id);
    });

    test(
        "getSelectedDropdownOption returns empty when"
        " selected option not found", () {
      final vm = OtherCertificationsViewModel()
        ..repository = repo
        ..yesNoNaOptions = [
          Reference(id: ServerConstants.optionNAid, name: "NA"),
        ]
        ..certificationDataMap[1] = CertificationData(
          appCertificationId: 1,
          certificateInformation: Reference(id: 1),
          selectedOption: Reference(id: 123456, name: "UNKNOWN"),
        );

      final list = vm.getSelectedDropdownOption(1);

      expect(list, isEmpty);
    });
  });

  group("checkReadAccess", () {
    test("copies pageMode=view into effectivePageMode", () async {
      final vm = OtherCertificationsViewModel()..pageMode = PageMode.view;
      await vm.checkReadAccess();
      expect(vm.effectivePageMode, PageMode.view);
      expect(vm.canEdit, false);
    });

    test("copies pageMode=edit into effectivePageMode", () async {
      final vm = OtherCertificationsViewModel()..pageMode = PageMode.edit;
      await vm.checkReadAccess();
      expect(vm.effectivePageMode, PageMode.edit);
      expect(vm.canEdit, true);
    });

    test("copies pageMode=na into effectivePageMode", () async {
      final vm = OtherCertificationsViewModel()..pageMode = PageMode.na;
      await vm.checkReadAccess();
      expect(vm.effectivePageMode, PageMode.na);
      expect(vm.isNA, true);
    });
  });

  group("onSaveContinueButtonPressed", () {
    test("returns early when already submitting", () async {
      final vm = _TestableOtherCertificationsViewModel()
        ..repository = repo
        ..isSubmitting = true;

      await vm.onSaveContinueButtonPressed();

      expect(repo.postCalls, 0);
      expect(vm.isSubmitting, true);
      expect(vm.deleteDraftCalled, false);
    });

    test("posts only updated items and completes success path", () async {
      final vm = _TestableOtherCertificationsViewModel()
        ..repository = repo
        ..certificationDataMap[1] = CertificationData(
          appCertificationId: 1,
          certificateInformation: Reference(id: 1),
          isUpdated: true,
        )
        ..certificationDataMap[2] = CertificationData(
          appCertificationId: 2,
          certificateInformation: Reference(id: 2),
          isUpdated: false,
        );

      await vm.onSaveContinueButtonPressed();

      expect(repo.postCalls, 1);
      expect(repo.postedPayload.length, 1);
      expect(repo.postedPayload.first.certificateInformation.id, 1);
      expect(alerts.successCalls, 1);
      expect(vm.deleteDraftCalled, true);
      expect(vm.isSubmitting, false);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("success path still posts empty list if nothing updated", () async {
      final vm = _TestableOtherCertificationsViewModel()
        ..repository = repo
        ..certificationDataMap[1] = CertificationData(
          appCertificationId: 1,
          certificateInformation: Reference(id: 1),
          isUpdated: false,
        );

      await vm.onSaveContinueButtonPressed();

      expect(repo.postCalls, 1);
      expect(repo.postedPayload, isEmpty);
      expect(alerts.successCalls, 1);
      expect(vm.deleteDraftCalled, true);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("error path shows failure toast and ends with loaded status",
        () async {
      repo.throwPostError = true;
      final vm = _TestableOtherCertificationsViewModel()
        ..repository = repo
        ..certificationDataMap[1] = CertificationData(
          appCertificationId: 1,
          certificateInformation: Reference(id: 1),
          isUpdated: true,
        );

      await vm.onSaveContinueButtonPressed();

      expect(repo.postCalls, 1);
      expect(alerts.failureCalls, 1);
      expect(alerts.lastFailure, contains("post error"));
      expect(vm.deleteDraftCalled, false);
      expect(vm.isSubmitting, false);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("init", () {
    test(
        "init success sets "
        "type, loads data, "
        "initializes defaults, and marks loaded", () async {
      final vm = _TestableOtherCertificationsViewModel();
      await vm.init(CertificationType.rm);

      expect(vm.state.type, CertificationType.rm);
      expect(vm.fetchReferenceDataCalled, true);
      expect(vm.fetchCertificationDetailsCalled, true);
      expect(vm.initializeMissingCertificatesCalled, true);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      expect(vm.allCertifications.length, 2);
      expect(vm.yesNoNaOptions.length, 1);
      expect(vm.certificationDataMap.containsKey(1), true);
      expect(vm.certificationDataMap.containsKey(2), true);
    });

    test("init success enters draft flow when canEdit is true", () async {
      final vm = _TestableOtherCertificationsViewModel()..forceCanEdit = true;

      await vm.init(CertificationType.documentation);

      expect(vm.state.type, CertificationType.documentation);
      expect(vm.fetchReferenceDataCalled, true);
      expect(vm.fetchCertificationDetailsCalled, true);
      expect(vm.initializeMissingCertificatesCalled, true);
      expect(vm.registerDraftCallbackCalled, true);
      expect(vm.loadDraftIfAvailableCalled, true);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init error path shows failure toast and emits error", () async {
      final vm = _TestableOtherCertificationsViewModel()
        ..throwFromFetchReferenceData = true;

      await vm.init(CertificationType.limitInput);

      expect(vm.fetchReferenceDataCalled, true);
      expect(vm.state.loaderStatus, LoadingStatus.error);
      expect(alerts.failureCalls, 1);
      expect(alerts.lastFailure, contains("init failure"));
    });
  });

  group("close", () {
    test("close unregisters draft callback", () async {
      final vm = _TestableOtherCertificationsViewModel();

      await vm.close();

      expect(vm.unregisterDraftCallbackCalled, true);
    });
  });
}
