  import "dart:ui" as ui;
  import "package:flutter/material.dart";

  /// A wrapper around [SelectableText] that supports both plain text and rich
  /// text content with configurable selection behavior.
  class CustomSelectableText extends StatelessWidget {
    /// Creates a [CustomSelectableText].
    ///
    /// Either [text] or [textSpan] must be provided.
    const CustomSelectableText({
      super.key,
      this.text,
      this.textSpan,
      this.style,
      this.textAlign,
      this.maxLines,
      this.focusNode,
      this.strutStyle,
      this.textDirection,
      this.textScaler,
      this.showCursor = false,
      this.autofocus = false,
      this.cursorWidth = 2.0,
      this.cursorHeight,
      this.cursorRadius,
      this.cursorColor,
      this.selectionHeightStyle = ui.BoxHeightStyle.tight,
      this.selectionWidthStyle = ui.BoxWidthStyle.tight,
      this.enableInteractiveSelection = true,
      this.onTap,
      this.scrollPhysics,
      this.semanticsLabel,
      this.textHeightBehavior,
      this.textWidthBasis,
      this.onSelectionChanged,
    }) : assert(
            text != null || textSpan != null,
            "Either text or textSpan must be provided",
          );

    /// Plain text content.
    final String? text;

    /// Rich text content.
    final TextSpan? textSpan;

    /// Text style.
    final TextStyle? style;

    /// Alignment of the text.
    final TextAlign? textAlign;

    /// Maximum number of lines.
    final int? maxLines;

    /// Focus node for text selection.
    final FocusNode? focusNode;

    /// Strut style applied to the text.
    final StrutStyle? strutStyle;

    /// Text direction.
    final TextDirection? textDirection;

    /// Text scaling configuration.
    final TextScaler? textScaler;

    /// Whether to display the cursor.
    final bool showCursor;

    /// Whether this widget should autofocus.
    final bool autofocus;

    /// Width of the cursor.
    final double cursorWidth;

    /// Height of the cursor.
    final double? cursorHeight;

    /// Radius of the cursor corners.
    final Radius? cursorRadius;

    /// Cursor color.
    final Color? cursorColor;

    /// Height style used for text selection.
    final ui.BoxHeightStyle selectionHeightStyle;

    /// Width style used for text selection.
    final ui.BoxWidthStyle selectionWidthStyle;

    /// Whether text selection is enabled.
    final bool enableInteractiveSelection;

    /// Callback invoked when the text is tapped.
    final GestureTapCallback? onTap;

    /// Scroll physics used by the text view.
    final ScrollPhysics? scrollPhysics;

    /// Accessibility label.
    final String? semanticsLabel;

    /// Text height behavior.
    final TextHeightBehavior? textHeightBehavior;

    /// Strategy for measuring text width.
    final TextWidthBasis? textWidthBasis;

    /// Callback invoked when the text selection changes.
    final Function(TextSelection, SelectionChangedCause?)? onSelectionChanged;

    @override
    Widget build(BuildContext context) {
      return SelectableText.rich(
        textSpan ??
            TextSpan(
              text: text,
              style: style ?? Theme.of(context).textTheme.bodyMedium,
            ),
        style: style ?? Theme.of(context).textTheme.bodyMedium,
        textAlign: textAlign,
        maxLines: maxLines,
        focusNode: focusNode,
        strutStyle: strutStyle,
        textDirection: textDirection,
        textScaler: textScaler,
        showCursor: showCursor,
        autofocus: autofocus,
        cursorWidth: cursorWidth,
        cursorHeight: cursorHeight,
        cursorRadius: cursorRadius,
        cursorColor: cursorColor,
        selectionHeightStyle: selectionHeightStyle,
        selectionWidthStyle: selectionWidthStyle,
        enableInteractiveSelection: enableInteractiveSelection,
        onTap: onTap,
        scrollPhysics: scrollPhysics,
        semanticsLabel: semanticsLabel,
        textHeightBehavior: textHeightBehavior,
        textWidthBasis: textWidthBasis,
        onSelectionChanged: onSelectionChanged,
      );
    }
  }
