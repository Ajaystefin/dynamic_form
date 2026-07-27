import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/components/textarea.dart";

/// Remarks text area field.
class RemarksField extends StatefulWidget {
  /// Creates a remarks field.
  const RemarksField({
    required this.referenceId,
    required this.initialText,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });

  /// Reference id associated with the remarks field.
  final int referenceId;

  /// Initial text displayed in the remarks field.
  final String initialText;

  /// Callback invoked when the remarks text changes.
  final void Function(String) onChanged;

  /// Indicates whether the remarks field is read-only.
  final bool readOnly;

  @override
  State<RemarksField> createState() => _RemarksFieldState();
}

class _RemarksFieldState extends State<RemarksField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void didUpdateWidget(covariant RemarksField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialText != widget.initialText &&
        _controller.text != widget.initialText) {
      _controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextArea(
      readOnly: widget.readOnly,
      controller: _controller,
      minLines: 5,
      maxLength: 1000,
      onChanged: widget.onChanged,
    );
  }
}
