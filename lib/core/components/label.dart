import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// Reusable LabelWidget with dynamic content, icon, and focus support
class LabelWidget extends StatefulWidget {
  // Toggles pointer interaction

  const LabelWidget({
    required this.label,
    super.key,
    this.isRequired = false,
    this.showLabel = true,
    this.isEnabled = true,
    this.child,
    this.exponent,
    this.icon,
    this.spacing = 4.0,
    this.verticalSpace = 4,
    this.labelStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    this.iconColor,
    this.iconSize,
    this.onTextTap,
    this.onIconTap,
    this.infoContent,
    this.isRichMessage = false,
  });
  final String label; // Main label text
  final bool isRequired; // Display * based on flag
  final String? exponent; // Display exponent appended to label
  final bool showLabel; // Toggle label visibility
  final Widget? child; // Child widget (e.g., input field)
  final IconData? icon; // Optional icon
  final double spacing; // Spacing between label and icon
  final double verticalSpace;
  final TextStyle? labelStyle; // Custom label text style
  final Color? iconColor; // Icon color
  final double? iconSize; // Icon size
  final VoidCallback? onTextTap; // Label tap action
  final VoidCallback? onIconTap; // Icon tap action
  final String? infoContent; // Info icon tooltip content
  final bool isRichMessage; // Info tooltip uses rich content
  final bool isEnabled;

  @override
  State<LabelWidget> createState() => _LabelWidgetState();
}

class _LabelWidgetState extends State<LabelWidget> {
  final FocusNode _textFocusNode = FocusNode();
  final FocusNode _iconFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.tab): const NextFocusIntent(),
        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab):
            const PreviousFocusIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      },
      child: Actions(
        actions: {
          NextFocusIntent: CallbackAction<NextFocusIntent>(
            onInvoke: (intent) => FocusScope.of(context).nextFocus(),
          ),
          PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
            onInvoke: (intent) => FocusScope.of(context).previousFocus(),
          ),
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              if (_textFocusNode.hasFocus) {
                widget.onTextTap?.call();
              } else if (_iconFocusNode.hasFocus) {
                widget.onIconTap?.call();
              }
              return null;
            },
          ),
        },
        child: IgnorePointer(
          ignoring: !widget.isEnabled,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label and icon row
              ExcludeSemantics(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // final textDirection = Directionality.of(context);
                    // final maxWidth = constraints.maxWidth;

                    // Measure overflow using the same style, lines and ellipsis
                    // final painter = TextPainter(
                    //   text: TextSpan(
                    //     text: widget.label,
                    //     style: widget.labelStyle,
                    //   ),
                    //   maxLines: 1,
                    //   textDirection: textDirection,
                    //   ellipsis: '…', // match TextOverflow.ellipsis
                    // )..layout(maxWidth: maxWidth);

                    // final didOverflow = painter.didExceedMaxLines;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (widget.showLabel)
                          Flexible(
                            child: FocusableActionDetector(
                              focusNode: _textFocusNode,
                              child: InkWell(
                                onTap: widget.onTextTap,
                                child: _buildOverflowAwareLabel(
                                  context: context,
                                  // didOverflow: didOverflow,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(width: widget.spacing),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: widget.verticalSpace),

              if (widget.child != null)
                ColoredBox(
                  color: widget.isEnabled
                      ? Colors.transparent
                      : AppColors.textFieldDisabledFill,
                  child: widget.child,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the actual rich label and wraps with CustomTooltip only if it
  /// overflowed.
  Widget _buildOverflowAwareLabel({
    required BuildContext context,
    // required bool didOverflow,
  }) {
    final richLabel = Text.rich(
      TextSpan(
        text: widget.label,
        children: [
          if (widget.exponent != null)
            TextSpan(
              text: " ${widget.exponent}",
              style: const TextStyle(
                fontSize: 9,
                fontFeatures: [
                  FontFeature.superscripts(),
                  FontFeature.enable("sups"),
                ],
              ),
            ),
          if (widget.isRequired)
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Transform.translate(
                offset: const Offset(0, 4),
                child: const Text(
                  " *",
                  style: TextStyle(
                    color: AppColors.failure,
                  ),
                ),
              ),
            ),
          if (widget.icon != null)
            WidgetSpan(
              child: FocusableActionDetector(
                focusNode: _iconFocusNode,
                child: InkWell(
                  onTap: widget.onIconTap,
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor ?? AppColors.black,
                    size: widget.iconSize ?? 20.0,
                  ),
                ),
              ),
            ),
          if (widget.infoContent != null)
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: CustomTooltip(
                  isRichMessage: widget.isRichMessage,
                  message: widget.infoContent!,
                  textAlign: TextAlign.start,
                  child: const Icon(
                    Icons.info_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
      style: widget.labelStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    // Only wrap with tooltip when text actually overflows
    if (widget.label.length > 34) {
      //check now
      return CustomTooltip(
        message: widget.label, // show full label in tooltip
        child: richLabel,
      );
    } else {
      return richLabel;
    }
  }

  @override
  void dispose() {
    _textFocusNode.dispose();
    _iconFocusNode.dispose();
    super.dispose();
  }
}
