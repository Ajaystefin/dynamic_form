// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:web/web.dart' as web;

/// Web-specific implementation for TinyMCE rich text editor
class TinyMceBuilder {
  static Widget buildEditor({
    Key? key,
    required String editorId,
    required double height,
    required bool enabled,
    String? initialContent,
    required Function(String) onContentUpdate,
    ScrollController? scrollController,
  }) {
    return TinyMceWebWidget(
      key: key,
      editorId: editorId,
      height: height,
      enabled: enabled,
      initialContent: initialContent,
      onContentUpdate: onContentUpdate,
      scrollController: scrollController,
    );
  }
}

class TinyMceWebWidget extends StatefulWidget {
  final String editorId;
  final double height;
  final bool enabled;
  final String? initialContent;
  final Function(String) onContentUpdate;
  final ScrollController? scrollController;

  const TinyMceWebWidget({
    super.key,
    required this.editorId,
    required this.height,
    required this.enabled,
    this.initialContent,
    required this.onContentUpdate,
    this.scrollController,
  });

  @override
  State<TinyMceWebWidget> createState() => TinyMceWidgetState();
}

class TinyMceWidgetState extends State<TinyMceWebWidget> {
  late web.HTMLIFrameElement _iframe;
  bool _isInitialized = false;
  StreamSubscription<web.MessageEvent>? _messageSubscription;

  late final String iframeId =
      "flutter-web-iframe-${widget.editorId}-${DateTime.now().millisecondsSinceEpoch}";

  @override
  void initState() {
    super.initState();
    _initializeIframe();
  }

  String get reactOrigin {
    final currentHost = web.window.location.host;
    final protocol = web.window.location.protocol;
    return "$protocol//$currentHost/wcas-angular?editorId=${widget.editorId}";
  }

  void _initializeIframe() {
    _iframe = web.HTMLIFrameElement()
      ..src = reactOrigin
      ..style.border = 'none';
    // ..style.pointerEvents = widget.enabled ? 'auto' : 'none';

    ui_web.platformViewRegistry
        .registerViewFactory(iframeId, (int viewId) => _iframe);

    _messageSubscription = web.window.onMessage.listen((event) {
      if (_iframe.contentWindow != null &&
          event.source != _iframe.contentWindow) {
        return;
      }

      var data = (event.data as JSObject).dartify();
      print("Flutter: Message from TinyMCE (${widget.editorId}): $data");

      if (data is Map && data['action'] != null) {
        if (data['editor_id'] != widget.editorId) {
          return;
        }
        _receiveAction(data['action'], data['data']);
      } else {
        logger.d(
            "Flutter: Invalid message format: data is not a Map or action is null");
      }
    });
  }

  void _sendMessageToReact(Map data) {
    logger.d("Flutter: Sending: ${jsonEncode(data).toString()}");
    // Send as object instead of JSON string for consistency
    _iframe.contentWindow?.postMessage(data.jsify(), reactOrigin.toJS);
  }

  void _receiveAction(String action, dynamic data) {
    print("Flutter: Received action: $action with data: ${data.toString()}");
    switch (action) {
      case "page_loaded":
        _isInitialized = true;
        _sendMessageToReact({
          "editor_id": widget.editorId,
          "action": "set_initial_data",
          "data": widget.initialContent ?? "",
          "enabled": widget.enabled
        });
        break;
      case "content_sent":
        widget.onContentUpdate(data);
        break;
      case "scroll_event":
        _handleIframeScroll(data);
        break;
      case "error":
        print("Flutter: Error from TinyMCE: $data");
        break;
      default:
        print("Flutter: Received unknown action: $action with data: $data");
    }
  }

  void _handleIframeScroll(Map<String, dynamic> scrollData) {
    final direction = scrollData['direction'] as String?;
    final delta = scrollData['delta'] as double? ?? 0;

    if (direction == 'up' || direction == 'down') {
      _scrollParentPage(direction == 'up' ? -delta : delta);
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
      } catch (e) {
        print('Flutter: ScrollController failed: $e');
      }
    }
  }

  // Public methods for controller
  void requestContent() {
    _sendMessageToReact({
      "editor_id": widget.editorId,
      "action": "request_content",
      "data": ""
    });
  }

  void setContent(String content) {
    if (_isInitialized) {
      _sendMessageToReact({
        "editor_id": widget.editorId,
        "action": "set_initial_data",
        "data": content
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
