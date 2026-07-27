import "package:flutter/material.dart";

/// Stub implementation for non-web platforms.
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

/// TinyMCE widget placeholder for non-web platforms.
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

  /// Scroll controller associated with the editor.
  final ScrollController? scrollController;

  /// Maximum number of characters allowed.
  final int? characterLimit;

  @override
  State<TinyMceWebWidget> createState() => TinyMceWidgetState();
}

/// State for the non-web TinyMCE placeholder widget.
class TinyMceWidgetState extends State<TinyMceWebWidget> {
  /// Requests the current editor content.
  ///
  /// No-op on non-web platforms.
  void requestContent() {
    // No-op on non-web platforms
  }

  /// Sets the editor content.
  ///
  /// No-op on non-web platforms.
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
