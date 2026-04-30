import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/model.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/remarks/fee_structure.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class MockBuildContext extends Mock implements BuildContext {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockRouter extends Mock implements GoRouter {}

class FakeFeeStructure extends Fake implements FeeStructure {}

class TestFeeStructureViewModel extends FeeStructureViewModel {
  bool deleteDraftCalled = false;

  @override
  Future<void> deleteDraft() async {
    deleteDraftCalled = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestFeeStructureViewModel viewModel;
  late MockRequestRepository mockRepository;
  late MockAlertManager mockAlertManager;
  late MockBuildContext mockContext;
  late MockRouter mockRouter;

  setUpAll(() async {
    registerFallbackValue(FeeStructure(id: "fallback", feeType: "fallback"));
    registerFallbackValue(<FeeStructure>[]);
    registerFallbackValue(RemarksTabs.feeStructure);
    await EnvConfig.setEnvironment();
  });

  setUp(() {
    mockRepository = MockRequestRepository();
    mockAlertManager = MockAlertManager();
    mockContext = MockBuildContext();
    mockRouter = MockRouter();

    viewModel = TestFeeStructureViewModel()
      ..repository = mockRepository
      ..defaultFeeTypes = <String>[
        "Arrangement Fee",
        "Processing Fee",
        "Commitment Fee",
        "Pre Payment Fee",
        "Breach Of Covenant",
      ];

    AlertManager.overrideInstance(mockAlertManager);
    router = mockRouter;

    Globals.selectedCustomer = null;
    Globals.request = Request(
      applicationRefNo: "APP123",
      borrowers: [Customer(customerRimNo: 999, preferredName: "Borrower One")],
      customers: [Customer(customerRimNo: 123, preferredName: "John Doe")],
    );
  });

  group("constructor and simple getters", () {
    test("starts with loaded state and returns request", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.request.applicationRefNo, "APP123");
    });

    test("isReadOnlyMode and isEdit reflect pageMode", () {
      viewModel.pageMode = PageMode.view;
      expect(viewModel.isReadOnlyMode, isTrue);
      expect(viewModel.isEdit, isFalse);

      viewModel.pageMode = PageMode.edit;
      expect(viewModel.isReadOnlyMode, isFalse);
      expect(viewModel.isEdit, isTrue);

      viewModel.pageMode = PageMode.na;
      expect(viewModel.isReadOnlyMode, isFalse);
      expect(viewModel.isEdit, isFalse);
    });

    test("showViewMore is true only for FI customer types", () {
      viewModel.selectedCustomer =
          Customer(type: CustomerType.investmentGradeBanks);
      expect(viewModel.showViewMore, isTrue);

      viewModel.selectedCustomer =
          Customer(type: CustomerType.belowInvestmentGradeBanks);
      expect(viewModel.showViewMore, isTrue);

      viewModel.selectedCustomer = Customer(type: CustomerType.country);
      expect(viewModel.showViewMore, isFalse);

      viewModel.selectedCustomer = Customer();
      expect(viewModel.showViewMore, isFalse);
    });
  });

  group("customer selection helpers", () {
    test("defaultSelectedCustomer prefers borrower when available", () {
      viewModel.defaultSelectedCustomer();
      expect(viewModel.selectedCustomer?.customerRimNo, 999);
    });

    test("defaultSelectedCustomer falls back to first customer", () {
      Globals.request = Request(
        applicationRefNo: "APP999",
        borrowers: [],
        customers: [
          Customer(customerRimNo: 456, preferredName: "Fallback Customer"),
        ],
      );

      viewModel.defaultSelectedCustomer();
      expect(viewModel.selectedCustomer?.customerRimNo, 456);
    });

    test("setAsterisks completes without throwing", () async {
      viewModel.selectedCustomer = Customer(customerRimNo: 123);
      await viewModel.setAsterisks();
      expect(viewModel.showAsteriskTabs, isA<List<RemarksTabs>>());
    });
  });

  group("row getters", () {
    test("defaultRows inject all missing default rows and marks them not new",
        () {
      viewModel.feeRows = [];
      final defaults = viewModel.defaultRows;

      expect(defaults.length, viewModel.defaultFeeTypes.length);
      expect(defaults.every((row) => !row.isNew), isTrue);
      expect(
        defaults.map((row) => row.feeType).toSet(),
        viewModel.defaultFeeTypes.toSet(),
      );
    });

    test("extraRows returns only non-default fee rows", () {
      viewModel.feeRows = [
        FeeStructure(id: "d1", feeType: viewModel.defaultFeeTypes.first),
        FeeStructure(id: "x1", feeType: "Custom A"),
        FeeStructure(id: "x2", feeType: "Custom B"),
      ];

      final extras = viewModel.extraRows;
      expect(extras.length, 2);
      expect(
        extras.map((e) => e.feeType),
        containsAll(<String>["Custom A", "Custom B"]),
      );
    });

    test("combinedRows returns defaults followed by extra rows", () {
      viewModel.feeRows = [
        FeeStructure(id: "x1", feeType: "Custom A"),
      ];

      final combined = viewModel.combinedRows;

      expect(combined.length, viewModel.defaultFeeTypes.length + 1);
      expect(combined.last.feeType, "Custom A");
    });

    test("combinedRows returns only defaults when feeRows is empty", () {
      viewModel.feeRows = [];
      final combined = viewModel.combinedRows;
      expect(combined.length, viewModel.defaultFeeTypes.length);
    });
  });

  group("getFeeStructureData", () {
    test(
        "populates controllers correctly for N/A, zero, integer, decimal, and numeric amount",
        () async {
      viewModel.selectedCustomer = Customer(customerRimNo: 123);

      final naRow = FeeStructure(
        id: "1",
        feeType: "Custom 1",
        amount: 0,
        comments: "NA comment",
      )..amountRaw = "N/A";
      final zeroRow = FeeStructure(
        id: "2",
        feeType: "Custom 2",
        amount: 0,
        comments: "Zero comment",
      )..amountRaw = "0";
      final integerRow = FeeStructure(
        id: "3",
        feeType: "Custom 3",
        amount: 12,
        comments: "Int comment",
      )..amountRaw = "12";
      final decimalRow = FeeStructure(
        id: "4",
        feeType: "Custom 4",
        amount: 12.5,
        comments: "Decimal comment",
      )..amountRaw = "12.5";
      final amountOnlyRow = FeeStructure(
        id: "5",
        feeType: "Custom 5",
        amount: 7.2,
        comments: "Amount comment",
      );

      when(() => mockRepository.getFeeStructureData(123)).thenAnswer(
        (_) async => <FeeStructure>[
          naRow,
          zeroRow,
          integerRow,
          decimalRow,
          amountOnlyRow,
        ],
      );

      await viewModel.getFeeStructureData();

      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
      expect(
        viewModel.amountControllers.length,
        viewModel.defaultFeeTypes.length + 5,
      );
      expect(
        viewModel.commentsControllers.length,
        viewModel.defaultFeeTypes.length + 5,
      );

      final offset = viewModel.defaultFeeTypes.length;
      expect(viewModel.amountControllers[offset + 0].text, "");
      expect(viewModel.amountControllers[offset + 1].text, "");
      expect(viewModel.amountControllers[offset + 2].text, "12.00");
      expect(viewModel.amountControllers[offset + 3].text, "12.5");
      expect(viewModel.amountControllers[offset + 4].text, "7.20");

      expect(viewModel.commentsControllers[offset + 0].text, "NA comment");
      expect(viewModel.commentsControllers[offset + 4].text, "Amount comment");

      expect(viewModel.displayAmount(naRow), "N/A");
      expect(viewModel.displayAmount(zeroRow), "N/A");
      expect(viewModel.displayAmount(amountOnlyRow), "7.2");
    });

    test("sets error state when repository throws", () async {
      viewModel.selectedCustomer = Customer(customerRimNo: 123);

      when(() => mockRepository.getFeeStructureData(123))
          .thenThrow(Exception("fetch failed"));

      await viewModel.getFeeStructureData();

      expect(viewModel.feeRows, isEmpty);
      expect(viewModel.state.tableLoader, LoadingStatus.error);
    });
  });

  group("displayAmount and onAmountFieldChanged", () {
    test("empty input clears amount/raw and displayAmount becomes empty", () {
      viewModel.defaultFeeTypes = [];
      final row = FeeStructure(id: "1", feeType: "X", amount: 5);
      viewModel.feeRows = [row];
      viewModel.amountControllers = [TextEditingController()];
      viewModel.commentsControllers = [TextEditingController()];

      viewModel.onAmountFieldChanged(0, "");

      expect(row.amount, isNull);
      expect(row.amountRaw, isNull);
      expect(viewModel.displayAmount(row), "");
    });

    test("N/A input stores textual N/A and amount 0.0", () {
      viewModel.defaultFeeTypes = [];
      final row = FeeStructure(id: "1", feeType: "X", amount: null);
      viewModel.feeRows = [row];
      viewModel.amountControllers = [TextEditingController()];
      viewModel.commentsControllers = [TextEditingController()];

      viewModel.onAmountFieldChanged(0, "N/A");

      expect(row.amountRaw, "N/A");
      expect(row.amount, 0.0);
      expect(viewModel.displayAmount(row), "N/A");
    });

    test(
        "valid numeric input preserves exact raw and parses safe length values",
        () {
      viewModel.defaultFeeTypes = [];
      final row = FeeStructure(id: "1", feeType: "X", amount: null);
      viewModel.feeRows = [row];
      viewModel.amountControllers = [TextEditingController()];
      viewModel.commentsControllers = [TextEditingController()];

      viewModel.onAmountFieldChanged(0, "12.5");

      expect(row.amountRaw, "12.5");
      expect(row.amount, 12.5);
      expect(viewModel.displayAmount(row), "12.5");
    });

    test("invalid numeric input keeps raw and leaves parsed amount null", () {
      viewModel.defaultFeeTypes = [];
      final row = FeeStructure(id: "1", feeType: "X", amount: null);
      viewModel.feeRows = [row];
      viewModel.amountControllers = [TextEditingController()];
      viewModel.commentsControllers = [TextEditingController()];

      viewModel.onAmountFieldChanged(0, "invalid");

      expect(row.amountRaw, "invalid");
      expect(row.amount, isNull);
      expect(viewModel.displayAmount(row), "");
    });

    test("oversized numeric input keeps raw and leaves parsed amount null", () {
      viewModel.defaultFeeTypes = [];
      final row = FeeStructure(id: "1", feeType: "X", amount: null);
      viewModel.feeRows = [row];
      viewModel.amountControllers = [TextEditingController()];
      viewModel.commentsControllers = [TextEditingController()];

      viewModel.onAmountFieldChanged(0, "12345678901234567");

      expect(row.amountRaw, "12345678901234567");
      expect(row.amount, isNull);
      expect(viewModel.displayAmount(row), "");
    });

    test("textual zero toggles N/A display for displayAmount", () {
      viewModel.defaultFeeTypes = [];
      final row = FeeStructure(id: "1", feeType: "X", amount: null);
      viewModel.feeRows = [row];
      viewModel.amountControllers = [TextEditingController()];
      viewModel.commentsControllers = [TextEditingController()];

      viewModel.onAmountFieldChanged(0, "0");

      expect(row.amountRaw, "0");
      expect(row.amount, 0.0);
      expect(viewModel.displayAmount(row), "N/A");
    });
  });

  group("mutations", () {
    test("addRow appends row and both controllers", () {
      viewModel.defaultFeeTypes = [];
      viewModel.addRow();

      expect(viewModel.feeRows.length, 1);
      expect(viewModel.amountControllers.length, 1);
      expect(viewModel.commentsControllers.length, 1);
      expect(viewModel.feeRows.first.isNew, isTrue);
      expect(viewModel.feeRows.first.feeType, "");
    });

    test("deleteRow removes local new row and controllers only", () async {
      viewModel.defaultFeeTypes = [];
      final row = FeeStructure(id: "1", feeType: "CustomType", isNew: true);
      viewModel.feeRows = [row];
      viewModel.amountControllers = [TextEditingController()];
      viewModel.commentsControllers = [TextEditingController()];

      await viewModel.deleteRow(row);

      expect(viewModel.feeRows, isEmpty);
      expect(viewModel.amountControllers, isEmpty);
      expect(viewModel.commentsControllers, isEmpty);
      verifyNever(() => mockRepository.deleteFeeStructureData(any()));
    });

    test(
        "deleteRow persisted row calls repository,"
        " reloads data and shows success toast", () async {
      viewModel.defaultFeeTypes = [];
      viewModel.selectedCustomer = Customer(customerRimNo: 123);

      final row = FeeStructure(id: "1", feeType: "X", isNew: false);
      viewModel.feeRows = [row];
      viewModel.amountControllers = [TextEditingController()];
      viewModel.commentsControllers = [TextEditingController()];

      when(() => mockRepository.deleteFeeStructureData(row))
          .thenAnswer((_) async => "deleted");
      when(() => mockRepository.getFeeStructureData(123))
          .thenAnswer((_) async => <FeeStructure>[]);
      when(() => mockAlertManager.showSuccessToast("deleted")).thenReturn(null);

      await viewModel.deleteRow(row);

      verify(() => mockRepository.deleteFeeStructureData(row)).called(1);
      verify(() => mockRepository.getFeeStructureData(123)).called(1);
      verify(() => mockAlertManager.showSuccessToast("deleted")).called(1);
      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });

    test("deleteRow failure shows error toast and error state", () async {
      viewModel.defaultFeeTypes = [];
      final row = FeeStructure(id: "1", feeType: "X", isNew: false);
      viewModel.feeRows = [row];
      viewModel.amountControllers = [TextEditingController()];
      viewModel.commentsControllers = [TextEditingController()];

      when(() => mockRepository.deleteFeeStructureData(row))
          .thenThrow(Exception("fail"));
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.deleteRow(row);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.tableLoader, LoadingStatus.error);
    });
  });

  group("save flow", () {
    test(
        "onSavePress syncs values, defaults appRefNo/rimNo, saves and shows success toast",
        () async {
      viewModel.defaultFeeTypes = [];
      viewModel.selectedCustomer = Customer(customerRimNo: 123);

      final emptyRow = FeeStructure(id: "1", feeType: "Empty", isNew: true);
      final naRow = FeeStructure(id: "2", feeType: "NA", isNew: true);
      final numericRow = FeeStructure(id: "3", feeType: "Numeric", isNew: true);
      final hugeRow = FeeStructure(id: "4", feeType: "Huge", isNew: true);

      viewModel.feeRows = [emptyRow, naRow, numericRow, hugeRow];
      viewModel.amountControllers = [
        TextEditingController(text: ""),
        TextEditingController(text: "N/A"),
        TextEditingController(text: "123.45"),
        TextEditingController(text: "12345678901234567"),
      ];
      viewModel.commentsControllers = [
        TextEditingController(text: "Comment 1"),
        TextEditingController(text: "Comment 2"),
        TextEditingController(text: "Comment 3"),
        TextEditingController(text: "Comment 4"),
      ];

      when(() => mockRepository.saveFeeStructure(any()))
          .thenAnswer((_) async => "ok");
      when(() => mockRepository.getFeeStructureData(123))
          .thenAnswer((_) async => <FeeStructure>[]);
      when(() => mockAlertManager.showSuccessToast("ok")).thenReturn(null);

      await viewModel.onSavePress(false, mockContext);

      verify(() => mockRepository.saveFeeStructure(any())).called(1);
      verify(() => mockRepository.getFeeStructureData(123)).called(1);
      verify(() => mockAlertManager.showSuccessToast("ok")).called(1);

      expect(viewModel.deleteDraftCalled, true);

      expect(emptyRow.amountRaw, isNull);
      expect(emptyRow.amount, isNull);
      expect(emptyRow.comments, "Comment 1");

      expect(naRow.amountRaw, "N/A");
      expect(naRow.amount, 0.0);
      expect(naRow.comments, "Comment 2");

      expect(numericRow.amountRaw, "123.45");
      expect(numericRow.amount, 123.45);
      expect(numericRow.comments, "Comment 3");

      expect(hugeRow.amountRaw, "12345678901234567");
      expect(hugeRow.amount, isNull);
      expect(hugeRow.comments, "Comment 4");

      for (final row in <FeeStructure>[emptyRow, naRow, numericRow, hugeRow]) {
        expect(row.appRefNo, "APP123");
        expect(row.rimNo, 123);
      }

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onSavePress handles save error gracefully", () async {
      viewModel.defaultFeeTypes = [];
      viewModel.selectedCustomer = Customer(customerRimNo: 123);

      final row = FeeStructure(id: "1", feeType: "X", isNew: true);
      viewModel.feeRows = [row];
      viewModel.amountControllers = [TextEditingController(text: "N/A")];
      viewModel.commentsControllers = [TextEditingController(text: "Comment")];

      when(() => mockRepository.saveFeeStructure(any()))
          .thenThrow(Exception("Save failed"));
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.onSavePress(false, mockContext);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.deleteDraftCalled, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets(
        "onSavePress with continue=true navigates to rmCertification route",
        (tester) async {
      viewModel.defaultFeeTypes = [];
      viewModel.selectedCustomer = Customer(customerRimNo: 123);

      final row = FeeStructure(id: "1", feeType: "X", isNew: true);
      viewModel.feeRows = [row];
      viewModel.amountControllers = [TextEditingController(text: "10")];
      viewModel.commentsControllers = [TextEditingController(text: "Comment")];

      when(() => mockRepository.saveFeeStructure(any()))
          .thenAnswer((_) async => "ok");
      when(() => mockRepository.getFeeStructureData(123))
          .thenAnswer((_) async => <FeeStructure>[]);
      when(() => mockAlertManager.showSuccessToast("ok")).thenReturn(null);

      late BuildContext pageContext;
      final appRouter = GoRouter(
        initialLocation: "/",
        routes: <RouteBase>[
          GoRoute(
            path: "/",
            builder: (context, state) {
              pageContext = context;
              return const Scaffold(body: Text("Home"));
            },
          ),
          GoRoute(
            path: Routes.rmCertification,
            builder: (context, state) =>
                const Scaffold(body: Text("RM Certification")),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      await tester.pumpAndSettle();

      await viewModel.onSavePress(true, pageContext);
      await tester.pumpAndSettle();

      expect(viewModel.deleteDraftCalled, true);
      expect(find.text("RM Certification"), findsOneWidget);
    });
  });

  group("other flows", () {
    test("init fetches fee data and ends in loaded state", () async {
      when(() => mockRepository.getFeeStructureData(any()))
          .thenAnswer((_) async => <FeeStructure>[]);

      await viewModel.init(mockContext);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
      expect(viewModel.selectedCustomer, isNotNull);
    });

    test(
        "onCustomerChanged "
        "updates selected "
        "customer, global customer and reloads data", () async {
      final customer = Customer(customerRimNo: 456, preferredName: "Jane");
      when(() => mockRepository.getFeeStructureData(456))
          .thenAnswer((_) async => <FeeStructure>[]);

      await viewModel.onCustomerChanged(customer);

      expect(viewModel.selectedCustomer, customer);
      expect(Globals.selectedCustomer, customer);
      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });

    test("changeTab navigates using global router", () async {
      const tab = RemarksTabs.feeStructure;
      when(() => mockRouter.go(any(), extra: any(named: "extra")))
          .thenReturn(null);

      await viewModel.changeTab(tab);

      verify(() => mockRouter.go(TabConstants.remarksRoutes[tab]!, extra: tab))
          .called(1);
    });

    test("close completes without throwing", () async {
      await expectLater(viewModel.close(), completes);
    });
  });
}
