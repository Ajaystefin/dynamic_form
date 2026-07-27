import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/rich_text_editor/tiny_mce.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpTinyMce(
    WidgetTester tester, {
    RichTextController? controller,
    String? initialContent,
    double height = 500,
    String? editorId,
    ScrollController? scrollController,
    bool enabled = true,
    int? characterLimit,
    Function(String)? onContentChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RichTextTinyMce(
            controller: controller,
            initialContent: initialContent,
            height: height,
            editorId: editorId,
            scrollController: scrollController,
            enabled: enabled,
            characterLimit: characterLimit,
            onContentChanged: onContentChanged,
          ),
        ),
      ),
    );

    await tester.pump();
  }

  Future<T> runWithImmediateFiveSecondTimeout<T>(
    Future<T> Function() callback,
  ) {
    return runZoned(
      callback,
      zoneSpecification: ZoneSpecification(
        createTimer: (
          Zone self,
          ZoneDelegate parent,
          Zone zone,
          Duration duration,
          void Function() timerCallback,
        ) {
          if (duration == const Duration(seconds: 5)) {
            return parent.createTimer(
              zone,
              Duration.zero,
              timerCallback,
            );
          }

          return parent.createTimer(
            zone,
            duration,
            timerCallback,
          );
        },
      ),
    );
  }

  Matcher timeoutExceptionMatcher() {
    return isA<TimeoutException>()
        .having(
          (exception) => exception.message,
          "message",
          "Failed to receive content from editor",
        )
        .having(
          (exception) => exception.duration,
          "duration",
          const Duration(seconds: 5),
        );
  }

  group("RichTextController", () {
    test("setText does not throw when no callback is attached", () {
      final controller = RichTextController();

      expect(() => controller.setText("Hello World"), returnsNormally);
      expect(() => controller.setText("Test"), returnsNormally);
      expect(() => controller.setText(""), returnsNormally);
    });

    test("multiple setText calls do not throw when no callback is attached", () {
      final controller = RichTextController();

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

    test("getText throws TimeoutException when editor never returns content",
        () async {
      final controller = RichTextController();

      await expectLater(
        runWithImmediateFiveSecondTimeout(controller.getText),
        throwsA(timeoutExceptionMatcher()),
      );
    });
  });

  group("RichTextTinyMce widget constructor and properties", () {
    testWidgets("renders with default properties", (WidgetTester tester) async {
      await pumpTinyMce(tester);

      expect(find.byType(RichTextTinyMce), findsOneWidget);

      final widget = tester.widget<RichTextTinyMce>(
        find.byType(RichTextTinyMce),
      );

      expect(widget.initialContent, isNull);
      expect(widget.height, 500);
      expect(widget.editorId, "rich-text-editor");
      expect(widget.scrollController, isNull);
      expect(widget.enabled, isTrue);
      expect(widget.controller, isNull);
      expect(widget.characterLimit, isNull);
      expect(widget.onContentChanged, isNull);
    });

    testWidgets("renders with custom height", (WidgetTester tester) async {
      await pumpTinyMce(
        tester,
        height: 300,
      );

      final widget = tester.widget<RichTextTinyMce>(
        find.byType(RichTextTinyMce),
      );

      expect(widget.height, 300);
      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("renders with initial content", (WidgetTester tester) async {
      await pumpTinyMce(
        tester,
        initialContent: "<p>Test Content</p>",
      );

      final widget = tester.widget<RichTextTinyMce>(
        find.byType(RichTextTinyMce),
      );

      expect(widget.initialContent, "<p>Test Content</p>");
      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("renders with custom editor ID", (WidgetTester tester) async {
      await pumpTinyMce(
        tester,
        editorId: "custom-editor-id",
      );

      final widget = tester.widget<RichTextTinyMce>(
        find.byType(RichTextTinyMce),
      );

      expect(widget.editorId, "custom-editor-id");
      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("uses default editor ID when editorId is not provided",
        (WidgetTester tester) async {
      await pumpTinyMce(tester);

      final widget = tester.widget<RichTextTinyMce>(
        find.byType(RichTextTinyMce),
      );

      expect(widget.editorId, "rich-text-editor");
    });

    testWidgets("renders with disabled state", (WidgetTester tester) async {
      await pumpTinyMce(
        tester,
        enabled: false,
      );

      final widget = tester.widget<RichTextTinyMce>(
        find.byType(RichTextTinyMce),
      );

      expect(widget.enabled, isFalse);
      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("renders with enabled state", (WidgetTester tester) async {
      await pumpTinyMce(
        tester,
      );

      final widget = tester.widget<RichTextTinyMce>(
        find.byType(RichTextTinyMce),
      );

      expect(widget.enabled, isTrue);
      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("renders with controller", (WidgetTester tester) async {
      final controller = RichTextController();

      await pumpTinyMce(
        tester,
        controller: controller,
      );

      final widget = tester.widget<RichTextTinyMce>(
        find.byType(RichTextTinyMce),
      );

      expect(widget.controller, same(controller));
      expect(find.byType(RichTextTinyMce), findsOneWidget);
      expect(() => controller.setText("Controller text"), returnsNormally);
    });

    testWidgets("renders without controller", (WidgetTester tester) async {
      await pumpTinyMce(
        tester,
        initialContent: "<p>No Controller</p>",
      );

      final widget = tester.widget<RichTextTinyMce>(
        find.byType(RichTextTinyMce),
      );

      expect(widget.controller, isNull);
      expect(widget.initialContent, "<p>No Controller</p>");
      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("renders with scroll controller", (WidgetTester tester) async {
      final scrollController = ScrollController();

      await pumpTinyMce(
        tester,
        scrollController: scrollController,
      );

      final widget = tester.widget<RichTextTinyMce>(
        find.byType(RichTextTinyMce),
      );

      expect(widget.scrollController, same(scrollController));
      expect(find.byType(RichTextTinyMce), findsOneWidget);

      scrollController.dispose();
    });

    testWidgets("renders with character limit", (WidgetTester tester) async {
      await pumpTinyMce(
        tester,
        characterLimit: 100,
      );

      final widget = tester.widget<RichTextTinyMce>(
        find.byType(RichTextTinyMce),
      );

      expect(widget.characterLimit, 100);
      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("renders with onContentChanged callback",
        (WidgetTester tester) async {
      String? changedContent;

      await pumpTinyMce(
        tester,
        onContentChanged: (content) {
          changedContent = content;
        },
      );

      final widget = tester.widget<RichTextTinyMce>(
        find.byType(RichTextTinyMce),
      );

      widget.onContentChanged?.call("Hello");

      expect(changedContent, "Hello");
      expect(find.byType(RichTextTinyMce), findsOneWidget);
    });

    testWidgets("renders with all optional properties set",
        (WidgetTester tester) async {
      final controller = RichTextController();
      final scrollController = ScrollController();

      await pumpTinyMce(
        tester,
        controller: controller,
        initialContent: "<p>Initial</p>",
        height: 400,
        editorId: "test-editor",
        scrollController: scrollController,
        enabled: false,
        characterLimit: 250,
        onContentChanged: (_) {},
      );

      final widget = tester.widget<RichTextTinyMce>(
        find.byType(RichTextTinyMce),
      );

      expect(widget.controller, same(controller));
      expect(widget.initialContent, "<p>Initial</p>");
      expect(widget.height, 400);
      expect(widget.editorId, "test-editor");
      expect(widget.scrollController, same(scrollController));
      expect(widget.enabled, isFalse);
      expect(widget.characterLimit, 250);
      expect(widget.onContentChanged, isNotNull);
      expect(find.byType(RichTextTinyMce), findsOneWidget);

      scrollController.dispose();
    });
  });

  group("RichTextTinyMce lifecycle", () {
    testWidgets("controller callbacks are registered and setText is safe",
        (WidgetTester tester) async {
      final controller = RichTextController();

      await pumpTinyMce(
        tester,
        controller: controller,
      );

      expect(find.byType(RichTextTinyMce), findsOneWidget);
      expect(() => controller.setText("Updated content"), returnsNormally);
    });

    testWidgets("controller callbacks are cleared on dispose",
        (WidgetTester tester) async {
      final controller = RichTextController();

      await pumpTinyMce(
        tester,
        controller: controller,
      );

      expect(find.byType(RichTextTinyMce), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox.shrink(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(RichTextTinyMce), findsNothing);
      expect(() => controller.setText("After dispose"), returnsNormally);
    });

    testWidgets("widget can be rebuilt with a different controller",
        (WidgetTester tester) async {
      final firstController = RichTextController();
      final secondController = RichTextController();

      await pumpTinyMce(
        tester,
        controller: firstController,
        editorId: "first-editor",
      );

      expect(find.byType(RichTextTinyMce), findsOneWidget);

      await pumpTinyMce(
        tester,
        controller: secondController,
        editorId: "second-editor",
      );

      final widget = tester.widget<RichTextTinyMce>(
        find.byType(RichTextTinyMce),
      );

      expect(widget.controller, same(secondController));
      expect(widget.editorId, "second-editor");
      expect(() => firstController.setText("Old controller"), returnsNormally);
      expect(() => secondController.setText("New controller"), returnsNormally);
    });

    testWidgets("widget can be disposed without controller",
        (WidgetTester tester) async {
      await pumpTinyMce(tester);

      expect(find.byType(RichTextTinyMce), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox.shrink(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(RichTextTinyMce), findsNothing);
    });

    testWidgets("widget can rebuild without controller after using controller",
        (WidgetTester tester) async {
      final controller = RichTextController();

      await pumpTinyMce(
        tester,
        controller: controller,
        editorId: "with-controller",
      );

      expect(find.byType(RichTextTinyMce), findsOneWidget);

      expect(
        tester.widget<RichTextTinyMce>(find.byType(RichTextTinyMce)).controller,
        same(controller),
      );

      await pumpTinyMce(
        tester,
        editorId: "without-controller",
      );

      final widget = tester.widget<RichTextTinyMce>(
        find.byType(RichTextTinyMce),
      );

      expect(widget.controller, isNull);
      expect(widget.editorId, "without-controller");
      expect(() => controller.setText("After rebuild"), returnsNormally);
    });
  });
}
