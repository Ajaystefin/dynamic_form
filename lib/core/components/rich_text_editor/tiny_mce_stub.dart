import "package:flutter/material.dart";

/// Stub implementation for non-web platforms
class TinyMceBuilder {
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

class TinyMceWebWidget extends StatefulWidget {
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
  final String editorId;
  final double height;
  final bool enabled;
  final String? initialContent;
  final Function(String) onContentUpdate;
  final ScrollController? scrollController;
  final int? characterLimit;

  @override
  State<TinyMceWebWidget> createState() => TinyMceWidgetState();
}

class TinyMceWidgetState extends State<TinyMceWebWidget> {
  // Public methods for controller (no-ops on non-web)
  void requestContent() {
    // No-op on non-web platforms
  }

  void setContent(String content) {
    // No-op on non-web platforms
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: Colors.orange[700],
          ),
          const SizedBox(height: 16),
          Text(
            "TinyMCE Rich Text Editor",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This editor is only available on web platform",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
