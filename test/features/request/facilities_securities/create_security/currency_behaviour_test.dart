import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/currency_rates_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/exchange_rate.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";

import "../../../../test_config.dart";

class _MockFacilitySecurityRepository extends Mock
    implements FacilitySecurityRepository {}

class _MockAlertManager extends Mock implements AlertManager {}

void main() {
  late CreateSecurityViewModel viewModel;
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

    viewModel = CreateSecurityViewModel()..securityRepository = mockRepository;

    CurrencyRatesService()
      ..clearCache()
      ..repository = mockRepository;
  });

  tearDown(() async {
    await viewModel.close();
    CurrencyRatesService().clearCache();
  });

  void stubRates(Map<String, num> rates) {
    when(() => mockRepository.getAllCurrencyRates())
        .thenAnswer((_) async => CurrencyRates(rates: rates));
  }

  group("getCurrencyRatesDebounced", () {
    test("collapses a burst of triggers into one repository call", () async {
      stubRates({"USD": 3.67});
      viewModel.security = Security(proposedSecurityAmount: 100);

      final Reference usd = Reference(name: "USD");
      unawaited(
        viewModel.getCurrencyRatesDebounced(
          usd,
          isPresentSecurityAmount: false,
        ),
      );
      unawaited(
        viewModel.getCurrencyRatesDebounced(
          usd,
          isPresentSecurityAmount: false,
        ),
      );
      await viewModel.getCurrencyRatesDebounced(
        usd,
        isPresentSecurityAmount: false,
      );

      verify(() => mockRepository.getAllCurrencyRates()).called(1);
      expect(viewModel.exchangeRate, 3.67);
      expect(viewModel.newProposedSecurityAmountController.text, "367");
    });

    test("present and proposed debounce independently", () async {
      stubRates({"USD": 2});
      viewModel.security = Security(
        presentSecurityAmount: 10,
        proposedSecurityAmount: 20,
      );

      final Reference usd = Reference(name: "USD");
      await Future.wait(<Future<void>>[
        viewModel.getCurrencyRatesDebounced(
          usd,
          isPresentSecurityAmount: true,
        ),
        viewModel.getCurrencyRatesDebounced(
          usd,
          isPresentSecurityAmount: false,
        ),
      ]);

      // Both amounts resolve to the same currency around the same time, so
      // CurrencyRatesService's cache/in-flight de-dupe collapses this to a
      // single underlying repository call.
      verify(() => mockRepository.getAllCurrencyRates()).called(1);
      expect(viewModel.newPresentSecurityAmountController.text, "20");
      expect(viewModel.newProposedSecurityAmountController.text, "40");
    });

    test("toggles the loading flag around the fetch", () async {
      stubRates({"USD": 3.67});
      viewModel.security = Security(proposedSecurityAmount: 1);

      final loading = viewModel.rateLoadingFor(isPresentSecurityAmount: false);
      expect(loading.value, isFalse);

      final Future<void> pending = viewModel.getCurrencyRatesDebounced(
        Reference(name: "USD"),
        isPresentSecurityAmount: false,
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
      viewModel.security = Security(proposedSecurityAmount: 0);

      await viewModel.getCurrencyRatesDebounced(
        Reference(name: "USD"),
        isPresentSecurityAmount: false,
        proposedAmount: 0,
      );

      verifyNever(() => mockRepository.getAllCurrencyRates());
      expect(viewModel.newProposedSecurityAmountController.text, "0");
      expect(viewModel.security.aedProposedSecurity, 0);
    });

    test("a rate already in flight cannot overwrite the cleared box", () async {
      final Completer<CurrencyRates> inFlight = Completer<CurrencyRates>();
      when(() => mockRepository.getAllCurrencyRates())
          .thenAnswer((_) => inFlight.future);

      final Reference usd = Reference(name: "USD");
      viewModel.security = Security(proposedSecurityAmount: 100);

      unawaited(
        viewModel.getCurrencyRatesDebounced(
          usd,
          isPresentSecurityAmount: false,
          proposedAmount: 100,
        ),
      );
      // Past the debounce, so the request is out and waiting on the response.
      await Future<void>.delayed(const Duration(milliseconds: 400));

      // The user clears the box while that response is still travelling.
      viewModel.security.proposedSecurityAmount = 0;
      await viewModel.getCurrencyRatesDebounced(
        usd,
        isPresentSecurityAmount: false,
        proposedAmount: 0,
      );
      expect(viewModel.newProposedSecurityAmountController.text, "0");

      inFlight.complete(const CurrencyRates(rates: {"USD": 3.67}));
      await Future<void>.delayed(Duration.zero);

      // Not "367": the superseded response is discarded.
      expect(viewModel.newProposedSecurityAmountController.text, "0");
    });
  });

  group("rounding", () {
    test("converted AED is rounded, not truncated", () async {
      stubRates({"USD": 1.0});
      // 7.6 AED must display as 8, not 7.
      viewModel.security = Security(proposedSecurityAmount: 7.6);

      await viewModel.getCurrencyRates(
        Reference(name: "USD"),
        isPresentSecurityAmount: false,
      );

      expect(viewModel.newProposedSecurityAmountController.text, "8");
      // The unrounded value is what reaches the payload.
      expect(viewModel.security.aedProposedSecurity, 7.6);
    });
  });

  group("applyInitialSecurityCurrency", () {
    test("shows the stored AED amounts instead of the converted ones",
        () async {
      stubRates({"USD": 3.67});
      viewModel.security = Security(
        proposedSecurityAmtCurrency: Reference(name: "USD"),
        presentSecurityAmount: 100,
        proposedSecurityAmount: 200,
        aedPresentSecurity: 111.4,
        aedProposedSecurity: 222.6,
      );

      await viewModel.applyInitialSecurityCurrency();

      // Not 100 * 3.67 / 200 * 3.67 — the backend's own values win, rounded.
      expect(viewModel.newPresentSecurityAmountController.text, "111");
      expect(viewModel.newProposedSecurityAmountController.text, "223");
      expect(viewModel.security.aedPresentSecurity, 111.4);
      expect(viewModel.security.aedProposedSecurity, 222.6);
    });

    test("makes no rate call when the API supplies the AED values", () async {
      stubRates({"USD": 3.67});
      viewModel.security = Security(
        proposedSecurityAmtCurrency: Reference(name: "USD"),
        proposedSecurityAmount: 200,
        aedProposedSecurity: 222.6,
      );

      await viewModel.applyInitialSecurityCurrency();

      verifyNever(() => mockRepository.getAllCurrencyRates());
      // The rate is only fetched once the user edits a field.
      expect(viewModel.exchangeRate, 0);
    });

    test("treats a stored AED of 0 as an answer, not as missing", () async {
      stubRates({"AUD": 2.51});
      // Mirrors issue/getSecurityDetails.json: present side is a genuine zero.
      viewModel.security = Security(
        proposedSecurityAmtCurrency: Reference(name: "AUD"),
        presentSecurityAmount: 0,
        proposedSecurityAmount: 230,
        aedPresentSecurity: 0,
        aedProposedSecurity: 578,
      );

      await viewModel.applyInitialSecurityCurrency();

      verifyNever(() => mockRepository.getAllCurrencyRates());
      expect(viewModel.newPresentSecurityAmountController.text, "0");
      expect(viewModel.newProposedSecurityAmountController.text, "578");
    });

    test("falls back to the live conversion when no AED value is stored",
        () async {
      stubRates({"USD": 3});
      viewModel.security = Security(
        proposedSecurityAmtCurrency: Reference(name: "USD"),
        proposedSecurityAmount: 200,
      );

      await viewModel.applyInitialSecurityCurrency();

      verify(() => mockRepository.getAllCurrencyRates()).called(1);
      expect(viewModel.newProposedSecurityAmountController.text, "600");
    });
  });
}
