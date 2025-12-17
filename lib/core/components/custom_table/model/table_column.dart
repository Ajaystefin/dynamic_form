part of '../table.dart';

class TableColumn extends DataColumn {
  final bool isStacked;
  final double? width;
  final double? forcedWidth;

  ///[forcedWidth] will be applied even [autofitWidth] is true
  const TableColumn({
    this.width,
    this.forcedWidth,
    this.isStacked = false,
    required super.label,
    super.columnWidth,
    super.headingRowAlignment,
    super.mouseCursor,
    super.numeric,
    super.onSort,
    super.tooltip,
  });
}
