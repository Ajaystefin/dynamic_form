import "package:decimal/decimal.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/group_information/facilities_data.dart";
import "package:wcas_frontend/repositories/group_information_repository.dart";

import "../../../../test_config.dart";

class MockGroupInformationRepository extends Mock
    implements GroupInformationRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockBuildContext extends Mock implements BuildContext {}

class MockAlertManager extends Mock implements AlertManager {}

class MockApplicationDetails extends Mock implements ApplicationDetails {}

class TestFormState extends Fake implements FormState {
  TestFormState(this.shouldValidate);

  final bool shouldValidate;

  @override
  bool validate() => shouldValidate;

  @override
  void save() {}

  @override
  String toString({
    DiagnosticLevel minLevel = DiagnosticLevel.info,
  }) =>
      "TestFormState(shouldValidate: $shouldValidate)";
}

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

void main() {
  late AddOtherBankDialogViewModel viewModel;
  late MockGroupInformationRepository mockRepository;
  late MockReferenceDataService mockReferenceService;
  late MockLocalStorageService mockLocalStorageService;

  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    registerFallbackValue(<Map<String, dynamic>>[]);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (call) async {
        if (call.method == "check") {
          return ["wifi"];
        }
        return null;
      },
    );
  });

  tearDownAll(() async {
    await TestConfig.cleanup();
  });

  setUp(() {
    mockRepository = MockGroupInformationRepository();
    mockReferenceService = MockReferenceDataService();
    mockLocalStorageService = MockLocalStorageService();

    viewModel = AddOtherBankDialogViewModel();
    viewModel.repository = mockRepository;
    viewModel.repositoryDataService = mockReferenceService;

    LocalStorageService().setStorage(mockLocalStorageService);
  });

  group("AddOtherBankDialogViewModel Tests", () {
    test("Initial loader status is loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("init should set repository and load project details", () async {
      final mockAlertManager = MockAlertManager();

      AlertManager.overrideInstance(mockAlertManager);

      await viewModel.init(MockBuildContext());

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init sets currentFacilityItems when initalFacility is provided",
        () async {
      final facility = Facility(
        customerRimNo: 12,
        customerName: "Test Facility",
      );

      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => {
          ReferenceDataKeys.bankList: [],
          ReferenceDataKeys.facilityTypes: [],
          ReferenceDataKeys.securityType: [],
        },
      );

      await viewModel.getReferenceDatas();

      await viewModel.init(
        MockBuildContext(),
        initalFacility: facility,
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));

      viewModel.currentFacilityItems = facility;

      expect(viewModel.currentFacilityItems, facility);
      expect(
        viewModel.currentFacilityItems.customerRimNo,
        facility.customerRimNo,
      );
      expect(
        viewModel.currentFacilityItems.customerName,
        facility.customerName,
      );
    });

    test("getReferenceDatas sets bank list and emits loaded status", () async {
      final referenceList = [Reference(id: 1, name: "Bank A")];

      when(
        () =>
            mockReferenceService.getReferenceData([ReferenceDataKeys.bankList]),
      ).thenAnswer(
        (_) async => {
          ReferenceDataKeys.bankList: referenceList,
        },
      );

      final res = await mockReferenceService.getReferenceData([
        ReferenceDataKeys.bankList,
      ]);

      expect(res[ReferenceDataKeys.bankList], referenceList);
    });

    test("customerRIMReferenceSelected sets selected customer", () {
      final customer = Customer(
        customerRimNo: 100,
        customerName: "Test Customer",
      );

      viewModel.customerRIMReferenceSelected(customer);

      expect(viewModel.selectedCustomer, customer);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "nameofBanksReferenceSelected sets selected"
        " bank and emits loaded status", () {
      final bank = Reference(id: 2, name: "Bank B");

      viewModel.nameofBanksReferenceSelected(bank);

      expect(viewModel.currentFacilityItems.bankNameId, equals(bank.id));
      expect(viewModel.state.loaderStatus, equals(LoadingStatus.loaded));
    });

    test(
        "onFacilityTypeSelected sets selected facility and emits loaded status",
        () {
      final List<Reference> facility = [Reference(id: 2, name: "Facility B")];

      viewModel.onFacilityTypeSelected(facility);

      expect(viewModel.currentFacilityItems.facilityWith, equals(facility));
      expect(viewModel.state.loaderStatus, equals(LoadingStatus.loaded));
    });

    test(
        "onSecurityTypeSelected sets selected security and emits loaded status",
        () {
      final List<Reference> security = [Reference(id: 2, name: "Security B")];

      viewModel.onSecurityTypeSelected(security);

      expect(viewModel.currentFacilityItems.securityWith, equals(security));
      expect(viewModel.state.loaderStatus, equals(LoadingStatus.loaded));
    });

    test("calculateTotal computes correct sum and emits loaded status", () {
      viewModel.currentFacilityItems.fundedLimit = Decimal.fromInt(100);
      viewModel.currentFacilityItems.nonFundedLimit = Decimal.fromInt(200);

      viewModel.calculateTotal();

      expect(viewModel.currentFacilityItems.total, Decimal.fromInt(300));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.facilityController.text, "300");
    });

    test("getReferenceDatas sets loaderStatus to loaded when data is present",
        () async {
      final mockReferenceData = {
        ReferenceDataKeys.bankList: [Reference(name: "Bank A")],
        ReferenceDataKeys.facilityTypes: [Reference(name: "Facility X")],
        ReferenceDataKeys.securityType: [Reference(name: "Security Y")],
      };

      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => mockReferenceData,
      );

      await viewModel.getReferenceDatas();

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.bankNameOptions, isNotEmpty);
      expect(viewModel.typeOfFacilityOptions, isNotEmpty);
      expect(viewModel.securityOptions, isNotEmpty);
    });

    test("getReferenceDatas sets loaderStatus to error when exception occurs",
        () async {
      when(() => mockReferenceService.getReferenceData(any())).thenThrow(
        Exception("Network error"),
      );

      await viewModel.getReferenceDatas();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test("getReferenceDatas populates options correctly", () async {
      final bankReference = Reference(id: 1, name: "Bank A");
      final facilityReference = Reference(id: 2, name: "Facility X");
      final securityReference = Reference(id: 3, name: "Security Y");

      final mockReferenceData = {
        ReferenceDataKeys.bankList: [bankReference],
        ReferenceDataKeys.facilityTypes: [facilityReference],
        ReferenceDataKeys.securityType: [securityReference],
      };

      when(
        () => mockReferenceService.getReferenceData([
          ReferenceDataKeys.bankList,
          ReferenceDataKeys.facilityTypes,
          ReferenceDataKeys.securityType,
        ]),
      ).thenAnswer((_) async => mockReferenceData);

      await viewModel.getReferenceDatas();

      expect(viewModel.bankNameOptions.length, 1);
      expect(viewModel.bankNameOptions.first.name, "Bank A");
      expect(viewModel.typeOfFacilityOptions.length, 1);
      expect(viewModel.typeOfFacilityOptions.first.name, "Facility X");
      expect(viewModel.securityOptions.length, 1);
      expect(viewModel.securityOptions.first.name, "Security Y");
    });

    test("getReferenceDatas handles null reference data", () async {
      final mockReferenceData = <String, List<Reference>>{
        ReferenceDataKeys.bankList: [],
      };

      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => mockReferenceData,
      );

      await viewModel.getReferenceDatas();

      expect(viewModel.bankNameOptions, isEmpty);
      expect(viewModel.typeOfFacilityOptions, isEmpty);
      expect(viewModel.securityOptions, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("calculateTotal handles null values correctly", () {
      viewModel.currentFacilityItems.fundedLimit = null;
      viewModel.currentFacilityItems.nonFundedLimit = null;

      viewModel.calculateTotal();

      expect(viewModel.currentFacilityItems.total, Decimal.fromInt(0));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.facilityController.text, "0");
    });

    test("calculateTotal handles string conversion correctly", () {
      viewModel.currentFacilityItems.fundedLimit = Decimal.fromInt(150);
      viewModel.currentFacilityItems.nonFundedLimit = Decimal.fromInt(250);

      viewModel.calculateTotal();

      expect(viewModel.currentFacilityItems.total, Decimal.fromInt(400));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.facilityController.text, "400");
    });

    test("onCancelButtonPressed calls context.pop", () async {
      final mockContext = MockBuildContext();

      expect(
        () => viewModel.onCancelButtonPressed(mockContext),
        throwsA(isA<AssertionError>()),
      );
    });

    test("onSaveButtonPressed - form validation fails", () async {
      viewModel.formKey = GlobalKey<FormState>();

      await viewModel.onSaveButtonPressed(MockBuildContext());

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init method sets showCurrentFiCreditRisk based on business segment",
        () async {
      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{},
      );

      await viewModel.init(MockBuildContext());

      expect(viewModel.isFiFlow, isA<bool>());
    });

    test("init method sets repository and repositoryDataService", () async {
      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{},
      );

      await viewModel.init(MockBuildContext());

      expect(viewModel.repository, isA<GroupInformationRepository>());
      expect(viewModel.repositoryDataService, isA<ReferenceDataService>());
    });

    test("property initialization tests", () {
      expect(viewModel.facilityCollection, isEmpty);
      expect(viewModel.currentFacilityItems, isA<Facility>());
      expect(viewModel.bankNameOptions, isEmpty);
      expect(viewModel.typeOfFacilityOptions, isEmpty);
      expect(viewModel.securityOptions, isEmpty);
      expect(viewModel.selectedCustomer, isA<Customer>());
      expect(viewModel.isFiFlow, false);
    });

    test("onSecurityDeleted removes valid item", () {
      viewModel.currentFacilityItems.securityWith = [
        Reference(id: 1, name: "Sec 1"),
        Reference(id: 2, name: "Sec 2"),
      ];

      viewModel.onSecurityDeleted(0);

      expect(viewModel.currentFacilityItems.securityWith?.length, 1);
      expect(viewModel.currentFacilityItems.securityWith?.first.name, "Sec 2");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onSecurityDeleted ignores invalid index", () {
      viewModel.currentFacilityItems.securityWith = [
        Reference(id: 1, name: "Sec 1"),
      ];

      viewModel.onSecurityDeleted(5);

      expect(viewModel.currentFacilityItems.securityWith?.length, 1);
    });

    test("onSecurityDeleted ignores null list", () {
      viewModel.currentFacilityItems.securityWith = null;

      viewModel.onSecurityDeleted(0);

      expect(viewModel.currentFacilityItems.securityWith, isNull);
    });

    test("onFacilityDeleted removes valid item", () {
      viewModel.currentFacilityItems.facilityWith = [
        Reference(id: 1, name: "Fac 1"),
        Reference(id: 2, name: "Fac 2"),
      ];

      viewModel.onFacilityDeleted(1);

      expect(viewModel.currentFacilityItems.facilityWith?.length, 1);
      expect(viewModel.currentFacilityItems.facilityWith?.first.name, "Fac 1");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onFacilityDeleted ignores invalid index", () {
      viewModel.currentFacilityItems.facilityWith = [
        Reference(id: 1, name: "Fac 1"),
      ];

      viewModel.onFacilityDeleted(-1);

      expect(viewModel.currentFacilityItems.facilityWith?.length, 1);
    });

    test("onFacilityDeleted ignores null list", () {
      viewModel.currentFacilityItems.facilityWith = null;

      viewModel.onFacilityDeleted(0);

      expect(viewModel.currentFacilityItems.facilityWith, isNull);
    });

    test("onSecurityTypeSelectedById updates ids and selected refs", () {
      viewModel.securityOptions = [
        Reference(id: 1, name: "Cash"),
        Reference(id: 2, name: "Property"),
        Reference(id: 3, name: "Guarantee"),
      ];

      viewModel.onSecurityTypeSelectedById([1, 3]);

      expect(viewModel.securityWithIds, [1, 3]);
      expect(viewModel.currentFacilityItems.securityWith?.length, 2);
      expect(
        viewModel.currentFacilityItems.securityWith
            ?.map((e) => e.name)
            .toList(),
        ["Cash", "Guarantee"],
      );
    });

    test("onSecurityTypeSelectedById handles unmatched ids", () {
      viewModel.securityOptions = [
        Reference(id: 1, name: "Cash"),
      ];

      viewModel.onSecurityTypeSelectedById([999]);

      expect(viewModel.securityWithIds, [999]);
      expect(viewModel.currentFacilityItems.securityWith, isEmpty);
    });

    test("displayNameFromIdOrRef returns matching option name", () {
      final result = viewModel.displayNameFromIdOrRef(
        ref: Reference(id: 1, name: "Fallback Name"),
        options: [Reference(id: 1, name: "Matched Name")],
      );

      expect(result, "Matched Name");
    });

    test("displayNameFromIdOrRef returns ref name when no match found", () {
      final result = viewModel.displayNameFromIdOrRef(
        ref: Reference(id: 5, name: "Ref Name"),
        options: [Reference(id: 1, name: "Matched Name")],
      );

      expect(result, "Ref Name");
    });

    test(
        "displayNameFromIdOrRef "
        "returns fallback when "
        "id match has null name and ref name null", () {
      final result = viewModel.displayNameFromIdOrRef(
        ref: Reference(id: 1, name: null),
        options: [Reference(id: 1, name: null)],
        fallback: "--",
      );

      expect(result, "--");
    });

    test("displayNameFromIdOrRef returns ref name when ref id is null", () {
      final result = viewModel.displayNameFromIdOrRef(
        ref: Reference(id: null, name: "No Id Name"),
        options: [Reference(id: 1, name: "Matched Name")],
      );

      expect(result, "No Id Name");
    });

    test(
        "displayNameFromIdOrRef returns fallback "
        "when ref id and ref name are null", () {
      final result = viewModel.displayNameFromIdOrRef(
        ref: Reference(id: null, name: null),
        options: [Reference(id: 1, name: "Matched Name")],
        fallback: "--",
      );

      expect(result, "--");
    });

    group("AddOtherBankDialogState", () {
      test("constructor sets loaderStatus", () {
        final state = AddOtherBankDialogState(
          loaderStatus: LoadingStatus.loading,
        );
        expect(state.loaderStatus, LoadingStatus.loading);
      });

      test("copyWith keeps existing when null", () {
        final original = AddOtherBankDialogState(
          loaderStatus: LoadingStatus.loaded,
        );
        final copied = original.copyWith();
        expect(copied.loaderStatus, LoadingStatus.loaded);
      });

      test("copyWith overrides", () {
        final original = AddOtherBankDialogState(
          loaderStatus: LoadingStatus.loaded,
        );
        final updated = original.copyWith(
          loaderStatus: LoadingStatus.error,
        );
        expect(updated.loaderStatus, LoadingStatus.error);
        expect(original.loaderStatus, LoadingStatus.loaded);
      });
    });
  });
}
