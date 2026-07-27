import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// Available gap sizes.
enum GapSize {
  /// Small gap.
  small,

  /// Medium gap.
  medium,

  /// Large gap.
  large,

  /// Form spacing gap.
  form,
}

/// A spacing widget used to add vertical or horizontal gaps.
class Gap extends StatelessWidget {
  // if used, default gap will be ignored

  /// Creates a [Gap].
  const Gap({
    super.key,
    this.size = GapSize.medium,
    this.direction = Axis.vertical,
    this.customValue,
  });

  /// Preset gap size.
  final GapSize size;

  /// Gap direction.
  final Axis direction;

  /// Custom gap value.
  final double? customValue;

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
