import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// A customizable tooltip widget that supports plain text,
/// rich content, and side-overlay display modes.
class CustomTooltip extends StatelessWidget {
  /// Creates a [CustomTooltip].
  const CustomTooltip({
    required this.message,
    required this.child,
    super.key,
    this.textStyle,
    this.decoration,
    this.waitDuration,
    this.height,
    this.padding,
    this.margin,
    this.preferBelow,
    this.showDuration,
    this.verticalOffset,
    this.textAlign,
    this.showTooltip = true,
    this.isRichMessage = false,
    this.showSideOverlay = false,
    this.sideOverlayOffset = const Offset(170, -10),
    this.sideOverlayWidth = 300,
    this.sideOverlayMaxHeight,
  });

  /// Tooltip message content.
  final String message;

  /// Widget that triggers the tooltip.
  final Widget child;

  /// Text style applied to the tooltip content.
  final TextStyle? textStyle;

  /// Decoration applied to the tooltip container.
  final Decoration? decoration;

  /// Delay before showing the tooltip.
  final Duration? waitDuration;

  /// Tooltip height.
  final double? height;

  /// Padding inside the tooltip.
  final EdgeInsetsGeometry? padding;

  /// Margin around the tooltip.
  final EdgeInsetsGeometry? margin;

  /// Whether the tooltip should appear below the child.
  final bool? preferBelow;

  /// Controls whether the tooltip is enabled.
  final bool showTooltip;

  /// Duration for which the tooltip remains visible.
  final Duration? showDuration;

  /// Vertical offset from the child widget.
  final double? verticalOffset;

  /// Alignment of the tooltip text.
  final TextAlign? textAlign;

  /// Indicates whether the tooltip content should be rendered
  /// as rich content.
  final bool isRichMessage;

  /// Displays the tooltip as a side overlay instead of a standard tooltip.
  final bool showSideOverlay;

  /// Offset applied when displaying the side overlay.
  final Offset sideOverlayOffset;

  /// Width of the side overlay tooltip.
  final double sideOverlayWidth;

  /// Maximum height of the side overlay tooltip.
  final double? sideOverlayMaxHeight;

  @override
  Widget build(BuildContext context) {
    if (!showTooltip) {
      return child;
    }

    //sideways mode only when explicitly requested
    if (showSideOverlay) {
      return _SideOverlayTooltip(
        message: message,
        textStyle: textStyle,
        decoration: decoration,
        padding: padding,
        offset: sideOverlayOffset,
        width: sideOverlayWidth,
        maxHeight: sideOverlayMaxHeight,
        textAlign: textAlign,
        isRichMessage: isRichMessage,
        child: child,
      );
    }

    return Tooltip(
      message: isRichMessage ? null : message,
      richMessage: isRichMessage
          ? WidgetSpan(
              child: SizedBox(
                width: 300,
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppStyle.columnName,
                  ),
                ),
              ),
            )
          : null,
      height: height,
      // constraints:
      //     height != null ? BoxConstraints(minHeight: height ?? 0) : null,
      textStyle: isRichMessage
          ? null
          : const TextStyle(
              color: AppColors.white,
              fontSize: AppStyle.columnName,
            ),
      decoration: BoxDecoration(
        color: AppColors.customToolTipBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.customToolTipBg),
      ),
      waitDuration: waitDuration ?? Duration.zero,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: margin ?? const EdgeInsets.only(top: 16, bottom: 16),
      preferBelow: preferBelow ?? false,
      showDuration: showDuration ?? const Duration(seconds: 2),
      verticalOffset: verticalOffset ?? 10.0,
      textAlign: textAlign ?? TextAlign.center,
      child: child,
    );
  }
}

class _SideOverlayTooltip extends StatefulWidget {
  const _SideOverlayTooltip({
    required this.message,
    required this.child,
    required this.offset,
    required this.width,
    required this.maxHeight,
    required this.isRichMessage,
    this.textStyle,
    this.decoration,
    this.padding,
    this.textAlign,
  });

  final String message;
  final Widget child;
  final TextStyle? textStyle;
  final Decoration? decoration;
  final EdgeInsetsGeometry? padding;
  final Offset offset;
  final double width;
  final double? maxHeight;
  final TextAlign? textAlign;
  final bool isRichMessage;

  @override
  State<_SideOverlayTooltip> createState() => _SideOverlayTooltipState();
}

class _SideOverlayTooltipState extends State<_SideOverlayTooltip> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showOverlay() {
    if (_overlayEntry != null || widget.message.trim().isEmpty) {
      return;
    }

    final OverlayState overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: IgnorePointer(
            // IMPORTANT: do not block clicking the link
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: widget.offset,
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: widget.width,
                    constraints: widget.maxHeight != null
                        ? BoxConstraints(maxHeight: widget.maxHeight!)
                        : null,
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                    decoration: widget.decoration ??
                        BoxDecoration(
                          color: AppColors.customToolTipBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.customToolTipBg),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 8,
                              offset: Offset(0, 2),
                              color: Colors.black26,
                            ),
                          ],
                        ),
                    child: widget.maxHeight != null
                        ? SingleChildScrollView(
                            child: SizedBox(
                              width: widget.width,
                              child: Text(
                                widget.message,
                                textAlign: widget.textAlign ?? TextAlign.left,
                                softWrap: true,
                                style: widget.textStyle ??
                                    const TextStyle(
                                      color: Colors.white,
                                      fontSize: AppStyle.columnName,
                                    ),
                              ),
                            ),
                          )
                        : SizedBox(
                            width: widget.width,
                            child: Text(
                              widget.message,
                              textAlign: widget.textAlign ?? TextAlign.left,
                              softWrap: true,
                              style: widget.textStyle ??
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: AppStyle.columnName,
                                  ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _showOverlay(),
      onExit: (_) => _hideOverlay(),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: widget.child,
      ),
    );
  }
}
