import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/form_access_provider.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class MockAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {"validation.emptyField": "Field cannot be empty"};
  }
}

void main() {
  late List<Reference> currencyCodes;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    currencyCodes = <Reference>[
      Reference(id: 1, name: "AED"),
      Reference(id: 2, name: "USD"),
    ];
  });

  Widget wrap(Widget child, {bool? formDisabled}) {
    final Widget body =
        formDisabled == null ? child : FormAccessProvider(disabled: formDisabled, child: child);
    return EasyLocalization(
      supportedLocales: const [Locale("en")],
      fallbackLocale: const Locale("en"),
      startLocale: const Locale("en"),
      path: "assets/translations",
      assetLoader: MockAssetLoader(),
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: Scaffold(body: body),
        ),
      ),
    );
  }

  group("CurrencyAmountField", () {
    testWidgets("wraps in a LabelWidget only when a label is given",
        (tester) async {
      await tester.pumpWidget(
        wrap(
          CurrencyAmountField(
            currencies: currencyCodes,
            selectedCurrencies: <Reference?>[currencyCodes.first],
            label: "Present Limit",
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.text("Present Limit"), findsOneWidget);

      await tester.pumpWidget(
        wrap(
          CurrencyAmountField(
            currencies: currencyCodes,
            selectedCurrencies: <Reference?>[currencyCodes.first],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LabelWidget), findsNothing);
      expect(find.byType(CustomTextField), findsOneWidget);
    });

    testWidgets("applies fieldKey to the inner CustomTextField, not the wrapper",
        (tester) async {
      const Key key = ValueKey("amount-field");

      await tester.pumpWidget(
        wrap(
          CurrencyAmountField(
            currencies: currencyCodes,
            selectedCurrencies: <Reference?>[currencyCodes.first],
            label: "Present Limit",
            fieldKey: key,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(key), findsOneWidget);
      expect(tester.widget(find.byKey(key)), isA<CustomTextField>());
    });

    testWidgets("renders the pre-selected currency code", (tester) async {
      await tester.pumpWidget(
        wrap(
          CurrencyAmountField(
            currencies: currencyCodes,
            selectedCurrencies: <Reference?>[currencyCodes[1]],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("USD"), findsOneWidget);
    });

    testWidgets("renders every 'nothing selected' shape without throwing",
        (tester) async {
      final List<List<Reference?>> shapes = <List<Reference?>>[
        <Reference?>[],
        <Reference?>[null],
        <Reference?>[Reference()],
        <Reference?>[currencyCodes.first],
      ];

      for (final List<Reference?> shape in shapes) {
        await tester.pumpWidget(
          wrap(
            CurrencyAmountField(
              currencies: currencyCodes,
              selectedCurrencies: shape,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CustomTextField), findsOneWidget);
      }
    });

    testWidgets("null inputFormatters really means no formatters",
        (tester) async {
      await tester.pumpWidget(
        wrap(
          CurrencyAmountField(
            currencies: currencyCodes,
            selectedCurrencies: <Reference?>[currencyCodes.first],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final TextField field = tester.widget<TextField>(find.byType(TextField));
      expect(field.inputFormatters, isNull);

      // The field must accept text a digits-only formatter would have stripped.
      await tester.enterText(find.byType(TextField), "abc");
      await tester.pump();
      expect(find.text("abc"), findsOneWidget);
    });

    testWidgets("forwards a supplied formatter list verbatim", (tester) async {
      final List<TextInputFormatter> formatters = currencyAmountFormatters();

      await tester.pumpWidget(
        wrap(
          CurrencyAmountField(
            currencies: currencyCodes,
            selectedCurrencies: <Reference?>[currencyCodes.first],
            inputFormatters: formatters,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final TextField field = tester.widget<TextField>(find.byType(TextField));
      expect(field.inputFormatters, same(formatters));
      expect(field.inputFormatters, hasLength(3));
    });

    testWidgets("passes readOnly and filled through to the field",
        (tester) async {
      await tester.pumpWidget(
        wrap(
          CurrencyAmountField(
            currencies: currencyCodes,
            selectedCurrencies: <Reference?>[currencyCodes.first],
            readOnly: true,
            filled: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final TextField field = tester.widget<TextField>(find.byType(TextField));
      expect(field.readOnly, isTrue);
      expect(field.decoration?.filled, isTrue);
    });

    testWidgets("reports the picked currency through onCurrencySelected",
        (tester) async {
      final List<Reference> picked = <Reference>[];

      await tester.pumpWidget(
        wrap(
          CurrencyAmountField(
            currencies: currencyCodes,
            selectedCurrencies: <Reference?>[currencyCodes.first],
            onCurrencySelected: picked.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text("AED"), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text("USD").last, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(picked, hasLength(1));
      expect(picked.single.name, "USD");
    });

    testWidgets("a disabled FormAccessProvider ancestor disables the field",
        (tester) async {
      await tester.pumpWidget(
        wrap(
          CurrencyAmountField(
            currencies: currencyCodes,
            selectedCurrencies: <Reference?>[currencyCodes.first],
          ),
          formDisabled: true,
        ),
      );
      await tester.pumpAndSettle();

      final TextField field = tester.widget<TextField>(find.byType(TextField));
      expect(field.readOnly, isTrue);
    });

    testWidgets("ignoreProvider opts out of a disabled FormAccessProvider",
        (tester) async {
      await tester.pumpWidget(
        wrap(
          CurrencyAmountField(
            currencies: currencyCodes,
            selectedCurrencies: <Reference?>[currencyCodes.first],
            ignoreProvider: true,
          ),
          formDisabled: true,
        ),
      );
      await tester.pumpAndSettle();

      final TextField field = tester.widget<TextField>(find.byType(TextField));
      expect(field.readOnly, isFalse);
    });
  });
}
