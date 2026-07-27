import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/accordion_file_tree.dart";

void main() {
  group("CustomFileAccordion", () {
    testWidgets("renders title and shows children when expanded",
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomFileAccordion(
              title: "Files",
              initiallyExpanded: true,
              children: [Text("File A"), Text("File B")],
            ),
          ),
        ),
      );

      expect(find.text("Files"), findsOneWidget);
      expect(find.text("File A"), findsOneWidget);
      expect(find.text("File B"), findsOneWidget);
      expect(find.byType(ExpansionTile), findsOneWidget);
    });

    testWidgets("toggles expansion by tapping title", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomFileAccordion(
              title: "Tap Files",
              children: [Text("Hidden File")],
            ),
          ),
        ),
      );

      expect(find.text("Hidden File"), findsNothing);
      await tester.tap(find.text("Tap Files"));
      await tester.pumpAndSettle();
    });

    testWidgets("shows primary and trailing icons when provided",
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomFileAccordion(
              title: "Icons",
              initiallyExpanded: true,
              primaryIcon: Icon(Icons.insert_drive_file),
              trailing: Icon(Icons.chevron_right),
              children: [SizedBox.shrink()],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.insert_drive_file), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}
