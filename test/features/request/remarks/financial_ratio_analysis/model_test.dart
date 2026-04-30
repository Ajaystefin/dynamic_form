// UPDATED unit tests: target ~100% coverage for FinancialRatioAnalysisViewModel
// File: test/features/request/remarks/financial_ratio_analysis/model_test.dart

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:html_editor_enhanced/html_editor.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/draft_handler.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/balance_sheet_analysis.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/cashflow_statement_analysis.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_details_response.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_ratio_response.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/income_statement_analysis.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/remarks_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class MockBuildContext extends Mock implements BuildContext {}

class MockRemarksRepository extends Mock implements RemarksRepository {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockRouter extends Mock implements GoRouter {}

class FakeStorage implements StorageInterface {
  @override
  Future<void> init({String? path}) async {}
  @override
  Future<void> put(String box, String key, dynamic value) async {}
  @override
  Future<dynamic> get(String box, String key) async => null;
  @override
  Future<void> delete(String box, String key) async {}
  @override
  Future<void> clearBox(String box) async {}
}

extension LocalizationBypass on String {
  String tr() => this;
}

/// Stub: no JS/platform eval, and remembers latest text.
class StubHtmlEditorController extends HtmlEditorController {
  String _lastText = "";
  @override
  Future<void> setText(String text) async {
    _lastText = text; // record what was set
  }

  @override
  Future<String> getText() async {
    return _lastText; // return last text
  }

