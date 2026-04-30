import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/chip.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  group("CustomChip", () {
    testWidgets("renders chip with label and calls onPressed when tapped",
        (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomChip(
              label: "Test Chip",
              isActive: false,
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text("Test Chip"), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();
      expect(pressed, isTrue);
    });

    testWidgets("applies active styling when isActive is true",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomChip(
              label: "Active Chip",
              isActive: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final style = button.style;
      expect(
        style?.backgroundColor?.resolve({WidgetState.pressed}),
        AppColors.primary,
      );
      expect(
        style?.side?.resolve({WidgetState.pressed})?.color,
        AppColors.white,
      );

      final text = tester.widget<Text>(find.text("Active Chip"));
      expect(text.style?.color, AppColors.white);
      expect(text.style?.fontWeight, FontWeight.bold);
    });

    testWidgets("applies inactive styling when isActive is false",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomChip(
              label: "Inactive Chip",
              isActive: false,
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final style = button.style;
      expect(style?.backgroundColor?.resolve({WidgetState.pressed}), isNull);
      expect(
        style?.side?.resolve({WidgetState.pressed})?.color,
        AppColors.primary,
      );

      final text = tester.widget<Text>(find.text("Inactive Chip"));
      expect(text.style?.color, AppColors.primary);
      expect(text.style?.fontWeight, FontWeight.bold);
    });
  });
}
