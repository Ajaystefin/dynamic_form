part of "../table.dart";

class RowData {
  RowData({
    required this.id,
    required this.cells,
    required this.dropdownValues,
    required this.isFilterRow,
    this.rowColor,
  });
  final String id;
  final List<Widget> cells;
  final List<dynamic> dropdownValues;
  final Color? rowColor;
  final bool isFilterRow;
}

class RowModel {
  RowModel({
    required this.widget,
    required this.isFilterRow,
    this.color,
  });
  final List<Widget> widget;
  final Color? color;
  final bool isFilterRow;
}
