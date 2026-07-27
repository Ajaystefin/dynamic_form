import "package:flutter/material.dart";
import "package:html_editor_enhanced/html_editor.dart";
import "package:wcas_frontend/core/components/rich_text_editor/text_editor.dart";
import "package:wcas_frontend/core/components/rich_text_editor/tiny_mce.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/utils/form_access_provider.dart";

/// Unified rich text editor widget that switches between implementations based
/// on environment configuration.
///
/// Simplified to include only commonly used parameters.
class UnifiedTextEditor extends StatefulWidget {
  /// Creates a [UnifiedTextEditor].
  const UnifiedTextEditor({
    required this.controller,
    super.key,
    this.disable = false,
    this.semanticLabel,
    this.characterLimit,
    this.initialText,
    this.showVideoUpload = true,
    this.height = 500,
    this.editorId,
    this.scrollController,
    this.ignoreProvider = false,
  });

  /// Controller that can be either [HtmlEditorController],
  /// [RichTextController], or [UnifiedEditorController].
  final dynamic controller;

  /// Whether the editor is disabled or read-only.
  ///
  /// Defaults to `false`.
  final bool disable;

  /// Semantic label used for accessibility.
  ///
  /// Ignored for TinyMCE.
  final String? semanticLabel;

  /// Maximum number of characters allowed.
  ///
  /// Ignored for TinyMCE.
  final int? characterLimit;

  /// Initial HTML content displayed in the editor.
  final String? initialText;

  /// Whether the video upload button is shown.
  ///
  /// Defaults to `true`.
  ///
  /// Ignored for TinyMCE.
  final bool showVideoUpload;

  /// Height of the TinyMCE editor.
  ///
  /// Defaults to `500`.
  ///
  /// Ignored for HtmlEditor.
  final double height;

  /// Editor identifier used by TinyMCE.
  ///
  /// Ignored for HtmlEditor.
  final String? editorId;

  /// Indicates whether the editor should ignore
  /// [FormAccessProvider] restrictions.
  final bool ignoreProvider;

  /// Scroll controller used by TinyMCE.
  ///
  /// Ignored for HtmlEditor.
  final ScrollController? scrollController;

  @override
  State<UnifiedTextEditor> createState() => _UnifiedTextEditorState();
}

class _UnifiedTextEditorState extends State<UnifiedTextEditor> {
  @override
  void initState() {
    super.initState();
    _initializeControllerText();
  }

  @override
  void didUpdateWidget(UnifiedTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != oldWidget.initialText ||
        widget.controller != oldWidget.controller) {
      _initializeControllerText();
    }
  }

  void _initializeControllerText() {
    if (widget.controller is UnifiedEditorController) {
      (widget.controller as UnifiedEditorController)
          .setInternalText(widget.initialText ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Combine the widget's own disable flag with any ancestor
    // FormAccessProvider
    // so that placing an RTE inside a disabled BoxLayout makes it read-only.
    final bool effectiveDisable =
        widget.disable || FormAccessProvider.of(context);

    // Check which editor to use based on env config
    if (EnvConfig.useTinyMceEditor) {
      return _buildTinyMceEditor(effectiveDisable);
    } else {
      return _buildHtmlEditor(effectiveDisable);
    }
  }

  Widget _buildHtmlEditor(bool disable) {
    // Extract HtmlEditorController from controller parameter
    final HtmlEditorController htmlController;
    if (widget.controller is UnifiedEditorController) {
      final unifiedController = widget.controller as UnifiedEditorController;
      if (unifiedController is HtmlEditorWrapper) {
        htmlController = unifiedController.controller;
      } else {
        throw ArgumentError(
          "When useTinyMceEditor is false, controller"
          " must wrap HtmlEditorController",
        );
      }
    } else if (widget.controller is HtmlEditorController) {
      htmlController = widget.controller;
    } else {
      throw ArgumentError(
        "Controller must be either "
        "HtmlEditorController or "
        "UnifiedEditorController wrapping HtmlEditorController",
      );
    }
    final bool effectiveIsEnabled =
        widget.ignoreProvider || !FormAccessProvider.of(context);

    return IgnorePointer(
      ignoring: !effectiveIsEnabled,
      child: CustomTextEditorWidget(
        controller: htmlController,
        disable: !effectiveIsEnabled && disable,
        semanticLabel: widget.semanticLabel,
        characterLimit: widget.characterLimit,
        initialText: widget.initialText,
        showVideoUpload: widget.showVideoUpload,
        onChanged: (String content) {
          if (widget.controller is UnifiedEditorController) {
            (widget.controller as UnifiedEditorController)
                .setInternalText(content);
          }
        },
      ),
    );
  }

  Widget _buildTinyMceEditor(bool disable) {
    // Extract RichTextController from controller parameter
    final RichTextController richTextController;
    if (widget.controller is UnifiedEditorController) {
      final unifiedController = widget.controller as UnifiedEditorController;
      if (unifiedController is TinyMceEditorWrapper) {
        richTextController = unifiedController.controller;
      } else {
        throw ArgumentError(
          "When useTinyMceEditor is true, "
          "controller must wrap RichTextController",
        );
      }
    } else if (widget.controller is RichTextController) {
      richTextController = widget.controller;
    } else {
      throw ArgumentError(
        "Controller must be either RichTextController or "
        "UnifiedEditorController wrapping RichTextController",
      );
    }

    return RichTextTinyMce(
      controller: richTextController,
      initialContent: widget.initialText,
      enabled: !disable,
      height: widget.height,
      editorId: widget.editorId,
      scrollController: widget.scrollController,
      characterLimit: widget.characterLimit,
      onContentChanged: (String content) {
        if (widget.controller is UnifiedEditorController) {
          (widget.controller as UnifiedEditorController)
              .setInternalText(content);
        }
      },
    );
  }
}
