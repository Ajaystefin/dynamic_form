import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/flexbox.dart";

void main() {
  group("FlexBox", () {
    testWidgets("renders Wrap with default parameters",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlexBox(children: [Text("a"), Text("b")]),
          ),
        ),
      );

      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.direction, Axis.horizontal);
      expect(wrap.alignment, WrapAlignment.start);
      expect(wrap.crossAxisAlignment, WrapCrossAlignment.start);
      expect(wrap.spacing, 8.0);
      expect(wrap.runSpacing, 8.0);
      expect(find.text("a"), findsOneWidget);
      expect(find.text("b"), findsOneWidget);
    });

    testWidgets("applies provided parameters", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlexBox(
              direction: Axis.vertical,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 6,
              children: [Icon(Icons.add), Icon(Icons.remove)],
            ),
          ),
        ),
      );

      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.direction, Axis.vertical);
      expect(wrap.alignment, WrapAlignment.center);
      expect(wrap.crossAxisAlignment, WrapCrossAlignment.center);
      expect(wrap.spacing, 12.0);
      expect(wrap.runSpacing, 6.0);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });
  });
}
