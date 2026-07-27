import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  group("CustomCheckbox", () {
    testWidgets("renders checkbox with default values",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomCheckbox(
              onChange: ({value}) {},
            ),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
      expect(checkbox.activeColor, AppColors.primary);
      expect(checkbox.checkColor, AppColors.white);
    });

    testWidgets("calls onChange when tapped", (WidgetTester tester) async {
      bool? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomCheckbox(
              onChange: ({value}) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(changedValue, true);
    });

    testWidgets("renders with child widget", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomCheckbox(
              onChange: ({value}) {},
              child: const Text("Checkbox Label"),
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text("Checkbox Label"), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets("applies custom colors and width", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomCheckbox(
              value: true,
              onChange: ({value}) {},
              activeColor: Colors.red,
              checkColor: Colors.blue,
              fillColor: Colors.green,
              width: 200,
            ),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.activeColor, Colors.red);
      expect(checkbox.checkColor, Colors.blue);
      expect(checkbox.value, true);
    });
  });

  group("GroupCheckbox", () {
    testWidgets("renders group of checkboxes vertically",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupCheckbox(
              widgets: const [Text("Option 1"), Text("Option 2")],
              selectedCheckboxIndex: 0,
              onChange: (index, {value}) {},
            ),
          ),
        ),
      );

      expect(find.text("Option 1"), findsOneWidget);
      expect(find.text("Option 2"), findsOneWidget);
      expect(find.byType(Checkbox), findsNWidgets(2));
    });

    testWidgets("renders group of checkboxes horizontally",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupCheckbox(
              widgets: const [Text("A"), Text("B")],
              selectedCheckboxIndex: 1,
              onChange: (index, {value}) {},
              childWidth: 150,
            ),
          ),
        ),
      );

      expect(find.byType(Wrap), findsOneWidget);
      expect(find.text("A"), findsOneWidget);
      expect(find.text("B"), findsOneWidget);
    });

    testWidgets("calls onChange with correct index",
        (WidgetTester tester) async {
      bool? receivedValue;
      int? receivedIndex;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupCheckbox(
              widgets: const [Text("Option 1"), Text("Option 2")],
              selectedCheckboxIndex: -1,
              onChange: (index, {value}) {
                receivedValue = value;
                receivedIndex = index;
              },
            ),
          ),
        ),
      );

      // Tap second checkbox
      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.at(1));
      await tester.pump();
      expect(receivedValue, true);
      expect(receivedIndex, 1);
    });
  });
}
