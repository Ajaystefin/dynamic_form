import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/ccsys/customer_information.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/ccsys_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockAlertManager extends Mock implements AlertManager {}

class MockCcsysRepository extends Mock implements CcsysRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class FakeBuildContext extends Fake implements BuildContext {}

class FakeCcsysCustomerInformation extends Fake
    implements CcsysCustomerInformation {}

class TestCustomerInformationViewModel extends CustomerInformationViewModel {
  @override
  Future<void> deleteDraft() async {
    // Prevent DraftRepository.deleteDraft() real Dio call and pending timers.
  }

  @override
  void moveToNext() {
    // Prevent real router navigation in tests.
  }
}

class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, Object? value) async {
    _storage[box] ??= {};
    _storage[box]![key] = value;
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  late TestCustomerInformationViewModel vm;
  late MockCcsysRepository mockCcsys;
  late MockCustomerRepository mockCustomerRepository;
  late MockReferenceDataService mockReferenceDataService;
  late MockAlertManager mockAlertManager;

  setUpAll(() async {
    registerFallbackValue(<String>[]);
    registerFallbackValue(FakeCcsysCustomerInformation());

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          return <dynamic>["wifi"];
        }
        return null;
      },
    );
  });

  setUp(() {
    mockCcsys = MockCcsysRepository();
    mockCustomerRepository = MockCustomerRepository();
    mockReferenceDataService = MockReferenceDataService();
    mockAlertManager = MockAlertManager();

    ReferenceDataService.overrideInstance = mockReferenceDataService;
    AlertManager.overrideInstance = mockAlertManager;
    LocalStorageService().getStorage = MockLocalStorageService();

    Globals.request = Request(
      applicationRefNo: "APP123",
      customerName: "Test Customer",
    );

    vm = TestCustomerInformationViewModel()
      ..repository = mockCcsys
      ..repositoryCustomer = mockCustomerRepository
      ..yesNoNaItems = [
        Reference(id: ServerConstants.yesRefId, name: "Yes"),
        Reference(id: ServerConstants.noRefId, name: "No"),
        Reference(id: ServerConstants.naRefId, name: "NA"),
      ];
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
  });

  Reference yesRef() => Reference(id: ServerConstants.yesRefId, name: "Yes");

  Reference noRef() => Reference(id: ServerConstants.noRefId, name: "No");

  PartnerShareholder validNpRow({int share = 100}) {
    return PartnerShareholder()
      ..partnerShareholderInEnglish = "Test Name"
      ..partnerShareholderResidence = ServerConstants.residenceRE
      ..legalStatusOfPartnerShareholder = ServerConstants.legalStatusNP
      ..partnerShareholderType = "PR1"
      ..shareholdingPartnershipPercentage = share
      ..networthPartnerShareholderAed = "1000"
      ..emiratesIdPartnerShareholder = "784-1234-1234567-1"
      ..emiratesIdExpiryDatePartnerShareholder = DateTime(2030)
      ..nationalityPartnerShareholder = "AE"
      ..gender = "Male";
  }

  PartnerShareholder validJpRow({int share = 100}) {
    return PartnerShareholder()
      ..partnerShareholderInEnglish = "Company"
      ..partnerShareholderResidence = ServerConstants.residenceRE
      ..legalStatusOfPartnerShareholder = ServerConstants.legalStatusJP
      ..partnerShareholderType = "SH"
      ..shareholdingPartnershipPercentage = share
      ..networthPartnerShareholderAed = "100000"
      ..tradeLicenseNumberPartnerShareholder = "TL001"
      ..placeIssueTradeLicenseNumberPartnerShareholder = "Dubai"
      ..psLei = "N"
      ..gender = "Male";
  }

  group("initial state and draft coverage", () {
    test("initial state is loading", () {
      expect(vm.state.loaderStatus, LoadingStatus.loading);
      expect(vm.state.partnerShareholderStatus, LoadingStatus.loading);
    });

    test("draft getters are covered", () {
      expect(vm.draftModuleKey, isNotEmpty);
      expect(vm.draftFormKey, isNotEmpty);
      expect(vm.draftHandler, isNotNull);
    });
  });

  group("initRightsAndMode", () {
    test("sets canEdit false when request rights are false", () {
      final request = Request()..ccsysCanEditReadOnly = false;

      vm.initRightsAndMode(request);

      expect(vm.canEdit, false);
    });

    test("handles rights true branch", () {
      final request = Request()..ccsysCanEditReadOnly = true;

      vm.initRightsAndMode(request);

      expect(vm.canEdit, isA<bool>());
    });

    test("handles null rights as true branch", () {
      final request = Request();

      vm.initRightsAndMode(request);

      expect(vm.canEdit, isA<bool>());
    });
  });

  group("init", () {
    test("init success loads references and customer information", () async {
      when(() => mockReferenceDataService.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{
          ReferenceDataKeys.ccsysCountryList: [Reference(name: "Bahrain")],
          ReferenceDataKeys.ccsysEmirateList: [Reference(name: "Dubai")],
          ReferenceDataKeys.ccsysGender: [Reference(name: "Male")],
          ReferenceDataKeys.ccsysPsLegalStatus: [
            Reference(reference1: ServerConstants.legalStatusNP),
          ],
          ReferenceDataKeys.ccsysPsResidence: [
            Reference(reference1: ServerConstants.residenceRE),
          ],
          ReferenceDataKeys.ccsysPsType: [Reference(name: "PR1")],
          ReferenceDataKeys.yesNoNa: [yesRef(), noRef()],
        },
      );

      when(() => mockCcsys.getCustomerInformationCCSYS())
          .thenAnswer((_) async => CcsysCustomerInformation());

      await vm.init(FakeBuildContext());

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.applicationTypes.first.name, "CCSYS");
    });

    test("init catches thrown error and still emits loaded", () async {
      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenThrow(Exception("reference failed"));

      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await vm.init(FakeBuildContext());

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("getReferenceData", () {
    test("loads all lists and sorts country list", () async {
      when(() => mockReferenceDataService.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{
          ReferenceDataKeys.ccsysCountryList: [
            Reference(name: "Zambia"),
            Reference(name: "Bahrain"),
            Reference(name: "Argentina"),
          ],
          ReferenceDataKeys.ccsysEmirateList: [Reference(name: "DXB")],
          ReferenceDataKeys.ccsysGender: [Reference(name: "Male")],
          ReferenceDataKeys.ccsysPsLegalStatus: [
            Reference(reference1: ServerConstants.legalStatusNP),
          ],
          ReferenceDataKeys.ccsysPsResidence: [
            Reference(reference1: ServerConstants.residenceRE),
          ],
          ReferenceDataKeys.ccsysPsType: [Reference(name: "PR1")],
          ReferenceDataKeys.yesNoNa: [yesRef(), noRef()],
        },
      );

      await vm.getReferenceData();

      expect(
        vm.ccsysCountryList.map((Reference e) => e.name),
        ["Argentina", "Bahrain", "Zambia"],
      );
      expect(vm.ccsysEmirateList.length, 1);
      expect(vm.ccsysGender.length, 1);
      expect(vm.ccsysPartnerLegalStatus.length, 1);
      expect(vm.ccsysPartnerShareholderResidence.length, 1);
      expect(vm.ccsysPartnerShareholderType.length, 1);
      expect(vm.yesNoNaItems.length, 2);
    });

    test("empty reference map sets empty lists", () async {
      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenAnswer((_) async => <String, List<Reference>>{});

      await vm.getReferenceData();

      expect(vm.ccsysCountryList, isEmpty);
      expect(vm.ccsysEmirateList, isEmpty);
      expect(vm.ccsysGender, isEmpty);
      expect(vm.ccsysPartnerLegalStatus, isEmpty);
      expect(vm.ccsysPartnerShareholderResidence, isEmpty);
      expect(vm.ccsysPartnerShareholderType, isEmpty);
      expect(vm.yesNoNaItems, isEmpty);
    });

    test("rethrows exception", () async {
      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenThrow(Exception("network error"));

      expect(() => vm.getReferenceData(), throwsException);
    });
  });

  group("getCustomerInformation", () {
    test("rethrows repository exception", () async {
      when(() => mockCcsys.getCustomerInformationCCSYS())
          .thenThrow(Exception("server error"));

      expect(() => vm.getCustomerInformation(), throwsException);
    });

    test("handles null response as default model", () async {
      when(() => mockCcsys.getCustomerInformationCCSYS())
          .thenAnswer((_) async => null);

      await vm.getCustomerInformation();

      expect(vm.controllerGroupImmediate.text, "NA");
      expect(vm.controllerGroupUltimate.text, "NA");
      expect(vm.leiController.text, "NA");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("borrowerSubsidiary null branch", () async {
      final data = CcsysCustomerInformation()..borrowerSubsidiary = null;

      when(() => mockCcsys.getCustomerInformationCCSYS())
          .thenAnswer((_) async => data);

      await vm.getCustomerInformation();

      expect(vm.customerInformation.borrowerSubsidiary, false);
      expect(vm.isBorrowingSubsidiary, false);
      expect(vm.controllerGroupImmediate.text, "NA");
      expect(vm.controllerGroupUltimate.text, "NA");
    });

    test("borrowerSubsidiary false branch", () async {
      final data = CcsysCustomerInformation()..borrowerSubsidiary = false;

      when(() => mockCcsys.getCustomerInformationCCSYS())
          .thenAnswer((_) async => data);

      await vm.getCustomerInformation();

      expect(vm.customerInformation.borrowerSubsidiary, false);
      expect(vm.isBorrowingSubsidiary, false);
      expect(vm.controllerGroupImmediate.text, "NA");
      expect(vm.controllerGroupUltimate.text, "NA");
    });

    test("borrowerSubsidiary true branch with parent values", () async {
      final data = CcsysCustomerInformation()
        ..borrowerSubsidiary = true
        ..groupImmediateParent = "Immediate Parent"
        ..groupUltimateParent = "Ultimate Parent";

      when(() => mockCcsys.getCustomerInformationCCSYS())
          .thenAnswer((_) async => data);

      await vm.getCustomerInformation();

      expect(vm.controllerGroupImmediate.text, "Immediate Parent");
      expect(vm.controllerGroupUltimate.text, "Ultimate Parent");
    });

    test("legalEntityIdentifier null branch", () async {
      final data = CcsysCustomerInformation()..legalEntityIdentifier = null;

      when(() => mockCcsys.getCustomerInformationCCSYS())
          .thenAnswer((_) async => data);

      await vm.getCustomerInformation();

      expect(vm.leiController.text, "NA");
      expect(vm.selectedEmirateLicense, isNull);
      expect(vm.selectedEmirateEstablishment, isNull);
    });

    test("legalEntityIdentifier false branch", () async {
      final data = CcsysCustomerInformation()..legalEntityIdentifier = false;

      when(() => mockCcsys.getCustomerInformationCCSYS())
          .thenAnswer((_) async => data);

      await vm.getCustomerInformation();

      expect(vm.leiController.text, "NA");
      expect(vm.selectedEmirateLicense, isNull);
      expect(vm.selectedEmirateEstablishment, isNull);
    });

    test("legalEntityIdentifier true branch with emirate matches", () async {
      final data = CcsysCustomerInformation()
        ..legalEntityIdentifier = true
        ..leiNumber = "LEI123"
        ..emiEst = "Dubai"
        ..emiLic = "Abu Dhabi";

      vm.ccsysEmirateList = [
        Reference(name: "Dubai"),
        Reference(name: "Abu Dhabi"),
      ];

      when(() => mockCcsys.getCustomerInformationCCSYS())
          .thenAnswer((_) async => data);

      await vm.getCustomerInformation();

      expect(vm.leiController.text, "LEI123");
      expect(vm.selectedEmirateEstablishment?.name, "Dubai");
      expect(vm.selectedEmirateLicense?.name, "Abu Dhabi");
    });

    test("legalEntityIdentifier true branch with fallback emirate references",
        () async {
      final data = CcsysCustomerInformation()
        ..legalEntityIdentifier = true
        ..leiNumber = "NA"
        ..emiEst = "Unknown Establishment"
        ..emiLic = "Unknown License";

      vm.ccsysEmirateList = [Reference(name: "Dubai")];

      when(() => mockCcsys.getCustomerInformationCCSYS())
          .thenAnswer((_) async => data);

      await vm.getCustomerInformation();

      expect(vm.leiController.text, "");
      expect(vm.selectedEmirateEstablishment?.name, "Unknown Establishment");
      expect(vm.selectedEmirateLicense?.name, "Unknown License");
    });

    test("initializes partner shareholder controllers from response", () async {
      final data = CcsysCustomerInformation()
        ..ccsysCustomerPartnerShareholderList = [
          PartnerShareholder()
            ..partnerShareholderInEnglish = "Partner A"
            ..shareholdingPartnershipPercentage = 100,
        ];

      when(() => mockCcsys.getCustomerInformationCCSYS())
          .thenAnswer((_) async => data);

      await vm.getCustomerInformation();

      expect(vm.rows.length, 1);
      expect(vm.ctrls.length, 1);
      expect(vm.ctrls.first.name.text, "Partner A");
    });
  });

  group("change handlers", () {
    test("setEmiratesId updates model", () {
      vm.setEmiratesId("784-XXXX");
      expect(vm.customerInformation.emiratesIdPartner, "784-XXXX");
    });

    test("setEmiratesId null updates model", () {
      vm.setEmiratesId(null);
      expect(vm.customerInformation.emiratesIdPartner, isNull);
    });

    test("onChangeBorrowingSubsidiary yes branch", () {
      vm.customerInformation
        ..groupImmediateParent = "Immediate"
        ..groupUltimateParent = "Ultimate";

      vm.onChangeBorrowingSubsidiary(yesRef());

      expect(vm.customerInformation.borrowerSubsidiary, true);
      expect(vm.selectedBorroweSubsidiary?.id, ServerConstants.yesRefId);
    });

    test("onChangeBorrowingSubsidiary no branch", () {
      vm.onChangeBorrowingSubsidiary(noRef());

      expect(vm.customerInformation.borrowerSubsidiary, false);
      expect(vm.controllerGroupImmediate.text, "NA");
      expect(vm.controllerGroupUltimate.text, "NA");
    });

    test("onChangeBorrowingSubsidiary null branch", () {
      vm.onChangeBorrowingSubsidiary(null);

      expect(vm.selectedBorroweSubsidiary, isNull);
    });

    test("onChangeisLegalEntityIdentifier yes branch", () {
      vm
        ..selectedEmirateLicense = Reference(name: "NA")
        ..selectedEmirateEstablishment = Reference(name: "NA");
      vm.customerInformation.leiNumber = "LEI999";

      vm.onChangeisLegalEntityIdentifier(yesRef());

      expect(vm.customerInformation.legalEntityIdentifier, true);
      expect(vm.leiController.text, "LEI999");
      expect(vm.selectedEmirateLicense, isNull);
      expect(vm.selectedEmirateEstablishment, isNull);
    });

    test("onChangeisLegalEntityIdentifier yes with NA lei clears text", () {
      vm.customerInformation.leiNumber = "NA";

      vm.onChangeisLegalEntityIdentifier(yesRef());

      expect(vm.customerInformation.legalEntityIdentifier, true);
      expect(vm.leiController.text, "");
    });

    test("onChangeisLegalEntityIdentifier no branch", () {
      vm.onChangeisLegalEntityIdentifier(noRef());

      expect(vm.customerInformation.legalEntityIdentifier, false);
      expect(vm.leiController.text, "NA");
      expect(vm.selectedEmirateLicense, isNull);
      expect(vm.selectedEmirateEstablishment, isNull);
    });

    test("onCountryChipDeleted removes by index", () {
      vm
        ..customerInformation.countryOfRiskFundUtilization = [
          Reference(name: "AE"),
          Reference(name: "IN"),
        ]
        ..onCountryChipDeleted(0);

      expect(
        vm.customerInformation.countryOfRiskFundUtilization!.first.name,
        "IN",
      );
    });

    test("onCountryChipDeleted no-op cases", () {
      vm.customerInformation.countryOfRiskFundUtilization = null;
      expect(() => vm.onCountryChipDeleted(0), returnsNormally);

      vm.customerInformation.countryOfRiskFundUtilization = [
        Reference(name: "AE"),
      ];
      vm
        ..onCountryChipDeleted(-1)
        ..onCountryChipDeleted(5);

      expect(vm.customerInformation.countryOfRiskFundUtilization!.length, 1);
    });

    test("updateCountriesOfRisk replaces list", () {
      final selected = [Reference(name: "US"), Reference(name: "GB")];

      vm.updateCountriesOfRisk(selected);

      expect(vm.customerInformation.countryOfRiskFundUtilization, selected);
    });

    test("onLegalStatusPartnerSelected and isLegalNpAndResidencyRE coverage",
        () {
      vm.onLegalStatusPartnerSelected(Reference(name: "NP"));
      expect(vm.isLegalNpAndResidencyRE(), false);
    });
  });

  group("row lifecycle", () {
    test("initializeControllers sets rows and controllers", () {
      final initial = [
        PartnerShareholder()
          ..partnerShareholderInEnglish = "Person A"
          ..shareholdingPartnershipPercentage = 60
          ..networthPartnerShareholderAed = "1000",
        PartnerShareholder()
          ..partnerShareholderInEnglish = "Person B"
          ..shareholdingPartnershipPercentage = 40
          ..networthPartnerShareholderAed = "2000",
      ];

      vm.initializeControllers(initial);

      expect(vm.rows.length, 2);
      expect(vm.ctrls.length, 2);
      expect(vm.ctrls[0].name.text, "Person A");
      expect(vm.ctrls[1].name.text, "Person B");
    });

    test("initializeControllers with empty list", () {
      vm.initializeControllers([]);

      expect(vm.rows, isEmpty);
      expect(vm.ctrls, isEmpty);
    });

    test("disposeControllers disposes and emits loaded", () {
      vm
        ..addRow()
        ..addRow()
        ..disposeControllers();

      expect(vm.state.partnerShareholderStatus, LoadingStatus.loaded);
    });

    test("addRow populates rows and controllers", () {
      vm.addRow();

      expect(vm.rows.length, 1);
      expect(vm.ctrls.length, 1);
    });

    test("addRow multiple times", () {
      vm
        ..addRow()
        ..addRow()
        ..addRow();

      expect(vm.rows.length, 3);
      expect(vm.ctrls.length, 3);
    });

    test("removeRow valid and invalid indexes", () {
      vm
        ..addRow()
        ..addRow()
        ..removeRow(0);

      expect(vm.rows.length, 1);

      vm
        ..removeRow(-1)
        ..removeRow(99);

      expect(vm.rows.length, 1);

      vm.removeRow(0);

      expect(vm.rows, isEmpty);
      expect(vm.ctrls, isEmpty);
    });

    test("updateRow applies changes", () async {
      vm.addRow();

      await vm.updateRow(() {
        vm.rows[0].partnerShareholderInEnglish = "Changed";
      });

      expect(vm.rows[0].partnerShareholderInEnglish, "Changed");
    });

    test("notifyRowChanged emits loaded", () async {
      vm.addRow();

      await vm.notifyRowChanged();

      expect(vm.state.partnerShareholderStatus, LoadingStatus.loaded);
    });
  });

  group("row setters", () {
    test("setResidency RE clears passport fields", () async {
      vm.addRow();

      await vm.setResidency(
        0,
        Reference(reference1: ServerConstants.residenceRE),
      );

      expect(
        vm.rows[0].partnerShareholderResidence,
        ServerConstants.residenceRE,
      );
      expect(vm.rows[0].passportNumberExpiryDatePartnerShareholder, isNull);
      expect(vm.ctrls[0].passport.text, "");
    });

    test("setResidency NR clears emirates fields", () async {
      vm.addRow();

      await vm.setResidency(
        0,
        Reference(reference1: ServerConstants.residenceNR),
      );

      expect(
        vm.rows[0].partnerShareholderResidence,
        ServerConstants.residenceNR,
      );
      expect(vm.rows[0].emiratesIdPartnerShareholder, "");
      expect(vm.rows[0].emiratesIdExpiryDatePartnerShareholder, isNull);
    });

    test("setLegalStatus JP clears natural person fields", () async {
      vm.addRow();

      await vm.setLegalStatus(
        0,
        Reference(reference1: ServerConstants.legalStatusJP),
      );

      expect(
        vm.rows[0].legalStatusOfPartnerShareholder,
        ServerConstants.legalStatusJP,
      );
      expect(vm.rows[0].nationalityPartnerShareholder, isNull);
      expect(vm.rows[0].emiratesIdPartnerShareholder, "");
      expect(vm.rows[0].emiratesIdExpiryDatePartnerShareholder, isNull);
      expect(vm.ctrls[0].netWorth.text, "");
    });

    test("setLegalStatus NP clears juridical person fields", () async {
      vm.addRow();

      await vm.setLegalStatus(
        0,
        Reference(reference1: ServerConstants.legalStatusNP),
      );

      expect(
        vm.rows[0].legalStatusOfPartnerShareholder,
        ServerConstants.legalStatusNP,
      );
      expect(vm.rows[0].tradeLicenseNumberPartnerShareholder, "");
      expect(vm.rows[0].placeIssueTradeLicenseNumberPartnerShareholder, isNull);
      expect(vm.rows[0].psLei, isNull);
      expect(vm.rows[0].leiNumberPartnerShareholder, "");
      expect(vm.ctrls[0].tradeLicense.text, "");
      expect(vm.ctrls[0].leiNumber.text, "");
      expect(vm.ctrls[0].netWorth.text, "0");
    });

    test("simple row setters", () async {
      vm.addRow();

      await vm.setNationality(0, Reference(name: "Indian"));
      await vm.setTradeLicensePlace(0, Reference(name: "Dubai"));
      await vm.setType(0, Reference(name: "PR1"));
      await vm.setGender(0, Reference(name: "Male"));

      final emiratesExpiry = DateTime(2030);
      final passportExpiry = DateTime(2032, 6, 15);

      await vm.setEmiratesIdExpiry(0, emiratesExpiry);
      await vm.setPassportExpiry(0, passportExpiry);

      expect(vm.rows[0].nationalityPartnerShareholder, "Indian");
      expect(
        vm.rows[0].placeIssueTradeLicenseNumberPartnerShareholder,
        "Dubai",
      );
      expect(vm.rows[0].partnerShareholderType, "PR1");
      expect(vm.rows[0].gender, "Male");
      expect(vm.rows[0].emiratesIdExpiryDatePartnerShareholder, emiratesExpiry);
      expect(
        vm.rows[0].passportNumberExpiryDatePartnerShareholder,
        passportExpiry,
      );
    });

    test("setLeiOpt yes and no", () async {
      vm.addRow();

      await vm.setLeiOpt(0, yesRef());
      expect(vm.rows[0].psLei, "Y");

      vm.ctrls[0].leiNumber.text = "LEI-TEXT";
      await vm.setLeiOpt(0, noRef());

      expect(vm.rows[0].psLei, "N");
      expect(vm.rows[0].leiNumberPartnerShareholder, "");
      expect(vm.ctrls[0].leiNumber.text, "");
    });

    test("text change handlers", () {
      vm
        ..addRow()
        ..onChangeTLNumber("TL12345", 0)
        ..onChangePassport("AB123/AE", 0)
        ..onChangeEmiratesId("784-1234-1234567-1", 0)
        ..onChangeLEINumber("ABCDE12345ABCDE12345", 0);

      expect(vm.rows[0].tradeLicenseNumberPartnerShareholder, "TL12345");
      expect(vm.rows[0].passportNumberPartnerShareholder, "AB123/AE");
      expect(vm.rows[0].emiratesIdPartnerShareholder, "784-1234-1234567-1");
      expect(vm.rows[0].leiNumberPartnerShareholder, "ABCDE12345ABCDE12345");
    });

    test("onChangePassport empty clears fields", () {
      vm
        ..addRow()
        ..rows[0].passportNumberPartnerShareholder = "OLD/AE"
        ..rows[0].passportNumberExpiryDatePartnerShareholder = DateTime.now()
        ..onChangePassport("", 0);

      expect(vm.rows[0].passportNumberExpiryDatePartnerShareholder, isNull);
      expect(vm.rows[0].passportNumberPartnerShareholder, "");
      expect(vm.isDateValidPassportExpiry, false);
    });
  });

  group("enabled and required helpers", () {
    test("helper booleans for invalid index", () {
      vm.canEdit = true;
      expect(vm.eidEnabled(99), false);
      expect(vm.eidExpiryEnabled(99), false);
      expect(vm.passportEnabled(99), false);
      expect(vm.passportExpiryEnabled(99), false);
      expect(vm.nationalityRequired(99), false);
      expect(vm.tradeLicenseEnabled(99), false);
      expect(vm.tradeLicensePlaceEnabled(99), false);
      expect(vm.leiVisible(99), false);
      expect(vm.leiNumberEnabled(99), false);
      expect(vm.isnetworkEditable(99), false);
    });

    test("eidEnabled branches", () {
      vm
        ..addRow()
        ..canEdit = true;

      vm.rows[0]
        ..partnerShareholderResidence = ServerConstants.residenceRE
        ..legalStatusOfPartnerShareholder = ServerConstants.legalStatusNP;

      expect(vm.eidEnabled(0), true);

      vm.rows[0].legalStatusOfPartnerShareholder =
          ServerConstants.legalStatusJP;
      expect(vm.eidEnabled(0), false);
    });

    test("passportEnabled branches", () {
      vm.addRow();

      vm.rows[0]
        ..partnerShareholderResidence = ServerConstants.residenceRE
        ..legalStatusOfPartnerShareholder = ServerConstants.legalStatusNP;

      expect(vm.passportEnabled(0), false);

      vm.rows[0].partnerShareholderResidence = ServerConstants.residenceNR;
      expect(vm.passportEnabled(0), true);

      vm.rows[0]
        ..partnerShareholderResidence = ServerConstants.residenceRE
        ..legalStatusOfPartnerShareholder = ServerConstants.legalStatusJP;

      expect(vm.passportEnabled(0), true);
    });

    test("other enabled helper branches", () {
      vm
        ..addRow()
        ..canEdit = true;
      vm.rows[0]
        ..legalStatusOfPartnerShareholder = ServerConstants.legalStatusNP
        ..partnerShareholderResidence = ServerConstants.residenceRE
        ..emiratesIdPartnerShareholder = "784"
        ..passportNumberPartnerShareholder = "P/AE";

      expect(vm.isnetworkEditable(0), true);
      expect(vm.rows[0].networthPartnerShareholderAed, "0");
      expect(vm.eidExpiryEnabled(0), true);
      expect(vm.passportExpiryEnabled(0), true);
      expect(vm.nationalityRequired(0), true);

      vm.rows[0]
        ..legalStatusOfPartnerShareholder = ServerConstants.legalStatusJP
        ..tradeLicenseNumberPartnerShareholder = "TL"
        ..psLei = "Y";

      expect(vm.tradeLicenseEnabled(0), true);
      expect(vm.tradeLicensePlaceEnabled(0), true);
      expect(vm.leiVisible(0), true);
      expect(vm.leiNumberEnabled(0), true);

      vm.rows[0]
        ..emiratesIdPartnerShareholder = ""
        ..passportNumberPartnerShareholder = ""
        ..tradeLicenseNumberPartnerShareholder = ""
        ..psLei = "N";

      expect(vm.eidExpiryEnabled(0), false);
      expect(vm.passportExpiryEnabled(0), false);
      expect(vm.tradeLicensePlaceEnabled(0), false);
      expect(vm.leiNumberEnabled(0), false);
    });
  });

  group("validators", () {
    test("shareHoldingPercentageValidator branches", () {
      expect(vm.shareHoldingPercentageValidator(null), isNotNull);

      vm.rows = [
        PartnerShareholder()..shareholdingPartnershipPercentage = 0,
      ];
      expect(vm.shareHoldingPercentageValidator("0"), isNotNull);

      vm.rows = [
        PartnerShareholder()..shareholdingPartnershipPercentage = 20,
        PartnerShareholder()..shareholdingPartnershipPercentage = 30,
      ];
      expect(vm.shareHoldingPercentageValidator("0"), isNotNull);

      vm.rows = [
        PartnerShareholder()..shareholdingPartnershipPercentage = 50,
        PartnerShareholder()..shareholdingPartnershipPercentage = 50,
      ];
      expect(vm.shareHoldingPercentageValidator("0"), isNull);
    });

    test("validateAll prefixes row numbers", () {
      vm.rows = [PartnerShareholder()];

      final errors = vm.validateAll();

      expect(errors.isNotEmpty, true);
      expect(errors.first.startsWith("Row 1:"), true);
    });

    test("validateRow empty row has errors", () {
      vm.rows = [PartnerShareholder()];

      expect(vm.validateRow(0), isNotEmpty);
    });

    test("validateRow RE NP missing emirates id", () {
      vm.rows = [
        validNpRow()
          ..emiratesIdPartnerShareholder = ""
          ..emiratesIdExpiryDatePartnerShareholder = null,
      ];

      expect(
        vm.validateRow(0).any(
              (String e) => e
                  .contains("ccsys.customerInformation.emiratesIdRequiredReNp"),
            ),
        true,
      );
    });

    test("validateRow RE NP emirates id expiry missing", () {
      vm.rows = [
        validNpRow()
          ..emiratesIdPartnerShareholder = "784"
          ..emiratesIdExpiryDatePartnerShareholder = null,
      ];

      expect(
        vm.validateRow(0).any(
              (String e) => e.contains(
                "ccsys.customerInformation.emiratesIdExpiryRequired",
              ),
            ),
        true,
      );
    });

    test("validateRow NR NP missing passport", () {
      vm.rows = [
        validNpRow()
          ..partnerShareholderResidence = ServerConstants.residenceNR
          ..passportNumberPartnerShareholder = ""
          ..emiratesIdPartnerShareholder = "",
      ];

      expect(
        vm.validateRow(0).any(
              (String e) =>
                  e.contains("ccsys.customerInformation.passportRequiredNrNp"),
            ),
        true,
      );
    });

    test("validateRow NR NP invalid passport format", () {
      vm.rows = [
        validNpRow()
          ..partnerShareholderResidence = ServerConstants.residenceNR
          ..passportNumberPartnerShareholder = "BAD-FORMAT"
          ..passportNumberExpiryDatePartnerShareholder = DateTime(2030),
      ];

      expect(
        vm.validateRow(0).any(
              (String e) =>
                  e.contains("ccsys.customerInformation.passportFormat"),
            ),
        true,
      );
    });

    test("validateRow passport expiry required when passport exists", () {
      vm.rows = [
        validJpRow()
          ..passportNumberPartnerShareholder = "AB123/AE"
          ..passportNumberExpiryDatePartnerShareholder = null,
      ];

      expect(
        vm.validateRow(0).any(
              (String e) => e
                  .contains("ccsys.customerInformation.passportExpiryRequired"),
            ),
        true,
      );
    });

    test("validateRow NP nationality missing", () {
      vm.rows = [
        validNpRow()..nationalityPartnerShareholder = "",
      ];

      expect(
        vm.validateRow(0).any(
              (String e) =>
                  e.contains("ccsys.customerInformation.nationalityRequiredNp"),
            ),
        true,
      );
    });

    test("validateRow JP trade license missing", () {
      vm.rows = [
        validJpRow()..tradeLicenseNumberPartnerShareholder = "",
      ];

      expect(
        vm.validateRow(0).any(
              (String e) => e
                  .contains("ccsys.customerInformation.tradeLicenseRequiredJp"),
            ),
        true,
      );
    });

    test("validateRow trade license place missing", () {
      vm.rows = [
        validJpRow()
          ..tradeLicenseNumberPartnerShareholder = "TL001"
          ..placeIssueTradeLicenseNumberPartnerShareholder = "",
      ];

      expect(
        vm.validateRow(0).any(
              (String e) => e.contains(
                "ccsys.customerInformation.placeOfIssueRequiredWithTl",
              ),
            ),
        true,
      );
    });

    test("validateRow JP LEI yes but missing number", () {
      vm.rows = [
        validJpRow()
          ..psLei = "Y"
          ..leiNumberPartnerShareholder = "",
      ];

      expect(
        vm.validateRow(0).any(
              (String e) =>
                  e.contains("ccsys.customerInformation.leiFieldsRequired"),
            ),
        true,
      );
    });

    test("validateRow field mandatory branches", () {
      vm.rows = [
        validJpRow()
          ..partnerShareholderInEnglish = ""
          ..partnerShareholderResidence = ""
          ..partnerShareholderType = ""
          ..shareholdingPartnershipPercentage = 150
          ..networthPartnerShareholderAed = ""
          ..gender = "",
      ];

      final errors = vm.validateRow(0);

      expect(
        errors.any(
          (String e) =>
              e.contains("ccsys.customerInformation.nameEnglishRequired"),
        ),
        true,
      );
      expect(
        errors.any(
          (String e) =>
              e.contains("ccsys.customerInformation.residenceRequired"),
        ),
        true,
      );
      expect(
        errors.any(
          (String e) => e.contains("ccsys.customerInformation.typeRequired"),
        ),
        true,
      );
      expect(
        errors.any(
          (String e) =>
              e.contains("ccsys.customerInformation.holdingOutOfRange"),
        ),
        true,
      );
      expect(
        errors.any(
          (String e) =>
              e.contains("ccsys.customerInformation.networthRequired"),
        ),
        true,
      );
      expect(
        errors.any(
          (String e) => e.contains("ccsys.customerInformation.genderRequired"),
        ),
        true,
      );
    });

    test("validateRow valid NP and JP rows", () {
      vm.rows = [validNpRow()];
      expect(vm.validateRow(0), isEmpty);

      vm.rows = [validJpRow()];
      expect(vm.validateRow(0), isEmpty);
    });
  });

  group("date validator", () {
    test("null and empty date with isToday set date fs flag", () {
      expect(
        vm.checkAuditedFsDate(null, isToday: true, isDateFs: true),
        isNotNull,
      );
      expect(vm.isDateValid, true);

      expect(
        vm.checkAuditedFsDate("", isToday: true, isDateFs: true),
        isNotNull,
      );
      expect(vm.isDateValid, true);
    });

    test("invalid date format branches", () {
      expect(vm.checkAuditedFsDate("bad", isDateFs: true), isNotNull);
      expect(vm.isDateValid, true);

      expect(vm.checkAuditedFsDate("bad-passport"), isNotNull);
      expect(vm.isDateValidPassportExpiry, true);
    });

    test("future date branches", () {
      final future = DateTime.now().add(const Duration(days: 5));
      final formatted =
          "${future.day.toString().padLeft(2, "0")}/${future.month.toString().padLeft(2, "0")}/${future.year}";

      expect(
        vm.checkAuditedFsDate(formatted, isToday: true, isDateFs: true),
        isNotNull,
      );
      expect(vm.isDateValid, true);

      expect(vm.checkAuditedFsDate(formatted, isToday: true), isNotNull);
      expect(vm.isDateValidPassportExpiry, true);
    });

    test("valid date returns null", () {
      expect(
        vm.checkAuditedFsDate("01/01/2020", isToday: true, isDateFs: true),
        isNull,
      );
      expect(vm.isDateValid, false);
    });
  });

  group("reusable helpers", () {
    test("validateSelection returns null or error", () {
      final options = [Reference(name: "Male"), Reference(name: "Female")];

      expect(vm.validateSelection("Male", options, "error.key"), isNull);
      expect(
        vm.validateSelection("Unknown", options, "error.key"),
        "error.key",
      );
      expect(vm.validateSelection(null, options, "error.key"), isNotNull);
    });

    test("getFilteredOptions removes NA id", () {
      final options = [
        Reference(id: ServerConstants.naRefId, name: "NA"),
        Reference(id: 1, name: "One"),
      ];

      final filtered = vm.getFilteredOptions(options);

      expect(filtered.length, 1);
      expect(filtered.first.name, "One");
    });

    test("getSelectedReference selected and fallback branches", () {
      final selected = Reference(id: ServerConstants.yesRefId, name: "Yes");
      final options = [
        selected,
        Reference(id: ServerConstants.noRefId, name: "No"),
      ];

      expect(
        vm.getSelectedReference(
          options: options,
          selectedValue: selected,
          fallbackFlag: false,
        ),
        selected,
      );

      expect(
        vm
            .getSelectedReference(
              options: options,
              selectedValue: null,
              fallbackFlag: false,
            )
            .id,
        ServerConstants.yesRefId,
      );
    });
  });

  group("PartnerShareholderControllers", () {
    test("attach syncs initial values and listeners update model", () {
      final model = PartnerShareholder()
        ..partnerShareholderInEnglish = "John"
        ..shareholdingPartnershipPercentage = 75
        ..networthPartnerShareholderAed = "9999"
        ..emiratesIdPartnerShareholder = "784-0000"
        ..passportNumberPartnerShareholder = "AB123/AE"
        ..tradeLicenseNumberPartnerShareholder = "TL001"
        ..leiNumberPartnerShareholder = "LEIABCDE12345LEIAB01";

      final ctrl = PartnerShareholderControllers()..attach(model);

      expect(ctrl.name.text, "John");
      expect(ctrl.sharePercent.text, "75");
      expect(ctrl.netWorth.text, "9999");
      expect(ctrl.emiratesId.text, "784-0000");
      expect(ctrl.passport.text, "AB123/AE");
      expect(ctrl.tradeLicense.text, "TL001");
      expect(ctrl.leiNumber.text, "LEIABCDE12345LEIAB01");

      ctrl
        ..name.text = "Updated Name"
        ..sharePercent.text = "55"
        ..netWorth.text = "12345"
        ..emiratesId.text = "784-9999"
        ..passport.text = "XY999/GB"
        ..tradeLicense.text = "TL-99999"
        ..leiNumber.text = "LEI999";

      expect(model.partnerShareholderInEnglish, "Updated Name");
      expect(model.shareholdingPartnershipPercentage, 55);
      expect(model.networthPartnerShareholderAed, "12345");
      expect(model.emiratesIdPartnerShareholder, "784-9999");
      expect(model.passportNumberPartnerShareholder, "XY999/GB");
      expect(model.tradeLicenseNumberPartnerShareholder, "TL-99999");
      expect(model.leiNumberPartnerShareholder, "LEI999");

      ctrl.sharePercent.text = "abc";
      expect(model.shareholdingPartnershipPercentage, isNull);

      ctrl.dispose();
    });

    test("attach with null model fields sets empty strings and dispose safe",
        () {
      final model = PartnerShareholder();
      final ctrl = PartnerShareholderControllers()..attach(model);

      expect(ctrl.name.text, "");
      expect(ctrl.sharePercent.text, "");
      expect(ctrl.netWorth.text, "");
      expect(ctrl.emiratesId.text, "");
      expect(ctrl.passport.text, "");
      expect(ctrl.tradeLicense.text, "");
      expect(ctrl.leiNumber.text, "");

      expect(ctrl.dispose, returnsNormally);
    });
  });

  group("saveCustomerInformation", () {
    testWidgets("validateAll errors branch", (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Form(key: vm.formKey, child: Container())),
      );

      vm.rows = [PartnerShareholder()];

      await vm.saveCustomerInformation();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("rows empty branch", (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Form(key: vm.formKey, child: Container())),
      );

      vm.rows = [];

      await vm.saveCustomerInformation();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("shareholding validator error branch", (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Form(key: vm.formKey, child: Container())),
      );

      vm.rows = [validNpRow(share: 50)];

      await vm.saveCustomerInformation();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save success branch", (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Form(key: vm.formKey, child: Container())),
      );

      vm
        ..rows = [validNpRow()]
        ..ccsysCustomerInformationId = 10;

      when(() => mockCcsys.saveCustomerInformation(any()))
          .thenAnswer((_) async => "common.success");

      when(() => mockCcsys.getCustomerInformationCCSYS())
          .thenAnswer((_) async => CcsysCustomerInformation());

      await vm.saveCustomerInformation();

      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save success branch with navigation", (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Form(key: vm.formKey, child: Container())),
      );

      vm.rows = [validNpRow()];

      when(() => mockCcsys.saveCustomerInformation(any()))
          .thenAnswer((_) async => "common.success");

      when(() => mockCcsys.getCustomerInformationCCSYS())
          .thenAnswer((_) async => CcsysCustomerInformation());

      await vm.saveCustomerInformation(ifNavigate: true);

      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
    });

    testWidgets("save failure response branch", (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Form(key: vm.formKey, child: Container())),
      );

      vm.rows = [validNpRow()];

      when(() => mockCcsys.saveCustomerInformation(any()))
          .thenAnswer((_) async => "FAILED");

      await vm.saveCustomerInformation();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save repository throws branch", (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Form(key: vm.formKey, child: Container())),
      );

      vm.rows = [validNpRow()];

      when(() => mockCcsys.saveCustomerInformation(any()))
          .thenThrow(Exception("save failed"));

      await vm.saveCustomerInformation();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("existing partner shareholder ids copied branch",
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Form(key: vm.formKey, child: Container())),
      );

      final existing = PartnerShareholder()..ccsysCustomerId = 99;

      vm.customerInformation.ccsysCustomerPartnerShareholderList = [existing];
      vm.rows = [validNpRow()];

      when(() => mockCcsys.saveCustomerInformation(any()))
          .thenAnswer((_) async => "FAILED");

      await vm.saveCustomerInformation();

      expect(vm.rows.first.ccsysCustomerId, 99);
    });
  });

  test("close unregisters draft callback safely", () async {
    await vm.close();
  });
}
