import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// Reusable label widget with support for dynamic content,
/// icons, tooltips, and focus handling.
class LabelWidget extends StatefulWidget {
  // Toggles pointer interaction

  /// Creates a [LabelWidget].
  const LabelWidget({
    required this.label,
    super.key,
    this.isRequired = false,
    this.showAsteric = true,
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
    this.labelStyle2 = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    this.iconColor,
    this.iconSize,
    this.onTextTap,
    this.onIconTap,
    this.infoContent,
    this.isRichMessage = false,
    this.customTooltip = false,
    this.label2,
    this.labelMaxLines = 1,
    this.showOverflowTooltip = true,
  });

  /// Main label text.
  final String label;

  /// Displays a required indicator when `true`.
  final bool isRequired;

  /// Controls whether the required asterisk is displayed.
  final bool showAsteric;

  /// Controls label visibility.
  final bool showLabel;

  /// Enables or disables user interaction.
  final bool isEnabled;

  /// Widget displayed below the label.
  final Widget? child;

  /// Optional exponent text displayed next to the label.
  final String? exponent;

  /// Optional icon displayed beside the label.
  final IconData? icon;

  /// Spacing between the label and icon.
  final double spacing;

  /// Vertical spacing between the label and child widget.
  final double verticalSpace;

  /// Text style applied to the primary label.
  final TextStyle? labelStyle;

  /// Text style applied to the secondary label.
  final TextStyle? labelStyle2;

  /// Color of the icon.
  final Color? iconColor;

  /// Size of the icon.
  final double? iconSize;

  /// Callback invoked when the label text is tapped.
  final VoidCallback? onTextTap;

  /// Callback invoked when the icon is tapped.
  final VoidCallback? onIconTap;

  /// Content displayed in the information tooltip.
  final String? infoContent;

  /// Indicates whether the tooltip should render rich content.
  final bool isRichMessage;

  /// Enables custom tooltip behavior.
  final bool customTooltip;

  /// Optional secondary label text.
  final String? label2;

  /// Maximum number of lines allowed for the label.
  final int labelMaxLines;

  /// Shows a tooltip when the label text overflows.
  final bool showOverflowTooltip;

  @override
  State<LabelWidget> createState() => _LabelWidgetState();
}

class _LabelWidgetState extends State<LabelWidget> {
  final FocusNode _textFocusNode = FocusNode();
  final FocusNode _iconFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.isEnabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label and icon row
          ExcludeSemantics(
            child: Shortcuts(
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
                    onInvoke: (intent) =>
                        FocusScope.of(context).previousFocus(),
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
          if (widget.isRequired && widget.showAsteric)
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
          if (widget.label2 != null)
            TextSpan(
              text: " ${widget.label2}",
              style: widget.labelStyle2,
            ),
        ],
      ),
      style: widget.labelStyle,
      maxLines: widget.labelMaxLines,
      softWrap: widget.labelMaxLines > 1,
      overflow: TextOverflow.ellipsis,
    );

    // Only wrap with tooltip when text actually overflows
    if (widget.showOverflowTooltip &&
        widget.label.length > 34 &&
        !widget.customTooltip) {
      //check now
      return CustomTooltip(
        isRichMessage: widget.isRichMessage,
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
