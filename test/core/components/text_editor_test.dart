import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:html_editor_enhanced/html_editor.dart";
import "package:wcas_frontend/core/components/text_editor.dart";
import "package:wcas_frontend/core/constants/constants.dart";

class _BuiltEditorConfig {
  _BuiltEditorConfig({
    required this.container,
    required this.editor,
  });

  final Container container;
  final HtmlEditor editor;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HtmlEditorController controller;

  setUp(() {
    controller = HtmlEditorController();
  });

  /// Recursively unwraps common wrappers until HtmlEditor is found.
  HtmlEditor extractHtmlEditor(Widget widget) {
    if (widget is HtmlEditor) {
      return widget;
    }

    if (widget is Semantics && widget.child != null) {
      return extractHtmlEditor(widget.child!);
    }

    if (widget is Container && widget.child != null) {
      return extractHtmlEditor(widget.child!);
    }

    if (widget is Padding) {
      return extractHtmlEditor(widget.child!);
    }

    if (widget is DecoratedBox) {
      return extractHtmlEditor(widget.child!);
    }

    if (widget is ColoredBox) {
      return extractHtmlEditor(widget.child!);
    }

    throw StateError(
      "HtmlEditor not found. Current runtimeType: ${widget.runtimeType}",
    );
  }

  Future<_BuiltEditorConfig> buildAndExtract(
    WidgetTester tester,
    CustomTextEditorWidget widget,
  ) async {
    late Widget builtWidget;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            builtWidget = widget.build(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final Container container = builtWidget as Container;

    if (container.child == null) {
      throw StateError("Container child is null");
    }

    final HtmlEditor editor = extractHtmlEditor(container.child!);

    return _BuiltEditorConfig(
      container: container,
      editor: editor,
    );
  }

  group("Constructor defaults", () {
    test("default values are assigned correctly", () {
      final widget = CustomTextEditorWidget(controller: controller);

      expect(widget.controller, controller);
      expect(widget.disable, isFalse);
      expect(widget.textStyle, isNull);
      expect(widget.allowImagePicking, isTrue);
      expect(widget.showRedo, isFalse);
      expect(widget.showUndo, isFalse);
      expect(widget.showFontSize, isTrue);
      expect(widget.showFontSizeUnit, isTrue);
      expect(widget.showListStyles, isTrue);
      expect(widget.showNumberedList, isTrue);
      expect(widget.showBulletList, isTrue);
      expect(widget.showAlignCenter, isTrue);
      expect(widget.showAlignJustify, isTrue);
      expect(widget.showAlignLeft, isTrue);
      expect(widget.showAlignRight, isTrue);
      expect(widget.showLineHeight, isTrue);
      expect(widget.showTextDirection, isTrue);
      expect(widget.showCaseConverter, isFalse);
      expect(widget.showDecreaseIndent, isFalse);
      expect(widget.showIncreaseIndent, isFalse);
      expect(widget.showForegroundColorButton, isTrue);
      expect(widget.showHighlightColorButton, isTrue);
      expect(widget.showBold, isTrue);
      expect(widget.showItalic, isTrue);
      expect(widget.showStrikethrough, isTrue);
      expect(widget.showUnderline, isTrue);
      expect(widget.showSubscript, isTrue);
      expect(widget.showSuperscript, isTrue);
      expect(widget.showHorizontalRuler, isTrue);
      expect(widget.showLink, isTrue);
      expect(widget.showImageUpload, isTrue);
      expect(widget.showAudioUpload, isFalse);
      expect(widget.otherFile, isFalse);
      expect(widget.showTable, isTrue);
      expect(widget.showVideoUpload, isTrue);
      expect(widget.hintText, "Your text here...");
      expect(widget.shouldEnsureVisible, isTrue);
      expect(widget.customToolbarButtons, isNull);
      expect(widget.toolbarType, isNull);
      expect(widget.characterLimit, isNull);
      expect(widget.initialText, isNull);
      expect(widget.semanticLabel, isNull);
      expect(widget.imageExtensions, isNull);
      expect(widget.videoExtensions, isNull);
      expect(widget.onChangeContent, isNull);
    });
  });

  group("Build - default configuration", () {
    testWidgets("build returns Container with expected margin and decoration",
        (tester) async {
      final widget = CustomTextEditorWidget(controller: controller);
      final result = await buildAndExtract(tester, widget);

      expect(result.container.margin, const EdgeInsets.all(5));

      final decoration = result.container.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.white);
      expect(decoration.border, isNotNull);
    });

    testWidgets("build returns HtmlEditor with default controller",
        (tester) async {
      final widget = CustomTextEditorWidget(controller: controller);
      final result = await buildAndExtract(tester, widget);

      expect(result.editor.controller, controller);
    });

    testWidgets("default HtmlToolbarOptions are mapped correctly",
        (tester) async {
      final widget = CustomTextEditorWidget(controller: controller);
      final result = await buildAndExtract(tester, widget);

      final toolbar = result.editor.htmlToolbarOptions;
      expect(toolbar.allowImagePicking, isTrue);
      expect(toolbar.textStyle, isNull);
      expect(toolbar.customToolbarButtons, isEmpty);
      expect(toolbar.toolbarPosition, ToolbarPosition.aboveEditor);
      expect(toolbar.toolbarType, ToolbarType.nativeExpandable);
      expect(toolbar.buttonSelectedColor, AppColors.black);
      expect(toolbar.imageExtensions, isNull);
      expect(toolbar.videoExtensions, isNull);

      final buttons = toolbar.defaultToolbarButtons;
      expect(buttons.length, 7);

      final other = buttons[0] as OtherButtons;
      expect(other.fullscreen, isFalse);
      expect(other.copy, isFalse);
      expect(other.help, isFalse);
      expect(other.paste, isFalse);
      expect(other.redo, isFalse);
      expect(other.undo, isFalse);
      expect(other.codeview, isFalse);

      final font = buttons[1] as FontButtons;
      expect(font.bold, isTrue);
      expect(font.clearAll, isFalse);
      expect(font.italic, isTrue);
      expect(font.strikethrough, isTrue);
      expect(font.underline, isTrue);
      expect(font.subscript, isTrue);
      expect(font.superscript, isTrue);

      final fontSettings = buttons[2] as FontSettingButtons;
      expect(fontSettings.fontSize, isTrue);
      expect(fontSettings.fontSizeUnit, isTrue);

      final colors = buttons[3] as ColorButtons;
      expect(colors.foregroundColor, isTrue);
      expect(colors.highlightColor, isTrue);

      final paragraph = buttons[4] as ParagraphButtons;
      expect(paragraph.alignCenter, isTrue);
      expect(paragraph.alignJustify, isTrue);
      expect(paragraph.alignLeft, isTrue);
      expect(paragraph.alignRight, isTrue);
      expect(paragraph.lineHeight, isTrue);
      expect(paragraph.textDirection, isTrue);
      expect(paragraph.caseConverter, isFalse);
      expect(paragraph.decreaseIndent, isFalse);
      expect(paragraph.increaseIndent, isFalse);

      final lists = buttons[5] as ListButtons;
      expect(lists.listStyles, isTrue);
      expect(lists.ol, isTrue);
      expect(lists.ul, isTrue);

      final insert = buttons[6] as InsertButtons;
      expect(insert.hr, isTrue);
      expect(insert.link, isTrue);
      expect(insert.picture, isTrue);
      expect(insert.audio, isFalse);
      expect(insert.otherFile, isFalse);
      expect(insert.table, isTrue);
      expect(insert.video, isTrue);
    });

    testWidgets("default HtmlEditorOptions are mapped correctly",
        (tester) async {
      final widget = CustomTextEditorWidget(controller: controller);
      final result = await buildAndExtract(tester, widget);

      final editorOptions = result.editor.htmlEditorOptions;
      expect(editorOptions.initialText, isNull);
      expect(editorOptions.adjustHeightForKeyboard, isFalse);
      expect(editorOptions.characterLimit, isNull);
      expect(editorOptions.autoAdjustHeight, isTrue);
      expect(editorOptions.hint, "Your text here...");
      expect(editorOptions.shouldEnsureVisible, isTrue);
      expect(editorOptions.disabled, isFalse);
    });
  });

