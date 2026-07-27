import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";

void main() {
  group("FormRow", () {
    testWidgets("renders with 2 children", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormRow(
              children: const [
                Text("Child 1"),
                Text("Child 2"),
              ],
            ),
          ),
        ),
      );

      expect(find.text("Child 1"), findsOneWidget);
      expect(find.text("Child 2"), findsOneWidget);
      expect(
        find.byType(Gap),
        findsNWidgets(1),
      ); // One Gap widget for 2 children
    });

    testWidgets("renders with 3 children", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormRow(
              children: const [
                Text("Child 1"),
                Text("Child 2"),
                Text("Child 3"),
              ],
            ),
          ),
        ),
      );

      expect(find.text("Child 1"), findsOneWidget);
      expect(find.text("Child 2"), findsOneWidget);
      expect(find.text("Child 3"), findsOneWidget);
      expect(
        find.byType(Gap),
        findsNWidgets(2),
      ); // Two Gap widgets for 3 children
    });

    testWidgets("asserts when more than 3 children are provided",
        (WidgetTester tester) async {
      expect(
        () => FormRow(
          children: const [
            Text("Child 1"),
            Text("Child 2"),
            Text("Child 3"),
            Text("Child 4"),
          ],
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
