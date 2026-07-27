import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/model.dart";

/// Text field widget that displays the business segment value.
class BusinessSegmentField extends StatelessWidget {
  /// Creates a [BusinessSegmentField] widget.
  const BusinessSegmentField({required this.viewModel, super.key});

  /// View model used to read and save business segment data.
  final RequestInformationViewModel viewModel;

  /// Builds the read-only business segment field.
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "requestInformation.requestInformation.businessSegment".tr(),
      child: CustomTextField(
        filled: true,
        semanticLabel:
            "requestInformation.requestInformation.businessSegment".tr(),
        readOnly: true,
        initialValue: (viewModel.applicationDetails?.businessSegment ??
                Globals.request?.businessSegment?.name ??
                "")
            .capitalizeFirstLetter(),
        onSaved: (String? value) {
          viewModel.applicationDetails?.businessSegment = value;
        },
      ),
    );
  }
}
