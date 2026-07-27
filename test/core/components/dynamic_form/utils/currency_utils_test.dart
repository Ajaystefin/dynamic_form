import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form/utils/currency_utils.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";

void main() {
  group("CurrencyUtils", () {
    group("formatCurrency", () {
      test("should format whole number with thousand separators", () {
        final result = CurrencyUtils.formatCurrency(1234);

        expect(result, "1,234");
      });

      test("should format large number with thousand separators", () {
        final result = CurrencyUtils.formatCurrency(123456789);

        expect(result, "123,456,789");
      });

      test("should round decimal values before formatting", () {
        final result = CurrencyUtils.formatCurrency(1234.99);

        expect(result, "1,235");
      });

      test("should round down below the halfway point", () {
        final result = CurrencyUtils.formatCurrency(1234.4);

        expect(result, "1,234");
      });

      test("should round up at the halfway point", () {
        final result = CurrencyUtils.formatCurrency(1234.5);

        expect(result, "1,235");
      });

      test("should format zero", () {
        final result = CurrencyUtils.formatCurrency(0);

        expect(result, "0");
      });

      test("should format negative values", () {
        final result = CurrencyUtils.formatCurrency(-1234.99);

        expect(result, "-1,235");
      });
    });

    group("parseCurrency", () {
      test("should parse comma separated currency string", () {
        final result = CurrencyUtils.parseCurrency("1,234");

        expect(result, 1234.0);
      });

      test("should parse large comma separated currency string", () {
        final result = CurrencyUtils.parseCurrency("123,456,789");

        expect(result, 123456789.0);
      });

      test("should parse decimal currency string", () {
        final result = CurrencyUtils.parseCurrency("1,234.56");

        expect(result, 1234.56);
      });

      test("should parse currency string without comma", () {
        final result = CurrencyUtils.parseCurrency("9876");

        expect(result, 9876.0);
      });

      test("should parse negative currency string", () {
        final result = CurrencyUtils.parseCurrency("-1,234.56");

        expect(result, -1234.56);
      });

      test("should return null for invalid currency string", () {
        final result = CurrencyUtils.parseCurrency("abc");

        expect(result, null);
      });

      test("should return null for empty currency string", () {
        final result = CurrencyUtils.parseCurrency("");

        expect(result, null);
      });

      test("should return null for invalid mixed currency string", () {
        final result = CurrencyUtils.parseCurrency("1,23a");

        expect(result, null);
      });
    });

    group("isAedCurrency", () {
      test("should return true when currency is AED", () {
        final result = CurrencyUtils.isAedCurrency(ServerConstants.aedCurrency);

        expect(result, true);
      });

      test("should return false when currency is not AED", () {
        final result = CurrencyUtils.isAedCurrency("USD");

        expect(result, false);
      });

      test("should return false when currency is null", () {
        final result = CurrencyUtils.isAedCurrency(null);

        expect(result, false);
      });

      test("should return false when currency is empty", () {
        final result = CurrencyUtils.isAedCurrency("");

        expect(result, false);
      });
    });

    group("createCurrencyMap", () {
      test("should create currency map with standard keys", () {
        final result = CurrencyUtils.createCurrencyMap(
          currency: "USD",
          amount: 100,
          aedEquivalent: 367,
        );

        expect(
          result,
          <String, dynamic>{
            "fromCurrency": "USD",
            "fromVal": 100.0,
            "aedEquivalent": 367.0,
          },
        );
      });

      test("should create currency map with zero values", () {
        final result = CurrencyUtils.createCurrencyMap(
          currency: "AED",
          amount: 0,
          aedEquivalent: 0,
        );

        expect(result["fromCurrency"], "AED");
        expect(result["fromVal"], 0.0);
        expect(result["aedEquivalent"], 0.0);
      });

      test("should create currency map with decimal values", () {
        final result = CurrencyUtils.createCurrencyMap(
          currency: "EUR",
          amount: 10.55,
          aedEquivalent: 42.22,
        );

        expect(result["fromCurrency"], "EUR");
        expect(result["fromVal"], 10.55);
        expect(result["aedEquivalent"], 42.22);
      });
    });

    group("calculateAedEquivalent", () {
      test("should return amount as-is when currency is AED", () {
        final result = CurrencyUtils.calculateAedEquivalent(
          currency: ServerConstants.aedCurrency,
          amount: 150,
          exchangeRate: 3.67,
        );

        expect(result, 150.0);
      });

      test("should multiply amount by exchange rate when currency is not AED",
          () {
        final result = CurrencyUtils.calculateAedEquivalent(
          currency: "USD",
          amount: 100,
          exchangeRate: 3.67,
        );

        expect(result, 367.0);
      });

      test("should calculate AED equivalent for decimal amount", () {
        final result = CurrencyUtils.calculateAedEquivalent(
          currency: "USD",
          amount: 10.5,
          exchangeRate: 3.5,
        );

        expect(result, 36.75);
      });

      test("should return zero when non-AED amount is zero", () {
        final result = CurrencyUtils.calculateAedEquivalent(
          currency: "USD",
          amount: 0,
          exchangeRate: 3.67,
        );

        expect(result, 0.0);
      });

      test("should return zero when non-AED exchange rate is zero", () {
        final result = CurrencyUtils.calculateAedEquivalent(
          currency: "USD",
          amount: 100,
          exchangeRate: 0,
        );

        expect(result, 0.0);
      });
    });

    group("extractFromDocument", () {
      test("should return null when document is null", () {
        final result = CurrencyUtils.extractFromDocument(null, "amount");

        expect(result, null);
      });

      test("should return null when field key does not exist", () {
        final document = <String, dynamic>{
          "otherField": <String, dynamic>{"USD": 100},
        };

        final result = CurrencyUtils.extractFromDocument(document, "amount");

        expect(result, null);
      });

      test("should return null when stored value is not map", () {
        final document = <String, dynamic>{
          "amount": "invalid",
        };

        final result = CurrencyUtils.extractFromDocument(document, "amount");

        expect(result, null);
      });

      test("should return null when stored value is empty map", () {
        final document = <String, dynamic>{
          "amount": <String, dynamic>{},
        };

        final result = CurrencyUtils.extractFromDocument(document, "amount");

        expect(result, null);
      });

      test("should extract new API format with numeric values", () {
        final document = <String, dynamic>{
          "amount": <String, dynamic>{
            "fromCurrency": "USD",
            "fromVal": 100,
            "aedEquivalent": 367,
          },
        };

        final result = CurrencyUtils.extractFromDocument(document, "amount");

        expect(result, isNotNull);
        expect(result?.currency, "USD");
        expect(result?.amount, 100.0);
        expect(result?.aedEquivalent, 367.0);
      });

      test("should extract new API format with string numeric values", () {
        final document = <String, dynamic>{
          "amount": <String, dynamic>{
            "fromCurrency": "EUR",
            "fromVal": "200.50",
            "aedEquivalent": "800.75",
          },
        };

        final result = CurrencyUtils.extractFromDocument(document, "amount");

        expect(result, isNotNull);
        expect(result?.currency, "EUR");
        expect(result?.amount, 200.50);
        expect(result?.aedEquivalent, 800.75);
      });

      test("should extract new API format and convert currency to string", () {
        final document = <String, dynamic>{
          "amount": <String, dynamic>{
            "fromCurrency": 123,
            "fromVal": 50,
            "aedEquivalent": 183.5,
          },
        };

        final result = CurrencyUtils.extractFromDocument(document, "amount");

        expect(result, isNotNull);
        expect(result?.currency, "123");
        expect(result?.amount, 50.0);
        expect(result?.aedEquivalent, 183.5);
      });

      test("should extract new API format with null values", () {
        final document = <String, dynamic>{
          "amount": <String, dynamic>{
            "fromCurrency": null,
            "fromVal": null,
            "aedEquivalent": null,
          },
        };

        final result = CurrencyUtils.extractFromDocument(document, "amount");

        expect(result, isNotNull);
        expect(result?.currency, null);
        expect(result?.amount, null);
        expect(result?.aedEquivalent, null);
      });

      test("should extract new API format with invalid numeric values", () {
        final document = <String, dynamic>{
          "amount": <String, dynamic>{
            "fromCurrency": "USD",
            "fromVal": "invalid",
            "aedEquivalent": "invalid",
          },
        };

        final result = CurrencyUtils.extractFromDocument(document, "amount");

        expect(result, isNotNull);
        expect(result?.currency, "USD");
        expect(result?.amount, null);
        expect(result?.aedEquivalent, null);
      });

      test("should extract new API format when fromVal key is missing", () {
        final document = <String, dynamic>{
          "amount": <String, dynamic>{
            "fromCurrency": "USD",
            "aedEquivalent": 367,
          },
        };

        final result = CurrencyUtils.extractFromDocument(document, "amount");

        expect(result, isNotNull);
        expect(result?.currency, "USD");
        expect(result?.amount, null);
        expect(result?.aedEquivalent, 367.0);
      });

      test("should extract new API format when aedEquivalent key is missing",
          () {
        final document = <String, dynamic>{
          "amount": <String, dynamic>{
            "fromCurrency": "USD",
            "fromVal": 100,
          },
        };

        final result = CurrencyUtils.extractFromDocument(document, "amount");

        expect(result, isNotNull);
        expect(result?.currency, "USD");
        expect(result?.amount, 100.0);
        expect(result?.aedEquivalent, null);
      });

      test("should extract old format with numeric amount", () {
        final document = <String, dynamic>{
          "amount": <String, dynamic>{
            "USD": 100,
          },
        };

        final result = CurrencyUtils.extractFromDocument(document, "amount");

        expect(result, isNotNull);
        expect(result?.currency, "USD");
        expect(result?.amount, 100.0);
        expect(result?.aedEquivalent, null);
      });

      test("should extract old format with string numeric amount", () {
        final document = <String, dynamic>{
          "amount": <String, dynamic>{
            "EUR": "250.75",
          },
        };

        final result = CurrencyUtils.extractFromDocument(document, "amount");

        expect(result, isNotNull);
        expect(result?.currency, "EUR");
        expect(result?.amount, 250.75);
        expect(result?.aedEquivalent, null);
      });

      test("should extract old format with null amount", () {
        final document = <String, dynamic>{
          "amount": <String, dynamic>{
            "USD": null,
          },
        };

        final result = CurrencyUtils.extractFromDocument(document, "amount");

        expect(result, isNotNull);
        expect(result?.currency, "USD");
        expect(result?.amount, null);
        expect(result?.aedEquivalent, null);
      });

      test("should extract old format with invalid amount", () {
        final document = <String, dynamic>{
          "amount": <String, dynamic>{
            "USD": "invalid",
          },
        };

        final result = CurrencyUtils.extractFromDocument(document, "amount");

        expect(result, isNotNull);
        expect(result?.currency, "USD");
        expect(result?.amount, null);
        expect(result?.aedEquivalent, null);
      });

      test(
          "should extract first entry in old format when multiple entries exist",
          () {
        final document = <String, dynamic>{
          "amount": <String, dynamic>{
            "USD": 100,
            "EUR": 200,
          },
        };

        final result = CurrencyUtils.extractFromDocument(document, "amount");

        expect(result, isNotNull);
        expect(result?.currency, "USD");
        expect(result?.amount, 100.0);
        expect(result?.aedEquivalent, null);
      });
    });
  });

  group("CurrencyFieldData", () {
    test("should create data object with all values", () {
      const data = CurrencyFieldData(
        currency: "USD",
        amount: 100,
        aedEquivalent: 367,
      );

      expect(data.currency, "USD");
      expect(data.amount, 100.0);
      expect(data.aedEquivalent, 367.0);
    });

    test("should create data object with null values", () {
      const data = CurrencyFieldData();

      expect(data.currency, null);
      expect(data.amount, null);
      expect(data.aedEquivalent, null);
    });

    test("formattedAmount should return formatted amount when amount exists",
        () {
      const data = CurrencyFieldData(
        currency: "USD",
        amount: 1234.56,
      );

      expect(data.formattedAmount, "1,235");
    });

    test("formattedAmount should return empty string when amount is null", () {
      const data = CurrencyFieldData(
        currency: "USD",
      );

      expect(data.formattedAmount, "");
    });

    test(
        "formattedAedEquivalent should return formatted AED equivalent when value exists",
        () {
      const data = CurrencyFieldData(
        currency: "USD",
        aedEquivalent: 12345.67,
      );

      expect(data.formattedAedEquivalent, "12,346");
    });

    test(
        "formattedAedEquivalent should return empty string when AED equivalent is null",
        () {
      const data = CurrencyFieldData(
        currency: "USD",
      );

      expect(data.formattedAedEquivalent, "");
    });

    test("formatted values should handle zero", () {
      const data = CurrencyFieldData(
        currency: "AED",
        amount: 0,
        aedEquivalent: 0,
      );

      expect(data.formattedAmount, "0");
      expect(data.formattedAedEquivalent, "0");
    });

    test("formatted values should handle negative values", () {
      const data = CurrencyFieldData(
        currency: "USD",
        amount: -1234.99,
        aedEquivalent: -5678.99,
      );

      expect(data.formattedAmount, "-1,235");
      expect(data.formattedAedEquivalent, "-5,679");
    });
  });
}
