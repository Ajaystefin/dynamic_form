import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/exchange_rate.dart";
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
  });

  tearDown(() async {
    await viewModel.close();
  });

  void stubRates(Map<String, num> rates) {
    when(() => mockRepository.getCurrencyRates(any()))
        .thenAnswer((_) async => CurrencyRates(rates: rates));
  }

  /// Seeds the minimum state `applyInitialCurrencyVisibility` reads.
  void seedFacility({
    required String currency,
    int presentOutstanding = 0,
    int proposedLimit = 0,
    int presentLimit = 0,
    num? presentLimitAed,
    num? presentOutstandingAed,
    num? proposedLimitAed,
  }) {
    final FacilityDetail detail = FacilityDetail.fromJson({
      "presentLimit": presentLimit,
      if (presentLimitAed != null) "presentLimitAED": presentLimitAed,
      if (presentOutstandingAed != null)
        "presentOutstandingAED": presentOutstandingAed,
      if (proposedLimitAed != null) "proposedLimitAED": proposedLimitAed,
    });

    viewModel
      ..facilityDetail = <FacilityDetail>[detail]
      ..getFacility.presentOutstandingAmount = presentOutstanding
      ..getFacility.presentOutstandingCurrency = Reference(name: currency)
      ..getFacility.proposedLimit = proposedLimit
      ..getFacility.proposedLimitValue = Reference(name: currency)
      ..getFacility.presentLimit = presentLimit
      ..getFacility.presentLimitValue = Reference(name: currency)
      ..getFacility.proposedByCc = 0
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

      verify(() => mockRepository.getCurrencyRates(any())).called(1);
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

      verify(() => mockRepository.getCurrencyRates(any())).called(2);
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

    test("still warms exchangeRate so sub-limit validation keeps working",
        () async {
      stubRates({"USD": 3.67});
      seedFacility(
        currency: "USD",
        presentLimit: 50,
        presentLimitAed: 184,
        presentOutstandingAed: 294,
        proposedLimitAed: 459,
      );

      viewModel.applyInitialCurrencyVisibility();
      // The warm-up is fire-and-forget; let it land.
      await Future<void>.delayed(Duration.zero);

      // Without the warm-up this would stay 0 and exceedsParentLimit would
      // start treating entered amounts as already-AED.
      expect(viewModel.exchangeRate, 3.67);
    });

    test("falls back to the live conversion when no AED value is stored",
        () async {
      stubRates({"USD": 3});
      // presentOutstanding has no stored AED here, so it converts as before.
      seedFacility(currency: "USD", presentOutstanding: 80);

      viewModel.applyInitialCurrencyVisibility();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.newPresentOutStandingController.text, "240");
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
      verifyNever(() => mockRepository.getCurrencyRates(any()));
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
      when(() => mockRepository.getCurrencyRates(any()))
          .thenThrow(Exception("boom"));
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.warmCurrencyRate(Reference(name: "USD"));

      expect(viewModel.exchangeRate, 0);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });
}
