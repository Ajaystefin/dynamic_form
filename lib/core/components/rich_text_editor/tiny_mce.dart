import "dart:async";
import "package:flutter/material.dart";
// Conditional import: use web implementation on web, stub on other platforms
import "package:wcas_frontend/core/components/rich_text_editor/tiny_mce_web.dart"
    if (dart.library.io) "tiny_mce_stub.dart";

/// Controller for [RichTextTinyMce] widget.
class RichTextController {
  Completer<String>? _contentCompleter;

  VoidCallback? _requestCallback;
  void Function(String)? _setCallback;

  /// Retrieves the current editor content.
  ///
  /// Throws a [TimeoutException] if content is not received within
  /// five seconds.
  Future<String> getText() async {
    _contentCompleter = Completer<String>();
    _requestCallback?.call();

    return _contentCompleter!.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw TimeoutException(
          "Failed to receive content from editor",
          const Duration(seconds: 5),
        );
      },
    );
  }

  /// Updates the editor content programmatically.
  void setText(String content) {
    _setCallback?.call(content);
  }
}

/// Rich text editor widget using TinyMCE.
class RichTextTinyMce extends StatefulWidget {
  /// Creates a [RichTextTinyMce].
  const RichTextTinyMce({
    super.key,
    this.initialContent,
    this.height = 500,
    this.onContentChanged,
    String? editorId,
    this.scrollController,
    this.enabled = true,
    this.controller,
    this.characterLimit,
  }) : editorId = editorId ?? "rich-text-editor";

  /// Initial HTML content displayed in the editor.
  final String? initialContent;

  /// Height of the editor widget.
  final double height;

  /// Callback invoked when the editor content changes.
  final Function(String)? onContentChanged;

  /// Unique editor identifier.
  final String editorId;

  /// Scroll controller used to synchronize parent scrolling.
  final ScrollController? scrollController;

  /// Indicates whether the editor is enabled.
  final bool enabled;

  /// Controller used to interact with the editor.
  final RichTextController? controller;

  /// Maximum number of characters allowed.
  final int? characterLimit;

  @override
  State<RichTextTinyMce> createState() => _RichTextTinyMceState();
}

class _RichTextTinyMceState extends State<RichTextTinyMce> {
  final GlobalKey<TinyMceWidgetState> _editorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!._requestCallback =
          () => _editorKey.currentState?.requestContent();
      widget.controller!._setCallback =
          (content) => _editorKey.currentState?.setContent(content);
    }
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!._requestCallback = null;
      widget.controller!._setCallback = null;
    }
    super.dispose();
  }

  void _onContentUpdate(String content) {
    if (widget.controller?._contentCompleter != null &&
        !widget.controller!._contentCompleter!.isCompleted) {
      widget.controller!._contentCompleter!.complete(content);
    }
    widget.onContentChanged?.call(content);
  }

  @override
  Widget build(BuildContext context) {
    return TinyMceBuilder.buildEditor(
      key: _editorKey,
      editorId: widget.editorId,
      height: widget.height,
      enabled: widget.enabled,
      initialContent: widget.initialContent,
      onContentUpdate: _onContentUpdate,
      scrollController: widget.scrollController,
      characterLimit: widget.characterLimit,
    );
  }
}
