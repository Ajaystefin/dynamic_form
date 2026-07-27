import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/country.dart";

void main() {
  group("Country", () {
    test("should create Country instance with all properties", () {
      final country = Country(
        code: "AE",
        description: "United Arab Emirates",
      );

      expect(country.code, "AE");
      expect(country.description, "United Arab Emirates");
    });

    test("should create Country instance with null properties", () {
      final country = Country();

      expect(country.code, isNull);
      expect(country.description, isNull);
    });

    test("should create Country from JSON with all properties", () {
      final json = {
        "countryCode": "AE",
        "description": "United Arab Emirates",
      };

      final country = Country.fromJson(json);

      expect(country.code, "AE");
      expect(country.description, "United Arab Emirates");
    });

    test("should create Country from JSON with null values", () {
      final json = {
        "countryCode": null,
        "description": null,
      };

      final country = Country.fromJson(json);

      expect(country.code, isNull);
      expect(country.description, isNull);
    });

    test("should create Country from JSON with missing properties", () {
      final json = {
        "countryCode": "AE",
      };

      final country = Country.fromJson(json);

      expect(country.code, "AE");
      expect(country.description, isNull);
    });

    test("should convert Country to JSON with all properties", () {
      final country = Country(
        code: "AE",
        description: "United Arab Emirates",
      );

      final json = country.toJson();

      expect(json["countryCode"], "AE");
      expect(json["description"], "United Arab Emirates");
    });

    test("should convert Country to JSON with null properties", () {
      final country = Country();

      final json = country.toJson();

      expect(json["countryCode"], isNull);
      expect(json["description"], isNull);
    });

    test("should handle empty strings", () {
      final country = Country(
        code: "",
        description: "",
      );

      final json = country.toJson();

      expect(json["countryCode"], "");
      expect(json["description"], "");
    });

    test("should handle special characters in description", () {
      final country = Country(
        code: "US",
        description:
            r"United States of America (USA) - Special chars: !@#$%^&*()",
      );

      final json = country.toJson();

      expect(json["countryCode"], "US");
      expect(
        json["description"],
        r"United States of America (USA) - Special chars: !@#$%^&*()",
      );
    });

    test("should handle different country codes", () {
      final countries = [
        Country(code: "US", description: "United States"),
        Country(code: "GB", description: "United Kingdom"),
        Country(code: "DE", description: "Germany"),
        Country(code: "FR", description: "France"),
        Country(code: "JP", description: "Japan"),
        Country(code: "CN", description: "China"),
        Country(code: "IN", description: "India"),
        Country(code: "BR", description: "Brazil"),
        Country(code: "CA", description: "Canada"),
        Country(code: "AU", description: "Australia"),
      ];

      for (final country in countries) {
        final json = country.toJson();
        expect(json["countryCode"], country.code);
        expect(json["description"], country.description);
      }
    });

    test("should handle long country descriptions", () {
      final country = Country(
        code: "XX",
        description: "This is a very long country description that contains "
            "many words and should be handled properly by the JSON "
            "serialization "
            "and deserialization methods. It includes various "
            "punctuation marks and special characters like: "
            r"!@#$%^&*()_+-=[]{}|;:,.<>?",
      );

      final json = country.toJson();
      final fromJson = Country.fromJson(json);

      expect(fromJson.code, "XX");
      expect(fromJson.description, country.description);
    });

    test("should handle numeric country codes as strings", () {
      final country = Country(
        code: "123",
        description: "Numeric Country Code",
      );

      final json = country.toJson();
      final fromJson = Country.fromJson(json);

      expect(fromJson.code, "123");
      expect(fromJson.description, "Numeric Country Code");
    });

    test("should handle whitespace in country codes and descriptions", () {
      final country = Country(
        code: "  AE  ",
        description: "  United Arab Emirates  ",
      );

      final json = country.toJson();
      final fromJson = Country.fromJson(json);

      expect(fromJson.code, "  AE  ");
      expect(fromJson.description, "  United Arab Emirates  ");
    });

    test("should handle unicode characters in descriptions", () {
      final country = Country(
        code: "ES",
        description: "España (Spain) - Español",
      );

      final json = country.toJson();
      final fromJson = Country.fromJson(json);

      expect(fromJson.code, "ES");
      expect(fromJson.description, "España (Spain) - Español");
    });

    test("should handle JSON with extra properties", () {
      final json = {
        "countryCode": "AE",
        "description": "United Arab Emirates",
        "extraProperty": "This should be ignored",
        "anotherProperty": 123,
      };

      final country = Country.fromJson(json);

      expect(country.code, "AE");
      expect(country.description, "United Arab Emirates");
    });

    test("should handle case sensitivity in country codes", () {
      final country1 = Country(code: "ae", description: "Lowercase UAE");
      final country2 = Country(code: "AE", description: "Uppercase UAE");
      final country3 = Country(code: "Ae", description: "Mixed case UAE");

      expect(country1.code, "ae");
      expect(country2.code, "AE");
      expect(country3.code, "Ae");
    });

    test("should handle round-trip JSON conversion", () {
      final originalCountry = Country(
        code: "AE",
        description: "United Arab Emirates",
      );

      final json = originalCountry.toJson();
      final convertedCountry = Country.fromJson(json);

      expect(convertedCountry.code, originalCountry.code);
      expect(convertedCountry.description, originalCountry.description);
    });

    test("should handle multiple round-trip conversions", () {
      final originalCountry = Country(
        code: "US",
        description: "United States of America",
      );

      Country currentCountry = originalCountry;

      for (int i = 0; i < 5; i++) {
        final json = currentCountry.toJson();
        currentCountry = Country.fromJson(json);
      }

      expect(currentCountry.code, originalCountry.code);
      expect(currentCountry.description, originalCountry.description);
    });
  });
}
