import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  group("BoxLayout", () {
    testWidgets("renders with default border and padding",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoxLayout(child: Text("content")),
          ),
        ),
      );

      expect(find.text("content"), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.white);
      expect(decoration.border?.top.width, 6);
      expect(decoration.border?.top.color, AppColors.scaffoldBorder);

      // default padding is AppStyle.spacing
      expect(container.padding, const EdgeInsets.all(AppStyle.spacing));
    });

    testWidgets("applies extra padding and custom border color and alignment",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoxLayout(
              extraPadding: true,
              borderColor: Colors.red,
              alignment: Alignment.centerRight,
              child: Text("x"),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.border?.top.color, Colors.red);
      expect(container.padding, const EdgeInsets.all(AppStyle.spacingLarge));
      expect(container.alignment, Alignment.centerRight);
    });
  });
}