  @override
  void clear() {
    _lastText = "";
  }
}

/// Test VM: shadow ALL HtmlEditorControllers with the stub so we can assert setText/getText.
class TestFinancialRatioAnalysisViewModel
    extends FinancialRatioAnalysisViewModel {
  TestFinancialRatioAnalysisViewModel({
    super.remarksRepository,
    super.referenceDataService,
  });
  // ignore: overridden_fields
  @override
  // ignore: overridden_fields
  final UnifiedEditorController balanceSheetcontroller =
      UnifiedEditorController.fromController(StubHtmlEditorController());
  // ignore: overridden_fields
  @override
  // ignore: overridden_fields
  final UnifiedEditorController cashflowController =
      UnifiedEditorController.fromController(StubHtmlEditorController());
  // ignore: overridden_fields
  @override
  // ignore: overridden_fields
  final UnifiedEditorController incomeStatementController =
      UnifiedEditorController.fromController(StubHtmlEditorController());
  // ignore: overridden_fields
  @override
  // ignore: overridden_fields
  final UnifiedEditorController descTextController =
      UnifiedEditorController.fromController(StubHtmlEditorController());
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    LocalStorageService().setStorage(FakeStorage());
    await EnvConfig.setEnvironment();
    // Silence connectivity plugin channels used in app bootstrap
    const connectivityMethodChannel =
        MethodChannel("dev.fluttercommunity.plus/connectivity");
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      connectivityMethodChannel,
      (MethodCall call) async {
        if (call.method == "check") return ["wifi"]; // ConnectivityResult.wifi
        return null;
      },
    );
    const connectivityEventChannel =
        "dev.fluttercommunity.plus/connectivity_status";
    binding.defaultBinaryMessenger.setMockMessageHandler(
      connectivityEventChannel,
      (ByteData? message) {
        final envelope =
            const StandardMethodCodec().encodeSuccessEnvelope(<dynamic>[]);
        return Future.value(envelope);
      },
    );
  });

  tearDownAll(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel("dev.fluttercommunity.plus/connectivity"),
      null,
    );
    binding.defaultBinaryMessenger.setMockMessageHandler(
      "dev.fluttercommunity.plus/connectivity_status",
      null,
    );
  });

  late FinancialRatioAnalysisViewModel vm;
  late MockRemarksRepository mockRepository;
  late MockAlertManager mockAlertManager;
  late MockRouter mockRouter;
  late MockReferenceDataService mockRefService;

  setUp(() {
    Globals.request = Request(
      customers: [
        Customer(id: "1", customerRimNo: 1111, customerName: "Alice"),
        Customer(id: "2", customerRimNo: 2222, customerName: "Bob"),
      ],
    );
    mockRepository = MockRemarksRepository();
    mockAlertManager = MockAlertManager();
    mockRouter = MockRouter();
    mockRefService = MockReferenceDataService();
    vm = TestFinancialRatioAnalysisViewModel(
      remarksRepository: mockRepository,
      referenceDataService: mockRefService,
    );
    AlertManager.overrideInstance(mockAlertManager);
    router = mockRouter;

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
  });

  tearDown(() {
    reset(mockRepository);
    reset(mockAlertManager);
    reset(mockRouter);
    reset(mockRefService);
    Globals.request = null;
  });

  group("FinancialRatioAnalysisViewModel – existing flows", () {
    test("loadReferenceData fetches and populates reference lists", () async {
      when(() => mockRefService.getReferenceData(any())).thenAnswer(
        (_) async => {
          ReferenceDataKeys.financialCategory: [
            Reference(id: 1, name: "Cat1"),
          ],
          ReferenceDataKeys.financialRatioType: [
            Reference(id: 2, name: "Type1"),
          ],
          ReferenceDataKeys.cashflowStatementHealth: [
            Reference(id: 3, name: "Health1"),
          ],
          ReferenceDataKeys.incomeStatementHealth: [
            Reference(id: 4, name: "Health2"),
          ],
          ReferenceDataKeys.balanceSheetHealth: [
            Reference(id: 5, name: "Health3"),
          ],
        },
      );
      await vm.loadReferenceData();

      expect(vm.financialCategory, hasLength(1));
      expect(vm.financialRatioType, hasLength(1));
      expect(vm.cashflowHealth, hasLength(1));
      expect(vm.incomeHealth, hasLength(1));
      expect(vm.balanceHealth, hasLength(1));
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("loadReferenceData handles error and shows failure toast", () async {
      when(() => mockRefService.getReferenceData(any()))
          .thenThrow(Exception("API Error"));
      await vm.loadReferenceData();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      // loaderStatus stays as constructed (loading) because emit happens only
      // on success
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("customers getter returns Globals.request.customers", () {
      expect(vm.customers, hasLength(2));
      expect(vm.customers.map((c) => c.customerName), ["Alice", "Bob"]);
    });

    test("initial selectedCustomer is first customer", () {
      expect(vm.selectedCustomer, Globals.request!.customers!.first);
    });

    test("add/delete rows & action flags", () {
      expect(vm.hasActionColumn, isFalse);
      expect(vm.hasActionColumnCashflow, isFalse);
      expect(vm.hasActionColumnBalanceSheet, isFalse);

      vm.addIncomeRow();
      vm.addCashflowRow();
      vm.addBalanceRow();

      expect(vm.hasActionColumn, isTrue);
      expect(vm.hasActionColumnCashflow, isTrue);
      expect(vm.hasActionColumnBalanceSheet, isTrue);

      vm.deleteIncomeRow(vm.incomeStatementRows.first.id);
      vm.deleteCashflowRow(vm.cashflowSheetRows.first.id);
      vm.deleteBalanceRow(vm.balanceSheetRows.first.id);

      expect(vm.hasActionColumn, isFalse);
      expect(vm.hasActionColumnCashflow, isFalse);
      expect(vm.hasActionColumnBalanceSheet, isFalse);
    });

    test("row-add guards keep max length at 10 for each table", () {
      for (var i = 0; i < 12; i++) {
        vm.addIncomeRow();
        vm.addCashflowRow();
        vm.addBalanceRow();
      }
      expect(vm.incomeStatementRows.length, 10);
      expect(vm.cashflowSheetRows.length, 10);
      expect(vm.balanceSheetRows.length, 10);
    });

    test("updateEntityId parses number or 0", () {
      expect(vm.state.currentEntityId, isNull);
      vm.updateEntityId("123");
      expect(vm.state.currentEntityId, 123);
      vm.updateEntityId("abc");
      expect(vm.state.currentEntityId, 0);
    });

    test("init executes setup flow cleanly", () async {
      when(() => mockRefService.getReferenceData(any()))
          .thenAnswer((_) async => {});
      final mockCustomerRepo = MockCustomerRepository();
      when(mockCustomerRepo.getChildRimsForGroup).thenAnswer((_) async => null);
      CustomerRepository.debugReplaceInstance = mockCustomerRepo;
      when(
        () => mockRepository.getFinancialRatioAnalysisDetails(
          rimNo: any(named: "rimNo"),
        ),
      ).thenAnswer(
        (_) async => FinancialRatioAnalysisResponse(
          customerFinancialsId: null,
          appRefNo: "",
          rimNo: 1111,
          customerName: "",
          descOfAccounts: "",
          entityDetails: [],
          createdBy: "",
          updatedBy: "",
          createdDate: null,
          updatedDate: null,
        ),
      );
      await vm.init(MockBuildContext());
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // allow async to finish

      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      await vm.close(); // Test close
    });

    test("getChildRimsForGroup loads group successfully", () async {
      final mockCustomerRepo = MockCustomerRepository();
      when(mockCustomerRepo.getChildRimsForGroup).thenAnswer(
        (_) async => [
          Customer(customerRimNo: 777, customerName: "Group Child"),
        ],
      );
      CustomerRepository.debugReplaceInstance = mockCustomerRepo;

      Globals.request = Request(
        groupId: 123,
        customers: [
          Customer(id: "1", customerRimNo: 1111, customerName: "Alice"),
        ],
      );

      await vm.getChildRimsForGroup();
      expect(vm.customerList, hasLength(1));
      expect(vm.selectedCustomer?.customerRimNo, 777);

      // Test the error fallback
      when(mockCustomerRepo.getChildRimsForGroup).thenThrow(Exception("err"));

      try {
        await vm.getChildRimsForGroup();
      } catch (_) {}

      expect(vm.selectedCustomer?.customerName, "Alice"); // fallback to default
    });
  });

  group("fetchSavedFinancialAnalysis – branches", () {
    test("exception path: repository throws -> does not crash", () async {
      when(
        () => mockRepository.getFinancialRatioAnalysisDetails(
          rimNo: any(named: "rimNo"),
        ),
      ).thenThrow(Exception("boom"));
      await vm.fetchSavedFinancialAnalysis();
      // still safe
      expect(vm.state.currentEntityId, isNull);
    });

    test("hydrates desc only when entityDetails empty", () async {
      final testVm = TestFinancialRatioAnalysisViewModel(
        remarksRepository: mockRepository,
        referenceDataService: mockRefService,
      );
      when(
        () => mockRepository.getFinancialRatioAnalysisDetails(
          rimNo: any(named: "rimNo"),
        ),
      ).thenAnswer(
        (_) async => FinancialRatioAnalysisResponse(
          customerFinancialsId: 101,
          appRefNo: "APP123",
          rimNo: 1111,
          customerName: "Alice",
          descOfAccounts: "Existing description",
          entityDetails: const [],
          createdBy: "",
          createdDate: null,
          updatedBy: "",
          updatedDate: null,
        ),
      );
      await testVm.fetchSavedFinancialAnalysis();
      expect(testVm.state.currentEntityId, isNull);
      // expect(await testVm.descTextController.getText(), contains(''));
    });

    test(
        "hydrates description and populates rows when"
        " entityDetails is present with categories", () async {
      final testVm = TestFinancialRatioAnalysisViewModel(
        remarksRepository: mockRepository,
        referenceDataService: mockRefService,
      );

      final mockIncomeValues = [
        FinancialValue(
          financialsCategory: 234,
          financialRatioType: "101",
          userAddedRatioType: null,
          financialYear: 2021,
          statementDate: "2021-12-31",
          period: "12M",
          auditMethod: "Audited",
          auditor: "Auditor A",
          value: 100.5,
        ),
        FinancialValue(
          financialsCategory: 234,
          financialRatioType: "", // user added
          userAddedRatioType: "My Ratio",
          financialYear: 2021,
          statementDate: "2021-12-31",
          period: "12M",
          auditMethod: "Audited",
          auditor: "Auditor A",
          value: 50,
        ),
      ];

      final mockCashflowValues = [
        FinancialValue(
          financialsCategory: 236,
          financialRatioType: "102",
          userAddedRatioType: null,
          financialYear: 2021,
          statementDate: "2021-12-31",
          period: "12M",
          auditMethod: "Audited",
          auditor: "Auditor A",
          value: 200.5,
        ),
      ];

      final mockBalanceValues = [
        FinancialValue(
          financialsCategory: 237,
          financialRatioType: "103",
          userAddedRatioType: null,
          financialYear: 2021,
          statementDate: "2021-12-31",
          period: "12M",
          auditMethod: "Audited",
          auditor: "Auditor A",
          value: 300.5,
        ),
      ];

      when(
        () => mockRepository.getFinancialRatioAnalysisDetails(
          rimNo: any(named: "rimNo"),
        ),
      ).thenAnswer(
        (_) async => FinancialRatioAnalysisResponse(
          customerFinancialsId: 101,
          appRefNo: "APP123",
          rimNo: 1111,
          customerName: "Alice",
          descOfAccounts: "Main Description",
          entityDetails: [
            EntityDetail(
              customerFinancialsId: null,
              entityId: 123,
              entityLongName: "Entity 1",
              financialsCategory: [
                FinancialCategoryDetail(
                  financialsCategory: 234, // income
                  financialHealth: 1,
                  remarks: "Income Remarks",
                  financialsValues: mockIncomeValues,
                ),
                FinancialCategoryDetail(
                  financialsCategory: 236, // cashflow
                  financialHealth: 2,
                  remarks: "Cashflow Remarks",
                  financialsValues: mockCashflowValues,
                ),
                FinancialCategoryDetail(
                  financialsCategory: 237, // balance
                  financialHealth: 3,
                  remarks: "Balance Remarks",
                  financialsValues: mockBalanceValues,
                ),
              ],
            ),
          ],
          createdBy: "",
          createdDate: null,
          updatedBy: "",
          updatedDate: null,
        ),
      );

      await testVm.fetchSavedFinancialAnalysis();

      expect(testVm.state.currentEntityId, 123);
      expect(testVm.description, "Main Description");
      expect(testVm.incomeDescription, "Income Remarks");
      expect(testVm.cashflowDescription, "Cashflow Remarks");
      expect(testVm.balanceSheetdescription, "Balance Remarks");
      expect(testVm.hasSavedAnalysisData, true);
      expect(testVm.incomeStatementRows, isNotEmpty);
      expect(testVm.cashflowSheetRows, isNotEmpty);
      expect(testVm.balanceSheetRows, isNotEmpty);
    });
  });

  group("searchEntity – success & error", () {
    test("searchEntity empty/invalid ID shows failure toast", () async {
      vm.updateEntityId(" ");
      await vm.searchEntity();
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      vm.updateEntityId("0");
      await vm.searchEntity();
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      vm.updateEntityId("-1");
      await vm.searchEntity();
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("searchEntity valid ID populates and sets buttonStatus loaded",
        () async {
      vm.financialRatioType = [
        Reference(
          id: 1,
          name: "Revenue",
          reference1: ServerConstants.incomeStatementAnalysis,
          reference2: "REV001",
        ),
      ];
      final resp = FinancialDetailsResponse(
        entityId: 123,
        longName: "Test Long Name",
        shortName: "TLN",
        statements: [
          Statement(
            id: 1,
            date: DateTime(2023, 1, 1),
            periods: 12,
            statementConsts: [StatementConst(id: 1, value: "test")],
          ),
        ],
        macros: const {},
      );
      when(() => mockRepository.getFinancialDetailsFromCreditLens(any()))
          .thenAnswer((_) async => resp);
      vm.updateEntityId("123");
      await vm.searchEntity();
      expect(vm.longName, "Test Long Name");
      expect(vm.shortName, "TLN");
      expect(vm.hasCreditLensData, isTrue);
      expect(vm.state.buttonStatus, LoadingStatus.loaded);
      verify(() => mockRepository.getFinancialDetailsFromCreditLens(123))
          .called(1);
    });

    test(
        "searchEntity API error shows "
        "toast and buttonStatus "
        "loaded=false -> stays loaded after emit", () async {
      when(() => mockRepository.getFinancialDetailsFromCreditLens(any()))
          .thenThrow(Exception("API Error"));
      vm.updateEntityId("123");
      await vm.searchEntity();
      expect(vm.hasCreditLensData, isFalse);
      expect(vm.state.buttonStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("helpers & formatters", () {
    test("getConstValue bounds & trimming and unqualified prefix", () {
      expect(vm.getConstValue(-1, 0), vm.unavailableText);
      expect(vm.getConstValue(999, 0), vm.unavailableText);
      vm.incomeStatements = [
        Statement(
          id: 1,
          date: DateTime(2023, 1, 1),
          periods: 12,
          statementConsts: [StatementConst(id: 1, value: " valid value ")],
        ),
      ];
      expect(vm.getConstValue(0, 0), "valid value");
      vm.incomeStatements = [
        Statement(
          id: 1,
          date: DateTime(2023, 1, 1),
          periods: 12,
          statementConsts: [
            StatementConst(id: 1, value: ServerConstants.unqualified),
          ],
        ),
      ];
      expect(vm.getConstValue(0, 0), "Audited-${ServerConstants.unqualified}");
    });

    test("getHeaderDate formats MMM-yyyy (nM) or unavailable", () {
      expect(vm.getHeaderDate(-1), vm.unavailableText);
      vm.incomeStatements = [
        Statement(
          id: 1,
          date: DateTime(2023, 6, 15),
          periods: 12,
          statementConsts: const [],
        ),
      ];
      expect(vm.getHeaderDate(0), "Jun-2023 (12M)");
    });

    test("rowValue trims; non-new empty -> unavailable; new returns raw", () {
      expect(vm.rowValue(null), vm.unavailableText);
      expect(vm.rowValue(""), vm.unavailableText);
      expect(vm.rowValue(" "), vm.unavailableText);
      expect(vm.rowValue(" test "), "test");
      expect(vm.rowValue(" test ", isNew: true), "test");
    });

    test(
        "deleteUserAddedIncomeRow success removes "
        "row; failure keeps row & shows toast", () async {
      vm.updateEntityId("7656");
      await vm.onChangeCustomer(Globals.request!.customers!.first); // rim 1111
      vm.addIncomeRow();
      final userRow = vm.incomeStatementRows.first
        ..incomePositions = "User Label";

      // success
      when(
        () => mockRepository.deleteFinancialRatioAnalysisDetails(
          rimNo: any(named: "rimNo"),
          entityId: any(named: "entityId"),
          financialsCategory: any(named: "financialsCategory"),
          userAddedRatioType: any(named: "userAddedRatioType"),
        ),
      ).thenAnswer(
        (_) async =>
            const DeleteFinancialRatioAnalysisResult(message: "Success"),
      );

      // Add a saved row
      final savedRow = IncomeStatementAnalysisRow(id: "74", isNew: false)
        ..incomePositions = "Saved";
      vm.incomeStatementRows.add(savedRow);

      await vm.deleteUserAddedIncomeRow(userRow);
      expect(vm.incomeStatementRows.length, 1);

      await vm.deleteUserAddedIncomeRow(savedRow);
      expect(vm.incomeStatementRows, isEmpty);

      // failure branch
      vm.addIncomeRow();
      when(
        () => mockRepository.deleteFinancialRatioAnalysisDetails(
          rimNo: any(named: "rimNo"),
          entityId: any(named: "entityId"),
          financialsCategory: any(named: "financialsCategory"),
          userAddedRatioType: any(named: "userAddedRatioType"),
        ),
      ).thenThrow(Exception("delete failed"));
      final savedRow2 = IncomeStatementAnalysisRow(id: "74", isNew: false)
        ..incomePositions = "Saved 2";
      vm.incomeStatementRows.add(savedRow2);
      await vm.deleteUserAddedIncomeRow(savedRow2);
      expect(vm.incomeStatementRows, isNotEmpty); // still present on failure
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("deleteUserAddedCashflowRow handles success and failure", () async {
      vm.updateEntityId("7656");
      vm.cashflowSheetRows.add(
        CashFlowSheetAnalysisRow(id: "75", isNew: false)
          ..cashFlowItems = "Saved",
      );

      when(
        () => mockRepository.deleteFinancialRatioAnalysisDetails(
          rimNo: any(named: "rimNo"),
          entityId: any(named: "entityId"),
          financialsCategory: any(named: "financialsCategory"),
          userAddedRatioType: any(named: "userAddedRatioType"),
        ),
      ).thenAnswer(
        (_) async =>
            const DeleteFinancialRatioAnalysisResult(message: "Success"),
      );

      await vm.deleteUserAddedCashflowRow(vm.cashflowSheetRows.first);
      expect(vm.cashflowSheetRows, isEmpty);

      vm.cashflowSheetRows.add(
        CashFlowSheetAnalysisRow(id: "75", isNew: false)
          ..cashFlowItems = "Saved",
      );
      when(
        () => mockRepository.deleteFinancialRatioAnalysisDetails(
          rimNo: any(named: "rimNo"),
          entityId: any(named: "entityId"),
          financialsCategory: any(named: "financialsCategory"),
          userAddedRatioType: any(named: "userAddedRatioType"),
        ),
      ).thenThrow(Exception("fail"));

      await vm.deleteUserAddedCashflowRow(vm.cashflowSheetRows.first);
      expect(vm.cashflowSheetRows, isNotEmpty);
    });

    test("deleteUserAddedBalanceRow handles success and failure", () async {
      vm.updateEntityId("7656");
      vm.balanceSheetRows.add(
        BalanceSheetAnalysisRow(id: "76", isNew: false)..balanceSheet = "Saved",
      );

      when(
        () => mockRepository.deleteFinancialRatioAnalysisDetails(
          rimNo: any(named: "rimNo"),
          entityId: any(named: "entityId"),
          financialsCategory: any(named: "financialsCategory"),
          userAddedRatioType: any(named: "userAddedRatioType"),
        ),
      ).thenAnswer(
        (_) async =>
            const DeleteFinancialRatioAnalysisResult(message: "Success"),
      );

      await vm.deleteUserAddedBalanceRow(vm.balanceSheetRows.first);
      expect(vm.balanceSheetRows, isEmpty);

      vm.balanceSheetRows.add(
        BalanceSheetAnalysisRow(id: "76", isNew: false)..balanceSheet = "Saved",
      );
      when(
        () => mockRepository.deleteFinancialRatioAnalysisDetails(
          rimNo: any(named: "rimNo"),
          entityId: any(named: "entityId"),
          financialsCategory: any(named: "financialsCategory"),
          userAddedRatioType: any(named: "userAddedRatioType"),
        ),
      ).thenThrow(Exception("fail"));

      await vm.deleteUserAddedBalanceRow(vm.balanceSheetRows.first);
      expect(vm.balanceSheetRows, isNotEmpty);
    });
  });

  group("onSavePress & navigation", () {
    test("changeTab calls router.go (no throw)", () async {
      when(() => mockRouter.go(any(), extra: any(named: "extra")))
          .thenReturn(null);
      await vm.changeTab(RemarksTabs.guarantorFinancials);
      await Future.delayed(const Duration(milliseconds: 200));
      verify(() => mockRouter.go(any(), extra: any(named: "extra"))).called(1);
    });

    test("navigate() does not throw", () {
      expect(() => vm.navigate(), returnsNormally);
    });
  });

  group("populateIncomeStatementRows", () {
    test("populates rows from API response with valid data", () {
      vm.financialRatioType = [
        Reference(
          id: 1,
          name: "Revenue",
          reference1: ServerConstants.incomeStatementAnalysis,
          reference2: "74",
        ),
        Reference(
          id: 2,
          name: "Net Income",
          reference1: ServerConstants.incomeStatementAnalysis,
          reference2: "75",
        ),
      ];

      final resp = FinancialDetailsResponse(
        entityId: 123,
        longName: "Test Company",
        shortName: "TC",
        statements: [
          Statement(
            id: 1,
            date: DateTime(2021, 12, 31),
            periods: 12,
            statementConsts: [
              StatementConst(id: 1, value: "Unqualif'd"),
              StatementConst(id: 2, value: "Auditor A"),
            ],
          ),
          Statement(
            id: 2,
            date: DateTime(2022, 12, 31),
            periods: 12,
            statementConsts: [
              StatementConst(id: 1, value: "Qualified"),
              StatementConst(id: 2, value: "Auditor B"),
            ],
          ),
        ],
        macros: {
          "74": [
            MacroItem(stmtID: 1, stmtDate: DateTime(2021), value: "100.50"),
            MacroItem(stmtID: 2, stmtDate: DateTime(2022), value: "200.75"),
          ],
          "75": [
            MacroItem(stmtID: 1, stmtDate: DateTime(2021), value: "nan"),
            MacroItem(stmtID: 2, stmtDate: DateTime(2022), value: ""),
          ],
        },
      );

      vm.populateIncomeStatementRows(resp);

      expect(vm.incomeStatementRows, hasLength(2));
      expect(vm.incomeStatementRows[0].incomePositions, "Revenue");
      expect(vm.incomeStatementRows[0].audited1, "100.50");
      expect(vm.incomeStatementRows[0].audited2, "200.75");
      expect(vm.incomeStatementRows[1].incomePositions, "Net Income");
      expect(vm.incomeStatementRows[1].audited1, vm.unavailableText);
      expect(vm.incomeRows, hasLength(2));
    });

    test("handles empty macros gracefully", () {
      vm.financialRatioType = [
        Reference(
          id: 1,
          name: "Revenue",
          reference1: ServerConstants.incomeStatementAnalysis,
          reference2: "74",
        ),
      ];

      final resp = FinancialDetailsResponse(
        entityId: 123,
        longName: "Test",
        shortName: "T",
        statements: [],
        macros: {},
      );

      vm.populateIncomeStatementRows(resp);

      expect(vm.incomeStatementRows, hasLength(1));
      expect(vm.incomeStatementRows[0].audited1, vm.unavailableText);
    });
  });

  group("populateBalanceSheetRows", () {
    test("populates balance sheet rows from API response", () {
      vm.financialRatioType = [
        Reference(
          id: 1,
          name: "Total Assets",
          reference1: ServerConstants.balanceSheetAnalysis,
          reference2: "100",
        ),
      ];

      final resp = FinancialDetailsResponse(
        entityId: 123,
        longName: "Test",
        shortName: "T",
        statements: [
          Statement(
            id: 1,
            date: DateTime(2021),
            periods: 12,
            statementConsts: [],
          ),
        ],
        macros: {
          "100": [
            MacroItem(stmtID: 1, stmtDate: DateTime(2021), value: "500.25"),
          ],
        },
      );

      vm.populateBalanceSheetRows(resp);

      expect(vm.balanceSheetRows, hasLength(1));
      expect(vm.balanceSheetRows[0].balanceSheet, "Total Assets");
      expect(vm.balanceSheetRows[0].audited1, "500.25");
      expect(vm.balanceRows, hasLength(1));
    });
  });

  group("populateCashflowRows", () {
    test("populates cashflow rows from API response", () {
      vm.financialRatioType = [
        Reference(
          id: 1,
          name: "Operating Cash Flow",
          reference1: ServerConstants.cashFlowAnalysis,
          reference2: "200",
        ),
      ];

      final resp = FinancialDetailsResponse(
        entityId: 123,
        longName: "Test",
        shortName: "T",
        statements: [
          Statement(
            id: 1,
            date: DateTime(2021),
            periods: 12,
            statementConsts: [],
          ),
        ],
        macros: {
          "200": [
            MacroItem(stmtID: 1, stmtDate: DateTime(2021), value: "75.50"),
          ],
        },
      );

      vm.populateCashflowRows(resp);

      expect(vm.cashflowSheetRows, hasLength(1));
      expect(vm.cashflowSheetRows[0].cashFlowItems, "Operating Cash Flow");
      expect(vm.cashflowSheetRows[0].audited1, "75.50");
      expect(vm.cashflowRows, hasLength(1));
    });
  });

  group("onSavePress", () {
    test("handles save error gracefully", () async {
      final testVm = TestFinancialRatioAnalysisViewModel(
        remarksRepository: mockRepository,
        referenceDataService: mockRefService,
      );

      testVm.updateEntityId("123");
      testVm.hasSavedAnalysisData = true;
      testVm.incomeRows = [];
      testVm.balanceRows = [];
      testVm.cashflowRows = [];

      when(
        () => mockRepository.saveFinancialRatioAnalysisDetails(
          items: any(named: "items"),
        ),
      ).thenThrow(Exception("Save failed"));

      // with existing financial details
      testVm.hasExistingFinancialDetails = true;
      await testVm.onSavePress(false, MockBuildContext());

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(testVm.state.buttonStatus, LoadingStatus.loaded);
    });

    test("buildSaveItems correctly extracts block categories", () async {
      final testVm = TestFinancialRatioAnalysisViewModel(
        remarksRepository: mockRepository,
        referenceDataService: mockRefService,
      );

      testVm.updateEntityId("123");
      testVm.hasCreditLensData = true;
      testVm.incomeStatements = [
        Statement(
          id: 1,
          date: DateTime(2021, 12, 31),
          periods: 12,
          statementConsts: [
            StatementConst(id: 0, value: "Audited"),
            StatementConst(id: 1, value: ""),
          ],
        ),
      ];

      testVm.incomeStatementRows.add(
        IncomeStatementAnalysisRow(
          id: "101",
          isNew: false,
          audited1: "100",
        )..incomePositions = "Income pos",
      );
      testVm.cashflowSheetRows.add(
        CashFlowSheetAnalysisRow(
          id: "102",
          isNew: false,
          audited1: "200",
        )..cashFlowItems = "Cashflow item",
      );
      testVm.balanceSheetRows.add(
        BalanceSheetAnalysisRow(
          id: "103",
          isNew: false,
          audited1: "300",
        )..balanceSheet = "Balance item",
      );

      // Add a user added blank row that shouldn't be extracted
      testVm.incomeStatementRows
          .add(IncomeStatementAnalysisRow(id: "0", isNew: true));

      final items = await testVm.buildSaveItems("Test comment");
      expect(items, isNotEmpty);
      final entityBlock = items.first.entityDetails.first;
      expect(entityBlock.financialsCategory, hasLength(3));

      // Test new row addition to payload when it's populated
      testVm.incomeStatementRows.add(
        IncomeStatementAnalysisRow(
          id: "0",
          isNew: true,
          audited1: "400",
          audited2: "500",
        )..incomePositions = "New Ratio",
      );
      final items2 = await testVm.buildSaveItems("Test comment");
      expect(
        items2.first.entityDetails.first.financialsCategory
            .firstWhere((e) => e.financialsCategory == 234)
            .financialsValues
            .length,
        2,
      );
    });
  });

  group("Draft related getters", () {
    test("draftModuleKey returns remarks key", () {
      // Act
      final result = vm.draftModuleKey;

      // Assert
      expect(result, DraftModuleKeys.remarks);
    });

    test("draftFormKey returns correct value when customer is selected", () {
      // Arrange
      vm.selectedCustomer = Customer(
        customerRimNo: 12345,
      );

      // Act
      final result = vm.draftFormKey;

      // Assert
      expect(
        result,
        "${Routes.financialRatiosAnalysis}_12345",
      );
    });

    test("draftFormKey handles null customer safely", () {
      // Arrange
      vm.selectedCustomer = null;

      // Act
      final result = vm.draftFormKey;

      // Assert
      expect(
        result,
        "${Routes.financialRatiosAnalysis}_null",
      );
    });

    test("draftHandler returns FinancialRatioAnalysisDraftHandler", () {
      // Act
      final handler = vm.draftHandler;

      // Assert
      expect(handler, isA<FinancialRatioAnalysisDraftHandler>());
    });
  });

  group("isReadOnlyMode", () {
    test("returns true when pageMode is view", () {
      // Arrange
      vm.pageMode = PageMode.view;

      // Act
      final result = vm.isReadOnlyMode;

      // Assert
      expect(result, isTrue);
    });

    test("returns false when pageMode is edit", () {
      // Arrange
      vm.pageMode = PageMode.edit;

      // Act
      final result = vm.isReadOnlyMode;

      // Assert
      expect(result, isFalse);
    });

    test("returns false when pageMode is create", () {
      // Arrange
      vm.pageMode = PageMode.na;

      // Act
      final result = vm.isReadOnlyMode;

      // Assert
      expect(result, isFalse);
    });
  });

  group("defaultSelectedCustomer", () {
    test("selects first borrower when borrowers list is not empty", () {
      // Arrange
      final borrower = Customer(customerRimNo: 111, customerName: "Borrower 1");
      final customer = Customer(customerRimNo: 222, customerName: "Customer 1");

      Globals.request = Request(
        borrowers: [borrower],
        customers: [customer],
      );

      // Act
      vm.defaultSelectedCustomer();

      // Assert
      expect(vm.selectedCustomer, borrower);
    });

    test("selects first customer when borrowers list is empty", () {
      // Arrange
      final customer = Customer(customerRimNo: 222, customerName: "Customer 1");

      Globals.request = Request(
        borrowers: [],
        customers: [customer],
      );

      // Act
      vm.defaultSelectedCustomer();

      // Assert
      expect(vm.selectedCustomer, customer);
    });

    // test('sets selectedCustomer to null when both lists are empty', () {
    //   // Arrange
    //   Globals.request = Request(
    //     borrowers: [],
    //     customers: [],
    //   );

    //   // Act
    //   vm.defaultSelectedCustomer();

    //   // Assert
    //   expect(vm.selectedCustomer, isNull);
    // });

    test("throws StateError when both lists are empty", () {
      Globals.request = Request(
        borrowers: [],
        customers: [],
      );

      expect(
        () => vm.defaultSelectedCustomer(),
        throwsA(isA<StateError>()),
      );
    });

    test("sets selectedCustomer to null when request is null", () {
      // Arrange
      Globals.request = null;

      // Act
      vm.defaultSelectedCustomer();

      // Assert
      expect(vm.selectedCustomer, isNull);
    });
  });

  group("healthRefById", () {
    test("returns null when id is null", () {
      final result = vm.healthRefById(
        null,
        [Reference(id: 1, name: "Low")],
      );

      expect(result, isNull);
    });

    test("returns null when list is null", () {
      final result = vm.healthRefById(1, null);
      expect(result, isNull);
    });

    test("returns matching reference when id exists", () {
      final low = Reference(id: 1, name: "Low");
      final high = Reference(id: 2, name: "High");

      final result = vm.healthRefById(2, [low, high]);

      expect(result, high);
    });

    test("returns null when id is not found", () {
      final result = vm.healthRefById(
        99,
        [Reference(id: 1, name: "Low")],
      );

      expect(result, isNull);
    });

    test("returns null when list is empty", () {
      final result = vm.healthRefById(1, []);
      expect(result, isNull);
    });
  });

  group("parseSavedMonths", () {
    test("returns numeric value when digits are present", () {
      expect(vm.parseSavedMonths("12 months"), 12);
    });

    test("returns first numeric value when multiple numbers are present", () {
      expect(vm.parseSavedMonths("6 of 12 months"), 6);
    });

    test("returns 0 when no digits are present", () {
      expect(vm.parseSavedMonths("months"), 0);
    });

    test("returns 0 for empty string", () {
      expect(vm.parseSavedMonths(""), 0);
    });

    test("returns 0 for non-numeric string", () {
      expect(vm.parseSavedMonths("ABC"), 0);
    });

    test("handles leading and trailing spaces", () {
      expect(vm.parseSavedMonths("  24 months  "), 24);
    });
  });

  group("dateFromSaved", () {
    test("returns parsed DateTime when statementDate is valid", () {
      final value = FinancialValue(
        financialsCategory: 1,
        financialRatioType: "RATIO",
        userAddedRatioType: null,
        financialYear: 2023,
        period: "12 months",
        auditMethod: "AUDITED",
        auditor: "KPMG",
        value: 10.5,
        statementDate: "2023-08-15",
      );

      final result = vm.dateFromSaved(value);

      expect(result, DateTime(2023, 8, 15));
    });

    test("parses statementDate with leading/trailing spaces", () {
      final value = FinancialValue(
        financialsCategory: 1,
        financialRatioType: "RATIO",
        userAddedRatioType: null,
        financialYear: 2022,
        period: "6 months",
        auditMethod: "AUDITED",
        auditor: null,
        value: null,
        statementDate: " 2022-03-10 ",
      );

      final result = vm.dateFromSaved(value);

      expect(result, DateTime(2022, 3, 10));
    });

    test("falls back to period-based date when statementDate is invalid", () {
      final value = FinancialValue(
        financialsCategory: 1,
        financialRatioType: "RATIO",
        userAddedRatioType: null,
        financialYear: 2023,
        period: "6 months",
        auditMethod: "UNAUDITED",
        auditor: null,
        value: null,
        statementDate: "invalid-date",
      );

      final result = vm.dateFromSaved(value);

      expect(result, DateTime(2023, 6, 1));
    });

    test("uses period when statementDate is null", () {
      final value = FinancialValue(
        financialsCategory: 1,
        financialRatioType: "RATIO",
        userAddedRatioType: null,
        financialYear: 2021,
        period: "9 months",
        auditMethod: "AUDITED",
        auditor: null,
        value: null,
        statementDate: null,
      );

      final result = vm.dateFromSaved(value);

      expect(result, DateTime(2021, 9, 1));
    });

    test("clamps period greater than 12 months to December", () {
      final value = FinancialValue(
        financialsCategory: 1,
        financialRatioType: "RATIO",
        userAddedRatioType: null,
        financialYear: 2020,
        period: "18 months",
        auditMethod: "AUDITED",
        auditor: null,
        value: null,
        statementDate: null,
      );

      final result = vm.dateFromSaved(value);

      expect(result, DateTime(2020, 12, 1));
    });

    test("defaults to January when period has no numeric value", () {
      final value = FinancialValue(
        financialsCategory: 1,
        financialRatioType: "RATIO",
        userAddedRatioType: null,
        financialYear: 2019,
        period: "months",
        auditMethod: "AUDITED",
        auditor: null,
        value: null,
        statementDate: null,
      );

      final result = vm.dateFromSaved(value);

      expect(result, DateTime(2019, 1, 1));
    });
  });

  group("buildStatementsFromSavedValues", () {
    FinancialValue fv({
      required int year,
      required String period,
      String? statementDate,
      String auditMethod = "AUDITED",
      String? auditor,
    }) {
      return FinancialValue(
        financialsCategory: 1,
        financialRatioType: "RATIO",
        userAddedRatioType: null,
        financialYear: year,
        period: period,
        auditMethod: auditMethod,
        auditor: auditor,
        value: 10,
        statementDate: statementDate,
      );
    }

    test("returns empty list when values are empty", () {
      final result = vm.buildStatementsFromSavedValues([]);

      expect(result, isEmpty);
    });

    test("keeps latest period per financial year", () {
      final values = [
        fv(year: 2022, period: "6 months"),
        fv(year: 2022, period: "12 months"), // latest
      ];

      final result = vm.buildStatementsFromSavedValues(values);

      expect(result.length, 1);
      expect(result.first.periods, 12);
    });

    test("sorts statements from oldest to newest by year and period", () {
      final values = [
        fv(year: 2023, period: "12 months"),
        fv(year: 2021, period: "6 months"),
        fv(year: 2022, period: "9 months"),
      ];

      final result = vm.buildStatementsFromSavedValues(values);

      expect(result[0].date.year, 2021);
      expect(result[1].date.year, 2022);
      expect(result[2].date.year, 2023);
    });

    test("keeps only last five years when more than five are present", () {
      final values = [
        fv(year: 2018, period: "12 months"),
        fv(year: 2019, period: "12 months"),
        fv(year: 2020, period: "12 months"),
        fv(year: 2021, period: "12 months"),
        fv(year: 2022, period: "12 months"),
        fv(year: 2023, period: "12 months"),
      ];

      final result = vm.buildStatementsFromSavedValues(values);

      expect(result.length, 5);
      expect(result.first.date.year, 2019);
      expect(result.last.date.year, 2023);
    });

    test("uses statementDate for header date when available", () {
      final values = [
        fv(
          year: 2022,
          period: "12 months",
          statementDate: "2022-08-31",
        ),
      ];

      final result = vm.buildStatementsFromSavedValues(values);

      expect(result.first.date, DateTime(2022, 8, 31));
    });

    test("falls back to period-based date when statementDate is invalid", () {
      final values = [
        fv(
          year: 2021,
          period: "6 months",
          statementDate: "invalid-date",
        ),
      ];

      final result = vm.buildStatementsFromSavedValues(values);

      expect(result.first.date, DateTime(2021, 6, 1));
    });

    test("sets audit method and auditor in statementConsts", () {
      final values = [
        fv(
          year: 2023,
          period: "12 months",
          auditMethod: "UNAUDITED",
          auditor: "EY",
        ),
      ];

      final result = vm.buildStatementsFromSavedValues(values);
      final consts = result.first.statementConsts;

      expect(consts[0].value, "UNAUDITED");
      expect(consts[1].value, "EY");
    });

    test("defaults auditor to empty string when null", () {
      final values = [
        fv(
          year: 2023,
          period: "12 months",
          auditor: null,
        ),
      ];

      final result = vm.buildStatementsFromSavedValues(values);
      final consts = result.first.statementConsts;

      expect(consts[1].value, "");
    });
  });

  group("displayNameForCode", () {
    setUp(() {
      vm.financialRatioType = null;
    });

    test("returns reference name when matching code exists", () {
      vm.financialRatioType = [
        Reference(reference2: "ROE", name: "Return on Equity"),
        Reference(reference2: "ROA", name: "Return on Assets"),
      ];

      final result = vm.displayNameForCode("ROE");

      expect(result, "Return on Equity");
    });

    test("returns code when matching reference has empty name", () {
      vm.financialRatioType = [
        Reference(reference2: "ROE", name: ""),
      ];

      final result = vm.displayNameForCode("ROE");

      expect(result, "ROE");
    });

    test("returns code when reference name is null", () {
      vm.financialRatioType = [
        Reference(reference2: "ROE", name: null),
      ];

      final result = vm.displayNameForCode("ROE");

      expect(result, "ROE");
    });

    test("returns code when no matching reference is found", () {
      vm.financialRatioType = [
        Reference(reference2: "ROA", name: "Return on Assets"),
      ];

      final result = vm.displayNameForCode("ROE");

      expect(result, "ROE");
    });

    test("returns code when financialRatioType list is null", () {
      vm.financialRatioType = null;

      final result = vm.displayNameForCode("ROE");

      expect(result, "ROE");
    });

    test("returns code when financialRatioType list is empty", () {
      vm.financialRatioType = [];

      final result = vm.displayNameForCode("ROE");

      expect(result, "ROE");
    });
  });

  group("mkIncomeRowFromSaved", () {
    FinancialValue fv({
      required int year,
      required String period,
      required String ratioType,
      double? value,
    }) {
      return FinancialValue(
        financialsCategory: 1,
        financialRatioType: ratioType,
        userAddedRatioType: null,
        financialYear: year,
        period: period,
        auditMethod: "AUDITED",
        auditor: "KPMG",
        value: value,
        statementDate: "$year-12-31",
      );
    }

    setUp(() {
      vm.incomeStatements = [
        Statement(
          id: 1,
          date: DateTime(2021, 12, 1),
          periods: 12,
          statementConsts: [],
        ),
        Statement(
          id: 2,
          date: DateTime(2022, 6, 1),
          periods: 6,
          statementConsts: [],
        ),
        Statement(
          id: 3,
          date: DateTime(2023, 12, 1),
          periods: 12,
          statementConsts: [],
        ),
      ];
    });

    test("creates code-based row with formatted values", () {
      final items = [
        fv(year: 2021, period: "12 months", ratioType: "REVENUE", value: 100.5),
        fv(year: 2022, period: "6 months", ratioType: "REVENUE", value: 200),
        fv(
          year: 2023,
          period: "12 months",
          ratioType: "REVENUE",
          value: 300.123,
        ),
      ];

      final row = vm.mkIncomeRowFromSaved(
        "REVENUE",
        items,
        "N/A",
      );

      expect(row.isNew, isFalse);
      expect(row.audited1, "100.50");
      expect(row.audited2, "200.00");
      expect(row.audited3, "300.12");
      expect(row.incomePositions, vm.displayNameForCode("REVENUE"));
    });

    test("marks row as new when ratio code is empty", () {
      final items = [
        fv(year: 2021, period: "12 months", ratioType: "", value: 10),
      ];

      final row = vm.mkIncomeRowFromSaved(
        "CUSTOM_RATIO",
        items,
        "NA",
      );

      expect(row.isNew, isTrue);
    });

    test("uses unavailable text when no matching statement exists", () {
      final items = [
        fv(year: 2021, period: "12 months", ratioType: "EXPENSE", value: 50),
      ];

      final row = vm.mkIncomeRowFromSaved(
        "EXPENSE",
        items,
        "--",
      );

      expect(row.audited1, "50.00");
      expect(row.audited2, "--");
      expect(row.audited3, "--");
      expect(row.inhouse, "--");
      expect(row.estimated, "--");
    });

    test("uses unavailable text when value is null", () {
      final items = [
        fv(year: 2021, period: "12 months", ratioType: "COGS", value: null),
      ];

      final row = vm.mkIncomeRowFromSaved(
        "COGS",
        items,
        "N/A",
      );

      expect(row.audited1, "N/A");
    });

    test("limits values to maximum five columns", () {
      vm.incomeStatements = List.generate(
        6,
        (i) => Statement(
          id: i + 1,
          date: DateTime(2018 + i, 12, 1),
          periods: 12,
          statementConsts: [],
        ),
      );

      final items = List.generate(
        6,
        (i) => fv(
          year: 2018 + i,
          period: "12 months",
          ratioType: "NET_PROFIT",
          value: 10.0 * i,
        ),
      );

      final row = vm.mkIncomeRowFromSaved(
        "NET_PROFIT",
        items,
        "NA",
      );

      // Only last 5 columns populated
      expect(row.audited1, isNot("NA"));
      expect(row.estimated, isNot("NA"));
    });
  });

  group("mkCashflowRowFromSaved", () {
    FinancialValue fv({
      required int year,
      required String period,
      required String ratioType,
      double? value,
    }) {
      return FinancialValue(
        financialsCategory: 236,
        financialRatioType: ratioType,
        userAddedRatioType: null,
        financialYear: year,
        period: period,
        auditMethod: "AUDITED",
        auditor: "EY",
        value: value,
        statementDate: "$year-12-31",
      );
    }

    setUp(() {
      vm.incomeStatements = [
        Statement(
          id: 1,
          date: DateTime(2021, 12, 1),
          periods: 12,
          statementConsts: const [],
        ),
        Statement(
          id: 2,
          date: DateTime(2022, 6, 1),
          periods: 6,
          statementConsts: const [],
        ),
        Statement(
          id: 3,
          date: DateTime(2023, 12, 1),
          periods: 12,
          statementConsts: const [],
        ),
      ];
    });

    test("creates code-based cashflow row with formatted values", () {
      final items = [
        fv(year: 2021, period: "12 months", ratioType: "CASH_IN", value: 100.5),
        fv(year: 2022, period: "6 months", ratioType: "CASH_IN", value: 200),
        fv(
          year: 2023,
          period: "12 months",
          ratioType: "CASH_IN",
          value: 300.123,
        ),
      ];

      final row = vm.mkCashflowRowFromSaved(
        "CASH_IN",
        items,
        "N/A",
      );

      expect(row.isNew, isFalse);
      expect(row.audited1, "100.50");
      expect(row.audited2, "200.00");
      expect(row.audited3, "300.12");
      expect(row.cashFlowItems, vm.displayNameForCode("CASH_IN"));
    });

    test('marks row as new when ratio code is empty or "null"', () {
      final items = [
        fv(year: 2021, period: "12 months", ratioType: "", value: 10),
      ];

      final row = vm.mkCashflowRowFromSaved(
        "CUSTOM_CF",
        items,
        "NA",
      );

      expect(row.isNew, isTrue);
    });
    test("uses unavailable text when no matching statement exists", () {
      const unavailable = "--";

      final items = [
        fv(year: 2021, period: "12 months", ratioType: "NET_CF", value: 50),
      ];

      final row = vm.mkCashflowRowFromSaved(
        "NET_CF",
        items,
        unavailable,
      );

      expect(row.audited1, "50.00");
      expect(row.audited2, unavailable);
      expect(row.audited3, unavailable);
      expect(row.inhouse, unavailable);
      expect(row.estimated, unavailable);
    });

    test("uses unavailable text when matched value is null", () {
      final items = [
        fv(year: 2021, period: "12 months", ratioType: "FREE_CF", value: null),
      ];

      final row = vm.mkCashflowRowFromSaved(
        "FREE_CF",
        items,
        "N/A",
      );

      expect(row.audited1, "N/A");
    });

    test("limits output to maximum of five columns", () {
      vm.incomeStatements = List.generate(
        6,
        (i) => Statement(
          id: i + 1,
          date: DateTime(2018 + i, 12, 1),
          periods: 12,
          statementConsts: const [],
        ),
      );

      final items = List.generate(
        6,
        (i) => fv(
          year: 2018 + i,
          period: "12 months",
          ratioType: "NET_CASH",
          value: 10.0 * i,
        ),
      );

      final row = vm.mkCashflowRowFromSaved(
        "NET_CASH",
        items,
        "NA",
      );

      expect(row.audited1, isNot("NA"));
      expect(row.estimated, isNot("NA"));
    });
  });

  group("mkBalanceRowFromSaved", () {
    FinancialValue fv({
      required int year,
      required String period,
      required String ratioType,
      double? value,
    }) {
      return FinancialValue(
        financialsCategory: 237,
        financialRatioType: ratioType,
        userAddedRatioType: null,
        financialYear: year,
        period: period,
        auditMethod: "AUDITED",
        auditor: "EY",
        value: value,
        statementDate: "$year-12-31",
      );
    }

    setUp(() {
      vm.incomeStatements = [
        Statement(
          id: 1,
          date: DateTime(2021, 12, 1),
          periods: 12,
          statementConsts: const [],
        ),
        Statement(
          id: 2,
          date: DateTime(2022, 6, 1),
          periods: 6,
          statementConsts: const [],
        ),
        Statement(
          id: 3,
          date: DateTime(2023, 12, 1),
          periods: 12,
          statementConsts: const [],
        ),
      ];
    });

    test("creates code-based balance sheet row with formatted values", () {
      final items = [
        fv(
          year: 2021,
          period: "12 months",
          ratioType: "TOTAL_ASSETS",
          value: 1000.5,
        ),
        fv(
          year: 2022,
          period: "6 months",
          ratioType: "TOTAL_ASSETS",
          value: 2000,
        ),
        fv(
          year: 2023,
          period: "12 months",
          ratioType: "TOTAL_ASSETS",
          value: 3000.123,
        ),
      ];

      final row = vm.mkBalanceRowFromSaved(
        "TOTAL_ASSETS",
        items,
        "N/A",
      );

      expect(row.isNew, isFalse);
      expect(row.audited1, "1000.50");
      expect(row.audited2, "2000.00");
      expect(row.audited3, "3000.12");
      expect(row.balanceSheet, vm.displayNameForCode("TOTAL_ASSETS"));
    });

    test('marks row as new when ratio code is empty or "null"', () {
      final items = [
        fv(year: 2021, period: "12 months", ratioType: "", value: 10),
      ];

      final row = vm.mkBalanceRowFromSaved(
        "CUSTOM_BALANCE",
        items,
        "NA",
      );

      expect(row.isNew, isTrue);
    });

    test("uses unavailable text when no matching financial value exists", () {
      const unavailable = "--";

      final items = [
        fv(year: 2021, period: "12 months", ratioType: "EQUITY", value: 500),
      ];

      final row = vm.mkBalanceRowFromSaved(
        "EQUITY",
        items,
        unavailable,
      );

      expect(row.audited1, "500.00");
      expect(row.audited2, unavailable);
      expect(row.audited3, unavailable);
      expect(row.inhouse, unavailable);
      expect(row.estimated, unavailable);
    });

    test("uses unavailable text when matched value is null", () {
      final items = [
        fv(
          year: 2021,
          period: "12 months",
          ratioType: "LIABILITIES",
          value: null,
        ),
      ];

      final row = vm.mkBalanceRowFromSaved(
        "LIABILITIES",
        items,
        "N/A",
      );

      expect(row.audited1, "N/A");
    });

    test("limits output to a maximum of five columns", () {
      vm.incomeStatements = List.generate(
        6,
        (i) => Statement(
          id: i + 1,
          date: DateTime(2018 + i, 12, 1),
          periods: 12,
          statementConsts: const [],
        ),
      );

      final items = List.generate(
        6,
        (i) => fv(
          year: 2018 + i,
          period: "12 months",
          ratioType: "NET_WORTH",
          value: 100.0 * i,
        ),
      );

      final row = vm.mkBalanceRowFromSaved(
        "NET_WORTH",
        items,
        "NA",
      );

      expect(row.audited1, isNot("NA"));
      expect(row.estimated, isNot("NA"));
    });
  });

  group("setAsterisks", () {
    test("sets showAsteriskTabs based on selectedCustomer", () async {
      final customer = Customer(
        customerRimNo: 100,
        customerName: "Test FI",
        type: CustomerType.investmentGradeBanks,
      );

      vm.selectedCustomer = customer;

      await vm.setAsterisks();

      // Verify field is set (not null / updated)
      expect(vm.showAsteriskTabs, isNotNull);
    });

    test("handles null selectedCustomer safely", () async {
      vm.selectedCustomer = null;

      await vm.setAsterisks();

      expect(vm.showAsteriskTabs, isNotNull);
    });
  });

  group("showViewMore", () {
    test("returns true for belowInvestmentGradeBanks customer", () {
      vm.selectedCustomer = Customer(
        customerRimNo: 1,
        type: CustomerType.belowInvestmentGradeBanks,
      );

      expect(vm.showViewMore, isTrue);
    });

    test("returns true for investmentGradeBanks customer", () {
      vm.selectedCustomer = Customer(
        customerRimNo: 2,
        type: CustomerType.investmentGradeBanks,
      );

      expect(vm.showViewMore, isTrue);
    });

    test("returns false for non-FI customer type", () {
      vm.selectedCustomer = Customer(
        customerRimNo: 3,
        type: CustomerType.country,
      );

      expect(vm.showViewMore, isFalse);
    });

    test("returns false when selectedCustomer is null", () {
      vm.selectedCustomer = null;

      expect(vm.showViewMore, isFalse);
    });
  });
  group("changeEntityIdExternally", () {
    test("updates currentEntityId in state", () {
      const entityId = 12345;

      vm.changeEntityIdExternally(entityId);

      expect(vm.state.currentEntityId, entityId);
    });
  });

  group("auditMethodForSave", () {
    test('removes "Audited-" prefix when present', () {
      final result = vm.auditMethodForSave("Audited-Full");

      expect(result, "Full");
    });

    test('removes "Audited-" prefix after trimming spaces', () {
      final result = vm.auditMethodForSave("  Audited-Limited  ");

      expect(result, "Limited");
    });

    test("returns original value when prefix is not present", () {
      final result = vm.auditMethodForSave("Unaudited");

      expect(result, "Unaudited");
    });

    test("returns trimmed value when no prefix exists", () {
      final result = vm.auditMethodForSave("  Review  ");

      expect(result, "Review");
    });

    test("handles empty string safely", () {
      final result = vm.auditMethodForSave("");

      expect(result, "");
    });

    test('handles "Audited-" only string', () {
      final result = vm.auditMethodForSave("Audited-");

      expect(result, "");
    });
  });

  group("auditorForSave", () {
    setUp(() {
      // Ensure unavailableText is set for the VM if it’s configurable
      vm.unavailableText = "--";
    });

    test("returns empty string when auditor is empty", () {
      final result = vm.auditorForSave("");

      expect(result, "");
    });

    test("returns empty string when auditor contains only spaces", () {
      final result = vm.auditorForSave("   ");

      expect(result, "");
    });

    test("returns empty string when auditor equals unavailableText", () {
      final result = vm.auditorForSave("--");

      expect(result, "");
    });

    test(
        "returns empty string when auditor equals "
        "unavailableText ignoring case and spaces", () {
      final result = vm.auditorForSave("  --  ");

      expect(result, "");
    });

    test("returns empty string when auditor equals dataNotAvailable constant",
        () {
      final result = vm.auditorForSave(ServerConstants.dataNotAvailable);

      expect(result, "");
    });

    test("returns trimmed auditor name when valid value is provided", () {
      final result = vm.auditorForSave("  Deloitte  ");

      expect(result, "Deloitte");
    });

    test("returns trimmed auditor name when value is not a special case", () {
      final result = vm.auditorForSave("KPMG");

      expect(result, "KPMG");
    });
  });

  group("updateLongName", () {
    test("sets trimmed value when text has leading and trailing spaces", () {
      vm.updateLongName("  Long Name Value  ");

      expect(vm.longName, "Long Name Value");
    });

    test("sets value as-is when text has no extra spaces", () {
      vm.updateLongName("ValidName");

      expect(vm.longName, "ValidName");
    });

    test("sets empty string when input is empty", () {
      vm.updateLongName("");

      expect(vm.longName, "");
    });

    test("sets empty string when input contains only spaces", () {
      vm.updateLongName("     ");

      expect(vm.longName, "");
    });
  });

  group("labelForRow", () {
    test("returns incomePositions for IncomeStatementAnalysisRow", () {
      final row = IncomeStatementAnalysisRow(
        id: "1",
        incomePositions: "Revenue",
        audited1: "--",
        audited2: "--",
        audited3: "--",
        inhouse: "--",
        estimated: "--",
        isNew: false,
      );

      final result = vm.labelForRow(row);

      expect(result, "Revenue");
    });

    test("returns cashFlowItems for CashFlowSheetAnalysisRow", () {
      final row = CashFlowSheetAnalysisRow(
        id: "2",
        cashFlowItems: "Operating Cash Flow",
        audited1: "--",
        audited2: "--",
        audited3: "--",
        inhouse: "--",
        estimated: "--",
        isNew: false,
      );

      final result = vm.labelForRow(row);

      expect(result, "Operating Cash Flow");
    });

    test("returns balanceSheet for BalanceSheetAnalysisRow", () {
      final row = BalanceSheetAnalysisRow(
        id: "3",
        balanceSheet: "Total Assets",
        audited1: "--",
        audited2: "--",
        audited3: "--",
        inhouse: "--",
        estimated: "--",
        isNew: false,
      );

      final result = vm.labelForRow(row);

      expect(result, "Total Assets");
    });

    test("returns empty string for unsupported row type", () {
      final result = vm.labelForRow(Object());

      expect(result, "");
    });

    test("returns empty string for null input", () {
      final result = vm.labelForRow(null);

      expect(result, "");
    });
  });

  group("valuesFromRow", () {
    setUp(() {
      // Setup 3 income statements with constants
      vm.incomeStatements = [
        Statement(
          id: 1,
          date: DateTime(2021, 12, 31),
          periods: 12,
          statementConsts: [
            StatementConst(id: 0, value: "Audited-Full"),
            StatementConst(id: 1, value: "KPMG"),
          ],
        ),
        Statement(
          id: 2,
          date: DateTime(2022, 12, 31),
          periods: 12,
          statementConsts: [
            StatementConst(id: 0, value: "Audited-Limited"),
            StatementConst(id: 1, value: "--"),
          ],
        ),
        Statement(
          id: 3,
          date: DateTime(2023, 12, 31),
          periods: 12,
          statementConsts: [
            StatementConst(id: 0, value: "Review"),
            StatementConst(id: 1, value: "Deloitte"),
          ],
        ),
      ];

      vm.unavailableText = "--";
    });

    test("maps columns to financial values correctly", () {
      final cols = [" 100.50 ", "200", "", ""];

      final result = vm.valuesFromRow(
        ratioCode: "REV",
        userAddedType: null,
        cols: cols,
        categoryId: 234,
      );

      expect(result.length, 3);

      expect(result[0].financialsCategory, 234);
      expect(result[0].financialRatioType, "REV");
      expect(result[0].userAddedRatioType, isNull);
      expect(result[0].financialYear, 2021);
      expect(result[0].period, "12M");
      expect(result[0].value, 100.50);
      expect(result[0].auditMethod, "Full");
      expect(result[0].auditor, "KPMG");

      expect(result[1].value, 200);
      expect(result[1].auditMethod, "Limited");
      expect(result[1].auditor, ""); // '--' → empty

      expect(result[2].value, isNull);
      expect(result[2].auditMethod, "Review");
      expect(result[2].auditor, "Deloitte");
    });

    test("handles user-added rows with null ratioCode", () {
      final cols = ["10"];

      final result = vm.valuesFromRow(
        ratioCode: null,
        userAddedType: "Custom Metric",
        cols: cols,
        categoryId: 236,
      );

      expect(result.length, 1);
      expect(result.first.financialRatioType, "");
      expect(result.first.userAddedRatioType, "Custom Metric");
      expect(result.first.value, 10);
    });

    test("limits emitted values to minimum of cols, incomeStatements, and 5",
        () {
      vm.incomeStatements = List.generate(
        6,
        (i) => Statement(
          id: i + 1,
          date: DateTime(2018 + i, 12, 31),
          periods: 12,
          statementConsts: [
            StatementConst(id: 0, value: "Audited-Full"),
            StatementConst(id: 1, value: "KPMG"),
          ],
        ),
      );

      final cols = ["1", "2", "3", "4", "5", "6", "7"];

      final result = vm.valuesFromRow(
        ratioCode: "TEST",
        userAddedType: null,
        cols: cols,
        categoryId: 234,
      );

      // max = 5
      expect(result.length, 5);
    });

    test("handles non-numeric column values safely", () {
      final cols = ["ABC"];

      final result = vm.valuesFromRow(
        ratioCode: "TEST",
        userAddedType: null,
        cols: cols,
        categoryId: 234,
      );

      expect(result.length, 1);
      expect(result.first.value, isNull);
    });
  });
}
