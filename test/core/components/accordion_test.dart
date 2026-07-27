import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/accordion.dart";

void main() {
  group("CustomAccordion", () {
    testWidgets("renders title and children when expanded", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomAccordion(
              title: "Section",
              initiallyExpanded: true,
              children: [Text("Child 1"), Text("Child 2")],
            ),
          ),
        ),
      );

      expect(find.text("Section"), findsOneWidget);
      expect(find.text("Child 1"), findsOneWidget);
      expect(find.text("Child 2"), findsOneWidget);
      expect(find.byType(ExpansionTile), findsOneWidget);
    });

    testWidgets("toggles expansion state on tap", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomAccordion(
              title: "Tap Me",
              children: [Text("Hidden Child")],
            ),
          ),
        ),
      );

      expect(find.text("Hidden Child"), findsNothing);
    });

    testWidgets("applies leading and trailing widgets", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomAccordion(
              title: "With Icons",
              initiallyExpanded: true,
              primaryIcon: Icon(Icons.folder),
              trailing: Icon(Icons.more_vert),
              children: [SizedBox.shrink()],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.folder), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });
}
