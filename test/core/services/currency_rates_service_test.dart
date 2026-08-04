import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/services/currency_rates_service.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";

class MockFacilitySecurityRepository extends Mock
    implements FacilitySecurityRepository {}

void main() {
  late CurrencyRatesService service;
  late MockFacilitySecurityRepository mockRepository;

  setUp(() {
    mockRepository = MockFacilitySecurityRepository();
    service = CurrencyRatesService();

    CurrencyRatesService.overrideInstance = service;

    service
      ..clearCache()
      ..repository = mockRepository;
  });

  tearDown(() {
    service
      ..clearCache()
      ..repository = null;
  });

  group("CurrencyRatesService.getRates", () {
    test("fetches from the repository on the first call", () async {
      when(() => mockRepository.getCurrencyList()).thenAnswer(
        (_) async => (
          currencies: <Reference>[Reference(name: "USD"), Reference(name: "AED")],
          rates: {"USD": 3.67, "AED": 1},
        ),
      );

      final rates = await service.getRates();

      expect(rates, {"USD": 3.67, "AED": 1});
      verify(() => mockRepository.getCurrencyList()).called(1);
    });

    test("reuses the cached table on subsequent calls", () async {
      when(() => mockRepository.getCurrencyList()).thenAnswer(
        (_) async => (
          currencies: <Reference>[Reference(name: "USD")],
          rates: {"USD": 3.67},
        ),
      );

      final first = await service.getRates();
      final second = await service.getRates();

      expect(first, same(second));
      verify(() => mockRepository.getCurrencyList()).called(1);
    });

    test("de-dupes concurrent first callers into a single repository call",
        () async {
      when(() => mockRepository.getCurrencyList()).thenAnswer(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return (
            currencies: <Reference>[Reference(name: "USD")],
            rates: {"USD": 3.67},
          );
        },
      );

      final results = await Future.wait([
        service.getRates(),
        service.getRates(),
        service.getRates(),
      ]);

      expect(results, everyElement({"USD": 3.67}));
      verify(() => mockRepository.getCurrencyList()).called(1);
    });

    test("clearCache forces the next call to re-fetch", () async {
      when(() => mockRepository.getCurrencyList()).thenAnswer(
        (_) async => (
          currencies: <Reference>[Reference(name: "USD")],
          rates: {"USD": 3.67},
        ),
      );

      await service.getRates();
      service.clearCache();
      await service.getRates();

      verify(() => mockRepository.getCurrencyList()).called(2);
    });
  });

  group("CurrencyRatesService.getCurrencies", () {
    test("fetches from the repository on the first call", () async {
      when(() => mockRepository.getCurrencyList()).thenAnswer(
        (_) async => (
          currencies: <Reference>[Reference(name: "USD"), Reference(name: "AED")],
          rates: {"USD": 3.67, "AED": 1},
        ),
      );

      final currencies = await service.getCurrencies();

      expect(currencies.map((c) => c.name), ["USD", "AED"]);
      verify(() => mockRepository.getCurrencyList()).called(1);
    });

    test("reuses the cached list on subsequent calls", () async {
      when(() => mockRepository.getCurrencyList()).thenAnswer(
        (_) async => (
          currencies: <Reference>[Reference(name: "USD")],
          rates: {"USD": 3.67},
        ),
      );

      final first = await service.getCurrencies();
      final second = await service.getCurrencies();

      expect(first, same(second));
      verify(() => mockRepository.getCurrencyList()).called(1);
    });

    test("clearCache forces the next call to re-fetch", () async {
      when(() => mockRepository.getCurrencyList()).thenAnswer(
        (_) async => (
          currencies: <Reference>[Reference(name: "USD")],
          rates: {"USD": 3.67},
        ),
      );

      await service.getCurrencies();
      service.clearCache();
      await service.getCurrencies();

      verify(() => mockRepository.getCurrencyList()).called(2);
    });

    test("getCurrencies and getRates share a single underlying fetch",
        () async {
      when(() => mockRepository.getCurrencyList()).thenAnswer(
        (_) async => (
          currencies: <Reference>[Reference(name: "USD")],
          rates: {"USD": 3.67},
        ),
      );

      final currencies = await service.getCurrencies();
      final rates = await service.getRates();

      expect(currencies.map((c) => c.name), ["USD"]);
      expect(rates, {"USD": 3.67});
      verify(() => mockRepository.getCurrencyList()).called(1);
    });
  });

  group("CurrencyRatesService.getRate / getRateFor", () {
    test("getRate returns null for a null currency code without fetching",
        () async {
      final rate = await service.getRate(null);

      expect(rate, isNull);
      verifyNever(() => mockRepository.getCurrencyList());
    });

    test("getRate returns the rate for a known code", () async {
      when(() => mockRepository.getCurrencyList()).thenAnswer(
        (_) async => (
          currencies: <Reference>[Reference(name: "EUR")],
          rates: {"EUR": 4.0},
        ),
      );

      expect(await service.getRate("EUR"), 4.0);
      expect(await service.getRate("GBP"), isNull);
    });

    test("getRateFor resolves the rate from a Reference", () async {
      when(() => mockRepository.getCurrencyList()).thenAnswer(
        (_) async => (
          currencies: <Reference>[Reference(name: "USD")],
          rates: {"USD": 3.67},
        ),
      );

      expect(await service.getRateFor(Reference(name: "USD")), 3.67);
      expect(await service.getRateFor(null), isNull);
    });
  });
}
