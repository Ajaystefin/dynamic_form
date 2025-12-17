// ignore_for_file: avoid_print

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

  String get iframeId => "flutter-web-iframe-${widget.editorId}";

  @override
  void initState() {
    super.initState();
    _initializeIframe();
  }

  String get reactOrigin {
    final currentHost = web.window.location.host;
    final protocol = web.window.location.protocol;
    return "$protocol//$currentHost/rich_text/tinymce";
  }

  void _initializeIframe() {
    _iframe = web.HTMLIFrameElement()
      ..src = reactOrigin
      ..style.border = 'none'
      ..style.pointerEvents = widget.enabled ? 'auto' : 'none';

    ui_web.platformViewRegistry
        .registerViewFactory(iframeId, (int viewId) => _iframe);

    web.window.onMessage.listen((event) {
      var data = (event.data as JSObject).dartify();
      logger.d("Message from TinyMCE (${widget.editorId}): $data");

      if (data is Map && data['action'] != null) {
        if (data['action'] != 'page_loaded' &&
            data['editor_id'] != widget.editorId) {
          return;
        }
        _receiveAction(data['action'], data['data']);
      }
    });
  }

  void _sendMessageToReact(Map data) {
    _iframe.contentWindow?.postMessage(jsonEncode(data).toJS, reactOrigin.toJS);
  }

  void _receiveAction(String action, dynamic data) {
    print('action received $action $data');
    switch (action) {
      case "page_loaded":
        logger.d("Received action: $action with data: $data");
        _isInitialized = true;
        _sendMessageToReact({
          "editor_id": widget.editorId,
          "action": "set_initial_data",
          "data": widget.initialContent ??
              "<h2>New Loaded Content from flutter</h2><p>Could be Loaded via API</p>",
          "enabled": widget.enabled
        });
        break;
      case "content_sent":
        logger.d("Received action: $action with data: $data");
        widget.onContentUpdate(data);
        break;
      case "scroll_event":
        _handleIframeScroll(data);
        break;
      default:
        logger.d("Received unknown action: $action with data: $data");
    }
  }

  void _handleIframeScroll(Map<String, dynamic> scrollData) {
    print('scroll data: $scrollData');
    final direction = scrollData['direction'] as String?;
    final delta = scrollData['delta'] as double? ?? 0;

    if (direction == 'up' || direction == 'down') {
      _scrollParentPage(direction == 'up' ? -delta : delta);
    }
  }

  void _scrollParentPage(double delta) {
    print('=== SCROLLING PARENT PAGE ===');
    print('Delta: $delta');

    if (widget.scrollController != null) {
      try {
        final currentOffset = widget.scrollController!.offset;
        final newOffset = currentOffset + delta;
        widget.scrollController!.animateTo(
          newOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        print('Flutter ScrollController scroll executed');
        return;
      } catch (e) {
        print('Flutter ScrollController failed: $e');
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: HtmlElementView(viewType: iframeId),
    );
  }
}
