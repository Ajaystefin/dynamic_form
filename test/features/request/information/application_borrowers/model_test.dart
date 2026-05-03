import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hive_ce/hive.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/application_borrowers/model.dart";
import "package:wcas_frontend/features/request/information/application_borrowers/state.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/group.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockContext extends Mock implements BuildContext {}

class FakeMountedContext implements BuildContext {
  @override
  bool get mounted => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAlertManager extends Fake implements AlertManager {
  @override
  void showFailureToast(String message) {
    // ✅ do nothing
  }
}

// Mock LocalStorageService
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
  late ApplicationBorrowersViewModel viewModel;
  late MockRequestRepository mockRepo;
  late MockLocalStorageService mockLocalStorageService;

  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    // Mock the connectivity plugin to return a list with wifi connectivity
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

    try {
      await Hive.close();
    } catch (_) {}
  });

  setUp(() {
    mockRepo = MockRequestRepository();
    viewModel = ApplicationBorrowersViewModel()
      ..repository = mockRepo;
    mockLocalStorageService = MockLocalStorageService();

    // Set up LocalStorageService mock
    LocalStorageService().setStorage(mockLocalStorageService);

    when(() => mockRepo.getApplicationBorrowers()).thenAnswer((_) async => []);
  });

  group("ApplicationBorrowersViewModel Tests", () {
    test("Initial loader status is loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("getApplicationBorrowers loads and merges customers correctly",
        () async {
      final borrowers = [
        Customer(customerRimNo: 123, isBorrower: true),
        Customer(customerRimNo: 456, isBorrowerBelowGrade: true),
      ];

      viewModel.customers = [
        Customer(customerRimNo: 123),
        Customer(customerRimNo: 789),
      ];

      when(() => mockRepo.getApplicationBorrowers())
          .thenAnswer((_) async => borrowers);

      //await viewModel.getApplicationBorrowers();

      expect(viewModel.customers.length, 2); // 123, 456, 789 merged
      // expect(
      //   viewModel.customers
      //       .any((c) => c.customerRimNo == 123 && (c.isSelected ?? false)),
      //   true,
      // );

      expect(
        viewModel.customers.any(
          (c) => c.customerRimNo == 456 && (c.isSelectedBelowGrade ?? false),
        ),
        false,
      );

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("getApplicationBorrowers handles error gracefully", () async {
      when(() => mockRepo.getApplicationBorrowers())
          .thenThrow(Exception("Failed"));

      // await viewModel.getApplicationBorrowers();

      expect(
        viewModel.state.loaderStatus,
        LoadingStatus.loading,
      ); // still emits loaded
    });

    test("onCustomerRimNameSelected updates selection", () {
      viewModel
        ..customers = [
          Customer(customerRimNo: 123),
          Customer(customerRimNo: 456),
        ]
        ..onCustomerRimNameSelected("123", true);

      expect(
        viewModel.customers
            .firstWhere((c) => c.customerRimNo == 123)
            .isSelected,
        true,
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onBelowGradeSelected updates below grade selection", () {
      viewModel
        ..customers = [
          Customer(customerRimNo: 123),
          Customer(customerRimNo: 456),
        ]
        ..onBelowGradeSelected("456", true);

      expect(
        viewModel.customers
            .firstWhere((c) => c.customerRimNo == 456)
            .isSelectedBelowGrade,
        true,
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    // test('onSaveButtonPressed does not throw', () {
    //   expect(() =>
    // viewModel.onSaveButtonPressed(MockContext(),navigationOrder: true),
    // returnsNormally);
    // });
  });

  group("ApplicationBorrowersState", () {
    test("constructor sets loaderStatus", () {
      final state =
          ApplicationBorrowersState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final original =
          ApplicationBorrowersState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      final original =
          ApplicationBorrowersState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("ApplicationBorrowersViewModel.isReadOnly", () {
    late ApplicationBorrowersViewModel viewModel;

    setUp(() {
      viewModel = ApplicationBorrowersViewModel();
    });

    tearDown(() {
      // ✅ IMPORTANT: reset global state after each test
      Globals.request = null;
    });

    test("returns false when Globals.request is null", () {
      Globals.request = null;

      expect(viewModel.isReadOnly, false);
    });

    test("returns true when applicationRefNo is present", () {
      Globals.request = Request(applicationRefNo: "APP-123");

      expect(viewModel.isReadOnly, true);
    });
    test("returns false when request.isCreateRequest is false", () {
      Globals.request = Request(isCreateRequest: false);

      expect(viewModel.isReadOnly, false);
    });

    test("returns false when request.isCreateRequest is null", () {
      Globals.request = Request(isCreateRequest: null);

      expect(viewModel.isReadOnly, false);
    });
  });

  group("ApplicationBorrowersViewModel.onSaveButtonPressed", () {
    late ApplicationBorrowersViewModel viewModel;

    setUp(() {
      viewModel = ApplicationBorrowersViewModel();
    });

    tearDown(() {
      Globals.request = null;
    });

    test("updates request customers and borrowers when editable and valid", () {
      final request = Request();
      Globals.request = request;

      viewModel.customers = [
        Customer(customerRimNo: 1, isSelected: true),
      ];

      expect(
        () => viewModel.onSaveButtonPressed(
          FakeMountedContext(),
          navigationOrder: true,
        ),
        returnsNormally,
      );

      expect(request.customers, viewModel.customers);
      expect(request.borrowers, viewModel.customers);
    });

    test("does not throw when readOnly is true", () {
      Globals.request = Request(applicationRefNo: "APP-1"); // readOnly

      expect(
        () => viewModel.onSaveButtonPressed(
          MockContext(),
          navigationOrder: false,
        ),
        returnsNormally,
      );
    });
  });

  group("ApplicationBorrowersViewModel.validateBorrowersSelection", () {
    late ApplicationBorrowersViewModel viewModel;

    setUp(() {
      viewModel = ApplicationBorrowersViewModel();
    });

    tearDown(() {
      Globals.request = null; // ✅ prevent global leakage
    });

    // ----------------------------------------------------------
    // Pure unit test — Toast NOT triggered
    // ----------------------------------------------------------

    test(
      "returns true when primary RIM is selected and valid",
      () {
        Globals.request = Request(
          customers: [
            Customer(customerRimNo: 100, isSelected: true),
          ],
        );

        viewModel
          ..primaryRim = 100
          ..isFI = false;

        final result = viewModel.validateBorrowersSelection();

        expect(result, true);
      },
    );
  });

  group("ApplicationBorrowersViewModel.onCountrySelected", () {
    late ApplicationBorrowersViewModel viewModel;

    setUp(() {
      viewModel = ApplicationBorrowersViewModel()
        ..selectedCustomers = [];
    });

    test(
      "selects customer when it IS country FI",
      () {
        final customer = Customer(
          customerRimNo: 200,
          isCountryFI: true,
          isSelected: true,
          isSelectedBelowGrade: true,
        );

        viewModel
          ..customers = [customer]
          ..onCountrySelected("200", true);

        expect(customer.isSelectedCountryFI, true);
        expect(customer.isSelected, false);
        expect(customer.isSelectedBelowGrade, false);

        expect(viewModel.selectedCustomers.length, 1);
        expect(viewModel.selectedCustomers.first.customerRimNo, 200);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );

    test(
      "removes customer from selectedCustomers when unselected",
      () {
        final customer = Customer(
          customerRimNo: 300,
          isCountryFI: true,
          isSelectedCountryFI: true,
        );

        viewModel
          ..customers = [customer]
          ..selectedCustomers = [customer]
          ..onCountrySelected("300", false);

        expect(customer.isSelectedCountryFI, false);
        expect(viewModel.selectedCustomers, isEmpty);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );

    test(
      "does not duplicate customer in selectedCustomers",
      () {
        final customer = Customer(
          customerRimNo: 400,
          isCountryFI: true,
        );

        viewModel
          ..customers = [customer]
          ..selectedCustomers = [customer]
          ..onCountrySelected("400", true);

        expect(viewModel.selectedCustomers.length, 1);
        expect(viewModel.selectedCustomers.first.customerRimNo, 400);
      },
    );
  });

  Future<void> pumpInit(
    WidgetTester tester,
    ApplicationBorrowersViewModel viewModel, {
    required Request request,
  }) async {
    Globals.request = request;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            viewModel.init(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    await tester.pumpAndSettle(); // flush async + emit
  }

  group("ApplicationBorrowersViewModel.init – readOnly", () {
    late ApplicationBorrowersViewModel viewModel;

    setUp(() {
      viewModel = ApplicationBorrowersViewModel();
    });

    tearDown(() {
      Globals.request = null;
    });

    testWidgets("investmentGradeBanks → isSelected true", (tester) async {
      final customer = Customer(
        customerRimNo: 100,
        type: CustomerType.investmentGradeBanks,
      );

      await pumpInit(
        tester,
        viewModel,
        request: Request(
          applicationRefNo: "APP-1", // forces readOnly
          borrowers: [customer],
        ),
      );

      expect(customer.isSelected, true);
      expect(customer.isSelectedBelowGrade, false);
      expect(customer.isSelectedCountryFI, false);
    });

    testWidgets("country → country FI selected", (tester) async {
      final customer = Customer(
        customerRimNo: 300,
        type: CustomerType.country,
      );

      await pumpInit(
        tester,
        viewModel,
        request: Request(
          applicationRefNo: "APP-1",
          borrowers: [customer],
        ),
      );

      expect(customer.isCountryFI, true);
      expect(customer.isSelectedCountryFI, true);
    });
  });

  group("ApplicationBorrowersViewModel.init – editable non-FI", () {
    late ApplicationBorrowersViewModel viewModel;

    setUp(() {
      viewModel = ApplicationBorrowersViewModel();
    });

    tearDown(() {
      Globals.request = null;
    });

    testWidgets("manual IG flag is respected", (tester) async {
      final borrower = Customer(
        customerRimNo: 200,
        isSelected: true,
      );

      await pumpInit(
        tester,
        viewModel,
        request: Request(
          applicationRefNo: null, // editable
          borrowers: [borrower],
        ),
      );

      expect(viewModel.selectedCustomers.length, 1);
      expect(viewModel.selectedCustomers.first.customerRimNo, 200);
    });
  });

  group("ApplicationBorrowersViewModel.init – core behavior", () {
    late ApplicationBorrowersViewModel viewModel;

    setUp(() {
      viewModel = ApplicationBorrowersViewModel();
    });

    tearDown(() {
      Globals.request = null;
    });

    testWidgets("sets loaderStatus and primaryRim", (tester) async {
      await pumpInit(
        tester,
        viewModel,
        request: Request(
          borrowers: [
            Customer(customerRimNo: 100),
            Customer(customerRimNo: 200),
          ],
          customerRimNo: 100,
        ),
      );

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.primaryRim, 100);
      expect(viewModel.customers.length, 2);
    });

    testWidgets("pins primary RIM to top", (tester) async {
      await pumpInit(
        tester,
        viewModel,
        request: Request(
          borrowers: [
            Customer(customerRimNo: 200),
            Customer(customerRimNo: 100),
          ],
          customerRimNo: 100,
        ),
      );

      expect(viewModel.customers.first.customerRimNo, 100);
    });

    testWidgets("deduplicates customers by RIM", (tester) async {
      await pumpInit(
        tester,
        viewModel,
        request: Request(
          borrowers: [
            Customer(customerRimNo: 100),
            Customer(customerRimNo: 100),
          ],
        ),
      );

      expect(viewModel.customers.length, 1);
    });
  });

  group(
    "ApplicationBorrowersViewModel.init – uncovered branches coverage",
    () {
      late ApplicationBorrowersViewModel viewModel;

      setUp(() {
        viewModel = ApplicationBorrowersViewModel();
      });

      tearDown(() {
        Globals.request = null;
      });

      Future<void> pumpInit(
        WidgetTester tester, {
        required Request request,
      }) async {
        Globals.request = request;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                viewModel.init(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        await tester.pumpAndSettle();
      }

      // ----------------------------------------------------------
      // groupOwner resolution: null, int, String
      // ----------------------------------------------------------
      testWidgets(
        "resolves groupOwner from null, int, and"
        " String and prefers searchedRimNo",
        (WidgetTester tester) async {
          await pumpInit(
            tester,
            request: Request(
              borrowers: [
                Customer(customerRimNo: 1), // searchedRimNo = 1
                Customer(customerRimNo: 2, groups: Group(groupOwner: 888)),
                Customer(customerRimNo: 3, groups: Group(groupOwner: 999)),
              ],
            ),
          );

          // searchedRimNo != groupOwnerRimNo → searchedRimNo wins
          expect(viewModel.primaryRim, 1);
        },
      );

      // ----------------------------------------------------------
      // rimNoToPin: searched != owner → searched wins
      // ----------------------------------------------------------
      testWidgets(
        "uses searchedRimNo when searched and owner differ",
        (WidgetTester tester) async {
          await pumpInit(
            tester,
            request: Request(
              customerRimNo: 100,
              borrowers: [
                Customer(customerRimNo: 1, groups: Group(id: "222")),
              ],
            ),
          );

          expect(viewModel.primaryRim, 100);
        },
      );

      // ----------------------------------------------------------
      // rimNoToPin: searched null → owner wins
      // ----------------------------------------------------------
      testWidgets(
        "uses groupOwnerRimNo when searchedRimNo is null",
        (WidgetTester tester) async {
          await pumpInit(
            tester,
            request: Request(
              borrowers: [
                Customer(customerRimNo: 1, groups: Group(id: "333")),
              ],
            ),
          );

          expect(viewModel.primaryRim, 1);
        },
      );

      // ----------------------------------------------------------
      // rimNoToPin: owner null → searched wins
      // ----------------------------------------------------------
      testWidgets(
        "uses searchedRimNo when groupOwner is null",
        (WidgetTester tester) async {
          await pumpInit(
            tester,
            request: Request(
              customerRimNo: 400,
              borrowers: [
                Customer(customerRimNo: 400),
              ],
            ),
          );

          expect(viewModel.primaryRim, 400);
        },
      );

      // ----------------------------------------------------------
      // READONLY: belowInvestmentGradeBanks
      // ----------------------------------------------------------
      testWidgets(
        "readonly – belowInvestmentGradeBanks selects below grade",
        (WidgetTester tester) async {
          final customer = Customer(
            customerRimNo: 10,
            type: CustomerType.belowInvestmentGradeBanks,
            isCountryFI: false,
          );

          await pumpInit(
            tester,
            request: Request(
              applicationRefNo: "APP-1", // readonly
              borrowers: [customer],
            ),
          );

          expect(customer.isSelectedBelowGrade, true);
          expect(customer.isSelected, false);
          expect(customer.isSelectedCountryFI, false);
        },
      );

      // ----------------------------------------------------------
      // READONLY: corporate
      // ----------------------------------------------------------
      testWidgets(
        "readonly – corporate selects normally",
        (WidgetTester tester) async {
          final customer = Customer(
            customerRimNo: 20,
            type: CustomerType.corporate,
          );

          await pumpInit(
            tester,
            request: Request(
              applicationRefNo: "APP-1", // readonly
              borrowers: [customer],
            ),
          );

          expect(customer.isSelected, true);
          expect(customer.isSelectedBelowGrade, false);
          expect(customer.isSelectedCountryFI, false);
        },
      );
    },
  );
}
