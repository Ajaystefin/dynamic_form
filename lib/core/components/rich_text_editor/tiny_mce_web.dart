import "dart:async";
import "dart:convert";
import "dart:js_interop";
import "dart:ui_web" as ui_web;
import "package:flutter/material.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:web/web.dart" as web;

/// Web-specific implementation for TinyMCE rich text editor.
class TinyMceBuilder {
  /// Builds a TinyMCE editor widget.
  static Widget buildEditor({
    required String editorId,
    required double height,
    required bool enabled,
    required Function(String) onContentUpdate,
    Key? key,
    String? initialContent,
    ScrollController? scrollController,
    int? characterLimit,
  }) {
    return TinyMceWebWidget(
      key: key,
      editorId: editorId,
      height: height,
      enabled: enabled,
      initialContent: initialContent,
      onContentUpdate: onContentUpdate,
      scrollController: scrollController,
      characterLimit: characterLimit,
    );
  }
}

/// TinyMCE web editor widget.
class TinyMceWebWidget extends StatefulWidget {
  /// Creates a [TinyMceWebWidget].
  const TinyMceWebWidget({
    required this.editorId,
    required this.height,
    required this.enabled,
    required this.onContentUpdate,
    super.key,
    this.initialContent,
    this.scrollController,
    this.characterLimit,
  });

  /// Unique editor identifier.
  final String editorId;

  /// Height of the editor widget.
  final double height;

  /// Indicates whether the editor is enabled.
  final bool enabled;

  /// Initial content loaded into the editor.
  final String? initialContent;

  /// Callback invoked when editor content changes.
  final Function(String) onContentUpdate;

  /// Scroll controller used to synchronize scrolling with the parent page.
  final ScrollController? scrollController;

  /// Maximum number of characters allowed.
  final int? characterLimit;

  @override
  State<TinyMceWebWidget> createState() => TinyMceWidgetState();
}

/// State implementation for the TinyMCE web editor widget.
class TinyMceWidgetState extends State<TinyMceWebWidget> {
  late web.HTMLIFrameElement _iframe;
  bool _isInitialized = false;
  StreamSubscription<web.MessageEvent>? _messageSubscription;

  /// Unique identifier used to register and render the TinyMCE iframe view.
  ///
  /// Combines the editor identifier with a timestamp to ensure uniqueness
  /// across multiple editor instances.
  late final String iframeId = "flutter-web-iframe-${widget.editorId}-"
      "${DateTime.now().millisecondsSinceEpoch}";

  @override
  void initState() {
    super.initState();
    _initializeIframe();
  }

  /// Origin URL hosting the TinyMCE React application.
  String get reactOrigin {
    final currentHost = web.window.location.host;
    final protocol = web.window.location.protocol;
    return "$protocol//$currentHost/wcas-angular?editorId=${widget.editorId}";
  }

  void _initializeIframe() {
    _iframe = web.HTMLIFrameElement()
      ..src = reactOrigin
      ..style.border = "none";
    // ..style.pointerEvents = widget.enabled ? 'auto' : 'none';

    ui_web.platformViewRegistry
        .registerViewFactory(iframeId, (int viewId) => _iframe);

    _messageSubscription = web.window.onMessage.listen((event) {
      if (_iframe.contentWindow != null &&
          event.source != _iframe.contentWindow) {
        return;
      }

      final data = (event.data! as JSObject).dartify();
      logger.i("Flutter: Message from TinyMCE (${widget.editorId}): $data");

      if (data is Map && data["action"] != null) {
        if (data["editor_id"] != widget.editorId) {
          return;
        }
        _receiveAction(data["action"], data["data"]);
      } else {
        logger.d(
          "Flutter: Invalid message format: data is"
          " not a Map or action is null",
        );
      }
    });
  }

  void _sendMessageToReact(Map data) {
    logger.d("Flutter: Sending: ${jsonEncode(data)}");
    // Send as object instead of JSON string for consistency
    _iframe.contentWindow?.postMessage(data.jsify(), reactOrigin.toJS);
  }

  void _receiveAction(String action, data) {
    logger.i("Flutter: Received action: $action with data: $data");
    switch (action) {
      case "page_loaded":
        _isInitialized = true;
        _sendMessageToReact({
          "editor_id": widget.editorId,
          "action": "set_initial_data",
          "data": widget.initialContent ?? "",
          "enabled": widget.enabled,
          "characterLimit": widget.characterLimit,
        });
      case "content_sent":
        widget.onContentUpdate(data);
      case "scroll_event":
        _handleIframeScroll(data);
      case "error":
        logger.i("Flutter: Error from TinyMCE: $data");
      default:
        logger.i(
          "Flutter: Received unknown action: $action with data: $data",
        );
    }
  }

  void _handleIframeScroll(Map<String, dynamic> scrollData) {
    final direction = scrollData["direction"] as String?;
    final delta = scrollData["delta"] as double? ?? 0;

    if (direction == "up" || direction == "down") {
      _scrollParentPage(direction == "up" ? -delta : delta);
    }
  }

  void _scrollParentPage(double delta) {
    if (widget.scrollController != null) {
      try {
        final currentOffset = widget.scrollController!.offset;
        final newOffset = currentOffset + delta;
        widget.scrollController!.animateTo(
          newOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );

        return;
      } on Object catch (e) {
        logger.i("Flutter: ScrollController failed: $e");
      }
    }
  }

  /// Requests the current editor content from TinyMCE.
  void requestContent() {
    _sendMessageToReact({
      "editor_id": widget.editorId,
      "action": "request_content",
      "data": "",
    });
  }

  /// Updates the editor content programmatically.
  ///
  /// Content is only sent after the editor has been initialized.
  void setContent(String content) {
    if (_isInitialized) {
      _sendMessageToReact({
        "editor_id": widget.editorId,
        "action": "set_initial_data",
        "data": content,
      });
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    // Manually remove the iframe from the DOM
    _iframe.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: HtmlElementView(viewType: iframeId),
    );
  }
}
