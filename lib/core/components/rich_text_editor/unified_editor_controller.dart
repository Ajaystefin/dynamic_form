import "package:html_editor_enhanced/html_editor.dart";
import "package:wcas_frontend/core/components/rich_text_editor/tiny_mce.dart";
import "package:wcas_frontend/core/env_config.dart";

/// Abstract interface for rich text editor controllers
/// Provides a unified API regardless of the underlying implementation
abstract class UnifiedEditorController {
  /// Factory constructor that returns the appropriate controller based on env
  /// config
  factory UnifiedEditorController() {
    if (EnvConfig.useTinyMceEditor) {
      return TinyMceEditorWrapper();
    } else {
      return HtmlEditorWrapper();
    }
  }

  /// Factory constructor for creating wrapper around existing controller
  factory UnifiedEditorController.fromController(dynamic controller) {
    if (controller is HtmlEditorController) {
      return HtmlEditorWrapper.fromController(controller);
    } else if (controller is RichTextController) {
      return TinyMceEditorWrapper.fromController(controller);
    } else {
      throw ArgumentError(
        "Unsupported controller type: ${controller.runtimeType}",
      );
    }
  }

  /// Get the current text/HTML content from the editor
  Future<String> getText();

  /// Synchronously get the current text/HTML content from the editor
  String get currentText;

  /// Set the content of the editor
  void setText(String content);

  /// Set the internal cached content without triggering external events
  void setInternalText(String content);

  /// Get the underlying controller instance
  dynamic get controller;
}

/// Wrapper for HtmlEditorController (html_editor_enhanced package)
class HtmlEditorWrapper implements UnifiedEditorController {
  HtmlEditorWrapper() : _controller = HtmlEditorController();

  HtmlEditorWrapper.fromController(this._controller);
  final HtmlEditorController _controller;
  String _currentText = "";

  @override
  Future<String> getText() async {
    return _currentText;
  }

  @override
  String get currentText => _currentText;

  @override
  void setText(String content) {
    _currentText = content;
    _controller.setText(content);
  }

  @override
  void setInternalText(String content) {
    _currentText = content;
  }

  @override
  HtmlEditorController get controller => _controller;
}

/// Wrapper for RichTextController (TinyMCE implementation)
class TinyMceEditorWrapper implements UnifiedEditorController {
  TinyMceEditorWrapper() : _controller = RichTextController();

  TinyMceEditorWrapper.fromController(this._controller);
  final RichTextController _controller;
  String _currentText = "";

  @override
  Future<String> getText() async {
    return _currentText;
  }

  @override
  String get currentText => _currentText;

  @override
  void setText(String content) {
    _currentText = content;
    _controller.setText(content);
  }

  @override
  void setInternalText(String content) {
    _currentText = content;
  }

  @override
  RichTextController get controller => _controller;
}
