import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/rich_text_editor/tiny_mce_stub.dart";

void main() {
  group("TinyMceBuilder", () {
    testWidgets("buildEditor returns TinyMceWebWidget",
        (WidgetTester tester) async {
      final widget = TinyMceBuilder.buildEditor(
        editorId: "test-editor",
        height: 500,
        enabled: true,
        onContentUpdate: (content) {},
      );

      expect(widget, isA<TinyMceWebWidget>());
    });

    testWidgets("buildEditor passes all parameters correctly",
        (WidgetTester tester) async {
      void onContentUpdate(String content) {}

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceBuilder.buildEditor(
              editorId: "custom-editor",
              height: 300,
              enabled: false,
              initialContent: "<p>Test</p>",
              onContentUpdate: onContentUpdate,
              scrollController: ScrollController(),
            ),
          ),
        ),
      );

      expect(find.byType(TinyMceWebWidget), findsOneWidget);

      final widget =
          tester.widget<TinyMceWebWidget>(find.byType(TinyMceWebWidget));
      expect(widget.editorId, "custom-editor");
      expect(widget.height, 300);
      expect(widget.enabled, false);
      expect(widget.initialContent, "<p>Test</p>");
    });

    testWidgets("buildEditor with key", (WidgetTester tester) async {
      final key = GlobalKey<TinyMceWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceBuilder.buildEditor(
              key: key,
              editorId: "test",
              height: 500,
              enabled: true,
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
    });
  });

  group("TinyMceWebWidget", () {
    testWidgets("renders placeholder message", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceWebWidget(
              editorId: "test",
              height: 500,
              enabled: true,
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      expect(find.text("TinyMCE Rich Text Editor"), findsOneWidget);
      expect(
        find.text("This editor is only available on web platform"),
        findsOneWidget,
      );
    });

    testWidgets("displays warning icon", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceWebWidget(
              editorId: "test",
              height: 500,
              enabled: true,
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets("uses correct height", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceWebWidget(
              editorId: "test",
              height: 350,
              enabled: true,
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxHeight, 350);
    });

    testWidgets("renders with initial content", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceWebWidget(
              editorId: "test",
              height: 500,
              enabled: true,
              initialContent: "<p>Initial content</p>",
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      expect(find.byType(TinyMceWebWidget), findsOneWidget);
    });

    testWidgets("renders in disabled state", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceWebWidget(
              editorId: "test",
              height: 500,
              enabled: false,
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      expect(find.byType(TinyMceWebWidget), findsOneWidget);
    });

    testWidgets("renders with scroll controller", (WidgetTester tester) async {
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceWebWidget(
              editorId: "test",
              height: 500,
              enabled: true,
              scrollController: scrollController,
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      expect(find.byType(TinyMceWebWidget), findsOneWidget);

      scrollController.dispose();
    });

    testWidgets("has correct container styling", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceWebWidget(
              editorId: "test",
              height: 500,
              enabled: true,
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;

      expect(decoration.color, Colors.grey[200]);
      expect(decoration.border, isA<Border>());
      expect(decoration.borderRadius, BorderRadius.circular(8));
    });

    testWidgets("has correct padding", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceWebWidget(
              editorId: "test",
              height: 500,
              enabled: true,
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, const EdgeInsets.all(16));
    });

    testWidgets("column is centered", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceWebWidget(
              editorId: "test",
              height: 500,
              enabled: true,
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets("has correct spacing between elements",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceWebWidget(
              editorId: "test",
              height: 500,
              enabled: true,
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final spacerBoxes =
          sizedBoxes.where((box) => box.height != null).toList();

      expect(spacerBoxes.length, greaterThanOrEqualTo(2));
    });
  });

  group("TinyMceWidgetState", () {
    testWidgets("requestContent is a no-op", (WidgetTester tester) async {
      final key = GlobalKey<TinyMceWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceWebWidget(
              key: key,
              editorId: "test",
              height: 500,
              enabled: true,
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      // Should not throw
      expect(() => key.currentState?.requestContent(), returnsNormally);
    });

    testWidgets("setContent is a no-op", (WidgetTester tester) async {
      final key = GlobalKey<TinyMceWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceWebWidget(
              key: key,
              editorId: "test",
              height: 500,
              enabled: true,
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      // Should not throw
      expect(
        () => key.currentState?.setContent("New content"),
        returnsNormally,
      );
    });

    testWidgets("can access state through key", (WidgetTester tester) async {
      final key = GlobalKey<TinyMceWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceWebWidget(
              key: key,
              editorId: "test",
              height: 500,
              enabled: true,
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      expect(key.currentState, isNotNull);
      expect(key.currentState, isA<TinyMceWidgetState>());
    });

    testWidgets("multiple calls to requestContent do not throw",
        (WidgetTester tester) async {
      final key = GlobalKey<TinyMceWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceWebWidget(
              key: key,
              editorId: "test",
              height: 500,
              enabled: true,
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      // Multiple calls should all be no-ops
      expect(
        () {
          key.currentState?.requestContent();
          key.currentState?.requestContent();
          key.currentState?.requestContent();
        },
        returnsNormally,
      );
    });

    testWidgets("multiple calls to setContent do not throw",
        (WidgetTester tester) async {
      final key = GlobalKey<TinyMceWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TinyMceWebWidget(
              key: key,
              editorId: "test",
              height: 500,
              enabled: true,
              onContentUpdate: (content) {},
            ),
          ),
        ),
      );

      // Multiple calls should all be no-ops
      expect(
        () {
          key.currentState?.setContent("Content 1");
          key.currentState?.setContent("Content 2");
          key.currentState?.setContent("Content 3");
        },
        returnsNormally,
      );
    });
  });
}
