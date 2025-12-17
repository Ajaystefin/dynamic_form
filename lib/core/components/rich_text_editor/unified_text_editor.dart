import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:wcas_frontend/core/components/rich_text_editor/text_editor.dart';
import 'package:wcas_frontend/core/components/rich_text_editor/tiny_mce.dart';
import 'package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart';
import 'package:wcas_frontend/core/env_config.dart';

/// Unified rich text editor widget that switches between implementations based on env config
/// Simplified to include only commonly-used parameters
class UnifiedTextEditor extends StatelessWidget {
  /// Controller can be either HtmlEditorController, RichTextController, or UnifiedEditorController
  final dynamic controller;

  /// Whether the editor is disabled/read-only (default: false)
  final bool disable;

  /// Semantic label for accessibility (ignored for TinyMCE)
  final String? semanticLabel;

  /// Character limit for the text field (ignored for TinyMCE)
  final int? characterLimit;

  /// Initial HTML content to display in the editor
  final String? initialText;

  /// Whether video upload button is shown (default: true, ignored for TinyMCE)
  final bool showVideoUpload;

  /// Height for TinyMCE editor (default: 500, ignored for HtmlEditor)
  final double height;

  /// Editor ID for TinyMCE (ignored for HtmlEditor)
  final String? editorId;

  /// Scroll controller for TinyMCE (ignored for HtmlEditor)
  final ScrollController? scrollController;

  const UnifiedTextEditor({
    super.key,
    required this.controller,
    this.disable = false,
    this.semanticLabel,
    this.characterLimit,
    this.initialText,
    this.showVideoUpload = true,
    this.height = 500,
    this.editorId,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // Check which editor to use based on env config
    if (EnvConfig.useTinyMceEditor) {
      return _buildTinyMceEditor();
    } else {
      return _buildHtmlEditor();
    }
  }

  Widget _buildHtmlEditor() {
    // Extract HtmlEditorController from controller parameter
    final HtmlEditorController htmlController;
    if (controller is UnifiedEditorController) {
      final unifiedController = controller as UnifiedEditorController;
      if (unifiedController is HtmlEditorWrapper) {
        htmlController = unifiedController.controller;
      } else {
        throw ArgumentError(
            'When useTinyMceEditor is false, controller must wrap HtmlEditorController');
      }
    } else if (controller is HtmlEditorController) {
      htmlController = controller;
    } else {
      throw ArgumentError(
          'Controller must be either HtmlEditorController or UnifiedEditorController wrapping HtmlEditorController');
    }

    return CustomTextEditorWidget(
      controller: htmlController,
      disable: disable,
      semanticLabel: semanticLabel,
      characterLimit: characterLimit,
      initialText: initialText,
      showVideoUpload: showVideoUpload,
    );
  }

  Widget _buildTinyMceEditor() {
    // Extract RichTextController from controller parameter
    final RichTextController richTextController;
    if (controller is UnifiedEditorController) {
      final unifiedController = controller as UnifiedEditorController;
      if (unifiedController is TinyMceEditorWrapper) {
        richTextController = unifiedController.controller;
      } else {
        throw ArgumentError(
            'When useTinyMceEditor is true, controller must wrap RichTextController');
      }
    } else if (controller is RichTextController) {
      richTextController = controller;
    } else {
      throw ArgumentError(
          'Controller must be either RichTextController or UnifiedEditorController wrapping RichTextController');
    }

    return RichTextTinyMce(
      controller: richTextController,
      initialContent: initialText,
      enabled: !disable,
      height: height,
      editorId: editorId,
      scrollController: scrollController,
    );
  }
}
