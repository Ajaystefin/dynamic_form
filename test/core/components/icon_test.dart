import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:wcas_frontend/core/components/icon.dart";

void main() {
  group("CustomIcon", () {
    testWidgets("renders FontAwesome icon with defaults",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomIcon(icon: FontAwesomeIcons.user),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(FaIcon), findsOneWidget);
      final faIcon = tester.widget<FaIcon>(find.byType(FaIcon));
      expect(faIcon.icon, FontAwesomeIcons.user);
      expect(faIcon.size, 24.0);
    });

    testWidgets("applies provided size and color and responds to tap",
        (WidgetTester tester) async {
      bool tapped = false;
      const color = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomIcon(
              icon: FontAwesomeIcons.plus,
              size: 32,
              iconColor: color,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      final faIcon = tester.widget<FaIcon>(find.byType(FaIcon));
      expect(faIcon.icon, FontAwesomeIcons.plus);
      expect(faIcon.size, 32.0);
      expect(faIcon.color, color);

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
