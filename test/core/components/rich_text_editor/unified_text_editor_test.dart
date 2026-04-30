import "package:flutter/material.dart";
import "package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart";
import "package:flutter_test/flutter_test.dart";
import "package:html_editor_enhanced/html_editor.dart";
import "package:visibility_detector/visibility_detector.dart";
import "package:wcas_frontend/core/components/rich_text_editor/text_editor.dart";
import "package:wcas_frontend/core/components/rich_text_editor/tiny_mce.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/env_config.dart";

/// Fake platform webview widget so HtmlEditor can build in widget tests.
class FakePlatformInAppWebViewWidget extends PlatformInAppWebViewWidget {
  FakePlatformInAppWebViewWidget(
    super.params,
  ) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) {
    return controller as T;
  }

  @override
  void dispose() {}
}

/// Fake platform implementation to stop HtmlEditor from throwing
/// createPlatformInAppWebViewWidget is not implemented.
class FakeInAppWebViewPlatform extends InAppWebViewPlatform {
  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    return FakePlatformInAppWebViewWidget(params);
  }
}

Future<void> pumpEditor(
  WidgetTester tester,
  Widget child,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(() {
    InAppWebViewPlatform.instance = FakeInAppWebViewPlatform();

    // IMPORTANT: prevents pending timer failures from visibility_detector
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  tearDown(() {
    EnvConfig.setConfigForTesting(null);
  });

  group("constructor / default values", () {
    test("uses default values correctly", () {
      final HtmlEditorController controller = HtmlEditorController();

      final UnifiedTextEditor widget = UnifiedTextEditor(
        controller: controller,
      );

      expect(widget.controller, same(controller));
      expect(widget.disable, false);
      expect(widget.semanticLabel, isNull);
      expect(widget.characterLimit, isNull);
      expect(widget.initialText, isNull);
      expect(widget.showVideoUpload, true);
      expect(widget.height, 500);
      expect(widget.editorId, isNull);
      expect(widget.scrollController, isNull);
    });

    test("accepts all optional parameters", () {
      final HtmlEditorController controller = HtmlEditorController();
      final ScrollController scrollController = ScrollController();

      final UnifiedTextEditor widget = UnifiedTextEditor(
        controller: controller,
        disable: true,
        semanticLabel: "Semantic label",
        characterLimit: 250,
        initialText: "<p>Initial</p>",
        showVideoUpload: false,
        height: 420,
        editorId: "editor-1",
        scrollController: scrollController,
      );

      expect(widget.controller, same(controller));
      expect(widget.disable, true);
      expect(widget.semanticLabel, "Semantic label");
      expect(widget.characterLimit, 250);
      expect(widget.initialText, "<p>Initial</p>");
      expect(widget.showVideoUpload, false);
      expect(widget.height, 420);
      expect(widget.editorId, "editor-1");
      expect(widget.scrollController, same(scrollController));

      scrollController.dispose();
    });
  });

  group("HTML editor path", () {
    setUp(() {
      EnvConfig.setConfigForTesting(<String, dynamic>{
        "useTinyMceEditor": false,
      });
    });

    testWidgets(
      "renders CustomTextEditorWidget with direct HtmlEditorController",
      (WidgetTester tester) async {
        final HtmlEditorController controller = HtmlEditorController();

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller,
            disable: true,
            semanticLabel: "HTML editor",
            characterLimit: 100,
            initialText: "<p>HTML</p>",
            showVideoUpload: false,
          ),
        );

        expect(find.byType(CustomTextEditorWidget), findsOneWidget);

        final CustomTextEditorWidget child =
            tester.widget<CustomTextEditorWidget>(
          find.byType(CustomTextEditorWidget),
        );

        expect(child.controller, same(controller));
        expect(child.disable, true);
        expect(child.semanticLabel, "HTML editor");
        expect(child.characterLimit, 100);
        expect(child.initialText, "<p>HTML</p>");
        expect(child.showVideoUpload, false);
      },
    );

    testWidgets(
      "renders CustomTextEditorWidget with UnifiedEditorController",
      (WidgetTester tester) async {
        final UnifiedEditorController controller = UnifiedEditorController();

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller,
            initialText: "<p>Wrapped HTML</p>",
          ),
        );

        expect(find.byType(CustomTextEditorWidget), findsOneWidget);
        expect(await controller.getText(), "<p>Wrapped HTML</p>");
      },
    );

    testWidgets(
      "initState initializes internal text for"
      " UnifiedEditorController in HTML mode",
      (WidgetTester tester) async {
        final UnifiedEditorController controller = UnifiedEditorController();

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller,
            initialText: "<p>Init HTML</p>",
          ),
        );

        expect(await controller.getText(), "<p>Init HTML</p>");
      },
    );

    testWidgets(
      "didUpdateWidget "
      "updates internal text "
      "when initialText changes in HTML mode",
      (WidgetTester tester) async {
        final UnifiedEditorController controller = UnifiedEditorController();

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller,
            initialText: "<p>Old</p>",
          ),
        );

        expect(await controller.getText(), "<p>Old</p>");

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller,
            initialText: "<p>New</p>",
          ),
        );

        expect(await controller.getText(), "<p>New</p>");
      },
    );

    testWidgets(
      "didUpdateWidget updates internal text "
      "when controller changes in HTML mode",
      (WidgetTester tester) async {
        final UnifiedEditorController controller1 = UnifiedEditorController();
        final UnifiedEditorController controller2 = UnifiedEditorController();

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller1,
            initialText: "<p>First</p>",
          ),
        );

        expect(await controller1.getText(), "<p>First</p>");

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller2,
            initialText: "<p>Second</p>",
          ),
        );

        expect(await controller2.getText(), "<p>Second</p>");
      },
    );

    testWidgets(
      "onChanged updates UnifiedEditorController internal text in HTML mode",
      (WidgetTester tester) async {
        final UnifiedEditorController controller = UnifiedEditorController();

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller,
            initialText: "<p>Before</p>",
          ),
        );

        final CustomTextEditorWidget child =
            tester.widget<CustomTextEditorWidget>(
          find.byType(CustomTextEditorWidget),
        );

        child.onChanged?.call("<p>After</p>");
        await tester.pump();

        expect(await controller.getText(), "<p>After</p>");
      },
    );

    testWidgets(
      "throws ArgumentError when HTML mode receives RichTextController",
      (WidgetTester tester) async {
        final RichTextController controller = RichTextController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTextEditor(
                controller: controller,
              ),
            ),
          ),
        );

        final Object? error = tester.takeException();
        expect(error, isA<ArgumentError>());
      },
    );
  });

  group("TinyMCE editor path", () {
    setUp(() {
      EnvConfig.setConfigForTesting(<String, dynamic>{
        "useTinyMceEditor": true,
      });
    });

    testWidgets(
      "renders RichTextTinyMce with direct RichTextController",
      (WidgetTester tester) async {
        final RichTextController controller = RichTextController();
        final ScrollController scrollController = ScrollController();

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller,
            disable: true,
            initialText: "<p>Tiny</p>",
            height: 400,
            editorId: "tiny-editor",
            scrollController: scrollController,
            characterLimit: 200,
          ),
        );

        expect(find.byType(RichTextTinyMce), findsOneWidget);

        final RichTextTinyMce child = tester.widget<RichTextTinyMce>(
          find.byType(RichTextTinyMce),
        );

        expect(child.controller, same(controller));
        expect(child.initialContent, "<p>Tiny</p>");
        expect(child.enabled, false);
        expect(child.height, 400);
        expect(child.editorId, "tiny-editor");
        expect(child.scrollController, same(scrollController));
        expect(child.characterLimit, 200);

        scrollController.dispose();
      },
    );

    testWidgets(
      "renders RichTextTinyMce with UnifiedEditorController",
      (WidgetTester tester) async {
        final UnifiedEditorController controller = UnifiedEditorController();

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller,
            initialText: "<p>Wrapped Tiny</p>",
          ),
        );

        expect(find.byType(RichTextTinyMce), findsOneWidget);
        expect(await controller.getText(), "<p>Wrapped Tiny</p>");
      },
    );

    testWidgets(
      "initState initializes internal text for "
      "UnifiedEditorController in Tiny mode",
      (WidgetTester tester) async {
        final UnifiedEditorController controller = UnifiedEditorController();

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller,
            initialText: "<p>Init Tiny</p>",
          ),
        );

        expect(await controller.getText(), "<p>Init Tiny</p>");
      },
    );

    testWidgets(
      "didUpdateWidget updates internal text "
      "when initialText changes in Tiny mode",
      (WidgetTester tester) async {
        final UnifiedEditorController controller = UnifiedEditorController();

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller,
            initialText: "<p>Old Tiny</p>",
          ),
        );

        expect(await controller.getText(), "<p>Old Tiny</p>");

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller,
            initialText: "<p>New Tiny</p>",
          ),
        );

        expect(await controller.getText(), "<p>New Tiny</p>");
      },
    );

    testWidgets(
      "didUpdateWidget updates internal text "
      "when controller changes in Tiny mode",
      (WidgetTester tester) async {
        final UnifiedEditorController controller1 = UnifiedEditorController();
        final UnifiedEditorController controller2 = UnifiedEditorController();

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller1,
            initialText: "<p>First Tiny</p>",
          ),
        );

        expect(await controller1.getText(), "<p>First Tiny</p>");

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller2,
            initialText: "<p>Second Tiny</p>",
          ),
        );

        expect(await controller2.getText(), "<p>Second Tiny</p>");
      },
    );

    testWidgets(
      "onContentChanged updates UnifiedEditorController "
      "internal text in Tiny mode",
      (WidgetTester tester) async {
        final UnifiedEditorController controller = UnifiedEditorController();

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller,
            initialText: "<p>Before Tiny</p>",
          ),
        );

        final RichTextTinyMce child = tester.widget<RichTextTinyMce>(
          find.byType(RichTextTinyMce),
        );

        child.onContentChanged?.call("<p>After Tiny</p>");
        await tester.pump();

        expect(await controller.getText(), "<p>After Tiny</p>");
      },
    );

    testWidgets(
      "passes enabled=true when disable is false",
      (WidgetTester tester) async {
        final RichTextController controller = RichTextController();

        await pumpEditor(
          tester,
          UnifiedTextEditor(
            controller: controller,
            disable: false,
          ),
        );

        final RichTextTinyMce child = tester.widget<RichTextTinyMce>(
          find.byType(RichTextTinyMce),
        );

        expect(child.enabled, true);
      },
    );

    testWidgets(
      "throws ArgumentError when TinyMCE mode receives HtmlEditorController",
      (WidgetTester tester) async {
        final HtmlEditorController controller = HtmlEditorController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedTextEditor(
                controller: controller,
              ),
            ),
          ),
        );

        final Object? error = tester.takeException();
        expect(error, isA<ArgumentError>());
      },
    );
  });
}
