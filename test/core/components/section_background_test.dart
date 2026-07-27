import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/section_background.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  group("SectionBackground", () {
    testWidgets("wraps child with padding and white background",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionBackground(child: Text("content")),
          ),
        ),
      );

      expect(find.text("content"), findsOneWidget);
      final container =
          tester.widget<DecoratedBox>(find.byType(DecoratedBox).first);
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, AppColors.white);

      // Find the specific Padding with 8.0 all sides
      final paddingFinder = find.byWidgetPredicate(
        (w) => w is Padding && w.padding == const EdgeInsets.all(8),
      );
      expect(paddingFinder, findsOneWidget);
    });
  });
}
