part of "../table.dart";

class StackedHeader {
  StackedHeader({
    this.startIndex = -1,
    this.endIndex = -1,
    this.width,
    this.widget,
  });
  final int startIndex;
  final int endIndex;
  double? width;
  final Widget? widget;
}
