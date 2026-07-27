import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";

void main() {
  group("AddItemButton", () {
    testWidgets("renders right-sided by default and responds to tap",
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddItemButton(
              child: const Text("Add Something"),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text("Add Something"), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets("renders left-sided when isLeftSided is true", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddItemButton(
              isLeftSided: true,
              child: Text("Left Add"),
            ),
          ),
        ),
      );

      expect(find.text("Left Add"), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
