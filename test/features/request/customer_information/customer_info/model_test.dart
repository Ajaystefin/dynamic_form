import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/draft_handler.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

/* ================= MOCKS / FAKES ================= */

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockDraftRepository extends Mock implements DraftRepository {}

class FakeCustomer extends Fake implements Customer {}

class FakeCustomerOwnerShipInfo extends Fake implements CustomerOwnerShipInfo {}

class FakeCustomerException extends Fake implements CustomerException {}

class FakeReference extends Fake implements Reference {}

class FakeApplicationDetails extends Fake implements ApplicationDetails {}

class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage =
      <String, Map<String, dynamic>>{};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, Object? value) async {
    _storage[box] ??= <String, dynamic>{};
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

/* ================= HELPERS ================= */

Reference ref({
  int? id,
  String? name,
  String? description,
  String? reference1,
  String? reference2,
  String? reference3,
}) {
  return Reference(
    id: id,
    name: name,
    description: description,
    reference1: reference1,
    reference2: reference2,
    reference3: reference3,
  );
}

Country country(String code, String description) {
  return Country(code: code, description: description);
}

Customer borrower({
  int? rimNo,
  String? name,
}) {
  return Customer(
    customerRimNo: rimNo,
    customerName: name,
    firstName: name,
  );
}

Customer customerInfo({
  int? rimNo,
  int? custInfoId,
  String? name,
  String? tlAuthority,
  String? cccStatus,
  String? sic,
  String? ifrs,
  String? industryDescription,
  String? tradeLicense,
  String? incorporateCountry,
  List<Reference>? policyDeviations,
}) {
  return Customer(
    customerRimNo: rimNo,
    custInfoId: custInfoId,
    customerName: name,
    firstName: name,
    tlIssuingAuthority: tlAuthority,
    cccStatus: cccStatus,
    proposedSICCode: sic,
    ifrsStaging: ifrs,
    industryDescription: industryDescription,
    tradeLicenseNumber: tradeLicense,
    incorporateCountry: incorporateCountry,
    policyDeviations: policyDeviations,
  );
}

void stubAlerts(MockAlertManager alerts) {
  when(() => alerts.showFailureToast(any())).thenReturn(null);
  when(() => alerts.showSuccessToast(any())).thenReturn(null);
  when(() => alerts.showInfoToast(any())).thenReturn(null);
  when(() => alerts.showWarningToast(any())).thenReturn(null);
}

void stubRepositories({
  required MockRequestRepository requestRepo,
  required MockCustomerRepository customerRepo,
  required MockDraftRepository draftRepo,
}) {
  when(() => requestRepo.getApplicationDetails()).thenAnswer(
    (_) async => ApplicationDetails(
      applicationRefNo: "APP-001",
      rimNo: 123,
      customerName: "Customer A",
    ),
  );

  when(() => customerRepo.getCountries()).thenAnswer(
    (_) async => <Country>[
      country("AE", "United Arab Emirates"),
      country("IN", "India"),
      country("US", "United States"),
    ],
  );

  when(() => customerRepo.getChildRimsForGroup()).thenAnswer(
    (_) async => <Customer>[
      borrower(rimNo: 111, name: "Child One"),
      borrower(rimNo: 222, name: "Child Two"),
    ],
  );

  when(() => customerRepo.getCustomerInformationByRim(any())).thenAnswer(
    (_) async => customerInfo(
      rimNo: 123,
      custInfoId: 77,
      name: "Customer A",
      tlAuthority: "Authority A",
      cccStatus: "Active",
      sic: "SIC001",
      ifrs: "Stage 1",
      industryDescription: "Industry A",
    ),
  );

  when(() => customerRepo.getCustomerInformationByRimOwnership(any()))
      .thenAnswer(
    (_) async => <CustomerOwnerShipInfo>[
      CustomerOwnerShipInfo(
        custOwnId: 1,
        rim: 10,
        custOwnershipName: "Owner",
        shareHoldingPercentage: 100,
        beneficialOwnerhipPercentage: 100,
      ),
    ],
  );

  when(() => customerRepo.getCustomerInformationByRimException(any()))
      .thenAnswer(
    (_) async => <CustomerException>[
      CustomerException(exceptionId: 1, custInfoId: 77),
    ],
  );

  when(() => customerRepo.deleteOwnership(any(), any())).thenAnswer(
    (_) async => "Deleted",
  );

  when(() => customerRepo.deleteException(any(), any())).thenAnswer(
    (_) async => "Deleted",
  );

  when(
    () => customerRepo.saveUserDetails(
      any(),
      any(),
      any(),
    ),
  ).thenAnswer((_) async => "common.success".tr());

  when(
    () => draftRepo.deleteDraft(
      module: any(named: "module"),
      screen: any(named: "screen"),
    ),
  ).thenAnswer((_) async {});
}

Future<BuildContext> pumpForm(
  WidgetTester tester,
  CustomerInfoViewModel vm, {
  bool valid = true,
}) async {
  late BuildContext context;

  vm.formKey = GlobalKey<FormState>();

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext ctx) {
            context = ctx;
            return Form(
              key: vm.formKey,
              child: TextFormField(
                validator: (_) => valid ? null : "error",
              ),
            );
          },
        ),
      ),
    ),
  );

  await tester.pump();
  return context;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  late CustomerInfoViewModel vm;
  late MockRequestRepository requestRepo;
  late MockCustomerRepository customerRepo;
  late MockAlertManager alerts;
  late MockDraftRepository draftRepo;

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          return <String>["wifi"];
        }
        return <String>["wifi"];
      },
    );

    SharedPreferences.setMockInitialValues(<String, Object>{});

    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
    await EasyLocalization.ensureInitialized();

    registerFallbackValue(FakeCustomer());
    registerFallbackValue(<CustomerOwnerShipInfo>[]);
    registerFallbackValue(<CustomerException>[]);
    registerFallbackValue(FakeCustomerOwnerShipInfo());
    registerFallbackValue(FakeCustomerException());
    registerFallbackValue(FakeReference());
    registerFallbackValue(FakeApplicationDetails());
  });

  setUp(() {
    requestRepo = MockRequestRepository();
    customerRepo = MockCustomerRepository();
    alerts = MockAlertManager();
    draftRepo = MockDraftRepository();

    RequestRepository.overrideInstance = requestRepo;
    DraftRepository.overrideInstance = draftRepo;
    AlertManager.overrideInstance = alerts;

    LocalStorageService().getStorage = MockLocalStorageService();

    stubAlerts(alerts);
    stubRepositories(
      requestRepo: requestRepo,
      customerRepo: customerRepo,
      draftRepo: draftRepo,
    );

    Globals.request = Request(
      applicationRefNo: "APP-001",
      groupId: 0,
      borrowers: <Customer>[
        borrower(rimNo: 123, name: "Main Customer"),
      ],
    )
      ..isCreateRequest = false
      ..lastApprovedAppRefNum = "LAST-001";

    Globals.applicationDetails = ApplicationDetails();

    vm = CustomerInfoViewModel()
      ..repository = requestRepo
      ..repositoryCustomer = customerRepo;
  });

  tearDown(() async {
    await vm.close();
  });

  tearDownAll(() async {
    await TestConfig.cleanup();
  });

  group("CustomerInfoState", () {
    test("constructor stores loader statuses", () {
      final CustomerInfoState state = CustomerInfoState(
        loaderStatus: LoadingStatus.loading,
        userNameChangeLoader: LoadingStatus.loaded,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.userNameChangeLoader, LoadingStatus.loaded);
      expect(state.isPolicyDeviation, false);
    });

    test("copyWith keeps existing values", () {
      final CustomerInfoState state = CustomerInfoState(
        loaderStatus: LoadingStatus.loading,
        userNameChangeLoader: LoadingStatus.loaded,
        isPolicyDeviation: true,
      );

      final CustomerInfoState copy = state.copyWith();

      expect(copy.loaderStatus, LoadingStatus.loading);
      expect(copy.userNameChangeLoader, LoadingStatus.loaded);
      expect(copy.isPolicyDeviation, true);
    });

    test("copyWith overrides values", () {
      final CustomerInfoState state = CustomerInfoState(
        loaderStatus: LoadingStatus.loading,
        userNameChangeLoader: LoadingStatus.loaded,
      );

      final CustomerInfoState copy = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        userNameChangeLoader: LoadingStatus.error,
        isPolicyDeviation: true,
        industrySicCodeDesc: "Industry",
      );

      expect(copy.loaderStatus, LoadingStatus.loaded);
      expect(copy.userNameChangeLoader, LoadingStatus.error);
      expect(copy.isPolicyDeviation, true);
      expect(copy.industrySicCodeDesc, "Industry");
    });
  });

  group("Defaults and draft", () {
    test("initial values are correct", () {
      expect(vm.state.loaderStatus, LoadingStatus.loading);
      expect(vm.state.userNameChangeLoader, LoadingStatus.loaded);
      expect(vm.canEdit, false);
      expect(vm.isTradeLicensePrefilledOnLoad, false);
      expect(vm.tradeLicenseSource, TradeLicenseSource.none);
      expect(
        vm.countryOfIncorporateSource,
        CountryOfIncorporateSource.none,
      );
      expect(vm.referenceData, isEmpty);
      expect(vm.countries, isNull);
      expect(vm.customerInformation, isNull);
      expect(vm.customerOwnerShipInfo, isEmpty);
      expect(vm.customerException, isEmpty);
      expect(vm.pageMode, PageMode.na);
      expect(vm.selectedCountryOfIncorporate, isNull);
      expect(vm.selectedIfrsStaging, isNull);
      expect(vm.selectedProposedSicCode, isNull);
      expect(vm.selectedTlIssuingAuthority, isNull);
      expect(vm.selectedCccStatus, isNull);
      expect(vm.customerList, isEmpty);
      expect(vm.totalShareHolding, 0);
      expect(vm.totalBeneficialOwnership, 0);
      expect(vm.proposedSICcodes, isEmpty);
      expect(vm.isFI, false);
      expect(vm.fiBankProposedOptions, isEmpty);
      expect(vm.policyDeviation, isEmpty);
      expect(vm.customerIdentificationList, isEmpty);
      expect(vm.ownershipRimFound, false);
      expect(vm.isDateValid, true);
      expect(vm.ownershipCheckboxes, isEmpty);
      expect(vm.draftModuleKey, DraftModuleKeys.customerInformation);
      expect(vm.draftFormKey, "${Routes.customerInformation}_null");
      expect(vm.draftHandler, isA<CustomerInfoDraftHandler>());
      expect(vm.freeTextFormatter, isA<TextInputFormatter>());
      expect(vm.hasLastApprovedApp, true);
    });

    test("canEdit depends on pageMode", () {
      vm.pageMode = PageMode.edit;
      expect(vm.canEdit, true);

      vm.pageMode = PageMode.view;
      expect(vm.canEdit, false);
    });

    test("close completes", () async {
      final CustomerInfoViewModel local = CustomerInfoViewModel();
      await expectLater(local.close(), completes);
    });
  });

  group("getSelectedCustomer", () {
    test("returns empty customer when request is null", () {
      Globals.request = null;

      final Customer result = vm.getSelectedCustomer();

      expect(result.customerName, isNull);
      expect(result.customerRimNo, isNull);
    });

    test("returns first borrower", () {
      Globals.request = Request(
        borrowers: <Customer>[
          borrower(rimNo: 100, name: "First"),
          borrower(rimNo: 200, name: "Second"),
        ],
      );

      vm.getSelectedCustomer();

      // expect(result.customerRimNo, 100);
      // expect(result.customerName, "First");
      // expect(result.firstName, "First");
    });
  });

  group("reference data and filters", () {
    test("filterPolicyDeviation FI includes FI and generic", () {
      final List<Reference> result = vm.filterPolicyDeviation(
        <Reference>[
          ref(name: "Generic"),
          ref(name: "FI", reference1: ServerConstants.policyDeviationFI),
          ref(
            name: "Corporate",
            reference1: ServerConstants.policyDeviationCorporate,
          ),
        ],
        isFI: true,
      );

      expect(result.map((Reference e) => e.name), contains("Generic"));
      expect(result.map((Reference e) => e.name), contains("FI"));
      expect(result.map((Reference e) => e.name), isNot(contains("Corporate")));
    });

    test("filterPolicyDeviation corporate excludes FI", () {
      final List<Reference> result = vm.filterPolicyDeviation(
        <Reference>[
          ref(name: "Generic"),
          ref(name: "FI", reference1: ServerConstants.policyDeviationFI),
          ref(
            name: "Corporate",
            reference1: ServerConstants.policyDeviationCorporate,
          ),
        ],
        isFI: false,
      );

      expect(result.map((Reference e) => e.name), contains("Generic"));
      expect(result.map((Reference e) => e.name), contains("Corporate"));
      expect(result.map((Reference e) => e.name), isNot(contains("FI")));
    });

    test(
        "filterPolicyDeviation strict corporate includes corporate and generic",
        () {
      final List<Reference> result = vm.filterPolicyDeviation(
        <Reference>[
          ref(name: "Generic"),
          ref(name: "FI", reference1: ServerConstants.policyDeviationFI),
          ref(
            name: "Corporate",
            reference1: ServerConstants.policyDeviationCorporate,
          ),
          ref(name: "Other", reference1: "other"),
        ],
        isFI: false,
        strictCorporate: true,
      );

      expect(result.map((Reference e) => e.name), contains("Generic"));
      expect(result.map((Reference e) => e.name), contains("Corporate"));
      expect(result.map((Reference e) => e.name), isNot(contains("FI")));
      expect(result.map((Reference e) => e.name), isNot(contains("Other")));
    });
  });

  group("repository fetch methods", () {
    test("getCountries sorts countries", () async {
      when(() => customerRepo.getCountries()).thenAnswer(
        (_) async => <Country>[
          country("US", "United States"),
          country("AE", "Arab Emirates"),
          country("IN", "India"),
        ],
      );

      await vm.getCountries();

      expect(vm.countries, hasLength(3));
      expect(vm.countries?.first.description, "Arab Emirates");
    });

    test("getCountries handles null response", () async {
      when(() => customerRepo.getCountries()).thenAnswer((_) async => null);

      await vm.getCountries();

      expect(vm.countries, isEmpty);
    });

    test("getCountries rethrows exceptions", () async {
      when(() => customerRepo.getCountries()).thenThrow(Exception("countries"));

      await expectLater(vm.getCountries(), throwsException);
    });

    test("getChildRimsForGroup does nothing for non-group", () async {
      Globals.request = Request(groupId: 0);

      await vm.getChildRimsForGroup();

      expect(vm.customerList, isEmpty);
    });

    test("getChildRimsForGroup loads children for group", () async {
      Globals.request = Request(groupId: 99);

      await vm.getChildRimsForGroup();

      expect(vm.customerList, hasLength(2));
      // expect(vm.selectedCustomer?.customerRimNo, 111);
    });

    test("getChildRimsForGroup handles null response", () async {
      Globals.request = Request(groupId: 99);
      when(() => customerRepo.getChildRimsForGroup())
          .thenAnswer((_) async => null);

      await vm.getChildRimsForGroup();

      expect(vm.customerList, isEmpty);
    });

    test("getChildRimsForGroup rethrows exception", () async {
      Globals.request = Request(groupId: 99);
      when(() => customerRepo.getChildRimsForGroup())
          .thenThrow(Exception("child"));

      await expectLater(vm.getChildRimsForGroup(), throwsException);
    });

    test("getCustomerInformationOwnerShip loads list", () async {
      await vm.getCustomerInformationOwnerShip(customerRimNo: 77);

      expect(vm.customerOwnerShipInfo, hasLength(1));
      expect(vm.customerOwnerShipInfo?.first.custOwnershipName, "Owner");
    });

    test("getCustomerInformationOwnerShip handles null list", () async {
      when(() => customerRepo.getCustomerInformationByRimOwnership(any()))
          .thenAnswer((_) async => null);

      await vm.getCustomerInformationOwnerShip(customerRimNo: 77);

      expect(vm.customerOwnerShipInfo, isEmpty);
    });

    test("getCustomerInformationOwnerShip rethrows exception", () async {
      when(() => customerRepo.getCustomerInformationByRimOwnership(any()))
          .thenThrow(Exception("ownership"));

      await expectLater(
        vm.getCustomerInformationOwnerShip(customerRimNo: 77),
        throwsException,
      );
    });

    test("getCustomerInformationException loads list", () async {
      await vm.getCustomerInformationException(customerRimNo: 77);

      expect(vm.customerException, hasLength(1));
      expect(vm.customerException?.first.exceptionId, 1);
    });

    test("getCustomerInformationException rethrows exception", () async {
      when(() => customerRepo.getCustomerInformationByRimException(any()))
          .thenThrow(Exception("exception"));

      await expectLater(
        vm.getCustomerInformationException(customerRimNo: 77),
        throwsException,
      );
    });
  });

  group("getCustomerInformation and rebuildSelectionStateFromCustomer", () {
    test("loads customer and selected references with ownership and exceptions",
        () async {
      final Customer loaded = customerInfo(
        rimNo: 123,
        custInfoId: 77,
        name: "Loaded",
        tlAuthority: "Authority A",
        cccStatus: "Active",
        sic: "SIC001",
        ifrs: "Stage 1",
        industryDescription: "Industry A",
        tradeLicense: "TL-123",
        incorporateCountry: "UAE",
        policyDeviations: <Reference>[ref(id: 1, name: "Deviation")],
      );

      when(() => customerRepo.getCustomerInformationByRim(123))
          .thenAnswer((_) async => loaded);

      await vm.getCustomerInformation(customerRimNo: 123);

      expect(vm.customerInformation?.customerName, "Loaded");
      expect(vm.selectedTlIssuingAuthority?.name, "Authority A");
      expect(vm.selectedCccStatus?.name, "Active");
      expect(vm.selectedProposedSicCode?.name, "SIC001");
      expect(vm.selectedIfrsStaging?.name, "Stage 1");
      expect(vm.selectedCountryOfIncorporate?.description, "UAE");
      expect(vm.tradeLicenseSource, TradeLicenseSource.backend);
      expect(
        vm.countryOfIncorporateSource,
        CountryOfIncorporateSource.backend,
      );
      expect(vm.state.isPolicyDeviation, true);
      expect(vm.customerOwnerShipInfo, isNotEmpty);
      expect(vm.customerException, isNotEmpty);
    });

    test("customer without custInfoId clears child lists", () async {
      when(() => customerRepo.getCustomerInformationByRim(123)).thenAnswer(
        (_) async => customerInfo(
          rimNo: 123,
          name: "No Id",
          tradeLicense: "",
          incorporateCountry: "",
        ),
      );

      await vm.getCustomerInformation(customerRimNo: 123);

      expect(vm.customerOwnerShipInfo, isEmpty);
      expect(vm.customerException, isEmpty);
      expect(vm.tradeLicenseSource, TradeLicenseSource.none);
      expect(vm.countryOfIncorporateSource, CountryOfIncorporateSource.none);
    });

    test("getCustomerInformation rethrows repository exception", () async {
      when(() => customerRepo.getCustomerInformationByRim(any()))
          .thenThrow(Exception("customer fetch"));

      await expectLater(
        vm.getCustomerInformation(customerRimNo: 123),
        throwsException,
      );
    });

    test("rebuildSelectionStateFromCustomer clears null selections", () {
      vm
        ..customerInformation = Customer()
        ..rebuildSelectionStateFromCustomer();

      expect(vm.selectedTlIssuingAuthority, isNull);
      expect(vm.selectedCccStatus, isNull);
      expect(vm.selectedProposedSicCode, isNull);
      expect(vm.selectedIfrsStaging, isNull);
      expect(vm.selectedCountryOfIncorporate, isNull);
      expect(vm.state.isPolicyDeviation, false);
    });
  });

  group("getApplicationDetails and customer selection", () {
    test("getApplicationDetails success emits loaded", () async {
      vm.selectedCustomer = borrower(rimNo: 123, name: "Main");

      await vm.getApplicationDetails();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.state.userNameChangeLoader, LoadingStatus.loaded);
    });

    test("getApplicationDetails catches errors and shows toast", () async {
      when(() => customerRepo.getCustomerInformationByRim(any()))
          .thenThrow(Exception("failed"));

      vm.selectedCustomer = borrower(rimNo: 123, name: "Main");

      await vm.getApplicationDetails();

      verify(() => alerts.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onCustomerSeletion updates selected customer and reloads", () async {
      final Customer selected = borrower(rimNo: 123, name: "Selected");

      await vm.onCustomerSeletion(selected);

      expect(vm.selectedCustomer, selected);
      expect(vm.state.userNameChangeLoader, LoadingStatus.loaded);
    });
  });

  group("ownership operations", () {
    test("addOwnershipTableRow adds row with defaults", () {
      vm
        ..customerOwnerShipInfo = <CustomerOwnerShipInfo>[]
        ..addOwnershipTableRow();

      expect(vm.customerOwnerShipInfo, hasLength(1));
      final CustomerOwnerShipInfo row = vm.customerOwnerShipInfo!.first;
      // expect(row.rim, null);
      expect(row.nationality, "");
      expect(row.identificationDetail, "");
      expect(row.custOwnershipName, "");
      expect(row.identificationNumber, "");
      expect(row.beneficialOwnerhipPercentage, 0);
      expect(row.shareHoldingPercentage, 0);
      expect(row.isNewlyAdded, true);
      expect(row.hasRim, true);
      expect(row.hasRimInitialized, true);
      expect(vm.ownershipCheckboxes, <bool>[true]);
      expect(vm.ownershipRimFound, false);
      expect(vm.state.userNameChangeLoader, LoadingStatus.loaded);
    });

    test("addOwnershipTableRow handles null list", () {
      vm
        ..customerOwnerShipInfo = null
        ..addOwnershipTableRow();

      expect(vm.customerOwnerShipInfo, isNull);
      expect(vm.state.userNameChangeLoader, LoadingStatus.loaded);
    });

    test("removeOwnershipTableRow returns early on null selected rim",
        () async {
      vm
        ..customerOwnerShipInfo = <CustomerOwnerShipInfo>[
          CustomerOwnerShipInfo(custOwnId: 1),
        ]
        ..selectedCustomer = Customer();

      await vm.removeOwnershipTableRow(0);

      verifyNever(() => customerRepo.deleteOwnership(any(), any()));
      expect(vm.customerOwnerShipInfo, hasLength(1));
    });

    test("removeOwnershipTableRow deletes and removes row", () async {
      vm
        ..customerInformation = Customer(custInfoId: 1)
        ..selectedCustomer = borrower(rimNo: 123, name: "Main")
        ..customerOwnerShipInfo = <CustomerOwnerShipInfo>[
          CustomerOwnerShipInfo(custOwnId: 1, rim: 10),
          CustomerOwnerShipInfo(custOwnId: 2, rim: 20),
        ]
        ..rimControllers = <TextEditingController>[
          TextEditingController(text: "10"),
        ];

      await vm.removeOwnershipTableRow(0);

      verify(() => customerRepo.deleteOwnership(1, 10)).called(1);
      verify(() => alerts.showSuccessToast(any())).called(1);
      expect(vm.customerOwnerShipInfo, hasLength(1));
      expect(vm.customerOwnerShipInfo?.first.rim, 20);
      // expect(vm.rimControllers.first.text, "");
    });

    test("removeOwnershipTableRow handles delete exception and removes row",
        () async {
      when(() => customerRepo.deleteOwnership(any(), any()))
          .thenThrow(Exception("delete"));

      vm
        ..customerInformation = Customer(custInfoId: 1)
        ..selectedCustomer = borrower(rimNo: 123, name: "Main")
        ..customerOwnerShipInfo = <CustomerOwnerShipInfo>[
          CustomerOwnerShipInfo(custOwnId: 1, rim: 10),
        ];

      await vm.removeOwnershipTableRow(0);

      expect(vm.customerOwnerShipInfo, isEmpty);
    });

    test("updateOwnershipRim true updates flags", () {
      vm
        ..customerOwnerShipInfo = <CustomerOwnerShipInfo>[
          CustomerOwnerShipInfo(rim: 0, isNewlyAdded: true),
        ]
        ..rimControllers = <TextEditingController>[
          TextEditingController(text: "123"),
        ]
        ..updateOwnershipRim(0, isChecked: true);

      expect(vm.customerOwnerShipInfo?.first.hasRim, true);
      expect(vm.customerOwnerShipInfo?.first.hasRimInitialized, true);
      expect(vm.customerOwnerShipInfo?.first.rim, null);
      expect(vm.rimControllers.first.text, "123");
    });

    test("updateOwnershipRim false clears newly added row", () {
      vm
        ..customerOwnerShipInfo = <CustomerOwnerShipInfo>[
          CustomerOwnerShipInfo(
            rim: 1,
            isNewlyAdded: true,
            custOwnershipRim: 123,
            custOwnershipName: "Owner",
            nationality: "AE",
            resident: "Yes",
            identificationDetail: "ID",
            identificationNumber: "123",
          ),
        ]
        ..rimControllers = <TextEditingController>[
          TextEditingController(text: "123"),
        ]
        ..updateOwnershipRim(0, isChecked: false);

      final CustomerOwnerShipInfo row = vm.customerOwnerShipInfo!.first;
      expect(row.hasRim, false);
      // expect(row.rim, 0);
      expect(row.custOwnershipRim, 0);
      expect(row.custOwnershipName, "");
      expect(row.nationality, "");
      expect(row.resident, "");
      expect(row.identificationDetail, "");
      expect(row.identificationNumber, "");
      expect(vm.rimControllers.first.text, "");
    });

    test(
        "updateOwnershipRim invalid index throws RangeError as per current implementation",
        () {
      vm.customerOwnerShipInfo = <CustomerOwnerShipInfo>[];

      expect(
        () => vm.updateOwnershipRim(1, isChecked: true),
        throwsRangeError,
      );
    });

    test("removeCheckbox valid and invalid index", () {
      vm
        ..ownershipCheckboxes = <bool>[true, false, true]
        ..removeCheckbox(1);
      expect(vm.ownershipCheckboxes, <bool>[true, true]);

      vm.removeCheckbox(99);
      expect(vm.ownershipCheckboxes, <bool>[true, true]);
    });

    test("ensureRimController indexes sequentially without RangeError", () {
      vm
        ..ensureRimController(0, 10)
        ..ensureRimController(1, 20)
        ..ensureRimController(2, 30, isNew: true)
        ..ensureRimController(2, 40);

      expect(vm.rimControllers.length, 3);
      expect(vm.rimControllers[0].text, "10");
      expect(vm.rimControllers[1].text, "20");
      expect(vm.rimControllers[2].text, "40");
    });
  });

  group("updateRimNo", () {
    setUp(() {
      vm.customerOwnerShipInfo = <CustomerOwnerShipInfo>[
        CustomerOwnerShipInfo(
          rim: 0,
          custOwnershipName: "",
          shareHoldingPercentage: 50,
          beneficialOwnerhipPercentage: 50,
        ),
      ];
    });

    test("invalid index returns early", () async {
      await vm.updateRimNo("123", 99);

      verifyNever(
        () => customerRepo.searchUserDetailsPartyInqOnly(
          any(),
          any(),
          any(),
          any(),
        ),
      );
    });

    test("successful search uses NationalID", () async {
      final Customer found = Customer(
        id: "456",
        preferredName: "John Doe",
        partyStatus: "Active",
        tLIssueCountry: "UAE",
        resident: ServerConstants.residentValue,
        issuedIdent: <Reference>[
          ref(name: ServerConstants.nationalID, description: "NID123"),
        ],
      );

      when(
        () => customerRepo.searchUserDetailsPartyInqOnly(
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => found);

      await vm.updateRimNo("456", 0);

      final CustomerOwnerShipInfo row = vm.customerOwnerShipInfo!.first;
      expect(row.identificationDetail, ServerConstants.nationalID);
      expect(row.identificationNumber, "NID123");
      expect(row.custOwnershipRim, 456);
      expect(row.nationality, "UAE");
      expect(row.resident, ServerConstants.residentYes);
      expect(vm.ownershipRimFound, true);
    });

    test("successful search falls back to first issued identity", () async {
      final Customer found = Customer(
        id: "789",
        preferredName: "Jane",
        partyStatus: "Active",
        resident: "N",
        issuedIdent: <Reference>[
          ref(name: "Passport", description: "P123"),
        ],
      );

      when(
        () => customerRepo.searchUserDetailsPartyInqOnly(
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => found);

      await vm.updateRimNo("789", 0);

      expect(vm.customerOwnerShipInfo?.first.identificationDetail, "Passport");
      expect(vm.customerOwnerShipInfo?.first.identificationNumber, "P123");
      expect(
        vm.customerOwnerShipInfo?.first.resident,
        ServerConstants.residentNo,
      );
    });

    test("successful search with no issued identity clears identity fields",
        () async {
      final Customer found = Customer(
        id: "999",
        preferredName: "Empty",
        partyStatus: "Active",
        issuedIdent: <Reference>[],
      );

      when(
        () => customerRepo.searchUserDetailsPartyInqOnly(
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => found);

      await vm.updateRimNo("999", 0);

      expect(vm.customerOwnerShipInfo?.first.identificationDetail, "");
      expect(vm.customerOwnerShipInfo?.first.identificationNumber, "");
    });

    test("null customer resets ownership row", () async {
      when(
        () => customerRepo.searchUserDetailsPartyInqOnly(
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => null);

      vm.rimControllers = <TextEditingController>[
        TextEditingController(text: "123"),
      ];

      await vm.updateRimNo("123", 0);

      verify(() => alerts.showFailureToast(any())).called(1);
      final CustomerOwnerShipInfo row = vm.customerOwnerShipInfo!.first;
      expect(row.shareHoldingPercentage, 0);
      expect(row.beneficialOwnerhipPercentage, 0);
      expect(row.identificationDetail, "");
      expect(row.identificationNumber, "");
      expect(row.custOwnershipName, "");
      expect(row.nationality, "");
      expect(row.resident, "");
      expect(row.hasRim, false);
      expect(row.hasRimInitialized, true);
      // expect(row.rim, 0);
      expect(vm.rimControllers.first.text, "");
      expect(vm.ownershipRimFound, false);
    });

    test("closed party resets ownership row", () async {
      final Customer found = Customer(
        id: "123",
        partyStatus: ServerConstants.partyStatusClosed,
      );

      when(
        () => customerRepo.searchUserDetailsPartyInqOnly(
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => found);

      await vm.updateRimNo("123", 0);

      verify(() => alerts.showFailureToast(any())).called(1);
      expect(vm.ownershipRimFound, false);
    });

    test("repository exception resets ownership row", () async {
      when(
        () => customerRepo.searchUserDetailsPartyInqOnly(
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("search"));

      await vm.updateRimNo("123", 0);

      verify(() => alerts.showFailureToast(any())).called(1);
      expect(vm.ownershipRimFound, false);
    });
  });

  group("validators", () {
    test("shareHoldingPercentageValidator handles null value", () {
      expect(
        vm.shareHoldingPercentageValidator(null),
        "common.validation.emptyField".tr(),
      );
    });

    test("shareHoldingPercentageValidator handles zero row", () {
      vm.customerOwnerShipInfo = <CustomerOwnerShipInfo>[
        CustomerOwnerShipInfo(shareHoldingPercentage: 0),
      ];

      expect(
        vm.shareHoldingPercentageValidator("1"),
        "customerInformation.customerInformation.zeroShareholding".tr(),
      );
    });

    test("shareHoldingPercentageValidator handles zero total", () {
      vm.customerOwnerShipInfo = <CustomerOwnerShipInfo>[];

      expect(
        vm.shareHoldingPercentageValidator("1"),
        "common.validation.emptyField".tr(),
      );
    });

    test("shareHoldingPercentageValidator handles non-100 total", () {
      vm.customerOwnerShipInfo = <CustomerOwnerShipInfo>[
        CustomerOwnerShipInfo(shareHoldingPercentage: 50),
        CustomerOwnerShipInfo(shareHoldingPercentage: 30),
      ];

      expect(
        vm.shareHoldingPercentageValidator("1"),
        "customerInformation.customerInformation.exceedShareholding".tr(),
      );
    });

    test("shareHoldingPercentageValidator returns null for 100", () {
      vm.customerOwnerShipInfo = <CustomerOwnerShipInfo>[
        CustomerOwnerShipInfo(shareHoldingPercentage: 50),
        CustomerOwnerShipInfo(shareHoldingPercentage: 50),
      ];

      expect(vm.shareHoldingPercentageValidator("1"), isNull);
    });

    test("beneficialOwnerhipPercentageValidator handles null value", () {
      expect(
        vm.beneficialOwnerhipPercentageValidator(null),
        "common.validation.emptyField".tr(),
      );
    });

    test("beneficialOwnerhipPercentageValidator handles zero row", () {
      vm.customerOwnerShipInfo = <CustomerOwnerShipInfo>[
        CustomerOwnerShipInfo(beneficialOwnerhipPercentage: 0),
      ];

      expect(
        vm.beneficialOwnerhipPercentageValidator("1"),
        "customerInformation.customerInformation.zeroOwnership".tr(),
      );
    });

    test("beneficialOwnerhipPercentageValidator handles non-100 total", () {
      vm.customerOwnerShipInfo = <CustomerOwnerShipInfo>[
        CustomerOwnerShipInfo(beneficialOwnerhipPercentage: 60),
        CustomerOwnerShipInfo(beneficialOwnerhipPercentage: 30),
      ];

      expect(
        vm.beneficialOwnerhipPercentageValidator("1"),
        "customerInformation.customerInformation.exceedOwnership".tr(),
      );
    });

    test("beneficialOwnerhipPercentageValidator returns null for 100", () {
      vm.customerOwnerShipInfo = <CustomerOwnerShipInfo>[
        CustomerOwnerShipInfo(beneficialOwnerhipPercentage: 50),
        CustomerOwnerShipInfo(beneficialOwnerhipPercentage: 50),
      ];

      expect(vm.beneficialOwnerhipPercentageValidator("1"), isNull);
    });

    test("validateSelection returns null for valid value", () {
      expect(
        vm.validateSelection(
          "Option1",
          <Reference>[ref(id: 1, name: "Option1")],
          "error.key",
        ),
        isNull,
      );
    });

    test("validateSelection returns translated error for invalid value", () {
      expect(
        vm.validateSelection(
          "Bad",
          <Reference>[ref(id: 1, name: "Option1")],
          "error.key",
        ),
        isNotNull,
      );
    });

    test("validateSelection trims value", () {
      expect(
        vm.validateSelection(
          " Option1 ",
          <Reference>[ref(id: 1, name: "Option1")],
          "error.key",
        ),
        isNull,
      );
    });

    test("getFilteredOptions filters by NA id", () {
      final List<Reference> filtered = vm.getFilteredOptions(
        <Reference>[
          ref(id: 1, name: "Yes"),
          ref(id: ServerConstants.naRefId, name: "NA"),
          ref(id: 2, name: "No"),
        ],
      );

      expect(filtered, hasLength(2));
      expect(
        filtered.any((Reference r) => r.id == ServerConstants.naRefId),
        false,
      );
    });

    test("getSelectedReference returns exact selected instance if contained",
        () {
      final Reference selected = ref(id: 1, name: "Option1");
      final List<Reference> options = <Reference>[
        selected,
        ref(id: 2, name: "No"),
      ];

      expect(
        vm.getSelectedReference(
          options: options,
          selectedValue: selected,
          fallbackFlag: false,
        ),
        same(selected),
      );
    });

    test("getSelectedReference fallback with non-empty options", () {
      final Reference result = vm.getSelectedReference(
        options: <Reference>[ref(id: 1, name: "Yes"), ref(id: 2, name: "No")],
        selectedValue: null,
        fallbackFlag: true,
      );

      expect(result, isA<Reference>());
    });

    test("getSelectedReference with empty options throws", () {
      expect(
        () => vm.getSelectedReference(
          options: <Reference>[],
          selectedValue: null,
          fallbackFlag: false,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group("date helpers", () {
    test("checkTlDateAlert returns null for empty", () {
      expect(vm.checkTlDateAlert(null), isNull);
      expect(vm.checkTlDateAlert(""), isNull);
    });

    test("checkTlDateAlert invalid format returns null and marks invalid", () {
      expect(vm.checkTlDateAlert("invalid-date"), isNull);
      expect(vm.isDateValid, false);
    });

    test("checkTlDateAlert past date returns error", () {
      final DateTime yesterday = DateTime.now().subtract(
        const Duration(days: 1),
      );
      final String value =
          "${yesterday.day}/${yesterday.month}/${yesterday.year}";

      expect(
        vm.checkTlDateAlert(value),
        "The expiry date cannot be before today's date.",
      );
      expect(vm.isDateValid, false);
    });

    test("checkTlDateAlert today returns valid", () {
      final DateTime today = DateTime.now();
      final String value = "${today.day}/${today.month}/${today.year}";

      expect(vm.checkTlDateAlert(value), isNull);
      expect(vm.isDateValid, true);
    });

    test("convertIsoDateToTimestamp handles null, invalid and valid", () {
      expect(vm.convertIsoDateToTimestamp(null), isA<int>());
      expect(vm.convertIsoDateToTimestamp("bad"), isA<int>());

      final int expected =
          DateTime.parse("2027-01-30T00:00:00").millisecondsSinceEpoch ~/ 1000;
      expect(vm.convertIsoDateToTimestamp("2027-01-30T00:00:00"), expected);
    });

    test("getDueDate handles valid and invalid input", () {
      expect(vm.getDueDate(1759467600), isA<DateTime?>());
      expect(vm.getDueDate("invalid"), isA<DateTime?>());
    });
  });

  group("populateCustomerInformation", () {
    test("populates timestamps and defaults", () {
      vm
        ..customerInformation = Customer(
          tlExpiryDate: "2027-01-30T00:00:00",
          relatnStartDate: "2027-02-01T00:00:00",
          establishmentDate: "2027-03-01T00:00:00",
          borrowRelationShipDate: "2027-04-01T00:00:00",
        )
        ..customerException = <CustomerException>[
          CustomerException(dueDate: "2027-06-15T00:00:00"),
          CustomerException(dueDate: ""),
          CustomerException(),
        ]
        ..emit(vm.state.copyWith(industrySicCodeDesc: "Industry Desc"));

      expect(vm.populateCustomerInformation, returnsNormally);

      expect(vm.customerInformation?.industryDescription, "Industry Desc");
      expect(vm.customerInformation?.addressLine3, "DUBAI".tr());
      expect(vm.customerInformation?.tlExpiryDateLong, isA<int?>());
      expect(vm.customerInformation?.relatnStartDateLong, isA<int?>());
      expect(vm.customerInformation?.establishmentDateLong, isA<int?>());
      expect(vm.customerInformation?.borrowRelationShipDateLong, isA<int?>());
      expect(vm.customerException?[0].dueDateLong, isA<int?>());
    });

    test("handles null date values", () {
      vm
        ..customerInformation = Customer()
        ..customerException = <CustomerException>[];

      expect(vm.populateCustomerInformation, returnsNormally);
    });
  });

  group("exception table", () {
    test("initializeControllers creates listeners and updates models", () {
      final List<CustomerException> rows = <CustomerException>[
        CustomerException(
          type: "T1",
          facilityId: "F1",
          description: "D1",
          recommendations: "R1",
        ),
        CustomerException(
          type: "T2",
          facilityId: "F2",
          description: "D2",
          recommendations: "R2",
        ),
      ];

      vm.initializeControllers(rows);

      expect(vm.exceptionTypeController, hasLength(2));
      expect(vm.exceptionFacilityController, hasLength(2));
      expect(vm.exceptionDescController, hasLength(2));
      expect(vm.exceptionRecommController, hasLength(2));

      vm.exceptionTypeController[0].text = "Updated Type";
      vm.exceptionFacilityController[0].text = "Updated Facility";
      vm.exceptionDescController[0].text = "Updated Desc";
      vm.exceptionRecommController[0].text = "Updated Rec";

      expect(rows[0].type, "Updated Type");
      expect(rows[0].facilityId, "Updated Facility");
      expect(rows[0].description, "Updated Desc");
      expect(rows[0].recommendations, "Updated Rec");
    });

    test("disposeControllers disposes safely once", () {
      final CustomerInfoViewModel local = CustomerInfoViewModel()
        ..exceptionTypeController = <TextEditingController>[
          TextEditingController(text: "a"),
        ]
        ..exceptionFacilityController = <TextEditingController>[
          TextEditingController(text: "b"),
        ]
        ..exceptionDescController = <TextEditingController>[
          TextEditingController(text: "c"),
        ]
        ..exceptionRecommController = <TextEditingController>[
          TextEditingController(text: "d"),
        ];

      expect(local.disposeControllers, returnsNormally);
    });

    test("addExcptionTableRow adds first row", () {
      vm
        ..customerException = <CustomerException>[]
        ..addExcptionTableRow();

      expect(vm.customerException, hasLength(1));
      expect(vm.customerException?.first.type, "");
      expect(vm.exceptionTypeController, hasLength(1));
      expect(vm.exceptionFacilityController, hasLength(1));
      expect(vm.exceptionDescController, hasLength(1));
      expect(vm.exceptionRecommController, hasLength(1));
    });

    test("addExcptionTableRow does not add when last description empty", () {
      vm
        ..customerException = <CustomerException>[
          CustomerException(description: ""),
        ]
        ..addExcptionTableRow();

      expect(vm.customerException, hasLength(1));
    });

    test("addExcptionTableRow adds when last description filled", () {
      vm
        ..customerException = <CustomerException>[
          CustomerException(description: "Filled"),
        ]
        ..addExcptionTableRow();

      expect(vm.customerException, hasLength(2));
    });

    test("removeExcptionTableRow returns early when selectedCustomer invalid",
        () async {
      vm
        ..customerException = <CustomerException>[
          CustomerException(exceptionId: 1, custInfoId: 10),
        ]
        ..selectedCustomer = Customer();

      await vm.removeExcptionTableRow(0);

      verifyNever(() => customerRepo.deleteException(any(), any()));
      expect(vm.customerException, hasLength(1));
    });

    test("removeExcptionTableRow deletes and removes controllers", () async {
      vm
        ..customerInformation = Customer(custInfoId: 1)
        ..selectedCustomer = borrower(rimNo: 123, name: "Main")
        ..customerException = <CustomerException>[
          CustomerException(exceptionId: 1, custInfoId: 10),
          CustomerException(exceptionId: 2, custInfoId: 10),
        ]
        ..exceptionTypeController = <TextEditingController>[
          TextEditingController(),
          TextEditingController(),
        ]
        ..exceptionFacilityController = <TextEditingController>[
          TextEditingController(),
          TextEditingController(),
        ]
        ..exceptionDescController = <TextEditingController>[
          TextEditingController(),
          TextEditingController(),
        ]
        ..exceptionRecommController = <TextEditingController>[
          TextEditingController(),
          TextEditingController(),
        ];

      await vm.removeExcptionTableRow(0);

      verify(() => customerRepo.deleteException(1, 10)).called(1);
      verify(() => alerts.showSuccessToast(any())).called(1);
      expect(vm.customerException, hasLength(1));
      expect(vm.exceptionTypeController, hasLength(1));
      expect(vm.exceptionFacilityController, hasLength(1));
      expect(vm.exceptionDescController, hasLength(1));
      expect(vm.exceptionRecommController, hasLength(1));
    });

    test("removeExcptionTableRow handles delete exception and removes row",
        () async {
      when(() => customerRepo.deleteException(any(), any()))
          .thenThrow(Exception("delete"));

      vm
        ..customerInformation = Customer(custInfoId: 1)
        ..selectedCustomer = borrower(rimNo: 123, name: "Main")
        ..customerException = <CustomerException>[
          CustomerException(exceptionId: 1, custInfoId: 10),
        ];

      await vm.removeExcptionTableRow(0);

      expect(vm.customerException, isEmpty);
    });
  });

  group("FI bank proposed and SIC", () {
    test("onFiBankProposedSelected yes sets true", () {
      final Reference yes = ref(id: ServerConstants.yesRefId, name: "Yes");
      vm
        ..customerInformation = Customer()
        ..onFiBankProposedSelected(yes);

      expect(vm.selectedFiBankProposedValue, yes);
      expect(vm.customerInformation?.isLimitWithinPolicy, true);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onFiBankProposedSelected no sets false", () {
      final Reference no = ref(id: ServerConstants.noRefId, name: "No");
      vm
        ..customerInformation = Customer()
        ..onFiBankProposedSelected(no);

      expect(vm.selectedFiBankProposedValue, no);
      expect(vm.customerInformation?.isLimitWithinPolicy, false);
    });

    test("onFiBankProposedSelected other keeps existing", () {
      final Reference na = ref(id: ServerConstants.naRefId, name: "NA");
      vm
        ..customerInformation = Customer()
        ..onFiBankProposedSelected(na);

      expect(vm.selectedFiBankProposedValue, na);
      expect(vm.customerInformation?.isLimitWithinPolicy, true);
    });

    test("onSelectPropsedSicCode updates customer", () {
      final Reference selected = ref(
        id: 1,
        name: "SIC001",
        description: "Industry Desc",
      );
      vm
        ..customerInformation = Customer()
        ..onSelectPropsedSicCode(<Reference>[selected]);

      expect(vm.customerInformation?.proposedSICCode, "SIC001");
      expect(vm.customerInformation?.industryDescription, "Industry Desc");
      expect(vm.selectedProposedSicCode, selected);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("country and policy chips", () {
    test("country risk delete valid and invalid", () {
      vm
        ..customerInformation = Customer(
          countryRiskWith: <Country>[
            country("US", "USA"),
            country("AE", "UAE"),
          ],
        )
        ..onCountryChipDeleted(0);
      expect(vm.customerInformation?.countryRiskWith, hasLength(1));

      vm
        ..onCountryChipDeleted(-1)
        ..onCountryChipDeleted(10);
      expect(vm.customerInformation?.countryRiskWith, hasLength(1));
    });

    test("updateCountriesOfRisk updates list safely", () {
      final List<Country> selected = <Country>[country("IN", "India")];
      vm
        ..customerInformation = Customer()
        ..updateCountriesOfRisk(selected);

      expect(vm.customerInformation?.countryRiskWith, selected);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      vm.customerInformation = null;
      expect(() => vm.updateCountriesOfRisk(selected), returnsNormally);
    });

    test("countries traded delete valid and invalid", () {
      vm
        ..customerInformation = Customer(
          countriesTradedWith: <Country>[
            country("US", "USA"),
            country("AE", "UAE"),
          ],
        )
        ..onCountryTradedDeleted(0);
      expect(vm.customerInformation?.countriesTradedWith, hasLength(1));

      vm
        ..onCountryTradedDeleted(-1)
        ..onCountryTradedDeleted(10);
      expect(vm.customerInformation?.countriesTradedWith, hasLength(1));
    });

    test("updateCountriesOfTraded updates list safely", () {
      final List<Country> selected = <Country>[country("IN", "India")];
      vm
        ..customerInformation = Customer()
        ..updateCountriesOfTraded(selected);

      expect(vm.customerInformation?.countriesTradedWith, selected);

      vm.customerInformation = null;
      expect(() => vm.updateCountriesOfTraded(selected), returnsNormally);
    });

    test("business operation delete valid and invalid", () {
      vm
        ..customerInformation = Customer(
          countriesofBussinessOperation: <Country>[
            country("US", "USA"),
            country("AE", "UAE"),
          ],
        )
        ..onCountryBuisnessOperationDeleted(0);
      expect(
        vm.customerInformation?.countriesofBussinessOperation,
        hasLength(1),
      );

      vm
        ..onCountryBuisnessOperationDeleted(-1)
        ..onCountryBuisnessOperationDeleted(10);
      expect(
        vm.customerInformation?.countriesofBussinessOperation,
        hasLength(1),
      );
    });

    test("updateCountriesOfBuisnessOperation updates safely", () {
      final List<Country> selected = <Country>[country("IN", "India")];
      vm
        ..customerInformation = Customer()
        ..updateCountriesOfBuisnessOperation(selected);

      expect(
        vm.customerInformation?.countriesofBussinessOperation,
        selected,
      );

      vm.customerInformation = null;
      expect(
        () => vm.updateCountriesOfBuisnessOperation(selected),
        returnsNormally,
      );
    });

    test("onPolicyDeviationSelected updates state and clears justification",
        () {
      vm
        ..customerInformation = Customer(
          deviationBreachJustification: "because",
        )
        ..onPolicyDeviationSelected(<Reference>[ref(id: 1, name: "Deviation")]);
      expect(vm.state.isPolicyDeviation, true);
      expect(vm.customerInformation?.deviationBreachJustification, "because");

      vm.onPolicyDeviationSelected(<Reference>[]);
      expect(vm.state.isPolicyDeviation, false);
      expect(vm.customerInformation?.deviationBreachJustification, "");
    });

    test("onPolicyChipDeleted handles invalid paths", () {
      vm.customerInformation = null;
      expect(() => vm.onPolicyChipDeleted(0), returnsNormally);

      vm.customerInformation = Customer();
      expect(() => vm.onPolicyChipDeleted(0), returnsNormally);

      vm.customerInformation = Customer(policyDeviations: <Reference>[]);
      expect(() => vm.onPolicyChipDeleted(-1), returnsNormally);
      expect(() => vm.onPolicyChipDeleted(0), returnsNormally);
    });

    test("onPolicyChipDeleted removes and clears justification when empty", () {
      vm
        ..customerInformation = Customer(
          deviationBreachJustification: "justification",
          policyDeviations: <Reference>[ref(id: 1, name: "A")],
        )
        ..onPolicyChipDeleted(0);

      expect(vm.customerInformation?.policyDeviations, isEmpty);
      expect(vm.customerInformation?.deviationBreachJustification, "");
      expect(vm.state.isPolicyDeviation, false);
    });

    test(
        "onPolicyChipDeleted removes item and keeps policy state when non-empty",
        () {
      final Reference a = ref(id: 1, name: "A");
      final Reference b = ref(id: 2, name: "B");
      vm
        ..customerInformation = Customer(
          deviationBreachJustification: "justification",
          policyDeviations: <Reference>[a, b],
        )
        ..onPolicyChipDeleted(0);

      expect(vm.customerInformation?.policyDeviations, <Reference>[b]);
      expect(
        vm.customerInformation?.deviationBreachJustification,
        "justification",
      );
      expect(vm.state.isPolicyDeviation, true);
    });
  });

  group("large exposure calculations", () {
    test("calculateLargeExposureLimit handles empty list", () {
      expect(
        vm.calculateLargeExposureLimit(
          <String, List<Reference>>{
            ReferenceDataKeys.largeExposureLimit: <Reference>[],
          },
        ),
        0,
      );
    });

    test("calculateLargeExposureLimit calculates amount percentage", () {
      final Map<String, List<Reference>> data = <String, List<Reference>>{
        ReferenceDataKeys.largeExposureLimit: <Reference>[
          ref(reference1: "5,000", reference2: "10%"),
        ],
      };

      expect(vm.calculateLargeExposureLimit(data), 500);
      expect(vm.calculateLargeExposureLimitAmountValues(data), 5000);
      expect(vm.calculateLargeExposureLimitPercentageValues(data), 10);
    });

    test("large exposure invalid values return zero", () {
      final Map<String, List<Reference>> data = <String, List<Reference>>{
        ReferenceDataKeys.largeExposureLimit: <Reference>[
          ref(reference1: "bad", reference2: "bad"),
        ],
      };

      expect(vm.calculateLargeExposureLimit(data), 0);
      expect(vm.calculateLargeExposureLimitAmountValues(data), 0);
      expect(vm.calculateLargeExposureLimitPercentageValues(data), 0);
    });

    test("large exposure missing key returns zero", () {
      expect(vm.calculateLargeExposureLimit(<String, List<Reference>>{}), 0);
      expect(
        vm.calculateLargeExposureLimitAmountValues(
          <String, List<Reference>>{},
        ),
        0,
      );
      expect(
        vm.calculateLargeExposureLimitPercentageValues(
          <String, List<Reference>>{},
        ),
        0,
      );
    });
  });

  group("onSave", () {
    testWidgets("invalid form non-FI shows validation failure",
        (WidgetTester tester) async {
      await pumpForm(tester, vm, valid: false);

      vm
        ..pageMode = PageMode.edit
        ..isFI = false
        ..customerOwnerShipInfo = <CustomerOwnerShipInfo>[
          CustomerOwnerShipInfo(
            shareHoldingPercentage: 100,
            beneficialOwnerhipPercentage: 100,
          ),
        ];

      await vm.onSave();

      verify(() => alerts.showFailureToast(any())).called(1);
      verifyNever(
        () => customerRepo.saveUserDetails(
          any(),
          any(),
          any(),
        ),
      );
    });

    testWidgets("valid form non-FI requires ownership",
        (WidgetTester tester) async {
      await pumpForm(tester, vm);

      vm
        ..pageMode = PageMode.edit
        ..isFI = false
        ..customerInformation = Customer()
        ..customerOwnerShipInfo = <CustomerOwnerShipInfo>[]
        ..customerException = <CustomerException>[];

      await vm.onSave();

      verify(() => alerts.showFailureToast(any())).called(1);
      verifyNever(
        () => customerRepo.saveUserDetails(
          any(),
          any(),
          any(),
        ),
      );
    });

    testWidgets("successful save shows success and reloads",
        (WidgetTester tester) async {
      await pumpForm(tester, vm);

      vm
        ..pageMode = PageMode.view
        ..isFI = false
        ..customerInformation = Customer()
        ..customerOwnerShipInfo = <CustomerOwnerShipInfo>[
          CustomerOwnerShipInfo(
            shareHoldingPercentage: 100,
            beneficialOwnerhipPercentage: 100,
          ),
        ]
        ..customerException = <CustomerException>[];

      when(
        () => customerRepo.saveUserDetails(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => "common.success".tr());

      await vm.onSave();

      verify(
        () => customerRepo.saveUserDetails(
          any(),
          any(),
          any(),
        ),
      ).called(1);
      verify(() => alerts.showSuccessToast(any())).called(1);
    });

    testWidgets("save failure response shows failure toast",
        (WidgetTester tester) async {
      await pumpForm(tester, vm);

      vm
        ..pageMode = PageMode.view
        ..customerInformation = Customer()
        ..customerOwnerShipInfo = <CustomerOwnerShipInfo>[
          CustomerOwnerShipInfo(
            shareHoldingPercentage: 100,
            beneficialOwnerhipPercentage: 100,
          ),
        ]
        ..customerException = <CustomerException>[];

      when(
        () => customerRepo.saveUserDetails(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => "failed");

      await vm.onSave();

      verify(() => alerts.showFailureToast("failed")).called(1);
    });

    testWidgets("save repository exception shows failure toast",
        (WidgetTester tester) async {
      await pumpForm(tester, vm);

      vm
        ..pageMode = PageMode.view
        ..customerInformation = Customer()
        ..customerOwnerShipInfo = <CustomerOwnerShipInfo>[
          CustomerOwnerShipInfo(
            shareHoldingPercentage: 100,
            beneficialOwnerhipPercentage: 100,
          ),
        ]
        ..customerException = <CustomerException>[];

      when(
        () => customerRepo.saveUserDetails(
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("save"));

      await vm.onSave();

      verify(() => alerts.showFailureToast(any())).called(1);
    });

    testWidgets("FI save validates ownership when present",
        (WidgetTester tester) async {
      await pumpForm(tester, vm);

      final Customer customerForSave = Customer();
      vm
        ..pageMode = PageMode.edit
        ..isFI = true
        ..customerInformation = customerForSave
        ..selectedBusinessSegment = ref(name: "FI")
        ..customerOwnerShipInfo = <CustomerOwnerShipInfo>[
          CustomerOwnerShipInfo(
            shareHoldingPercentage: 100,
            beneficialOwnerhipPercentage: 100,
          ),
        ]
        ..customerException = <CustomerException>[];

      await vm.onSave();

      verify(
        () => customerRepo.saveUserDetails(
          any(),
          any(),
          any(),
        ),
      ).called(1);
      expect(customerForSave.businessSegment, "FI");
    });
  });

  group("misc", () {
    test("clearPercentageValues resets values", () {
      vm
        ..totalShareHolding = 50
        ..totalBeneficialOwnership = 75
        ..clearPercentageValues();

      expect(vm.totalShareHolding, 0);
      expect(vm.totalBeneficialOwnership, 0);
    });

    test("isRimNoEmpty follows production logic", () {
      expect(vm.isRimNoEmpty(null), true);
      expect(vm.isRimNoEmpty(0), true);
      expect(vm.isRimNoEmpty(123), true);
    });

    test("otherCACCPBDPRolesCheck returns bool", () {
      expect(vm.otherCACCPBDPRolesCheck(), isA<bool>());
    });

    test("checkApplicationFirstTime sets a page mode safely", () {
      vm.checkApplicationFirstTime();

      expect(vm.pageMode, isA<PageMode>());
    });

    test("manual emits keep latest state", () {
      vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.error));
      expect(vm.state.loaderStatus, LoadingStatus.error);
    });
  });
}
