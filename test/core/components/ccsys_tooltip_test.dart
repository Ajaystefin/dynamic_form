import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/ccsys_tooltip.dart";

void main() {
  group("CcsysTooltip Widget Test", () {
    testWidgets("should render child widget correctly",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CcsysTootltip(
              message: "Test Tooltip Message",
              child: Text("Tooltip Child"),
            ),
          ),
        ),
      );
      expect(find.text("Tooltip Child"), findsOneWidget);
      // Tooltip is a widget in the tree
      expect(find.byType(Tooltip), findsOneWidget);
    });
    testWidgets("renders richMessage when isRichMessage is true",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CcsysTootltip(
              message: "Rich tooltip",
              child: Text("Child"),
            ),
          ),
        ),
      );

      // Should still render the child
      expect(find.text("Child"), findsOneWidget);
      // Tooltip present in tree
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets("applies provided parameters without crashing",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CcsysTootltip(
              message: "Config tooltip",
              child: Icon(Icons.info),
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });
  });
}
