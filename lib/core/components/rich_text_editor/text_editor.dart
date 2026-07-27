import "package:flutter/material.dart";
import "package:html_editor_enhanced/html_editor.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// Rich text HTML editor widget with configurable formatting,
/// media upload, and toolbar options.
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
    this.onChanged,
  });

  /// Controller used to manage the HTML editor content.
  final HtmlEditorController controller;

  /// Indicates whether the editor is disabled.
  final bool disable;

  /// Optional text style for the HTML editor text.
  final TextStyle? textStyle;

  /// Whether image picking is allowed in the toolbar.
  ///
  /// Defaults to `true`.
  final bool allowImagePicking;

  /// Whether the redo button is enabled in the toolbar.
  ///
  /// Defaults to `false`.
  final bool showRedo;

  /// Whether the undo button is enabled in the toolbar.
  ///
  /// Defaults to `false`.
  final bool showUndo;

  /// Whether the font size button is enabled in the toolbar.
  ///
  /// Defaults to `true`.
  final bool showFontSize;

  /// Whether the font size unit button is enabled in the toolbar.
  ///
  /// Defaults to `true`.
  final bool showFontSizeUnit;

  /// Whether the list styles button (numbered list and bullet list)
  /// is enabled.
  ///
  /// Defaults to `true`.
  final bool showListStyles;

  /// Whether the numbered list button is enabled.
  ///
  /// Defaults to `true`.
  final bool showNumberedList;

  /// Whether the bullet list button is enabled.
  ///
  /// Defaults to `true`.
  final bool showBulletList;

  /// Whether the align center button is enabled.
  ///
  /// Defaults to `true`.
  final bool showAlignCenter;

  /// Whether the align justify button is enabled.
  ///
  /// Defaults to `true`.
  final bool showAlignJustify;

  /// Whether the align left button is enabled.
  ///
  /// Defaults to `true`.
  final bool showAlignLeft;

  /// Whether the align right button is enabled.
  ///
  /// Defaults to `true`.
  final bool showAlignRight;

  /// Whether the line height button is enabled.
  ///
  /// Defaults to `true`.
  final bool showLineHeight;

  /// Whether the text direction (LTR/RTL) button is enabled.
  ///
  /// Defaults to `true`.
  final bool showTextDirection;

  /// Whether the case converter button is enabled.
  ///
  /// Defaults to `false`.
  final bool showCaseConverter;

  /// Whether the decrease indent button is enabled.
  ///
  /// Defaults to `false`.
  final bool showDecreaseIndent;

  /// Whether the increase indent button is enabled.
  ///
  /// Defaults to `false`.
  final bool showIncreaseIndent;

  /// Whether the foreground color button is enabled.
  ///
  /// Defaults to `true`.
  final bool showForegroundColorButton;

  /// Whether the highlight color button is enabled.
  ///
  /// Defaults to `true`.
  final bool showHighlightColorButton;

  /// Whether the bold button is enabled.
  ///
  /// Defaults to `true`.
  final bool showBold;

  /// Whether the italic button is enabled.
  ///
  /// Defaults to `true`.
  final bool showItalic;

  /// Whether the strikethrough button is enabled.
  ///
  /// Defaults to `true`.
  final bool showStrikethrough;

  /// Whether the underline button is enabled.
  ///
  /// Defaults to `true`.
  final bool showUnderline;

  /// Semantic label used for accessibility.
  final String? semanticLabel;

  /// Whether the subscript button is enabled.
  ///
  /// Defaults to `true`.
  final bool showSubscript;

  /// Whether the superscript button is enabled.
  ///
  /// Defaults to `true`.
  final bool showSuperscript;

  /// Whether the horizontal rule button is enabled.
  ///
  /// Defaults to `true`.
  final bool showHorizontalRuler;

  /// Whether the link button is enabled.
  ///
  /// Defaults to `true`.
  final bool showLink;

  /// Whether the picture button is enabled.
  ///
  /// Defaults to `true`.
  final bool showImageUpload;

  /// Whether the audio button is enabled.
  ///
  /// Defaults to `false`.
  final bool showAudioUpload;

  /// Whether the other file button is enabled.
  ///
  /// Defaults to `false`.
  final bool otherFile;

  /// Whether the table button is enabled.
  ///
  /// Defaults to `true`.
  final bool showTable;

  /// Whether the video button is enabled.
  ///
  /// Defaults to `true`.
  final bool showVideoUpload;

  /// The hint text displayed when no content has been entered.
  ///
  /// Defaults to `'Your text here...'`.
  final String hintText;

  /// Whether to ensure the editor remains visible when the user starts typing.
  ///
  /// Defaults to `true`.
  final bool shouldEnsureVisible;

  /// Custom widgets added to the toolbar.
  final List<Widget>? customToolbarButtons;

  /// Type of toolbar to display.
  final ToolbarType? toolbarType;

  /// Maximum number of characters allowed in the editor.
  final int? characterLimit;

  /// Initial text displayed in the editor.
  final String? initialText;

  /// Allowed image file extensions.
  final List<String>? imageExtensions;

  /// Allowed video file extensions.
  final List<String>? videoExtensions;

  /// Callback invoked when the editor content changes.
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(),
      ),
      child: Semantics(
        label: semanticLabel,
        enabled: !disable,
        container: true,
        child: HtmlEditor(
          controller: controller,
          callbacks: Callbacks(
            onChangeContent: (String? val) {
              onChanged?.call(val ?? "");
            },
          ),
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
            disabled: disable,
          ),
        ),
      ),
    );
  }
}
