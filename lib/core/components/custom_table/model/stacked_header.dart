part of '../table.dart';

class StackedHeader {
  final int startIndex;
  final int endIndex;
  double? width;
  final Widget? widget;
  StackedHeader({
    this.startIndex = -1,
    this.endIndex = -1,
    this.width,
    this.widget,
  });
}