  group("Build - custom configuration", () {
    testWidgets(
        "all custom values are passed into"
        " HtmlToolbarOptions and HtmlEditorOptions", (tester) async {
      final customButtons = [
        const Icon(Icons.add),
        const Icon(Icons.remove),
      ];

      const textStyle = TextStyle(
        fontSize: 20,
        color: Colors.red,
        fontWeight: FontWeight.bold,
      );

      final widget = CustomTextEditorWidget(
        controller: controller,
        disable: true,
        textStyle: textStyle,
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
        customToolbarButtons: customButtons,
        toolbarType: ToolbarType.nativeGrid,
        characterLimit: 250,
        initialText: "<p>Initial</p>",
        semanticLabel: "semantic-editor",
        imageExtensions: const ["jpg", "png"],
        videoExtensions: const ["mp4"],
        onChangeContent: (_) {},
      );

      final result = await buildAndExtract(tester, widget);

      final toolbar = result.editor.htmlToolbarOptions;
      expect(toolbar.allowImagePicking, isFalse);
      expect(toolbar.textStyle, textStyle);
      expect(toolbar.customToolbarButtons, customButtons);
      expect(toolbar.toolbarPosition, ToolbarPosition.aboveEditor);
      expect(toolbar.toolbarType, ToolbarType.nativeGrid);
      expect(toolbar.buttonSelectedColor, AppColors.black);
      expect(toolbar.imageExtensions, const ["jpg", "png"]);
      expect(toolbar.videoExtensions, const ["mp4"]);

      final buttons = toolbar.defaultToolbarButtons;
      expect(buttons.length, 7);

      final other = buttons[0] as OtherButtons;
      expect(other.redo, isTrue);
      expect(other.undo, isTrue);

      final font = buttons[1] as FontButtons;
      expect(font.bold, isFalse);
      expect(font.italic, isFalse);
      expect(font.strikethrough, isFalse);
      expect(font.underline, isFalse);
      expect(font.subscript, isFalse);
      expect(font.superscript, isFalse);

      final fontSettings = buttons[2] as FontSettingButtons;
      expect(fontSettings.fontSize, isFalse);
      expect(fontSettings.fontSizeUnit, isFalse);

      final colors = buttons[3] as ColorButtons;
      expect(colors.foregroundColor, isFalse);
      expect(colors.highlightColor, isFalse);

      final paragraph = buttons[4] as ParagraphButtons;
      expect(paragraph.alignCenter, isFalse);
      expect(paragraph.alignJustify, isFalse);
      expect(paragraph.alignLeft, isFalse);
      expect(paragraph.alignRight, isFalse);
      expect(paragraph.lineHeight, isFalse);
      expect(paragraph.textDirection, isFalse);
      expect(paragraph.caseConverter, isTrue);
      expect(paragraph.decreaseIndent, isTrue);
      expect(paragraph.increaseIndent, isTrue);

      final lists = buttons[5] as ListButtons;
      expect(lists.listStyles, isFalse);
      expect(lists.ol, isFalse);
      expect(lists.ul, isFalse);

      final insert = buttons[6] as InsertButtons;
      expect(insert.hr, isFalse);
      expect(insert.link, isFalse);
      expect(insert.picture, isFalse);
      expect(insert.audio, isTrue);
      expect(insert.otherFile, isTrue);
      expect(insert.table, isFalse);
      expect(insert.video, isFalse);

      final editorOptions = result.editor.htmlEditorOptions;
      expect(editorOptions.initialText, "<p>Initial</p>");
      expect(editorOptions.adjustHeightForKeyboard, isFalse);
      expect(editorOptions.characterLimit, 250);
      expect(editorOptions.autoAdjustHeight, isTrue);
      expect(editorOptions.hint, "Custom hint");
      expect(editorOptions.shouldEnsureVisible, isFalse);
      expect(editorOptions.disabled, isTrue);
    });
  });

