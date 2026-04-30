import "package:flutter/material.dart";
import "package:html_editor_enhanced/html_editor.dart";
import "package:wcas_frontend/core/constants/constants.dart";

class CustomTextEditorWidget extends StatelessWidget {
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
  final HtmlEditorController controller;

  final bool disable;

  /// Optional: Text style for the HTML editor text.
  final TextStyle? textStyle;

  // Whether image picking is allowed in the toolbar (default is true).
  final bool allowImagePicking;

  // Whether the redo button is enabled in the toolbar (default is false).
  final bool showRedo;

  // Whether the undo button is enabled in the toolbar (default is false).
  final bool showUndo;

  // Whether the font size button is enabled in the toolbar (default is true).
  final bool showFontSize;

  // Whether the font size unit button is enabled in the toolbar (default is
  // true).
  final bool showFontSizeUnit;

  // Whether the list styles button (numberedList andbulletList) is enabled
  // (default is true).
  final bool showListStyles;

  // Whether the numbered list button is enabled (default is true).
  final bool showNumberedList;

  // Whether the bullet list button is enabled (default is true).
  final bool showBulletList;

  // Whether the align center button is enabled (default is true).
  final bool showAlignCenter;

  // Whether the align justify button is enabled (default is true).
  final bool showAlignJustify;

  // Whether the align left button is enabled (default is true).
  final bool showAlignLeft;

  // Whether the align right button is enabled (default is true).
  final bool showAlignRight;

  // Whether the line height button is enabled (default is true).
  final bool showLineHeight;

  // Whether the text direction (LTR/RTL) button is enabled (default is true).
  final bool showTextDirection;

  // Whether the case converter button is enabled (default is false).
  final bool showCaseConverter;

  // Whether the decrease indent button is enabled (default is true).
  final bool showDecreaseIndent;

  // Whether the increase indent button is enabled (default is true).
  final bool showIncreaseIndent;

  // Whether the foreground color button is enabled (default is true).
  final bool showForegroundColorButton;

  // Whether the highlight color button is enabled (default is true).
  final bool showHighlightColorButton;

  // Whether the bold button is enabled (default is true).
  final bool showBold;

  // Whether the italic button is enabled (default is true).
  final bool showItalic;

  // Whether the strikethrough button is enabled (default is true).
  final bool showStrikethrough;

  // Whether the underline button is enabled (default is true).
  final bool showUnderline;

  final String? semanticLabel;

  // Whether the subscript button is enabled (default is true).
  final bool showSubscript;

  // Whether the superscript button is enabled (default is true).
  final bool showSuperscript;

  // Whether the horizontal rule button is enabled (default is true).
  final bool showHorizontalRuler;

  // Whether the link button is enabled (default is true).
  final bool showLink;

  // Whether the picture button is enabled (default is true).
  final bool showImageUpload;

  // Whether the audio button is enabled (default is false).
  final bool showAudioUpload;

  // Whether the other file button is enabled (default is false).
  final bool otherFile;

  // Whether the table button is enabled (default is true).
  final bool showTable;

  // Whether the video button is enabled (default is true).
  final bool showVideoUpload;

  // The hint text to display in the editor when no text is entered (default is
  // 'Your text here...').
  final String hintText;

  // Whether to ensure the editor is visible when the user starts typing
  // (default is true).
  final bool shouldEnsureVisible;

  /// To add custom widgets to the toolbar
  final List<Widget>? customToolbarButtons;

  /// To change the type of Toolbar
  final ToolbarType? toolbarType;

  /// To limit allowed characters in the text field
  final int? characterLimit;

  /// initial String text  to the editor
  final String? initialText;

  /// Allowed image extensions
  final List<String>? imageExtensions;

  /// Allowed video extensions
  final List<String>? videoExtensions;

  final ValueChanged<String>? onChangeContent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.black),
      ),
      child: HtmlEditor(
        controller: controller,
        htmlToolbarOptions: HtmlToolbarOptions(
          imageExtensions: imageExtensions,
          videoExtensions: videoExtensions,
          allowImagePicking: allowImagePicking,
          textStyle: textStyle,
          customToolbarButtons: customToolbarButtons ?? [],
          toolbarPosition: ToolbarPosition.aboveEditor,
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
          autoAdjustHeight: true,
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
