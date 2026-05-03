import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/rich_text_editor/tiny_mce.dart";

void main() {
  group("RichTextController", () {
    late RichTextController controller;

    setUp(() {
      controller = RichTextController();
    });

    test("setText updates controller", () {
      controller.setText("Hello World");
      // Controller should accept setText without errors
      expect(() => controller.setText("Test"), returnsNormally);
    });

    test("setText does not throw when setting content", () {
      expect(() => controller.setText("Content"), returnsNormally);
    });

    test("getText returns future", () async {
      final result = controller.getText();
      expect(result, isA<Future<String>>());
    });

    test("multiple setText calls work correctly", () {
      expect(
        () {
          controller
            ..setText("First")
            ..setText("Second")
            ..setText("Third");
        },
        returnsNormally,
      );
    });
  });

  group("RichTextTinyMce", () {
    testWidgets("renders with default properties", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RichTextTinyMce(),
          ),
        ),
      );

      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("renders with custom height", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RichTextTinyMce(
              height: 300,
            ),
          ),
        ),
      );

      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("renders with initial content", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RichTextTinyMce(
              initialContent: "<p>Test Content</p>",
            ),
          ),
        ),
      );

      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("renders with custom editor ID", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RichTextTinyMce(
              editorId: "custom-editor-id",
            ),
          ),
        ),
      );

      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("renders with disabled state", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RichTextTinyMce(
              enabled: false,
            ),
          ),
        ),
      );

      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("renders with controller", (WidgetTester tester) async {
      final controller = RichTextController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichTextTinyMce(
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("renders with scroll controller", (WidgetTester tester) async {
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichTextTinyMce(
              scrollController: scrollController,
            ),
          ),
        ),
      );

      expect(find.byType(RichTextTinyMce), findsOneWidget);

      scrollController.dispose();
    });

    testWidgets("uses default editor ID when not provided",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RichTextTinyMce(),
          ),
        ),
      );

      final widget =
          tester.widget<RichTextTinyMce>(find.byType(RichTextTinyMce));
      expect(widget.editorId, "rich-text-editor");
    });

    testWidgets("renders with all properties set", (WidgetTester tester) async {
      final controller = RichTextController();
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichTextTinyMce(
              controller: controller,
              initialContent: "<p>Initial</p>",
              height: 400,
              editorId: "test-editor",
              scrollController: scrollController,
              enabled: false,
            ),
          ),
        ),
      );

      expect(find.byType(RichTextTinyMce), findsOneWidget);

      scrollController.dispose();
    });

    testWidgets("works without controller", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RichTextTinyMce(
              initialContent: "<p>No Controller</p>",
            ),
          ),
        ),
      );

      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("onContentChanged callback can be provided",
        (WidgetTester tester) async {
      String? changedContent;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichTextTinyMce(
              onContentChanged: (content) {
                changedContent = content;
                changedContent = changedContent;
              },
            ),
          ),
        ),
      );

      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("can be created with all optional parameters",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RichTextTinyMce(
              initialContent: "<h1>Test</h1>",
              height: 600,
              editorId: "my-editor",
              enabled: true,
            ),
          ),
        ),
      );

      final widget =
          tester.widget<RichTextTinyMce>(find.byType(RichTextTinyMce));
      expect(widget.height, 600);
      expect(widget.initialContent, "<h1>Test</h1>");
      expect(widget.editorId, "my-editor");
      expect(widget.enabled, true);
    });
  });
}
