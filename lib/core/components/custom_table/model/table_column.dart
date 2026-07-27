part of "../table.dart";

/// Table column configuration.
class TableColumn extends DataColumn {
  /// Creates a [TableColumn].
  ///
  /// [forcedWidth] will be applied even when `autoFitWidth` is true.
  const TableColumn({
    required super.label,
    this.width,
    this.forcedWidth,
    this.isStacked = false,
    super.columnWidth,
    super.headingRowAlignment,
    super.mouseCursor,
    super.numeric,
    super.onSort,
    super.tooltip,
  });

  /// Indicates whether the column is part of a stacked header.
  final bool isStacked;

  /// Column width.
  final double? width;

  /// Fixed column width.
  final double? forcedWidth;
}
