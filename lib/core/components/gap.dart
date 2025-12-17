import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

enum GapSize { small, medium, large, form }

class Gap extends StatelessWidget {
  final GapSize size;
  final Axis direction;
  final double? customValue; // if used, default gap will be ignored

  const Gap({
    super.key,
    this.size = GapSize.medium,
    this.direction = Axis.vertical,
    this.customValue,
  });

  double get _sizeValue {
    switch (size) {
      case GapSize.small:
        return AppStyle.spacingSmall;
      case GapSize.medium:
        return AppStyle.spacing;
      case GapSize.large:
        return AppStyle.spacingLarge;
      case GapSize.form:
        return AppStyle.spacingForm;
    }
  }

  @override
  Widget build(BuildContext context) {
    return direction == Axis.vertical
        ? SizedBox(height: customValue ?? _sizeValue)
        : SizedBox(width: customValue ?? _sizeValue);
  }
}
