import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

/// Reusable LabelWidget with dynamic content, icon, and focus support
class LabelWidget extends StatefulWidget {
  final String label; // Main label text
  final bool isRequired; // Display * or + based on flag
  final String? exponent; // Display exponentials append from label
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
  final String? infoContent;
  final bool isRichMessage;
  final bool isEnabled;

  const LabelWidget(
      {super.key,
      required this.label,
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
      this.isRichMessage = false});

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
                child: LayoutBuilder(builder: (context, constraint) {
                  String displayText = widget.label;
                  if (widget.label.trim().isNotEmpty) {
                    final TextPainter textPainter = TextPainter(
                        text: TextSpan(
                            text: widget.label, style: widget.labelStyle),
                        maxLines: 2,
                        textDirection: TextDirection.ltr
                        // overflow: TextOverflow.ellipsis,
                        )
                      ..layout(maxWidth: constraint.maxWidth - 50);

                    if (textPainter.didExceedMaxLines) {
                      final endIndex = textPainter
                          .getPositionForOffset(
                              Offset(textPainter.width, textPainter.height))
                          .offset;
                      displayText = "${widget.label.substring(0, endIndex)}...";
                    }
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    // textBaseline: TextBaseline.alphabetic,
                    children: [
                      if (widget.showLabel)
                        Flexible(
                          child: FocusableActionDetector(
                            focusNode: _textFocusNode,
                            child: InkWell(
                                onTap: widget.onTextTap,
                                child: Text.rich(
                                  TextSpan(text: displayText, children: [
                                    if (widget.isRequired)
                                      WidgetSpan(
                                        alignment:
                                            PlaceholderAlignment.baseline,
                                        baseline: TextBaseline.alphabetic,
                                        child: Transform.translate(
                                          // move it slightly down (positive y goes down)
                                          offset: const Offset(
                                              0, 4), // tweak 1–3 px to taste
                                          child: const Text(
                                            ' *',
                                            style: TextStyle(
                                              color: AppColors.failure,
                                              // Keep same font size as base text so width matches,
                                              // but we’re nudging its baseline down via translate.
                                              // fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (widget.exponent != null)
                                      TextSpan(
                                        text: " ${widget.exponent}",
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontFeatures: [
                                            FontFeature.superscripts(),
                                            FontFeature.enable('sups')
                                          ],
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
                                              color: widget.iconColor ??
                                                  AppColors.black,
                                              size: widget.iconSize ?? 20.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (widget.infoContent != null)
                                      WidgetSpan(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 4.0),
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
                                  ]),
                                  style: widget.labelStyle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ),
                        ),
                      SizedBox(width: widget.spacing),
                    ],
                  );
                }),
              ),
              SizedBox(height: widget.verticalSpace),
              if (widget.child != null) widget.child!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textFocusNode.dispose();
    _iconFocusNode.dispose();
    super.dispose();
  }
}
