import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/features/request/information/create_request/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays the Business Segment field used during request creation.
///
/// The field is bound to the provided [CreateRequestViewModel] and
/// allows users to view or select the applicable business segment.
class BussinessSegmentField extends StatelessWidget {
  /// Creates a [BussinessSegmentField].
  const BussinessSegmentField({
    required this.viewModel,
    super.key,
  });

  /// View model that supplies data and handles interactions
  /// for the Business Segment field.
  final CreateRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      isRequired: true,
      // infoContent: "requestInformation.createRequest.nbfiMessage".tr(),
      label: "requestInformation.createRequest.bussinessSegment".tr(),
      label2: "requestInformation.createRequest.bussinessSegment2".tr(),
      child: CustomRadioButton<Reference>(
        options: viewModel.bussinessSegments,
        selectedValue: viewModel.businessSegmentValue ?? Reference(),
        onChanged: (value) async {
          await viewModel.onBussinessSegmentSelected(value);
        },
        itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) {
          return Text(item.name ?? "");
        },
        isRequired: true,
        scrollDirection: Axis.horizontal,
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
