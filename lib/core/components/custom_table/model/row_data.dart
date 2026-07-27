part of "../table.dart";

/// Row data model.
class RowData {
  /// Creates a [RowData].
  RowData({
    required this.id,
    required this.cells,
    required this.dropdownValues,
    required this.isFilterRow,
    this.rowColor,
  });

  /// Row identifier.
  final String id;

  /// Row cells.
  final List<Widget> cells;

  /// Dropdown values.
  final List<dynamic> dropdownValues;

  /// Row color.
  final Color? rowColor;

  /// Filter row flag.
  final bool isFilterRow;
}

/// Row model.
class RowModel {
  /// Creates a [RowModel].
  RowModel({
    required this.widget,
    required this.isFilterRow,
    this.color,
  });

  /// Row widgets.
  final List<Widget> widget;

  /// Row color.
  final Color? color;

  /// Filter row flag.
  final bool isFilterRow;
}
