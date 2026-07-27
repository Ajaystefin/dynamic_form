import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_icon.dart";

void main() {
  group("dynamicIcon", () {
    testWidgets("renders with default parameters", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dynamicIcon(),
          ),
        ),
      );

      expect(find.byType(Icon), findsOneWidget);
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.edit);
      expect(icon.size, 16);
      expect(icon.color, Colors.blue);
    });

    testWidgets("applies provided parameters and responds to tap",
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dynamicIcon(
              icon: Icons.add,
              iconSize: 24,
              iconColor: Colors.red,
              borderColor: Colors.green,
              padding: 8,
              borderRadius: 10,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.add);
      expect(icon.size, 24);
      expect(icon.color, Colors.red);

      // Ensure container decoration applied
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.border?.top.color, Colors.green);
      expect((decoration.borderRadius! as BorderRadius).topLeft.x, 10);

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
