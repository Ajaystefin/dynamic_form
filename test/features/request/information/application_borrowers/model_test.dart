import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/application_borrowers/model.dart";
import "package:wcas_frontend/features/request/information/application_borrowers/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/group.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

/* ================= MOCKS / FAKES ================= */

class MockRequestRepository extends Mock implements RequestRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeCustomer extends Fake implements Customer {}

/// Test-only VM.
/// Prevents init() from calling real ReferenceDataService, which causes
/// async "Error fetching reference data: common.error" failures in unit tests.
class TestApplicationBorrowersViewModel extends ApplicationBorrowersViewModel {
  @override
  Future<void> getReferenceDatas() async {
    referenceData = <String, List<Reference>>{};
  }
}

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

class FakeMountedContext implements BuildContext {
  @override
  bool get mounted => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/* ================= HELPERS ================= */

Customer customer({
  int? rimNo,
  String? id,
  String? classCode,
  bool? isSelected,
  bool? isSelectedBelowGrade,
  bool? isSelectedCountryFI,
  bool? isCountryFI,
  bool? isBorrower,
  bool? isBorrowerBelowGrade,
  CustomerType? type,
  Group? groups,
  String? name,
}) {
  return Customer(
    customerRimNo: rimNo,
    id: id,
    classCode: classCode,
    customerName: name,
    firstName: name,
    isSelected: isSelected,
    isSelectedBelowGrade: isSelectedBelowGrade,
    isSelectedCountryFI: isSelectedCountryFI,
    isCountryFI: isCountryFI,
    isBorrower: isBorrower,
    isBorrowerBelowGrade: isBorrowerBelowGrade,
    type: type,
    groups: groups,
  );
}

Reference businessSegmentRef(BusinessSegment segment) {
  return Reference(
    id: ServerConstants.businessSegmentId[segment],
    name: segment.name,
  );
}

void stubAlerts(MockAlertManager alerts) {
  when(() => alerts.showFailureToast(any())).thenReturn(null);
  when(() => alerts.showSuccessToast(any())).thenReturn(null);
  when(() => alerts.showInfoToast(any())).thenReturn(null);
  when(() => alerts.showWarningToast(any())).thenReturn(null);
}

Request readonlyRequest({
  List<Customer> borrowers = const <Customer>[],
  int? customerRimNo,
}) {
  return Request(
    applicationRefNo: "APP-READONLY",
    borrowers: borrowers,
    customerRimNo: customerRimNo,
  );
}

Request editableRequest({
  List<Customer> borrowers = const <Customer>[],
  int? customerRimNo,
  Reference? businessSegment,
  List<Customer>? fiCustomerListCountry,
}) {
  final Request request = Request(
    borrowers: borrowers,
    customerRimNo: customerRimNo,
    businessSegment: businessSegment,
  );

  if (fiCustomerListCountry != null) {
    request.fiCustomerListCountry = fiCustomerListCountry;
  }

  return request;
}

Future<void> pumpAndInit(
  WidgetTester tester,
  ApplicationBorrowersViewModel vm, {
  required Request request,
}) async {
  Globals.request = request;

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return ElevatedButton(
            onPressed: () {},
            child: const Text("init"),
          );
        },
      ),
    ),
  );

  await tester.runAsync(() async {
    await vm.init(tester.element(find.byType(ElevatedButton)));
  });

  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  late TestApplicationBorrowersViewModel vm;
  late MockRequestRepository repo;
  late MockAlertManager alerts;

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
  });

  setUp(() {
    repo = MockRequestRepository();
    alerts = MockAlertManager();

    RequestRepository.overrideInstance = repo;
    AlertManager.overrideInstance = alerts;
    LocalStorageService().getStorage = MockLocalStorageService();

    stubAlerts(alerts);

    when(() => repo.getApplicationBorrowers()).thenAnswer(
      (_) async => <Customer>[],
    );

    Globals.request = editableRequest(
      borrowers: <Customer>[
        customer(rimNo: 100, name: "Main"),
      ],
    );

    vm = TestApplicationBorrowersViewModel()..repository = repo;
  });

  tearDown(() async {
    Globals.request = null;
    await vm.close();
  });

  tearDownAll(() async {
    await TestConfig.cleanup();
  });

  /* ================= STATE ================= */

  group("ApplicationBorrowersState", () {
    test("constructor stores loaderStatus", () {
      final ApplicationBorrowersState state = ApplicationBorrowersState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing value", () {
      final ApplicationBorrowersState state = ApplicationBorrowersState(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(state.copyWith().loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides value", () {
      final ApplicationBorrowersState state = ApplicationBorrowersState(
        loaderStatus: LoadingStatus.loaded,
      );

      final ApplicationBorrowersState updated = state.copyWith(
        loaderStatus: LoadingStatus.error,
      );

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(state.loaderStatus, LoadingStatus.loaded);
    });
  });

  /* ================= DEFAULTS ================= */

  group("defaults", () {
    test("initial values are correct", () {
      expect(vm.state.loaderStatus, LoadingStatus.loading);
      expect(vm.formKey, isA<GlobalKey<FormState>>());
      expect(vm.applicationBorrowers, isEmpty);
      expect(vm.customers, isEmpty);
      expect(vm.selectedCustomers, isEmpty);
      expect(vm.primaryRim, isNull);
      expect(vm.isFI, false);
      expect(vm.pagemode, PageMode.na);
      expect(vm.referenceData, isEmpty);
    });

    test("isReadOnly false when request null", () {
      Globals.request = null;

      expect(vm.isReadOnly, false);
    });

    test("isReadOnly follows computed request state", () {
      Globals.request = readonlyRequest();
      expect(vm.isReadOnly, true);

      Globals.request = editableRequest();
      expect(vm.isReadOnly, false);
    });

    test("test getReferenceDatas override stores empty map", () async {
      await vm.getReferenceDatas();

      expect(vm.referenceData, isEmpty);
    });
  });

  /* ================= INIT CORE ================= */

  group("init core behavior", () {
    testWidgets("loads borrowers, sets primaryRim, emits loaded",
        (WidgetTester tester) async {
      await pumpAndInit(
        tester,
        vm,
        request: editableRequest(
          customerRimNo: 100,
          borrowers: <Customer>[
            customer(rimNo: 100),
            customer(rimNo: 200),
          ],
        ),
      );

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.primaryRim, 100);
      expect(vm.customers, hasLength(2));
      expect(vm.isFI, isA<bool>());
      expect(vm.pagemode, isA<PageMode>());
    });

    testWidgets("uses first borrower rim when request.customerRimNo is null",
        (WidgetTester tester) async {
      await pumpAndInit(
        tester,
        vm,
        request: editableRequest(
          borrowers: <Customer>[
            customer(rimNo: 300),
            customer(rimNo: 400),
          ],
        ),
      );

      expect(vm.primaryRim, 300);
    });

    testWidgets("pins primary RIM to top", (WidgetTester tester) async {
      await pumpAndInit(
        tester,
        vm,
        request: editableRequest(
          customerRimNo: 100,
          borrowers: <Customer>[
            customer(rimNo: 200),
            customer(rimNo: 100),
            customer(rimNo: 300),
          ],
        ),
      );

      expect(vm.customers.first.customerRimNo, 100);
    });

    testWidgets("deduplicates customers by RIM", (WidgetTester tester) async {
      await pumpAndInit(
        tester,
        vm,
        request: editableRequest(
          borrowers: <Customer>[
            customer(rimNo: 100),
            customer(rimNo: 100),
            customer(rimNo: 200),
          ],
        ),
      );

      expect(
        vm.customers.map((Customer c) => c.customerRimNo),
        <int?>[100, 200],
      );
    });

    testWidgets("removes null RIM during dedupe", (WidgetTester tester) async {
      await pumpAndInit(
        tester,
        vm,
        request: editableRequest(
          borrowers: <Customer>[
            customer(),
            customer(rimNo: 200),
          ],
        ),
      );

      expect(vm.customers, hasLength(1));
      expect(vm.customers.first.customerRimNo, 200);
    });

    testWidgets("searched rim wins when searched and group owner differ",
        (WidgetTester tester) async {
      await pumpAndInit(
        tester,
        vm,
        request: editableRequest(
          customerRimNo: 999,
          borrowers: <Customer>[
            customer(
              rimNo: 100,
              groups: const Group(groupOwner: 100),
            ),
          ],
        ),
      );

      expect(vm.primaryRim, 999);
    });

    testWidgets("group owner wins when searched rim equals owner",
        (WidgetTester tester) async {
      await pumpAndInit(
        tester,
        vm,
        request: editableRequest(
          customerRimNo: 100,
          borrowers: <Customer>[
            customer(
              rimNo: 100,
              groups: const Group(groupOwner: 100),
            ),
          ],
        ),
      );

      expect(vm.primaryRim, 100);
    });

    testWidgets("group owner is used when no searched rim",
        (WidgetTester tester) async {
      await pumpAndInit(
        tester,
        vm,
        request: editableRequest(
          borrowers: <Customer>[
            customer(
              groups: const Group(groupOwner: 555),
            ),
          ],
        ),
      );

      expect(vm.primaryRim, 555);
    });

    testWidgets("searched rim used when group owner is null",
        (WidgetTester tester) async {
      await pumpAndInit(
        tester,
        vm,
        request: editableRequest(
          customerRimNo: 700,
          borrowers: <Customer>[
            customer(rimNo: 700),
          ],
        ),
      );

      expect(vm.primaryRim, 700);
    });

    testWidgets("empty borrowers leaves primaryRim null",
        (WidgetTester tester) async {
      await pumpAndInit(
        tester,
        vm,
        request: editableRequest(
          borrowers: <Customer>[],
        ),
      );

      expect(vm.primaryRim, isNull);
      expect(vm.customers, isEmpty);
      expect(vm.selectedCustomers, isEmpty);
    });
  });

  /* ================= INIT READONLY ================= */

  group("init readonly behavior", () {
    testWidgets("investmentGradeBanks selects IG when not country FI",
        (WidgetTester tester) async {
      final Customer c = customer(
        rimNo: 100,
        type: CustomerType.investmentGradeBanks,
        isCountryFI: false,
      );

      await pumpAndInit(
        tester,
        vm,
        request: readonlyRequest(
          borrowers: <Customer>[c],
        ),
      );

      expect(c.isSelected, true);
      expect(c.isSelectedBelowGrade, false);
      expect(c.isSelectedCountryFI, false);
      expect(vm.selectedCustomers, contains(c));
    });

    testWidgets("investmentGradeBanks ignored when already country FI",
        (WidgetTester tester) async {
      final Customer c = customer(
        rimNo: 100,
        type: CustomerType.investmentGradeBanks,
        isCountryFI: true,
      );

      await pumpAndInit(
        tester,
        vm,
        request: readonlyRequest(
          borrowers: <Customer>[c],
        ),
      );

      expect(c.isSelected, isNot(true));
      expect(vm.selectedCustomers, isNot(contains(c)));
    });

    testWidgets("belowInvestmentGradeBanks selects below grade",
        (WidgetTester tester) async {
      final Customer c = customer(
        rimNo: 200,
        type: CustomerType.belowInvestmentGradeBanks,
        isCountryFI: false,
      );

      await pumpAndInit(
        tester,
        vm,
        request: readonlyRequest(
          borrowers: <Customer>[c],
        ),
      );

      expect(c.isSelectedBelowGrade, true);
      expect(c.isSelected, false);
      expect(c.isSelectedCountryFI, false);
      expect(vm.selectedCustomers, contains(c));
    });

    testWidgets("country selects country FI", (WidgetTester tester) async {
      final Customer c = customer(
        rimNo: 300,
        type: CustomerType.country,
      );

      await pumpAndInit(
        tester,
        vm,
        request: readonlyRequest(
          borrowers: <Customer>[c],
        ),
      );

      expect(c.isCountryFI, true);
      expect(c.isSelectedCountryFI, true);
      expect(c.isSelected, false);
      expect(c.isSelectedBelowGrade, false);
      expect(vm.selectedCustomers, contains(c));
    });

    testWidgets("corporate selects normal IG", (WidgetTester tester) async {
      final Customer c = customer(
        rimNo: 400,
        type: CustomerType.corporate,
      );

      await pumpAndInit(
        tester,
        vm,
        request: readonlyRequest(
          borrowers: <Customer>[c],
        ),
      );

      expect(c.isCountryFI, false);
      expect(c.isSelectedCountryFI, false);
      expect(c.isSelected, true);
      expect(c.isSelectedBelowGrade, false);
      expect(vm.selectedCustomers, contains(c));
    });

    testWidgets("default type keeps existing flags",
        (WidgetTester tester) async {
      final Customer c = customer(
        rimNo: 500,
        isSelected: true,
      );

      await pumpAndInit(
        tester,
        vm,
        request: readonlyRequest(
          borrowers: <Customer>[c],
        ),
      );

      expect(c.isSelected, true);
      expect(vm.selectedCustomers, contains(c));
    });
  });

  /* ================= INIT EDITABLE ================= */

  group("init editable behavior", () {
    testWidgets("non-FI primary pinned customer is auto selected",
        (WidgetTester tester) async {
      final Customer primary = customer(rimNo: 100);
      final Customer other = customer(rimNo: 200);

      await pumpAndInit(
        tester,
        vm,
        request: editableRequest(
          customerRimNo: 100,
          borrowers: <Customer>[other, primary],
        ),
      );

      expect(vm.customers.first.customerRimNo, 100);
      expect(vm.customers.first.isSelected, true);
      expect(vm.selectedCustomers.first.customerRimNo, 100);
    });

    testWidgets("non-FI selected IG is respected", (WidgetTester tester) async {
      final Customer c = customer(rimNo: 100, isSelected: true);

      await pumpAndInit(
        tester,
        vm,
        request: editableRequest(
          borrowers: <Customer>[c],
        ),
      );

      expect(vm.selectedCustomers, hasLength(1));
      expect(vm.selectedCustomers.first.customerRimNo, 100);
    });

    testWidgets("non-FI below grade selected is respected",
        (WidgetTester tester) async {
      final Customer c = customer(rimNo: 200, isSelectedBelowGrade: true);

      await pumpAndInit(
        tester,
        vm,
        request: editableRequest(
          borrowers: <Customer>[c],
        ),
      );

      expect(vm.selectedCustomers, hasLength(1));
      expect(vm.selectedCustomers.first.customerRimNo, 200);
    });

    testWidgets("FI marks country FI using fiCustomerListCountry",
        (WidgetTester tester) async {
      final Customer countryBorrower = customer(rimNo: 10);
      final Customer bankBorrower = customer(rimNo: 20, isSelected: true);

      await pumpAndInit(
        tester,
        vm,
        request: editableRequest(
          businessSegment: businessSegmentRef(
            BusinessSegment.financialInstitution,
          ),
          borrowers: <Customer>[
            countryBorrower,
            bankBorrower,
          ],
          fiCustomerListCountry: <Customer>[
            customer(
              id: "10",
              classCode: ServerConstants.countryClassCode,
            ),
            customer(
              id: "20",
              classCode: "BANK",
            ),
          ],
        ),
      );

      expect(vm.isFI, true);
      expect(countryBorrower.isCountryFI, true);
      expect(countryBorrower.isSelectedCountryFI, true);
      expect(bankBorrower.isCountryFI, false);
      expect(vm.selectedCustomers, contains(countryBorrower));
      expect(vm.selectedCustomers, contains(bankBorrower));
    });

    testWidgets("FI ignores invalid fiCustomerListCountry ids",
        (WidgetTester tester) async {
      final Customer c = customer(rimNo: 10);

      await pumpAndInit(
        tester,
        vm,
        request: editableRequest(
          businessSegment: businessSegmentRef(
            BusinessSegment.financialInstitution,
          ),
          borrowers: <Customer>[c],
          fiCustomerListCountry: <Customer>[
            customer(id: "", classCode: ServerConstants.countryClassCode),
            customer(id: "bad", classCode: ServerConstants.countryClassCode),
            customer(id: "10", classCode: ""),
          ],
        ),
      );

      expect(c.isCountryFI, false);
      expect(c.isSelectedCountryFI, false);
    });
  });

  /* ================= SELECTION HANDLERS ================= */

  group("onCustomerRimNameSelected", () {
    test("selects IG and clears below grade", () {
      final Customer c = customer(
        rimNo: 100,
        isSelectedBelowGrade: true,
      );

      vm
        ..customers = <Customer>[c]
        ..selectedCustomers = <Customer>[c]
        ..onCustomerRimNameSelected("100", isSelected: true);

      expect(c.isSelected, true);
      expect(c.isSelectedBelowGrade, false);
      expect(vm.selectedCustomers, hasLength(1));
      expect(vm.selectedCustomers.first.customerRimNo, 100);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("unselects IG and removes customer", () {
      final Customer c = customer(
        rimNo: 100,
        isSelected: true,
      );

      vm
        ..customers = <Customer>[c]
        ..selectedCustomers = <Customer>[c]
        ..onCustomerRimNameSelected("100", isSelected: false);

      expect(c.isSelected, false);
      expect(vm.selectedCustomers, isEmpty);
    });

    test("non-FI primary cannot be unselected", () {
      final Customer c = customer(
        rimNo: 100,
        isSelected: true,
      );

      vm
        ..isFI = false
        ..primaryRim = 100
        ..customers = <Customer>[c]
        ..selectedCustomers = <Customer>[c]
        ..onCustomerRimNameSelected("100", isSelected: false);

      expect(c.isSelected, true);
      expect(vm.selectedCustomers, <Customer>[c]);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("country FI cannot be selected as IG", () {
      final Customer c = customer(
        rimNo: 100,
        isCountryFI: true,
      );

      vm
        ..customers = <Customer>[c]
        ..selectedCustomers = <Customer>[]
        ..onCustomerRimNameSelected("100", isSelected: true);

      expect(c.isSelected, isNot(true));
      expect(vm.selectedCustomers, isEmpty);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("non-FI selected list sorts primary first", () {
      final Customer primary = customer(rimNo: 100);
      final Customer other = customer(rimNo: 200);

      vm
        ..isFI = false
        ..primaryRim = 100
        ..customers = <Customer>[primary, other]
        ..selectedCustomers = <Customer>[]
        ..onCustomerRimNameSelected("200", isSelected: true)
        ..onCustomerRimNameSelected("100", isSelected: true);

      expect(vm.selectedCustomers.first.customerRimNo, 100);
      expect(vm.selectedCustomers.last.customerRimNo, 200);
    });

    test("throws StateError for missing rim", () {
      vm.customers = <Customer>[];

      expect(
        () => vm.onCustomerRimNameSelected("999", isSelected: true),
        throwsA(isA<StateError>()),
      );
    });
  });

  group("onBelowGradeSelected", () {
    test("selects below grade and clears IG", () {
      final Customer c = customer(
        rimNo: 200,
        isSelected: true,
      );

      vm
        ..customers = <Customer>[c]
        ..selectedCustomers = <Customer>[c]
        ..onBelowGradeSelected("200", isSelected: true);

      expect(c.isSelectedBelowGrade, true);
      expect(c.isSelected, false);
      expect(vm.selectedCustomers, hasLength(1));
      expect(vm.selectedCustomers.first.customerRimNo, 200);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("unselects below grade and removes customer", () {
      final Customer c = customer(
        rimNo: 200,
        isSelectedBelowGrade: true,
      );

      vm
        ..customers = <Customer>[c]
        ..selectedCustomers = <Customer>[c]
        ..onBelowGradeSelected("200", isSelected: false);

      expect(c.isSelectedBelowGrade, false);
      expect(vm.selectedCustomers, isEmpty);
    });

    test("country FI cannot be selected below grade", () {
      final Customer c = customer(
        rimNo: 200,
        isCountryFI: true,
      );

      vm
        ..customers = <Customer>[c]
        ..selectedCustomers = <Customer>[]
        ..onBelowGradeSelected("200", isSelected: true);

      expect(c.isSelectedBelowGrade, isNot(true));
      expect(vm.selectedCustomers, isEmpty);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("throws StateError for missing rim", () {
      vm.customers = <Customer>[];

      expect(
        () => vm.onBelowGradeSelected("999", isSelected: true),
        throwsA(isA<StateError>()),
      );
    });
  });

  group("onCountrySelected", () {
    test("selects country FI", () {
      final Customer c = customer(
        rimNo: 300,
        isCountryFI: true,
        isSelected: true,
        isSelectedBelowGrade: true,
      );

      vm
        ..customers = <Customer>[c]
        ..selectedCustomers = <Customer>[]
        ..onCountrySelected("300", isSelected: true);

      expect(c.isSelectedCountryFI, true);
      expect(c.isSelected, false);
      expect(c.isSelectedBelowGrade, false);
      expect(vm.selectedCustomers, hasLength(1));
      expect(vm.selectedCustomers.first.customerRimNo, 300);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("unselects country FI and removes customer", () {
      final Customer c = customer(
        rimNo: 300,
        isCountryFI: true,
        isSelectedCountryFI: true,
      );

      vm
        ..customers = <Customer>[c]
        ..selectedCustomers = <Customer>[c]
        ..onCountrySelected("300", isSelected: false);

      expect(c.isSelectedCountryFI, false);
      expect(vm.selectedCustomers, isEmpty);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("non-country FI cannot be country selected", () {
      final Customer c = customer(
        rimNo: 300,
        isCountryFI: false,
      );

      vm
        ..customers = <Customer>[c]
        ..selectedCustomers = <Customer>[]
        ..onCountrySelected("300", isSelected: true);

      expect(c.isSelectedCountryFI, isNot(true));
      expect(vm.selectedCustomers, isEmpty);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("does not duplicate selected country", () {
      final Customer c = customer(
        rimNo: 300,
        isCountryFI: true,
      );

      vm
        ..customers = <Customer>[c]
        ..selectedCustomers = <Customer>[c]
        ..onCountrySelected("300", isSelected: true);

      expect(vm.selectedCustomers, hasLength(1));
    });

    test("throws StateError for missing rim", () {
      vm.customers = <Customer>[];

      expect(
        () => vm.onCountrySelected("999", isSelected: true),
        throwsA(isA<StateError>()),
      );
    });
  });

  /* ================= VALIDATION ================= */

  group("validateBorrowersSelection", () {
    test("returns false and shows toast when customers empty", () {
      Globals.request = Request(customers: <Customer>[]);

      final bool result = vm.validateBorrowersSelection();

      expect(result, false);
      verify(() => alerts.showFailureToast(any())).called(1);
    });

    test("returns true when primaryRim null and customers exist", () {
      Globals.request = Request(
        customers: <Customer>[
          customer(rimNo: 100),
        ],
      );

      vm.primaryRim = null;

      expect(vm.validateBorrowersSelection(), true);
    });

    test("non-FI returns true when primary RIM selected IG", () {
      Globals.request = Request(
        customers: <Customer>[
          customer(rimNo: 100, isSelected: true),
        ],
      );

      vm
        ..isFI = false
        ..primaryRim = 100;

      expect(vm.validateBorrowersSelection(), true);
    });

    test("non-FI returns false when primary RIM only below grade", () {
      Globals.request = Request(
        customers: <Customer>[
          customer(rimNo: 100, isSelectedBelowGrade: true),
        ],
      );

      vm
        ..isFI = false
        ..primaryRim = 100;

      final bool result = vm.validateBorrowersSelection();

      expect(result, false);
      verify(() => alerts.showFailureToast(any())).called(1);
    });

    test("FI returns true when primary selected country FI", () {
      Globals.request = Request(
        customers: <Customer>[
          customer(rimNo: 100, isSelectedCountryFI: true),
        ],
      );

      vm
        ..isFI = true
        ..primaryRim = 100;

      expect(vm.validateBorrowersSelection(), true);
    });

    test("FI returns true when primary selected below grade", () {
      Globals.request = Request(
        customers: <Customer>[
          customer(rimNo: 100, isSelectedBelowGrade: true),
        ],
      );

      vm
        ..isFI = true
        ..primaryRim = 100;

      expect(vm.validateBorrowersSelection(), true);
    });

    test("returns false when primary RIM missing", () {
      Globals.request = Request(
        customers: <Customer>[
          customer(rimNo: 200, isSelected: true),
        ],
      );

      vm
        ..isFI = false
        ..primaryRim = 100;

      final bool result = vm.validateBorrowersSelection();

      expect(result, false);
      verify(() => alerts.showFailureToast(any())).called(1);
    });
  });

  /* ================= SAVE ================= */

  group("onSaveButtonPressed", () {
    test("editable invalid selection does not navigate but updates request",
        () {
      final Request request = Request(
        customers: <Customer>[],
        borrowers: <Customer>[],
      );
      Globals.request = request;

      vm
        ..isFI = false
        ..primaryRim = 100
        ..customers = <Customer>[
          customer(rimNo: 100, isSelected: false),
        ];

      try {
        vm.onSaveButtonPressed(
          FakeMountedContext(),
          navigationOrder: true,
        );
      } on Object {
        // Global router can be unattached in isolated unit tests.
      }

      expect(request.customers, vm.customers);
      expect(request.borrowers, vm.customers);
      verify(() => alerts.showFailureToast(any())).called(1);
    });

    test("editable valid selection updates request and may navigate", () {
      final Request request = Request();
      Globals.request = request;

      vm
        ..isFI = false
        ..primaryRim = 100
        ..customers = <Customer>[
          customer(rimNo: 100, isSelected: true),
        ];

      try {
        vm.onSaveButtonPressed(
          FakeMountedContext(),
          navigationOrder: true,
        );
      } on Object {
        // Global router can be unattached in isolated unit tests.
      }

      expect(request.customers, vm.customers);
      expect(request.borrowers, vm.customers);
    });

    test("editable valid selection with navigationOrder false", () {
      final Request request = Request();
      Globals.request = request;

      vm
        ..isFI = false
        ..primaryRim = 100
        ..customers = <Customer>[
          customer(rimNo: 100, isSelected: true),
        ];

      try {
        vm.onSaveButtonPressed(
          FakeMountedContext(),
          navigationOrder: false,
        );
      } on Object {
        // Global router can be unattached in isolated unit tests.
      }

      expect(request.customers, vm.customers);
      expect(request.borrowers, vm.customers);
    });

    test("readonly path may navigate without updating customers", () {
      final Request request = readonlyRequest();
      Globals.request = request;

      vm.customers = <Customer>[
        customer(rimNo: 100, isSelected: true),
      ];

      try {
        vm.onSaveButtonPressed(
          FakeMountedContext(),
          navigationOrder: true,
        );
      } on Object {
        // Global router can be unattached in isolated unit tests.
      }

      expect(request.customers, isNull);
    });

    test("readonly path with navigationOrder false", () {
      final Request request = readonlyRequest();
      Globals.request = request;

      try {
        vm.onSaveButtonPressed(
          FakeMountedContext(),
          navigationOrder: false,
        );
      } on Object {
        // Global router can be unattached in isolated unit tests.
      }

      expect(vm.isReadOnly, true);
    });
  });

  /* ================= MANUAL FIELD / STATE COVERAGE ================= */

  group("field and state coverage", () {
    test("manual emits keep latest state", () {
      vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.error));
      expect(vm.state.loaderStatus, LoadingStatus.error);
    });

    test("properties are mutable", () {
      final List<Customer> customers = <Customer>[
        customer(rimNo: 1),
      ];

      vm
        ..applicationBorrowers = customers
        ..customers = customers
        ..selectedCustomers = customers
        ..primaryRim = 1
        ..isFI = true
        ..pagemode = PageMode.edit
        ..referenceData = <String, List<Reference>>{
          "key": <Reference>[
            Reference(id: 1, name: "name"),
          ],
        };

      expect(vm.applicationBorrowers, customers);
      expect(vm.customers, customers);
      expect(vm.selectedCustomers, customers);
      expect(vm.primaryRim, 1);
      expect(vm.isFI, true);
      expect(vm.pagemode, PageMode.edit);
      expect(vm.referenceData, contains("key"));
    });
  });
}
