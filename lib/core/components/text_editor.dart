import "package:flutter/material.dart";
import "package:html_editor_enhanced/html_editor.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// Rich text HTML editor widget with configurable toolbar options.
class CustomTextEditorWidget extends StatelessWidget {
  /// Creates a [CustomTextEditorWidget].
  const CustomTextEditorWidget({
    required this.controller,
    super.key,
    this.disable = false,
    this.textStyle,
    this.allowImagePicking = true,
    this.showRedo = false,
    this.showUndo = false,
    this.showFontSize = true,
    this.showFontSizeUnit = true,
    this.showListStyles = true,
    this.showNumberedList = true,
    this.showBulletList = true,
    this.showAlignCenter = true,
    this.showAlignJustify = true,
    this.showAlignLeft = true,
    this.showAlignRight = true,
    this.showLineHeight = true,
    this.showTextDirection = true,
    this.showCaseConverter = false,
    this.showDecreaseIndent = false,
    this.showIncreaseIndent = false,
    this.showForegroundColorButton = true,
    this.showHighlightColorButton = true,
    this.showBold = true,
    this.showItalic = true,
    this.showStrikethrough = true,
    this.showUnderline = true,
    this.showSubscript = true,
    this.showSuperscript = true,
    this.showHorizontalRuler = true,
    this.showLink = true,
    this.showImageUpload = true,
    this.showAudioUpload = false,
    this.otherFile = false,
    this.showTable = true,
    this.showVideoUpload = true,
    this.hintText = "Your text here...",
    this.shouldEnsureVisible = true,
    this.customToolbarButtons,
    this.toolbarType,
    this.characterLimit,
    this.initialText,
    this.semanticLabel,
    this.imageExtensions,
    this.videoExtensions,
    this.onChangeContent,
  });

  /// Controller used to manage the editor content.
  final HtmlEditorController controller;

  /// Disables editing when `true`.
  final bool disable;

  /// Optional text style for editor content.
  final TextStyle? textStyle;

  /// Whether image picking is allowed in the toolbar.
  final bool allowImagePicking;

  /// Whether the redo button is enabled.
  final bool showRedo;

  /// Whether the undo button is enabled.
  final bool showUndo;

  /// Whether the font size button is enabled.
  final bool showFontSize;

  /// Whether the font size unit button is enabled.
  final bool showFontSizeUnit;

  /// Whether list style controls are enabled.
  final bool showListStyles;

  /// Whether numbered list support is enabled.
  final bool showNumberedList;

  /// Whether bullet list support is enabled.
  final bool showBulletList;

  /// Whether center alignment is enabled.
  final bool showAlignCenter;

  /// Whether justify alignment is enabled.
  final bool showAlignJustify;

  /// Whether left alignment is enabled.
  final bool showAlignLeft;

  /// Whether right alignment is enabled.
  final bool showAlignRight;

  /// Whether line height controls are enabled.
  final bool showLineHeight;

  /// Whether text direction controls are enabled.
  final bool showTextDirection;

  /// Whether case conversion controls are enabled.
  final bool showCaseConverter;

  /// Whether decrease-indent control is enabled.
  final bool showDecreaseIndent;

  /// Whether increase-indent control is enabled.
  final bool showIncreaseIndent;

  /// Whether foreground color controls are enabled.
  final bool showForegroundColorButton;

  /// Whether highlight color controls are enabled.
  final bool showHighlightColorButton;

  /// Whether bold formatting is enabled.
  final bool showBold;

  /// Whether italic formatting is enabled.
  final bool showItalic;

  /// Whether strikethrough formatting is enabled.
  final bool showStrikethrough;

  /// Whether underline formatting is enabled.
  final bool showUnderline;

  /// Semantic label used for accessibility.
  final String? semanticLabel;

  /// Whether subscript formatting is enabled.
  final bool showSubscript;

  /// Whether superscript formatting is enabled.
  final bool showSuperscript;

  /// Whether horizontal ruler insertion is enabled.
  final bool showHorizontalRuler;

  /// Whether link insertion is enabled.
  final bool showLink;

  /// Whether image upload is enabled.
  final bool showImageUpload;

  /// Whether audio upload is enabled.
  final bool showAudioUpload;

  /// Whether generic file upload is enabled.
  final bool otherFile;

  /// Whether table insertion is enabled.
  final bool showTable;

  /// Whether video upload is enabled.
  final bool showVideoUpload;

  /// Hint text displayed when the editor is empty.
  final String hintText;

  /// Whether the editor should remain visible while typing.
  final bool shouldEnsureVisible;

  /// Additional custom toolbar widgets.
  final List<Widget>? customToolbarButtons;

  /// Toolbar display type.
  final ToolbarType? toolbarType;

  /// Maximum number of allowed characters.
  final int? characterLimit;

  /// Initial HTML content displayed in the editor.
  final String? initialText;

  /// Allowed image file extensions.
  final List<String>? imageExtensions;

  /// Allowed video file extensions.
  final List<String>? videoExtensions;

  /// Callback invoked when the editor content changes.
  final ValueChanged<String>? onChangeContent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(),
      ),
      child: HtmlEditor(
        controller: controller,
        htmlToolbarOptions: HtmlToolbarOptions(
          imageExtensions: imageExtensions,
          videoExtensions: videoExtensions,
          allowImagePicking: allowImagePicking,
          textStyle: textStyle,
          customToolbarButtons: customToolbarButtons ?? [],
          toolbarType: toolbarType ?? ToolbarType.nativeExpandable,
          buttonSelectedColor: AppColors.black,
          defaultToolbarButtons: [
            OtherButtons(
              fullscreen: false,
              copy: false,
              help: false,
              paste: false,
              redo: showRedo,
              undo: showUndo,
              codeview: false,
            ),
            FontButtons(
              bold: showBold,
              clearAll: false,
              italic: showItalic,
              strikethrough: showStrikethrough,
              underline: showUnderline,
              subscript: showSubscript,
              superscript: showSuperscript,
            ),
            FontSettingButtons(
              fontSize: showFontSize,
              fontSizeUnit: showFontSizeUnit,
            ),
            ColorButtons(
              foregroundColor: showForegroundColorButton,
              highlightColor: showHighlightColorButton,
            ),
            ParagraphButtons(
              alignCenter: showAlignCenter,
              alignJustify: showAlignJustify,
              alignLeft: showAlignLeft,
              alignRight: showAlignRight,
              lineHeight: showLineHeight,
              textDirection: showTextDirection,
              caseConverter: showCaseConverter,
              decreaseIndent: showDecreaseIndent,
              increaseIndent: showIncreaseIndent,
            ),
            ListButtons(
              listStyles: showListStyles,
              ol: showNumberedList,
              ul: showBulletList,
            ),
            InsertButtons(
              hr: showHorizontalRuler,
              link: showLink,
              picture: showImageUpload,
              audio: showAudioUpload,
              otherFile: otherFile,
              table: showTable,
              video: showVideoUpload,
            ),
          ],
        ),
        htmlEditorOptions: HtmlEditorOptions(
          initialText: initialText,
          adjustHeightForKeyboard: false,
          characterLimit: characterLimit,
          hint: hintText,
          shouldEnsureVisible: shouldEnsureVisible,
          disabled: disable,
        ),
        callbacks: Callbacks(
          onChangeContent: (content) {
            onChangeContent!(content ?? "");
          },
        ),
      ),
    );
  }
}
