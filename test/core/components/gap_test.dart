import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  group("Gap", () {
    testWidgets("renders vertical gap with default medium size",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Gap(),
          ),
        ),
      );

      final sized = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sized.height, AppStyle.spacing);
      expect(sized.width, isNull);
    });

    testWidgets("renders horizontal gap with large size",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Gap(size: GapSize.large, direction: Axis.horizontal),
          ),
        ),
      );

      final sized = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sized.width, AppStyle.spacingLarge);
      expect(sized.height, isNull);
    });

    testWidgets("uses customValue when provided", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Gap(customValue: 42),
          ),
        ),
      );

      final sized = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sized.height, 42);
    });
  });
}
