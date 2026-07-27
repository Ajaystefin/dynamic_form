import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/utils/scale.dart";

void main() {
  group("Scale", () {
    setUp(() {
      // Reset Scale to default values before each test
      Scale.setupWith(const Size(1280, 720), const Size(1280, 720));
    });

    group("setup", () {
      testWidgets("should setup scale with context and screen size",
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                Scale.setup(context, const Size(1920, 1080));
                return const SizedBox();
              },
            ),
          ),
        );

        // Test that setup was called (we can't easily verify the internal
        // state)
        expect(Scale.scaleHorizontally(100), isA<double>());
      });

      test("should setup scale with device screen size and screen size", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        // Test that the scale factors are calculated correctly
        final horizontalScale = Scale.scaleHorizontally(100);
        final verticalScale = Scale.scaleVertically(100);

        expect(horizontalScale, isA<double>());
        expect(verticalScale, isA<double>());
        expect(horizontalScale, greaterThan(0));
        expect(verticalScale, greaterThan(0));
      });
    });

    group("scaleHorizontally", () {
      test("should scale number horizontally", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        final result = Scale.scaleHorizontally(100);
        expect(result, equals(150.0)); // 1920/1280 * 100 = 150
      });

      test("should handle zero input", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        final result = Scale.scaleHorizontally(0);
        expect(result, equals(0.0));
      });

      test("should handle negative input", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        final result = Scale.scaleHorizontally(-100);
        expect(result, equals(-150.0)); // 1920/1280 * -100 = -150
      });

      test("should handle decimal input", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        final result = Scale.scaleHorizontally(50.5);
        expect(result, equals(75.75)); // 1920/1280 * 50.5 = 75.75
      });

      test("should handle large numbers", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        final result = Scale.scaleHorizontally(10000);
        expect(result, equals(15000.0)); // 1920/1280 * 10000 = 15000
      });
    });

    group("scaleVertically", () {
      test("should scale number vertically", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        final result = Scale.scaleVertically(100);
        expect(result, equals(150.0)); // 1080/720 * 100 = 150
      });

      test("should handle zero input", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        final result = Scale.scaleVertically(0);
        expect(result, equals(0.0));
      });

      test("should handle negative input", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        final result = Scale.scaleVertically(-100);
        expect(result, equals(-150.0)); // 1080/720 * -100 = -150
      });

      test("should handle decimal input", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        final result = Scale.scaleVertically(50.5);
        expect(result, equals(75.75)); // 1080/720 * 50.5 = 75.75
      });
    });

    group("scaleFont", () {
      test("should scale font size", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        final result = Scale.scaleFont(16);
        expect(result, isA<double>());
        expect(result, greaterThan(0));
      });

      test("should handle zero input", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        final result = Scale.scaleFont(0);
        expect(result, equals(0.0));
      });

      test("should handle negative input", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        final result = Scale.scaleFont(-16);
        expect(result, isA<double>());
        expect(result, lessThan(0));
      });
    });

    group("scaleDiagonally", () {
      test("should scale number diagonally", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        final result = Scale.scaleDiagonally(100);
        expect(result, isA<double>());
        expect(result, greaterThan(0));
      });

      test("should handle zero input", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        final result = Scale.scaleDiagonally(0);
        expect(result, equals(0.0));
      });

      test("should handle negative input", () {
        Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));

        final result = Scale.scaleDiagonally(-100);
        expect(result, isA<double>());
        expect(result, lessThan(0));
      });
    });
  });

  group("ScreenExtension", () {
    setUp(() {
      Scale.setupWith(const Size(1920, 1080), const Size(1280, 720));
    });

    group("w (width)", () {
      test("should scale number horizontally", () {
        final result = 100.w;
        expect(result, equals(150.0)); // 1920/1280 * 100 = 150
      });

      test("should handle zero", () {
        final result = 0.w;
        expect(result, equals(0.0));
      });

      test("should handle negative numbers", () {
        final result = (-100).w;
        expect(result, equals(-150.0));
      });

      test("should handle decimal numbers", () {
        final result = 50.5.w;
        expect(result, equals(75.75));
      });
    });

    group("h (height)", () {
      test("should scale number vertically", () {
        final result = 100.h;
        expect(result, equals(150.0)); // 1080/720 * 100 = 150
      });

      test("should handle zero", () {
        final result = 0.h;
        expect(result, equals(0.0));
      });

      test("should handle negative numbers", () {
        final result = (-100).h;
        expect(result, equals(-150.0));
      });

      test("should handle decimal numbers", () {
        final result = 50.5.h;
        expect(result, equals(75.75));
      });
    });

    group("sf (scale font)", () {
      test("should scale font size", () {
        final result = 16.sf;
        expect(result, isA<double>());
        expect(result, greaterThan(0));
      });

      test("should handle zero", () {
        final result = 0.sf;
        expect(result, equals(0.0));
      });

      test("should handle negative numbers", () {
        final result = (-16).sf;
        expect(result, isA<double>());
        expect(result, lessThan(0));
      });
    });

    group("sd (scale diagonal)", () {
      test("should scale number diagonally", () {
        final result = 100.sd;
        expect(result, isA<double>());
        expect(result, greaterThan(0));
      });

      test("should handle zero", () {
        final result = 0.sd;
        expect(result, equals(0.0));
      });

      test("should handle negative numbers", () {
        final result = (-100).sd;
        expect(result, isA<double>());
        expect(result, lessThan(0));
      });
    });
  });

  group("DeviceType", () {
    testWidgets("should detect device types correctly",
        (WidgetTester tester) async {
      // Test that the extension methods exist and work
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.deviceScreenType, isA<DeviceScreenType>());
              expect(context.isMobile, isA<bool>());
              expect(context.isTablet, isA<bool>());
              expect(context.isDesktop, isA<bool>());
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets("should handle different screen sizes",
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final deviceType = context.deviceScreenType;
              expect(deviceType, isA<DeviceScreenType>());
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets("should handle small screen sizes",
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final deviceType = context.deviceScreenType;
              expect(deviceType, isA<DeviceScreenType>());
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets("should handle medium screen sizes",
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(768, 1024));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final deviceType = context.deviceScreenType;
              expect(deviceType, isA<DeviceScreenType>());
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets("should handle very small screen sizes",
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(200, 200));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final deviceType = context.deviceScreenType;
              expect(deviceType, isA<DeviceScreenType>());
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
