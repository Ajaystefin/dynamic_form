import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";

class SegmentField extends StatelessWidget {
  const SegmentField({required this.viewModel, super.key});
  final OthersLimitDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label:
          "Segment".tr(), // Replace with your localization key if you have one
      isRequired: true,
      child: Align(
        alignment: Alignment.centerLeft,
        child: CustomRadioButton<Segment>(
          isEnabled: true,
          options: Segment.values,
          // Default to Corporate when nothing selected yet
          selectedValue: viewModel.selectedSegment ?? Segment.corporate,
          onChanged: (selected) {
            viewModel.changeSegment(selected);
          },
          // Render "Corporate" / "FI"
          itemBuilder: (context, item, isSelected, isEnabled) =>
              Text(viewModel.segmentLabel(item)),
          // Mandatory validation
          validator: (_) => CustomValidator.requiredField(
            (viewModel.selectedSegment != null)
                ? viewModel.segmentLabel(viewModel.selectedSegment!)
                : viewModel.segmentLabel(Segment.corporate),
          ),
          isRequired: true,
          scrollDirection: Axis.horizontal,
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
