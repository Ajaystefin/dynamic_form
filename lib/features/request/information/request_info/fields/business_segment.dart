import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

/// Displays the Business Segment field on the Request Information screen.
///
/// Allows users to view the business segment associated with the
/// current request.
class BusinessSegmentField extends StatelessWidget {
  /// Creates a [BusinessSegmentField].
  const BusinessSegmentField({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages business segment-related behavior.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // viewModel.applicationDetails?.businessSegment?.isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.businessSegment".tr(),
          child: CustomTextField(
            filled: true,
            semanticLabel:
                "requestInformation.requestInformation.businessSegment".tr(),
            readOnly: true,
            initialValue: ((viewModel.isFI)
                ? viewModel.applicationDetails?.businessSegment ??
                    Globals.user?.segments?.first ??
                    Globals.request?.businessSegment?.name ??
                    ""
                : viewModel.applicationDetails?.businessSegment ??
                    Globals.request?.businessSegment?.name ??
                    Globals.user?.segments?.first ??
                    ""),
            onSaved: (String? value) {
              viewModel.applicationDetails?.businessSegment = value;
            },
          ),
        ),
      ],
    );
  }
}
