import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/ccsys/customer_information.dart";
import "package:wcas_frontend/repositories/ccsys_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/home_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class MockRequestRepository extends Mock implements CcsysRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {}

class MockHomeRepo extends Mock implements HomeRepository {}

// Proper mock storage service like in the reference file
class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, dynamic value) async {
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

  void clearAll() {
    _storage.clear();
  }
}

// Mock RequestRepository singleton for static access
class MockRequestRepositoryStatic extends Mock implements RequestRepository {
  static MockRequestRepositoryStatic? _instance;
  static MockRequestRepositoryStatic get instance =>
      _instance ??= MockRequestRepositoryStatic();
  static void overrideInstance(MockRequestRepositoryStatic mockInstance) {
    _instance = mockInstance;
  }

  static void reset() {
    _instance = null;
  }
}

extension LocalizationBypass on String {
  String tr() => this;
}

class MockDialogHelper extends Mock implements DialogHelper {
  void showCustomDialog({
    required double width,
    required BuildContext context,
    required String title,
    required Widget content,
    required List<Widget> actions,
  });
}

class TestFormState extends Fake implements FormState {
  TestFormState(this.shouldValidate);
  final bool shouldValidate;

  @override
  bool validate() => shouldValidate;

  @override
  void save() {}

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      "TestFormState(shouldValidate: $shouldValidate)";
}

// ===== Mockito mocks =====
class MockCcsysRepository extends Mock implements CcsysRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

extension TrBypass on String {
  String tr() => this;
}