  group("Callback coverage", () {
    testWidgets("onChangeContent forwards normal content", (tester) async {
      String? latestValue;

      final widget = CustomTextEditorWidget(
        controller: controller,
        onChangeContent: (value) {
          latestValue = value;
        },
      );

      final result = await buildAndExtract(tester, widget);

      final callbacks = result.editor.callbacks!;
      callbacks.onChangeContent?.call("<p>Hello</p>");

      expect(latestValue, "<p>Hello</p>");
    });

    testWidgets("onChangeContent converts null into empty string",
        (tester) async {
      String? latestValue;

      final widget = CustomTextEditorWidget(
        controller: controller,
        onChangeContent: (value) {
          latestValue = value;
        },
      );

      final result = await buildAndExtract(tester, widget);

      final callbacks = result.editor.callbacks!;
      callbacks.onChangeContent?.call(null);

      expect(latestValue, "");
    });

    testWidgets("onChangeContent throws when callback is not provided",
        (tester) async {
      final widget = CustomTextEditorWidget(
        controller: controller,
      );

      final result = await buildAndExtract(tester, widget);

      final callbacks = result.editor.callbacks!;
      expect(
        () => callbacks.onChangeContent?.call("<p>boom</p>"),
        throwsA(anything),
      );
    });
  });

  group("Extra property coverage", () {
    test("semanticLabel is stored", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        semanticLabel: "editor-semantic-label",
      );

      expect(widget.semanticLabel, "editor-semantic-label");
    });

    test("initialText is stored", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        initialText: "<p>Seed</p>",
      );

      expect(widget.initialText, "<p>Seed</p>");
    });

    test("characterLimit is stored", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        characterLimit: 999,
      );

      expect(widget.characterLimit, 999);
    });

    test("imageExtensions and videoExtensions are stored", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        imageExtensions: const ["png", "jpg"],
        videoExtensions: const ["mp4", "mov"],
      );

      expect(widget.imageExtensions, const ["png", "jpg"]);
      expect(widget.videoExtensions, const ["mp4", "mov"]);
    });

    test("customToolbarButtons are stored", () {
      final buttons = [const Icon(Icons.abc)];

      final widget = CustomTextEditorWidget(
        controller: controller,
        customToolbarButtons: buttons,
      );

      expect(widget.customToolbarButtons, buttons);
    });

    test("toolbarType is stored", () {
      final widget = CustomTextEditorWidget(
        controller: controller,
        toolbarType: ToolbarType.nativeScrollable,
      );

      expect(widget.toolbarType, ToolbarType.nativeScrollable);
    });

    test("textStyle is stored", () {
      const style = TextStyle(fontSize: 18, color: Colors.blue);

      final widget = CustomTextEditorWidget(
        controller: controller,
        textStyle: style,
      );

      expect(widget.textStyle, style);
    });
  });
}
