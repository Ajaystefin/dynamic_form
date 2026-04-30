import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/tooltip.dart";

void main() {
  group("CustomTooltip", () {
    testWidgets("renders with plain message and child",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTooltip(
              message: "Hello tooltip",
              child: Text("Child"),
            ),
          ),
        ),
      );

      expect(find.text("Child"), findsOneWidget);
      // Tooltip is a widget in the tree
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets("renders richMessage when isRichMessage is true",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTooltip(
              message: "Rich tooltip",
              isRichMessage: true,
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
            body: CustomTooltip(
              message: "Config tooltip",
              textStyle: TextStyle(color: Colors.yellow),
              height: 40,
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.all(4),
              preferBelow: true,
              waitDuration: Duration(milliseconds: 10),
              showDuration: Duration(milliseconds: 50),
              verticalOffset: 12,
              textAlign: TextAlign.left,
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
