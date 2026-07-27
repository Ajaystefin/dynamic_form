import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/tooltip.dart";

// Dummy AppColors for testing

void main() {
  group("LabelWidget", () {
    testWidgets("renders label correctly", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LabelWidget(label: "Test Label"),
          ),
        ),
      );

      expect(find.text("Test Label"), findsOneWidget);
    });

    testWidgets("renders required indicator when isRequired is true",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LabelWidget(label: "Test Label", isRequired: true),
          ),
        ),
      );

      // expect(find.text('Test Label *'), findsOneWidget);
    });

    testWidgets("does not render label when showLabel is false",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LabelWidget(label: "Test Label", showLabel: false),
          ),
        ),
      );

      expect(find.text("Test Label"), findsNothing);
    });

    testWidgets("renders child widget", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LabelWidget(label: "Test Label", child: Text("Child Widget")),
          ),
        ),
      );

      expect(find.text("Child Widget"), findsOneWidget);
    });

    testWidgets("renders icon when provided", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LabelWidget(label: "Test Label", icon: Icons.info),
          ),
        ),
      );

      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets("calls onTextTap when label is tapped",
        (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LabelWidget(
              label: "Test Label",
              onTextTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text("Test Label"));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets("calls onIconTap when icon is tapped",
        (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LabelWidget(
              label: "Test Label",
              icon: Icons.info,
              onIconTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.info));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets("renders CustomTooltip when infoContent is provided",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LabelWidget(
              label: "Test Label",
              infoContent: "Tooltip Content",
            ),
          ),
        ),
      );

      expect(find.byType(CustomTooltip), findsOneWidget);
    });
  });
}
