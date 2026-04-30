import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:wcas_frontend/core/components/common_currency_convert_field.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// ------------------------------------------------------
/// MOCKS
/// ------------------------------------------------------
class MockCreateFacilityViewModel extends Mock
    implements CreateFacilityViewModel {}

class MockReference extends Mock implements Reference {}

/// ------------------------------------------------------
/// MOCK EasyLocalization AssetLoader
/// ------------------------------------------------------
class MockAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "validation.emptyField": "Field cannot be empty",
    };
  }
}

void main() {
  late MockCreateFacilityViewModel mockViewModel;
  late TextEditingController textController;
  late List<Reference> currencyCodes;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    mockViewModel = MockCreateFacilityViewModel();
    textController = TextEditingController();

    /// ✅ Mock Reference objects
    final aedRef = MockReference();
    when(() => aedRef.name).thenReturn("AED");
    when(() => aedRef.id).thenReturn(1);

    final usdRef = MockReference();
    when(() => usdRef.name).thenReturn("USD");
    when(() => usdRef.id).thenReturn(2);

    currencyCodes = [aedRef, usdRef];

    when(() => mockViewModel.currencyCodes).thenReturn(currencyCodes);
  });

  tearDown(() {
    textController.dispose();
  });

  /// ------------------------------------------------------
  /// WIDGET BUILDER
  /// ------------------------------------------------------
  Widget createWidgetUnderTest() {
    return EasyLocalization(
      supportedLocales: const [Locale("en")],
      fallbackLocale: const Locale("en"),
      startLocale: const Locale("en"),
      path: "assets/translations",
      assetLoader: MockAssetLoader(),
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(1200, 800),
          ),
          child: Scaffold(
            body: CommonCurrencyConvertField(
              viewModel: mockViewModel,
              textController: textController,
            ),
          ),
        ),
      ),
    );
  }

  /// ======================================================
  /// TESTS
  /// ======================================================
  group("CommonCurrencyConvertField", () {
    testWidgets("renders widget correctly", (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(
        find.byType(CommonCurrencyConvertField),
        findsOneWidget,
      );
      expect(
        find.byType(TextField),
        findsOneWidget,
      );
    });

    testWidgets("initializes with default values", (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(
        find.byType(TextField),
      );

      expect(textController.text, "0");
      expect(textField.readOnly, isTrue);
      expect(textField.decoration?.filled, isTrue);
    });

    testWidgets("has correct input formatters", (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(
        find.byType(TextField),
      );

      final formatters = textField.inputFormatters;

      expect(formatters, isNotNull);
      expect(
        formatters!.any((f) => f is LengthLimitingTextInputFormatter),
        isTrue,
      );
      expect(
        formatters.any((f) => f is FilteringTextInputFormatter),
        isTrue,
      );

      /// Length + digitsOnly + ThousandsSeparatorFormatter
      expect(formatters.length, 3);
    });

    testWidgets("shows default AED currency in dropdown", (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text("AED"), findsOneWidget);
    });
  });
}