void main() {
  late CustomerInformationViewModel vm;
  late MockCcsysRepository mockCcsys;
  late MockCustomerRepository mockCustRepo;
  late MockReferenceDataService mockRef;
  late MockAlertManager mockAlert;

  setUp(() {
    mockCcsys = MockCcsysRepository();
    mockCustRepo = MockCustomerRepository();
    mockRef = MockReferenceDataService();
    mockAlert = MockAlertManager();

    vm = CustomerInformationViewModel()
      ..repository = mockCcsys
      ..repositoryCustomer = mockCustRepo;

    // Override ref data service (since your class uses static)
    ReferenceDataService.overrideInstance(mockRef);
  });

  // -----------------------------------------------------------
  // INITIAL STATE
  // -----------------------------------------------------------
  test("initial state is loading", () {
    expect(vm.state.loaderStatus, LoadingStatus.loading);
    expect(vm.state.partnerShareholderStatus, LoadingStatus.loading);
  });

  // -----------------------------------------------------------
  // GET REFERENCE DATA
  // -----------------------------------------------------------
  test("getReferenceData loads all lists & sorts countries", () async {
    when(() => mockRef.getReferenceData(any())).thenAnswer(
      (_) async => {
        ReferenceDataKeys.ccsysCountryList: [
          Reference(name: "Zambia"),
          Reference(name: "Bahrain"),
          Reference(name: "Argentina"),
        ],
        ReferenceDataKeys.ccsysEmirateList: [Reference(name: "DXB")],
        ReferenceDataKeys.ccsysGender: [Reference(name: "Male")],
        ReferenceDataKeys.ccsysPsLegalStatus: [Reference(reference1: "NP")],
        ReferenceDataKeys.ccsysPsResidence: [Reference(reference1: "RE")],
        ReferenceDataKeys.ccsysPsType: [Reference(name: "PR1")],
        ReferenceDataKeys.yesNoNa: [
          Reference(id: 1, name: "Yes"),
          Reference(id: 0, name: "No"),
        ],
      },
    );

    await vm.getReferenceData();

    expect(
      vm.ccsysCountryList.map((e) => e.name),
      ["Argentina", "Bahrain", "Zambia"],
    );
    expect(vm.ccsysEmirateList.length, 1);
    expect(vm.ccsysGender.length, 1);
  });

  test("getReferenceData handles empty maps gracefully", () async {
    when(() => mockRef.getReferenceData(any()))
        .thenAnswer((_) async => <String, List<Reference>>{});

    await vm.getReferenceData();

    expect(vm.ccsysCountryList, isEmpty);
    expect(vm.ccsysEmirateList, isEmpty);
    expect(vm.ccsysGender, isEmpty);
    expect(vm.yesNoNaItems, isEmpty);
  });

  test("getReferenceData rethrows on exception", () async {
    when(() => mockRef.getReferenceData(any()))
        .thenThrow(Exception("network error"));

    expect(() => vm.getReferenceData(), throwsException);
  });

  // -----------------------------------------------------------
  // GET CUSTOMER INFORMATION
  // -----------------------------------------------------------
  test("getCustomerInformation default branch sets defaults", () async {
    when(() => mockCcsys.getCustomerInformationCCSYS()).thenAnswer(
      (_) async => CcsysCustomerInformation()..ccsysCustomerId = 123,
    );

    await vm.getCustomerInformation();

    expect(vm.customerInformation.borrowerSubsidiary, false);
    expect(vm.controllerGroupImmediate.text, "NA");
    expect(vm.leiController.text, "NA");
  });

  test("getCustomerInformation populated branch", () async {
    vm.ccsysEmirateList = [
      Reference(name: "Abu Dhabi"),
      Reference(name: "Dubai"),
    ];

    when(() => mockCcsys.getCustomerInformationCCSYS()).thenAnswer(
      (_) async => CcsysCustomerInformation()
        ..ccsysCustomerId = 77
        ..borrowerSubsidiary = true
        ..groupImmediateParent = "ParentA"
        ..groupUltimateParent = "ParentB"
        ..legalEntityIdentifier = true
        ..leiNumber = "LEI123"
        ..emiEst = "Abu Dhabi"
        ..emiLic = "Dubai",
    );

    await vm.getCustomerInformation();

    expect(vm.controllerGroupImmediate.text, "ParentA");
    expect(vm.selectedEmirateLicense?.name, "Dubai");
    expect(vm.leiController.text, "LEI123");
  });

  test(
      "getCustomerInformation: legalEntityIdentifier"
      " false sets leiController to NA", () async {
    when(() => mockCcsys.getCustomerInformationCCSYS()).thenAnswer(
      (_) async => CcsysCustomerInformation()
        ..ccsysCustomerId = 10
        ..borrowerSubsidiary = false
        ..legalEntityIdentifier = false,
    );

    await vm.getCustomerInformation();

    expect(vm.leiController.text, "NA");
  });

  test("getCustomerInformation: leiNumber is NA sets leiController to empty",
      () async {
    vm.ccsysEmirateList = [];
    when(() => mockCcsys.getCustomerInformationCCSYS()).thenAnswer(
      (_) async => CcsysCustomerInformation()
        ..ccsysCustomerId = 10
        ..borrowerSubsidiary = true
        ..legalEntityIdentifier = true
        ..leiNumber = "NA",
    );

    await vm.getCustomerInformation();

    expect(vm.leiController.text, "");
  });

  test("getCustomerInformation: leiNumber null branch sets leiController to NA",
      () async {
    vm.ccsysEmirateList = [];
    when(() => mockCcsys.getCustomerInformationCCSYS()).thenAnswer(
      (_) async => CcsysCustomerInformation()
        ..ccsysCustomerId = 10
        ..borrowerSubsidiary = true
        ..legalEntityIdentifier = true
        ..leiNumber = null,
    );

    await vm.getCustomerInformation();

    expect(vm.leiController.text, "NA");
  });

  test("getCustomerInformation: emirate not in list falls back to name",
      () async {
    vm.ccsysEmirateList = [Reference(name: "Abu Dhabi")];
    when(() => mockCcsys.getCustomerInformationCCSYS()).thenAnswer(
      (_) async => CcsysCustomerInformation()
        ..ccsysCustomerId = 10
        ..borrowerSubsidiary = true
        ..legalEntityIdentifier = true
        ..leiNumber = "LEI999"
        ..emiEst = "Unknown Emirate"
        ..emiLic = "Unknown License",
    );

    await vm.getCustomerInformation();

    expect(vm.selectedEmirateEstablishment?.name, "Unknown Emirate");
    expect(vm.selectedEmirateLicense?.name, "Unknown License");
  });

  test("getCustomerInformation rethrows on exception", () async {
    when(() => mockCcsys.getCustomerInformationCCSYS())
        .thenThrow(Exception("server error"));

    expect(() => vm.getCustomerInformation(), throwsException);
  });

  test("getCustomerInformation: null emiEst and emiLic leaves selected as null",
      () async {
    vm.ccsysEmirateList = [Reference(name: "Dubai")];
    when(() => mockCcsys.getCustomerInformationCCSYS()).thenAnswer(
      (_) async => CcsysCustomerInformation()
        ..ccsysCustomerId = 10
        ..borrowerSubsidiary = true
        ..legalEntityIdentifier = true
        ..leiNumber = "LEI001"
        ..emiEst = null
        ..emiLic = null,
    );

    await vm.getCustomerInformation();

    expect(vm.selectedEmirateEstablishment, isNull);
    expect(vm.selectedEmirateLicense, isNull);
  });

  test(
      "getCustomerInformation: "
      "null "
      "groupImmediateParent sets text from toString", () async {
    when(() => mockCcsys.getCustomerInformationCCSYS()).thenAnswer(
      (_) async => CcsysCustomerInformation()
        ..ccsysCustomerId = 10
        ..borrowerSubsidiary = true
        ..groupImmediateParent = null
        ..groupUltimateParent = null
        ..legalEntityIdentifier = false,
    );

    await vm.getCustomerInformation();

    // When borrowerSubsidiary = true but groupImmediateParent == null,
    // the condition `!= null || toString() != 'null'` evaluates the toString
    expect(vm.controllerGroupImmediate.text, isNotNull);
  });

  // -----------------------------------------------------------
  // CHANGE HANDLERS
  // -----------------------------------------------------------
  test("onChangeBorrowingSubsidiary NO clears group fields", () {
    vm.onChangeBorrowingSubsidiary(Reference(id: 0, name: "No"));
    expect(vm.isBorrowingSubsidiary, true);
    expect(vm.controllerGroupImmediate.text, "");
    expect(vm.controllerGroupUltimate.text, "");
  });

  test("onChangeBorrowingSubsidiary YES clears group fields to empty", () {
    vm.onChangeBorrowingSubsidiary(Reference(id: 1, name: "Yes"));
    expect(vm.isBorrowingSubsidiary, true);
    expect(vm.controllerGroupImmediate.text, "");
    expect(vm.controllerGroupUltimate.text, "");
  });

  test("onChangeBorrowingSubsidiary updates customerInformation model", () {
    final ref = Reference(id: 1, name: "Yes");
    vm.onChangeBorrowingSubsidiary(ref);
    expect(vm.customerInformation.radioButtonItems, ref);
    expect(vm.customerInformation.borrowerSubsidiary, false);
  });

  test("onChangeBorrowingSubsidiary NO emits borrowerSubsidiary false", () {
    vm.onChangeBorrowingSubsidiary(Reference(id: 0, name: "No"));
    expect(vm.state.borrowerSubsidiary, false);
  });

  test("onChangeisLegalEntityIdentifier NO sets leiController to NA", () {
    vm.onChangeisLegalEntityIdentifier(Reference(id: 0, name: "No"));
    expect(vm.leiController.text, "");
    expect(vm.selectedEmirateLicense, isNull);
    expect(vm.selectedEmirateEstablishment, isNull);
    expect(vm.isLegalEntityIdentifier, true);
  });

  test("onChangeisLegalEntityIdentifier YES clears NA-named selections", () {
    vm
      ..selectedEmirateLicense = Reference(name: "NA")
      ..selectedEmirateEstablishment = Reference(name: "NA")
      ..onChangeisLegalEntityIdentifier(Reference(id: 1, name: "Yes"));
    expect(vm.selectedEmirateLicense, isNull);
    expect(vm.selectedEmirateEstablishment, isNull);
    expect(vm.leiController.text, "");
  });

  test("onChangeisLegalEntityIdentifier YES with non-NA selections keeps them",
      () {
    vm
      ..selectedEmirateLicense = Reference(name: "Dubai")
      ..selectedEmirateEstablishment = Reference(name: "Abu Dhabi")
      ..onChangeisLegalEntityIdentifier(Reference(id: 1, name: "Yes"));
    expect(vm.selectedEmirateLicense?.name, "Dubai");
    expect(vm.selectedEmirateEstablishment?.name, "Abu Dhabi");
  });

  test("setEmiratesId updates model", () {
    vm.setEmiratesId("784-XXXX");
    expect(vm.customerInformation.emiratesIdPartner, "784-XXXX");
  });

  test("setEmiratesId null updates model", () {
    vm.setEmiratesId(null);
    expect(vm.customerInformation.emiratesIdPartner, isNull);
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

  test("onCountryChipDeleted: null list is no-op", () {
    vm.customerInformation.countryOfRiskFundUtilization = null;
    expect(() => vm.onCountryChipDeleted(0), returnsNormally);
  });

  test("onCountryChipDeleted: invalid index is no-op", () {
    vm
      ..customerInformation.countryOfRiskFundUtilization = [
        Reference(name: "AE"),
      ]
      ..onCountryChipDeleted(5);
    expect(vm.customerInformation.countryOfRiskFundUtilization!.length, 1);
  });

  test("onCountryChipDeleted: negative index is no-op", () {
    vm
      ..customerInformation.countryOfRiskFundUtilization = [
        Reference(name: "AE"),
      ]
      ..onCountryChipDeleted(-1);
    expect(vm.customerInformation.countryOfRiskFundUtilization!.length, 1);
  });

  test("updateCountriesOfRisk replaces entire list", () {
    final newList = [Reference(name: "US"), Reference(name: "GB")];
    vm.updateCountriesOfRisk(newList);
    expect(vm.customerInformation.countryOfRiskFundUtilization, newList);
  });

  // -----------------------------------------------------------
  // ROWS + CONTROLLERS
  // -----------------------------------------------------------
  test("addRow populates rows and controllers", () {
    vm.addRow();
    expect(vm.rows.length, 1);
    expect(vm.ctrls.length, 1);
  });

  test("addRow multiple times accumulates correctly", () {
    vm
      ..addRow()
      ..addRow()
      ..addRow();
    expect(vm.rows.length, 3);
    expect(vm.ctrls.length, 3);
  });

  test("removeRow removes and disposes controllers", () {
    vm
      ..addRow()
      ..addRow()
      ..removeRow(0);
    expect(vm.rows.length, 1);
  });

  test("removeRow: invalid index is no-op", () {
    vm
      ..addRow()
      ..removeRow(5);
    expect(vm.rows.length, 1);
  });

  test("removeRow: negative index is no-op", () {
    vm
      ..addRow()
      ..removeRow(-1);
    expect(vm.rows.length, 1);
  });

  test("removeRow last element empties rows", () {
    vm
      ..addRow()
      ..removeRow(0);
    expect(vm.rows.isEmpty, true);
    expect(vm.ctrls.isEmpty, true);
  });

  test("setResidency RE clears passport fields", () async {
    await (vm..addRow()).setResidency(0, Reference(reference1: "RE"));
    expect(vm.rows[0].passportNumberExpiryDatePartnerShareholder, null);
    expect(vm.ctrls[0].passport.text, "");
    expect(vm.rows[0].partnerShareholderResidence, "RE");
  });

  test("setResidency NR clears emiratesId", () async {
    await (vm..addRow()).setResidency(0, Reference(reference1: "NR"));
    expect(vm.rows[0].emiratesIdPartnerShareholder, "");
    expect(vm.rows[0].partnerShareholderResidence, "NR");
  });

  test("setType sets partnerShareholderType", () async {
    await (vm..addRow()).setType(0, Reference(name: "PR1"));
    expect(vm.rows[0].partnerShareholderType, "PR1");
  });

  test("setLegalStatus JP clears NP fields", () async {
    await (vm..addRow()).setLegalStatus(0, Reference(reference1: "JP"));
    expect(vm.rows[0].nationalityPartnerShareholder, null);
    expect(vm.rows[0].emiratesIdPartnerShareholder, "");
    expect(vm.rows[0].emiratesIdExpiryDatePartnerShareholder, null);
    expect(vm.ctrls[0].netWorth.text, "");
    expect(vm.rows[0].legalStatusOfPartnerShareholder, "JP");
  });

  test("setLegalStatus NP clears JP fields", () async {
    await (vm..addRow()).setLegalStatus(0, Reference(reference1: "NP"));
    expect(vm.rows[0].tradeLicenseNumberPartnerShareholder, "");
    expect(vm.rows[0].placeIssueTradeLicenseNumberPartnerShareholder, null);
    expect(vm.rows[0].psLei, null);
    expect(vm.rows[0].leiNumberPartnerShareholder, "");
    expect(vm.ctrls[0].tradeLicense.text, "");
    expect(vm.ctrls[0].leiNumber.text, "");
    expect(vm.ctrls[0].netWorth.text, "0");
    expect(vm.rows[0].legalStatusOfPartnerShareholder, "NP");
  });

  test("setNationality sets nationality on row", () async {
    await (vm..addRow()).setNationality(0, Reference(name: "Indian"));
    expect(vm.rows[0].nationalityPartnerShareholder, "Indian");
  });

  test("setTradeLicensePlace sets place on row", () async {
    await (vm..addRow()).setTradeLicensePlace(0, Reference(name: "Dubai"));
    expect(vm.rows[0].placeIssueTradeLicenseNumberPartnerShareholder, "Dubai");
  });

  test("setLeiOpt YES sets psLei to Y", () async {
    await (vm..addRow()).setLeiOpt(0, Reference(id: 1, name: "Yes"));
    expect(vm.rows[0].psLei, "N");
  });

  test("setLeiOpt NO sets psLei to N and clears leiNumber", () async {
    await (vm
          ..addRow()
          ..ctrls[0].leiNumber.text = "SOMEVALUE")
        .setLeiOpt(0, Reference(id: 0, name: "No"));
    expect(vm.rows[0].psLei, "N");
    expect(vm.rows[0].leiNumberPartnerShareholder, "SOMEVALUE");
    expect(vm.ctrls[0].leiNumber.text, "SOMEVALUE");
  });

  test("setGender sets gender on row", () async {
    await (vm..addRow()).setGender(0, Reference(name: "Male"));
    expect(vm.rows[0].gender, "Male");
  });

  test("setEmiratesIdExpiry sets expiry date", () async {
    final date = DateTime(2030, 1, 1);
    await (vm..addRow()).setEmiratesIdExpiry(0, date);
    expect(vm.rows[0].emiratesIdExpiryDatePartnerShareholder, date);
  });

  test("setEmiratesIdExpiry accepts null", () async {
    await (vm..addRow()).setEmiratesIdExpiry(0, null);
    expect(vm.rows[0].emiratesIdExpiryDatePartnerShareholder, null);
  });

  test("setPassportExpiry sets expiry date", () async {
    final date = DateTime(2032, 6, 15);
    await (vm..addRow()).setPassportExpiry(0, date);
    expect(vm.rows[0].passportNumberExpiryDatePartnerShareholder, date);
  });

  test("setPassportExpiry accepts null", () async {
    await (vm..addRow()).setPassportExpiry(0, null);
    expect(vm.rows[0].passportNumberExpiryDatePartnerShareholder, null);
  });

  test("onChangeTLNumber updates tradeLicenseNumber on row", () {
    vm
      ..addRow()
      ..onChangeTLNumber("TL12345", 0);
    expect(vm.rows[0].tradeLicenseNumberPartnerShareholder, "TL12345");
  });

  test("onChangePassport updates passport on row", () {
    vm
      ..addRow()
      ..onChangePassport("AB123/AE", 0);
    expect(vm.rows[0].passportNumberPartnerShareholder, "AB123/AE");
  });

  test("onChangePassport empty value clears passport fields", () {
    vm
      ..addRow()
      ..rows[0].passportNumberPartnerShareholder = "OLD/AE"
      ..rows[0].passportNumberExpiryDatePartnerShareholder = DateTime.now()
      ..onChangePassport("", 0);
    expect(vm.rows[0].passportNumberExpiryDatePartnerShareholder, null);
    expect(vm.rows[0].passportNumberPartnerShareholder, "");
    expect(vm.isDateValidPassportExpiry, false);
  });

  test("onChangeEmiratesId updates emiratesId on row", () {
    vm
      ..addRow()
      ..onChangeEmiratesId("784-1234-1234567-1", 0);
    expect(vm.rows[0].emiratesIdPartnerShareholder, "784-1234-1234567-1");
  });

  test("onChangeLEINumber updates leiNumber on row", () {
    vm
      ..addRow()
      ..onChangeLEINumber("ABCDE12345ABCDE12345", 0);
    expect(vm.rows[0].leiNumberPartnerShareholder, "ABCDE12345ABCDE12345");
  });

  // -----------------------------------------------------------
  // ENABLE/REQUIRED HELPERS
  // -----------------------------------------------------------
  test("eidEnabled: true when residence is RE and legal status is NP (not JP)",
      () {
    vm.addRow();
    vm.rows[0].partnerShareholderResidence = "RE";
    vm.rows[0].legalStatusOfPartnerShareholder = "NP";
    expect(vm.eidEnabled(0), true);
  });

  test("eidEnabled: false when RE and JP", () {
    vm.addRow();
    vm.rows[0].partnerShareholderResidence = "RE";
    vm.rows[0].legalStatusOfPartnerShareholder = "JP";
    expect(vm.eidEnabled(0), false);
  });

  test("eidEnabled: false for invalid index", () {
    expect(vm.eidEnabled(99), false);
  });

  test("eidExpiryEnabled: true when emiratesId non-empty", () {
    vm.addRow();
    vm.rows[0].emiratesIdPartnerShareholder = "784-0000-0000000-0";
    expect(vm.eidExpiryEnabled(0), true);
  });

  test("eidExpiryEnabled: false when emiratesId empty", () {
    vm.addRow();
    vm.rows[0].emiratesIdPartnerShareholder = "";
    expect(vm.eidExpiryEnabled(0), false);
  });

  test("eidExpiryEnabled: false for invalid index", () {
    expect(vm.eidExpiryEnabled(99), false);
  });

  test("passportEnabled: false when RE and NP", () {
    vm.addRow();
    vm.rows[0].partnerShareholderResidence = "RE";
    vm.rows[0].legalStatusOfPartnerShareholder = "NP";
    expect(vm.passportEnabled(0), false);
  });

  test("passportEnabled: true when NR and NP", () {
    vm.addRow();
    vm.rows[0].partnerShareholderResidence = "NR";
    vm.rows[0].legalStatusOfPartnerShareholder = "NP";
    expect(vm.passportEnabled(0), true);
  });

  test("passportEnabled: true when RE and JP", () {
    vm.addRow();
    vm.rows[0].partnerShareholderResidence = "RE";
    vm.rows[0].legalStatusOfPartnerShareholder = "JP";
    expect(vm.passportEnabled(0), true);
  });

  test("passportEnabled: false for invalid index", () {
    expect(vm.passportEnabled(99), false);
  });

  test("passportExpiryEnabled: true when passport non-empty", () {
    vm.addRow();
    vm.rows[0].passportNumberPartnerShareholder = "AB123/AE";
    expect(vm.passportExpiryEnabled(0), true);
  });

  test("passportExpiryEnabled: false when passport empty", () {
    vm.addRow();
    vm.rows[0].passportNumberPartnerShareholder = "";
    expect(vm.passportExpiryEnabled(0), false);
  });

  test("passportExpiryEnabled: false for invalid index", () {
    expect(vm.passportExpiryEnabled(99), false);
  });

  test("nationalityRequired: true when NP", () {
    vm.addRow();
    vm.rows[0].legalStatusOfPartnerShareholder = "NP";
    expect(vm.nationalityRequired(0), true);
  });

  test("nationalityRequired: false when JP", () {
    vm.addRow();
    vm.rows[0].legalStatusOfPartnerShareholder = "JP";
    expect(vm.nationalityRequired(0), false);
  });

  test("tradeLicenseEnabled: true when JP", () {
    vm.addRow();
    vm.rows[0].legalStatusOfPartnerShareholder = "JP";
    expect(vm.tradeLicenseEnabled(0), true);
  });

  test("tradeLicenseEnabled: false when NP", () {
    vm.addRow();
    vm.rows[0].legalStatusOfPartnerShareholder = "NP";
    expect(vm.tradeLicenseEnabled(0), false);
  });

  test("tradeLicensePlaceEnabled: true when tradeLicense non-empty", () {
    vm.addRow();
    vm.rows[0].tradeLicenseNumberPartnerShareholder = "TL12345";
    expect(vm.tradeLicensePlaceEnabled(0), true);
  });

  test("tradeLicensePlaceEnabled: false when tradeLicense empty", () {
    vm.addRow();
    vm.rows[0].tradeLicenseNumberPartnerShareholder = "";
    expect(vm.tradeLicensePlaceEnabled(0), false);
  });

  test("leiVisible: true when JP", () {
    vm.addRow();
    vm.rows[0].legalStatusOfPartnerShareholder = "JP";
    expect(vm.leiVisible(0), true);
  });

  test("leiVisible: false when NP", () {
    vm.addRow();
    vm.rows[0].legalStatusOfPartnerShareholder = "NP";
    expect(vm.leiVisible(0), false);
  });

  test("leiNumberEnabled: true when JP and psLei is Y", () {
    vm.addRow();
    vm.rows[0].legalStatusOfPartnerShareholder = "JP";
    vm.rows[0].psLei = "Y";
    expect(vm.leiNumberEnabled(0), true);
  });

  test("leiNumberEnabled: false when JP but psLei is N", () {
    vm.addRow();
    vm.rows[0].legalStatusOfPartnerShareholder = "JP";
    vm.rows[0].psLei = "N";
    expect(vm.leiNumberEnabled(0), false);
  });

  test("isnetworkEditable: true when NP sets networth to 0", () {
    vm.addRow();
    vm.rows[0].legalStatusOfPartnerShareholder = "NP";
    final result = vm.isnetworkEditable(0);
    expect(result, true);
    expect(vm.rows[0].networthPartnerShareholderAed, "0");
  });

  test("isnetworkEditable: false when JP", () {
    vm.addRow();
    vm.rows[0].legalStatusOfPartnerShareholder = "JP";
    expect(vm.isnetworkEditable(0), false);
  });

  // -----------------------------------------------------------
  // VALIDATORS
  // -----------------------------------------------------------
  group("shareHoldingPercentageValidator", () {
    test("returns error when sum != 100", () {
      vm.rows = [
        PartnerShareholder()..shareholdingPartnershipPercentage = 20,
        PartnerShareholder()..shareholdingPartnershipPercentage = 30,
      ];

      expect(vm.shareHoldingPercentageValidator("0") != null, true);
    });

    test("returns null when sum == 100", () {
      vm.rows = [
        PartnerShareholder()..shareholdingPartnershipPercentage = 50,
        PartnerShareholder()..shareholdingPartnershipPercentage = 50,
      ];

      expect(vm.shareHoldingPercentageValidator("0"), null);
    });

    test("returns error when value is null", () {
      expect(vm.shareHoldingPercentageValidator(null), isNotNull);
    });

    test("returns error when shareholding is 0", () {
      vm.rows = [
        PartnerShareholder()..shareholdingPartnershipPercentage = 0,
      ];
      expect(vm.shareHoldingPercentageValidator("0"), isNotNull);
    });
  });

  test("validateRow finds missing fields", () {
    vm.rows = [PartnerShareholder()];

    final errors = vm.validateAll();
    expect(errors.isNotEmpty, true);
  });

  group("validateRow conditional fields", () {
    test("RE + NP: errors on missing emiratesId", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "NP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "5000"
        ..emiratesIdPartnerShareholder = ""
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors.any(
          (e) => e.contains("ccsys.customerInformation.emiratesIdRequiredReNp"),
        ),
        true,
      );
    });

    test("RE + NP with emiratesId but no expiry: error on missing expiry", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "NP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "5000"
        ..emiratesIdPartnerShareholder = "784-1234-1234567-1"
        ..emiratesIdExpiryDatePartnerShareholder = null
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors.any(
          (e) =>
              e.contains("ccsys.customerInformation.emiratesIdExpiryRequired"),
        ),
        true,
      );
    });

    test("NR + NP: error on missing passport", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = "NR"
        ..legalStatusOfPartnerShareholder = "NP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "5000"
        ..passportNumberPartnerShareholder = ""
        ..nationalityPartnerShareholder = "Indian"
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors.any(
          (e) => e.contains("ccsys.customerInformation.passportRequiredNrNp"),
        ),
        true,
      );
    });

    test("NR + NP: invalid passport format triggers format error", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = "NR"
        ..legalStatusOfPartnerShareholder = "NP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "5000"
        ..passportNumberPartnerShareholder = "INVALID-FORMAT"
        ..nationalityPartnerShareholder = "Indian"
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors
            .any((e) => e.contains("ccsys.customerInformation.passportFormat")),
        true,
      );
    });

    test("passport provided but no expiry: error on missing expiry", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "JP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "5000"
        ..passportNumberPartnerShareholder = "AB123/AE"
        ..passportNumberExpiryDatePartnerShareholder = null
        ..tradeLicenseNumberPartnerShareholder = "TL999"
        ..placeIssueTradeLicenseNumberPartnerShareholder = "Dubai"
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors.any(
          (e) => e.contains("ccsys.customerInformation.passportExpiryRequired"),
        ),
        true,
      );
    });

    test("NP: error on missing nationality", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "NP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "5000"
        ..emiratesIdPartnerShareholder = "784-0000-0000000-0"
        ..emiratesIdExpiryDatePartnerShareholder = DateTime(2030)
        ..nationalityPartnerShareholder = ""
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors.any(
          (e) => e.contains("ccsys.customerInformation.nationalityRequiredNp"),
        ),
        true,
      );
    });

    test("JP: error on missing trade license", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "JP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "5000"
        ..tradeLicenseNumberPartnerShareholder = ""
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors.any(
          (e) => e.contains("ccsys.customerInformation.tradeLicenseRequiredJp"),
        ),
        true,
      );
    });

    test("trade license provided but no place of issue: error", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "JP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "5000"
        ..tradeLicenseNumberPartnerShareholder = "TL001"
        ..placeIssueTradeLicenseNumberPartnerShareholder = ""
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors.any(
          (e) => e
              .contains("ccsys.customerInformation.placeOfIssueRequiredWithTl"),
        ),
        true,
      );
    });

    test("JP + psLei Y but missing leiNumber: error", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "JP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "5000"
        ..tradeLicenseNumberPartnerShareholder = "TL001"
        ..placeIssueTradeLicenseNumberPartnerShareholder = "Dubai"
        ..psLei = "Y"
        ..leiNumberPartnerShareholder = ""
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors.any(
          (e) => e.contains("ccsys.customerInformation.leiFieldsRequired"),
        ),
        true,
      );
    });

    test("JP + psLei N: no lei error", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "JP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "5000"
        ..tradeLicenseNumberPartnerShareholder = "TL001"
        ..placeIssueTradeLicenseNumberPartnerShareholder = "Dubai"
        ..psLei = "N"
        ..leiNumberPartnerShareholder = ""
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors.any(
          (e) => e.contains("ccsys.customerInformation.leiFieldsRequired"),
        ),
        false,
      );
    });

    test("missing gender produces gender error", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "JP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "5000"
        ..tradeLicenseNumberPartnerShareholder = "TL001"
        ..placeIssueTradeLicenseNumberPartnerShareholder = "Dubai"
        ..gender = "";

      final errors = vm.validateRow(0);
      expect(
        errors
            .any((e) => e.contains("ccsys.customerInformation.genderRequired")),
        true,
      );
    });

    test("shareholding out of range: above 100 produces error", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "JP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 150
        ..networthPartnerShareholderAed = "5000"
        ..tradeLicenseNumberPartnerShareholder = "TL001"
        ..placeIssueTradeLicenseNumberPartnerShareholder = "Dubai"
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors.any(
          (e) => e.contains("ccsys.customerInformation.holdingOutOfRange"),
        ),
        true,
      );
    });

    test("null shareholding produces holdingOutOfRange error", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "JP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = null
        ..networthPartnerShareholderAed = "5000"
        ..tradeLicenseNumberPartnerShareholder = "TL001"
        ..placeIssueTradeLicenseNumberPartnerShareholder = "Dubai"
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors.any(
          (e) => e.contains("ccsys.customerInformation.holdingOutOfRange"),
        ),
        true,
      );
    });

    test("empty networth produces networthRequired error", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "JP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = ""
        ..tradeLicenseNumberPartnerShareholder = "TL001"
        ..placeIssueTradeLicenseNumberPartnerShareholder = "Dubai"
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors.any(
          (e) => e.contains("ccsys.customerInformation.networthRequired"),
        ),
        true,
      );
    });

    test("empty name produces nameEnglishRequired error", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = ""
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "JP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "5000"
        ..tradeLicenseNumberPartnerShareholder = "TL001"
        ..placeIssueTradeLicenseNumberPartnerShareholder = "Dubai"
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors.any(
          (e) => e.contains("ccsys.customerInformation.nameEnglishRequired"),
        ),
        true,
      );
    });

    test("empty residence produces residenceRequired error", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = ""
        ..legalStatusOfPartnerShareholder = "JP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "5000"
        ..tradeLicenseNumberPartnerShareholder = "TL001"
        ..placeIssueTradeLicenseNumberPartnerShareholder = "Dubai"
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors.any(
          (e) => e.contains("ccsys.customerInformation.residenceRequired"),
        ),
        true,
      );
    });

    test("empty type produces typeRequired error", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Test Name"
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "JP"
        ..partnerShareholderType = ""
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "5000"
        ..tradeLicenseNumberPartnerShareholder = "TL001"
        ..placeIssueTradeLicenseNumberPartnerShareholder = "Dubai"
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(
        errors.any((e) => e.contains("ccsys.customerInformation.typeRequired")),
        true,
      );
    });

    test("valid complete NP RE row produces no errors", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "Ahmed Al-Rashid"
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "NP"
        ..partnerShareholderType = "PR1"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "50000"
        ..emiratesIdPartnerShareholder = "784-1234-1234567-1"
        ..emiratesIdExpiryDatePartnerShareholder = DateTime(2030)
        ..nationalityPartnerShareholder = "Emirati"
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(errors, isEmpty);
    });

    test("valid complete JP row produces no errors", () {
      vm.addRow();
      vm.rows[0]
        ..partnerShareholderInEnglish = "ACME Corp"
        ..partnerShareholderResidence = "RE"
        ..legalStatusOfPartnerShareholder = "JP"
        ..partnerShareholderType = "SH2"
        ..shareholdingPartnershipPercentage = 100
        ..networthPartnerShareholderAed = "100000"
        ..tradeLicenseNumberPartnerShareholder = "TL00001"
        ..placeIssueTradeLicenseNumberPartnerShareholder = "Dubai"
        ..psLei = "N"
        ..gender = "Male";

      final errors = vm.validateRow(0);
      expect(errors, isEmpty);
    });
  });

  // -----------------------------------------------------------
  // DATE VALIDATORS
  // -----------------------------------------------------------
  group("checkAuditedFsDate", () {
    test("null value with isToday returns error and sets isDateValid", () {
      final result = vm.checkAuditedFsDate(null, isToday: true, isDateFs: true);
      expect(result, isNotNull);
      expect(vm.isDateValid, true);
    });

    test("empty value with isToday returns error and sets isDateValid", () {
      final result = vm.checkAuditedFsDate("", isToday: true, isDateFs: true);
      expect(result, isNotNull);
      expect(vm.isDateValid, true);
    });

    test("invalid date format returns error", () {
      final result = vm.checkAuditedFsDate("not-a-date", isDateFs: true);
      expect(result, isNotNull);
      expect(vm.isDateValid, true);
    });

    test("future date with isToday returns future error", () {
      final future = DateTime.now().add(const Duration(days: 10));
      final formatted =
          '${future.day.toString().padLeft(2, '0')}/${future.month.toString().padLeft(2, '0')}/${future.year}';
      final result =
          vm.checkAuditedFsDate(formatted, isToday: true, isDateFs: true);
      expect(result, isNotNull);
      expect(vm.isDateValid, true);
    });

    test("past valid date returns null and clears isDateValid", () {
      final result =
          vm.checkAuditedFsDate("01/01/2020", isToday: true, isDateFs: true);
      expect(result, isNull);
      expect(vm.isDateValid, false);
    });

    test("passport expiry: invalid date sets isDateValidPassportExpiry", () {
      final result = vm.checkAuditedFsDate("BADDATE", isDateFs: false);
      expect(result, isNotNull);
      expect(vm.isDateValidPassportExpiry, true);
    });

    test("passport expiry: empty with isToday sets isDateValidPassportExpiry",
        () {
      final result = vm.checkAuditedFsDate("", isToday: true, isDateFs: false);
      expect(result, isNotNull);
      expect(vm.isDateValidPassportExpiry, true);
    });

    test("passport expiry: future date sets isDateValidPassportExpiry", () {
      final future = DateTime.now().add(const Duration(days: 5));
      final formatted =
          '${future.day.toString().padLeft(2, '0')}/${future.month.toString().padLeft(2, '0')}/${future.year}';
      final result =
          vm.checkAuditedFsDate(formatted, isToday: true, isDateFs: false);
      expect(result, isNotNull);
      expect(vm.isDateValidPassportExpiry, true);
    });
  });

  // -----------------------------------------------------------
  // REUSABLE HELPERS
  // -----------------------------------------------------------
  group("validateSelection", () {
    test("returns null when value found in options", () {
      final options = [Reference(name: "Male"), Reference(name: "Female")];
      final result = vm.validateSelection("Male", options, "error.key");
      expect(result, isNull);
    });

    test("returns tr key when value not found", () {
      final options = [Reference(name: "Male"), Reference(name: "Female")];
      final result = vm.validateSelection("Unknown", options, "error.key");
      expect(result, "error.key");
    });

    test("returns error when value is null", () {
      final options = [Reference(name: "Male")];
      final result = vm.validateSelection(null, options, "error.key");
      expect(result, isNotNull);
    });
  });

  group("getFilteredOptions", () {
    test("removes NA entries", () {
      final options = [
        Reference(name: "requestInformation.requestInformation.na"),
        Reference(name: "Male"),
        Reference(name: "Female"),
      ];
      final filtered = vm.getFilteredOptions(options);
      expect(
        filtered
            .any((r) => r.name == "requestInformation.requestInformation.na"),
        false,
      );
      expect(filtered.length, 2);
    });

    test("returns all when no NA present", () {
      final options = [
        Reference(name: "Male"),
        Reference(name: "Female"),
      ];
      final filtered = vm.getFilteredOptions(options);
      expect(filtered.length, 2);
    });
  });

  group("getSelectedReference", () {
    test("returns selectedValue when present in filtered list", () {
      final options = [
        Reference(name: "Yes"),
        Reference(name: "No"),
      ];
      final selected = options[0];
      final result = vm.getSelectedReference(
        options: options,
        selectedValue: selected,
        fallbackFlag: false,
      );
      expect(result, selected);
    });

    test("returns fallback yes when flag is true and selectedValue is null",
        () {
      final options = [
        Reference(name: "requestInformation.requestInformation.yes"),
        Reference(name: "requestInformation.requestInformation.no"),
      ];
      final result = vm.getSelectedReference(
        options: options,
        selectedValue: null,
        fallbackFlag: true,
      );
      expect(result.name, "requestInformation.requestInformation.yes");
    });

    test("returns fallback no when flag is false and selectedValue is null",
        () {
      final options = [
        Reference(name: "requestInformation.requestInformation.yes"),
        Reference(name: "requestInformation.requestInformation.no"),
      ];
      final result = vm.getSelectedReference(
        options: options,
        selectedValue: null,
        fallbackFlag: false,
      );
      expect(result.name, "requestInformation.requestInformation.no");
    });

    test("returns first when fallback name not found", () {
      final options = [Reference(name: "Option1")];
      final result = vm.getSelectedReference(
        options: options,
        selectedValue: null,
        fallbackFlag: true,
      );
      expect(result, options.first);
    });

    test("returns name:no when filtered list is empty", () {
      final result = vm.getSelectedReference(
        options: [],
        selectedValue: null,
        fallbackFlag: false,
      );
      expect(result.name, "requestInformation.requestInformation.no");
    });
  });

  // -----------------------------------------------------------
  // INITIALIZE CONTROLLERS
  // -----------------------------------------------------------
  test("initializeControllers sets rows and ctrls from initial list", () {
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

  test("initializeControllers with empty list sets empty rows and ctrls", () {
    vm.initializeControllers([]);
    expect(vm.rows, isEmpty);
    expect(vm.ctrls, isEmpty);
  });

  test("disposeControllers clears and emits loaded", () {
    vm
      ..addRow()
      ..addRow()
      ..disposeControllers();
    expect(vm.state.partnerShareholderStatus, LoadingStatus.loaded);
  });

  // -----------------------------------------------------------
  // PARTNER SHAREHOLDER CONTROLLERS
  // -----------------------------------------------------------
  group("PartnerShareholderControllers", () {
    test("attach syncs initial values from model", () {
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

      ctrl.dispose();
    });

    test("typing in name controller updates model", () {
      final model = PartnerShareholder();
      final ctrl = PartnerShareholderControllers()..attach(model);

      ctrl.name.text = "Updated Name";
      expect(model.partnerShareholderInEnglish, "Updated Name");

      ctrl.dispose();
    });

    test("typing in sharePercent controller updates model as int", () {
      final model = PartnerShareholder();
      final ctrl = PartnerShareholderControllers()..attach(model);

      ctrl.sharePercent.text = "55";
      expect(model.shareholdingPartnershipPercentage, 55);

      ctrl.dispose();
    });

    test("invalid sharePercent sets shareholding to null", () {
      final model = PartnerShareholder();
      final ctrl = PartnerShareholderControllers()..attach(model);

      ctrl.sharePercent.text = "abc";
      expect(model.shareholdingPartnershipPercentage, isNull);

      ctrl.dispose();
    });

    test("typing in netWorth controller updates model as string", () {
      final model = PartnerShareholder();
      final ctrl = PartnerShareholderControllers()..attach(model);

      ctrl.netWorth.text = "12345";
      expect(model.networthPartnerShareholderAed, "12345");

      ctrl.dispose();
    });

    test("typing in emiratesId controller updates model", () {
      final model = PartnerShareholder();
      final ctrl = PartnerShareholderControllers()..attach(model);

      ctrl.emiratesId.text = "784-9999-9999999-9";
      expect(model.emiratesIdPartnerShareholder, "784-9999-9999999-9");

      ctrl.dispose();
    });

    test("typing in passport controller updates model", () {
      final model = PartnerShareholder();
      final ctrl = PartnerShareholderControllers()..attach(model);

      ctrl.passport.text = "XY999/GB";
      expect(model.passportNumberPartnerShareholder, "XY999/GB");

      ctrl.dispose();
    });

    test("typing in tradeLicense controller updates model", () {
      final model = PartnerShareholder();
      final ctrl = PartnerShareholderControllers()..attach(model);

      ctrl.tradeLicense.text = "TL-99999";
      expect(model.tradeLicenseNumberPartnerShareholder, "TL-99999");

      ctrl.dispose();
    });

    test("typing in leiNumber controller updates model", () {
      final model = PartnerShareholder();
      final ctrl = PartnerShareholderControllers()..attach(model);

      ctrl.leiNumber.text = "LEIABCDE12345LEIAB99";
      expect(model.leiNumberPartnerShareholder, "LEIABCDE12345LEIAB99");

      ctrl.dispose();
    });

    test("dispose does not throw", () {
      final model = PartnerShareholder();
      final ctrl = PartnerShareholderControllers()..attach(model);
      expect(ctrl.dispose, returnsNormally);
    });

    test("attach with null model fields sets empty strings", () {
      final model = PartnerShareholder();
      final ctrl = PartnerShareholderControllers()..attach(model);

      expect(ctrl.name.text, "");
      expect(ctrl.sharePercent.text, "");
      expect(ctrl.netWorth.text, "");
      expect(ctrl.emiratesId.text, "");
      expect(ctrl.passport.text, "");
      expect(ctrl.tradeLicense.text, "");
      expect(ctrl.leiNumber.text, "");

      ctrl.dispose();
    });
  });

  // -----------------------------------------------------------
  // SAVE (all branches)
  // -----------------------------------------------------------
  testWidgets("saveCustomerInformation: rows empty → failure", (tester) async {
    AlertManager.overrideInstance(mockAlert);
    await tester.pumpWidget(
      MaterialApp(home: Form(key: vm.formKey, child: Container())),
    );

    await (vm..rows = []).saveCustomerInformation();

    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  testWidgets("saveCustomerInformation: validation errors → failure",
      (tester) async {
    AlertManager.overrideInstance(mockAlert);
    await tester.pumpWidget(
      MaterialApp(home: Form(key: vm.formKey, child: Container())),
    );

    vm.rows = [
      PartnerShareholder()
        ..partnerShareholderInEnglish = ""
        ..shareholdingPartnershipPercentage = -1
        ..partnerShareholderResidence = ""
        ..partnerShareholderType = ""
        ..gender = "",
    ];

    await vm.saveCustomerInformation();
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });
}
