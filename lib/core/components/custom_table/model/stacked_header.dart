part of "../table.dart";

/// Stacked table header configuration.
class StackedHeader {
  /// Creates a [StackedHeader].
  StackedHeader({
    this.startIndex = -1,
    this.endIndex = -1,
    this.width,
    this.widget,
  });

  /// Start column index.
  final int startIndex;

  /// End column index.
  final int endIndex;

  /// Header width.
  double? width;

  /// Header widget.
  final Widget? widget;
}
