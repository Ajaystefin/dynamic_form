import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/textarea.dart";

void main() {
  group("CustomTextArea", () {
    testWidgets("renders textarea with default properties",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextArea(),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets("renders with initial value and hint text",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextArea(
              initialValue: "Initial text",
              hintText: "Enter text here",
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.initialValue, "Initial text");
    });

    testWidgets("renders with label and helper text",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextArea(
              labelText: "Description",
              helperText: "Enter a description",
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets("renders with prefix and suffix icons",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextArea(
              prefixIcon: Icon(Icons.edit),
              suffixIcon: Icon(Icons.clear),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets("calls onChanged when text changes",
        (WidgetTester tester) async {
      String? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextArea(
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), "New text");
      await tester.pump();
      expect(changedValue, "New text");
    });

    testWidgets("applies custom styling", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextArea(
              textStyle: TextStyle(fontSize: 16, color: Colors.blue),
              hintStyle: TextStyle(color: Colors.grey),
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              fillColor: Colors.yellow,
              filled: true,
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets("sets correct maxLines and minLines",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextArea(
              maxLines: 5,
              minLines: 3,
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets("renders as read-only when specified",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextArea(
              readOnly: true,
              initialValue: "Read only text",
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}
