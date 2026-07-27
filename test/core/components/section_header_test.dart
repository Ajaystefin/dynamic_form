import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  group("CustomSectionHeader", () {
    testWidgets("renders title with default styles and divider",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomSectionHeader(title: "Header"),
          ),
        ),
      );

      expect(find.text("Header"), findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);

      final text = tester.widget<Text>(find.text("Header"));
      expect(text.style?.color, AppColors.primary);
    });

    testWidgets("applies custom styles and colors",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomSectionHeader(
              title: "Custom",
              textStyle: TextStyle(fontSize: 20, color: Colors.red),
              leadingColor: Colors.green,
              leadingWidth: 4,
              color: Colors.yellow,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text("Custom"));
      expect(text.style?.fontSize, 20);
      expect(text.style?.color, Colors.red);

      final divider =
          tester.widget<VerticalDivider>(find.byType(VerticalDivider));
      expect(divider.color, Colors.green);
      expect(divider.width, 4);
      expect(divider.thickness, 4);

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, Colors.yellow);
    });
  });
}
