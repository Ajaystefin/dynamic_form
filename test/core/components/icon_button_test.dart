import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/icon_button.dart";

void main() {
  group("dynamicIcon", () {
    testWidgets("renders with default values", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dynamicIcon(),
          ),
        ),
      );

      expect(find.byType(Icon), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets("renders with custom icon and size",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dynamicIcon(icon: Icons.add, iconSize: 24),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.add));
      expect(icon.size, 24);
    });

    testWidgets("calls onTap callback when tapped",
        (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dynamicIcon(
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets("renders with custom colors and border radius",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dynamicIcon(
              iconColor: Colors.red,
              borderColor: Colors.green,
              borderRadius: 8,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.border?.top.color, Colors.green);
      expect(decoration.borderRadius, BorderRadius.circular(8));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, Colors.red);
    });
  });
}
