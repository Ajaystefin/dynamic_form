import "package:flutter_test/flutter_test.dart";
import "package:html_editor_enhanced/html_editor.dart";
import "package:wcas_frontend/core/components/rich_text_editor/tiny_mce.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/env_config.dart";

void main() {
  group("UnifiedEditorController factory", () {
    tearDown(() {
      EnvConfig.configForTesting = null;
    });

    test("creates HtmlEditorWrapper when useTinyMceEditor is false", () {
      EnvConfig.configForTesting = {"useTinyMceEditor": false};

      final controller = UnifiedEditorController();

      expect(controller, isA<HtmlEditorWrapper>());
      expect(controller.controller, isA<HtmlEditorController>());
    });

    test("creates TinyMceEditorWrapper when useTinyMceEditor is true", () {
      EnvConfig.configForTesting = {"useTinyMceEditor": true};

      final controller = UnifiedEditorController();

      expect(controller, isA<TinyMceEditorWrapper>());
      expect(controller.controller, isA<RichTextController>());
    });

    test("creates HtmlEditorWrapper when config is null", () {
      EnvConfig.configForTesting = null;

      final controller = UnifiedEditorController();

      expect(controller, isA<HtmlEditorWrapper>());
    });
  });

  group("UnifiedEditorController.fromController factory", () {
    test("creates HtmlEditorWrapper from HtmlEditorController", () {
      final htmlController = HtmlEditorController();

      final wrapper = UnifiedEditorController.fromController(htmlController);

      expect(wrapper, isA<HtmlEditorWrapper>());
      expect(wrapper.controller, same(htmlController));
    });

    test("creates TinyMceEditorWrapper from RichTextController", () {
      final richTextController = RichTextController();

      final wrapper =
          UnifiedEditorController.fromController(richTextController);

      expect(wrapper, isA<TinyMceEditorWrapper>());
      expect(wrapper.controller, same(richTextController));
    });

    test("throws ArgumentError for unsupported controller type", () {
      final unsupportedController = Object();

      expect(
        () => UnifiedEditorController.fromController(unsupportedController),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            "message",
            contains("Unsupported controller type"),
          ),
        ),
      );
    });
  });

  group("HtmlEditorWrapper", () {
    test("initializes with new controller", () {
      final wrapper = HtmlEditorWrapper();

      expect(wrapper.controller, isA<HtmlEditorController>());
    });

    test("initializes with existing controller", () {
      final htmlController = HtmlEditorController();

      final wrapper = HtmlEditorWrapper.fromController(htmlController);

      expect(wrapper.controller, same(htmlController));
    });

    test("controller getter returns HtmlEditorController", () {
      final htmlController = HtmlEditorController();
      final wrapper = HtmlEditorWrapper.fromController(htmlController);

      expect(wrapper.controller, isA<HtmlEditorController>());
      expect(wrapper.controller, same(htmlController));
    });

    test("implements UnifiedEditorController interface", () {
      final wrapper = HtmlEditorWrapper();

      expect(wrapper, isA<UnifiedEditorController>());
    });
  });

  group("TinyMceEditorWrapper", () {
    test("initializes with new controller", () {
      final wrapper = TinyMceEditorWrapper();

      expect(wrapper.controller, isA<RichTextController>());
    });

    test("initializes with existing controller", () {
      final richTextController = RichTextController();

      final wrapper = TinyMceEditorWrapper.fromController(richTextController);

      expect(wrapper.controller, same(richTextController));
    });

    test("setText calls controller setText", () {
      final wrapper = TinyMceEditorWrapper();

      expect(() => wrapper.setText("Test content"), returnsNormally);
    });

    test("controller getter returns RichTextController", () {
      final richTextController = RichTextController();
      final wrapper = TinyMceEditorWrapper.fromController(richTextController);

      expect(wrapper.controller, isA<RichTextController>());
      expect(wrapper.controller, same(richTextController));
    });

    test("implements UnifiedEditorController interface", () {
      final wrapper = TinyMceEditorWrapper();

      expect(wrapper, isA<UnifiedEditorController>());
    });
  });

  group("Interface compliance", () {
    test("HtmlEditorWrapper exposes getText method", () {
      final wrapper = HtmlEditorWrapper();

      expect(wrapper.getText, isA<Function>());
    });

    test("HtmlEditorWrapper exposes setText method", () {
      final wrapper = HtmlEditorWrapper();

      expect(wrapper.setText, isA<Function>());
    });

    test("HtmlEditorWrapper exposes controller getter", () {
      final wrapper = HtmlEditorWrapper();

      expect(wrapper.controller, isNotNull);
    });

    test("TinyMceEditorWrapper exposes getText method", () {
      final wrapper = TinyMceEditorWrapper();

      expect(wrapper.getText, isA<Function>());
    });

    test("TinyMceEditorWrapper exposes setText method", () {
      final wrapper = TinyMceEditorWrapper();

      expect(wrapper.setText, isA<Function>());
    });

    test("TinyMceEditorWrapper exposes controller getter", () {
      final wrapper = TinyMceEditorWrapper();

      expect(wrapper.controller, isNotNull);
    });
  });

  group("Integration tests", () {
    tearDown(() {
      EnvConfig.configForTesting = null;
    });

    test("factory creates correct wrapper based on env config", () {
      EnvConfig.configForTesting = {"useTinyMceEditor": false};
      final controller1 = UnifiedEditorController();
      expect(controller1, isA<HtmlEditorWrapper>());

      EnvConfig.configForTesting = {"useTinyMceEditor": true};
      final controller2 = UnifiedEditorController();
      expect(controller2, isA<TinyMceEditorWrapper>());
    });

    test(
        "fromController factory creates correct"
        " wrapper for each controller type", () {
      final htmlController = HtmlEditorController();
      final richTextController = RichTextController();

      final wrapper1 = UnifiedEditorController.fromController(htmlController);
      final wrapper2 =
          UnifiedEditorController.fromController(richTextController);

      expect(wrapper1, isA<HtmlEditorWrapper>());
      expect(wrapper2, isA<TinyMceEditorWrapper>());
    });

    test("both wrappers implement same interface", () {
      final wrapper1 = HtmlEditorWrapper();
      final wrapper2 = TinyMceEditorWrapper();

      // Both should expose the same interface
      expect(wrapper1, isA<UnifiedEditorController>());
      expect(wrapper2, isA<UnifiedEditorController>());
      expect(wrapper1.controller, isNotNull);
      expect(wrapper2.controller, isNotNull);
    });
  });
}
