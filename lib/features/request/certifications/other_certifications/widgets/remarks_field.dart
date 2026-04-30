import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/components/textarea.dart";

class RemarksField extends StatefulWidget {
  const RemarksField({
    required this.referenceId,
    required this.initialText,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });
  final int referenceId;
  final String initialText;
  final void Function(String) onChanged;
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
      maxLines: 10,
      maxLength: 1000,
      onChanged: widget.onChanged,
    );
  }
}
