import 'dart:async';
import 'package:flutter/material.dart';

// Conditional import: use web implementation on web, stub on other platforms
import 'tiny_mce_web.dart' if (dart.library.io) 'tiny_mce_stub.dart';

/// Controller for RichTextTinyMce widget
class RichTextController {
  String _content = "";
  Completer<String>? _contentCompleter;

  VoidCallback? _requestCallback;
  void Function(String)? _setCallback;

  Future<String> getText() async {
    _contentCompleter = Completer<String>();
    _requestCallback?.call();

    try {
      return await _contentCompleter!.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => _content,
      );
    } catch (e) {
      return _content;
    }
  }

  void setText(String content) {
    _content = content;
    _setCallback?.call(content);
  }
}

/// Rich text editor widget using TinyMCE
class RichTextTinyMce extends StatefulWidget {
  final String? initialContent;
  final double height;
  final Function(String)? onContentChanged;
  final String editorId;
  final ScrollController? scrollController;
  final bool enabled;
  final RichTextController? controller;

  const RichTextTinyMce({
    super.key,
    this.initialContent,
    this.height = 500,
    this.onContentChanged,
    String? editorId,
    this.scrollController,
    this.enabled = true,
    this.controller,
  }) : editorId = editorId ?? 'rich-text-editor';

  @override
  State<RichTextTinyMce> createState() => _RichTextTinyMceState();
}

class _RichTextTinyMceState extends State<RichTextTinyMce> {
  final GlobalKey<TinyMceWidgetState> _editorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!._requestCallback = () => _editorKey.currentState?.requestContent();
      widget.controller!._setCallback = (content) => _editorKey.currentState?.setContent(content);
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
    widget.controller?._content = content;
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
    );
  }
}
