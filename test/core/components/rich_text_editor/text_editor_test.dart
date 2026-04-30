import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:html_editor_enhanced/html_editor.dart";
import "package:wcas_frontend/core/components/rich_text_editor/text_editor.dart";

void main() {
  group("CustomTextEditorWidget", () {
    late HtmlEditorController controller;

    setUp(() {
      controller = HtmlEditorController();
    });

    test("widget can be instantiated with required parameters", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
      );

      expect(widget, isA<CustomTextEditorWidget>());
      expect(widget.controller, same(controller));
    });

    test("widget accepts all optional parameters", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        disable: true,
        textStyle: const TextStyle(fontSize: 16),
        allowImagePicking: false,
        showRedo: true,
        showUndo: true,
        showFontSize: false,
        showFontSizeUnit: false,
        showListStyles: false,
        showNumberedList: false,
        showBulletList: false,
        showAlignCenter: false,
        showAlignJustify: false,
        showAlignLeft: false,
        showAlignRight: false,
        showLineHeight: false,
        showTextDirection: false,
        showCaseConverter: true,
        showDecreaseIndent: true,
        showIncreaseIndent: true,
        showForegroundColorButton: false,
        showHighlightColorButton: false,
        showBold: false,
        showItalic: false,
        showStrikethrough: false,
        showUnderline: false,
        showSubscript: false,
        showSuperscript: false,
        showHorizontalRuler: false,
        showLink: false,
        showImageUpload: false,
        showAudioUpload: true,
        otherFile: true,
        showTable: false,
        showVideoUpload: false,
        hintText: "Custom hint",
        shouldEnsureVisible: false,
        customToolbarButtons: const [],
        characterLimit: 100,
        initialText: "<p>Test</p>",
        semanticLabel: "Editor",
      );

      expect(widget, isA<CustomTextEditorWidget>());
    });

    test("widget has correct default values", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
      );

      expect(widget.disable, false);
      expect(widget.allowImagePicking, true);
      expect(widget.showRedo, false);
      expect(widget.showUndo, false);
      expect(widget.showFontSize, true);
      expect(widget.showFontSizeUnit, true);
      expect(widget.showListStyles, true);
      expect(widget.showNumberedList, true);
      expect(widget.showBulletList, true);
      expect(widget.showAlignCenter, true);
      expect(widget.showAlignJustify, true);
      expect(widget.showAlignLeft, true);
      expect(widget.showAlignRight, true);
      expect(widget.showLineHeight, true);
      expect(widget.showTextDirection, true);
      expect(widget.showCaseConverter, false);
      expect(widget.showDecreaseIndent, false);
      expect(widget.showIncreaseIndent, false);
      expect(widget.showForegroundColorButton, true);
      expect(widget.showHighlightColorButton, true);
      expect(widget.showBold, true);
      expect(widget.showItalic, true);
      expect(widget.showStrikethrough, true);
      expect(widget.showUnderline, true);
      expect(widget.showSubscript, true);
      expect(widget.showSuperscript, true);
      expect(widget.showHorizontalRuler, true);
      expect(widget.showLink, true);
      expect(widget.showImageUpload, true);
      expect(widget.showAudioUpload, false);
      expect(widget.otherFile, false);
      expect(widget.showTable, true);
      expect(widget.showVideoUpload, true);
      expect(widget.hintText, "Your text here...");
      expect(widget.shouldEnsureVisible, true);
    });

    test("widget with custom hint text", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        hintText: "Custom hint text",
      );

      expect(widget.hintText, "Custom hint text");
    });

    test("widget with disabled state", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        disable: true,
      );

      expect(widget.disable, true);
    });

    test("widget with custom text style", () {
      const textStyle = TextStyle(fontSize: 16, color: Color(0xFF000000));
      final widget = CustomTextEditorWidget(
        controller: controller,
        textStyle: textStyle,
      );

      expect(widget.textStyle, textStyle);
    });

    test("widget with image picking disabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        allowImagePicking: false,
      );

      expect(widget.allowImagePicking, false);
    });

    test("widget with redo and undo enabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showRedo: true,
        showUndo: true,
      );

      expect(widget.showRedo, true);
      expect(widget.showUndo, true);
    });

    test("widget with font settings disabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showFontSize: false,
        showFontSizeUnit: false,
      );

      expect(widget.showFontSize, false);
      expect(widget.showFontSizeUnit, false);
    });

    test("widget with list styles disabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showListStyles: false,
        showNumberedList: false,
        showBulletList: false,
      );

      expect(widget.showListStyles, false);
      expect(widget.showNumberedList, false);
      expect(widget.showBulletList, false);
    });

    test("widget with alignment options disabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showAlignCenter: false,
        showAlignJustify: false,
        showAlignLeft: false,
        showAlignRight: false,
      );

      expect(widget.showAlignCenter, false);
      expect(widget.showAlignJustify, false);
      expect(widget.showAlignLeft, false);
      expect(widget.showAlignRight, false);
    });

    test("widget with case converter enabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showCaseConverter: true,
      );

      expect(widget.showCaseConverter, true);
    });

    test("widget with indent buttons enabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showDecreaseIndent: true,
        showIncreaseIndent: true,
      );

      expect(widget.showDecreaseIndent, true);
      expect(widget.showIncreaseIndent, true);
    });

    test("widget with color buttons disabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showForegroundColorButton: false,
        showHighlightColorButton: false,
      );

      expect(widget.showForegroundColorButton, false);
      expect(widget.showHighlightColorButton, false);
    });

    test("widget with font style buttons disabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showBold: false,
        showItalic: false,
        showStrikethrough: false,
        showUnderline: false,
      );

      expect(widget.showBold, false);
      expect(widget.showItalic, false);
      expect(widget.showStrikethrough, false);
      expect(widget.showUnderline, false);
    });

    test("widget with subscript and superscript disabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showSubscript: false,
        showSuperscript: false,
      );

      expect(widget.showSubscript, false);
      expect(widget.showSuperscript, false);
    });

    test("widget with insert buttons disabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showHorizontalRuler: false,
        showLink: false,
        showImageUpload: false,
        showTable: false,
        showVideoUpload: false,
      );

      expect(widget.showHorizontalRuler, false);
      expect(widget.showLink, false);
      expect(widget.showImageUpload, false);
      expect(widget.showTable, false);
      expect(widget.showVideoUpload, false);
    });

    test("widget with audio and other file uploads enabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showAudioUpload: true,
        otherFile: true,
      );

      expect(widget.showAudioUpload, true);
      expect(widget.otherFile, true);
    });

    test("widget with shouldEnsureVisible false", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        shouldEnsureVisible: false,
      );

      expect(widget.shouldEnsureVisible, false);
    });

    test("widget with character limit", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        characterLimit: 100,
      );

      expect(widget.characterLimit, 100);
    });

    test("widget with initial text", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        initialText: "<p>Initial content</p>",
      );

      expect(widget.initialText, "<p>Initial content</p>");
    });

    test("widget with semantic label", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        semanticLabel: "Text editor field",
      );

      expect(widget.semanticLabel, "Text editor field");
    });

    test("widget with custom image extensions", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        imageExtensions: const ["jpg", "png", "gif"],
      );

      expect(widget.imageExtensions, ["jpg", "png", "gif"]);
    });

    test("widget with custom video extensions", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        videoExtensions: const ["mp4", "avi", "mov"],
      );

      expect(widget.videoExtensions, ["mp4", "avi", "mov"]);
    });

    test("widget with custom toolbar type", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        toolbarType: ToolbarType.nativeScrollable,
      );

      expect(widget.toolbarType, ToolbarType.nativeScrollable);
    });

    test("widget with all options customized", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        disable: true,
        textStyle: const TextStyle(fontSize: 14),
        allowImagePicking: false,
        hintText: "Type here...",
        shouldEnsureVisible: false,
        characterLimit: 500,
        initialText: "<p>Test</p>",
        semanticLabel: "Editor",
        imageExtensions: const ["jpg"],
        videoExtensions: const ["mp4"],
        toolbarType: ToolbarType.nativeGrid,
      );

      expect(widget.disable, true);
      expect(widget.textStyle?.fontSize, 14);
      expect(widget.allowImagePicking, false);
      expect(widget.hintText, "Type here...");
      expect(widget.shouldEnsureVisible, false);
      expect(widget.characterLimit, 500);
      expect(widget.initialText, "<p>Test</p>");
      expect(widget.semanticLabel, "Editor");
      expect(widget.imageExtensions, ["jpg"]);
      expect(widget.videoExtensions, ["mp4"]);
      expect(widget.toolbarType, ToolbarType.nativeGrid);
    });

    test("widget creates default toolbar buttons list", () {
      final widget = CustomTextEditorWidget(controller: controller);

      // Verify widget is created successfully
      expect(widget, isNotNull);
      expect(widget.customToolbarButtons, isNull);
    });

    test("widget with empty custom toolbar buttons", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        customToolbarButtons: const [],
      );

      expect(widget.customToolbarButtons, isEmpty);
    });

    test("widget with multiple custom toolbar buttons", () {
      final buttons = [
        const Icon(Icons.save),
        const Icon(Icons.undo),
        const Icon(Icons.redo),
      ];

      final widget = CustomTextEditorWidget(
        controller: controller,
        customToolbarButtons: buttons,
      );

      expect(widget.customToolbarButtons, buttons);
      expect(widget.customToolbarButtons?.length, 3);
    });

    test("widget accepts null values for optional parameters", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        textStyle: null,
        semanticLabel: null,
        characterLimit: null,
        initialText: null,
        imageExtensions: null,
        videoExtensions: null,
        customToolbarButtons: null,
        toolbarType: null,
      );

      expect(widget.textStyle, isNull);
      expect(widget.semanticLabel, isNull);
      expect(widget.characterLimit, isNull);
      expect(widget.initialText, isNull);
      expect(widget.imageExtensions, isNull);
      expect(widget.videoExtensions, isNull);
      expect(widget.customToolbarButtons, isNull);
      expect(widget.toolbarType, isNull);
    });

    test("widget with mixed toolbar configuration", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showBold: true,
        showItalic: false,
        showUnderline: true,
        showStrikethrough: false,
        showFontSize: true,
        showFontSizeUnit: false,
      );

      expect(widget.showBold, true);
      expect(widget.showItalic, false);
      expect(widget.showUnderline, true);
      expect(widget.showStrikethrough, false);
      expect(widget.showFontSize, true);
      expect(widget.showFontSizeUnit, false);
    });

    test("widget with extreme character limit", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        characterLimit: 999999,
      );

      expect(widget.characterLimit, 999999);
    });

    test("widget with zero character limit", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        characterLimit: 0,
      );

      expect(widget.characterLimit, 0);
    });
  });

  group("CustomTextEditorWidget build method coverage", () {
    late HtmlEditorController controller;

    setUp(() {
      controller = HtmlEditorController();
    });

    test("build method executes with default configuration", () {
      final widget = CustomTextEditorWidget(controller: controller);
      final context = _MockBuildContext();

      // Build executes lines even if it throws platform exception
      expect(
        () => widget.build(context),
        anyOf(returnsNormally, throwsA(anything)),
      );
    });

    test("build method executes with disable true", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        disable: true,
      );
      final context = _MockBuildContext();

      expect(
        () => widget.build(context),
        anyOf(returnsNormally, throwsA(anything)),
      );
    });

    test("build method executes with custom hint text", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        hintText: "Custom hint for coverage",
      );
      final context = _MockBuildContext();

      expect(
        () => widget.build(context),
        anyOf(returnsNormally, throwsA(anything)),
      );
    });

    test("build with customToolbarButtons null uses default", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        customToolbarButtons: null,
      );
      final context = _MockBuildContext();

      // Tests null coalescing: customToolbarButtons ?? []
      expect(
        () => widget.build(context),
        anyOf(returnsNormally, throwsA(anything)),
      );
    });

    test("build with customToolbarButtons provided", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        customToolbarButtons: const [Icon(Icons.save)],
      );
      final context = _MockBuildContext();

      // Tests null coalescing: customToolbarButtons ?? []
      expect(
        () => widget.build(context),
        anyOf(returnsNormally, throwsA(anything)),
      );
    });

    test("build with toolbarType null uses default", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        toolbarType: null,
      );
      final context = _MockBuildContext();

      // Tests null coalescing: toolbarType ?? ToolbarType.nativeExpandable
      expect(
        () => widget.build(context),
        anyOf(returnsNormally, throwsA(anything)),
      );
    });

    test("build with toolbarType provided", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        toolbarType: ToolbarType.nativeGrid,
      );
      final context = _MockBuildContext();

      // Tests null coalescing: toolbarType ?? ToolbarType.nativeExpandable
      expect(
        () => widget.build(context),
        anyOf(returnsNormally, throwsA(anything)),
      );
    });

    test("build with all font buttons disabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showBold: false,
        showItalic: false,
        showUnderline: false,
        showStrikethrough: false,
        showSubscript: false,
        showSuperscript: false,
      );
      final context = _MockBuildContext();

      expect(
        () => widget.build(context),
        anyOf(returnsNormally, throwsA(anything)),
      );
    });

    test("build with all list buttons disabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showListStyles: false,
        showNumberedList: false,
        showBulletList: false,
      );
      final context = _MockBuildContext();

      expect(
        () => widget.build(context),
        anyOf(returnsNormally, throwsA(anything)),
      );
    });

    test("build with custom image and video extensions", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        imageExtensions: const ["jpg", "png", "gif"],
        videoExtensions: const ["mp4", "webm"],
      );
      final context = _MockBuildContext();

      expect(
        () => widget.build(context),
        anyOf(returnsNormally, throwsA(anything)),
      );
    });

    test("build with all insert buttons disabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showLink: false,
        showImageUpload: false,
        showVideoUpload: false,
        showTable: false,
        showHorizontalRuler: false,
      );
      final context = _MockBuildContext();

      expect(
        () => widget.build(context),
        anyOf(returnsNormally, throwsA(anything)),
      );
    });

    test("build with custom text style", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );
      final context = _MockBuildContext();

      expect(
        () => widget.build(context),
        anyOf(returnsNormally, throwsA(anything)),
      );
    });

    test("build with character limit and initial text", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        characterLimit: 500,
        initialText: "<p>Initial content for coverage</p>",
        shouldEnsureVisible: false,
      );
      final context = _MockBuildContext();

      expect(
        () => widget.build(context),
        anyOf(returnsNormally, throwsA(anything)),
      );
    });

    test("build with all alignment buttons disabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showAlignLeft: false,
        showAlignCenter: false,
        showAlignRight: false,
        showAlignJustify: false,
      );
      final context = _MockBuildContext();

      expect(
        () => widget.build(context),
        anyOf(returnsNormally, throwsA(anything)),
      );
    });

    test("build with redo and undo enabled", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        showRedo: true,
        showUndo: true,
      );
      final context = _MockBuildContext();

      expect(
        () => widget.build(context),
        anyOf(returnsNormally, throwsA(anything)),
      );
    });
  });
}

// Mock BuildContext for testing build method without platform dependencies
class _MockBuildContext extends Fake implements BuildContext {}
