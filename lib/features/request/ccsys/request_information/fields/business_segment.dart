import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/model.dart";

class BusinessSegmentField extends StatelessWidget {
  const BusinessSegmentField({required this.viewModel, super.key});
  final RequestInformationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "requestInformation.requestInformation.businessSegment".tr(),
      isRequired: false,
      showLabel: true,
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
