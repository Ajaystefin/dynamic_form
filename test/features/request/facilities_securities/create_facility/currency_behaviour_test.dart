import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/currency_rates_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";

import "../../../../test_config.dart";

class _MockFacilitySecurityRepository extends Mock
    implements FacilitySecurityRepository {}

class _MockAlertManager extends Mock implements AlertManager {}

void main() {
  late CreateFacilityViewModel viewModel;
  late _MockFacilitySecurityRepository mockRepository;
  late _MockAlertManager mockAlertManager;

  setUpAll(() async {
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
  });

  setUp(() {
    mockRepository = _MockFacilitySecurityRepository();
    mockAlertManager = _MockAlertManager();
    AlertManager.overrideInstance = mockAlertManager;

    viewModel = CreateFacilityViewModel()..repository = mockRepository;

    CurrencyRatesService()
      ..clearCache()
      ..repository = mockRepository;
  });

  tearDown(() async {
    await viewModel.close();
    CurrencyRatesService().clearCache();
  });

  void stubRates(Map<String, num> rates) {
    when(() => mockRepository.getCurrencyList()).thenAnswer(
      (_) async => (
        currencies: rates.keys.map((code) => Reference(name: code)).toList(),
        rates: rates,
      ),
    );
  }

  /// Seeds the minimum state `applyInitialCurrencyVisibility` reads.
  ///
  /// [fiAmount] / [fiAmountAed] drive the six FI fields at once — they all read
  /// their amount, currency and AED value off the same `FacilityDetail`.
  void seedFacility({
    required String currency,
    int presentOutstanding = 0,
    int proposedLimit = 0,
    int presentLimit = 0,
    num? presentLimitAed,
    num? presentOutstandingAed,
    num? proposedLimitAed,
    num fiAmount = 0,
    num? fiAmountAed,
    double proposedByCc = 0,
    num? proposedByCcAed,
    bool isMainLimit = true,
    int? parentProposedLimit,
  }) {
    final FacilityDetail detail = FacilityDetail.fromJson({
      "presentLimit": presentLimit,
      if (presentLimitAed != null) "presentLimitAED": presentLimitAed,
      if (presentOutstandingAed != null)
        "presentOutstandingAED": presentOutstandingAed,
      if (proposedLimitAed != null) "proposedLimitAED": proposedLimitAed,
      if (proposedByCcAed != null) "proposedByCcAED": proposedByCcAed,
      "cbdEquityTier325Percent": fiAmount,
      "cbdEquityTier325PercentCurrency": currency,
      "counterpartyEquity5Percent": fiAmount,
      "counterpartyEquity5PercentCurrency": currency,
      "counterpartyTotalAssets2Percent": fiAmount,
      "counterpartyTotalAssets2PercentCurrency": currency,
      "excessOverMaxLimitAllowance": fiAmount,
      "excessOverMaxLimitAllowanceCurrency": currency,
      "excessOverMaxLimitAllowanceByCc": fiAmount,
      "excessOverMaxLimitAllowanceCurrencyByCc": currency,
      if (fiAmountAed != null) ...{
        "cbdEquityTier325PercentAED": fiAmountAed,
        "counterpartyEquity5PercentAED": fiAmountAed,
        "counterpartyTotalAssets2PercentAED": fiAmountAed,
        "excessOverMaxLimitAllowanceAED": fiAmountAed,
        "excessOverMaxLimitAllowanceByCcAED": fiAmountAed,
      },
    });

    viewModel
      ..facilityDetail = <FacilityDetail>[detail]
      ..parentProposedLimit = parentProposedLimit
      ..getFacility.isMainLimit = isMainLimit
      ..getFacility.presentOutstandingAmount = presentOutstanding
      ..getFacility.presentOutstandingCurrency = Reference(name: currency)
      ..getFacility.proposedLimit = proposedLimit
      ..getFacility.proposedLimitValue = Reference(name: currency)
      ..getFacility.presentLimit = presentLimit
      ..getFacility.presentLimitValue = Reference(name: currency)
      ..getFacility.proposedByCc = proposedByCc
      ..getFacility.proposedByCcCurrency = currency;
  }

  group("getCurrencyRatesDebounced", () {
    test("collapses a burst of triggers into one repository call", () async {
      stubRates({"USD": 3.67});
      viewModel.getFacility.presentLimit = 100;

      final Reference usd = Reference(name: "USD");
      unawaited(
        viewModel.getCurrencyRatesDebounced(usd, CurrencyField.presentLimit),
      );
      unawaited(
        viewModel.getCurrencyRatesDebounced(usd, CurrencyField.presentLimit),
      );
      await viewModel.getCurrencyRatesDebounced(
        usd,
        CurrencyField.presentLimit,
      );

      verify(() => mockRepository.getCurrencyList()).called(1);
      expect(viewModel.exchangeRate, 3.67);
      expect(viewModel.newPresentLimitController.text, "367");
    });

    test("each field debounces independently", () async {
      stubRates({"USD": 2});
      viewModel.getFacility
        ..presentLimit = 10
        ..presentOutstandingAmount = 20;

      final Reference usd = Reference(name: "USD");
      await Future.wait(<Future<void>>[
        viewModel.getCurrencyRatesDebounced(usd, CurrencyField.presentLimit),
        viewModel.getCurrencyRatesDebounced(
          usd,
          CurrencyField.presentOutstanding,
        ),
      ]);

      // Both fields resolve to the same currency around the same time, so
      // CurrencyRatesService's cache/in-flight de-dupe collapses this to a
      // single underlying repository call.
      verify(() => mockRepository.getCurrencyList()).called(1);
      expect(viewModel.newPresentLimitController.text, "20");
      expect(viewModel.newPresentOutStandingController.text, "40");
    });

    test("toggles the loading flag around the fetch", () async {
      stubRates({"USD": 3.67});
      viewModel.getFacility.presentLimit = 1;

      final loading = viewModel.rateLoadingFor(CurrencyField.presentLimit);
      expect(loading.value, isFalse);

      final Future<void> pending = viewModel.getCurrencyRatesDebounced(
        Reference(name: "USD"),
        CurrencyField.presentLimit,
      );
      expect(loading.value, isTrue);

      await pending;
      expect(loading.value, isFalse);
    });
  });

  group("clearing an amount", () {
    test("a cleared amount shows 0 and fetches no rate", () async {
      stubRates({"USD": 3.67});
      // What the field widget leaves behind when the box is emptied.
      viewModel.getFacility.presentLimit = 0;

      await viewModel.getCurrencyRatesDebounced(
        Reference(name: "USD"),
        CurrencyField.presentLimit,
      );

      verifyNever(() => mockRepository.getCurrencyList());
      expect(viewModel.newPresentLimitController.text, "0");
    });

    test("a rate already in flight cannot overwrite the cleared box", () async {
      final Completer<CurrencyListResult> inFlight =
          Completer<CurrencyListResult>();
      when(() => mockRepository.getCurrencyList())
          .thenAnswer((_) => inFlight.future);

      final Reference usd = Reference(name: "USD");
      viewModel.getFacility.presentLimit = 100;

      unawaited(
        viewModel.getCurrencyRatesDebounced(usd, CurrencyField.presentLimit),
      );
      // Past the debounce, so the request is out and waiting on the response.
      await Future<void>.delayed(const Duration(milliseconds: 400));

      // The user clears the box while that response is still travelling.
      viewModel.getFacility.presentLimit = 0;
      await viewModel.getCurrencyRatesDebounced(
        usd,
        CurrencyField.presentLimit,
      );
      expect(viewModel.newPresentLimitController.text, "0");

      inFlight.complete(
        (currencies: <Reference>[Reference(name: "USD")], rates: {"USD": 3.67}),
      );
      await Future<void>.delayed(Duration.zero);

      // Not "367": the superseded response is discarded.
      expect(viewModel.newPresentLimitController.text, "0");
    });
  });

  group("rounding", () {
    test("the AED branch rounds rather than truncates", () async {
      stubRates({"AED": 1});
      // cbdEquityTier325Percent is one of the few double-backed amounts.
      viewModel.getFacility.cbdEquityTier325Percent = 7.6;

      await viewModel.getCurrencyRates(
        Reference(name: "AED"),
        CurrencyField.cbdEquityTier325Percent,
      );

      expect(viewModel.newCbdEquityTier325PercentController.text, "8");
    });
  });

  group("applyInitialCurrencyVisibility initial-AED short-circuit", () {
    test("shows the stored AED amounts instead of converting them", () async {
      stubRates({"USD": 3.67});
      seedFacility(
        currency: "USD",
        presentOutstanding: 80,
        proposedLimit: 125,
        presentLimit: 50,
        presentLimitAed: 184,
        presentOutstandingAed: 293.6,
        proposedLimitAed: 459,
      );

      viewModel.applyInitialCurrencyVisibility();

      // Written synchronously — no rate fetch is awaited for these.
      expect(viewModel.newPresentLimitController.text, "184");
      expect(viewModel.newPresentOutStandingController.text, "294");
      expect(viewModel.newProposedLimitController.text, "459");

      expect(viewModel.showNewPresentLimitAmount, isTrue);
      expect(viewModel.showNewPresentOutStandingLimit, isTrue);
      expect(viewModel.showNewProposedLimitAmount, isTrue);
    });

    test("the six FI amounts show their stored AED and fetch nothing",
        () async {
      stubRates({"USD": 3.67});
      seedFacility(
        currency: "USD",
        fiAmount: 125,
        fiAmountAed: 459,
        proposedByCc: 125,
        proposedByCcAed: 459,
        presentLimitAed: 1,
        presentOutstandingAed: 1,
        proposedLimitAed: 1,
      );

      viewModel.applyInitialCurrencyVisibility();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.newCbdEquityTier325PercentController.text, "459");
      expect(viewModel.newCounterpartyEquity5PercentController.text, "459");
      expect(
        viewModel.newCounterpartyTotalAssets2PercentController.text,
        "459",
      );
      expect(
        viewModel.newExcessOverMaxLimitAllowanceProposedByFiController.text,
        "459",
      );
      expect(
        viewModel
            .newExcessOverMaxLimitAllowanceRecommendedByCreditController.text,
        "459",
      );
      expect(viewModel.newProposedByccController.text, "459");

      verifyNever(() => mockRepository.getCurrencyList());
    });

    test("a main limit loads without warming the rate at all", () async {
      stubRates({"USD": 3.67});
      seedFacility(
        currency: "USD",
        presentLimit: 50,
        presentLimitAed: 184,
        presentOutstandingAed: 294,
        proposedLimitAed: 459,
      );

      viewModel.applyInitialCurrencyVisibility();
      // The warm-up would be fire-and-forget; give it the chance to land.
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => mockRepository.getCurrencyList());
      // The rate is only fetched once the user edits a field.
      expect(viewModel.exchangeRate, 0);
    });

    test("a sub-limit still warms exchangeRate for its parent-cap validation",
        () async {
      stubRates({"USD": 3.67});
      seedFacility(
        currency: "USD",
        presentLimit: 50,
        presentLimitAed: 184,
        presentOutstandingAed: 294,
        proposedLimitAed: 459,
        isMainLimit: false,
        parentProposedLimit: 1000,
      );

      viewModel.applyInitialCurrencyVisibility();
      // The warm-up is fire-and-forget; let it land.
      await Future<void>.delayed(Duration.zero);

      // Without the warm-up this would stay 0 and exceedsParentLimit would
      // start treating entered amounts as already-AED.
      expect(viewModel.exchangeRate, 3.67);
      verify(() => mockRepository.getCurrencyList()).called(1);
    });

    test("falls back to the live conversion when no AED value is stored",
        () async {
      stubRates({"USD": 3});
      // presentOutstanding has no stored AED here, so it converts live.
      seedFacility(currency: "USD", presentOutstanding: 80);

      viewModel.applyInitialCurrencyVisibility();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.newPresentOutStandingController.text, "240");
      // Only that one field converts; the empty ones need no rate.
      verify(() => mockRepository.getCurrencyList()).called(1);
    });

    test("an empty amount shows 0 without fetching a rate", () async {
      stubRates({"USD": 3});
      // Nothing entered anywhere: converting could only ever produce 0.
      seedFacility(currency: "USD");

      viewModel.applyInitialCurrencyVisibility();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.newPresentOutStandingController.text, "0");
      expect(viewModel.newCbdEquityTier325PercentController.text, "0");
      verifyNever(() => mockRepository.getCurrencyList());
    });

    test("AED currencies never short-circuit and never fetch", () {
      seedFacility(
        currency: "AED",
        presentOutstanding: 80,
        presentLimit: 50,
        presentLimitAed: 999,
      );

      viewModel.applyInitialCurrencyVisibility();

      // Unchanged AED path: the converted field mirrors the source amount
      // (which for present limit has always been the AED column).
      expect(viewModel.newPresentLimitController.text, "999");
      expect(viewModel.newPresentOutStandingController.text, "80");
      expect(viewModel.showNewPresentLimitAmount, isFalse);
      verifyNever(() => mockRepository.getCurrencyList());
    });
  });

  group("warmCurrencyRate", () {
    test("sets exchangeRate and writes no controller", () async {
      stubRates({"USD": 3.67});

      await viewModel.warmCurrencyRate(Reference(name: "USD"));

      expect(viewModel.exchangeRate, 3.67);
      expect(viewModel.newPresentLimitController.text, "");
    });

    test("shows a toast and leaves the rate alone on failure", () async {
      when(() => mockRepository.getCurrencyList())
          .thenThrow(Exception("boom"));
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.warmCurrencyRate(Reference(name: "USD"));

      expect(viewModel.exchangeRate, 0);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });
}
