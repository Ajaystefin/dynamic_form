part of '../table.dart';

class RowData {
  final String id;
  final List<Widget> cells;
  final List<dynamic> dropdownValues;
  final Color? rowColor;
  final bool isFilterRow;


  RowData({
    required this.id,
    required this.cells,
    required this.dropdownValues,
    this.rowColor,
    required this.isFilterRow,

  });
}

class RowModel {
  final List<Widget> widget;
  final Color? color;
  final bool isFilterRow;

  RowModel({
    required this.widget,
    this.color,
    required this.isFilterRow,
  });
}
