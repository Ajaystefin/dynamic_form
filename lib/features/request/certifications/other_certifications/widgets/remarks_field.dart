import 'package:flutter/widgets.dart';
import 'package:wcas_frontend/core/components/textfield.dart';

class RemarksField extends StatefulWidget {
  final int referenceId;
  final String initialText;
  final void Function(String) onChanged;
  final bool readOnly;

  const RemarksField(
      {super.key,
      required this.referenceId,
      required this.initialText,
      required this.onChanged,
      required this.readOnly});

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
    return CustomTextField(
      readOnly: widget.readOnly,
      controller: _controller,
      minLines: 5,
      maxLines: 10,
      counterText: "",
      maxLength: 1000,
      onChanged: widget.onChanged,
    );
  }
}
