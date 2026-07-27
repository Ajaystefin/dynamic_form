import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";

void main() {
  group("CustomSelectableText", () {
    testWidgets("renders with plain text", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomSelectableText(text: "Hello"),
          ),
        ),
      );

      // SelectableText uses RichText internally
      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text("Hello"), findsOneWidget);
    });

    testWidgets("renders with textSpan", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomSelectableText(
              textSpan: TextSpan(
                children: [
                  TextSpan(text: "A", style: TextStyle(color: Colors.red)),
                  TextSpan(text: "B", style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SelectableText), findsOneWidget);
      final selectable =
          tester.widget<SelectableText>(find.byType(SelectableText));
      expect(selectable.textSpan, isNotNull);
      expect(selectable.textSpan!.children?.length, 2);
    });

    testWidgets("applies cursor and selection configuration",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomSelectableText(
              text: "Cursor",
              showCursor: true,
              cursorWidth: 3,
              cursorColor: Colors.green,
              autofocus: true,
              maxLines: 2,
            ),
          ),
        ),
      );

      final widget = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(widget.showCursor, isTrue);
      expect(widget.cursorWidth, 3.0);
      expect(widget.cursorColor, Colors.green);
      expect(widget.autofocus, isTrue);
      expect(widget.maxLines, 2);
    });
  });
}
