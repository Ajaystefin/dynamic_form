import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:wcas_frontend/core/components/currency/converted_amount_field.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class MockAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {"validation.emptyField": "Field cannot be empty"};
  }
}

void main() {
  late TextEditingController textController;
  late List<Reference> currencyCodes;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    textController = TextEditingController();
    currencyCodes = <Reference>[
      Reference(id: 1, name: "AED"),
      Reference(id: 2, name: "USD"),
    ];
  });

  tearDown(() {
    textController.dispose();
  });

  Widget wrap(Widget child) {
    return EasyLocalization(
      supportedLocales: const [Locale("en")],
      fallbackLocale: const Locale("en"),
      startLocale: const Locale("en"),
      path: "assets/translations",
      assetLoader: MockAssetLoader(),
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  group("ConvertedAmountField", () {
    testWidgets("renders read-only and filled with the default initial value",
        (tester) async {
      await tester.pumpWidget(
        wrap(
          ConvertedAmountField(
            currencies: currencyCodes,
            controller: textController,
            inputFormatters: currencyAmountFormatters(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ConvertedAmountField), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      final TextField field = tester.widget<TextField>(find.byType(TextField));
      expect(textController.text, "0");
      expect(field.readOnly, isTrue);
      expect(field.decoration?.filled, isTrue);
    });

    testWidgets("carries the currency formatter list", (tester) async {
      await tester.pumpWidget(
        wrap(
          ConvertedAmountField(
            currencies: currencyCodes,
            controller: textController,
            inputFormatters: currencyAmountFormatters(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final TextField field = tester.widget<TextField>(find.byType(TextField));
      final List<TextInputFormatter>? formatters = field.inputFormatters;

      expect(formatters, isNotNull);
      expect(
        formatters!.any((f) => f is LengthLimitingTextInputFormatter),
        isTrue,
      );
      expect(formatters.any((f) => f is FilteringTextInputFormatter), isTrue);
      expect(formatters.length, 3);
    });

    testWidgets("locks the dropdown to AED when present", (tester) async {
      await tester.pumpWidget(
        wrap(
          ConvertedAmountField(
            currencies: currencyCodes,
            controller: textController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("AED"), findsOneWidget);
    });

    testWidgets("falls back to the first currency when AED is absent",
        (tester) async {
      await tester.pumpWidget(
        wrap(
          ConvertedAmountField(
            currencies: <Reference>[
              Reference(id: 2, name: "USD"),
              Reference(id: 3, name: "EUR"),
            ],
            controller: textController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The outgoing widgets used `.where(...).first` here and threw a
      // StateError instead of rendering.
      expect(tester.takeException(), isNull);
      expect(find.text("USD"), findsOneWidget);
    });

    testWidgets("renders without throwing when the currency list is empty",
        (tester) async {
      await tester.pumpWidget(
        wrap(
          ConvertedAmountField(
            currencies: const <Reference>[],
            controller: textController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets("readOnly/filled can be turned off for the present-security "
        "call site", (tester) async {
      await tester.pumpWidget(
        wrap(
          ConvertedAmountField(
            currencies: currencyCodes,
            controller: textController,
            readOnly: false,
            filled: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final TextField field = tester.widget<TextField>(find.byType(TextField));
      expect(field.readOnly, isFalse);
      expect(field.decoration?.filled, isFalse);
    });
  });
}
