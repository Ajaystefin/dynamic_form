part of "../table.dart";

class TableColumn extends DataColumn {
  ///[forcedWidth] will be applied even [autofitWidth] is true
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
  final bool isStacked;
  final double? width;
  final double? forcedWidth;
}
